class StockLedger {
  final String id;
  final int x;
  final int y;
  final int z;
  final int floor;
  final String productId;
  final int quantity;
  final String? recordedAt;
  final String? createdAt;
  final String? updatedAt;

  StockLedger({
    required this.id,
    required this.x,
    required this.y,
    required this.z,
    this.floor = 0,
    required this.productId,
    required this.quantity,
    this.recordedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory StockLedger.fromJson(Map<String, dynamic> json) {
    return StockLedger(
      id: json['id'] ?? '',
      x: json['x'] ?? 0,
      y: json['y'] ?? 0,
      z: json['z'] ?? 0,
      floor: json['floor'] ?? 0,
      productId: json['product_id'] ?? '',
      quantity: json['quantity'] ?? 0,
      recordedAt: json['recorded_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z,
    'floor': floor,
    'product_id': productId,
    'quantity': quantity,
  };

  bool get isInbound => quantity > 0;
  bool get isOutbound => quantity < 0;
  String get coordinateLabel => '($x, $y, $z) F$floor';
}
