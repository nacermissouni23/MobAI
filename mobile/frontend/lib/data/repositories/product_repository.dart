import 'package:frontend/data/models/product.dart';
import 'base_repository.dart';

class ProductRepository extends BaseRepository<Product> {
  ProductRepository() : super('products');

  @override
  Product fromMap(Map<String, dynamic> map) => Product.fromMap(map);

  @override
  Map<String, dynamic> toMap(Product entity) => entity.toMap();

  // ── Domain queries ────────────────────────────────────────

  /// Find product by SKU code.
  Future<Product?> findBySku(String sku) => findOne('sku', sku);

  /// Get active products only.
  Future<List<Product>> getActiveProducts() {
    return query(where: 'actif = 1', orderBy: 'nom_produit ASC');
  }

  /// Get all products sorted by name.
  Future<List<Product>> getAllSorted() {
    return getAll(orderBy: 'nom_produit ASC');
  }

  /// Get products by category.
  Future<List<Product>> getByCategory(String category) {
    return query(where: 'categorie = ?', whereArgs: [category]);
  }

  /// Search products by name or SKU.
  Future<List<Product>> search(String term) {
    final like = '%$term%';
    return query(
      where: '(nom_produit LIKE ? OR sku LIKE ?)',
      whereArgs: [like, like],
      orderBy: 'nom_produit ASC',
    );
  }

  /// Get distinct categories.
  Future<List<String>> getCategories() async {
    final db = await database;
    final results = await db.rawQuery(
      'SELECT DISTINCT categorie FROM products WHERE categorie IS NOT NULL AND is_deleted = 0 ORDER BY categorie ASC',
    );
    return results.map((r) => r['categorie'] as String).toList();
  }

  /// Toggle product active status.
  Future<void> toggleActive(String productId) async {
    final product = await getById(productId);
    if (product != null) {
      await update(productId, {'actif': product.isActive ? 0 : 1});
    }
  }
}
