import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/operation.dart';

class OperationsScreen extends StatefulWidget {
  const OperationsScreen({super.key});

  @override
  State<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends State<OperationsScreen> {
  String _statusFilter = 'all';
  String _typeFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DataProvider>().loadOperations());
  }

  Future<void> _refresh() => context.read<DataProvider>().loadOperations();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final auth = context.watch<AuthProvider>();
    final isSupervisor = auth.isSupervisor;

    var filtered = data.operations;
    if (_statusFilter != 'all') {
      filtered = filtered.where((o) => o.status == _statusFilter).toList();
    }
    if (_typeFilter != 'all') {
      filtered = filtered.where((o) => o.type == _typeFilter).toList();
    }

    return Column(
      children: [
        // Type filter row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip('All Types', 'all', isType: true),
                const SizedBox(width: 6),
                _chip('Receipt', 'receipt', isType: true),
                const SizedBox(width: 6),
                _chip('Transfer', 'transfer', isType: true),
                const SizedBox(width: 6),
                _chip('Picking', 'picking', isType: true),
                const SizedBox(width: 6),
                _chip('Delivery', 'delivery', isType: true),
              ],
            ),
          ),
        ),
        // Status filter row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              _chip('All', 'all', isType: false),
              const SizedBox(width: 6),
              _chip('Pending', 'pending', isType: false),
              const SizedBox(width: 6),
              _chip('In Progress', 'in_progress', isType: false),
              const SizedBox(width: 6),
              _chip('Validated', 'validated', isType: false),
            ],
          ),
        ),
        const Divider(height: 1),
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
                                child: Text('No operations found'),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (ctx, i) => _OperationCard(
                            operation: filtered[i],
                            isSupervisor: isSupervisor,
                          ),
                        ),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value, {required bool isType}) {
    final selected = isType ? _typeFilter == value : _statusFilter == value;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) {
        setState(() {
          if (isType) {
            _typeFilter = value;
          } else {
            _statusFilter = value;
          }
        });
      },
    );
  }
}

class _OperationCard extends StatelessWidget {
  final Operation operation;
  final bool isSupervisor;

  const _OperationCard({required this.operation, required this.isSupervisor});

  IconData _typeIcon(String type) {
    switch (type) {
      case 'receipt':
        return Icons.archive;
      case 'transfer':
        return Icons.swap_horiz;
      case 'picking':
        return Icons.shopping_basket;
      case 'delivery':
        return Icons.local_shipping;
      default:
        return Icons.work;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'receipt':
        return Colors.green;
      case 'transfer':
        return Colors.blue;
      case 'picking':
        return Colors.orange;
      case 'delivery':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'validated':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _typeColor(operation.type).withValues(alpha: 0.2),
          child: Icon(
            _typeIcon(operation.type),
            color: _typeColor(operation.type),
          ),
        ),
        title: Text(
          operation.typeLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Qty: ${operation.quantity} • ${operation.id.substring(0, 8)}...',
        ),
        trailing: _statusChip(operation.status),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (operation.productId != null)
                  _detail('Product', operation.productId!),
                if (operation.employeeId != null)
                  _detail('Employee', operation.employeeId!),
                if (operation.chariotId != null)
                  _detail('Chariot', operation.chariotId!),
                if (operation.emplacementId != null)
                  _detail('Emplacement', operation.emplacementId!),
                if (operation.sourceEmplacementId != null)
                  _detail('Source', operation.sourceEmplacementId!),
                if (operation.orderId != null)
                  _detail('Order', operation.orderId!),
                if (operation.suggestedRoute != null &&
                    operation.suggestedRoute!.isNotEmpty)
                  _detail('Route', operation.suggestedRoute!.join(' → ')),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isSupervisor && operation.isPending)
                      FilledButton.icon(
                        onPressed: () => _approve(context),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Approve'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    if (operation.isInProgress) ...[
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => _validate(context),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Validate'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    return Chip(
      label: Text(
        operation.statusLabel,
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: _statusColor(status),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Future<void> _approve(BuildContext context) async {
    final data = context.read<DataProvider>();
    final ok = await data.approveOperation(operation.id);
    if (ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Operation approved')));
    }
  }

  Future<void> _validate(BuildContext context) async {
    final data = context.read<DataProvider>();
    final ok = await data.validateOperation(operation.id);
    if (ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Operation validated')));
    }
  }
}
