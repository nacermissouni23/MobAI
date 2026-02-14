import 'package:frontend/data/models/emplacement.dart';
import 'base_repository.dart';

class EmplacementRepository extends BaseRepository<Emplacement> {
  EmplacementRepository() : super('emplacements');

  @override
  Emplacement fromMap(Map<String, dynamic> map) => Emplacement.fromMap(map);

  @override
  Map<String, dynamic> toMap(Emplacement entity) => entity.toMap();

  // ── Domain queries ────────────────────────────────────────

  /// Get all emplacements for a specific floor.
  Future<List<Emplacement>> getByFloor(int floor) {
    return query(where: 'floor = ?', whereArgs: [floor], orderBy: 'y ASC, x ASC');
  }

  /// Get a single emplacement by coordinates.
  Future<Emplacement?> getByCoords(int x, int y, int z, int floor) async {
    final results = await query(
      where: 'x = ? AND y = ? AND z = ? AND floor = ?',
      whereArgs: [x, y, z, floor],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  /// Get all storage slots (non-obstacle, non-road).
  Future<List<Emplacement>> getSlots({int? floor}) {
    if (floor != null) {
      return query(
        where: 'is_slot = 1 AND floor = ?',
        whereArgs: [floor],
      );
    }
    return query(where: 'is_slot = 1');
  }

  /// Get occupied slots.
  Future<List<Emplacement>> getOccupiedSlots({int? floor}) {
    if (floor != null) {
      return query(
        where: 'is_occupied = 1 AND floor = ?',
        whereArgs: [floor],
      );
    }
    return query(where: 'is_occupied = 1');
  }

  /// Get all emplacements containing a specific product.
  Future<List<Emplacement>> getByProduct(String productId) {
    return query(
      where: 'product_id = ? AND quantity > 0',
      whereArgs: [productId],
    );
  }

  /// Get available (empty) slots on a floor.
  Future<List<Emplacement>> getAvailableSlots(int floor) {
    return query(
      where: 'is_slot = 1 AND is_occupied = 0 AND floor = ?',
      whereArgs: [floor],
    );
  }

  /// Get all elevator cells.
  Future<List<Emplacement>> getElevators() {
    return query(where: 'is_elevator = 1');
  }

  /// Get expedition zones.
  Future<List<Emplacement>> getExpeditionZones() {
    return query(where: 'is_expedition = 1');
  }

  /// Get distinct floor numbers.
  Future<List<int>> getFloorNumbers() async {
    final db = await database;
    final results = await db.rawQuery(
      'SELECT DISTINCT floor FROM emplacements WHERE is_deleted = 0 ORDER BY floor ASC',
    );
    return results.map((r) => r['floor'] as int).toList();
  }

  /// Get grid dimensions for a floor.
  Future<Map<String, int>> getFloorDimensions(int floor) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(x) as max_x, MAX(y) as max_y FROM emplacements WHERE floor = ? AND is_deleted = 0',
      [floor],
    );
    if (result.isEmpty) return {'width': 0, 'height': 0};
    return {
      'width': ((result.first['max_x'] as int?) ?? 0) + 1,
      'height': ((result.first['max_y'] as int?) ?? 0) + 1,
    };
  }

  /// Update stock at a specific emplacement.
  Future<void> updateStock(String emplacementId, String? productId, int quantity) {
    return update(emplacementId, {
      'product_id': productId,
      'quantity': quantity,
      'is_occupied': (productId != null && quantity > 0) ? 1 : 0,
    });
  }
}
