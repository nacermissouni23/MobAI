import 'package:equatable/equatable.dart';
import 'package:frontend/data/enums.dart';

class OperationLog extends Equatable {
  final String id;
  final String operationId;
  final String? employeeId;
  final String? productId;
  final int quantity;
  final OperationType? type;
  final String? overriderId;
  final String? chariotId;
  final int? storageFloor;
  final int? storageRow;
  final int? storageCol;
  final String? overrideReason;
  final int? aiSuggestedFloor;
  final int? aiSuggestedRow;
  final int? aiSuggestedCol;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync fields
  final String? serverId;
  final bool syncPending;
  final DateTime? lastSyncedAt;
  final bool isDeleted;

  const OperationLog({
    required this.id,
    required this.operationId,
    this.employeeId,
    this.productId,
    this.quantity = 0,
    this.type,
    this.overriderId,
    this.chariotId,
    this.storageFloor,
    this.storageRow,
    this.storageCol,
    this.overrideReason,
    this.aiSuggestedFloor,
    this.aiSuggestedRow,
    this.aiSuggestedCol,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.syncPending = true,
    this.lastSyncedAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [id, operationId];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operation_id': operationId,
      'employee_id': employeeId,
      'product_id': productId,
      'quantity': quantity,
      'type': type?.value,
      'overrider_id': overriderId,
      'chariot_id': chariotId,
      'storage_floor': storageFloor,
      'storage_row': storageRow,
      'storage_col': storageCol,
      'override_reason': overrideReason,
      'ai_suggested_floor': aiSuggestedFloor,
      'ai_suggested_row': aiSuggestedRow,
      'ai_suggested_col': aiSuggestedCol,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'server_id': serverId,
      'sync_pending': syncPending ? 1 : 0,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory OperationLog.fromMap(Map<String, dynamic> map) {
    return OperationLog(
      id: map['id'] as String,
      operationId: map['operation_id'] as String,
      employeeId: map['employee_id'] as String?,
      productId: map['product_id'] as String?,
      quantity: map['quantity'] as int? ?? 0,
      type: map['type'] != null ? OperationType.fromString(map['type'] as String) : null,
      overriderId: map['overrider_id'] as String?,
      chariotId: map['chariot_id'] as String?,
      storageFloor: map['storage_floor'] as int?,
      storageRow: map['storage_row'] as int?,
      storageCol: map['storage_col'] as int?,
      overrideReason: map['override_reason'] as String?,
      aiSuggestedFloor: map['ai_suggested_floor'] as int?,
      aiSuggestedRow: map['ai_suggested_row'] as int?,
      aiSuggestedCol: map['ai_suggested_col'] as int?,
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
      'operation_id': operationId,
      'employee_id': employeeId,
      'product_id': productId,
      'quantity': quantity,
      'type': type?.value,
      'overrider_id': overriderId,
      'chariot_id': chariotId,
      'storage_floor': storageFloor,
      'storage_row': storageRow,
      'storage_col': storageCol,
      'override_reason': overrideReason,
      'ai_suggested_floor': aiSuggestedFloor,
      'ai_suggested_row': aiSuggestedRow,
      'ai_suggested_col': aiSuggestedCol,
    };
  }

  factory OperationLog.fromJson(Map<String, dynamic> json, {String? localId}) {
    return OperationLog(
      id: localId ?? json['id'] as String,
      operationId: json['operation_id'] as String,
      employeeId: json['employee_id'] as String?,
      productId: json['product_id'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      type: json['type'] != null ? OperationType.fromString(json['type'] as String) : null,
      overriderId: json['overrider_id'] as String?,
      chariotId: json['chariot_id'] as String?,
      storageFloor: json['storage_floor'] as int?,
      storageRow: json['storage_row'] as int?,
      storageCol: json['storage_col'] as int?,
      overrideReason: json['override_reason'] as String?,
      aiSuggestedFloor: json['ai_suggested_floor'] as int?,
      aiSuggestedRow: json['ai_suggested_row'] as int?,
      aiSuggestedCol: json['ai_suggested_col'] as int?,
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

  OperationLog copyWith({
    String? id,
    String? operationId,
    String? employeeId,
    String? productId,
    int? quantity,
    OperationType? type,
    String? overriderId,
    String? chariotId,
    int? storageFloor,
    int? storageRow,
    int? storageCol,
    String? overrideReason,
    int? aiSuggestedFloor,
    int? aiSuggestedRow,
    int? aiSuggestedCol,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serverId,
    bool? syncPending,
    DateTime? lastSyncedAt,
    bool? isDeleted,
  }) {
    return OperationLog(
      id: id ?? this.id,
      operationId: operationId ?? this.operationId,
      employeeId: employeeId ?? this.employeeId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      overriderId: overriderId ?? this.overriderId,
      chariotId: chariotId ?? this.chariotId,
      storageFloor: storageFloor ?? this.storageFloor,
      storageRow: storageRow ?? this.storageRow,
      storageCol: storageCol ?? this.storageCol,
      overrideReason: overrideReason ?? this.overrideReason,
      aiSuggestedFloor: aiSuggestedFloor ?? this.aiSuggestedFloor,
      aiSuggestedRow: aiSuggestedRow ?? this.aiSuggestedRow,
      aiSuggestedCol: aiSuggestedCol ?? this.aiSuggestedCol,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      syncPending: syncPending ?? this.syncPending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  bool get isOverride => overriderId != null;
}
