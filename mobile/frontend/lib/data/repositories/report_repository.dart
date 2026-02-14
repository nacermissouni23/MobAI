import 'package:frontend/data/models/report.dart';
import 'base_repository.dart';

class ReportRepository extends BaseRepository<Report> {
  ReportRepository() : super('reports');

  @override
  Report fromMap(Map<String, dynamic> map) => Report.fromMap(map);

  @override
  Map<String, dynamic> toMap(Report entity) => entity.toMap();

  // ── Domain queries ────────────────────────────────────────

  /// Get reports for a specific operation.
  Future<List<Report>> getByOperation(String operationId) {
    return query(
      where: 'operation_id = ?',
      whereArgs: [operationId],
      orderBy: 'created_at DESC',
    );
  }

  /// Get reports filed by a specific user.
  Future<List<Report>> getByReporter(String userId) {
    return query(
      where: 'reported_by = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  /// Get reports with anomalies (missing, damage, or extra).
  Future<List<Report>> getAnomalies() {
    return query(
      where: 'missing_quantity > 0 OR physical_damage = 1 OR extra_quantity > 0',
      orderBy: 'created_at DESC',
    );
  }

  /// Get all reports sorted by date.
  Future<List<Report>> getAllSorted() {
    return getAll(orderBy: 'created_at DESC');
  }

  /// Get recent reports.
  Future<List<Report>> getRecent({int limit = 20}) {
    return getAll(orderBy: 'created_at DESC', limit: limit);
  }

  /// Count anomalies by type.
  Future<Map<String, int>> countAnomalies() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN missing_quantity > 0 THEN 1 ELSE 0 END) as missing,
        SUM(CASE WHEN physical_damage = 1 THEN 1 ELSE 0 END) as damaged,
        SUM(CASE WHEN extra_quantity > 0 THEN 1 ELSE 0 END) as extra
      FROM reports WHERE is_deleted = 0
    ''');
    if (result.isEmpty) return {'missing': 0, 'damaged': 0, 'extra': 0};
    return {
      'missing': (result.first['missing'] as int?) ?? 0,
      'damaged': (result.first['damaged'] as int?) ?? 0,
      'extra': (result.first['extra'] as int?) ?? 0,
    };
  }
}
