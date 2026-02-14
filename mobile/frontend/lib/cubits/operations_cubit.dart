import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/operation.dart';
import 'package:frontend/data/repositories/operation_repository.dart';

// ── States ──────────────────────────────────────────────────

abstract class OperationsState extends Equatable {
  const OperationsState();
  @override
  List<Object?> get props => [];
}

class OperationsInitial extends OperationsState {}

class OperationsLoading extends OperationsState {}

class OperationsLoaded extends OperationsState {
  final List<Operation> operations;
  const OperationsLoaded(this.operations);
  @override
  List<Object?> get props => [operations];
}

class OperationsError extends OperationsState {
  final String message;
  const OperationsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────

class OperationsCubit extends Cubit<OperationsState> {
  final OperationRepository _operationRepo;

  OperationsCubit({required OperationRepository operationRepository})
      : _operationRepo = operationRepository,
        super(OperationsInitial());

  Future<void> loadOperations() async {
    emit(OperationsLoading());
    try {
      final operations = await _operationRepo.getAllSorted();
      emit(OperationsLoaded(operations));
    } catch (e) {
      emit(OperationsError('Failed to load operations: $e'));
    }
  }

  Future<void> loadByEmployee(String employeeId) async {
    emit(OperationsLoading());
    try {
      final operations = await _operationRepo.getByEmployee(employeeId);
      emit(OperationsLoaded(operations));
    } catch (e) {
      emit(OperationsError('Failed to load operations: $e'));
    }
  }

  Future<void> startOperation(String operationId) async {
    try {
      await _operationRepo.start(operationId);
      await loadOperations();
    } catch (e) {
      emit(OperationsError('Failed to start operation: $e'));
    }
  }

  Future<void> completeOperation(String operationId, {String? validatorId}) async {
    try {
      await _operationRepo.complete(operationId, validatorId: validatorId);
      await loadOperations();
    } catch (e) {
      emit(OperationsError('Failed to complete operation: $e'));
    }
  }

  Future<void> failOperation(String operationId) async {
    try {
      await _operationRepo.fail(operationId);
      await loadOperations();
    } catch (e) {
      emit(OperationsError('Failed to fail operation: $e'));
    }
  }
}
