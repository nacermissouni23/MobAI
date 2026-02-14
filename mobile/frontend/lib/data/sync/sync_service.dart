import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:frontend/data/api/api_client.dart';
import 'package:frontend/data/api/api_config.dart';
import 'package:frontend/data/database/database_helper.dart';
import 'package:frontend/data/repositories/repositories.dart';
import 'package:frontend/data/models/models.dart';

/// Sync status for UI display.
enum SyncStatus { idle, syncing, success, error }

/// Full sync service implementing the Fetch-Before-Write pattern.
///
/// Flow (per the offline-first diagram):
/// 1. Pull latest from server → merge into local DB
/// 2. Push local pending changes → mark as synced
/// 3. Update sync_metadata timestamps
class SyncService {
  final ApiClient apiClient;
  final UserRepository userRepo;
  final ProductRepository productRepo;
  final EmplacementRepository emplacementRepo;
  final ChariotRepository chariotRepo;
  final OrderRepository orderRepo;
  final OperationRepository operationRepo;
  final OperationLogRepository operationLogRepo;
  final ReportRepository reportRepo;
  final StockLedgerRepository stockLedgerRepo;

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;
  String? _lastError;
  String? get lastError => _lastError;

  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;

  SyncService({
    required this.apiClient,
    required this.userRepo,
    required this.productRepo,
    required this.emplacementRepo,
    required this.chariotRepo,
    required this.orderRepo,
    required this.operationRepo,
    required this.operationLogRepo,
    required this.reportRepo,
    required this.stockLedgerRepo,
  });

  /// Run a full sync cycle: pull then push.
  Future<void> syncAll() async {
    if (_status == SyncStatus.syncing) return;
    _setStatus(SyncStatus.syncing);
    _lastError = null;

    try {
      // Check server reachability first
      if (!apiClient.hasToken) {
        throw Exception('Not authenticated. Please login first.');
      }

      final reachable = await apiClient.isServerReachable();
      if (!reachable) {
        throw Exception('Server is not reachable. Changes saved locally.');
      }

      // Step 1: Pull remote changes (Fetch)
      await _pullFromServer();

      // Step 2: Push local pending changes (Write)
      await _pushToServer();

      // Step 3: Update last sync timestamp
      await _updateSyncTimestamp();

      _setStatus(SyncStatus.success);
    } catch (e) {
      _lastError = e.toString();
      _setStatus(SyncStatus.error);
    }
  }

  /// Step 1: Pull server data and merge into local DB.
  Future<void> _pullFromServer() async {
    final lastSync = await getLastSyncTime();
    final sinceParam = lastSync?.toIso8601String();

    // GET /api/sync/updates?since=<timestamp>
    final Map<String, String> queryParams = {};
    if (sinceParam != null) queryParams['since'] = sinceParam;

    final response = await apiClient.get(
      ApiConfig.syncUpdatesUrl,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response is Map<String, dynamic>) {
      // Merge each entity type
      await _mergeEntities<User>(
        response['users'] as List? ?? [],
        userRepo,
        (json) => User.fromJson(json as Map<String, dynamic>),
      );
      await _mergeEntities<Product>(
        response['products'] as List? ?? [],
        productRepo,
        (json) => Product.fromJson(json as Map<String, dynamic>),
      );
      await _mergeEntities<Emplacement>(
        response['emplacements'] as List? ?? [],
        emplacementRepo,
        (json) => Emplacement.fromJson(json as Map<String, dynamic>),
      );
      await _mergeEntities<Chariot>(
        response['chariots'] as List? ?? [],
        chariotRepo,
        (json) => Chariot.fromJson(json as Map<String, dynamic>),
      );
      await _mergeEntities<Order>(
        response['orders'] as List? ?? [],
        orderRepo,
        (json) => Order.fromJson(json as Map<String, dynamic>),
      );
      await _mergeEntities<Operation>(
        response['operations'] as List? ?? [],
        operationRepo,
        (json) => Operation.fromJson(json as Map<String, dynamic>),
      );
      await _mergeEntities<OperationLog>(
        response['operation_logs'] as List? ?? [],
        operationLogRepo,
        (json) => OperationLog.fromJson(json as Map<String, dynamic>),
      );
      await _mergeEntities<Report>(
        response['reports'] as List? ?? [],
        reportRepo,
        (json) => Report.fromJson(json as Map<String, dynamic>),
      );
      await _mergeEntities<StockLedger>(
        response['stock_ledger'] as List? ?? [],
        stockLedgerRepo,
        (json) => StockLedger.fromJson(json as Map<String, dynamic>),
      );
    }
  }

  /// Merge server entities into local DB.
  /// Conflict resolution: server wins if local has no pending changes.
  Future<void> _mergeEntities<T>(
    List serverRecords,
    BaseRepository<T> repo,
    T Function(dynamic json) fromJson,
  ) async {
    for (final record in serverRecords) {
      if (record is! Map<String, dynamic>) continue;
      final serverId = record['id'] as String?;
      if (serverId == null) continue;

      try {
        // Find local record by server_id
        final localRecord = await repo.findOne('server_id', serverId);

        if (localRecord == null) {
          // No local record → insert from server
          final entity = fromJson(record);
          await repo.insertFromServer(entity, serverId);
        } else {
          // Local record exists
          final localMap = repo.toMap(localRecord);
          final localSyncPending = localMap['sync_pending'] == 1;

          if (!localSyncPending) {
            // No local changes → update with server data
            final entity = fromJson(record);
            final map = repo.toMap(entity);
            final localId = localMap['id'] as String;
            map.remove('id');
            map['server_id'] = serverId;
            map['sync_pending'] = 0;
            map['last_synced_at'] = DateTime.now().toIso8601String();
            await repo.update(localId, map);
          }
          // If local has pending changes, skip (local wins until pushed)
        }
      } catch (e) {
        // Log but continue with other records
        // ignore individual merge errors
      }
    }
  }

