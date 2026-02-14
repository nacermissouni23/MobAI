import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/order.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _filter = 'all'; // all, pending, validated

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DataProvider>().loadOrders());
  }

  Future<void> _refresh() => context.read<DataProvider>().loadOrders(
    status: _filter == 'all' ? null : _filter,
  );

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final auth = context.watch<AuthProvider>();
    final isSupervisor = auth.isSupervisor;

    final filtered = _filter == 'all'
        ? data.orders
        : data.orders.where((o) => o.status == _filter).toList();

    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _chip('All', 'all'),
              const SizedBox(width: 8),
              _chip('Pending', 'pending'),
              const SizedBox(width: 8),
              _chip('Validated', 'validated'),
              const Spacer(),
              if (isSupervisor)
                FilledButton.icon(
                  onPressed: () => _showCreateDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New'),
                ),
            ],
          ),
        ),
        Expanded(
          child: data.loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: filtered.isEmpty
                      ? ListView(
                          children: const [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text('No orders found'),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (ctx, i) => _OrderCard(
                            order: filtered[i],
                            isSupervisor: isSupervisor,
                          ),
                        ),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _filter = value);
        _refresh();
      },
    );
  }

  void _showCreateDialog(BuildContext context) {
    final productIdCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: productIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Product ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final data = context.read<DataProvider>();
              final ok = await data.createOrder(
                productId: productIdCtrl.text.trim(),
                quantity: int.tryParse(quantityCtrl.text) ?? 0,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Order created')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final bool isSupervisor;

  const _OrderCard({required this.order, required this.isSupervisor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          order.type == 'command' ? Icons.shopping_cart : Icons.auto_awesome,
          color: order.type == 'command' ? Colors.blue : Colors.purple,
        ),
        title: Text(
          '${order.type.toUpperCase()} — ${order.id.substring(0, 8)}...',
        ),
        subtitle: Text(
          'Product: ${order.productId ?? "N/A"} • Qty: ${order.quantity}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusChip(order.status),
            if (isSupervisor && order.isPending) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'Validate',
                onPressed: () async {
                  final data = context.read<DataProvider>();
                  final ok = await data.validateOrder(order.id);
                  if (ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order validated & receipt created'),
                      ),
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = status == 'validated' ? Colors.green : Colors.orange;
    return Chip(
      label: Text(
        status,
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
