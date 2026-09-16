import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin/providers/admin_inbox_providers.dart';

class ReviewerResponseDetailScreen extends ConsumerWidget {
  const ReviewerResponseDetailScreen({super.key, required this.responseId});

  final String responseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final response = ref.watch(responseDetailProvider(responseId));
    return Scaffold(
      appBar: AppBar(title: const Text('Response detail')),
      body: response.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load response: $error')),
        data: (value) {
          if (value == null) {
            return const Center(child: Text('Response not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Rating ${value.rating}/5',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              const Text(
                'Feedback',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(value.review),
              if (value.suggestion != null && value.suggestion!.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Suggestion',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(value.suggestion!),
              ],
              const SizedBox(height: 20),
              Text('Status: ${value.status.name}'),
            ],
          );
        },
      ),
    );
  }
}
