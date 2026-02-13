import 'package:equatable/equatable.dart';

enum TaskType { pick, deliver, store, receipt }

enum TaskStatus { pending, inProgress, completed }

class WarehouseTask extends Equatable {
  final String id;
  final TaskType type;
  final TaskStatus status;
  final String location;
  final String? productId;
  final int quantity;
  final DateTime scheduledAt;
  final String? assignedTo;
  final String? fromLocation;
  final String? toLocation;
  final List<PathPoint>? path;

  const WarehouseTask({
    required this.id,
    required this.type,
    required this.status,
    required this.location,
    this.productId,
    this.quantity = 0,
    required this.scheduledAt,
    this.assignedTo,
    this.fromLocation,
    this.toLocation,
    this.path,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    status,
    location,
    productId,
    quantity,
    scheduledAt,
  ];

  String get typeLabel {
    switch (type) {
      case TaskType.pick:
        return 'PICK';
      case TaskType.deliver:
        return 'DELIVER';
      case TaskType.store:
        return 'STORE';
      case TaskType.receipt:
        return 'RECEIPT';
    }
  }

  String get typeIcon {
    switch (type) {
      case TaskType.pick:
        return 'location_on';
      case TaskType.deliver:
        return 'local_shipping';
      case TaskType.store:
        return 'inventory_2';
      case TaskType.receipt:
        return 'input';
    }
  }

  WarehouseTask copyWith({
    String? id,
    TaskType? type,
    TaskStatus? status,
    String? location,
    String? productId,
    int? quantity,
    DateTime? scheduledAt,
    String? assignedTo,
    String? fromLocation,
    String? toLocation,
    List<PathPoint>? path,
  }) {
    return WarehouseTask(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      assignedTo: assignedTo ?? this.assignedTo,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      path: path ?? this.path,
    );
  }
}

class PathPoint extends Equatable {
  final int x;
  final int y;

  const PathPoint({required this.x, required this.y});

  @override
  List<Object?> get props => [x, y];
}
