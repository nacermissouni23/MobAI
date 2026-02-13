import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/widgets/widgets.dart';

/// Suggestion Detail / Picking screen with product ID, quantity stepper,
/// from/to locations, warehouse floor-map grid, and Override/Validate footer.
class SuggestionDetailsScreen extends StatefulWidget {
  final String productId;
  final int initialQuantity;
  final String fromLocation;
  final String toLocation;

  const SuggestionDetailsScreen({
    super.key,
    this.productId = 'P-55219',
    this.initialQuantity = 15,
    this.fromLocation = 'A-12-04',
    this.toLocation = 'B-05-01',
  });

  @override
  State<SuggestionDetailsScreen> createState() =>
      _SuggestionDetailsScreenState();
}

class _SuggestionDetailsScreenState extends State<SuggestionDetailsScreen> {
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
      appBar: const WarehouseAppBar(title: 'PICKING', showBackButton: true),
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
                    'PRODUCT ID',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary.withValues(alpha: 0.7),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.productId,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      letterSpacing: -1,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quantity Selector
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'QUANTITY TO PICK',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                              child: Column(
                                children: [
                                  Text(
                                    _quantity.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'UNITS',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
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
                                      blurRadius: 12,
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
                  // Location Details
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
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
                                'FROM LOCATION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.6,
                                  ),
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.fromLocation,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                  color: AppColors.textMain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
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
                                'TO DESTINATION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.6,
                                  ),
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.toLocation,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                  color: AppColors.textMain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Warehouse Floor Map
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'FLOOR MAP',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: Colors.grey.shade500.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 12,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Level 01',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 8-column Grid
                        _FloorMapGrid(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'CURRENT TARGET',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade600.withValues(
                                  alpha: 0.8,
                                ),
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
          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              border: Border(
                top: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OVERRIDE'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        elevation: 8,
                        shadowColor: AppColors.primary.withValues(alpha: 0.2),
                      ),
                      child: const Text('VALIDATE'),
                    ),
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

/// 8-column grid schematic of the warehouse floor
class _FloorMapGrid extends StatelessWidget {
  // Special cells
  static const _targetCell = '1-3'; // Highlighted target
  static const _highlightedCells = {'0-3', '1-1'};
  static const _dashedCell = '2-2';

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 32, // 4 rows x 8 cols
      itemBuilder: (context, index) {
        final row = index ~/ 8;
        final col = index % 8;
        final key = '$row-$col';

        if (key == _targetCell) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          );
        }

        if (_highlightedCells.contains(key)) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }

        if (key == _dashedCell) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}
