class Report {
  final String id;
  final String operationId;
  final bool physicalDamage;
  final int missingQuantity;
  final int extraQuality;
  final String? reportedBy;
  final String? createdAt;
  final String? updatedAt;

  Report({
    required this.id,
    required this.operationId,
    this.physicalDamage = false,
    this.missingQuantity = 0,
    this.extraQuality = 0,
    this.reportedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? '',
      operationId: json['operation_id'] ?? '',
      physicalDamage: json['physical_damage'] ?? false,
      missingQuantity: json['missing_quantity'] ?? 0,
      extraQuality: json['extra_quality'] ?? 0,
      reportedBy: json['reported_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'operation_id': operationId,
    'physical_damage': physicalDamage,
    'missing_quantity': missingQuantity,
    'extra_quality': extraQuality,
  };
}
