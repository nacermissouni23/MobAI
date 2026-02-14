import 'package:frontend/data/models/order.dart';
import 'package:frontend/data/enums.dart';
import 'base_repository.dart';

class OrderRepository extends BaseRepository<Order> {
  OrderRepository() : super('orders');

  @override
  Order fromMap(Map<String, dynamic> map) => Order.fromMap(map);

  @override
  Map<String, dynamic> toMap(Order entity) => entity.toMap();

  // ── Domain queries ────────────────────────────────────────

  /// Get orders by type.
  Future<List<Order>> getByType(OrderType type) {
    return query(
      where: 'type = ?',
      whereArgs: [type.value],
      orderBy: 'created_at DESC',
    );
  }

  /// Get orders by status.
  Future<List<Order>> getByStatus(OrderStatus status) {
    return query(
      where: 'status = ?',
      whereArgs: [status.value],
      orderBy: 'created_at DESC',
    );
  }

  /// Get pending orders (not yet completed).
  Future<List<Order>> getPending() {
    return query(
      where: "status IN ('pending', 'ai_generated', 'validated', 'overridden')",
      orderBy: 'created_at DESC',
    );
  }

  /// Get AI-generated orders.
  Future<List<Order>> getAiGenerated() {
    return query(
      where: 'generated_by_ai = 1',
      orderBy: 'created_at DESC',
    );
  }

  /// Get overridden orders.
  Future<List<Order>> getOverridden() {
    return query(
      where: 'overridden_by IS NOT NULL',
      orderBy: 'created_at DESC',
    );
  }

  /// Get all orders sorted by date.
  Future<List<Order>> getAllSorted() {
    return getAll(orderBy: 'created_at DESC');
  }

  /// Complete an order.
  Future<void> complete(String orderId, String completedBy) {
    return update(orderId, {
      'status': OrderStatus.completed.value,
      'completed_at': DateTime.now().toIso8601String(),
      'completed_by': completedBy,
    }).then((_) {});
  }

  /// Override an order.
  Future<void> overrideOrder(String orderId, {
    required String overriddenBy,
    required String reason,
  }) {
    return update(orderId, {
      'status': OrderStatus.overridden.value,
      'overridden_by': overriddenBy,
      'override_reason': reason,
    }).then((_) {});
  }

  /// Validate (accept) an AI-generated order.
  Future<void> validate(String orderId) {
    return update(orderId, {
      'status': OrderStatus.validated.value,
    }).then((_) {});
  }
}
