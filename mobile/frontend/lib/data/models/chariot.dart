import 'package:equatable/equatable.dart';

enum ChariotStatus { available, inUse, offline }

class Chariot extends Equatable {
  final String id;
  final String name;
  final ChariotStatus status;
  final String? location;
  final String? currentUser;
  final String? details;

  const Chariot({
    required this.id,
    required this.name,
    required this.status,
    this.location,
    this.currentUser,
    this.details,
  });

  @override
  List<Object?> get props => [id, name, status, location, currentUser];

  String get statusLabel {
    switch (status) {
      case ChariotStatus.available:
        return 'Available';
      case ChariotStatus.inUse:
        return 'In Use';
      case ChariotStatus.offline:
        return 'Offline';
    }
  }
}
