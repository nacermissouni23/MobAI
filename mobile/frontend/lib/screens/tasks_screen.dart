import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final isEmployee =
        authState is AuthAuthenticated &&
        authState.user.role == UserRole.employee;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: isEmployee ? null : const AppDrawer(),
      appBar: WarehouseAppBar(
        title: 'TASKS',
        showBackButton: false,
        leadingIcon: isEmployee ? Icons.logout : null,
        onMenuPressed: isEmployee
            ? () {
                context.read<AuthCubit>().logout();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            : null,
      ),
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          if (state is TasksLoaded) {
            final tasks = state.tasks
                .where(
                  (t) =>
                      t.status != TaskStatus.completed &&
                      (t.type == TaskType.pick || t.type == TaskType.store),
                )
                .toList();
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return _TaskCard(task: tasks[index]);
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final WarehouseTask task;

  const _TaskCard({required this.task});

  IconData _getIconForType(TaskType type) {
    switch (type) {
      case TaskType.pick:
        return Icons.location_on;
      case TaskType.deliver:
        return Icons.local_shipping;
      case TaskType.store:
        return Icons.inventory_2;
      case TaskType.receipt:
        return Icons.input;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');
    final timeFormat = DateFormat('hh:mm a');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          switch (task.type) {
            case TaskType.pick:
              Navigator.of(context).pushNamed('/pick-1', arguments: task);
              break;
            case TaskType.deliver:
              Navigator.of(
                context,
              ).pushNamed('/delivery-task', arguments: task);
              break;
            case TaskType.store:
              Navigator.of(context).pushNamed('/store-task', arguments: task);
              break;
            case TaskType.receipt:
              // For employees, show received receipt verification screen
              Navigator.of(context).pushNamed(
                '/received-receipt',
                arguments: {
                  'productName': task.productId ?? 'Unknown',
                  'productId': task.productId ?? '',
                  'expectedQuantity': task.quantity,
                },
              );
              break;
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    task.typeLabel,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    _getIconForType(task.type),
                    size: 18,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task.location,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(task.scheduledAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeFormat.format(task.scheduledAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
