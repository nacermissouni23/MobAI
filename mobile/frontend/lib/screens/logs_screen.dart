import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';
import 'package:intl/intl.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  String _selectedCategory = 'All';
  String _selectedTimeRange = 'Today';

  @override
  void initState() {
    super.initState();
    context.read<LogsCubit>().loadLogs();
  }

  List<OperationLog> _filterLogs(List<OperationLog> logs) {
    var filtered = logs;

    // Category filter
    if (_selectedCategory == 'Override') {
      filtered = filtered.where((l) => l.isOverride).toList();
    } else if (_selectedCategory == 'Operation') {
      filtered = filtered.where((l) => !l.isOverride).toList();
    }

    // Time range filter
    final now = DateTime.now();
    if (_selectedTimeRange == 'Today') {
      filtered = filtered
          .where(
            (l) =>
                l.createdAt.year == now.year &&
                l.createdAt.month == now.month &&
                l.createdAt.day == now.day,
          )
          .toList();
    } else if (_selectedTimeRange == '7 days') {
      final cutoff = now.subtract(const Duration(days: 7));
      filtered = filtered.where((l) => l.createdAt.isAfter(cutoff)).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: const WarehouseAppBar(title: 'LOGS'),
      body: BlocBuilder<LogsCubit, LogsState>(
        builder: (context, state) {
          if (state is LogsLoaded) {
            final logs = _filterLogs(state.logs);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filters Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'Operation', 'Override'].map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedCategory = cat),
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? null
                                        : Border.all(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textMain,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Time range label
                      Row(
                        children: [
                          Text(
                            'TIME RANGE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary.withValues(alpha: 0.6),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Today', '7 days'].map((range) {
                          final isSelected = _selectedTimeRange == range;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: range == 'Today' ? 8 : 0,
                              ),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedTimeRange = range),
                                child: Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withValues(
                                            alpha: 0.1,
                                          )
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary.withValues(
                                              alpha: 0.2,
                                            )
                                          : AppColors.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                    ),
                                  ),
                                  child: Text(
                                    range,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textMain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                // Activity Feed Label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'ACTIVITY FEED  (${logs.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Log Entries
                Expanded(
                  child: logs.isEmpty
                      ? const Center(
                          child: Text(
                            'No logs found',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            return _LogCard(entry: logs[index]);
                          },
                        ),
                ),
              ],
            );
          }
          if (state is LogsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final OperationLog entry;
  const _LogCard({required this.entry});

  IconData _getTypeIcon() {
    if (entry.isOverride) return Icons.history_edu;
    switch (entry.type) {
      case OperationType.picking:
        return Icons.check_circle;
      case OperationType.receipt:
        return Icons.inventory_2;
      case OperationType.transfer:
        return Icons.move_up;
      case OperationType.delivery:
        return Icons.local_shipping;
      default:
        return Icons.description;
    }
  }

  String _typeLabel() {
    if (entry.isOverride) return 'OVERRIDE';
    return entry.type?.label.toUpperCase() ?? 'OPERATION';
  }

  String _buildDescription() {
    final parts = <String>[];
    if (entry.productId != null) parts.add('Product: ${entry.productId}');
    if (entry.quantity > 0) parts.add('Qty: ${entry.quantity}');
    if (entry.storageFloor != null) {
      parts.add(
        'Location: F${entry.storageFloor}-R${entry.storageRow}-C${entry.storageCol}',
      );
    }
    if (entry.overrideReason != null) {
      parts.add('Reason: ${entry.overrideReason}');
    }
    return parts.isEmpty ? 'Operation ${entry.operationId}' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(entry.createdAt);
    final dateStr = DateFormat('MMM dd').format(entry.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTypeIcon(),
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMain.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: entry.isOverride
                        ? Colors.orange.shade50
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: entry.isOverride
                          ? Colors.orange.shade200
                          : AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    _typeLabel(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: entry.isOverride
                          ? Colors.orange.shade700
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Body
            if (entry.employeeId != null)
              Text(
                'Employee: ${entry.employeeId}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              _buildDescription(),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMain.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            // Reference
            Row(
              children: [
                Text(
                  'Operation:',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMain.withValues(alpha: 0.4),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.operationId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
