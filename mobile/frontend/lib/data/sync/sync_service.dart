import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:frontend/data/database/database_helper.dart';
import 'package:frontend/data/repositories/repositories.dart';

/// Sync status for UI display.
enum SyncStatus { idle, syncing, success, error }

/// Skeleton sync service implementing the Fetch-Before-Write pattern.
/// Full implementation will connect to the backend API.
///
/// Flow (per the attached diagram):
/// 1. Pull latest from server → merge into local DB
/// 2. Push local pending changes → mark as synced
/// 3. Update sync_metadata timestamps
class SyncService {
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

  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;

  SyncService({
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

  /// Run a full sync cycle.
  Future<void> syncAll() async {
    if (_status == SyncStatus.syncing) return;
    _setStatus(SyncStatus.syncing);

    try {
      // Step 1: Fetch latest from server (pull)
      await _pullFromServer();

      // Step 2: Push local pending changes
      await _pushToServer();

      // Step 3: Update last sync timestamp
      await _updateSyncTimestamp();

      _setStatus(SyncStatus.success);
    } catch (e) {
      _setStatus(SyncStatus.error);
      rethrow;
    }
  }

  /// Pull server data and merge (placeholder).
  Future<void> _pullFromServer() async {
    // TODO: Implement when backend API is connected.
    // For each entity type:
    //   1. Get last_synced_at from sync_metadata
    //   2. Fetch server records modified since that timestamp
    //   3. For each server record:
    //      a. If local record exists with same server_id:
    //         - If local has sync_pending=0 → update local with server data
    //         - If local has sync_pending=1 → conflict resolution (server wins by default)
    //      b. If no local record → insert from server
  }

  /// Push pending local changes (placeholder).
  Future<void> _pushToServer() async {
    // TODO: Implement when backend API is connected.
    // For each entity type:
    //   1. Get all records with sync_pending=1
    //   2. For each pending record:
    //      a. If server_id is null → POST (create) → save returned server_id
    //      b. If server_id exists → PUT (update)
    //      c. If is_deleted=1 → DELETE on server → hard delete locally
    //   3. Mark all pushed records as synced
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

  void _setStatus(SyncStatus s) {
    _status = s;
    _statusController.add(s);
  }

  void dispose() {
    _statusController.close();
  }
}
