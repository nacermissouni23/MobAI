import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/operation_log.dart';
import 'package:frontend/data/repositories/operation_log_repository.dart';

// ── States ──────────────────────────────────────────────────

abstract class LogsState extends Equatable {
  const LogsState();
  @override
  List<Object?> get props => [];
}

class LogsInitial extends LogsState {}

class LogsLoading extends LogsState {}

class LogsLoaded extends LogsState {
  final List<OperationLog> logs;
  const LogsLoaded(this.logs);
  @override
  List<Object?> get props => [logs];
}

class LogsError extends LogsState {
  final String message;
  const LogsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────

class LogsCubit extends Cubit<LogsState> {
  final OperationLogRepository _logRepo;

  LogsCubit({required OperationLogRepository operationLogRepository})
      : _logRepo = operationLogRepository,
        super(LogsInitial());

  Future<void> loadLogs() async {
    emit(LogsLoading());
    try {
      final logs = await _logRepo.getAllSorted();
      emit(LogsLoaded(logs));
    } catch (e) {
      emit(LogsError('Failed to load logs: $e'));
    }
  }

  Future<void> loadRecentLogs({int limit = 50}) async {
    emit(LogsLoading());
    try {
      final logs = await _logRepo.getRecent(limit: limit);
      emit(LogsLoaded(logs));
    } catch (e) {
      emit(LogsError('Failed to load logs: $e'));
    }
  }
}
