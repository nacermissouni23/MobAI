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
      final newChariot = Chariot(
        id: chariotId,
        name: 'Chariot #${chariotId.replaceAll('CH-', '')}',
        status: ChariotStatus.available,
        location: 'Unassigned',
      );
      emit(ChariotsLoaded([...current, newChariot]));
    }
  }
}
