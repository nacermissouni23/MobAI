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

  const Sku({
    required this.id,
    required this.name,
    required this.skuCode,
    this.quantity = 0,
    required this.stockStatus,
    this.locationLabel,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, skuCode, quantity, stockStatus];

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
