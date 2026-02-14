import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/repositories/user_repository.dart';

// ── States ──────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────

class AuthCubit extends Cubit<AuthState> {
  final UserRepository _userRepo;

  AuthCubit({required UserRepository userRepository})
    : _userRepo = userRepository,
      super(AuthInitial());

  User? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  Future<void> login(String identifier, String password) async {
    emit(AuthLoading());
    try {
      if (identifier.isEmpty || password.isEmpty) {
        emit(const AuthError('Please enter both ID and password'));
        return;
      }

      // Try by email first
      var user = await _userRepo.authenticate(identifier, password);

      // Fallback: find by name and verify password
      if (user == null) {
        final byName = await _userRepo.query(
          where: 'LOWER(name) = ? AND is_active = 1',
          whereArgs: [identifier.toLowerCase()],
          limit: 1,
        );
        if (byName.isNotEmpty && byName.first.password == password) {
          user = byName.first;
        }
      }

      // Fallback: find by id and verify password
      if (user == null) {
        final byId = await _userRepo.getById(identifier);
        if (byId != null && byId.isActive && byId.password == password) {
          user = byId;
        }
      }

      if (user == null) {
        emit(const AuthError('Invalid credentials'));
        return;
      }

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Login failed: $e'));
    }
  }

  void logout() {
    emit(AuthInitial());
  }
}
