import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/models.dart';

// States
abstract class WarehouseState extends Equatable {
  const WarehouseState();
  @override
  List<Object?> get props => [];
}

class WarehouseInitial extends WarehouseState {}

class WarehouseLoaded extends WarehouseState {
  final List<WarehouseFloor> floors;
  final int currentFloor;

  const WarehouseLoaded({required this.floors, this.currentFloor = 0});

  List<WarehouseCell> get cells =>
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

// Cubit
class WarehouseCubit extends Cubit<WarehouseState> {
  WarehouseCubit() : super(WarehouseInitial());

  List<WarehouseFloor> _floors = [];

  Future<void> loadWarehouse() async {
    try {
      // Load all floor JSON files from assets
      final groundJson = await rootBundle.loadString(
        'assets/warehouse/ground_floor.json',
      );
      final floor12Json = await rootBundle.loadString(
        'assets/warehouse/floor_1_and_2.json',
      );
      final floor3Json = await rootBundle.loadString(
        'assets/warehouse/floor3.json',
      );
      final floor4Json = await rootBundle.loadString(
        'assets/warehouse/floor4.json',
      );

      final groundData = json.decode(groundJson) as Map<String, dynamic>;
      final floor12Data = json.decode(floor12Json) as Map<String, dynamic>;
      final floor3Data = json.decode(floor3Json) as Map<String, dynamic>;
      final floor4Data = json.decode(floor4Json) as Map<String, dynamic>;

      // Parse ground floor
      final groundCells = (groundData['cells'] as List)
          .map((c) => WarehouseCell.fromJson(c as Map<String, dynamic>))
          .toList();
      final groundFloor = WarehouseFloor(
        floorNumber: 0,
        name: 'Ground',
        cells: groundCells,
        width: groundData['width'] as int? ?? 29,
        height: groundData['height'] as int? ?? 44,
      );

      // Parse floor 1 and 2 (same file, filter by floor)
      final floor12Cells = (floor12Data['cells'] as List)
          .map((c) => WarehouseCell.fromJson(c as Map<String, dynamic>))
          .toList();
      final floor1Cells = floor12Cells.where((c) => c.floor == 1).toList();
      final floor2Cells = floor12Cells.where((c) => c.floor == 2).toList();

      final floor1 = WarehouseFloor(
        floorNumber: 1,
        name: 'Floor 1',
        cells: floor1Cells,
        width: floor12Data['width'] as int? ?? 29,
        height: floor12Data['height'] as int? ?? 44,
      );

      final floor2 = WarehouseFloor(
        floorNumber: 2,
        name: 'Floor 2',
        cells: floor2Cells,
        width: floor12Data['width'] as int? ?? 29,
        height: floor12Data['height'] as int? ?? 44,
      );

      // Parse floor 3
      final floor3Cells = (floor3Data['cells'] as List)
          .map((c) => WarehouseCell.fromJson(c as Map<String, dynamic>))
          .toList();
      final floor3 = WarehouseFloor(
        floorNumber: 3,
        name: 'Floor 3',
        cells: floor3Cells,
        width: floor3Data['width'] as int? ?? 29,
        height: floor3Data['height'] as int? ?? 46,
      );

      // Parse floor 4
      final floor4Cells = (floor4Data['cells'] as List)
          .map((c) => WarehouseCell.fromJson(c as Map<String, dynamic>))
          .toList();
      final floor4 = WarehouseFloor(
        floorNumber: 4,
        name: 'Floor 4',
        cells: floor4Cells,
        width: floor4Data['width'] as int? ?? 29,
        height: floor4Data['height'] as int? ?? 46,
      );

      _floors = [groundFloor, floor1, floor2, floor3, floor4];
      emit(WarehouseLoaded(floors: _floors, currentFloor: 0));
    } catch (e) {
      // Fallback: emit with empty floors
      _floors = [];
      emit(WarehouseLoaded(floors: _floors, currentFloor: 0));
    }
  }

  void switchFloor(int floorIndex) {
    if (_floors.isNotEmpty && floorIndex < _floors.length) {
      emit(WarehouseLoaded(floors: _floors, currentFloor: floorIndex));
    }
  }

  void updateCell(int floorIndex, int x, int y, WarehouseCell updatedCell) {
    if (_floors.isNotEmpty && floorIndex < _floors.length) {
      final floor = _floors[floorIndex];
      final updatedCells = floor.cells.map((c) {
        if (c.x == x && c.y == y) return updatedCell;
        return c;
      }).toList();
      _floors[floorIndex] = WarehouseFloor(
        floorNumber: floor.floorNumber,
        name: floor.name,
        cells: updatedCells,
        width: floor.width,
        height: floor.height,
      );
      emit(
        WarehouseLoaded(floors: List.from(_floors), currentFloor: floorIndex),
      );
    }
  }
}
