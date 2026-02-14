import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:frontend/data/enums.dart';

class OrderLine extends Equatable {
  final String productId;
  final String? sku;
  final String? productName;
  final int quantity;
  final int? sourceX;
  final int? sourceY;
  final int? sourceZ;
  final int? sourceFloor;
  final int? destinationX;
  final int? destinationY;
  final int? destinationZ;
  final int? destinationFloor;

  const OrderLine({
    required this.productId,
    this.sku,
    this.productName,
    required this.quantity,
    this.sourceX,
    this.sourceY,
    this.sourceZ,
    this.sourceFloor,
    this.destinationX,
    this.destinationY,
    this.destinationZ,
    this.destinationFloor,
  });

  @override
  List<Object?> get props => [productId, quantity];

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'sku': sku,
      'product_name': productName,
      'quantity': quantity,
      'source_x': sourceX,
      'source_y': sourceY,
      'source_z': sourceZ,
      'source_floor': sourceFloor,
      'destination_x': destinationX,
      'destination_y': destinationY,
      'destination_z': destinationZ,
      'destination_floor': destinationFloor,
    };
  }

  factory OrderLine.fromMap(Map<String, dynamic> map) {
    return OrderLine(
      productId: map['product_id'] as String,
      sku: map['sku'] as String?,
      productName: map['product_name'] as String?,
      quantity: map['quantity'] as int,
      sourceX: map['source_x'] as int?,
      sourceY: map['source_y'] as int?,
      sourceZ: map['source_z'] as int?,
      sourceFloor: map['source_floor'] as int?,
      destinationX: map['destination_x'] as int?,
      destinationY: map['destination_y'] as int?,
      destinationZ: map['destination_z'] as int?,
      destinationFloor: map['destination_floor'] as int?,
    );
  }
}

class Order extends Equatable {
  final String id;
  final OrderType type;
  final OrderStatus status;
  final List<OrderLine> lines;
  final bool generatedByAi;
  final String? overriddenBy;
  final String? overrideReason;
  final DateTime? completedAt;
  final String? completedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync fields
  final String? serverId;
  final bool syncPending;
  final DateTime? lastSyncedAt;
  final bool isDeleted;

  const Order({
    required this.id,
    required this.type,
    this.status = OrderStatus.pending,
    this.lines = const [],
    this.generatedByAi = false,
    this.overriddenBy,
    this.overrideReason,
    this.completedAt,
    this.completedBy,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.syncPending = true,
    this.lastSyncedAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [id, type, status];

  // ── Convenience getters for UI backwards-compat ──

  /// Type label for display (e.g. "Picking", "Command").
  String get typeLabel => type.label;

  /// First order line's product ID (used where old Suggestion.productId was).
  String get productId => lines.isNotEmpty ? lines.first.productId : '';

  /// First order line's product name.
  String get productName =>
      lines.isNotEmpty ? (lines.first.productName ?? '') : '';

  /// Total quantity across all lines.
  int get quantity => lines.fold(0, (sum, l) => sum + l.quantity);

  /// Formatted source location from first line.
  String get fromLocation {
    if (lines.isEmpty) return 'Unknown';
    final l = lines.first;
    if (l.sourceFloor == null && l.sourceX == null) return 'Unknown';
    return 'F${l.sourceFloor ?? 0}-R${l.sourceX ?? 0}-C${l.sourceY ?? 0}';
  }

  /// Formatted destination location from first line.
  String get toLocation {
    if (lines.isEmpty) return 'Unknown';
    final l = lines.first;
    if (l.destinationFloor == null && l.destinationX == null) return 'Unknown';
    return 'F${l.destinationFloor ?? 0}-R${l.destinationX ?? 0}-C${l.destinationY ?? 0}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.value,
      'status': status.value,
      'lines_json': jsonEncode(lines.map((l) => l.toMap()).toList()),
      'generated_by_ai': generatedByAi ? 1 : 0,
      'overridden_by': overriddenBy,
      'override_reason': overrideReason,
      'completed_at': completedAt?.toIso8601String(),
      'completed_by': completedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'server_id': serverId,
      'sync_pending': syncPending ? 1 : 0,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    List<OrderLine> lines = [];
    if (map['lines_json'] != null) {
      final decoded = jsonDecode(map['lines_json'] as String) as List;
      lines = decoded
          .map((l) => OrderLine.fromMap(l as Map<String, dynamic>))
          .toList();
    }
    return Order(
      id: map['id'] as String,
      type: OrderType.fromString(map['type'] as String),
      status: OrderStatus.fromString(map['status'] as String),
      lines: lines,
      generatedByAi: (map['generated_by_ai'] as int?) == 1,
      overriddenBy: map['overridden_by'] as String?,
      overrideReason: map['override_reason'] as String?,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      completedBy: map['completed_by'] as String?,
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
      'type': type.value,
      'status': status.value,
      'lines': lines.map((l) => l.toMap()).toList(),
      'generated_by_ai': generatedByAi,
      'overridden_by': overriddenBy,
      'override_reason': overrideReason,
      'completed_at': completedAt?.toIso8601String(),
      'completed_by': completedBy,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json, {String? localId}) {
    List<OrderLine> lines = [];
    if (json['lines'] != null) {
      lines = (json['lines'] as List)
          .map((l) => OrderLine.fromMap(l as Map<String, dynamic>))
          .toList();
    }
    return Order(
      id: localId ?? json['id'] as String,
      type: OrderType.fromString(json['type'] as String),
      status: OrderStatus.fromString(json['status'] as String),
      lines: lines,
      generatedByAi: json['generated_by_ai'] as bool? ?? false,
      overriddenBy: json['overridden_by'] as String?,
      overrideReason: json['override_reason'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      completedBy: json['completed_by'] as String?,
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

  Order copyWith({
    String? id,
    OrderType? type,
    OrderStatus? status,
    List<OrderLine>? lines,
    bool? generatedByAi,
    String? overriddenBy,
    String? overrideReason,
    DateTime? completedAt,
    String? completedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serverId,
    bool? syncPending,
    DateTime? lastSyncedAt,
    bool? isDeleted,
  }) {
    return Order(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      lines: lines ?? this.lines,
      generatedByAi: generatedByAi ?? this.generatedByAi,
      overriddenBy: overriddenBy ?? this.overriddenBy,
      overrideReason: overrideReason ?? this.overrideReason,
      completedAt: completedAt ?? this.completedAt,
      completedBy: completedBy ?? this.completedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      syncPending: syncPending ?? this.syncPending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
