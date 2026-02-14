import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/emplacement.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    Future.microtask(() {
      final data = context.read<DataProvider>();
      data.loadEmplacements();
      data.loadStockSummary();
      data.loadChariots();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Warehouse'),
            Tab(text: 'Stock'),
            Tab(text: 'Chariots'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: const [_WarehouseTab(), _StockTab(), _ChariotsTab()],
          ),
        ),
      ],
    );
  }
}

// ── Warehouse Tab ──────────────────────────────────────────────

class _WarehouseTab extends StatefulWidget {
  const _WarehouseTab();

  @override
  State<_WarehouseTab> createState() => _WarehouseTabState();
}

class _WarehouseTabState extends State<_WarehouseTab> {
  String _filter = 'all'; // all, slots, occupied, available, expedition

  Future<void> _refresh() => context.read<DataProvider>().loadEmplacements();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final auth = context.watch<AuthProvider>();

    var filtered = data.emplacements;
    switch (_filter) {
      case 'slots':
        filtered = filtered.where((e) => e.isSlot).toList();
        break;
      case 'occupied':
        filtered = filtered.where((e) => e.isSlot && e.isOccupied).toList();
        break;
      case 'available':
        filtered = filtered.where((e) => e.isSlot && !e.isOccupied).toList();
        break;
      case 'expedition':
        filtered = filtered.where((e) => e.isExpedition).toList();
        break;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip('All', 'all'),
                const SizedBox(width: 6),
                _chip('Slots', 'slots'),
                const SizedBox(width: 6),
                _chip('Occupied', 'occupied'),
                const SizedBox(width: 6),
                _chip('Available', 'available'),
                const SizedBox(width: 6),
                _chip('Expedition', 'expedition'),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${filtered.length} locations',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              if (auth.isSupervisor)
                TextButton.icon(
                  onPressed: () => _showCreateDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
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
                                child: Text('No locations found'),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (ctx, i) =>
                              _EmplacementCard(emplacement: filtered[i]),
                        ),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final xCtrl = TextEditingController();
    final yCtrl = TextEditingController();
    final zCtrl = TextEditingController();
    final floorCtrl = TextEditingController(text: '0');
    bool isSlot = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Location'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: xCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'X',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: yCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Y',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: zCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Z',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: floorCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Floor',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Is Storage Slot'),
                  value: isSlot,
                  onChanged: (v) => setDialogState(() => isSlot = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final data = context.read<DataProvider>();
                final ok = await data.createEmplacement({
                  'x': int.tryParse(xCtrl.text) ?? 0,
                  'y': int.tryParse(yCtrl.text) ?? 0,
                  'z': int.tryParse(zCtrl.text) ?? 0,
                  'floor': int.tryParse(floorCtrl.text) ?? 0,
                  'is_slot': isSlot,
                  'is_obstacle': false,
                  'is_elevator': false,
                  'is_road': !isSlot,
                  'is_expedition': false,
                });
                if (ctx.mounted) Navigator.pop(ctx);
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location created')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmplacementCard extends StatelessWidget {
  final Emplacement emplacement;

  const _EmplacementCard({required this.emplacement});

  Color get _typeColor {
    if (emplacement.isExpedition) return Colors.purple;
    if (emplacement.isElevator) return Colors.teal;
    if (emplacement.isSlot && emplacement.isOccupied) return Colors.orange;
    if (emplacement.isSlot) return Colors.green;
    if (emplacement.isObstacle) return Colors.red;
    return Colors.grey;
  }

  IconData get _typeIcon {
    if (emplacement.isExpedition) return Icons.local_shipping;
    if (emplacement.isElevator) return Icons.elevator;
    if (emplacement.isSlot) return Icons.inventory;
    if (emplacement.isObstacle) return Icons.block;
    if (emplacement.isRoad) return Icons.route;
    return Icons.grid_view;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _typeColor.withValues(alpha: 0.2),
          child: Icon(_typeIcon, color: _typeColor, size: 20),
        ),
        title: Text(
          emplacement.coordinateLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(emplacement.typeLabel),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (emplacement.isSlot)
              Text(
                emplacement.isOccupied ? 'Occupied' : 'Empty',
                style: TextStyle(
                  fontSize: 11,
                  color: emplacement.isOccupied ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (emplacement.quantity > 0)
              Text(
                'Qty: ${emplacement.quantity}',
                style: const TextStyle(fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Stock Summary Tab ──────────────────────────────────────────

class _StockTab extends StatefulWidget {
  const _StockTab();

  @override
  State<_StockTab> createState() => _StockTabState();
}

class _StockTabState extends State<_StockTab> {
  Future<void> _refresh() => context.read<DataProvider>().loadStockSummary();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: data.loading
          ? const Center(child: CircularProgressIndicator())
          : data.stockSummary.isEmpty
          ? ListView(
              children: const [
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('No stock data'),
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: data.stockSummary.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (ctx, i) {
                final item = data.stockSummary[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
                    title: Text(
                      item['product_id']?.toString() ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Locations: ${item['locations'] ?? 0}'),
                    trailing: Text(
                      'Total: ${item['total_quantity'] ?? 0}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ── Chariots Tab ───────────────────────────────────────────────

class _ChariotsTab extends StatefulWidget {
  const _ChariotsTab();

  @override
  State<_ChariotsTab> createState() => _ChariotsTabState();
}

class _ChariotsTabState extends State<_ChariotsTab> {
  Future<void> _refresh() => context.read<DataProvider>().loadChariots();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final auth = context.watch<AuthProvider>();

    return Column(
      children: [
        if (auth.isSupervisor)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '${data.chariots.length} Chariots',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _showCreateDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
        Expanded(
          child: data.loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: data.chariots.isEmpty
                      ? ListView(
                          children: const [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text('No chariots found'),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: data.chariots.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (ctx, i) {
                            final c = data.chariots[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: c.isAvailable
                                      ? Colors.green.shade50
                                      : Colors.orange.shade50,
                                  child: Icon(
                                    Icons.local_shipping,
                                    color: c.isAvailable
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  'Chariot ${c.id.substring(0, 8)}...',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: c.assignedToOperationId != null
                                    ? Text(
                                        'Assigned to: ${c.assignedToOperationId!.substring(0, 8)}...',
                                      )
                                    : null,
                                trailing: Chip(
                                  label: Text(
                                    c.statusLabel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: c.isAvailable
                                      ? Colors.green
                                      : c.isActive
                                      ? Colors.orange
                                      : Colors.grey,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Chariot'),
        content: const Text('Create a new chariot for warehouse operations?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final data = context.read<DataProvider>();
              final ok = await data.createChariot({'is_active': true});
              if (ctx.mounted) Navigator.pop(ctx);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chariot created')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
