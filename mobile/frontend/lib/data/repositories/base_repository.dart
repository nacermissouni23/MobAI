import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:frontend/data/database/database_helper.dart';

const _uuid = Uuid();

/// Generic CRUD repository for SQLite tables.
/// All entity repositories extend this with table-specific queries.
abstract class BaseRepository<T> {
  final String tableName;

  BaseRepository(this.tableName);

  // ── Abstract conversion ───────────────────────────────────

  /// Convert a DB row map to a domain model.
  T fromMap(Map<String, dynamic> map);

  /// Convert a domain model to a DB row map.
  Map<String, dynamic> toMap(T entity);

  // ── Helpers ───────────────────────────────────────────────

  Future<Database> get database => DatabaseHelper.instance.database;

  /// Generate a new UUID for local records.
  String generateId() => _uuid.v4();

  /// Current ISO-8601 timestamp string.
  String _now() => DateTime.now().toIso8601String();

  // ── CREATE ────────────────────────────────────────────────

  /// Insert a new record. Sets sync_pending = 1 automatically.
  Future<T> insert(T entity) async {
    final db = await database;
    final map = toMap(entity);
    map['sync_pending'] = 1;
    map['updated_at'] = _now();
    if (map['created_at'] == null) {
      map['created_at'] = map['updated_at'];
    }
    await db.insert(
      tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return fromMap(map);
  }

  /// Insert multiple records in a batch.
  Future<void> insertAll(List<T> entities) async {
    final db = await database;
    final batch = db.batch();
    final now = _now();
    for (final entity in entities) {
      final map = toMap(entity);
      map['sync_pending'] = 1;
      map['updated_at'] = now;
      if (map['created_at'] == null) {
        map['created_at'] = now;
      }
      batch.insert(
        tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // ── READ ──────────────────────────────────────────────────

  /// Get a single record by local ID.
  Future<T?> getById(String id) async {
    final db = await database;
    final results = await db.query(
      tableName,
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return fromMap(results.first);
  }

  /// Get all non-deleted records.
  Future<List<T>> getAll({int? limit, String? orderBy}) async {
    final db = await database;
    final results = await db.query(
      tableName,
      where: 'is_deleted = 0',
      orderBy: orderBy,
      limit: limit,
    );
    return results.map(fromMap).toList();
  }

  /// Query with filters. Each filter is a column condition.
  Future<List<T>> query({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    final effectiveWhere = where != null
        ? '($where) AND is_deleted = 0'
        : 'is_deleted = 0';
    final results = await db.query(
      tableName,
      where: effectiveWhere,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
    return results.map(fromMap).toList();
  }

  /// Find a single record matching a field value.
  Future<T?> findOne(String field, Object value) async {
    final db = await database;
    final results = await db.query(
      tableName,
      where: '$field = ? AND is_deleted = 0',
      whereArgs: [value],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return fromMap(results.first);
  }

  /// Count records matching optional filters.
  Future<int> count({String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    final effectiveWhere = where != null
        ? '($where) AND is_deleted = 0'
        : 'is_deleted = 0';
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM $tableName WHERE $effectiveWhere',
      whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ── UPDATE ────────────────────────────────────────────────

  /// Update a record by ID. Sets sync_pending = 1 + updated_at.
  Future<int> update(String id, Map<String, dynamic> fields) async {
    final db = await database;
    fields['sync_pending'] = 1;
    fields['updated_at'] = _now();
    return db.update(tableName, fields, where: 'id = ?', whereArgs: [id]);
  }

  /// Replace a full entity by ID.
  Future<int> updateEntity(T entity) async {
    final db = await database;
    final map = toMap(entity);
    map['sync_pending'] = 1;
    map['updated_at'] = _now();
    return db.update(tableName, map, where: 'id = ?', whereArgs: [map['id']]);
  }

  // ── DELETE ────────────────────────────────────────────────

  /// Soft-delete a record (sets is_deleted = 1 + sync_pending = 1).
  Future<int> softDelete(String id) async {
    return update(id, {'is_deleted': 1});
  }

  /// Hard-delete a record (permanent, use after sync confirmation only).
  Future<int> hardDelete(String id) async {
    final db = await database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // ── SYNC HELPERS ──────────────────────────────────────────

  /// Get all records pending sync.
  Future<List<T>> getPendingSync() async {
    final db = await database;
    final results = await db.query(tableName, where: 'sync_pending = 1');
    return results.map(fromMap).toList();
  }

  /// Mark a record as synced (clear sync_pending, set server_id).
  Future<void> markSynced(String localId, String serverId) async {
    final db = await database;
    await db.update(
      tableName,
      {'sync_pending': 0, 'server_id': serverId, 'last_synced_at': _now()},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  /// Clear all sync_pending flags (after full sync).
  Future<void> clearAllSyncFlags() async {
    final db = await database;
    await db.update(tableName, {
      'sync_pending': 0,
      'last_synced_at': _now(),
    }, where: 'sync_pending = 1');
  }

  /// Insert a record from server (sync_pending = 0).
  Future<void> insertFromServer(T entity, String serverId) async {
    final db = await database;
    final map = toMap(entity);
    map['server_id'] = serverId;
    map['sync_pending'] = 0;
    map['last_synced_at'] = _now();
    await db.insert(
      tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
