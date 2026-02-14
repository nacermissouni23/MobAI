class Operation {
  final String id;
  final String type;
  final String status;
  final String? productId;
  final int quantity;
  final String? employeeId;
  final String? validatorId;
  final String? validatedAt;
  final String? chariotId;
  final String? orderId;
  final String? emplacementId;
  final String? sourceEmplacementId;
  final List<dynamic>? suggestedRoute;
  final String? createdAt;
  final String? updatedAt;

  Operation({
    required this.id,
    required this.type,
    this.status = 'pending',
    this.productId,
    this.quantity = 0,
    this.employeeId,
    this.validatorId,
    this.validatedAt,
    this.chariotId,
    this.orderId,
    this.emplacementId,
    this.sourceEmplacementId,
    this.suggestedRoute,
    this.createdAt,
    this.updatedAt,
  });

  factory Operation.fromJson(Map<String, dynamic> json) {
    return Operation(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'pending',
      productId: json['product_id'],
      quantity: json['quantity'] ?? 0,
      employeeId: json['employee_id'],
      validatorId: json['validator_id'],
      validatedAt: json['validated_at'],
      chariotId: json['chariot_id'],
      orderId: json['order_id'],
      emplacementId: json['emplacement_id'],
      sourceEmplacementId: json['source_emplacement_id'],
      suggestedRoute: json['suggested_route'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'product_id': productId,
    'quantity': quantity,
    'employee_id': employeeId,
    'chariot_id': chariotId,
    'order_id': orderId,
    'emplacement_id': emplacementId,
    'source_emplacement_id': sourceEmplacementId,
  };

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isValidated => status == 'validated';

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'validated':
        return 'Validated';
      default:
        return status;
    }
  }

  String get typeLabel {
    switch (type) {
      case 'receipt':
        return 'Receipt';
      case 'transfer':
        return 'Transfer';
      case 'picking':
        return 'Picking';
      case 'delivery':
        return 'Delivery';
      default:
        return type;
    }
  }
}
