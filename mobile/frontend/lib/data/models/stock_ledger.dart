import 'package:equatable/equatable.dart';
import 'package:frontend/data/enums.dart';

/// Immutable stock movement record for audit trail.
class StockLedger extends Equatable {
  final String id;
  final int x;
  final int y;
  final int z;
  final int floor;
  final String productId;
  final int quantity; // positive=in, negative=out
  final DateTime recordedAt;
  final String? operationId;
  final OperationType? operationType;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync fields
  final String? serverId;
  final bool syncPending;
  final DateTime? lastSyncedAt;
  final bool isDeleted;

  const StockLedger({
    required this.id,
    required this.x,
    required this.y,
    this.z = 0,
    this.floor = 0,
    required this.productId,
    required this.quantity,
    required this.recordedAt,
    this.operationId,
    this.operationType,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.syncPending = true,
    this.lastSyncedAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [id, productId, quantity, recordedAt];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'z': z,
      'floor': floor,
      'product_id': productId,
      'quantity': quantity,
      'recorded_at': recordedAt.toIso8601String(),
      'operation_id': operationId,
      'operation_type': operationType?.value,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'server_id': serverId,
      'sync_pending': syncPending ? 1 : 0,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory StockLedger.fromMap(Map<String, dynamic> map) {
    return StockLedger(
      id: map['id'] as String,
      x: map['x'] as int,
      y: map['y'] as int,
      z: map['z'] as int? ?? 0,
      floor: map['floor'] as int? ?? 0,
      productId: map['product_id'] as String,
      quantity: map['quantity'] as int,
      recordedAt: DateTime.parse(map['recorded_at'] as String),
      operationId: map['operation_id'] as String?,
      operationType: map['operation_type'] != null
          ? OperationType.fromString(map['operation_type'] as String)
          : null,
      userId: map['user_id'] as String?,
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
      'x': x,
      'y': y,
      'z': z,
      'floor': floor,
      'product_id': productId,
      'quantity': quantity,
      'recorded_at': recordedAt.toIso8601String(),
      'operation_id': operationId,
      'operation_type': operationType?.value,
      'user_id': userId,
    };
  }

  factory StockLedger.fromJson(Map<String, dynamic> json, {String? localId}) {
    return StockLedger(
      id: localId ?? json['id'] as String,
      x: json['x'] as int,
      y: json['y'] as int,
      z: json['z'] as int? ?? 0,
      floor: json['floor'] as int? ?? 0,
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int,
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String)
          : DateTime.now(),
      operationId: json['operation_id'] as String?,
      operationType: json['operation_type'] != null
          ? OperationType.fromString(json['operation_type'] as String)
          : null,
      userId: json['user_id'] as String?,
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

  StockLedger copyWith({
    String? id,
    int? x,
    int? y,
    int? z,
    int? floor,
    String? productId,
    int? quantity,
    DateTime? recordedAt,
    String? operationId,
    OperationType? operationType,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serverId,
    bool? syncPending,
    DateTime? lastSyncedAt,
    bool? isDeleted,
  }) {
    return StockLedger(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      floor: floor ?? this.floor,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      recordedAt: recordedAt ?? this.recordedAt,
      operationId: operationId ?? this.operationId,
      operationType: operationType ?? this.operationType,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      syncPending: syncPending ?? this.syncPending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
