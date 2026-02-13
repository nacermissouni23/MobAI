import 'package:frontend/data/models/models.dart';

class MockData {
  // Users
  static const List<AppUser> users = [
    AppUser(id: '001', fullName: 'John Doe', role: UserRole.employee),
    AppUser(id: '002', fullName: 'Jane Smith', role: UserRole.supervisor),
    AppUser(id: '003', fullName: 'Robert Johnson', role: UserRole.employee),
    AppUser(id: '004', fullName: 'Emily Davis', role: UserRole.supervisor),
    AppUser(id: '005', fullName: 'Michael Chen', role: UserRole.employee),
    AppUser(id: '006', fullName: 'Sarah Wilson', role: UserRole.admin),
  ];

  // Tasks
  static List<WarehouseTask> tasks = [
    WarehouseTask(
      id: 'T001',
      type: TaskType.pick,
      status: TaskStatus.pending,
      location: 'A-12-04',
      productId: 'P-99042',
      quantity: 15,
      scheduledAt: DateTime(2026, 2, 13, 10, 30),
      fromLocation: 'A-12-04',
      toLocation: 'B-05-01',
    ),
    WarehouseTask(
      id: 'T002',
      type: TaskType.deliver,
      status: TaskStatus.pending,
      location: 'B-05-01',
      productId: 'P-88219',
      quantity: 8,
      scheduledAt: DateTime(2026, 2, 13, 11, 15),
    ),
    WarehouseTask(
      id: 'T003',
      type: TaskType.store,
      status: TaskStatus.pending,
      location: 'C-02-09',
      productId: 'P-77410',
      quantity: 20,
      scheduledAt: DateTime(2026, 2, 13, 11, 45),
      fromLocation: 'Receiving',
      toLocation: 'C-02-09',
    ),
    WarehouseTask(
      id: 'T004',
      type: TaskType.pick,
      status: TaskStatus.pending,
      location: 'D-10-15',
      productId: 'P-55219',
      quantity: 15,
      scheduledAt: DateTime(2026, 2, 13, 12, 30),
      fromLocation: 'D-10-15',
      toLocation: 'E-03-02',
    ),
  ];

  // Chariots
  static const List<Chariot> chariots = [
    Chariot(
      id: 'CH-001',
      name: 'Chariot #001',
      status: ChariotStatus.available,
      location: 'Zone A-12',
      details: 'Last used: 08:30 AM',
    ),
    Chariot(
      id: 'CH-002',
      name: 'Chariot #002',
      status: ChariotStatus.inUse,
      currentUser: 'J. Miller',
      location: 'Zone C-04',
      details: 'Active 45m',
    ),
    Chariot(
      id: 'CH-003',
      name: 'Chariot #003',
      status: ChariotStatus.available,
      location: 'Charging Dock B',
      details: 'Battery 98%',
    ),
    Chariot(
      id: 'CH-004',
      name: 'Chariot #004',
      status: ChariotStatus.inUse,
      currentUser: 'S. Chen',
      location: 'Zone A-02',
      details: 'Active 12m',
    ),
    Chariot(
      id: 'CH-005',
      name: 'Chariot #005',
      status: ChariotStatus.offline,
      details: 'Scheduled Maintenance • Tech: R. Davis',
    ),
  ];

  // SKUs
  static const List<Sku> skus = [
    Sku(
      id: 'SKU1',
      name: 'Industrial Drill - X500',
      skuCode: 'SKU-99234-A',
      quantity: 45,
      stockStatus: SkuStockStatus.inStock,
      locationLabel: 'Aisle 4, Shelf B',
    ),
    Sku(
      id: 'SKU2',
      name: 'Safety Goggles (Clear)',
      skuCode: 'SKU-11209-B',
      quantity: 5,
      stockStatus: SkuStockStatus.lowStock,
      locationLabel: 'Aisle 1, Shelf A',
    ),
    Sku(
      id: 'SKU3',
      name: 'Reflective Vest (Orange)',
      skuCode: 'SKU-55412-C',
      quantity: 120,
      stockStatus: SkuStockStatus.inStock,
      locationLabel: 'Aisle 8, Shelf D',
    ),
    Sku(
      id: 'SKU4',
      name: 'Hex Bolt M10 (100pk)',
      skuCode: 'SKU-22341-F',
      quantity: 0,
      stockStatus: SkuStockStatus.outOfStock,
      locationLabel: 'Aisle 2, Bin 12',
    ),
    Sku(
      id: 'SKU5',
      name: 'Precision Caliper 150mm',
      skuCode: 'SKU-88712-P',
      quantity: 30,
      stockStatus: SkuStockStatus.inStock,
      locationLabel: 'Tools Room, Cabinet 1',
    ),
    Sku(
      id: 'SKU6',
      name: 'WD-40 Specialist Spray',
      skuCode: 'SKU-44102-L',
      quantity: 60,
      stockStatus: SkuStockStatus.inStock,
      locationLabel: 'Hazardous Store',
    ),
  ];

