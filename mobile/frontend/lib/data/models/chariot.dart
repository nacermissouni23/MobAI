import 'package:equatable/equatable.dart';

class Chariot extends Equatable {
  final String id;
  final bool isActive;

  const Chariot({required this.id, required this.isActive});

  @override
  List<Object?> get props => [id, isActive];

  Chariot copyWith({String? id, bool? isActive}) {
    return Chariot(id: id ?? this.id, isActive: isActive ?? this.isActive);
  }
}
