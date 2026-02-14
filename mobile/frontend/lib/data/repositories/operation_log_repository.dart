import 'package:frontend/data/models/operation_log.dart';
import 'package:frontend/data/enums.dart';
import 'base_repository.dart';

class OperationLogRepository extends BaseRepository<OperationLog> {
  OperationLogRepository() : super('operation_logs');

  @override
  OperationLog fromMap(Map<String, dynamic> map) => OperationLog.fromMap(map);

  @override
  Map<String, dynamic> toMap(OperationLog entity) => entity.toMap();

  // ── Domain queries ────────────────────────────────────────

  /// Get logs for a specific operation.
  Future<List<OperationLog>> getByOperation(String operationId) {
    return query(
      where: 'operation_id = ?',
      whereArgs: [operationId],
      orderBy: 'created_at DESC',
    );
  }

  /// Get logs by employee.
  Future<List<OperationLog>> getByEmployee(String employeeId) {
    return query(
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      orderBy: 'created_at DESC',
    );
  }

  /// Get all override logs (where someone overrode AI suggestion).
  Future<List<OperationLog>> getOverrides() {
    return query(
      where: 'overrider_id IS NOT NULL',
      orderBy: 'created_at DESC',
    );
  }

  /// Get logs by type.
  Future<List<OperationLog>> getByType(OperationType type) {
    return query(
      where: 'type = ?',
      whereArgs: [type.value],
      orderBy: 'created_at DESC',
    );
  }

  /// Get all logs sorted by date (most recent first).
  Future<List<OperationLog>> getAllSorted({int? limit}) {
    return getAll(orderBy: 'created_at DESC', limit: limit);
  }

  /// Get recent logs (last N entries).
  Future<List<OperationLog>> getRecent({int limit = 50}) {
    return getAll(orderBy: 'created_at DESC', limit: limit);
  }
}
