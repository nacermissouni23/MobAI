import 'package:equatable/equatable.dart';

/// Anomaly report linked to an operation (matches backend Report model).
class Report extends Equatable {
  final String id;
  final String operationId;
  final int missingQuantity;
  final bool physicalDamage;
  final int extraQuantity;
  final String? notes;
  final String reportedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync fields
  final String? serverId;
  final bool syncPending;
  final DateTime? lastSyncedAt;
  final bool isDeleted;

  const Report({
    required this.id,
    required this.operationId,
    this.missingQuantity = 0,
    this.physicalDamage = false,
    this.extraQuantity = 0,
    this.notes,
    required this.reportedBy,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.syncPending = true,
    this.lastSyncedAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [id, operationId, reportedBy];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operation_id': operationId,
      'missing_quantity': missingQuantity,
      'physical_damage': physicalDamage ? 1 : 0,
      'extra_quantity': extraQuantity,
      'notes': notes,
      'reported_by': reportedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'server_id': serverId,
      'sync_pending': syncPending ? 1 : 0,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] as String,
      operationId: map['operation_id'] as String,
      missingQuantity: map['missing_quantity'] as int? ?? 0,
      physicalDamage: (map['physical_damage'] as int?) == 1,
      extraQuantity: map['extra_quantity'] as int? ?? 0,
      notes: map['notes'] as String?,
      reportedBy: map['reported_by'] as String,
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
      'missing_quantity': missingQuantity,
      'physical_damage': physicalDamage,
      'extra_quantity': extraQuantity,
      'notes': notes,
      'reported_by': reportedBy,
    };
  }

  factory Report.fromJson(Map<String, dynamic> json, {String? localId}) {
    return Report(
      id: localId ?? json['id'] as String,
      operationId: json['operation_id'] as String,
      missingQuantity: json['missing_quantity'] as int? ?? 0,
      physicalDamage: json['physical_damage'] as bool? ?? false,
      extraQuantity: json['extra_quantity'] as int? ?? 0,
      notes: json['notes'] as String?,
      reportedBy: json['reported_by'] as String,
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

  Report copyWith({
    String? id,
    String? operationId,
    int? missingQuantity,
    bool? physicalDamage,
    int? extraQuantity,
    String? notes,
    String? reportedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serverId,
    bool? syncPending,
    DateTime? lastSyncedAt,
    bool? isDeleted,
  }) {
    return Report(
      id: id ?? this.id,
      operationId: operationId ?? this.operationId,
      missingQuantity: missingQuantity ?? this.missingQuantity,
      physicalDamage: physicalDamage ?? this.physicalDamage,
      extraQuantity: extraQuantity ?? this.extraQuantity,
      notes: notes ?? this.notes,
      reportedBy: reportedBy ?? this.reportedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      syncPending: syncPending ?? this.syncPending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  bool get hasAnomaly => missingQuantity > 0 || physicalDamage || extraQuantity > 0;
}
