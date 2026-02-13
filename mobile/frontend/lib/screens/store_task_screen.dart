import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

/// Screen for completing a storage task.
/// Employee confirms product stored at the target warehouse cell.
/// Allows quantity adjustment but NO override of location/path.
class StoreTaskScreen extends StatefulWidget {
  final WarehouseTask task;
  const StoreTaskScreen({super.key, required this.task});

  @override
  State<StoreTaskScreen> createState() => _StoreTaskScreenState();
}

class _StoreTaskScreenState extends State<StoreTaskScreen> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.task.quantity;
  }

  void _handleValidate() {
    // Logic to complete the task
    context.read<TasksCubit>().completeTask(widget.task.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const WarehouseAppBar(title: 'STORAGE', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info
                  _buildHeaderInfo(),
                  const SizedBox(height: 24),
                  
                  // Location Info (From -> To)
                  _buildLocationSection(),
                  const SizedBox(height: 24),

                  // Visualization (Grid placeholder as requested to match suggestion storage view)
                  _buildGridSection(),
                ],
              ),
            ),
          ),
          // Footer
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'STORE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              _StatusBadge(status: widget.task.status),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'PRODUCT ID',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.task.productId ?? '—',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'QUANTITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              _buildQuantityEditor(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityEditor() {
    return Row(
      children: [
        IconButton(
           onPressed: () {
             if (_quantity > 1) setState(() => _quantity--);
           },
           icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 40,
          child: Center(
            child: Text(
              '$_quantity',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        IconButton(
           onPressed: () => setState(() => _quantity++),
           icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Row(
      children: [
        Expanded(
          child: _LocationCard(
            label: 'FROM LOCATION',
            value: widget.task.fromLocation ?? 'Unknown',
            icon: Icons.upload_file,
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.arrow_forward, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: _LocationCard(
            label: 'TO DESTINATION',
            value: widget.task.toLocation ?? 'Unknown',
            icon: Icons.download,
          ),
        ),
      ],
    );
  }

  Widget _buildGridSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PATH VISUALIZATION',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.grid_on, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Storage Location Map',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
      ),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleValidate,
          child: const Text('VALIDATE'),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _LocationCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case TaskStatus.completed:
        color = AppColors.successGreen;
        label = 'COMPLETED';
        icon = Icons.check_circle;
        break;
      case TaskStatus.inProgress:
        color = AppColors.primary;
        label = 'IN PROGRESS';
        icon = Icons.timer;
        break;
      case TaskStatus.pending:
        color = AppColors.warning;
        label = 'PENDING';
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}