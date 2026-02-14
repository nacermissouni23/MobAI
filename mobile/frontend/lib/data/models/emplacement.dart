import 'package:equatable/equatable.dart';

/// Represents a single storage location / grid cell in the warehouse.
class Emplacement extends Equatable {
  final String id;
  final int x;
  final int y;
  final int z;
  final int floor;
  final bool isObstacle;
  final bool isSlot;
  final bool isElevator;
  final bool isRoad;
  final bool isExpedition;
  final String? productId;
  final int quantity;
  final bool isOccupied;
  final String? locationCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync fields
  final String? serverId;
  final bool syncPending;
  final DateTime? lastSyncedAt;
  final bool isDeleted;

  const Emplacement({
    required this.id,
    required this.x,
    required this.y,
    this.z = 0,
    this.floor = 0,
    this.isObstacle = false,
    this.isSlot = false,
    this.isElevator = false,
    this.isRoad = false,
    this.isExpedition = false,
    this.productId,
    this.quantity = 0,
    this.isOccupied = false,
    this.locationCode,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.syncPending = true,
    this.lastSyncedAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    x,
    y,
    z,
    floor,
    productId,
    quantity,
    isOccupied,
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'z': z,
      'floor': floor,
      'is_obstacle': isObstacle ? 1 : 0,
      'is_slot': isSlot ? 1 : 0,
      'is_elevator': isElevator ? 1 : 0,
      'is_road': isRoad ? 1 : 0,
      'is_expedition': isExpedition ? 1 : 0,
      'product_id': productId,
      'quantity': quantity,
      'is_occupied': isOccupied ? 1 : 0,
      'location_code': locationCode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'server_id': serverId,
      'sync_pending': syncPending ? 1 : 0,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Emplacement.fromMap(Map<String, dynamic> map) {
    return Emplacement(
      id: map['id'] as String,
      x: map['x'] as int,
      y: map['y'] as int,
      z: map['z'] as int? ?? 0,
      floor: map['floor'] as int? ?? 0,
      isObstacle: (map['is_obstacle'] as int?) == 1,
      isSlot: (map['is_slot'] as int?) == 1,
      isElevator: (map['is_elevator'] as int?) == 1,
      isRoad: (map['is_road'] as int?) == 1,
      isExpedition: (map['is_expedition'] as int?) == 1,
      productId: map['product_id'] as String?,
      quantity: map['quantity'] as int? ?? 0,
      isOccupied: (map['is_occupied'] as int?) == 1,
      locationCode: map['location_code'] as String?,
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
      'is_obstacle': isObstacle,
      'is_slot': isSlot,
      'is_elevator': isElevator,
      'is_road': isRoad,
      'is_expedition': isExpedition,
      'product_id': productId,
      'quantity': quantity,
      'is_occupied': isOccupied,
      'location_code': locationCode,
    };
  }

  factory Emplacement.fromJson(Map<String, dynamic> json, {String? localId}) {
    return Emplacement(
      id: localId ?? json['id'] as String,
      x: json['x'] as int,
      y: json['y'] as int,
      z: json['z'] as int? ?? 0,
      floor: json['floor'] as int? ?? 0,
      isObstacle: json['is_obstacle'] as bool? ?? false,
      isSlot: json['is_slot'] as bool? ?? false,
      isElevator: json['is_elevator'] as bool? ?? false,
      isRoad: json['is_road'] as bool? ?? false,
      isExpedition: json['is_expedition'] as bool? ?? false,
      productId: json['product_id'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      isOccupied: json['is_occupied'] as bool? ?? false,
      locationCode: json['location_code'] as String?,
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

  Emplacement copyWith({
    String? id,
    int? x,
    int? y,
    int? z,
    int? floor,
    bool? isObstacle,
    bool? isSlot,
    bool? isElevator,
    bool? isRoad,
    bool? isExpedition,
    String? productId,
    int? quantity,
    bool? isOccupied,
    String? locationCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serverId,
    bool? syncPending,
    DateTime? lastSyncedAt,
    bool? isDeleted,
  }) {
    return Emplacement(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      floor: floor ?? this.floor,
      isObstacle: isObstacle ?? this.isObstacle,
      isSlot: isSlot ?? this.isSlot,
      isElevator: isElevator ?? this.isElevator,
      isRoad: isRoad ?? this.isRoad,
      isExpedition: isExpedition ?? this.isExpedition,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      isOccupied: isOccupied ?? this.isOccupied,
      locationCode: locationCode ?? this.locationCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      syncPending: syncPending ?? this.syncPending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Cell type classification for warehouse grid rendering.
  String get cellTypeLabel {
    if (isElevator) return 'Elevator';
    if (isExpedition) return 'Expedition';
    if (isObstacle) return 'Obstacle';
    if (isSlot) return 'Slot';
    return 'Road';
  }
}
