import 'package:frontend/data/models/models.dart';
import 'package:frontend/data/repositories/repositories.dart';

/// Seeds the local database with initial demo data on first launch.
/// Replaces the old MockData static class.
class DatabaseSeeder {
  final UserRepository userRepo;
  final ProductRepository productRepo;
  final ChariotRepository chariotRepo;
  final OrderRepository orderRepo;
  final OperationRepository operationRepo;
  final OperationLogRepository operationLogRepo;
  final ReportRepository reportRepo;

  DatabaseSeeder({
    required this.userRepo,
    required this.productRepo,
    required this.chariotRepo,
    required this.orderRepo,
    required this.operationRepo,
    required this.operationLogRepo,
    required this.reportRepo,
  });

  /// Check if seeding has already been done.
  Future<bool> isSeeded() async {
    final count = await userRepo.count();
    return count > 0;
  }

  /// Run the full seed.
  Future<void> seed() async {
    if (await isSeeded()) return;

    await _seedUsers();
    await _seedProducts();
    await _seedChariots();
    await _seedOrders();
    await _seedOperations();
    await _seedOperationLogs();
    await _seedReports();
  }

  Future<void> _seedUsers() async {
    final now = DateTime.now();
    final users = [
      User(id: '001', name: 'John Doe', email: 'john@warehouse.com', password: 'pass', role: UserRole.employee, createdAt: now, updatedAt: now),
      User(id: '002', name: 'Jane Smith', email: 'jane@warehouse.com', password: 'pass', role: UserRole.supervisor, createdAt: now, updatedAt: now),
      User(id: '003', name: 'Robert Johnson', email: 'robert@warehouse.com', password: 'pass', role: UserRole.employee, createdAt: now, updatedAt: now),
      User(id: '004', name: 'Emily Davis', email: 'emily@warehouse.com', password: 'pass', role: UserRole.supervisor, createdAt: now, updatedAt: now),
      User(id: '005', name: 'Michael Chen', email: 'michael@warehouse.com', password: 'pass', role: UserRole.employee, createdAt: now, updatedAt: now),
      User(id: '006', name: 'Sarah Wilson', email: 'admin@warehouse.com', password: 'admin', role: UserRole.admin, createdAt: now, updatedAt: now),
      User(id: '007', name: 'Ahmed Benali', email: 'ahmed@warehouse.com', password: 'pass', role: UserRole.employee, createdAt: now, updatedAt: now),
      User(id: '008', name: 'Youssef Kaci', email: 'youssef@warehouse.com', password: 'pass', role: UserRole.supervisor, createdAt: now, updatedAt: now),
      User(id: '009', name: 'Karim Hadj', email: 'karim@warehouse.com', password: 'pass', role: UserRole.employee, isActive: false, createdAt: now, updatedAt: now),
      User(id: '010', name: 'Nadia Merah', email: 'nadia@warehouse.com', password: 'admin', role: UserRole.admin, createdAt: now, updatedAt: now),
      // Legacy demo users for easy login
      User(id: 'admin', name: 'Admin', email: 'admin', password: 'admin', role: UserRole.admin, createdAt: now, updatedAt: now),
      User(id: 'supervisor', name: 'Supervisor', email: 'supervisor', password: 'pass', role: UserRole.supervisor, createdAt: now, updatedAt: now),
      User(id: 'employee', name: 'Employee', email: 'employee', password: 'pass', role: UserRole.employee, createdAt: now, updatedAt: now),
    ];
    await userRepo.insertAll(users);
  }