  // Suggestions
  static const List<Suggestion> suggestions = [
    Suggestion(
      id: 'SG001',
      productId: 'P-99823',
      fromLocation: 'A-12',
      toLocation: 'B-04',
      status: SuggestionStatus.ready,
      quantity: 15,
    ),
    Suggestion(
      id: 'SG002',
      productId: 'P-77410',
      fromLocation: 'C-02',
      toLocation: 'D-09',
      status: SuggestionStatus.urgent,
      quantity: 10,
    ),
    Suggestion(
      id: 'SG003',
      productId: 'P-88231',
      fromLocation: 'E-15',
      toLocation: 'F-22',
      status: SuggestionStatus.pending,
      quantity: 25,
    ),
  ];

  // Reports
  static List<Report> reports = [
    Report(
      id: 'R001',
      title: 'Inbound Audit Complete',
      date: DateTime(2026, 2, 13, 9, 45),
      iconName: 'assignment_turned_in',
      isHighlighted: true,
    ),
    Report(
      id: 'R002',
      title: 'Inventory Reconciliation',
      date: DateTime(2026, 2, 12, 16, 20),
      iconName: 'inventory_2',
    ),
    Report(
      id: 'R003',
      title: 'Shift Summary Report',
      date: DateTime(2026, 2, 12, 6, 0),
      iconName: 'description',
    ),
    Report(
      id: 'R004',
      title: 'Damage Logs: Bay 12-B',
      date: DateTime(2026, 2, 11, 14, 15),
      iconName: 'report_problem',
    ),
    Report(
      id: 'R005',
      title: 'Outbound Efficiency Analysis',
      date: DateTime(2026, 2, 10, 11, 30),
      iconName: 'local_shipping',
      isHighlighted: true,
    ),
    Report(
      id: 'R006',
      title: 'Daily Throughput Report',
      date: DateTime(2026, 2, 9, 20, 0),
      iconName: 'monitoring',
    ),
  ];

  // Logs
  static const List<LogEntry> logs = [
    LogEntry(
      id: 'L001',
      time: '10:00 AM',
      timeAgo: 'Just now',
      category: 'Override',
      userName: 'Supervisor Youssef',
      description: 'Override AI suggestion for location assignment.',
      referenceLabel: 'Reference ID',
      referenceId: 'XC-992',
    ),
    LogEntry(
      id: 'L002',
      time: '11:15 AM',
      timeAgo: '1h ago',
      category: 'Picking',
      userName: 'Employee Ahmed',
      description: 'Validated picking sequence completion for shipment.',
      referenceLabel: 'Order ID',
      referenceId: 'ORD-55',
    ),
    LogEntry(
      id: 'L003',
      time: '12:30 PM',
      timeAgo: '2h ago',
      category: 'Stock',
      userName: 'Operator Sarah',
      description: 'Inventory adjustment after cycle count mismatch.',
      referenceLabel: 'SKU',
      referenceId: 'SKU-8821-B',
    ),
    LogEntry(
      id: 'L004',
      time: '01:45 PM',
      timeAgo: '3h ago',
      category: 'Relocation',
      userName: 'Employee Mike',
      description: 'Pallet relocation from Receiving to Zone A-4.',
      referenceLabel: 'Location',
      referenceId: 'BIN-404-X',
    ),
  ];

  // Warehouse Grid (simplified for the visual display)
  static List<WarehouseCell> generateWarehouseGrid({int floor = 0}) {
    final cells = <WarehouseCell>[];
    const width = 6;
    const height = 3;

    final occupied = {'0-0', '0-1', '0-4', '1-0', '1-1', '1-4', '2-2', '2-4'};

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final key = '$y-$x';
        final isOcc = occupied.contains(key);
        cells.add(
          WarehouseCell(
            x: x,
            y: y,
            floor: floor,
            isSlot: true,
            isRoad: false,
            isOccupied: isOcc,
            productId: isOcc
                ? 'B7-${(y * width + x + 1).toString().padLeft(2, '0')}'
                : null,
          ),
        );
      }
    }
    return cells;
  }
}
