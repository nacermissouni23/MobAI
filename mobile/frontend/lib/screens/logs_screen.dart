import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/data/mock_data.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  String _selectedCategory = 'All';
  String _selectedTimeRange = 'Today';

  @override
  Widget build(BuildContext context) {
    final logs = MockData.logs;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: const WarehouseAppBar(title: 'LOGS'),
      body: Column(
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
                    children: ['All', 'Stock', 'Operation'].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : AppColors.primary.withValues(alpha: 0.1),
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
              'ACTIVITY FEED',
              style: TextStyle(
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: logs.length,
              itemBuilder: (context, index) => _LogCard(entry: logs[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final LogEntry entry;
  const _LogCard({required this.entry});

  IconData _getCategoryIcon() {
    switch (entry.category.toLowerCase()) {
      case 'override':
        return Icons.history_edu;
      case 'picking':
        return Icons.check_circle;
      case 'stock':
        return Icons.inventory_2;
      case 'relocation':
        return Icons.move_up;
      default:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        _getCategoryIcon(),
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.time,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          entry.timeAgo,
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
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    entry.category.toUpperCase(),
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
            const SizedBox(height: 12),
            // Body
            Text(
              entry.userName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.description,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMain.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            // Reference
            if (entry.referenceId != null)
              Row(
                children: [
                  Text(
                    '${entry.referenceLabel ?? 'Ref'}:',
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
                      entry.referenceId!,
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
