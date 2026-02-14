import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/product.dart';
import 'package:frontend/data/repositories/product_repository.dart';

// ── States ──────────────────────────────────────────────────

abstract class ProductsState extends Equatable {
  const ProductsState();
  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  const ProductsLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

class ProductsError extends ProductsState {
  final String message;
  const ProductsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────

class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository _productRepo;

  ProductsCubit({required ProductRepository productRepository})
      : _productRepo = productRepository,
        super(ProductsInitial());

  Future<void> loadProducts() async {
    emit(ProductsLoading());
    try {
      final products = await _productRepo.getAllSorted();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError('Failed to load products: $e'));
    }
  }

  Future<void> addProduct({
    required String name,
    required String sku,
    String unitOfMeasure = 'pcs',
    String? category,
    bool isActive = true,
    int? unitsPerBundle,
    int? unitsPerPallet,
    double? volumePerUnit,
    double? weight,
    bool isStackable = false,
  }) async {
    try {
      final now = DateTime.now();
      final product = Product(
        id: _productRepo.generateId(),
        sku: sku,
        name: name,
        unitOfMeasure: unitOfMeasure,
        category: category,
        isActive: isActive,
        unitsPerBundle: unitsPerBundle,
        unitsPerPallet: unitsPerPallet,
        volumePerUnit: volumePerUnit,
        weight: weight,
        isStackable: isStackable,
        createdAt: now,
        updatedAt: now,
      );
      await _productRepo.insert(product);
      await loadProducts();
    } catch (e) {
      emit(ProductsError('Failed to add product: $e'));
    }
  }

  Future<void> updateProduct(Product updatedProduct) async {
    try {
      await _productRepo.updateEntity(updatedProduct);
      await loadProducts();
    } catch (e) {
      emit(ProductsError('Failed to update product: $e'));
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _productRepo.softDelete(productId);
      await loadProducts();
    } catch (e) {
      emit(ProductsError('Failed to delete product: $e'));
    }
  }
}
