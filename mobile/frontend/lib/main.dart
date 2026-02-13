import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/screens/screens.dart';

void main() {
  runApp(const WarehouseApp());
}

class WarehouseApp extends StatelessWidget {
  const WarehouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(create: (_) => TasksCubit()..loadTasks()),
        BlocProvider(create: (_) => ChariotsCubit()..loadChariots()),
        BlocProvider(create: (_) => SkusCubit()..loadSkus()),
        BlocProvider(create: (_) => UsersCubit()..loadUsers()),
        BlocProvider(create: (_) => SuggestionsCubit()..loadSuggestions()),
        BlocProvider(create: (_) => WarehouseCubit()..loadWarehouse()),
      ],
      child: MaterialApp(
        title: 'Warehouse Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const MainShell(),
          '/tasks': (context) => const TasksScreen(),
          '/add-chariot': (context) => const AddChariotScreen(),
          '/add-sku': (context) => const AddSkuScreen(),
          '/add-user': (context) => const AddUserScreen(),
          '/new-receipt': (context) => const NewReceiptScreen(),
          '/pick-1': (context) => const PickScreen(),
          '/pick-2': (context) => const PickValidateScreen(),
          '/suggestion-details': (context) => const SuggestionDetailsScreen(),
        },
      ),
    );
  }
}
