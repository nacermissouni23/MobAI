import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../models/operation.dart';
import '../models/product.dart';
import '../models/report.dart';
import '../models/emplacement.dart';
import '../models/chariot.dart';
import '../models/stock_ledger.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/data_api_service.dart';

/// Manages application data state: orders, operations, products, reports,
/// emplacements, chariots, users, inventory.
class DataProvider extends ChangeNotifier {
  late final DataApiService _dataApi;

  DataProvider(ApiService api) {
    _dataApi = DataApiService(api);
  }

  // ── State ──────────────────────────────────────────────────────

  List<Order> _orders = [];
  List<Operation> _operations = [];
  List<Product> _products = [];
  List<Report> _reports = [];
  List<Emplacement> _emplacements = [];
  List<Chariot> _chariots = [];
  List<User> _users = [];
  List<StockLedger> _ledger = [];
  List<Map<String, dynamic>> _stockSummary = [];
  bool _loading = false;
  String? _error;

  List<Order> get orders => _orders;
  List<Operation> get operations => _operations;
  List<Product> get products => _products;
  List<Report> get reports => _reports;
  List<Emplacement> get emplacements => _emplacements;
  List<Chariot> get chariots => _chariots;
  List<User> get users => _users;
  List<StockLedger> get ledger => _ledger;
  List<Map<String, dynamic>> get stockSummary => _stockSummary;
  bool get loading => _loading;
  String? get error => _error;

  List<Order> get pendingOrders => _orders.where((o) => o.isPending).toList();
  List<Operation> get pendingOperations =>
      _operations.where((o) => o.isPending).toList();
  List<Operation> get inProgressOperations =>
      _operations.where((o) => o.isInProgress).toList();
  List<Chariot> get availableChariots =>
      _chariots.where((c) => c.isAvailable).toList();
  List<Emplacement> get occupiedSlots =>
      _emplacements.where((e) => e.isSlot && e.isOccupied).toList();
  List<Emplacement> get availableSlots =>
      _emplacements.where((e) => e.isSlot && !e.isOccupied).toList();

  // ── Orders ─────────────────────────────────────────────────────

