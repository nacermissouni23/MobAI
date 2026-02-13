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
  late TextEditingController _quantityController;
  late TextEditingController _uniteController;
  late TextEditingController _categorieController;
  late TextEditingController _colisageFardeauController;
  late TextEditingController _colisagePaletteController;
  late TextEditingController _volumeController;
  late TextEditingController _poidsController;
  late bool _actif;
  late bool _isGerbable;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sku.name);
    _codeController = TextEditingController(text: widget.sku.skuCode);
    _quantityController = TextEditingController(
      text: widget.sku.quantity.toString(),
    );
    _uniteController = TextEditingController(text: '');
    _categorieController = TextEditingController(
      text: widget.sku.category ?? '',
    );
    _colisageFardeauController = TextEditingController(text: '');
    _colisagePaletteController = TextEditingController(text: '');
    _volumeController = TextEditingController(text: '');
    _poidsController = TextEditingController(
      text: widget.sku.weight.toString(),
    );
    _actif = true;
    _isGerbable = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
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
                  // Product Name
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
                            final current =
                                int.tryParse(_quantityController.text) ?? 0;
                            if (current > 0) {
                              setState(() {
                                _quantityController.text = (current - 1)
                                    .toString();
                              });
                            }
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: TextField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMain,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                hintText: '0',
                                hintStyle: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final current =
                                int.tryParse(_quantityController.text) ?? 0;
                            setState(() {
                              _quantityController.text = (current + 1)
                                  .toString();
                            });
                          },
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
                  // Unité de Mesure
                  _label('UNITÉ DE MESURE'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _uniteController,
                    decoration: _inputDecoration('e.g. Pcs, Kg, L'),
                  ),
                  const SizedBox(height: 20),
                  // Catégorie
                  _label('CATÉGORIE'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _categorieController,
                    decoration: _inputDecoration('Enter category'),
                  ),
                  const SizedBox(height: 20),
                  // Colisage Fardeau + Colisage Palette row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('COLISAGE FARDEAU'),
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
                            _label('COLISAGE PALETTE'),
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
                  const SizedBox(height: 20),
                  // Volume + Poids row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('VOLUME (M³)'),
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
                            _label('POIDS (KG)'),
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
                  const SizedBox(height: 20),
                  // Actif & Is Gerbable row
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
          // Bottom Actions
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
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final confirmed = await showConfirmDialog(
                              context,
                              title: 'Delete SKU',
                              message:
                                  'Are you sure you want to delete ${widget.sku.name}? This action cannot be undone.',
                              confirmLabel: 'DELETE',
                              isDestructive: true,
                            );
                            if (confirmed && context.mounted) {
                              context.read<SkusCubit>().deleteSku(
                                widget.sku.id,
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('DELETE'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(
                              color: Colors.red.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<SkusCubit>().updateSku(
                              widget.sku.copyWith(
                                name: _nameController.text,
                                skuCode: _codeController.text,
                                quantity:
                                    int.tryParse(_quantityController.text) ?? 0,
                                category: _categorieController.text,
                                weight:
                                    double.tryParse(_poidsController.text) ??
                                    widget.sku.weight,
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
