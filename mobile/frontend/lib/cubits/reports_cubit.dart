import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/report.dart';
import 'package:frontend/data/repositories/report_repository.dart';

// ── States ──────────────────────────────────────────────────

abstract class ReportsState extends Equatable {
  const ReportsState();
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<Report> reports;
  const ReportsLoaded(this.reports);
  @override
  List<Object?> get props => [reports];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────

class ReportsCubit extends Cubit<ReportsState> {
  final ReportRepository _reportRepo;

  ReportsCubit({required ReportRepository reportRepository})
      : _reportRepo = reportRepository,
        super(ReportsInitial());

  Future<void> loadReports() async {
    emit(ReportsLoading());
    try {
      final reports = await _reportRepo.getAllSorted();
      emit(ReportsLoaded(reports));
    } catch (e) {
      emit(ReportsError('Failed to load reports: $e'));
    }
  }

  Future<void> addReport({
    required String operationId,
    required String reportedBy,
    int missingQuantity = 0,
    bool physicalDamage = false,
    int extraQuantity = 0,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final report = Report(
        id: _reportRepo.generateId(),
        operationId: operationId,
        missingQuantity: missingQuantity,
        physicalDamage: physicalDamage,
        extraQuantity: extraQuantity,
        notes: notes,
        reportedBy: reportedBy,
        createdAt: now,
        updatedAt: now,
      );
      await _reportRepo.insert(report);
      await loadReports();
    } catch (e) {
      emit(ReportsError('Failed to add report: $e'));
    }
  }

  Future<void> deleteReport(String reportId) async {
    try {
      await _reportRepo.softDelete(reportId);
      await loadReports();
    } catch (e) {
      emit(ReportsError('Failed to delete report: $e'));
    }
  }
}
