import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/admin_inbox_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const organizationId = 'test-org';
    final stats = ref.watch(inboxStatsProvider(organizationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: stats.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load dashboard: $error')),
        data: (value) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Feedback overview',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _Metric(label: 'Total', value: '${value.totalCount}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Metric(
                    label: 'Average rating',
                    value: value.avgRating.toStringAsFixed(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Submitted',
                    value: '${value.submittedCount}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Metric(
                    label: 'Reviewing',
                    value: '${value.reviewingCount}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Metric(label: 'Reviewed', value: '${value.reviewedCount}'),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
