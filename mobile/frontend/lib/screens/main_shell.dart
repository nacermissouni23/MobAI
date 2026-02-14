import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/screens/screens.dart';

/// The main shell screen that uses NavigationCubit to swap between pages.
/// This is the primary container for supervisor and admin users.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return _buildPage(state.currentPage);
      },
    );
  }

  Widget _buildPage(AppPage page) {
    switch (page) {
      case AppPage.home:
        return const HomeScreen();
      case AppPage.tasks:
        return const TasksScreen();
      case AppPage.users:
        return const UsersScreen();
      case AppPage.warehouse:
        return const WarehouseScreen();
      case AppPage.skus:
        return const SkusScreen();
      case AppPage.chariots:
        return const ChariotsScreen();
      case AppPage.suggestions:
        return const SuggestionsScreen();
      case AppPage.reports:
        return const ReportsScreen();
      case AppPage.logs:
        return const LogsScreen();
    }
  }
}
