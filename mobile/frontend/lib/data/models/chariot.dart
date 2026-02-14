import 'package:equatable/equatable.dart';

class Chariot extends Equatable {
  final String id;
  final String code;
  final bool isActive;
  final int currentX;
  final int currentY;
  final int currentZ;
  final int currentFloor;
  final String? assignedToOperation;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync fields
  final String? serverId;
  final bool syncPending;
  final DateTime? lastSyncedAt;
  final bool isDeleted;

  const Chariot({
    required this.id,
    required this.code,
    this.isActive = true,
    this.currentX = 0,
    this.currentY = 0,
    this.currentZ = 0,
    this.currentFloor = 0,
    this.assignedToOperation,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.syncPending = true,
    this.lastSyncedAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [id, code, isActive];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'is_active': isActive ? 1 : 0,
      'current_x': currentX,
      'current_y': currentY,
      'current_z': currentZ,
      'current_floor': currentFloor,
      'assigned_to_operation': assignedToOperation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'server_id': serverId,
      'sync_pending': syncPending ? 1 : 0,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Chariot.fromMap(Map<String, dynamic> map) {
    return Chariot(
      id: map['id'] as String,
      code: map['code'] as String,
      isActive: (map['is_active'] as int?) == 1,
      currentX: map['current_x'] as int? ?? 0,
      currentY: map['current_y'] as int? ?? 0,
      currentZ: map['current_z'] as int? ?? 0,
      currentFloor: map['current_floor'] as int? ?? 0,
      assignedToOperation: map['assigned_to_operation'] as String?,
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
      'code': code,
      'is_active': isActive,
      'current_x': currentX,
      'current_y': currentY,
      'current_z': currentZ,
      'current_floor': currentFloor,
      'assigned_to_operation': assignedToOperation,
    };
  }

  factory Chariot.fromJson(Map<String, dynamic> json, {String? localId}) {
    return Chariot(
      id: localId ?? json['id'] as String,
      code: json['code'] as String,
      isActive: json['is_active'] as bool? ?? true,
      currentX: json['current_x'] as int? ?? 0,
      currentY: json['current_y'] as int? ?? 0,
      currentZ: json['current_z'] as int? ?? 0,
      currentFloor: json['current_floor'] as int? ?? 0,
      assignedToOperation: json['assigned_to_operation'] as String?,
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

  Chariot copyWith({
    String? id,
    String? code,
    bool? isActive,
    int? currentX,
    int? currentY,
    int? currentZ,
    int? currentFloor,
    String? assignedToOperation,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serverId,
    bool? syncPending,
    DateTime? lastSyncedAt,
    bool? isDeleted,
  }) {
    return Chariot(
      id: id ?? this.id,
      code: code ?? this.code,
      isActive: isActive ?? this.isActive,
      currentX: currentX ?? this.currentX,
      currentY: currentY ?? this.currentY,
      currentZ: currentZ ?? this.currentZ,
      currentFloor: currentFloor ?? this.currentFloor,
      assignedToOperation: assignedToOperation ?? this.assignedToOperation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      syncPending: syncPending ?? this.syncPending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  bool get isAvailable => isActive && assignedToOperation == null;
}
