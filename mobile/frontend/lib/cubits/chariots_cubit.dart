import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/chariot.dart';
import 'package:frontend/data/repositories/chariot_repository.dart';

// ── States ──────────────────────────────────────────────────

abstract class ChariotsState extends Equatable {
  const ChariotsState();
  @override
  List<Object?> get props => [];
}

class ChariotsInitial extends ChariotsState {}

class ChariotsLoading extends ChariotsState {}

class ChariotsLoaded extends ChariotsState {
  final List<Chariot> chariots;
  const ChariotsLoaded(this.chariots);
  @override
  List<Object?> get props => [chariots];
}

class ChariotsError extends ChariotsState {
  final String message;
  const ChariotsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────

class ChariotsCubit extends Cubit<ChariotsState> {
  final ChariotRepository _chariotRepo;

  ChariotsCubit({required ChariotRepository chariotRepository})
      : _chariotRepo = chariotRepository,
        super(ChariotsInitial());

  Future<void> loadChariots() async {
    emit(ChariotsLoading());
    try {
      final chariots = await _chariotRepo.getAllSorted();
      emit(ChariotsLoaded(chariots));
    } catch (e) {
      emit(ChariotsError('Failed to load chariots: $e'));
    }
  }

  Future<void> addChariot(String code, {bool isActive = true}) async {
    try {
      final now = DateTime.now();
      final chariot = Chariot(
        id: _chariotRepo.generateId(),
        code: code,
        isActive: isActive,
        createdAt: now,
        updatedAt: now,
      );
      await _chariotRepo.insert(chariot);
      await loadChariots();
    } catch (e) {
      emit(ChariotsError('Failed to add chariot: $e'));
    }
  }

  Future<void> updateChariot(Chariot updatedChariot) async {
    try {
      await _chariotRepo.updateEntity(updatedChariot);
      await loadChariots();
    } catch (e) {
      emit(ChariotsError('Failed to update chariot: $e'));
    }
  }

  Future<void> deleteChariot(String chariotId) async {
    try {
      await _chariotRepo.softDelete(chariotId);
      await loadChariots();
    } catch (e) {
      emit(ChariotsError('Failed to delete chariot: $e'));
    }
  }
}