  /// Step 2: Push pending local changes to server.
  Future<void> _pushToServer() async {
    final body = <String, dynamic>{};

    // Collect pending records from each repo
    body['operations'] = await _collectPending(operationRepo);
    body['orders'] = await _collectPending(orderRepo);
    body['products'] = await _collectPending(productRepo);
    body['emplacements'] = await _collectPending(emplacementRepo);
    body['chariots'] = await _collectPending(chariotRepo);
    body['operation_logs'] = await _collectPending(operationLogRepo);
    body['reports'] = await _collectPending(reportRepo);
    body['stock_movements'] = await _collectPending(stockLedgerRepo);

    // Check if there's anything to push
    final hasData = body.values.any((list) => (list as List).isNotEmpty);
    if (!hasData) return;

    // POST /api/sync/batch
    final response = await apiClient.post(ApiConfig.syncBatchUrl, body: body);

    if (response is Map<String, dynamic>) {
      // Process sync results and mark records as synced
      await _processSyncResults(response, 'operations', operationRepo);
      await _processSyncResults(response, 'orders', orderRepo);
      await _processSyncResults(response, 'products', productRepo);
      await _processSyncResults(response, 'emplacements', emplacementRepo);
      await _processSyncResults(response, 'chariots', chariotRepo);
      await _processSyncResults(response, 'operation_logs', operationLogRepo);
      await _processSyncResults(response, 'reports', reportRepo);
      await _processSyncResults(response, 'stock_movements', stockLedgerRepo);
    }
  }

  /// Collect pending sync items from a repository.
  Future<List<Map<String, dynamic>>> _collectPending<T>(
    BaseRepository<T> repo,
  ) async {
    final pending = await repo.getPendingSync();
    return pending.map((entity) {
      final map = repo.toMap(entity);
      return {
        'local_id': map['id'],
        'server_id': map['server_id'],
        'data': _toSyncData(map),
        'client_timestamp': DateTime.now().toIso8601String(),
        'is_deleted': map['is_deleted'] == 1,
      };
    }).toList();
  }

  /// Convert local map to sync-compatible data (strip sync metadata).
  Map<String, dynamic> _toSyncData(Map<String, dynamic> map) {
    final data = Map<String, dynamic>.from(map);
    data.remove('sync_pending');
    data.remove('last_synced_at');
    data.remove('is_deleted');
    data.remove('server_id');
    // Keep 'id' as local reference
    return data;
  }

  /// Process sync results: mark local records as synced with server IDs.
  Future<void> _processSyncResults<T>(
    Map<String, dynamic> response,
    String entityKey,
    BaseRepository<T> repo,
  ) async {
    final entityResult = response[entityKey] as Map<String, dynamic>?;
    if (entityResult == null) return;

    final synced = entityResult['synced'] as List? ?? [];
    for (final item in synced) {
      if (item is Map<String, dynamic>) {
        final localId = item['local_id'] as String?;
        final serverId = item['server_id'] as String?;
        if (localId != null && serverId != null) {
          await repo.markSynced(localId, serverId);
        }
      }
    }

    // Also handle skipped (already on server)
    final skipped = entityResult['skipped'] as List? ?? [];
    for (final item in skipped) {
      if (item is Map<String, dynamic>) {
        final localId = item['local_id'] as String?;
        final serverId = item['server_id'] as String?;
        if (localId != null && serverId != null) {
          await repo.markSynced(localId, serverId);
        }
      }
    }
  }

  /// Update sync_metadata with current timestamp.
  Future<void> _updateSyncTimestamp() async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();
    await db.insert('sync_metadata', {
      'key': 'last_full_sync',
      'value': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get last full sync timestamp.
  Future<DateTime?> getLastSyncTime() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'sync_metadata',
      where: "key = 'last_full_sync'",
      limit: 1,
    );
    if (result.isEmpty) return null;
    return DateTime.tryParse(result.first['value'] as String);
  }

  /// Check if there are local changes pending sync.
  Future<bool> hasPendingChanges() async {
    final List<BaseRepository> repos = [
      userRepo,
      productRepo,
      emplacementRepo,
      chariotRepo,
      orderRepo,
      operationRepo,
      operationLogRepo,
      reportRepo,
      stockLedgerRepo,
    ];
    for (final repo in repos) {
      final pending = await repo.getPendingSync();
      if (pending.isNotEmpty) return true;
    }
    return false;
  }

  /// Get count of pending changes per entity type.
  Future<Map<String, int>> getPendingCounts() async {
    return {
      'users': (await userRepo.getPendingSync()).length,
      'products': (await productRepo.getPendingSync()).length,
      'emplacements': (await emplacementRepo.getPendingSync()).length,
      'chariots': (await chariotRepo.getPendingSync()).length,
      'orders': (await orderRepo.getPendingSync()).length,
      'operations': (await operationRepo.getPendingSync()).length,
      'operation_logs': (await operationLogRepo.getPendingSync()).length,
      'reports': (await reportRepo.getPendingSync()).length,
      'stock_ledger': (await stockLedgerRepo.getPendingSync()).length,
    };
  }

  void _setStatus(SyncStatus s) {
    _status = s;
    _statusController.add(s);
  }

  void dispose() {
    _statusController.close();
  }
}