  Future<void> _seedProducts() async {
    final now = DateTime.now();
    final products = [
      Product(id: 'P-99042', sku: 'SKU-99234-A', name: 'Industrial Drill X500', category: 'Tools', weight: 4.5, isActive: true, createdAt: now, updatedAt: now),
      Product(id: 'P-55219', sku: 'SKU-11209-B', name: 'Safety Goggles (Clear)', category: 'Safety', weight: 0.2, isActive: true, createdAt: now, updatedAt: now),
      Product(id: 'P-88219', sku: 'SKU-55412-C', name: 'Reflective Vest (Orange)', category: 'Safety', weight: 0.5, isActive: true, createdAt: now, updatedAt: now),
      Product(id: 'P-22341', sku: 'SKU-22341-F', name: 'Hex Bolt M10 (100pk)', category: 'Hardware', weight: 3.0, isActive: true, createdAt: now, updatedAt: now),
      Product(id: 'P-88712', sku: 'SKU-88712-P', name: 'Precision Caliper 150mm', category: 'Tools', weight: 0.8, isActive: true, createdAt: now, updatedAt: now),
      Product(id: 'P-44102', sku: 'SKU-44102-L', name: 'WD-40 Specialist Spray', category: 'Chemicals', weight: 0.4, isActive: true, createdAt: now, updatedAt: now),
      Product(id: 'P-77410', sku: 'SKU-77410-S', name: 'Steel Cable 10m Roll', category: 'Materials', weight: 12.0, isActive: true, createdAt: now, updatedAt: now),
      Product(id: 'P-88231', sku: 'SKU-88231-E', name: 'LED Floodlight 100W', category: 'Electrical', weight: 2.5, isActive: true, createdAt: now, updatedAt: now),
      Product(id: 'P-99823', sku: 'SKU-99823-H', name: 'Hydraulic Jack 5T', category: 'Equipment', weight: 25.0, isActive: true, createdAt: now, updatedAt: now),
      Product(id: 'P-33102', sku: 'SKU-33102-W', name: 'Pallet Wrap Film', category: 'Packaging', weight: 1.5, isActive: true, createdAt: now, updatedAt: now),
      Product(id: 'P-11209', sku: 'SKU-11209-X', name: 'Safety Goggles (Tinted)', category: 'Safety', weight: 0.2, isActive: true, createdAt: now, updatedAt: now),
    ];
    await productRepo.insertAll(products);
  }

  Future<void> _seedChariots() async {
    final now = DateTime.now();
    final chariots = [
      Chariot(id: 'CH-001', code: 'CH-001', isActive: true, createdAt: now, updatedAt: now),
      Chariot(id: 'CH-002', code: 'CH-002', isActive: true, createdAt: now, updatedAt: now),
      Chariot(id: 'CH-003', code: 'CH-003', isActive: true, createdAt: now, updatedAt: now),
      Chariot(id: 'CH-004', code: 'CH-004', isActive: true, createdAt: now, updatedAt: now),
      Chariot(id: 'CH-005', code: 'CH-005', isActive: false, createdAt: now, updatedAt: now),
      Chariot(id: 'CH-006', code: 'CH-006', isActive: true, createdAt: now, updatedAt: now),
    ];
    await chariotRepo.insertAll(chariots);
  }

