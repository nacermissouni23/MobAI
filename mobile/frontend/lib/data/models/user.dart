import 'package:equatable/equatable.dart';
import 'package:frontend/data/enums.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? emplacementId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sync fields
  final String? serverId;
  final bool syncPending;
  final DateTime? lastSyncedAt;
  final bool isDeleted;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.password = '',
    this.role = UserRole.employee,
    this.emplacementId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.syncPending = true,
    this.lastSyncedAt,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [id, name, email, role, isActive];

  // --------------- Serialization ---------------

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.value,
      'emplacement_id': emplacementId,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'server_id': serverId,
      'sync_pending': syncPending ? 1 : 0,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String? ?? 'employee'),
      emplacementId: map['emplacement_id'] as String?,
      isActive: (map['is_active'] as int?) == 1,
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

  /// For API sync payloads.
  Map<String, dynamic> toJson() {
    return {
      'id': serverId ?? id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.value,
      'emplacement_id': emplacementId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json, {String? localId}) {
    return User(
      id: localId ?? json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String? ?? 'employee'),
      emplacementId: json['emplacement_id']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
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

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    String? emplacementId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serverId,
    bool? syncPending,
    DateTime? lastSyncedAt,
    bool? isDeleted,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      emplacementId: emplacementId ?? this.emplacementId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      syncPending: syncPending ?? this.syncPending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Convenience for UI: full name display.
  String get fullName => name;

  /// Convenience for UI: role label.
  String get roleLabel => role.label;
}
