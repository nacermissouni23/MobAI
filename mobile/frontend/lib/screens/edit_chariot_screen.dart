import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

class EditChariotScreen extends StatefulWidget {
  final Chariot chariot;
  const EditChariotScreen({super.key, required this.chariot});

  @override
  State<EditChariotScreen> createState() => _EditChariotScreenState();
}

class _EditChariotScreenState extends State<EditChariotScreen> {
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _currentUserController;
  late ChariotStatus _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.chariot.name);
    _locationController = TextEditingController(
      text: widget.chariot.location ?? '',
    );
    _currentUserController = TextEditingController(
      text: widget.chariot.currentUser ?? '',
    );
    _status = widget.chariot.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _currentUserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const WarehouseAppBar(
        title: 'Edit Chariot',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'ID: ${widget.chariot.id}',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                        color: AppColors.primary.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Name
                  _label('CHARIOT NAME'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration('Enter chariot name'),
                  ),
                  const SizedBox(height: 20),
                  // Status
                  _label('STATUS'),
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
                      child: DropdownButton<ChariotStatus>(
                        isExpanded: true,
                        value: _status,
                        items: ChariotStatus.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s == ChariotStatus.available
                                  ? 'Available'
                                  : s == ChariotStatus.inUse
                                  ? 'In Use'
                                  : 'Offline',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Location
                  _label('LOCATION'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration('e.g. Zone A-12'),
                  ),
                  const SizedBox(height: 20),
                  // Current User (if in use)
                  _label('ASSIGNED USER'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _currentUserController,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration('User name (if in use)'),
                  ),
                  const SizedBox(height: 32),
                  // Delete chariot
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Chariot'),
                            content: Text(
                              'Are you sure you want to delete ${widget.chariot.name}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<ChariotsCubit>().deleteChariot(
                                    widget.chariot.id,
                                  );
                                  Navigator.pop(ctx);
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'DELETE CHARIOT',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
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
                        context.read<ChariotsCubit>().updateChariot(
                          widget.chariot.copyWith(
                            name: _nameController.text,
                            status: _status,
                            location: _locationController.text,
                            currentUser: _currentUserController.text,
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
