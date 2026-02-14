import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/enums.dart';
import 'package:frontend/data/models/operation.dart';
import 'package:frontend/data/models/operation_log.dart';
import 'package:frontend/data/models/stock_ledger.dart';
import 'package:frontend/data/repositories/operation_repository.dart';
import 'package:frontend/data/repositories/operation_log_repository.dart';
import 'package:frontend/data/repositories/emplacement_repository.dart';
import 'package:frontend/data/repositories/stock_ledger_repository.dart';
import 'package:frontend/data/repositories/report_repository.dart';
import 'package:frontend/data/models/report.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

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
  final OperationLogRepository? _logRepo;
  final EmplacementRepository? _emplacementRepo;
  final StockLedgerRepository? _stockLedgerRepo;
  final ReportRepository? _reportRepo;

  OperationsCubit({
    required OperationRepository operationRepository,
    OperationLogRepository? operationLogRepository,
    EmplacementRepository? emplacementRepository,
    StockLedgerRepository? stockLedgerRepository,
    ReportRepository? reportRepository,
  }) : _operationRepo = operationRepository,
       _logRepo = operationLogRepository,
       _emplacementRepo = emplacementRepository,
       _stockLedgerRepo = stockLedgerRepository,
       _reportRepo = reportRepository,
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

  /// Create a receipt operation (supervisor creates it, assigns to employee).
  Future<Operation?> createReceiptOperation({
    required String productId,
    required int quantity,
    String? employeeId,
    String? orderId,
  }) async {
    try {
      final now = DateTime.now();
      final op = Operation(
        id: _uuid.v4(),
        type: OperationType.receipt,
        status: OperationStatus.pending,
        productId: productId,
        quantity: quantity,
        employeeId: employeeId,
        orderId: orderId,
        createdAt: now,
        updatedAt: now,
      );
      final created = await _operationRepo.insert(op);
      await _createLog(created, 'created');
      await loadOperations();
      return created;
    } catch (e) {
      emit(OperationsError('Failed to create receipt: $e'));
      return null;
    }
  }

  /// Create a delivery operation (supervisor creates it).
  Future<Operation?> createDeliveryOperation({
    required String productId,
    required int quantity,
    String? employeeId,
  }) async {
    try {
      final now = DateTime.now();
      final op = Operation(
        id: _uuid.v4(),
        type: OperationType.delivery,
        status: OperationStatus.pending,
        productId: productId,
        quantity: quantity,
        employeeId: employeeId,
        createdAt: now,
        updatedAt: now,
      );
      final created = await _operationRepo.insert(op);
      await _createLog(created, 'created');
      await loadOperations();
      return created;
    } catch (e) {
      emit(OperationsError('Failed to create delivery: $e'));
      return null;
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

  /// Validate/complete a receipt operation.
  /// On completion, creates a stock ledger entry and a pending transfer operation.
  Future<void> validateReceipt({
    required String operationId,
    required int actualQuantity,
    required String productId,
    String? validatorId,
    int? discrepancy,
  }) async {
    try {
      // Complete the receipt
      await _operationRepo.complete(operationId, validatorId: validatorId);

      // Log the validation
      final op = await _operationRepo.getById(operationId);
      if (op != null) {
        await _createLog(op, 'validated');

        // Create a report if there's a discrepancy
        if (discrepancy != null && discrepancy != 0 && _reportRepo != null) {
          final report = Report(
            id: _uuid.v4(),
            operationId: operationId,
            missingQuantity: discrepancy < 0 ? discrepancy.abs() : 0,
            physicalDamage: false,
            extraQuantity: discrepancy > 0 ? discrepancy : 0,
            notes:
                'Receipt discrepancy: expected ${op.quantity}, received $actualQuantity',
            reportedBy: validatorId ?? '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _reportRepo.insert(report);
        }

        // Create a transfer operation (pending supervisor approval for storage)
        final now = DateTime.now();
        final transferOp = Operation(
          id: _uuid.v4(),
          type: OperationType.transfer,
          status: OperationStatus.pending,
          productId: productId,
          quantity: actualQuantity,
          orderId: op.orderId,
          employeeId: op.employeeId,
          createdAt: now,
          updatedAt: now,
        );
        await _operationRepo.insert(transferOp);
        await _createLog(transferOp, 'created');
      }

      await loadOperations();
    } catch (e) {
      emit(OperationsError('Failed to validate receipt: $e'));
    }
  }

  /// Validate/complete a transfer (storage) operation.
  /// Updates emplacement stock and creates ledger entry.
  Future<void> validateStorage({
    required String operationId,
    String? validatorId,
  }) async {
    try {
      final op = await _operationRepo.getById(operationId);
      if (op == null) return;

      await _operationRepo.complete(operationId, validatorId: validatorId);
      await _createLog(op, 'validated');

      // Update emplacement stock
      if (_emplacementRepo != null &&
          op.destinationX != null &&
          op.destinationY != null &&
          op.productId != null) {
        final emplacement = await _emplacementRepo.getByCoords(
          op.destinationX!,
          op.destinationY!,
          op.destinationZ ?? 0,
          op.destinationFloor ?? 0,
        );
        if (emplacement != null) {
          await _emplacementRepo.updateStock(
            emplacement.id,
            op.productId!,
            op.quantity,
          );
        }

        // Create stock ledger entry
        if (_stockLedgerRepo != null) {
          final ledger = StockLedger(
            id: _uuid.v4(),
            x: op.destinationX!,
            y: op.destinationY!,
            z: op.destinationZ ?? 0,
            floor: op.destinationFloor ?? 0,
            productId: op.productId!,
            quantity: op.quantity,
            recordedAt: DateTime.now(),
            operationId: operationId,
            operationType: op.type,
            userId: validatorId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _stockLedgerRepo.insert(ledger);
        }
      }

      await loadOperations();
    } catch (e) {
      emit(OperationsError('Failed to validate storage: $e'));
    }
  }

  /// Validate/complete a picking operation.
  /// Decrements source stock. Delivery is created separately by supervisor/admin.
  Future<void> validatePicking({
    required String operationId,
    required int pickedQuantity,
    String? validatorId,
  }) async {
    try {
      final op = await _operationRepo.getById(operationId);
      if (op == null) return;

      await _operationRepo.complete(operationId, validatorId: validatorId);
      await _createLog(op, 'validated');

      // Decrement source emplacement stock
      if (_emplacementRepo != null &&
          op.sourceX != null &&
          op.sourceY != null &&
          op.productId != null) {
        final sourceEmplacement = await _emplacementRepo.getByCoords(
          op.sourceX!,
          op.sourceY!,
          op.sourceZ ?? 0,
          op.sourceFloor ?? 0,
        );
        if (sourceEmplacement != null) {
          await _emplacementRepo.updateStock(
            sourceEmplacement.id,
            op.productId!,
            -pickedQuantity,
          );
        }

        // Create stock ledger (negative = out)
        if (_stockLedgerRepo != null) {
          final ledger = StockLedger(
            id: _uuid.v4(),
            x: op.sourceX!,
            y: op.sourceY!,
            z: op.sourceZ ?? 0,
            floor: op.sourceFloor ?? 0,
            productId: op.productId!,
            quantity: -pickedQuantity,
            recordedAt: DateTime.now(),
            operationId: operationId,
            operationType: op.type,
            userId: validatorId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _stockLedgerRepo.insert(ledger);
        }
      }

      await loadOperations();
    } catch (e) {
      emit(OperationsError('Failed to validate picking: $e'));
    }
  }

  /// Validate/complete a delivery operation.
  Future<void> validateDelivery({
    required String operationId,
    String? validatorId,
  }) async {
    try {
      final op = await _operationRepo.getById(operationId);
      if (op == null) return;

      await _operationRepo.complete(operationId, validatorId: validatorId);
      await _createLog(op, 'validated');

      await loadOperations();
    } catch (e) {
      emit(OperationsError('Failed to validate delivery: $e'));
    }
  }

  Future<void> completeOperation(
    String operationId, {
    String? validatorId,
  }) async {
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

  /// Create an operation log entry.
  Future<void> _createLog(Operation op, String action) async {
    if (_logRepo == null) return;
    try {
      final log = OperationLog(
        id: _uuid.v4(),
        operationId: op.id,
        employeeId: op.employeeId,
        productId: op.productId,
        quantity: op.quantity,
        type: op.type,
        chariotId: op.chariotId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _logRepo.insert(log);
    } catch (_) {
      // Don't fail the operation if logging fails
    }
  }
}
