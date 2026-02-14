import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/report.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DataProvider>().loadReports());
  }

  Future<void> _refresh() => context.read<DataProvider>().loadReports();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${data.reports.length} Reports',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => _showCreateDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Report'),
              ),
            ],
          ),
        ),
        Expanded(
          child: data.loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: data.reports.isEmpty
                      ? ListView(
                          children: const [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text('No reports found'),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: data.reports.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (ctx, i) =>
                              _ReportCard(report: data.reports[i]),
                        ),
                ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context) {
    final operationIdCtrl = TextEditingController();
    final missingCtrl = TextEditingController(text: '0');
    final extraCtrl = TextEditingController(text: '0');
    bool hasDamage = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: operationIdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Operation ID *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Physical Damage'),
                  value: hasDamage,
                  onChanged: (v) => setDialogState(() => hasDamage = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: missingCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Missing Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: extraCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Extra Quality',
                    border: OutlineInputBorder(),
                  ),
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
                if (operationIdCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Operation ID is required')),
                  );
                  return;
                }
                final data = context.read<DataProvider>();
                final ok = await data.createReport(
                  operationId: operationIdCtrl.text.trim(),
                  physicalDamage: hasDamage,
                  missingQuantity: int.tryParse(missingCtrl.text) ?? 0,
                  extraQuality: int.tryParse(extraCtrl.text) ?? 0,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report created')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.report, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Report ${report.id.substring(0, 8)}...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _row('Operation', report.operationId),
            if (report.reportedBy != null)
              _row('Reported by', report.reportedBy!),
            _row('Damage', report.physicalDamage ? 'Yes' : 'No'),
            _row('Missing Qty', '${report.missingQuantity}'),
            _row('Extra Quality', '${report.extraQuality}'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
