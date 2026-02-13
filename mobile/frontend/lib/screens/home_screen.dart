import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.group,
                        value: '24',
                        label: 'Active Users',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.person_outline,
                        value: '8',
                        label: 'Available Users',
                      ),
                    ),
                  ],
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
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.gps_fixed,
                        value: '86%',
                        label: 'Accuracy',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _RouteMetricCard()),
                  ],
                ),
                const SizedBox(height: 24),
                // Facility Status Image
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.slateLight),
                    color: Colors.grey.shade100,
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.05),
                                  AppColors.primary.withValues(alpha: 0.15),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.warehouse_outlined,
                                size: 80,
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FACILITY STATUS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate400,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'ZONE A-14 OPTIMAL',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                        // New delivery action
                        Navigator.of(context).pushNamed('/new-receipt');
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

class _RouteMetricCard extends StatelessWidget {
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
          const Icon(Icons.route, color: AppColors.primary, size: 22),
          const SizedBox(height: 12),
          const Text(
            '120m',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'AVG PICK ROUTE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.slate500,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'vs 180m',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
