import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/widgets/widgets.dart';

/// Pick Step 1: Shows product ID, quantity stepper, current location,
/// path visualization grid, and a NEXT button.
class PickScreen extends StatefulWidget {
  final String productId;
  final int initialQuantity;
  final String currentLocation;

  const PickScreen({
    super.key,
    this.productId = 'P-99042',
    this.initialQuantity = 15,
    this.currentLocation = 'Floor 1',
  });

  @override
  State<PickScreen> createState() => _PickScreenState();
}

class _PickScreenState extends State<PickScreen> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
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
                  // Product Identification
                  const SizedBox(height: 16),
                  Text(
                    'Product ID',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary.withValues(alpha: 0.6),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.productId,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quantity Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'QUANTITY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary.withValues(alpha: 0.6),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  color: AppColors.primary,
                                  size: 28,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Center(
                                child: Text(
                                  _quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMain,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _quantity++),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Location Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Location',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                widget.currentLocation,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMain,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('View Map'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Path Visualization
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PATH VISUALIZATION',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary.withValues(alpha: 0.6),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: SizedBox(
                            width: 280,
                            height: 280,
                            child: CustomPaint(
                              painter: _PathVisualizationPainter(
                                gridColor: AppColors.primary.withValues(
                                  alpha: 0.05,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LegendItem(color: Colors.blue, label: 'Start'),
                            const SizedBox(width: 16),
                            _LegendItem(
                              color: Colors.blue,
                              label: 'Target Slot',
                              isOutlined: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // Space for bottom button
                ],
              ),
            ),
          ),
          // Fixed Bottom CTA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight.withValues(alpha: 0.9),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/pick-2');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'NEXT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isOutlined;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color,
            shape: BoxShape.circle,
            border: isOutlined ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.primary.withValues(alpha: 0.4),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _PathVisualizationPainter extends CustomPainter {
  final Color gridColor;

  _PathVisualizationPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 5;
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.fill;

    // Draw grid
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        final rect = Rect.fromLTWH(
          col * cellSize + 2,
          row * cellSize + 2,
          cellSize - 4,
          cellSize - 4,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          gridPaint,
        );
      }
    }

    // Draw path
    final pathPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final startX = cellSize * 0.5;
    final startY = cellSize * 4.5;
    final midY = cellSize * 1.5;
    final endX = cellSize * 3.5;

    final path = Path()
      ..moveTo(startX, startY)
      ..lineTo(startX, midY)
      ..lineTo(endX, midY);

    canvas.drawPath(path, pathPaint);

    // Start point
    canvas.drawCircle(Offset(startX, startY), 4, Paint()..color = Colors.blue);

    // End point (target)
    canvas.drawCircle(Offset(endX, midY), 6, Paint()..color = Colors.blue);

    // Ring around target
    canvas.drawCircle(
      Offset(endX, midY),
      10,
      Paint()
        ..color = Colors.blue.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
