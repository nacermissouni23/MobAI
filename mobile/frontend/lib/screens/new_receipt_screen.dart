import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/widgets/widgets.dart';

class NewReceiptScreen extends StatefulWidget {
  const NewReceiptScreen({super.key});

  @override
  State<NewReceiptScreen> createState() => _NewReceiptScreenState();
}

class _NewReceiptScreenState extends State<NewReceiptScreen> {
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  int _quantity = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const WarehouseAppBar(title: 'NEW RECEIPT', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  _FieldLabel('PRODUCT NAME'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration('Scan or enter name'),
                  ),
                  const SizedBox(height: 32),
                  // Product ID
                  _FieldLabel('PRODUCT ID'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _idController,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration('Enter ID / SKU').copyWith(
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Quantity Selector
                  Center(
                    child: Text(
                      'QUANTITY',
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
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                    ),
                    child: Row(
                      children: [
                        // Minus
                        GestureDetector(
                          onTap: () {
                            if (_quantity > 1) setState(() => _quantity--);
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
                              _quantity.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMain,
                              ),
                            ),
                          ),
                        ),
                        // Plus
                        GestureDetector(
                          onTap: () => setState(() => _quantity++),
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
                          onPressed: () => setState(() => _quantity = val),
                        ),
                      );
                    }).toList(),
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
                      Navigator.of(context).pop();
                    },
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
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.check_circle, size: 24),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}

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
