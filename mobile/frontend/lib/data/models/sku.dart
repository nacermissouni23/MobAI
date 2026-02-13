import 'package:equatable/equatable.dart';

enum SkuStockStatus { inStock, lowStock, outOfStock }

class Sku extends Equatable {
  final String id;
  final String name;
  final String skuCode;
  final int quantity;
  final SkuStockStatus stockStatus;
  final String? locationLabel;
  final String? imageUrl;
  final double weight;
  final String? category;

  const Sku({
    required this.id,
    required this.name,
    required this.skuCode,
    this.quantity = 0,
    required this.stockStatus,
    this.locationLabel,
    this.imageUrl,
    this.weight = 0.0,
    this.category,
  });

  @override
  List<Object?> get props => [id, name, skuCode, quantity, stockStatus];

  Sku copyWith({
    String? id,
    String? name,
    String? skuCode,
    int? quantity,
    SkuStockStatus? stockStatus,
    String? locationLabel,
    String? imageUrl,
    double? weight,
    String? category,
  }) {
    return Sku(
      id: id ?? this.id,
      name: name ?? this.name,
      skuCode: skuCode ?? this.skuCode,
      quantity: quantity ?? this.quantity,
      stockStatus: stockStatus ?? this.stockStatus,
      locationLabel: locationLabel ?? this.locationLabel,
      imageUrl: imageUrl ?? this.imageUrl,
      weight: weight ?? this.weight,
      category: category ?? this.category,
    );
  }

  String get stockStatusLabel {
    switch (stockStatus) {
      case SkuStockStatus.inStock:
        return 'IN STOCK';
      case SkuStockStatus.lowStock:
        return 'LOW STOCK';
      case SkuStockStatus.outOfStock:
        return 'OUT OF STOCK';
    }
  }
}
