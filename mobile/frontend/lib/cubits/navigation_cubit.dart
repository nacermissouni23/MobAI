import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppPage {
  home,
  tasks,
  users,
  warehouse,
  skus,
  chariots,
  suggestions,
  reports,
  logs,
}

// States
class NavigationState extends Equatable {
  final AppPage currentPage;
  const NavigationState({this.currentPage = AppPage.home});
  @override
  List<Object?> get props => [currentPage];
}

// Cubit
class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void navigateTo(AppPage page) {
    emit(NavigationState(currentPage: page));
  }
}
