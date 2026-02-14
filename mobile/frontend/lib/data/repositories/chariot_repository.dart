import 'package:frontend/data/models/chariot.dart';
import 'base_repository.dart';

class ChariotRepository extends BaseRepository<Chariot> {
  ChariotRepository() : super('chariots');

  @override
  Chariot fromMap(Map<String, dynamic> map) => Chariot.fromMap(map);

  @override
  Map<String, dynamic> toMap(Chariot entity) => entity.toMap();

  // ── Domain queries ────────────────────────────────────────

  /// Find chariot by code.
  Future<Chariot?> findByCode(String code) => findOne('code', code);

  /// Get all active chariots.
  Future<List<Chariot>> getActive() {
    return query(where: 'is_active = 1', orderBy: 'code ASC');
  }

  /// Get all chariots sorted by code.
  Future<List<Chariot>> getAllSorted() {
    return getAll(orderBy: 'code ASC');
  }

  /// Get available chariots (active + no assigned operation).
  Future<List<Chariot>> getAvailable() {
    return query(
      where: 'is_active = 1 AND assigned_to_operation IS NULL',
      orderBy: 'code ASC',
    );
  }

  /// Assign chariot to an operation.
  Future<void> assignToOperation(String chariotId, String operationId) {
    return update(chariotId, {'assigned_to_operation': operationId}).then((_) {});
  }

  /// Release chariot from operation.
  Future<void> release(String chariotId) {
    return update(chariotId, {'assigned_to_operation': null}).then((_) {});
  }

  /// Toggle chariot active status.
  Future<void> toggleActive(String chariotId) async {
    final chariot = await getById(chariotId);
    if (chariot != null) {
      await update(chariotId, {'is_active': chariot.isActive ? 0 : 1});
    }
  }

  /// Update chariot position.
  Future<void> updatePosition(String chariotId, int x, int y, int z, int floor) {
    return update(chariotId, {
      'current_x': x,
      'current_y': y,
      'current_z': z,
      'current_floor': floor,
    }).then((_) {});
  }
}
