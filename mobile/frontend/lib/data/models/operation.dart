import 'package:equatable/equatable.dart';
import 'package:frontend/data/enums.dart';

class Operation extends Equatable {
  final String id;
  final OperationType type;
  final String? employeeId;
  final String? validatorId;
  final DateTime? validatedAt;
  final String? chariotId;
  final String? orderId;
  final int? destinationX;
  final int? destinationY;
  final int? destinationZ;
  final int? destinationFloor;
  final int? sourceX;
  final int? sourceY;
  final int? sourceZ;
  final int? sourceFloor;
  final String? warehouseId;
  final OperationStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? productId;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync fields
  final String? serverId;
  final bool syncPending;
  final DateTime? lastSyncedAt;
  final bool isDeleted;

  const Operation({
    required this.id,
    required this.type,
    this.employeeId,
    this.validatorId,
    this.validatedAt,
    this.chariotId,
    this.orderId,
    this.destinationX,
    this.destinationY,
    this.destinationZ,
    this.destinationFloor,
    this.sourceX,
    this.sourceY,
    this.sourceZ,
    this.sourceFloor,
    this.warehouseId,
    this.status = OperationStatus.pending,
    this.startedAt,
    this.completedAt,
    this.productId,
    this.quantity = 0,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.syncPending = true,
    this.lastSyncedAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [id, type, status, employeeId];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.value,
      'employee_id': employeeId,
      'validator_id': validatorId,
      'validated_at': validatedAt?.toIso8601String(),
      'chariot_id': chariotId,
      'order_id': orderId,
      'destination_x': destinationX,
      'destination_y': destinationY,
      'destination_z': destinationZ,
      'destination_floor': destinationFloor,
      'source_x': sourceX,
      'source_y': sourceY,
      'source_z': sourceZ,
      'source_floor': sourceFloor,
      'warehouse_id': warehouseId,
      'status': status.value,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'product_id': productId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'server_id': serverId,
      'sync_pending': syncPending ? 1 : 0,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Operation.fromMap(Map<String, dynamic> map) {
    return Operation(
      id: map['id'] as String,
      type: OperationType.fromString(map['type'] as String),
      employeeId: map['employee_id'] as String?,
      validatorId: map['validator_id'] as String?,
      validatedAt: map['validated_at'] != null
          ? DateTime.parse(map['validated_at'] as String)
          : null,
      chariotId: map['chariot_id'] as String?,
      orderId: map['order_id'] as String?,
      destinationX: map['destination_x'] as int?,
      destinationY: map['destination_y'] as int?,
      destinationZ: map['destination_z'] as int?,
      destinationFloor: map['destination_floor'] as int?,
      sourceX: map['source_x'] as int?,
      sourceY: map['source_y'] as int?,
      sourceZ: map['source_z'] as int?,
      sourceFloor: map['source_floor'] as int?,
      warehouseId: map['warehouse_id'] as String?,
      status: OperationStatus.fromString(map['status'] as String),
      startedAt: map['started_at'] != null
          ? DateTime.parse(map['started_at'] as String)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      productId: map['product_id'] as String?,
      quantity: map['quantity'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      serverId: map['server_id'] as String?,
      syncPending: (map['sync_pending'] as int?) == 1,
      lastSyncedAt: map['last_synced_at'] != null
          ? DateTime.parse(map['last_synced_at'] as String)
          : null,
      isDeleted: (map['is_deleted'] as int?) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': serverId ?? id,
      'type': type.value,
      'employee_id': employeeId,
      'validator_id': validatorId,
      'validated_at': validatedAt?.toIso8601String(),
      'chariot_id': chariotId,
      'order_id': orderId,
      'destination_x': destinationX,
      'destination_y': destinationY,
      'destination_z': destinationZ,
      'destination_floor': destinationFloor,
      'source_x': sourceX,
      'source_y': sourceY,
      'source_z': sourceZ,
      'source_floor': sourceFloor,
      'warehouse_id': warehouseId,
      'status': status.value,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'product_id': productId,
      'quantity': quantity,
    };
  }

  factory Operation.fromJson(Map<String, dynamic> json, {String? localId}) {
    return Operation(
      id: localId ?? json['id'] as String,
      type: OperationType.fromString(json['type'] as String),
      employeeId: json['employee_id'] as String?,
      validatorId: json['validator_id'] as String?,
      validatedAt: json['validated_at'] != null
          ? DateTime.parse(json['validated_at'] as String)
          : null,
      chariotId: json['chariot_id'] as String?,
      orderId: json['order_id'] as String?,
      destinationX: json['destination_x'] as int?,
      destinationY: json['destination_y'] as int?,
      destinationZ: json['destination_z'] as int?,
      destinationFloor: json['destination_floor'] as int?,
      sourceX: json['source_x'] as int?,
      sourceY: json['source_y'] as int?,
      sourceZ: json['source_z'] as int?,
      sourceFloor: json['source_floor'] as int?,
      warehouseId: json['warehouse_id'] as String?,
      status: OperationStatus.fromString(json['status'] as String),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      productId: json['product_id'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      serverId: json['id'] as String?,
      syncPending: false,
      lastSyncedAt: DateTime.now(),
      isDeleted: false,
    );
  }

  Operation copyWith({
    String? id,
    OperationType? type,
    String? employeeId,
    String? validatorId,
    DateTime? validatedAt,
    String? chariotId,
    String? orderId,
    int? destinationX,
    int? destinationY,
    int? destinationZ,
    int? destinationFloor,
    int? sourceX,
    int? sourceY,
    int? sourceZ,
    int? sourceFloor,
    String? warehouseId,
    OperationStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    String? productId,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serverId,
    bool? syncPending,
    DateTime? lastSyncedAt,
    bool? isDeleted,
  }) {
    return Operation(
      id: id ?? this.id,
      type: type ?? this.type,
      employeeId: employeeId ?? this.employeeId,
      validatorId: validatorId ?? this.validatorId,
      validatedAt: validatedAt ?? this.validatedAt,
      chariotId: chariotId ?? this.chariotId,
      orderId: orderId ?? this.orderId,
      destinationX: destinationX ?? this.destinationX,
      destinationY: destinationY ?? this.destinationY,
      destinationZ: destinationZ ?? this.destinationZ,
      destinationFloor: destinationFloor ?? this.destinationFloor,
      sourceX: sourceX ?? this.sourceX,
      sourceY: sourceY ?? this.sourceY,
      sourceZ: sourceZ ?? this.sourceZ,
      sourceFloor: sourceFloor ?? this.sourceFloor,
      warehouseId: warehouseId ?? this.warehouseId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      syncPending: syncPending ?? this.syncPending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Convenience: formatted source location string for UI display.
  String? get fromLocation {
    if (sourceFloor == null && sourceX == null && sourceY == null) return null;
    return 'F${sourceFloor ?? 0}-R${sourceX ?? 0}-C${sourceY ?? 0}';
  }

  /// Convenience: formatted destination location string for UI display.
  String? get toLocation {
    if (destinationFloor == null &&
        destinationX == null &&
        destinationY == null) {
      return null;
    }
    return 'F${destinationFloor ?? 0}-R${destinationX ?? 0}-C${destinationY ?? 0}';
  }

  /// Convenience: primary location string (uses source or destination).
  String get location => fromLocation ?? toLocation ?? 'Unknown';

  /// Convenience: scheduled date (uses startedAt or createdAt as proxy).
  DateTime get scheduledAt => startedAt ?? createdAt;

  String get typeLabel => type.label;
  String get statusLabel => status.label;
}
