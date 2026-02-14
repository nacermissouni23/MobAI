import 'package:frontend/data/models/stock_ledger.dart';
import 'package:frontend/data/enums.dart';
import 'base_repository.dart';

class StockLedgerRepository extends BaseRepository<StockLedger> {
  StockLedgerRepository() : super('stock_ledger');

  @override
  StockLedger fromMap(Map<String, dynamic> map) => StockLedger.fromMap(map);

  @override
  Map<String, dynamic> toMap(StockLedger entity) => entity.toMap();

  // ── Domain queries ────────────────────────────────────────

  /// Get ledger entries for a specific product.
  Future<List<StockLedger>> getByProduct(String productId) {
    return query(
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'recorded_at DESC',
    );
  }

  /// Get ledger entries for a specific location.
  Future<List<StockLedger>> getByLocation(int x, int y, int z, int floor) {
    return query(
      where: 'x = ? AND y = ? AND z = ? AND floor = ?',
      whereArgs: [x, y, z, floor],
      orderBy: 'recorded_at DESC',
    );
  }

  /// Get entries linked to an operation.
  Future<List<StockLedger>> getByOperation(String operationId) {
    return query(
      where: 'operation_id = ?',
      whereArgs: [operationId],
      orderBy: 'recorded_at ASC',
    );
  }

  /// Get entries by operation type.
  Future<List<StockLedger>> getByOperationType(OperationType type) {
    return query(
      where: 'operation_type = ?',
      whereArgs: [type.value],
      orderBy: 'recorded_at DESC',
    );
  }

  /// Get recent movements.
  Future<List<StockLedger>> getRecent({int limit = 50}) {
    return getAll(orderBy: 'recorded_at DESC', limit: limit);
  }

  /// Get net stock for a product at a location.
  Future<int> getNetStock(String productId, int x, int y, int z, int floor) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(quantity), 0) as net FROM stock_ledger WHERE product_id = ? AND x = ? AND y = ? AND z = ? AND floor = ? AND is_deleted = 0',
      [productId, x, y, z, floor],
    );
    return (result.first['net'] as int?) ?? 0;
  }

  /// Get total stock for a product across all locations.
  Future<int> getTotalStock(String productId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(quantity), 0) as total FROM stock_ledger WHERE product_id = ? AND is_deleted = 0',
      [productId],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  /// Get stock summary by floor.
  Future<Map<int, int>> getStockByFloor(String productId) async {
    final db = await database;
    final results = await db.rawQuery(
      'SELECT floor, COALESCE(SUM(quantity), 0) as total FROM stock_ledger WHERE product_id = ? AND is_deleted = 0 GROUP BY floor',
      [productId],
    );
    final map = <int, int>{};
    for (final row in results) {
      map[row['floor'] as int] = row['total'] as int;
    }
    return map;
  }
}
