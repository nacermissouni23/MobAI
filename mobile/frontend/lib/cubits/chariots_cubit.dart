import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/data/mock_data.dart';

// States
abstract class ChariotsState extends Equatable {
  const ChariotsState();
  @override
  List<Object?> get props => [];
}

class ChariotsInitial extends ChariotsState {}

class ChariotsLoaded extends ChariotsState {
  final List<Chariot> chariots;
  const ChariotsLoaded(this.chariots);
  @override
  List<Object?> get props => [chariots];
}

// Cubit
class ChariotsCubit extends Cubit<ChariotsState> {
  ChariotsCubit() : super(ChariotsInitial());

  void loadChariots() {
    emit(const ChariotsLoaded(MockData.chariots));
  }

  void addChariot(String chariotId) {
    if (state is ChariotsLoaded) {
      final current = (state as ChariotsLoaded).chariots;
      final newChariot = Chariot(id: chariotId, isActive: true);
      emit(ChariotsLoaded([...current, newChariot]));
    }
  }

  void updateChariot(Chariot updatedChariot) {
    if (state is ChariotsLoaded) {
      final current = (state as ChariotsLoaded).chariots;
      final updated = current.map((c) {
        if (c.id == updatedChariot.id) return updatedChariot;
        return c;
      }).toList();
      emit(ChariotsLoaded(updated));
    }
  }

  void deleteChariot(String chariotId) {
    if (state is ChariotsLoaded) {
      final current = (state as ChariotsLoaded).chariots;
      emit(ChariotsLoaded(current.where((c) => c.id != chariotId).toList()));
    }
  }
}
