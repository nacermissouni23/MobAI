import '../models/order.dart';
import '../models/operation.dart';
import '../models/product.dart';
import '../models/report.dart';
import '../models/emplacement.dart';
import '../models/chariot.dart';
import '../models/stock_ledger.dart';
import '../models/user.dart';
import 'api_service.dart';

/// Handles all non-auth API calls: orders, operations, products, reports,
/// emplacements, chariots, users, inventory, and sync.
class DataApiService {
  final ApiService _api;

  DataApiService(this._api);

  // ── Orders ──────────────────────────────────────────────────────

  Future<List<Order>> getOrders({String? type, String? status}) async {
    final q = <String, String>{};
    if (type != null) q['order_type'] = type;
    if (status != null) q['status'] = status;
    final data = await _api.get('/api/orders/', query: q.isNotEmpty ? q : null);
    return (data as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<List<Order>> getPendingOrders() async {
    final data = await _api.get('/api/orders/pending');
    return (data as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<Order> getOrder(String id) async {
    final data = await _api.get('/api/orders/$id');
    return Order.fromJson(data);
  }

  Future<Order> createOrder({
    required String productId,
    required int quantity,
    String type = 'command',
  }) async {
    final data = await _api.post(
      '/api/orders/',
      body: {'type': type, 'product_id': productId, 'quantity': quantity},
    );
    return Order.fromJson(data);
  }

  Future<Order> validateOrder(String orderId) async {
    final data = await _api.put('/api/orders/$orderId/validate');
    return Order.fromJson(data);
  }

  Future<void> deleteOrder(String orderId) async {
    await _api.delete('/api/orders/$orderId');
  }

  Future<List<Order>> generatePreparationOrders() async {
    final data = await _api.post('/api/orders/generate-preparation');
    return (data as List).map((e) => Order.fromJson(e)).toList();
  }

  // ── Operations ─────────────────────────────────────────────────

  Future<List<Operation>> getOperations({
    String? type,
    String? status,
    String? employeeId,
  }) async {
    final q = <String, String>{};
    if (type != null) q['operation_type'] = type;
    if (status != null) q['status'] = status;
    if (employeeId != null) q['employee_id'] = employeeId;
    final data = await _api.get(
      '/api/operations/',
      query: q.isNotEmpty ? q : null,
    );
    return (data as List).map((e) => Operation.fromJson(e)).toList();
  }

  Future<List<Operation>> getPendingOperations() async {
    final data = await _api.get('/api/operations/pending');
    return (data as List).map((e) => Operation.fromJson(e)).toList();
  }

  Future<List<Operation>> getMyOperations(String employeeId) async {
    final data = await _api.get(
      '/api/operations/employee/$employeeId/operations',
    );
    return (data as List).map((e) => Operation.fromJson(e)).toList();
  }

  Future<Operation> getOperation(String id) async {
    final data = await _api.get('/api/operations/$id');
    return Operation.fromJson(data);
  }

  Future<Operation> approveOperation(
    String operationId, {
    Map<String, dynamic>? override,
  }) async {
    final data = await _api.put(
      '/api/operations/$operationId/approve',
      body: override,
    );
    return Operation.fromJson(data);
  }

  Future<Operation> validateOperation(String operationId) async {
    final data = await _api.put('/api/operations/$operationId/validate');
    return Operation.fromJson(data);
  }

  Future<void> deleteOperation(String operationId) async {
    await _api.delete('/api/operations/$operationId');
  }

  // ── Products ───────────────────────────────────────────────────

  Future<List<Product>> getProducts({String? category}) async {
    final q = <String, String>{};
    if (category != null) q['category'] = category;
    final data = await _api.get(
      '/api/products/',
      query: q.isNotEmpty ? q : null,
    );
    return (data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> getProduct(String id) async {
    final data = await _api.get('/api/products/$id');
    return Product.fromJson(data);
  }

  Future<Product> createProduct(Map<String, dynamic> productData) async {
    final data = await _api.post('/api/products/', body: productData);
    return Product.fromJson(data);
  }

  // ── Reports ────────────────────────────────────────────────────

  Future<List<Report>> getReports({String? operationId}) async {
    final q = <String, String>{};
    if (operationId != null) q['operation_id'] = operationId;
    final data = await _api.get(
      '/api/reports/',
      query: q.isNotEmpty ? q : null,
    );
    return (data as List).map((e) => Report.fromJson(e)).toList();
  }

  Future<Report> createReport({
    required String operationId,
    bool physicalDamage = false,
    int missingQuantity = 0,
    int extraQuality = 0,
  }) async {
    final data = await _api.post(
      '/api/reports/',
      body: {
        'operation_id': operationId,
        'physical_damage': physicalDamage,
        'missing_quantity': missingQuantity,
        'extra_quality': extraQuality,
      },
    );
    return Report.fromJson(data);
  }

  Future<Map<String, dynamic>> getReportStatistics() async {
    final data = await _api.get('/api/reports/statistics/summary');
    return Map<String, dynamic>.from(data);
  }

  // ── Inventory ──────────────────────────────────────────────────

  Future<List<Emplacement>> getStock({String? productId, int? floor}) async {
    final q = <String, String>{};
    if (productId != null) q['product_id'] = productId;
    if (floor != null) q['floor'] = floor.toString();
    final data = await _api.get(
      '/api/inventory/stock',
      query: q.isNotEmpty ? q : null,
    );
    return (data as List).map((e) => Emplacement.fromJson(e)).toList();
  }

  Future<List<Emplacement>> getProductStock(String productId) async {
    final data = await _api.get('/api/inventory/stock/product/$productId');
    return (data as List).map((e) => Emplacement.fromJson(e)).toList();
  }

  Future<List<StockLedger>> getLedger({String? productId, int? limit}) async {
    final q = <String, String>{};
    if (productId != null) q['product_id'] = productId;
    if (limit != null) q['limit'] = limit.toString();
    final data = await _api.get(
      '/api/inventory/ledger',
      query: q.isNotEmpty ? q : null,
    );
    return (data as List).map((e) => StockLedger.fromJson(e)).toList();
  }

  Future<List<StockLedger>> getLedgerByLocation({
    required int x,
    required int y,
    required int z,
    int floor = 0,
  }) async {
    final q = {
      'x': x.toString(),
      'y': y.toString(),
      'z': z.toString(),
      'floor': floor.toString(),
    };
    final data = await _api.get('/api/inventory/ledger/location', query: q);
    return (data as List).map((e) => StockLedger.fromJson(e)).toList();
  }

  Future<StockLedger> adjustStock({
    required int x,
    required int y,
    required int z,
    int floor = 0,
    required String productId,
    required int quantity,
  }) async {
    final data = await _api.post(
      '/api/inventory/adjust',
      body: {
        'x': x,
        'y': y,
        'z': z,
        'floor': floor,
        'product_id': productId,
        'quantity': quantity,
      },
    );
    return StockLedger.fromJson(data);
  }

  Future<List<Emplacement>> getLowStock({int? threshold}) async {
    final q = <String, String>{};
    if (threshold != null) q['threshold'] = threshold.toString();
    final data = await _api.get(
      '/api/inventory/low-stock',
      query: q.isNotEmpty ? q : null,
    );
    return (data as List).map((e) => Emplacement.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getStockSummary() async {
    final data = await _api.get('/api/inventory/stock-summary');
    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ── Emplacements ──────────────────────────────────────────────

  Future<List<Emplacement>> getEmplacements({
    int? floor,
    bool? isSlot,
    bool? isOccupied,
  }) async {
    final q = <String, String>{};
    if (floor != null) q['floor'] = floor.toString();
    if (isSlot != null) q['is_slot'] = isSlot.toString();
    if (isOccupied != null) q['is_occupied'] = isOccupied.toString();
    final data = await _api.get(
      '/api/emplacements/locations',
      query: q.isNotEmpty ? q : null,
    );
    return (data as List).map((e) => Emplacement.fromJson(e)).toList();
  }

  Future<Emplacement> getEmplacement(String id) async {
    final data = await _api.get('/api/emplacements/locations/$id');
    return Emplacement.fromJson(data);
  }

  Future<List<Emplacement>> getAvailableSlots({int? floor}) async {
    final q = <String, String>{};
    if (floor != null) q['floor'] = floor.toString();
    final data = await _api.get(
      '/api/emplacements/available-slots',
      query: q.isNotEmpty ? q : null,
    );
    return (data as List).map((e) => Emplacement.fromJson(e)).toList();
  }

  Future<List<Emplacement>> getOccupiedSlots({int? floor}) async {
    final q = <String, String>{};
    if (floor != null) q['floor'] = floor.toString();
    final data = await _api.get(
      '/api/emplacements/occupied-slots',
      query: q.isNotEmpty ? q : null,
    );
    return (data as List).map((e) => Emplacement.fromJson(e)).toList();
  }

  Future<List<Emplacement>> getExpeditionZones() async {
    final data = await _api.get('/api/emplacements/expedition-zones');
    return (data as List).map((e) => Emplacement.fromJson(e)).toList();
  }

  Future<List<Emplacement>> getProductLocations(String productId) async {
    final data = await _api.get(
      '/api/emplacements/product/$productId/locations',
    );
    return (data as List).map((e) => Emplacement.fromJson(e)).toList();
  }

  Future<Emplacement> createEmplacement(Map<String, dynamic> body) async {
    final data = await _api.post('/api/emplacements/locations', body: body);
    return Emplacement.fromJson(data);
  }

  Future<Emplacement> updateEmplacement(
    String id,
    Map<String, dynamic> body,
  ) async {
    final data = await _api.put('/api/emplacements/locations/$id', body: body);
    return Emplacement.fromJson(data);
  }

  Future<void> deleteEmplacement(String id) async {
    await _api.delete('/api/emplacements/locations/$id');
  }

  // ── Chariots ──────────────────────────────────────────────────

  Future<List<Chariot>> getChariots({bool? isActive}) async {
    final q = <String, String>{};
    if (isActive != null) q['is_active'] = isActive.toString();
    final data = await _api.get(
      '/api/chariots/',
      query: q.isNotEmpty ? q : null,
    );
    return (data as List).map((e) => Chariot.fromJson(e)).toList();
  }

  Future<Chariot> getChariot(String id) async {
    final data = await _api.get('/api/chariots/$id');
    return Chariot.fromJson(data);
  }

  Future<Chariot> createChariot(Map<String, dynamic> body) async {
    final data = await _api.post('/api/chariots/', body: body);
    return Chariot.fromJson(data);
  }

  Future<Chariot> updateChariot(String id, Map<String, dynamic> body) async {
    final data = await _api.put('/api/chariots/$id', body: body);
    return Chariot.fromJson(data);
  }

  Future<void> deleteChariot(String id) async {
    await _api.delete('/api/chariots/$id');
  }

  // ── Users (Admin) ─────────────────────────────────────────────

  Future<List<User>> getUsers({String? role}) async {
    final q = <String, String>{};
    if (role != null) q['role'] = role;
    final data = await _api.get('/api/users/', query: q.isNotEmpty ? q : null);
    return (data as List).map((e) => User.fromJson(e)).toList();
  }

  Future<List<User>> getEmployees() async {
    final data = await _api.get('/api/users/employees');
    return (data as List).map((e) => User.fromJson(e)).toList();
  }

  Future<User> getUser(String id) async {
    final data = await _api.get('/api/users/$id');
    return User.fromJson(data);
  }

  Future<User> updateUser(String id, Map<String, dynamic> body) async {
    final data = await _api.put('/api/users/$id', body: body);
    return User.fromJson(data);
  }

  Future<void> deleteUser(String id) async {
    await _api.delete('/api/users/$id');
  }

  // ── Operations (Create by Type) ───────────────────────────────

  Future<Operation> createReceipt(Map<String, dynamic> body) async {
    final data = await _api.post('/api/operations/receipt', body: body);
    return Operation.fromJson(data);
  }

  Future<Operation> createTransfer(Map<String, dynamic> body) async {
    final data = await _api.post('/api/operations/transfer', body: body);
    return Operation.fromJson(data);
  }

  Future<Operation> createPicking(Map<String, dynamic> body) async {
    final data = await _api.post('/api/operations/picking', body: body);
    return Operation.fromJson(data);
  }

  Future<Operation> createDelivery(Map<String, dynamic> body) async {
    final data = await _api.post('/api/operations/delivery', body: body);
    return Operation.fromJson(data);
  }

  Future<Map<String, dynamic>> getOperationDestinationInfo(
    String operationId,
  ) async {
    final data = await _api.get(
      '/api/operations/$operationId/destination-info',
    );
    return Map<String, dynamic>.from(data);
  }

  // ── Order Logs ────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getOrderLogs(String orderId) async {
    final data = await _api.get('/api/orders/$orderId/logs');
    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllOrderLogs() async {
    final data = await _api.get('/api/order-logs/');
    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ── Operation Logs ────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getOperationLogs(
    String operationId,
  ) async {
    final data = await _api.get('/api/operations/$operationId/logs');
    return (data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ── Sync ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> syncOperations(
    List<Map<String, dynamic>> operations,
  ) async {
    final data = await _api.post(
      '/api/sync/operations',
      body: {'operations': operations},
    );
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> syncStockMovements(
    List<Map<String, dynamic>> movements,
  ) async {
    final data = await _api.post(
      '/api/sync/stock-movements',
      body: {'movements': movements},
    );
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> fullSync({
    List<Map<String, dynamic>>? operations,
    List<Map<String, dynamic>>? movements,
    String? lastSyncTimestamp,
  }) async {
    final body = <String, dynamic>{};
    if (operations != null) body['operations'] = operations;
    if (movements != null) body['stock_movements'] = movements;
    if (lastSyncTimestamp != null) {
      body['last_sync_timestamp'] = lastSyncTimestamp;
    }
    final data = await _api.post('/api/sync/full-sync', body: body);
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    final data = await _api.get('/api/sync/status');
    return Map<String, dynamic>.from(data);
  }

  // ── AI Agent ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAIHealth() async {
    final data = await _api.get('/api/ai/health');
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> aiHandleReceipt({
    required String productId,
    required int quantityPalettes,
    double? poids,
    double? volume,
    bool? fragile,
    int? frequence,
  }) async {
    final body = <String, dynamic>{
      'product_id': productId,
      'quantity_palettes': quantityPalettes,
    };
    if (poids != null) body['poids'] = poids;
    if (volume != null) body['volume'] = volume;
    if (fragile != null) body['fragile'] = fragile;
    if (frequence != null) body['frequence'] = frequence;
    final data = await _api.post('/api/ai/receipt', body: body);
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> aiRunForecast({String? targetDate}) async {
    final body = <String, dynamic>{};
    if (targetDate != null) body['target_date'] = targetDate;
    final data = await _api.post('/api/ai/forecast', body: body);
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> aiOverrideDecision({
    required String decisionId,
    required String overriddenBy,
    required String overrideReason,
    required Map<String, dynamic> newDecision,
  }) async {
    final data = await _api.post(
      '/api/ai/override',
      body: {
        'decision_id': decisionId,
        'overridden_by': overriddenBy,
        'override_reason': overrideReason,
        'new_decision': newDecision,
      },
    );
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> getAIDecisions({int limit = 10}) async {
    final data = await _api.get(
      '/api/ai/decisions',
      query: {'limit': limit.toString()},
    );
    return Map<String, dynamic>.from(data);
  }
}
