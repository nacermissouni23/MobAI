import 'package:equatable/equatable.dart';

enum UserRole { admin, supervisor, employee }

class AppUser extends Equatable {
  final String id;
  final String fullName;
  final UserRole role;
  final bool isActive;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.role,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, fullName, role, isActive];

  AppUser copyWith({
    String? id,
    String? fullName,
    UserRole? role,
    bool? isActive,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }

  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.employee:
        return 'Employee';
    }
  }
}
