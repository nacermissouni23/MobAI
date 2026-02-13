import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/data/mock_data.dart';

// States
abstract class WarehouseState extends Equatable {
  const WarehouseState();
  @override
  List<Object?> get props => [];
}

class WarehouseInitial extends WarehouseState {}

class WarehouseLoaded extends WarehouseState {
  final List<WarehouseCell> cells;
  final int currentFloor;
  final List<String> floorNames;

  const WarehouseLoaded({
    required this.cells,
    this.currentFloor = 0,
    this.floorNames = const ['Ground', 'Floor 1', 'Floor 2'],
  });

  @override
  List<Object?> get props => [cells, currentFloor];
}

// Cubit
class WarehouseCubit extends Cubit<WarehouseState> {
  WarehouseCubit() : super(WarehouseInitial());

  void loadWarehouse() {
    final cells = MockData.generateWarehouseGrid(floor: 0);
    emit(WarehouseLoaded(cells: cells));
  }

  void switchFloor(int floor) {
    final cells = MockData.generateWarehouseGrid(floor: floor);
    emit(WarehouseLoaded(cells: cells, currentFloor: floor));
  }
}
