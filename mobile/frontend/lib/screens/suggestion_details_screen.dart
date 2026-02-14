import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

class SuggestionDetailsScreen extends StatefulWidget {
  final Order? suggestion;

  const SuggestionDetailsScreen({super.key, this.suggestion});

  @override
  State<SuggestionDetailsScreen> createState() =>
      _SuggestionDetailsScreenState();
}

class _SuggestionDetailsScreenState extends State<SuggestionDetailsScreen> {
  late Order _order;
  late int _quantity;
  late TextEditingController _justificationController;
  late TextEditingController _altFloorController;
  late TextEditingController _altRowController;
  late TextEditingController _altColController;
  bool _isOverriding = false;

  @override
  void initState() {
    super.initState();
    _order =
        widget.suggestion ??
        Order(
          id: 'SG000',
          type: OrderType.picking,
          status: OrderStatus.pending,
          lines: const [
            OrderLine(
              productId: 'P-55219',
              productName: 'Sample Product',
              quantity: 15,
              sourceFloor: 0,
              sourceX: 7,
              sourceY: 1,
              destinationFloor: 0,
              destinationX: 1,
              destinationY: 3,
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
    _quantity = _order.quantity;
    _justificationController = TextEditingController();
    _altFloorController = TextEditingController();
    _altRowController = TextEditingController();
    _altColController = TextEditingController();
  }

  @override
  void dispose() {
    _justificationController.dispose();
    _altFloorController.dispose();
    _altRowController.dispose();
    _altColController.dispose();
    super.dispose();
  }

  void _handleOverrideConfirm() {
    final currentUser = context.read<AuthCubit>().currentUser;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Override Justification'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please provide a reason and alternate location.'),
              const SizedBox(height: 16),
              TextField(
                controller: _justificationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter justification here...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ALTERNATE LOCATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _altFloorController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Floor',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _altRowController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Row',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _altColController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Col',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_justificationController.text.isNotEmpty) {
                final altLocation = _altFloorController.text.isNotEmpty
                    ? 'F${_altFloorController.text}-R${_altRowController.text}-C${_altColController.text}'
                    : null;
                final reason = altLocation != null
                    ? '${_justificationController.text} [Alt: $altLocation]'
                    : _justificationController.text;
                context.read<OrdersCubit>().overrideOrder(
                  orderId: _order.id,
                  overriddenBy: currentUser?.id ?? 'unknown',
                  reason: reason,
                );
                Navigator.pop(ctx);
                setState(() => _isOverriding = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Suggestion overridden successfully'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _handleValidate() {
    context.read<OrdersCubit>().validateOrder(_order.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Suggestion validated and approved'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: WarehouseAppBar(title: _order.typeLabel, showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderInfo(),
                  const SizedBox(height: 24),
                  LocationRow(
                    fromValue: _order.fromLocation,
                    toValue: _order.toLocation,
                    showTo: _order.type != OrderType.preparation,
                  ),
                  const SizedBox(height: 24),
                  if (_order.type == OrderType.picking) _buildGridSection(),
                ],
              ),
            ),
          ),
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
              TypeBadge(label: _order.typeLabel),
              OrderStatusBadge(status: _order.status),
            ],
          ),
          const SizedBox(height: 16),
          const SectionLabel('Product ID'),
          const SizedBox(height: 4),
          Text(
            _order.productId,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          const SectionLabel('Product Name'),
          const SizedBox(height: 4),
          Text(
            _order.productName,
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
              const SectionLabel('Quantity'),
              _isOverriding
                  ? QuantityStepper(
                      value: _quantity,
                      onChanged: (v) => setState(() => _quantity = v),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionLabel('Path Visualization'),
            if (_isOverriding)
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Path editor would open here'),
                    ),
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
              _buildGridCard(
                'Destination (Ground Floor)',
                Colors.green.shade50,
              ),
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
            style: TextStyle(fontSize: 10, color: Colors.grey),
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
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_isOverriding) {
      return BottomActionBar.dual(
        secondaryLabel: 'CANCEL',
        onSecondary: () {
          setState(() {
            _quantity = _order.quantity;
            _isOverriding = false;
          });
        },
        primaryLabel: 'CONFIRM OVERRIDE',
        onPrimary: _handleOverrideConfirm,
        primaryColor: Colors.orange.shade600,
      );
    }
    return BottomActionBar.dual(
      secondaryLabel: 'OVERRIDE',
      onSecondary: () => setState(() => _isOverriding = true),
      primaryLabel: 'VALIDATE',
      onPrimary: _handleValidate,
    );
  }
}
