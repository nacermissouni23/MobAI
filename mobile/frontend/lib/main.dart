import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/api/api_client.dart';
import 'package:frontend/data/database/database_helper.dart';
import 'package:frontend/data/database/seeder.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/data/repositories/repositories.dart';
import 'package:frontend/data/sync/sync_service.dart';
import 'firebase_options.dart';
import 'package:frontend/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize database
  await DatabaseHelper.instance.database;

  // Create API client (shared across app)
  final apiClient = ApiClient();

  // Create repositories
  final userRepo = UserRepository();
  final productRepo = ProductRepository();
  final emplacementRepo = EmplacementRepository();
  final chariotRepo = ChariotRepository();
  final orderRepo = OrderRepository();
  final operationRepo = OperationRepository();
  final operationLogRepo = OperationLogRepository();
  final reportRepo = ReportRepository();
  final stockLedgerRepo = StockLedgerRepository();

  // Create sync service
  final syncService = SyncService(
    apiClient: apiClient,
    userRepo: userRepo,
    productRepo: productRepo,
    emplacementRepo: emplacementRepo,
    chariotRepo: chariotRepo,
    orderRepo: orderRepo,
    operationRepo: operationRepo,
    operationLogRepo: operationLogRepo,
    reportRepo: reportRepo,
    stockLedgerRepo: stockLedgerRepo,
  );

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
      apiClient: apiClient,
      syncService: syncService,
      userRepo: userRepo,
      productRepo: productRepo,
      emplacementRepo: emplacementRepo,
      chariotRepo: chariotRepo,
      orderRepo: orderRepo,
      operationRepo: operationRepo,
      operationLogRepo: operationLogRepo,
      reportRepo: reportRepo,
      stockLedgerRepo: stockLedgerRepo,
    ),
  );
}

class WarehouseApp extends StatelessWidget {
  final ApiClient apiClient;
  final SyncService syncService;
  final UserRepository userRepo;
  final ProductRepository productRepo;
  final EmplacementRepository emplacementRepo;
  final ChariotRepository chariotRepo;
  final OrderRepository orderRepo;
  final OperationRepository operationRepo;
  final OperationLogRepository operationLogRepo;
  final ReportRepository reportRepo;
  final StockLedgerRepository stockLedgerRepo;

  const WarehouseApp({
    super.key,
    required this.apiClient,
    required this.syncService,
    required this.userRepo,
    required this.productRepo,
    required this.emplacementRepo,
    required this.chariotRepo,
    required this.orderRepo,
    required this.operationRepo,
    required this.operationLogRepo,
    required this.reportRepo,
    required this.stockLedgerRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: syncService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                AuthCubit(userRepository: userRepo, apiClient: apiClient),
          ),
          BlocProvider(create: (_) => NavigationCubit()),
          BlocProvider(
            create: (_) => OperationsCubit(
              operationRepository: operationRepo,
              operationLogRepository: operationLogRepo,
              emplacementRepository: emplacementRepo,
              stockLedgerRepository: stockLedgerRepo,
              reportRepository: reportRepo,
            )..loadOperations(),
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
            create: (_) =>
                OrdersCubit(orderRepository: orderRepo)..loadOrders(),
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
          BlocProvider(create: (_) => SyncCubit(syncService: syncService)),
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
              final order =
                  ModalRoute.of(context)?.settings.arguments as Order?;
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
                operationId: args?['operationId'] as String?,
              );
            },
          },
        ),
      ),
    );
  }
}
