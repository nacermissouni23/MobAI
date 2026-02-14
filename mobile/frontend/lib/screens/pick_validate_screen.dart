import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

/// Pick Step 2: Path from elevator to rack + validate.
class PickValidateScreen extends StatelessWidget {
  final Operation task;
  final int pickedQuantity;

  const PickValidateScreen({
    super.key,
    required this.task,
    required this.pickedQuantity,
  });

  void _handleValidate(BuildContext context) {
    context.read<OperationsCubit>().completeOperation(task.id);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const WarehouseAppBar(title: 'PICK 2', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Product Identity
                  const SectionLabel('Product Identity'),
                  const SizedBox(height: 4),
                  Text(
                    task.productId ?? 'UNKNOWN',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quantity display
                  _buildQuantityDisplay(),
                  const SizedBox(height: 24),

                  // Location Badge
                  _buildLocationBadge(),
                  const SizedBox(height: 24),

                  // Path Grid
                  const PathGrid(
                    title: 'Warehouse Path Map',
                    startIndex: 20,
                    endIndex: 4,
                    hint: 'Follow highlighted aisle',
                  ),
                ],
              ),
            ),
          ),
          BottomActionBar.single(
            label: 'VALIDATE',
            icon: Icons.check_circle,
            onPressed: () => _handleValidate(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityDisplay() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Column(
        children: [
          const SectionLabel('Quantity to Pick'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$pickedQuantity',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'UNITS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBadge() {
    final location = task.toLocation ?? 'Floor 0, Zone A-12';
    final parts = location.split(',');
    final floor = parts.first.trim();
    final zone = parts.length > 1 ? parts.last.trim() : 'A-12';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LOCATION',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    floor,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'ZONE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 1,
                ),
              ),
              Text(
                zone,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
