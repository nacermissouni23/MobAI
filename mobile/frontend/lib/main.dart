import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
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
          '/new-delivery': (context) => const NewDeliveryScreen(),
          '/pick-1': (context) => const PickScreen(),
          '/pick-2': (context) => const PickValidateScreen(),
          '/suggestion-details': (context) {
            final suggestion =
                ModalRoute.of(context)?.settings.arguments as Suggestion?;
            return SuggestionDetailsScreen(suggestion: suggestion);
          },
          '/edit-user': (context) {
            final user = ModalRoute.of(context)!.settings.arguments as AppUser;
            return EditUserScreen(user: user);
          },
          '/edit-sku': (context) {
            final sku = ModalRoute.of(context)!.settings.arguments as Sku;
            return EditSkuScreen(sku: sku);
          },
          '/edit-chariot': (context) {
            final chariot =
                ModalRoute.of(context)!.settings.arguments as Chariot;
            return EditChariotScreen(chariot: chariot);
          },
          '/delivery-task': (context) {
            final task =
                ModalRoute.of(context)!.settings.arguments as WarehouseTask;
            return DeliveryTaskScreen(task: task);
          },
          '/store-task': (context) {
            final task =
                ModalRoute.of(context)!.settings.arguments as WarehouseTask;
            return StoreTaskScreen(task: task);
          },
          '/received-receipt': (context) {
            final args =
                ModalRoute.of(context)?.settings.arguments
                    as Map<String, dynamic>?;
            return ReceivedReceiptScreen(
              productName: args?['productName'] ?? '',
              productId: args?['productId'] ?? '',
              expectedQuantity: args?['expectedQuantity'] ?? 0,
            );
          },
        },
      ),
    );
  }
}
