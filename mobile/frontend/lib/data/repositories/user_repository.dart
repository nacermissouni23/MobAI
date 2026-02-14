import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/enums.dart';
import 'base_repository.dart';

class UserRepository extends BaseRepository<User> {
  UserRepository() : super('users');

  @override
  User fromMap(Map<String, dynamic> map) => User.fromMap(map);

  @override
  Map<String, dynamic> toMap(User entity) => entity.toMap();

  // ── Domain queries ────────────────────────────────────────

  /// Find user by email (for login).
  Future<User?> findByEmail(String email) => findOne('email', email);

  /// Authenticate by email + password. Returns null if not found.
  Future<User?> authenticate(String email, String password) async {
    final results = await query(
      where: 'email = ? AND password = ? AND is_active = 1',
      whereArgs: [email, password],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  /// Get users by role.
  Future<List<User>> getByRole(UserRole role) {
    return query(where: 'role = ?', whereArgs: [role.value]);
  }

  /// Get active users only.
  Future<List<User>> getActiveUsers() {
    return query(where: 'is_active = 1', orderBy: 'name ASC');
  }

  /// Get all users sorted by name.
  Future<List<User>> getAllSorted() {
    return getAll(orderBy: 'name ASC');
  }

  /// Toggle user active status.
  Future<void> toggleActive(String userId) async {
    final user = await getById(userId);
    if (user != null) {
      await update(userId, {'is_active': user.isActive ? 0 : 1});
    }
  }
}
