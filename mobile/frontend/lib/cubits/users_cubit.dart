import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/data/mock_data.dart';

// States
abstract class UsersState extends Equatable {
  const UsersState();
  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoaded extends UsersState {
  final List<AppUser> users;
  const UsersLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

// Cubit
class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(UsersInitial());

  void loadUsers() {
    emit(const UsersLoaded(MockData.users));
  }

  void addUser({
    required String fullName,
    required String id,
    required UserRole role,
  }) {
    if (state is UsersLoaded) {
      final current = (state as UsersLoaded).users;
      final newUser = AppUser(id: id, fullName: fullName, role: role);
      emit(UsersLoaded([...current, newUser]));
    }
  }
}
