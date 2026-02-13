import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/models.dart';

// States
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;
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

// Cubit
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void login(String id, String password) {
    emit(AuthLoading());

    // Mock authentication logic
    Future.delayed(const Duration(milliseconds: 800), () {
      if (id.isEmpty || password.isEmpty) {
        emit(const AuthError('Please enter both ID and password'));
        return;
      }

      // Demo users
      AppUser? user;
      switch (id.toLowerCase()) {
        case 'admin':
          user = const AppUser(
            id: 'admin',
            fullName: 'Sarah Wilson',
            role: UserRole.admin,
          );
          break;
        case 'supervisor':
          user = const AppUser(
            id: 'supervisor',
            fullName: 'Jane Smith',
            role: UserRole.supervisor,
          );
          break;
        case 'employee':
          user = const AppUser(
            id: 'employee',
            fullName: 'John Doe',
            role: UserRole.employee,
          );
          break;
        default:
          emit(const AuthError('Invalid credentials'));
          return;
      }

      emit(AuthAuthenticated(user));
    });
  }

  void logout() {
    emit(AuthInitial());
  }
}
