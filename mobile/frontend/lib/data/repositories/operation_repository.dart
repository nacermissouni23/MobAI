import 'package:frontend/data/models/operation.dart';
import 'package:frontend/data/enums.dart';
import 'base_repository.dart';

class OperationRepository extends BaseRepository<Operation> {
  OperationRepository() : super('operations');

  @override
  Operation fromMap(Map<String, dynamic> map) => Operation.fromMap(map);

  @override
  Map<String, dynamic> toMap(Operation entity) => entity.toMap();

  // ── Domain queries ────────────────────────────────────────

  /// Get operations by type.
  Future<List<Operation>> getByType(OperationType type) {
    return query(
      where: 'type = ?',
      whereArgs: [type.value],
      orderBy: 'created_at DESC',
    );
  }

  /// Get operations by status.
  Future<List<Operation>> getByStatus(OperationStatus status) {
    return query(
      where: 'status = ?',
      whereArgs: [status.value],
      orderBy: 'created_at DESC',
    );
  }

  /// Get operations assigned to an employee.
  Future<List<Operation>> getByEmployee(String employeeId) {
    return query(
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      orderBy: 'created_at DESC',
    );
  }

  /// Get pending operations for an employee.
  Future<List<Operation>> getPendingForEmployee(String employeeId) {
    return query(
      where: "employee_id = ? AND status IN ('pending', 'in_progress')",
      whereArgs: [employeeId],
      orderBy: 'created_at ASC',
    );
  }

  /// Get operations linked to an order.
  Future<List<Operation>> getByOrder(String orderId) {
    return query(
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'created_at ASC',
    );
  }

  /// Get all operations sorted by date.
  Future<List<Operation>> getAllSorted() {
    return getAll(orderBy: 'created_at DESC');
  }

  /// Get pending operations (all employees).
  Future<List<Operation>> getAllPending() {
    return query(
      where: "status IN ('pending', 'in_progress')",
      orderBy: 'created_at ASC',
    );
  }

  /// Start an operation.
  Future<void> start(String operationId) {
    return update(operationId, {
      'status': OperationStatus.inProgress.value,
      'started_at': DateTime.now().toIso8601String(),
    }).then((_) {});
  }

  /// Complete an operation.
  Future<void> complete(String operationId, {String? validatorId}) {
    final fields = <String, dynamic>{
      'status': OperationStatus.completed.value,
      'completed_at': DateTime.now().toIso8601String(),
    };
    if (validatorId != null) {
      fields['validator_id'] = validatorId;
      fields['validated_at'] = DateTime.now().toIso8601String();
    }
    return update(operationId, fields).then((_) {});
  }

  /// Fail an operation.
  Future<void> fail(String operationId) {
    return update(operationId, {
      'status': OperationStatus.failed.value,
      'completed_at': DateTime.now().toIso8601String(),
    }).then((_) {});
  }

  /// Get operations by chariot.
  Future<List<Operation>> getByChariot(String chariotId) {
    return query(
      where: 'chariot_id = ?',
      whereArgs: [chariotId],
      orderBy: 'created_at DESC',
    );
  }

  /// Count operations by status.
  Future<Map<OperationStatus, int>> countByStatus() async {
    final db = await database;
    final results = await db.rawQuery(
      'SELECT status, COUNT(*) as cnt FROM operations WHERE is_deleted = 0 GROUP BY status',
    );
    final map = <OperationStatus, int>{};
    for (final row in results) {
      map[OperationStatus.fromString(row['status'] as String)] =
          row['cnt'] as int;
    }
    return map;
  }
}
