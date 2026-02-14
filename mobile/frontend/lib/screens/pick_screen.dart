import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/screens/pick_validate_screen.dart';
import 'package:frontend/widgets/widgets.dart';

/// Pick Step 1: Path from current location to elevator.
class PickScreen extends StatefulWidget {
  final Operation task;
  const PickScreen({super.key, required this.task});

  @override
  State<PickScreen> createState() => _PickScreenState();
}

class _PickScreenState extends State<PickScreen> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.task.quantity;
  }

  void _handleNext() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            PickValidateScreen(task: widget.task, pickedQuantity: _quantity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const WarehouseAppBar(title: 'PICK 1', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Product ID
                  const SectionLabel('Product ID'),
                  const SizedBox(height: 4),
                  Text(
                    widget.task.productId ?? 'UNKNOWN',
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quantity Adjustment
                  LargeQuantityStepper(
                    value: _quantity,
                    onChanged: (v) => setState(() => _quantity = v),
                  ),
                  const SizedBox(height: 24),

                  // Location Card
                  _buildLocationCard(),
                  const SizedBox(height: 24),

                  // Path Grid
                  const PathGrid(
                    title: 'Path Visualization',
                    startIndex: 20,
                    endIndex: 4,
                    hint: 'Follow highlighted aisle',
                  ),
                ],
              ),
            ),
          ),
          BottomActionBar.single(
            label: 'NEXT',
            icon: Icons.arrow_forward,
            onPressed: _handleNext,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Current Location'),
                const SizedBox(height: 4),
                Text(
                  widget.task.fromLocation ?? 'Floor 1',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
