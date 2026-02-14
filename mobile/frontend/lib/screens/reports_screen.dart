import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<ReportsCubit>().loadReports();
  }

  List<Report> _filterReports(List<Report> reports) {
    if (_selectedFilter == 'All') return reports;
    final now = DateTime.now();
    if (_selectedFilter == '7 Days') {
      final cutoff = now.subtract(const Duration(days: 7));
      return reports.where((r) => r.createdAt.isAfter(cutoff)).toList();
    }
    if (_selectedFilter == '30 Days') {
      final cutoff = now.subtract(const Duration(days: 30));
      return reports.where((r) => r.createdAt.isAfter(cutoff)).toList();
    }
    return reports;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: const WarehouseAppBar(title: 'REPORTS'),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoaded) {
            final reports = _filterReports(state.reports);
            return Column(
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
                            onTap: () =>
                                setState(() => _selectedFilter = filter),
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
                        'ANOMALY REPORTS  (${reports.length})',
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
                  child: reports.isEmpty
                      ? const Center(
                          child: Text(
                            'No reports found',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: reports.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            return _ReportItem(report: report);
                          },
                        ),
                ),
              ],
            );
          }
          if (state is ReportsError) {
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

class _ReportItem extends StatelessWidget {
  final Report report;
  const _ReportItem({required this.report});

  IconData _getIcon() {
    if (report.physicalDamage) return Icons.report_problem;
    if (report.missingQuantity > 0) return Icons.remove_circle_outline;
    if (report.extraQuantity > 0) return Icons.add_circle_outline;
    return Icons.description;
  }

  String _getTitle() {
    final parts = <String>[];
    if (report.physicalDamage) parts.add('Physical Damage');
    if (report.missingQuantity > 0)
      parts.add('Missing: ${report.missingQuantity}');
    if (report.extraQuantity > 0) parts.add('Extra: ${report.extraQuantity}');
    if (parts.isEmpty) parts.add('Report');
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'MMM dd, yyyy • hh:mm a',
    ).format(report.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: report.hasAnomaly
            ? const Border(left: BorderSide(color: Colors.orange, width: 4))
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: report.hasAnomaly
                ? Colors.orange.withValues(alpha: 0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIcon(),
            color: report.hasAnomaly ? Colors.orange : Colors.grey.shade500,
          ),
        ),
        title: Text(
          _getTitle(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (report.notes != null && report.notes!.isNotEmpty)
              Text(
                report.notes!,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              dateStr,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: () {},
      ),
    );
  }
}
