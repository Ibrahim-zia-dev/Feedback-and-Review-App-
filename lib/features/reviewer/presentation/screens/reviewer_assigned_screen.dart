import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../admin/providers/admin_inbox_providers.dart';
import '../../../shared/domain/entities/context_entity.dart';

class ReviewerAssignedScreen extends ConsumerWidget {
  const ReviewerAssignedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responses = ref.watch(
      adminInboxProvider((organizationId: 'test-org', pageSize: 100)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Assigned responses')),
      body: responses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load assignments: $error')),
        data: (items) {
          final assigned = items
              .where(
                (item) =>
                    item.assignedTo != null && item.assignedTo!.isNotEmpty,
              )
              .toList();
          if (assigned.isEmpty) {
            return const Center(child: Text('No responses assigned yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assigned.length,
            itemBuilder: (context, index) {
              final response = assigned[index];
              return Card(
                child: ListTile(
                  title: Text(response.review),
                  subtitle: Text('Rating ${response.rating}/5'),
                  trailing: Text(response.status.displayName),
                  onTap: () =>
                      context.push('/reviewer/responses/${response.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
