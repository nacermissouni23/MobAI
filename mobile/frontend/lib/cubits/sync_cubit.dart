import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:frontend/data/sync/sync_service.dart';

// ── States ──────────────────────────────────────────────────

abstract class SyncState extends Equatable {
  const SyncState();
  @override
  List<Object?> get props => [];
}

class SyncIdle extends SyncState {
  final DateTime? lastSyncTime;
  final bool hasPending;
  const SyncIdle({this.lastSyncTime, this.hasPending = false});
  @override
  List<Object?> get props => [lastSyncTime, hasPending];
}

class SyncInProgress extends SyncState {}

class SyncSuccess extends SyncState {
  final DateTime syncTime;
  const SyncSuccess(this.syncTime);
  @override
  List<Object?> get props => [syncTime];
}

class SyncError extends SyncState {
  final String message;
  const SyncError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────

class SyncCubit extends Cubit<SyncState> {
  final SyncService _syncService;
  StreamSubscription? _connectivitySub;
  StreamSubscription? _syncStatusSub;
  Timer? _autoSyncTimer;

  SyncCubit({required SyncService syncService})
    : _syncService = syncService,
      super(const SyncIdle()) {
    _init();
  }

  void _init() {
    // Listen to sync status changes
    _syncStatusSub = _syncService.statusStream.listen((status) {
      switch (status) {
        case SyncStatus.syncing:
          emit(SyncInProgress());
          break;
        case SyncStatus.success:
          emit(SyncSuccess(DateTime.now()));
          _checkIdleState();
          break;
        case SyncStatus.error:
          emit(SyncError(_syncService.lastError ?? 'Sync failed'));
          break;
        case SyncStatus.idle:
          _checkIdleState();
          break;
      }
    });

    // Listen for connectivity changes → auto-sync when online
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      if (isConnected) {
        // Auto-sync when connectivity is restored
        triggerSync();
      }
    });

    // Auto-sync every 5 minutes
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      triggerSync();
    });

    // Check initial state
    _checkIdleState();
  }

  /// Trigger a manual sync.
  Future<void> triggerSync() async {
    if (state is SyncInProgress) return;
    try {
      await _syncService.syncAll();
    } catch (_) {
      // Error is handled via stream
    }
  }

  /// Check and emit idle state with pending info.
  Future<void> _checkIdleState() async {
    final lastSync = await _syncService.getLastSyncTime();
    final hasPending = await _syncService.hasPendingChanges();
    emit(SyncIdle(lastSyncTime: lastSync, hasPending: hasPending));
  }

  /// Get pending change counts.
  Future<Map<String, int>> getPendingCounts() {
    return _syncService.getPendingCounts();
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    _syncStatusSub?.cancel();
    _autoSyncTimer?.cancel();
    return super.close();
  }
}
