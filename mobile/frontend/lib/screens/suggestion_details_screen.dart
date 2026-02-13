import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

/// Suggestion Detail screen with product info, override + refuse options.
class SuggestionDetailsScreen extends StatefulWidget {
  final Suggestion? suggestion;

  const SuggestionDetailsScreen({super.key, this.suggestion});

  @override
  State<SuggestionDetailsScreen> createState() =>
      _SuggestionDetailsScreenState();
}

class _SuggestionDetailsScreenState extends State<SuggestionDetailsScreen> {
  late Suggestion _suggestion;
  late int _quantity;
  late TextEditingController _fromController;
  late TextEditingController _toController;
  late TextEditingController _justificationController;
  bool _isOverriding = false;

  @override
  void initState() {
    super.initState();
    _suggestion =
        widget.suggestion ??
        const Suggestion(
          id: 'SG000',
          productId: 'P-55219',
          fromLocation: 'B7-N1-C7',
          toLocation: 'B7-0A-01-03',
          status: SuggestionStatus.ready,
          type: SuggestionType.picking,
          quantity: 15,
        );
    _quantity = _suggestion.quantity;
    _fromController = TextEditingController(text: _suggestion.fromLocation);
    _toController = TextEditingController(text: _suggestion.toLocation);
    _justificationController = TextEditingController();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _justificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: WarehouseAppBar(
        title: _suggestion.typeLabel,
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Type + Status header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _suggestion.typeLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      _StatusBadge(status: _suggestion.status),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Product Identification
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
                    _suggestion.productId,
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
                          'QUANTITY',
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
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.remove,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Center(
                                child: Text(
                                  _quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _quantity++),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Location Details (editable in override mode)
                  Row(
                    children: [
                      Expanded(
                        child: _isOverriding
                            ? _editableLocationField(
                                'FROM LOCATION',
                                _fromController,
                              )
                            : _locationCard(
                                'FROM LOCATION',
                                _suggestion.effectiveFrom,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _isOverriding
                            ? _editableLocationField(
                                'TO DESTINATION',
                                _toController,
                              )
                            : _locationCard(
                                'TO DESTINATION',
                                _suggestion.effectiveTo,
                              ),
                      ),
                    ],
                  ),
                  // Override mode - justification field
                  if (_isOverriding) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.edit_note,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'OVERRIDE JUSTIFICATION',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange.shade700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _justificationController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText:
                                  'Explain why you are overriding the AI suggestion...',
                              hintStyle: TextStyle(
                                color: Colors.orange.shade200,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Override-already indicator
                  if (_suggestion.isOverridden)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This suggestion was overridden. Reason: ${_suggestion.overrideJustification ?? "N/A"}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade800,
                              ),
                            ),
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
            child: _isOverriding
                ? Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _isOverriding = false),
                            child: const Text('CANCEL'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context
                                  .read<SuggestionsCubit>()
                                  .overrideSuggestion(
                                    id: _suggestion.id,
                                    justification:
                                        _justificationController.text,
                                    newFromLocation: _fromController.text,
                                    newToLocation: _toController.text,
                                  );
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                            ),
                            icon: const Icon(Icons.check),
                            label: const Text('CONFIRM OVERRIDE'),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      // Refuse button
                      SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Refuse Suggestion'),
                                content: const Text(
                                  'Are you sure you want to refuse this AI suggestion?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<SuggestionsCubit>()
                                          .refuseSuggestion(_suggestion.id);
                                      Navigator.pop(ctx);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Refuse',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text(
                            'REFUSE',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Override button
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () =>
                                setState(() => _isOverriding = true),
                            child: const Text('OVERRIDE'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Validate button
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              elevation: 8,
                              shadowColor: AppColors.primary.withValues(
                                alpha: 0.2,
                              ),
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

  Widget _locationCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary.withValues(alpha: 0.6),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableLocationField(
    String label,
    TextEditingController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.orange.shade700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SuggestionStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case SuggestionStatus.ready:
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        icon = Icons.check_circle;
        break;
      case SuggestionStatus.urgent:
        bgColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        icon = Icons.warning;
        break;
      case SuggestionStatus.pending:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade500;
        icon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status == SuggestionStatus.ready
                ? 'READY'
                : status == SuggestionStatus.urgent
                ? 'URGENT'
                : 'PENDING',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