  Future<void> _seedOrders() async {
    final now = DateTime.now();
    final orders = [
      Order(
        id: 'ORD-001',
        type: OrderType.picking,
        status: OrderStatus.aiGenerated,
        generatedByAi: true,
        lines: [
          const OrderLine(productId: 'P-99823', sku: 'SKU-99823-H', productName: 'Hydraulic Jack 5T', quantity: 15),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Order(
        id: 'ORD-002',
        type: OrderType.picking,
        status: OrderStatus.aiGenerated,
        generatedByAi: true,
        lines: [
          const OrderLine(productId: 'P-77410', sku: 'SKU-77410-S', productName: 'Steel Cable 10m', quantity: 10),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Order(
        id: 'ORD-003',
        type: OrderType.preparation,
        status: OrderStatus.pending,
        generatedByAi: true,
        lines: [
          const OrderLine(productId: 'P-88231', sku: 'SKU-88231-E', productName: 'LED Floodlight 100W', quantity: 25),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Order(
        id: 'ORD-004',
        type: OrderType.preparation,
        status: OrderStatus.aiGenerated,
        generatedByAi: true,
        lines: [
          const OrderLine(productId: 'P-44102', sku: 'SKU-44102-L', productName: 'WD-40 Specialist', quantity: 50),
        ],
        createdAt: now,
        updatedAt: now,
      ),
    ];
    await orderRepo.insertAll(orders);
  }

  Future<void> _seedOperations() async {
    final now = DateTime.now();
    final operations = [
      // Picking operations
      Operation(id: 'T001', type: OperationType.picking, status: OperationStatus.pending, employeeId: '001', productId: 'P-99042', quantity: 15, sourceX: 7, sourceY: 1, sourceFloor: 1, destinationX: 7, destinationY: 0, destinationFloor: 0, createdAt: now, updatedAt: now),
      Operation(id: 'T002', type: OperationType.picking, status: OperationStatus.pending, employeeId: '001', productId: 'P-55219', quantity: 10, sourceX: 7, sourceY: 2, sourceFloor: 1, destinationX: 7, destinationY: 0, destinationFloor: 0, createdAt: now, updatedAt: now),
      // Delivery operations
      Operation(id: 'T003', type: OperationType.delivery, status: OperationStatus.pending, employeeId: '003', productId: 'P-88219', quantity: 8, sourceX: 7, sourceY: 0, sourceFloor: 0, destinationX: 0, destinationY: 0, destinationFloor: 0, createdAt: now, updatedAt: now),
      Operation(id: 'T004', type: OperationType.delivery, status: OperationStatus.pending, employeeId: '005', productId: 'P-77410', quantity: 20, sourceX: 7, sourceY: 0, sourceFloor: 0, destinationX: 0, destinationY: 0, destinationFloor: 0, createdAt: now, updatedAt: now),
      // Receipt operations
      Operation(id: 'T005', type: OperationType.receipt, status: OperationStatus.pending, employeeId: '001', productId: 'P-44102', quantity: 50, destinationX: 0, destinationY: 0, destinationFloor: 0, createdAt: now, updatedAt: now),
      Operation(id: 'T006', type: OperationType.receipt, status: OperationStatus.pending, employeeId: '003', productId: 'P-22341', quantity: 100, destinationX: 0, destinationY: 0, destinationFloor: 0, createdAt: now, updatedAt: now),
      // Transfer/storage operations
      Operation(id: 'T007', type: OperationType.transfer, status: OperationStatus.pending, employeeId: '007', productId: 'P-44102', quantity: 50, sourceX: 0, sourceY: 0, sourceFloor: 0, destinationX: 7, destinationY: 1, destinationFloor: 1, createdAt: now, updatedAt: now),
      Operation(id: 'T008', type: OperationType.transfer, status: OperationStatus.pending, employeeId: '005', productId: 'P-88712', quantity: 30, sourceX: 0, sourceY: 0, sourceFloor: 0, destinationX: 7, destinationY: 3, destinationFloor: 1, createdAt: now, updatedAt: now),
      // Completed
      Operation(id: 'T009', type: OperationType.picking, status: OperationStatus.completed, employeeId: '001', productId: 'P-99823', quantity: 15, sourceX: 7, sourceY: 1, sourceFloor: 1, destinationX: 7, destinationY: 0, destinationFloor: 0, startedAt: now.subtract(const Duration(hours: 2)), completedAt: now.subtract(const Duration(hours: 1)), createdAt: now, updatedAt: now),
      Operation(id: 'T010', type: OperationType.delivery, status: OperationStatus.completed, employeeId: '003', productId: 'P-99823', quantity: 15, sourceX: 7, sourceY: 0, sourceFloor: 0, destinationX: 0, destinationY: 0, destinationFloor: 0, startedAt: now.subtract(const Duration(hours: 3)), completedAt: now.subtract(const Duration(hours: 2)), createdAt: now, updatedAt: now),
      // In progress
      Operation(id: 'T011', type: OperationType.transfer, status: OperationStatus.inProgress, employeeId: '007', productId: 'P-11209', quantity: 25, sourceX: 0, sourceY: 0, sourceFloor: 0, destinationX: 7, destinationY: 2, destinationFloor: 1, startedAt: now.subtract(const Duration(minutes: 30)), createdAt: now, updatedAt: now),
    ];
    await operationRepo.insertAll(operations);
  }

  Future<void> _seedOperationLogs() async {
    final now = DateTime.now();
    final logs = [
      OperationLog(id: 'L001', operationId: 'T007', employeeId: '008', productId: 'P-44102', quantity: 50, type: OperationType.transfer, overriderId: '008', storageFloor: 1, storageRow: 1, storageCol: 5, overrideReason: 'Closer to expedition zone', aiSuggestedFloor: 3, aiSuggestedRow: 3, aiSuggestedCol: 5, createdAt: now, updatedAt: now),
      OperationLog(id: 'L002', operationId: 'T005', employeeId: '001', productId: 'P-44102', quantity: 50, type: OperationType.receipt, createdAt: now.subtract(const Duration(minutes: 15)), updatedAt: now),
      OperationLog(id: 'L003', operationId: 'T009', employeeId: '007', productId: 'P-99823', quantity: 15, type: OperationType.picking, storageFloor: 1, storageRow: 1, storageCol: 2, createdAt: now.subtract(const Duration(minutes: 30)), updatedAt: now),
      OperationLog(id: 'L004', operationId: 'T010', employeeId: '003', productId: 'P-99823', quantity: 15, type: OperationType.delivery, createdAt: now.subtract(const Duration(hours: 1)), updatedAt: now),
      OperationLog(id: 'L005', operationId: 'T011', employeeId: '005', productId: 'P-11209', quantity: 25, type: OperationType.transfer, storageFloor: 1, storageRow: 2, storageCol: 8, createdAt: now.subtract(const Duration(hours: 2)), updatedAt: now),
      OperationLog(id: 'L006', operationId: 'T001', employeeId: '008', productId: 'P-55219', quantity: 10, type: OperationType.picking, overriderId: '006', overrideReason: 'Changed destination from B7-0A-03-02 to B7-0A-02-01', aiSuggestedFloor: 0, aiSuggestedRow: 3, aiSuggestedCol: 2, storageFloor: 0, storageRow: 2, storageCol: 1, createdAt: now.subtract(const Duration(hours: 2, minutes: 15)), updatedAt: now),
    ];
    await operationLogRepo.insertAll(logs);
  }

  Future<void> _seedReports() async {
    final now = DateTime.now();
    final reports = [
      Report(id: 'R001', operationId: 'T005', reportedBy: '001', missingQuantity: 0, physicalDamage: false, extraQuantity: 0, notes: 'All received items verified against command order CO-445.', createdAt: now, updatedAt: now),
      Report(id: 'R002', operationId: 'T009', reportedBy: '002', missingQuantity: 2, physicalDamage: false, extraQuantity: 0, notes: 'Cycle count on Floor 1 complete. 2 discrepancies found.', createdAt: now.subtract(const Duration(days: 1)), updatedAt: now),
      Report(id: 'R003', operationId: 'T010', reportedBy: '004', missingQuantity: 0, physicalDamage: true, extraQuantity: 0, notes: 'Water damage detected on 3 pallets in storage N2.', createdAt: now.subtract(const Duration(days: 2)), updatedAt: now),
      Report(id: 'R004', operationId: 'T003', reportedBy: '003', missingQuantity: 0, physicalDamage: false, extraQuantity: 3, notes: 'Extra 3 units found during delivery to expedition zone.', createdAt: now.subtract(const Duration(days: 3)), updatedAt: now),
    ];
    await reportRepo.insertAll(reports);
  }
}
