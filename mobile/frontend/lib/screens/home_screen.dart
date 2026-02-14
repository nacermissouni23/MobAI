import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data for metrics
    context.read<UsersCubit>().loadUsers();
    context.read<OrdersCubit>().loadOrders();
    context.read<ReportsCubit>().loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: const WarehouseAppBar(title: 'HOME'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Metrics Row
                BlocBuilder<UsersCubit, UsersState>(
                  builder: (context, state) {
                    final totalUsers = state is UsersLoaded
                        ? state.users.length
                        : 0;
                    final activeUsers = state is UsersLoaded
                        ? state.users.where((u) => u.isActive).length
                        : 0;
                    return Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.group,
                            value: '$totalUsers',
                            label: 'Total Users',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.person_outline,
                            value: '$activeUsers',
                            label: 'Active Users',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                // AI Performance Section
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'AI PERFORMANCE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.slate400,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                BlocBuilder<OrdersCubit, OrdersState>(
                  builder: (context, state) {
                    int totalOrders = 0;
                    int validatedOrders = 0;
                    if (state is OrdersLoaded) {
                      totalOrders = state.orders.length;
                      validatedOrders = state.orders
                          .where(
                            (o) =>
                                o.status == OrderStatus.validated ||
                                o.status == OrderStatus.completed,
                          )
                          .length;
                    }
                    final accuracy = totalOrders > 0
                        ? ((validatedOrders / totalOrders) * 100).round()
                        : 0;
                    final pendingCount = state is OrdersLoaded
                        ? state.orders
                              .where(
                                (o) =>
                                    o.status == OrderStatus.pending ||
                                    o.status == OrderStatus.aiGenerated,
                              )
                              .length
                        : 0;
                    return Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.gps_fixed,
                            value: '$accuracy%',
                            label: 'AI Accuracy',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.lightbulb_outline,
                            value: '$pendingCount',
                            label: 'Pending Suggestions',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Reports Overview
                BlocBuilder<ReportsCubit, ReportsState>(
                  builder: (context, state) {
                    final anomalyCount = state is ReportsLoaded
                        ? state.reports.where((r) => r.hasAnomaly).length
                        : 0;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slateLight),
                        color: AppColors.surface,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: anomalyCount > 0
                                  ? Colors.orange.withValues(alpha: 0.1)
                                  : Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              anomalyCount > 0
                                  ? Icons.warning_amber
                                  : Icons.check_circle_outline,
                              color: anomalyCount > 0
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ANOMALY REPORTS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slate400,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  anomalyCount > 0
                                      ? '$anomalyCount anomalies detected'
                                      : 'All systems nominal',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slate700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Bottom Actions
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                border: Border(top: BorderSide(color: AppColors.slateLight)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/new-receipt'),
                      icon: const Icon(Icons.input),
                      label: const Text('NEW RECEIPT'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/new-delivery');
                      },
                      icon: const Icon(Icons.local_shipping),
                      label: const Text('NEW DELIVERY'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slateLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.slate500,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
