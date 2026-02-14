import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/order.dart';
import 'package:frontend/data/repositories/order_repository.dart';

// ── States ──────────────────────────────────────────────────

abstract class OrdersState extends Equatable {
  const OrdersState();
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;
  const OrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrdersError extends OrdersState {
  final String message;
  const OrdersError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────

class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository _orderRepo;

  OrdersCubit({required OrderRepository orderRepository})
      : _orderRepo = orderRepository,
        super(OrdersInitial());

  Future<void> loadOrders() async {
    emit(OrdersLoading());
    try {
      final orders = await _orderRepo.getAllSorted();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError('Failed to load orders: $e'));
    }
  }

  Future<void> validateOrder(String orderId) async {
    try {
      await _orderRepo.validate(orderId);
      await loadOrders();
    } catch (e) {
      emit(OrdersError('Failed to validate order: $e'));
    }
  }

  Future<void> overrideOrder({
    required String orderId,
    required String overriddenBy,
    required String reason,
  }) async {
    try {
      await _orderRepo.overrideOrder(orderId, overriddenBy: overriddenBy, reason: reason);
      await loadOrders();
    } catch (e) {
      emit(OrdersError('Failed to override order: $e'));
    }
  }

  Future<void> completeOrder(String orderId, String completedBy) async {
    try {
      await _orderRepo.complete(orderId, completedBy);
      await loadOrders();
    } catch (e) {
      emit(OrdersError('Failed to complete order: $e'));
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _orderRepo.softDelete(orderId);
      await loadOrders();
    } catch (e) {
      emit(OrdersError('Failed to delete order: $e'));
    }
  }
}
