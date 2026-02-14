import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import 'orders_screen.dart';
import 'operations_screen.dart';
import 'products_screen.dart';
import 'reports_screen.dart';
import 'inventory_screen.dart';
import 'users_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _drawerSelection = -1; // -1 = main nav, 0+ = drawer items

  Widget get _currentScreen {
    if (_drawerSelection == 0) return const InventoryScreen();
    if (_drawerSelection == 1) return const UsersScreen();
    return _mainScreens[_currentIndex];
  }

  String get _currentTitle {
    if (_drawerSelection == 0) return 'Inventory';
    if (_drawerSelection == 1) return 'User Management';
    return _labels[_currentIndex];
  }

  final _mainScreens = const [
    _DashboardTab(),
    OrdersScreen(),
    OperationsScreen(),
    ProductsScreen(),
    ReportsScreen(),
  ];

  final _labels = const [
    'Dashboard',
    'Orders',
    'Operations',
    'Products',
    'Reports',
  ];
  final _icons = const [
    Icons.dashboard_rounded,
    Icons.shopping_cart_rounded,
    Icons.precision_manufacturing_rounded,
    Icons.inventory_2_rounded,
    Icons.assessment_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Chip(
                avatar: const Icon(Icons.person, size: 18),
                label: Text(
                  user.role.toUpperCase(),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => auth.logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.warehouse_rounded, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'WarehouseAI',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (user != null)
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.grid_view_rounded),
              title: const Text('Inventory & Warehouse'),
              selected: _drawerSelection == 0,
              onTap: () {
                setState(() => _drawerSelection = 0);
                Navigator.pop(context);
              },
            ),
            if (auth.isAdmin)
              ListTile(
                leading: const Icon(Icons.people_rounded),
                title: const Text('User Management'),
                selected: _drawerSelection == 1,
                onTap: () {
                  setState(() => _drawerSelection = 1);
                  Navigator.pop(context);
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('Back to Main'),
              onTap: () {
                setState(() => _drawerSelection = -1);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _drawerSelection >= 0
          ? _currentScreen
          : IndexedStack(index: _currentIndex, children: _mainScreens),
      bottomNavigationBar: _drawerSelection >= 0
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              destinations: List.generate(
                _labels.length,
                (i) => NavigationDestination(
                  icon: Icon(_icons[i]),
                  label: _labels[i],
                ),
              ),
            ),
    );
  }
}

// ── Dashboard Tab ─────────────────────────────────────────────────

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _refresh();
    }
  }

  Future<void> _refresh() async {
    final data = context.read<DataProvider>();
    await Future.wait([
      data.loadOrders(),
      data.loadOperations(),
      data.loadProducts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final auth = context.watch<AuthProvider>();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Welcome, ${auth.user?.name ?? "User"}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          _buildStatRow(context, data),
          const SizedBox(height: 24),
          Text(
            'Recent Operations',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (data.loading)
            const Center(child: CircularProgressIndicator())
          else if (data.operations.isEmpty)
            const Card(child: ListTile(title: Text('No operations yet')))
          else
            ...data.operations
                .take(5)
                .map(
                  (op) => Card(
                    child: ListTile(
                      leading: _opIcon(op.type),
                      title: Text('${op.typeLabel} — ${op.statusLabel}'),
                      subtitle: Text(
                        'Product: ${op.productId ?? "N/A"} • Qty: ${op.quantity}',
                      ),
                      trailing: _statusChip(op.status),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, DataProvider data) {
    return Row(
      children: [
        _StatCard(
          label: 'Orders',
          value: '${data.orders.length}',
          icon: Icons.shopping_cart,
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Pending Ops',
          value: '${data.pendingOperations.length}',
          icon: Icons.pending_actions,
          color: Colors.orange,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Products',
          value: '${data.products.length}',
          icon: Icons.inventory_2,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _opIcon(String type) {
    switch (type) {
      case 'receipt':
        return const Icon(Icons.call_received, color: Colors.blue);
      case 'transfer':
        return const Icon(Icons.swap_horiz, color: Colors.purple);
      case 'picking':
        return const Icon(Icons.shopping_basket, color: Colors.orange);
      case 'delivery':
        return const Icon(Icons.local_shipping, color: Colors.green);
      default:
        return const Icon(Icons.circle);
    }
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'in_progress':
        color = Colors.blue;
        break;
      case 'validated':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(
        status.replaceAll('_', ' '),
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
