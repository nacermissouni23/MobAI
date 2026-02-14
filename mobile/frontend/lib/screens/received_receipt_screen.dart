import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/widgets/widgets.dart';

class ReceivedReceiptScreen extends StatefulWidget {
  final String productName;
  final String productId;
  final int expectedQuantity;
  final String? operationId;

  const ReceivedReceiptScreen({
    super.key,
    required this.productName,
    required this.productId,
    required this.expectedQuantity,
    this.operationId,
  });

  @override
  State<ReceivedReceiptScreen> createState() => _ReceivedReceiptScreenState();
}

class _ReceivedReceiptScreenState extends State<ReceivedReceiptScreen> {
  late int _receivedQuantity;

  @override
  void initState() {
    super.initState();
    _receivedQuantity = widget.expectedQuantity;
  }

  bool get _quantityMatches => _receivedQuantity == widget.expectedQuantity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const WarehouseAppBar(
        title: 'VERIFY RECEIPT',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name (read-only)
                  const _FieldLabel('PRODUCT NAME'),
                  const SizedBox(height: 8),
                  _ReadOnlyField(value: widget.productName),
                  const SizedBox(height: 28),

                  // Product ID (read-only)
                  const _FieldLabel('PRODUCT ID'),
                  const SizedBox(height: 8),
                  _ReadOnlyField(
                    value: widget.productId,
                    trailing: Icon(
                      Icons.qr_code_scanner,
                      color: AppColors.primary.withValues(alpha: 0.4),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Expected Quantity (read-only)
                  const _FieldLabel('EXPECTED QUANTITY'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.expectedQuantity.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'units',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Received Quantity (editable)
                  Center(
                    child: Text(
                      'RECEIVED QUANTITY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _quantityMatches
                            ? Colors.grey.shade200
                            : AppColors.warning.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Minus
                        GestureDetector(
                          onTap: () {
                            if (_receivedQuantity > 0) {
                              setState(() => _receivedQuantity--);
                            }
                          },
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                        ),
                        // Value
                        Expanded(
                          child: Center(
                            child: Text(
                              _receivedQuantity.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: _quantityMatches
                                    ? AppColors.textMain
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                        ),
                        // Plus
                        GestureDetector(
                          onTap: () => setState(() => _receivedQuantity++),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
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
                  ),
                  const SizedBox(height: 16),

                  // Quick Selection Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [10, 25, 50, 100].map((val) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ActionChip(
                          label: Text(
                            val.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                          backgroundColor: AppColors.surface,
                          side: BorderSide(color: Colors.grey.shade200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onPressed: () =>
                              setState(() => _receivedQuantity = val),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Mismatch warning
                  if (!_quantityMatches)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.warning,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Received quantity differs from expected '
                              '(${widget.expectedQuantity}). '
                              'Difference: ${(_receivedQuantity - widget.expectedQuantity).abs()}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
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

          // Validate Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () {
                      // If we have an operationId, validate via cubit
                      if (widget.operationId != null) {
                        final authState = context.read<AuthCubit>().state;
                        String? validatorId;
                        if (authState is AuthAuthenticated) {
                          validatorId = authState.user.id;
                        }

                        final discrepancy =
                            _receivedQuantity - widget.expectedQuantity;

                        context.read<OperationsCubit>().validateReceipt(
                          operationId: widget.operationId!,
                          actualQuantity: _receivedQuantity,
                          productId: widget.productId,
                          validatorId: validatorId,
                          discrepancy: discrepancy != 0 ? discrepancy : null,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _quantityMatches
                                  ? 'Receipt validated, transfer created'
                                  : 'Receipt validated with discrepancy',
                            ),
                          ),
                        );
                      }

                      Navigator.of(context).pop({
                        'productName': widget.productName,
                        'productId': widget.productId,
                        'expectedQuantity': widget.expectedQuantity,
                        'receivedQuantity': _receivedQuantity,
                        'matched': _quantityMatches,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _quantityMatches
                          ? AppColors.primary
                          : AppColors.warning,
                      elevation: 8,
                      shadowColor:
                          (_quantityMatches
                                  ? AppColors.primary
                                  : AppColors.warning)
                              .withValues(alpha: 0.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _quantityMatches ? 'VALIDATE' : 'CONFIRM MISMATCH',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _quantityMatches
                              ? Icons.check_circle
                              : Icons.warning_amber_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Read-only field widget ──────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  final String value;
  final Widget? trailing;

  const _ReadOnlyField({required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain.withValues(alpha: 0.8),
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Field label ─────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
