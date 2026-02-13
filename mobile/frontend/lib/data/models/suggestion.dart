import 'package:equatable/equatable.dart';

enum SuggestionStatus { ready, urgent, pending }

class Suggestion extends Equatable {
  final String id;
  final String productId;
  final String fromLocation;
  final String toLocation;
  final SuggestionStatus status;
  final int quantity;
  final String? assignedTo;
  final String? overrideJustification;
  final List<Map<String, int>>? path;

  const Suggestion({
    required this.id,
    required this.productId,
    required this.fromLocation,
    required this.toLocation,
    required this.status,
    this.quantity = 0,
    this.assignedTo,
    this.overrideJustification,
    this.path,
  });

  @override
  List<Object?> get props => [
    id,
    productId,
    fromLocation,
    toLocation,
    status,
    quantity,
  ];

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
}
