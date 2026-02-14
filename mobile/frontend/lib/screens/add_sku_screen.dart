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
  final _quantityController = TextEditingController();
  final _uniteController = TextEditingController();
  final _categorieController = TextEditingController();
  final _colisageFardeauController = TextEditingController();
  final _colisagePaletteController = TextEditingController();
  final _volumeController = TextEditingController();
  final _poidsController = TextEditingController();
  bool _actif = true;
  bool _isGerbable = false;

  @override
  void dispose() {
    _nameController.dispose();
    _skuIdController.dispose();
    _quantityController.dispose();
    _uniteController.dispose();
    _categorieController.dispose();
    _colisageFardeauController.dispose();
    _colisagePaletteController.dispose();
    _volumeController.dispose();
    _poidsController.dispose();
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
                  TextField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false,
                    ),
                    decoration: _inputDecoration('Enter quantity'),
                  ),
                  const SizedBox(height: 32),
                  // Unité de Mesure
                  _FieldLabel('UNITÉ DE MESURE'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _uniteController,
                    decoration: _inputDecoration('e.g. Pcs, Kg, L'),
                  ),
                  const SizedBox(height: 32),
                  // Catégorie
                  _FieldLabel('CATÉGORIE'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _categorieController,
                    decoration: _inputDecoration('Enter category'),
                  ),
                  const SizedBox(height: 32),
                  // Colisage Fardeau & Colisage Palette (2 columns)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('COLISAGE FARDEAU'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _colisageFardeauController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('0'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('COLISAGE PALETTE'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _colisagePaletteController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('0'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Volume & Poids (2 columns)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('VOLUME (M³)'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _volumeController,
                              keyboardType: TextInputType.number,
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
                            _FieldLabel('POIDS (KG)'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _poidsController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration('0.0'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Actif & Is Gerbable (2 columns with toggles)
                  Row(
                    children: [
                      Expanded(
                        child: _CheckboxField(
                          label: 'ACTIF',
                          value: _actif,
                          onChanged: (value) => setState(() => _actif = value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _CheckboxField(
                          label: 'GERBABLE',
                          value: _isGerbable,
                          onChanged: (value) =>
                              setState(() => _isGerbable = value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Save button
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_nameController.text.isNotEmpty &&
                          _skuIdController.text.isNotEmpty) {
                        context.read<ProductsCubit>().addProduct(
                          name: _nameController.text,
                          sku: _skuIdController.text,
                          unitOfMeasure: _uniteController.text.isNotEmpty
                              ? _uniteController.text
                              : 'pcs',
                          category: _categorieController.text.isNotEmpty
                              ? _categorieController.text
                              : null,
                          isActive: _actif,
                          isStackable: _isGerbable,
                          unitsPerBundle: int.tryParse(
                            _colisageFardeauController.text,
                          ),
                          unitsPerPallet: int.tryParse(
                            _colisagePaletteController.text,
                          ),
                          volumePerUnit: double.tryParse(
                            _volumeController.text,
                          ),
                          weight: double.tryParse(_poidsController.text),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('SAVE'),
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

class _CheckboxField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckboxField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            activeColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
