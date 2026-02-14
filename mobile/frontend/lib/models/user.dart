class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'employee',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'is_active': isActive,
  };

  bool get isAdmin => role == 'admin';
  bool get isSupervisor => role == 'supervisor' || role == 'admin';
  bool get isEmployee => role == 'employee';
}
