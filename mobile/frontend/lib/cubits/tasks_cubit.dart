import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/data/mock_data.dart';

// States
abstract class TasksState extends Equatable {
  const TasksState();
  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {}

class TasksLoaded extends TasksState {
  final List<WarehouseTask> tasks;
  const TasksLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

// Cubit
class TasksCubit extends Cubit<TasksState> {
  TasksCubit() : super(TasksInitial());

  void loadTasks() {
    emit(TasksLoaded(MockData.tasks));
  }

  void completeTask(String taskId) {
    if (state is TasksLoaded) {
      final currentTasks = (state as TasksLoaded).tasks;
      final updated = currentTasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(status: TaskStatus.completed);
        }
        return t;
      }).toList();
      emit(TasksLoaded(updated));
    }
  }
}
