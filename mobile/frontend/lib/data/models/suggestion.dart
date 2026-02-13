import 'package:equatable/equatable.dart';

enum SuggestionStatus { ready, urgent, pending }

enum SuggestionType { picking, store }

class Suggestion extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String fromLocation;
  final String toLocation;
  final SuggestionStatus status;
  final SuggestionType type;
  final int quantity;
  final String? assignedTo;
  final String? overrideJustification;
  final String? overriddenFromLocation;
  final String? overriddenToLocation;
  final bool isOverridden;
  final List<Map<String, int>>? path;

  const Suggestion({
    required this.id,
    required this.productId,
    this.productName = 'Product Name',
    required this.fromLocation,
    required this.toLocation,
    required this.status,
    this.type = SuggestionType.picking,
    this.quantity = 0,
    this.assignedTo,
    this.overrideJustification,
    this.overriddenFromLocation,
    this.overriddenToLocation,
    this.isOverridden = false,
    this.path,
  });

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    fromLocation,
    toLocation,
    status,
    quantity,
  ];

  Suggestion copyWith({
    String? id,
    String? productId,
    String? productName,
    String? fromLocation,
    String? toLocation,
    SuggestionStatus? status,
    SuggestionType? type,
    int? quantity,
    String? assignedTo,
    String? overrideJustification,
    String? overriddenFromLocation,
    String? overriddenToLocation,
    bool? isOverridden,
    List<Map<String, int>>? path,
  }) {
    return Suggestion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      status: status ?? this.status,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      assignedTo: assignedTo ?? this.assignedTo,
      overrideJustification:
          overrideJustification ?? this.overrideJustification,
      overriddenFromLocation:
          overriddenFromLocation ?? this.overriddenFromLocation,
      overriddenToLocation: overriddenToLocation ?? this.overriddenToLocation,
      isOverridden: isOverridden ?? this.isOverridden,
      path: path ?? this.path,
    );
  }

  String get statusLabel {
    switch (status) {
      case SuggestionStatus.ready:
        return 'READY';
      case SuggestionStatus.urgent:
        return 'URGENT';
      case SuggestionStatus.pending:
        return 'PENDING';
    }
  }

  String get typeLabel {
    switch (type) {
      case SuggestionType.picking:
        return 'PICKING';
      case SuggestionType.store:
        return 'STORE';
    }
  }

  /// Effective locations (after override if any)
  String get effectiveFrom => overriddenFromLocation ?? fromLocation;
  String get effectiveTo => overriddenToLocation ?? toLocation;
}
