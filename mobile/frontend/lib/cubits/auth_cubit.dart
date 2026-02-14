import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/api/api_client.dart';
import 'package:frontend/data/api/api_config.dart';
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
  final bool isOnline;
  const AuthAuthenticated(this.user, {this.isOnline = false});
  @override
  List<Object?> get props => [user, isOnline];
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
  final ApiClient? _apiClient;

  AuthCubit({required UserRepository userRepository, ApiClient? apiClient})
    : _userRepo = userRepository,
      _apiClient = apiClient,
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

      // Try backend API login first (if available)
      if (_apiClient != null) {
        try {
          final response = await _apiClient.post(
            ApiConfig.loginUrl,
            body: {'email': identifier, 'password': password},
          );

          if (response != null && response is Map<String, dynamic>) {
            final token = response['access_token'] as String?;
            final userData = response['user'] as Map<String, dynamic>?;

            if (token != null && userData != null) {
              _apiClient.setToken(token);

              // Save/update user locally
              final user = User.fromJson(userData);
              final existingLocal = await _userRepo.findOne(
                'server_id',
                userData['id'],
              );
              if (existingLocal == null) {
                await _userRepo.insertFromServer(
                  user,
                  userData['id'] as String,
                );
              }

              // Re-read from local DB to get correct local ID
              final localUser =
                  await _userRepo.findOne('server_id', userData['id']) ??
                  await _userRepo.findOne('email', identifier);
              emit(AuthAuthenticated(localUser ?? user, isOnline: true));
              return;
            }
          }
        } on ApiException catch (_) {
          // Backend login failed, fall through to local auth
        } catch (_) {
          // Network error, fall through to local auth
        }
      }

      // Fallback: local SQLite authentication
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

      emit(AuthAuthenticated(user, isOnline: false));
    } catch (e) {
      emit(AuthError('Login failed: $e'));
    }
  }

  void logout() {
    _apiClient?.clearToken();
    emit(AuthInitial());
  }
}
