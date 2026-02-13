import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

class EditSkuScreen extends StatefulWidget {
  final Sku sku;
  const EditSkuScreen({super.key, required this.sku});

  @override
  State<EditSkuScreen> createState() => _EditSkuScreenState();
}

class _EditSkuScreenState extends State<EditSkuScreen> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _locationController;
  late TextEditingController _weightController;
  late TextEditingController _categoryController;
  late int _quantity;
  late SkuStockStatus _stockStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sku.name);
    _codeController = TextEditingController(text: widget.sku.skuCode);
    _locationController = TextEditingController(
      text: widget.sku.locationLabel ?? '',
    );
    _weightController = TextEditingController(
      text: widget.sku.weight.toString(),
    );
    _categoryController = TextEditingController(
      text: widget.sku.category ?? '',
    );
    _quantity = widget.sku.quantity;
    _stockStatus = widget.sku.stockStatus;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _locationController.dispose();
    _weightController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const WarehouseAppBar(title: 'Edit SKU', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: AppColors.primary.withValues(alpha: 0.4),
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      widget.sku.skuCode,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'monospace',
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Name
                  _label('PRODUCT NAME'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration('Enter product name'),
                  ),
                  const SizedBox(height: 20),
                  // SKU Code
                  _label('SKU CODE'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _codeController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                    decoration: _inputDecoration('SKU-XXXXX-X'),
                  ),
                  const SizedBox(height: 20),
                  // Location
                  _label('WAREHOUSE LOCATION'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                    decoration: _inputDecoration('e.g. B7-N1-C7'),
                  ),
                  const SizedBox(height: 20),
                  // Weight + Category row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('WEIGHT (kg)'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: _inputDecoration('0.0'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('CATEGORY'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _categoryController,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: _inputDecoration('Category'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Quantity
                  _label('QUANTITY'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_quantity > 0) setState(() => _quantity--);
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              _quantity.toString(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMain,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _quantity++),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stock Status
                  _label('STOCK STATUS'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<SkuStockStatus>(
                        isExpanded: true,
                        value: _stockStatus,
                        items: SkuStockStatus.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s == SkuStockStatus.inStock
                                  ? 'In Stock'
                                  : s == SkuStockStatus.lowStock
                                  ? 'Low Stock'
                                  : 'Out of Stock',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _stockStatus = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Actions
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
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                        context.read<SkusCubit>().updateSku(
                          widget.sku.copyWith(
                            name: _nameController.text,
                            skuCode: _codeController.text,
                            locationLabel: _locationController.text,
                            weight:
                                double.tryParse(_weightController.text) ??
                                widget.sku.weight,
                            category: _categoryController.text,
                            quantity: _quantity,
                            stockStatus: _stockStatus,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('SAVE'),
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

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 2,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade300),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
