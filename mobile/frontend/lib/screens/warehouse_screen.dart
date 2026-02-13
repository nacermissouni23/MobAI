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
  bool _editMode = false;

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
                // Depot Title + Legend
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Depot B7',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMain,
                        ),
                      ),
                      if (_editMode)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            'EDITING',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange.shade700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Floor Selector Tabs
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.floorNames.length,
                    itemBuilder: (context, index) {
                      final name = state.floorNames[index];
                      final isSelected = index == state.currentFloor;
                      return GestureDetector(
                        onTap: () =>
                            context.read<WarehouseCubit>().switchFloor(index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.slate500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _legendItem(
                        AppColors.primary.withValues(alpha: 0.3),
                        'Slot (occupied)',
                      ),
                      _legendItem(AppColors.surface, 'Slot (empty)'),
                      _legendItem(Colors.grey.shade400, 'Obstacle'),
                      _legendItem(Colors.blue.shade200, 'Elevator'),
                      _legendItem(Colors.green.shade200, 'Expedition'),
                      _legendItem(Colors.orange.shade200, 'Vrac'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Grid size info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${state.gridWidth} × ${state.gridHeight} • ${state.cells.length} cells',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Warehouse Grid - interactive scrollable
                Expanded(
                  child: InteractiveViewer(
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(100),
                    minScale: 0.1,
                    maxScale: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                        width: state.gridWidth * 18.0,
                        height: state.gridHeight * 18.0,
                        child: CustomPaint(
                          painter: _WarehouseGridPainter(
                            cells: state.cells,
                            gridWidth: state.gridWidth,
                            gridHeight: state.gridHeight,
                          ),
                        ),
                      ),
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
                      onPressed: () {
                        setState(() => _editMode = !_editMode);
                        if (_editMode) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Pinch to zoom, tap cells to select. Editing mode active.',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: Icon(_editMode ? Icons.check : Icons.edit),
                      label: Text(_editMode ? 'DONE EDITING' : 'EDIT SLOTS'),
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

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for rendering the warehouse grid efficiently
class _WarehouseGridPainter extends CustomPainter {
  final List<WarehouseCell> cells;
  final int gridWidth;
  final int gridHeight;

  _WarehouseGridPainter({
    required this.cells,
    required this.gridWidth,
    required this.gridHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridWidth;
    final roadPaint = Paint()..color = const Color(0xFFF8F9FA);
    final obstaclePaint = Paint()..color = const Color(0xFF9E9E9E);
    final slotEmptyPaint = Paint()..color = const Color(0xFFFFFFFF);
    final slotOccupiedPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25);
    final elevatorPaint = Paint()..color = const Color(0xFF90CAF9);
    final expeditionPaint = Paint()..color = const Color(0xFFA5D6A7);
    final vracPaint = Paint()..color = const Color(0xFFFFCC80);
    final borderPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    for (final cell in cells) {
      final rect = Rect.fromLTWH(
        cell.x * cellSize,
        cell.y * cellSize,
        cellSize,
        cellSize,
      );

      Paint fillPaint;
      if (cell.isElevator) {
        fillPaint = elevatorPaint;
      } else if (cell.isExpeditionZone) {
        fillPaint = expeditionPaint;
      } else if (cell.isVracZone) {
        fillPaint = vracPaint;
      } else if (cell.isObstacle) {
        fillPaint = obstaclePaint;
      } else if (cell.isSlot) {
        fillPaint = cell.isOccupied ? slotOccupiedPaint : slotEmptyPaint;
      } else {
        fillPaint = roadPaint;
      }

      canvas.drawRect(rect, fillPaint);
      if (cell.isSlot ||
          cell.isElevator ||
          cell.isExpeditionZone ||
          cell.isVracZone) {
        canvas.drawRect(rect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WarehouseGridPainter oldDelegate) {
    return oldDelegate.cells != cells || oldDelegate.gridWidth != gridWidth;
  }
}
