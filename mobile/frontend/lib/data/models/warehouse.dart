import 'package:equatable/equatable.dart';

enum CellType { road, slot, obstacle, elevator, expeditionZone, vracZone }

class WarehouseCell extends Equatable {
  final int x;
  final int y;
  final int z;
  final int floor;
  final bool isObstacle;
  final bool isSlot;
  final bool isElevator;
  final bool isRoad;
  final bool isExpeditionZone;
  final bool isVracZone;
  final String? productId;
  final int quantity;
  final bool isOccupied;

  const WarehouseCell({
    required this.x,
    required this.y,
    this.z = 0,
    this.floor = 0,
    this.isObstacle = false,
    this.isSlot = false,
    this.isElevator = false,
    this.isRoad = true,
    this.isExpeditionZone = false,
    this.isVracZone = false,
    this.productId,
    this.quantity = 0,
    this.isOccupied = false,
  });

  factory WarehouseCell.fromJson(Map<String, dynamic> json) {
    return WarehouseCell(
      x: json['x'] as int,
      y: json['y'] as int,
      z: json['z'] as int? ?? 0,
      floor: json['floor'] as int? ?? 0,
      isObstacle: json['is_obstacle'] as bool? ?? false,
      isSlot: json['is_slot'] as bool? ?? false,
      isElevator: json['is_elevator'] as bool? ?? false,
      isRoad: json['is_road'] as bool? ?? false,
      isExpeditionZone: json['is_expedition_zone'] as bool? ?? false,
      isVracZone: json['is_vrac_zone'] as bool? ?? false,
      productId: json['product_id'] as String?,
      quantity: json['quantity'] as int? ?? 0,
      isOccupied: json['is_occupied'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'floor': floor,
      'is_obstacle': isObstacle,
      'is_slot': isSlot,
      'is_elevator': isElevator,
      'is_road': isRoad,
      'is_expedition_zone': isExpeditionZone,
      'is_vrac_zone': isVracZone,
      'product_id': productId,
      'quantity': quantity,
      'is_occupied': isOccupied,
    };
  }

  WarehouseCell copyWith({
    int? x,
    int? y,
    int? z,
    int? floor,
    bool? isObstacle,
    bool? isSlot,
    bool? isElevator,
    bool? isRoad,
    bool? isExpeditionZone,
    bool? isVracZone,
    String? productId,
    int? quantity,
    bool? isOccupied,
  }) {
    return WarehouseCell(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      floor: floor ?? this.floor,
      isObstacle: isObstacle ?? this.isObstacle,
      isSlot: isSlot ?? this.isSlot,
      isElevator: isElevator ?? this.isElevator,
      isRoad: isRoad ?? this.isRoad,
      isExpeditionZone: isExpeditionZone ?? this.isExpeditionZone,
      isVracZone: isVracZone ?? this.isVracZone,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      isOccupied: isOccupied ?? this.isOccupied,
    );
  }

  @override
  List<Object?> get props => [
    x,
    y,
    z,
    floor,
    isObstacle,
    isSlot,
    isElevator,
    isRoad,
    isExpeditionZone,
    isVracZone,
    productId,
    quantity,
    isOccupied,
  ];

  CellType get cellType {
    if (isElevator) return CellType.elevator;
    if (isExpeditionZone) return CellType.expeditionZone;
    if (isVracZone) return CellType.vracZone;
    if (isObstacle) return CellType.obstacle;
    if (isSlot) return CellType.slot;
    return CellType.road;
  }

  String get label {
    if (isElevator) return 'ELV';
    if (isExpeditionZone) return 'EXP';
    if (isVracZone) return 'VRAC';
    if (isObstacle) return '';
    if (isSlot && isOccupied) return productId ?? 'OCC';
    if (isSlot) return 'SLOT';
    return '';
  }
}

class WarehouseFloor extends Equatable {
  final int floorNumber;
  final String name;
  final List<WarehouseCell> cells;
  final int width;
  final int height;

  const WarehouseFloor({
    required this.floorNumber,
    required this.name,
    required this.cells,
    this.width = 29,
    this.height = 44,
  });

  factory WarehouseFloor.fromJson(
    Map<String, dynamic> json, {
    required String name,
    required int floorNumber,
  }) {
    final cellsList = (json['cells'] as List)
        .map((c) => WarehouseCell.fromJson(c as Map<String, dynamic>))
        .where((c) => c.floor == floorNumber)
        .toList();
    return WarehouseFloor(
      floorNumber: floorNumber,
      name: name,
      cells: cellsList,
      width: json['width'] as int? ?? 29,
      height: json['height'] as int? ?? 44,
    );
  }

  @override
  List<Object?> get props => [floorNumber, name, cells];
}