  Future<void> loadOrders({String? type, String? status}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _dataApi.getOrders(type: type, status: status);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> createOrder({
    required String productId,
    required int quantity,
    String type = 'command',
  }) async {
    try {
      final order = await _dataApi.createOrder(
        productId: productId,
        quantity: quantity,
        type: type,
      );
      _orders.insert(0, order);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> validateOrder(String orderId) async {
    try {
      final updated = await _dataApi.validateOrder(orderId);
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx >= 0) _orders[idx] = updated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    try {
      await _dataApi.deleteOrder(orderId);
      _orders.removeWhere((o) => o.id == orderId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<List<Order>> generatePreparationOrders() async {
    try {
      final newOrders = await _dataApi.generatePreparationOrders();
      _orders.insertAll(0, newOrders);
      notifyListeners();
      return newOrders;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return [];
    }
  }

  // ── Operations ─────────────────────────────────────────────────

  Future<void> loadOperations({
    String? type,
    String? status,
    String? employeeId,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _operations = await _dataApi.getOperations(
        type: type,
        status: status,
        employeeId: employeeId,
      );
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadMyOperations(String employeeId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _operations = await _dataApi.getMyOperations(employeeId);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> approveOperation(
    String operationId, {
    Map<String, dynamic>? override,
  }) async {
    try {
      final updated = await _dataApi.approveOperation(
        operationId,
        override: override,
      );
      final idx = _operations.indexWhere((o) => o.id == operationId);
      if (idx >= 0) _operations[idx] = updated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> validateOperation(String operationId) async {
    try {
      final updated = await _dataApi.validateOperation(operationId);
      final idx = _operations.indexWhere((o) => o.id == operationId);
      if (idx >= 0) _operations[idx] = updated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Products ───────────────────────────────────────────────────

  Future<void> loadProducts() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _dataApi.getProducts();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  // ── Reports ────────────────────────────────────────────────────

  Future<void> loadReports() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _reports = await _dataApi.getReports();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> createReport({
    required String operationId,
    bool physicalDamage = false,
    int missingQuantity = 0,
    int extraQuality = 0,
  }) async {
    try {
      final report = await _dataApi.createReport(
        operationId: operationId,
        physicalDamage: physicalDamage,
        missingQuantity: missingQuantity,
        extraQuality: extraQuality,
      );
      _reports.insert(0, report);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Emplacements ──────────────────────────────────────────────

  Future<void> loadEmplacements({
    int? floor,
    bool? isSlot,
    bool? isOccupied,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _emplacements = await _dataApi.getEmplacements(
        floor: floor,
        isSlot: isSlot,
        isOccupied: isOccupied,
      );
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> createEmplacement(Map<String, dynamic> body) async {
    try {
      final emp = await _dataApi.createEmplacement(body);
      _emplacements.insert(0, emp);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmplacement(String id, Map<String, dynamic> body) async {
    try {
      final emp = await _dataApi.updateEmplacement(id, body);
      final idx = _emplacements.indexWhere((e) => e.id == id);
      if (idx >= 0) _emplacements[idx] = emp;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEmplacement(String id) async {
    try {
      await _dataApi.deleteEmplacement(id);
      _emplacements.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Chariots ──────────────────────────────────────────────────

  Future<void> loadChariots({bool? isActive}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _chariots = await _dataApi.getChariots(isActive: isActive);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> createChariot(Map<String, dynamic> body) async {
    try {
      final c = await _dataApi.createChariot(body);
      _chariots.insert(0, c);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateChariot(String id, Map<String, dynamic> body) async {
    try {
      final c = await _dataApi.updateChariot(id, body);
      final idx = _chariots.indexWhere((ch) => ch.id == id);
      if (idx >= 0) _chariots[idx] = c;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteChariot(String id) async {
    try {
      await _dataApi.deleteChariot(id);
      _chariots.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Users (Admin) ─────────────────────────────────────────────

  Future<void> loadUsers({String? role}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await _dataApi.getUsers(role: role);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> updateUser(String id, Map<String, dynamic> body) async {
    try {
      final u = await _dataApi.updateUser(id, body);
      final idx = _users.indexWhere((user) => user.id == id);
      if (idx >= 0) _users[idx] = u;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      await _dataApi.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Inventory ─────────────────────────────────────────────────

  Future<void> loadStockSummary() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _stockSummary = await _dataApi.getStockSummary();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadLedger({String? productId, int? limit}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _ledger = await _dataApi.getLedger(productId: productId, limit: limit);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  // ── Sync ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> syncAll({
    List<Map<String, dynamic>>? operations,
    List<Map<String, dynamic>>? movements,
    String? lastSyncTimestamp,
  }) async {
    try {
      return await _dataApi.fullSync(
        operations: operations,
        movements: movements,
        lastSyncTimestamp: lastSyncTimestamp,
      );
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return {};
    }
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      return await _dataApi.getSyncStatus();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return {};
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── AI Agent ────────────────────────────────────────────────────

  Map<String, dynamic>? _aiHealth;
  List<Map<String, dynamic>> _aiDecisions = [];

  Map<String, dynamic>? get aiHealth => _aiHealth;
  List<Map<String, dynamic>> get aiDecisions => _aiDecisions;

  Future<void> loadAIHealth() async {
    try {
      _aiHealth = await _dataApi.getAIHealth();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> aiHandleReceipt({
    required String productId,
    required int quantityPalettes,
    double? poids,
    double? volume,
    bool? fragile,
    int? frequence,
  }) async {
    try {
      return await _dataApi.aiHandleReceipt(
        productId: productId,
        quantityPalettes: quantityPalettes,
        poids: poids,
        volume: volume,
        fragile: fragile,
        frequence: frequence,
      );
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return {};
    }
  }

  Future<Map<String, dynamic>> aiRunForecast({String? targetDate}) async {
    try {
      return await _dataApi.aiRunForecast(targetDate: targetDate);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return {};
    }
  }

  Future<Map<String, dynamic>> aiOverrideDecision({
    required String decisionId,
    required String overriddenBy,
    required String overrideReason,
    required Map<String, dynamic> newDecision,
  }) async {
    try {
      return await _dataApi.aiOverrideDecision(
        decisionId: decisionId,
        overriddenBy: overriddenBy,
        overrideReason: overrideReason,
        newDecision: newDecision,
      );
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return {};
    }
  }

  Future<void> loadAIDecisions({int limit = 10}) async {
    try {
      final result = await _dataApi.getAIDecisions(limit: limit);
      final data = result['data'] as Map<String, dynamic>?;
      if (data != null) {
        _aiDecisions = List<Map<String, dynamic>>.from(
          data['decisions'] as List? ?? [],
        );
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
}
