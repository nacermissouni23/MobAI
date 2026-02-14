import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/emplacement.dart';
import 'package:frontend/data/repositories/emplacement_repository.dart';

// ── Helper types ────────────────────────────────────────────

/// Lightweight floor data for warehouse grid rendering.
class WarehouseFloorData extends Equatable {
  final int floorNumber;
  final String name;
  final List<Emplacement> cells;
  final int width;
  final int height;

  const WarehouseFloorData({
    required this.floorNumber,
    required this.name,
    required this.cells,
    required this.width,
    required this.height,
  });

  @override
  List<Object?> get props => [floorNumber, name, cells.length, width, height];
}

// ── States ──────────────────────────────────────────────────

abstract class WarehouseState extends Equatable {
  const WarehouseState();
  @override
  List<Object?> get props => [];
}

class WarehouseInitial extends WarehouseState {}

class WarehouseLoading extends WarehouseState {}

class WarehouseLoaded extends WarehouseState {
  final List<WarehouseFloorData> floors;
  final int currentFloor;

  const WarehouseLoaded({required this.floors, this.currentFloor = 0});

  List<Emplacement> get cells =>
      floors.isNotEmpty && currentFloor < floors.length
          ? floors[currentFloor].cells
          : [];

  List<String> get floorNames => floors.map((f) => f.name).toList();

  int get gridWidth => floors.isNotEmpty && currentFloor < floors.length
      ? floors[currentFloor].width
      : 29;

  int get gridHeight => floors.isNotEmpty && currentFloor < floors.length
      ? floors[currentFloor].height
      : 44;

  @override
  List<Object?> get props => [floors, currentFloor];
}

class WarehouseError extends WarehouseState {
  final String message;
  const WarehouseError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ───────────────────────────────────────────────────

class WarehouseCubit extends Cubit<WarehouseState> {
  final EmplacementRepository _emplacementRepo;

  WarehouseCubit({required EmplacementRepository emplacementRepository})
      : _emplacementRepo = emplacementRepository,
        super(WarehouseInitial());

  List<WarehouseFloorData> _floors = [];

  /// Load warehouse from asset JSON files and seed into the emplacement repository.
  Future<void> loadWarehouse() async {
    emit(WarehouseLoading());
    try {
      // Check if emplacements are already in the DB
      final count = await _emplacementRepo.count();
      if (count > 0) {
        await _loadFromDatabase();
        return;
      }

      // First run: load from JSON assets and insert into DB
      await _loadFromAssetsAndSeed();
    } catch (e) {
      emit(WarehouseError('Failed to load warehouse: $e'));
    }
  }

  Future<void> _loadFromDatabase() async {
    final floorNumbers = await _emplacementRepo.getFloorNumbers();
    final floors = <WarehouseFloorData>[];

    for (final floorNum in floorNumbers) {
      final cells = await _emplacementRepo.getByFloor(floorNum);
      final dims = await _emplacementRepo.getFloorDimensions(floorNum);
      final name = floorNum == 0 ? 'Ground' : 'Floor $floorNum';
      floors.add(WarehouseFloorData(
        floorNumber: floorNum,
        name: name,
        cells: cells,
        width: dims['width'] ?? 29,
        height: dims['height'] ?? 44,
      ));
    }

    _floors = floors;
    emit(WarehouseLoaded(floors: _floors, currentFloor: 0));
  }

  Future<void> _loadFromAssetsAndSeed() async {
    try {
      final groundJson = await rootBundle.loadString('assets/warehouse/ground_floor.json');
      final floor12Json = await rootBundle.loadString('assets/warehouse/floor_1_and_2.json');
      final floor3Json = await rootBundle.loadString('assets/warehouse/floor3.json');
      final floor4Json = await rootBundle.loadString('assets/warehouse/floor4.json');

      final groundData = json.decode(groundJson) as Map<String, dynamic>;
      final floor12Data = json.decode(floor12Json) as Map<String, dynamic>;
      final floor3Data = json.decode(floor3Json) as Map<String, dynamic>;
      final floor4Data = json.decode(floor4Json) as Map<String, dynamic>;

      final allCells = <Emplacement>[];

      // Parse and convert JSON cells to Emplacement models
      allCells.addAll(_parseCells(groundData, 0));
      allCells.addAll(_parseCells(floor12Data, null)); // floor from cell data
      allCells.addAll(_parseCells(floor3Data, 3));
      allCells.addAll(_parseCells(floor4Data, 4));

      // Batch insert into DB
      await _emplacementRepo.insertAll(allCells);

      // Now load from DB to get consistent state
      await _loadFromDatabase();
    } catch (e) {
      // Fallback: emit empty
      _floors = [];
      emit(WarehouseLoaded(floors: _floors, currentFloor: 0));
    }
  }

  List<Emplacement> _parseCells(Map<String, dynamic> data, int? defaultFloor) {
    final cells = data['cells'] as List;
    final now = DateTime.now();
    return cells.map((c) {
      final map = c as Map<String, dynamic>;
      final floor = map['floor'] as int? ?? defaultFloor ?? 0;
      return Emplacement(
        id: _emplacementRepo.generateId(),
        x: map['x'] as int? ?? 0,
        y: map['y'] as int? ?? 0,
        z: map['z'] as int? ?? 0,
        floor: floor,
        isObstacle: map['is_obstacle'] as bool? ?? map['type'] == 'obstacle',
        isSlot: map['is_slot'] as bool? ?? map['type'] == 'slot',
        isElevator: map['is_elevator'] as bool? ?? map['type'] == 'elevator',
        isRoad: map['is_road'] as bool? ?? map['type'] == 'road',
        isExpedition: map['is_expedition'] as bool? ?? map['type'] == 'expedition',
        productId: map['product_id'] as String?,
        quantity: map['quantity'] as int? ?? 0,
        isOccupied: map['is_occupied'] as bool? ?? (map['product_id'] != null),
        locationCode: map['location_code'] as String?,
        createdAt: now,
        updatedAt: now,
      );
    }).toList();
  }

  void switchFloor(int floorIndex) {
    if (_floors.isNotEmpty && floorIndex < _floors.length) {
      emit(WarehouseLoaded(floors: _floors, currentFloor: floorIndex));
    }
  }

  Future<void> updateCell(int floorIndex, int x, int y, Emplacement updatedCell) async {
    try {
      await _emplacementRepo.updateEntity(updatedCell);
      // Refresh the specific floor
      if (_floors.isNotEmpty && floorIndex < _floors.length) {
        final floorNum = _floors[floorIndex].floorNumber;
        final cells = await _emplacementRepo.getByFloor(floorNum);
        _floors[floorIndex] = WarehouseFloorData(
          floorNumber: _floors[floorIndex].floorNumber,
          name: _floors[floorIndex].name,
          cells: cells,
          width: _floors[floorIndex].width,
          height: _floors[floorIndex].height,
        );
        emit(WarehouseLoaded(floors: List.from(_floors), currentFloor: floorIndex));
      }
    } catch (e) {
      emit(WarehouseError('Failed to update cell: $e'));
    }
  }
}
