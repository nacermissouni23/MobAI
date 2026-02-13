import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WarehouseCubit>().loadWarehouse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: const WarehouseAppBar(title: 'Warehouse'),
      body: BlocBuilder<WarehouseCubit, WarehouseState>(
        builder: (context, state) {
          if (state is WarehouseLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Depot Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Depot B7',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                // Floor Selector Tabs
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: state.floorNames.asMap().entries.map((entry) {
                      final index = entry.key;
                      final name = entry.value;
                      final isSelected = index == state.currentFloor;
                      return GestureDetector(
                        onTap: () =>
                            context.read<WarehouseCubit>().switchFloor(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.slate500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Warehouse Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                      itemCount: state.cells.length,
                      itemBuilder: (context, index) {
                        final cell = state.cells[index];
                        return _WarehouseGridCell(cell: cell, index: index);
                      },
                    ),
                  ),
                ),
                // Bottom Action
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                      label: const Text('EDIT SLOTS'),
                    ),
                  ),
                ),
              ],
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

class _WarehouseGridCell extends StatelessWidget {
  final WarehouseCell cell;
  final int index;

  const _WarehouseGridCell({required this.cell, required this.index});

  @override
  Widget build(BuildContext context) {
    final slotName = 'B7-${(index + 1).toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: cell.isOccupied
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: cell.isOccupied
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.slateLight,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (cell.isOccupied)
            Icon(
              Icons.inventory_2,
              color: AppColors.primary.withValues(alpha: 0.6),
              size: 20,
            ),
          const SizedBox(height: 4),
          Text(
            slotName,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: cell.isOccupied ? AppColors.primary : AppColors.slate400,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
