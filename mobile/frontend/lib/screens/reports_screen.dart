import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/data/mock_data.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedFilter = '7 Days';

  List<Report> get _filteredReports {
    final reports = MockData.reports;
    if (_selectedFilter == '7 Days') return reports.take(4).toList();
    if (_selectedFilter == '30 Days') return reports.take(7).toList();
    return reports;
  }

  @override
  Widget build(BuildContext context) {
    final reports = _filteredReports;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: const WarehouseAppBar(title: 'REPORTS'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: ['All', '7 Days', '30 Days'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Section Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT ACTIVITY',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.textMain.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // Report List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: reports.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final report = reports[index];
                return _ReportItem(report: report);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportItem extends StatelessWidget {
  final Report report;
  const _ReportItem({required this.report});

  IconData _getIcon() {
    switch (report.iconName) {
      case 'assignment_turned_in':
        return Icons.assignment_turned_in;
      case 'inventory_2':
        return Icons.inventory_2;
      case 'description':
        return Icons.description;
      case 'report_problem':
        return Icons.report_problem;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'monitoring':
        return Icons.monitor;
      default:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(report.date);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: report.isHighlighted
            ? const Border(left: BorderSide(color: AppColors.primary, width: 4))
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: report.isHighlighted
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIcon(),
            color: report.isHighlighted
                ? AppColors.primary
                : Colors.grey.shade500,
          ),
        ),
        title: Text(
          report.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          dateStr,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: () {},
      ),
    );
  }
}
