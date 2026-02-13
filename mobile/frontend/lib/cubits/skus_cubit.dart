import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/data/mock_data.dart';

// States
abstract class SkusState extends Equatable {
  const SkusState();
  @override
  List<Object?> get props => [];
}

class SkusInitial extends SkusState {}

class SkusLoaded extends SkusState {
  final List<Sku> skus;
  const SkusLoaded(this.skus);
  @override
  List<Object?> get props => [skus];
}

// Cubit
class SkusCubit extends Cubit<SkusState> {
  SkusCubit() : super(SkusInitial());

  void loadSkus() {
    emit(const SkusLoaded(MockData.skus));
  }

  void addSku({
    required String name,
    required String skuCode,
    required int quantity,
  }) {
    if (state is SkusLoaded) {
      final current = (state as SkusLoaded).skus;
      final newSku = Sku(
        id: 'SKU${current.length + 1}',
        name: name,
        skuCode: skuCode,
        quantity: quantity,
        stockStatus: quantity > 10
            ? SkuStockStatus.inStock
            : quantity > 0
            ? SkuStockStatus.lowStock
            : SkuStockStatus.outOfStock,
      );
      emit(SkusLoaded([...current, newSku]));
    }
  }

  void updateSku(Sku updatedSku) {
    if (state is SkusLoaded) {
      final current = (state as SkusLoaded).skus;
      final updated = current.map((s) {
        if (s.id == updatedSku.id) return updatedSku;
        return s;
      }).toList();
      emit(SkusLoaded(updated));
    }
  }

  void deleteSku(String skuId) {
    if (state is SkusLoaded) {
      final current = (state as SkusLoaded).skus;
      emit(SkusLoaded(current.where((s) => s.id != skuId).toList()));
    }
  }
}
