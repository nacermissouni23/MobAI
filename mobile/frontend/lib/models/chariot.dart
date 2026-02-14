class Chariot {
  final String id;
  final bool isActive;
  final String? assignedToOperationId;
  final String? createdAt;
  final String? updatedAt;

  Chariot({
    required this.id,
    this.isActive = true,
    this.assignedToOperationId,
    this.createdAt,
    this.updatedAt,
  });

  factory Chariot.fromJson(Map<String, dynamic> json) {
    return Chariot(
      id: json['id'] ?? '',
      isActive: json['is_active'] ?? true,
      assignedToOperationId: json['assigned_to_operation_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'is_active': isActive,
    'assigned_to_operation_id': assignedToOperationId,
  };

  bool get isAvailable => isActive && assignedToOperationId == null;

  String get statusLabel {
    if (!isActive) return 'Inactive';
    if (assignedToOperationId != null) return 'In Use';
    return 'Available';
  }
}
