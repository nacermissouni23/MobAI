import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/data/mock_data.dart';

// States
abstract class SuggestionsState extends Equatable {
  const SuggestionsState();
  @override
  List<Object?> get props => [];
}

class SuggestionsInitial extends SuggestionsState {}

class SuggestionsLoaded extends SuggestionsState {
  final List<Suggestion> suggestions;
  const SuggestionsLoaded(this.suggestions);
  @override
  List<Object?> get props => [suggestions];
}

// Cubit
class SuggestionsCubit extends Cubit<SuggestionsState> {
  SuggestionsCubit() : super(SuggestionsInitial());

  void loadSuggestions() {
    emit(const SuggestionsLoaded(MockData.suggestions));
  }

  void validateSuggestion(String id) {
    if (state is SuggestionsLoaded) {
      final current = (state as SuggestionsLoaded).suggestions;
      emit(SuggestionsLoaded(current.where((s) => s.id != id).toList()));
    }
  }

  void overrideSuggestion({
    required String id,
    required String justification,
    String? newFromLocation,
    String? newToLocation,
  }) {
    if (state is SuggestionsLoaded) {
      final current = (state as SuggestionsLoaded).suggestions;
      final updated = current.map((s) {
        if (s.id == id) {
          return s.copyWith(
            isOverridden: true,
            overrideJustification: justification,
            overriddenFromLocation: newFromLocation,
            overriddenToLocation: newToLocation,
          );
        }
        return s;
      }).toList();
      emit(SuggestionsLoaded(updated));
    }
  }

  void refuseSuggestion(String id) {
    if (state is SuggestionsLoaded) {
      final current = (state as SuggestionsLoaded).suggestions;
      emit(SuggestionsLoaded(current.where((s) => s.id != id).toList()));
    }
  }
}
