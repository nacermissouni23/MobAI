class Order {
  final String id;
  final String type;
  final String status;
  final String? supervisorId;
  final String? validatorId;
  final String? validatedAt;
  final String? productId;
  final int quantity;
  final String? createdAt;
  final String? updatedAt;

  Order({
    required this.id,
    required this.type,
    this.status = 'pending',
    this.supervisorId,
    this.validatorId,
    this.validatedAt,
    this.productId,
    this.quantity = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      type: json['type'] ?? 'command',
      status: json['status'] ?? 'pending',
      supervisorId: json['supervisor_id'],
      validatorId: json['validator_id'],
      validatedAt: json['validated_at'],
      productId: json['product_id'],
      quantity: json['quantity'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'product_id': productId,
    'quantity': quantity,
  };

  bool get isPending => status == 'pending';
  bool get isValidated => status == 'validated';
}
