import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/widgets/widgets.dart';

/// Pick Step 2: Shows product ID, quantity stepper, location badge,
/// 5x5 grid path map with highlighted path, and a VALIDATE button.
class PickValidateScreen extends StatefulWidget {
  final String productId;
  final int initialQuantity;
  final String floor;
  final String zone;

  const PickValidateScreen({
    super.key,
    this.productId = 'P-88219',
    this.initialQuantity = 15,
    this.floor = 'Floor 0',
    this.zone = 'A-12',
  });

  @override
  State<PickValidateScreen> createState() => _PickValidateScreenState();
}

class _PickValidateScreenState extends State<PickValidateScreen> {
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
      appBar: const WarehouseAppBar(title: 'PICK 2', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Product ID
                  const SizedBox(height: 16),
                  Text(
                    'Product Identity',
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
                      letterSpacing: -1,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quantity Stepper
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
                          'QUANTITY TO PICK',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary.withValues(alpha: 0.6),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Minus
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.remove,
                                      color: AppColors.primary,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Value
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Text(
                                    _quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 56,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textMain,
                                    ),
                                  ),
                                  Text(
                                    'UNITS',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Plus
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _quantity++),
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      color: AppColors.primary,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Location Badge
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LOCATION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                widget.floor,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'ZONE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              widget.zone,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Path Map (5x5 grid)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'WAREHOUSE PATH MAP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary.withValues(alpha: 0.6),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _PathGrid(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.near_me,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'FOLLOW HIGHLIGHTED AISLE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Validate button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  elevation: 8,
                  shadowColor: AppColors.primary.withValues(alpha: 0.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'VALIDATE',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.check_circle, size: 24),
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

/// A 5x5 grid widget showing an L-shaped path from bottom-left to top-right
class _PathGrid extends StatelessWidget {
  // Highlighted cells forming the L-path: bottom row (4,0->4,4) and right column (0,4->3,4)
  // plus the target at (0,4) and start at (4,0)
  static const _pathCells = {
    // Bottom row going right
    '4-1', '4-2', '4-3', '4-4',
    // Right column going up
    '0-4', '1-4', '2-4', '3-4',
  };

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 25,
      itemBuilder: (context, index) {
        final row = index ~/ 5;
        final col = index % 5;
        final key = '$row-$col';

        final isStart = row == 4 && col == 0;
        final isTarget = row == 0 && col == 4;
        final isPath = _pathCells.contains(key);

        if (isTarget) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.inventory_2, color: Colors.white, size: 16),
            ),
          );
        }

        if (isStart) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.primary,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.person_pin_circle,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          );
        }

        if (isPath) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
        );
      },
    );
  }
}
