import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

/// Screen for completing a storage task.
/// Allows quantity adjustment but NO override of location/path.
class StoreTaskScreen extends StatefulWidget {
  final Operation task;
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
    final authState = context.read<AuthCubit>().state;
    String? validatorId;
    if (authState is AuthAuthenticated) {
      validatorId = authState.user.id;
    }

    context.read<OperationsCubit>().validateStorage(
      operationId: widget.task.id,
      validatorId: validatorId,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Storage validated')));
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
                  _buildHeaderInfo(),
                  const SizedBox(height: 24),
                  LocationRow(
                    fromValue: widget.task.fromLocation ?? 'Unknown',
                    toValue: widget.task.toLocation ?? 'Unknown',
                  ),
                  const SizedBox(height: 24),
                  PathGrid(
                    route: widget.task.suggestedRoute,
                    title: 'Path Visualization',
                    hint: 'Follow highlighted aisle',
                  ),
                ],
              ),
            ),
          ),
          BottomActionBar.single(label: 'VALIDATE', onPressed: _handleValidate),
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
              const TypeBadge(label: 'Store'),
              OperationStatusBadge(status: widget.task.status),
            ],
          ),
          const SizedBox(height: 16),
          const SectionLabel('Product ID'),
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
              const SectionLabel('Quantity'),
              QuantityStepper(
                value: _quantity,
                onChanged: (v) => setState(() => _quantity = v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
