import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/widgets/widgets.dart';

class AddSkuScreen extends StatefulWidget {
  const AddSkuScreen({super.key});

  @override
  State<AddSkuScreen> createState() => _AddSkuScreenState();
}

class _AddSkuScreenState extends State<AddSkuScreen> {
  final _nameController = TextEditingController();
  final _skuIdController = TextEditingController();
  int _quantity = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _skuIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const WarehouseAppBar(title: 'Add SKU', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  _FieldLabel('PRODUCT NAME'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration('Enter product name'),
                  ),
                  const SizedBox(height: 32),
                  // SKU ID
                  _FieldLabel('SKU ID'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _skuIdController,
                    style: const TextStyle(fontFamily: 'monospace'),
                    decoration: _inputDecoration('Enter SKU ID (e.g. SKU-001)'),
                  ),
                  const SizedBox(height: 32),
                  // Quantity
                  _FieldLabel('QUANTITY'),
                  const SizedBox(height: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _quantity.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _quantity++),
                              child: Icon(
                                Icons.expand_less,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_quantity > 0) setState(() => _quantity--);
                              },
                              child: Icon(
                                Icons.expand_more,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Cancel
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('CANCEL'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Save button
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
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_nameController.text.isNotEmpty &&
                      _skuIdController.text.isNotEmpty) {
                    context.read<SkusCubit>().addSku(
                      name: _nameController.text,
                      skuCode: _skuIdController.text,
                      quantity: _quantity,
                    );
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('SAVE'),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
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
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 0.5,
      ),
    );
  }
}
