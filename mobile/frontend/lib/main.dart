import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/database/database_helper.dart';
import 'package:frontend/data/database/seeder.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/data/repositories/repositories.dart';
import 'package:frontend/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseHelper.instance.database;

  // Create repositories
  final userRepo = UserRepository();
  final productRepo = ProductRepository();
  final emplacementRepo = EmplacementRepository();
  final chariotRepo = ChariotRepository();
  final orderRepo = OrderRepository();
  final operationRepo = OperationRepository();
  final operationLogRepo = OperationLogRepository();
  final reportRepo = ReportRepository();

  // Seed on first launch
  final seeder = DatabaseSeeder(
    userRepo: userRepo,
    productRepo: productRepo,
    chariotRepo: chariotRepo,
    orderRepo: orderRepo,
    operationRepo: operationRepo,
    operationLogRepo: operationLogRepo,
    reportRepo: reportRepo,
  );
  if (!await seeder.isSeeded()) {
    await seeder.seed();
  }

  runApp(
    WarehouseApp(
      userRepo: userRepo,
      productRepo: productRepo,
      emplacementRepo: emplacementRepo,
      chariotRepo: chariotRepo,
      orderRepo: orderRepo,
      operationRepo: operationRepo,
      operationLogRepo: operationLogRepo,
      reportRepo: reportRepo,
    ),
  );
}

class WarehouseApp extends StatelessWidget {
  final UserRepository userRepo;
  final ProductRepository productRepo;
  final EmplacementRepository emplacementRepo;
  final ChariotRepository chariotRepo;
  final OrderRepository orderRepo;
  final OperationRepository operationRepo;
  final OperationLogRepository operationLogRepo;
  final ReportRepository reportRepo;

  const WarehouseApp({
    super.key,
    required this.userRepo,
    required this.productRepo,
    required this.emplacementRepo,
    required this.chariotRepo,
    required this.orderRepo,
    required this.operationRepo,
    required this.operationLogRepo,
    required this.reportRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(userRepository: userRepo)),
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(
          create: (_) =>
              OperationsCubit(operationRepository: operationRepo)
                ..loadOperations(),
        ),
        BlocProvider(
          create: (_) =>
              ChariotsCubit(chariotRepository: chariotRepo)..loadChariots(),
        ),
        BlocProvider(
          create: (_) =>
              ProductsCubit(productRepository: productRepo)..loadProducts(),
        ),
        BlocProvider(
          create: (_) => UsersCubit(userRepository: userRepo)..loadUsers(),
        ),
        BlocProvider(
          create: (_) => OrdersCubit(orderRepository: orderRepo)..loadOrders(),
        ),
        BlocProvider(
          create: (_) =>
              ReportsCubit(reportRepository: reportRepo)..loadReports(),
        ),
        BlocProvider(
          create: (_) =>
              LogsCubit(operationLogRepository: operationLogRepo)..loadLogs(),
        ),
        BlocProvider(
          create: (_) =>
              WarehouseCubit(emplacementRepository: emplacementRepo)
                ..loadWarehouse(),
        ),
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
          '/pick-1': (context) {
            final task =
                ModalRoute.of(context)!.settings.arguments as Operation;
            return PickScreen(task: task);
          },
          '/pick-2': (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return PickValidateScreen(
              task: args['task'] as Operation,
              pickedQuantity: args['pickedQuantity'] as int,
            );
          },
          '/suggestion-details': (context) {
            final order = ModalRoute.of(context)?.settings.arguments as Order?;
            return SuggestionDetailsScreen(suggestion: order);
          },
          '/edit-user': (context) {
            final user = ModalRoute.of(context)!.settings.arguments as User;
            return EditUserScreen(user: user);
          },
          '/edit-sku': (context) {
            final product =
                ModalRoute.of(context)!.settings.arguments as Product;
            return EditSkuScreen(sku: product);
          },
          '/edit-chariot': (context) {
            final chariot =
                ModalRoute.of(context)!.settings.arguments as Chariot;
            return EditChariotScreen(chariot: chariot);
          },
          '/delivery-task': (context) {
            final task =
                ModalRoute.of(context)!.settings.arguments as Operation;
            return DeliveryTaskScreen(task: task);
          },
          '/store-task': (context) {
            final task =
                ModalRoute.of(context)!.settings.arguments as Operation;
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
