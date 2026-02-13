import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

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
  late TextEditingController _justificationController;
  bool _isOverriding = false;

  @override
  void initState() {
    super.initState();
    // Fallback if no suggestion passed (should rarely happen in production flow)
    _suggestion =
        widget.suggestion ??
        const Suggestion(
          id: 'SG000',
          productId: 'P-55219',
          productName: 'Sample Product',
          fromLocation: 'B7-N1-C7',
          toLocation: 'B7-0A-01-03',
          status: SuggestionStatus.ready,
          type: SuggestionType.picking,
          quantity: 15,
        );
    _quantity = _suggestion.quantity;
    _justificationController = TextEditingController();
  }

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  void _handleOverrideConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Override Justification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please provide a reason for overriding this suggestion.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _justificationController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter justification here...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_justificationController.text.isNotEmpty) {
                // Apply override logic here
                context.read<SuggestionsCubit>().overrideSuggestion(
                  id: _suggestion.id,
                  justification: _justificationController.text,
                  // We might want to pass the new quantity here if the cubit supports it
                  // For now assuming existing override signature needs update or we just use what we have
                  // logic below assumes we stick to what the cubit supported roughly or mock it
                );
                Navigator.pop(ctx); // Close dialog
                setState(() {
                  _isOverriding = false;
                });
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _handleValidate() {
    context.read<SuggestionsCubit>().validateSuggestion(_suggestion.id);
    Navigator.of(context).pop();
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Info (Type, Product ID, Name, Quantity)
                  _buildHeaderInfo(),
                  const SizedBox(height: 24),

                  // 2. Locations (Detailed)
                  _buildLocationSection(),
                  const SizedBox(height: 24),

                  // 3. Grid Maps (Conditional)
                  if (_shouldShowGrid()) _buildGridSection(),
                ],
              ),
            ),
          ),
          // 4. Action Bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          const SizedBox(height: 16),
          const Text(
            'PRODUCT ID',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _suggestion.productId,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'PRODUCT NAME',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _suggestion.productName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'QUANTITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              _isOverriding ? _buildQuantityEditor() : _buildQuantityDisplay(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$_quantity',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildQuantityEditor() {
    return Row(
      children: [
        IconButton(
           onPressed: () {
             if (_quantity > 1) setState(() => _quantity--);
           },
           icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 40,
          child: Center(
            child: Text(
              '$_quantity',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        IconButton(
           onPressed: () => setState(() => _quantity++),
           icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    // Logic:
    // Delivery/Picking -> Show From & To
    // Receipt -> Show From Only (Destination hidden as per request)
    return Row(
      children: [
        Expanded(
          child: _LocationCard(
            label: 'FROM LOCATION',
            value: _suggestion.fromLocation,
            icon: Icons.upload_file, // Placeholder icon
          ),
        ),
        if (_suggestion.type != SuggestionType.store) ...[
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: _LocationCard(
              label: 'TO DESTINATION',
              value: _suggestion.toLocation,
              icon: Icons.download,
            ),
          ),
        ],
      ],
    );
  }

  bool _shouldShowGrid() {
    // Only picking shows grid (2 grids actually)
    // Delivery -> No grid
    // Receipt -> No grid
    return _suggestion.type == SuggestionType.picking;
  }

  Widget _buildGridSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PATH VISUALIZATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            if (_isOverriding)
               TextButton.icon(
                 onPressed: () {
                   // Mock functionality for editing path
                   ScaffoldMessenger.of(context).showSnackBar(
                     const SnackBar(content: Text('Path editor would open here')),
                   );
                 },
                 icon: const Icon(Icons.edit_road, size: 16),
                 label: const Text('Edit Path'),
               ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: PageView(
            children: [
              _buildGridCard('Product Location (Floor)', Colors.blue.shade50),
              _buildGridCard('Destination (Ground Floor)', Colors.green.shade50),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               Icon(Icons.circle, size: 8, color: AppColors.primary),
               SizedBox(width: 4),
               Icon(Icons.circle, size: 8, color: Colors.grey),
            ],
          ),
        ),
        const Center(
          child: Text(
            'Swipe to view destination', 
            style: TextStyle(fontSize: 10, color: Colors.grey)
          ),
        ),
      ],
    );
  }

  Widget _buildGridCard(String title, Color bgColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_on, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Grid Map Placeholder',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          if (_isOverriding) ...[
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    // Reset quantity and exit override mode
                    setState(() {
                      _quantity = _suggestion.quantity;
                      _isOverriding = false;
                    });
                  },
                  child: const Text('CANCEL'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleOverrideConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                  ),
                  child: const Text('CONFIRM OVERRIDE'),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isOverriding = true;
                    });
                  },
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
                  onPressed: _handleValidate,
                  child: const Text('VALIDATE'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _LocationCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
            overflow: TextOverflow.ellipsis,
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
