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
}
