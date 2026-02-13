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

  Chariot copyWith({
    String? id,
    String? name,
    ChariotStatus? status,
    String? location,
    String? currentUser,
    String? details,
  }) {
    return Chariot(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      location: location ?? this.location,
      currentUser: currentUser ?? this.currentUser,
      details: details ?? this.details,
    );
  }

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
