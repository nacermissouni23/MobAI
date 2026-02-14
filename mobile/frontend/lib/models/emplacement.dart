class Emplacement {
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
  final String? createdAt;
  final String? updatedAt;

  Emplacement({
    required this.id,
    required this.x,
    required this.y,
    required this.z,
    this.floor = 0,
    this.isObstacle = false,
    this.isSlot = false,
    this.isElevator = false,
    this.isRoad = false,
    this.isExpedition = false,
    this.productId,
    this.quantity = 0,
    this.isOccupied = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Emplacement.fromJson(Map<String, dynamic> json) {
    return Emplacement(
      id: json['id'] ?? '',
      x: json['x'] ?? 0,
      y: json['y'] ?? 0,
      z: json['z'] ?? 0,
      floor: json['floor'] ?? 0,
      isObstacle: json['is_obstacle'] ?? false,
      isSlot: json['is_slot'] ?? false,
      isElevator: json['is_elevator'] ?? false,
      isRoad: json['is_road'] ?? false,
      isExpedition: json['is_expedition'] ?? false,
      productId: json['product_id'],
      quantity: json['quantity'] ?? 0,
      isOccupied: json['is_occupied'] ?? false,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
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
  };

  String get coordinateLabel => '($x, $y, $z) F$floor';

  String get typeLabel {
    if (isSlot) return 'Storage Slot';
    if (isObstacle) return 'Obstacle';
    if (isElevator) return 'Elevator';
    if (isRoad) return 'Road';
    if (isExpedition) return 'Expedition Zone';
    return 'Unknown';
  }
}
