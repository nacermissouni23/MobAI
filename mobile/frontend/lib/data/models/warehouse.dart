import 'package:equatable/equatable.dart';

class WarehouseCell extends Equatable {
  final int x;
  final int y;
  final int z;
  final int floor;
  final bool isObstacle;
  final bool isSlot;
  final bool isElevator;
  final bool isRoad;
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
    this.productId,
    this.quantity = 0,
    this.isOccupied = false,
  });

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
    productId,
    quantity,
    isOccupied,
  ];

  String get label {
    if (isElevator) return 'ELV';
    if (isObstacle) return 'OBS';
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
    this.width = 30,
    this.height = 30,
  });

  @override
  List<Object?> get props => [floorNumber, name, cells];
}
