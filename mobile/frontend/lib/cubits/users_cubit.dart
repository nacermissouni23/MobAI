import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/enums.dart';
import 'package:frontend/data/repositories/user_repository.dart';

// ── States ──────────────────────────────────────────────────

abstract class UsersState extends Equatable {
  const UsersState();
  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<User> users;
  const UsersLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

class UsersError extends UsersState {
  final String message;
  const UsersError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────

class UsersCubit extends Cubit<UsersState> {
  final UserRepository _userRepo;

  UsersCubit({required UserRepository userRepository})
    : _userRepo = userRepository,
      super(UsersInitial());

  Future<void> loadUsers() async {
    emit(UsersLoading());
    try {
      final users = await _userRepo.getAllSorted();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersError('Failed to load users: $e'));
    }
  }

  Future<void> addUser({
    required String name,
    required String email,
    required UserRole role,
    String password = '',
  }) async {
    try {
      final now = DateTime.now();
      final user = User(
        id: _userRepo.generateId(),
        name: name,
        email: email,
        password: password,
        role: role,
        createdAt: now,
        updatedAt: now,
      );
      await _userRepo.insert(user);
      await loadUsers();
    } catch (e) {
      emit(UsersError('Failed to add user: $e'));
    }
  }

  Future<void> updateUser(User updatedUser) async {
    try {
      await _userRepo.updateEntity(updatedUser);
      await loadUsers();
    } catch (e) {
      emit(UsersError('Failed to update user: $e'));
    }
  }

  Future<void> toggleUserActive(String userId) async {
    try {
      await _userRepo.toggleActive(userId);
      await loadUsers();
    } catch (e) {
      emit(UsersError('Failed to toggle user: $e'));
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _userRepo.softDelete(userId);
      await loadUsers();
    } catch (e) {
      emit(UsersError('Failed to delete user: $e'));
    }
  }
}
