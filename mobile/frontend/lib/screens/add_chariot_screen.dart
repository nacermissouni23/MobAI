import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/widgets/widgets.dart';

class AddChariotScreen extends StatefulWidget {
  const AddChariotScreen({super.key});

  @override
  State<AddChariotScreen> createState() => _AddChariotScreenState();
}

class _AddChariotScreenState extends State<AddChariotScreen> {
  final _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const WarehouseAppBar(title: 'Add Chariot', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ADD CHARIOT',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Register a new asset to the fleet tracking system.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMain.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Chariot ID Field
                  Text(
                    'CHARIOT ID',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      hintText: 'Enter Chariot ID (e.g. CH-001)',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Decorative element
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.conveyor_belt,
                            size: 48,
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'New asset details will be synchronized\nacross the local industrial network.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textMain.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
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
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_idController.text.isNotEmpty) {
                    context.read<ChariotsCubit>().addChariot(
                      _idController.text,
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
}
