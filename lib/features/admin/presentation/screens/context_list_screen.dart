import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/presentation/widgets/input_widgets.dart';
import '../../../shared/presentation/widgets/state_widgets.dart';
import '../../../shared/domain/entities/context_entity.dart';
import '../../providers/admin_context_providers.dart';

/// Admin screen for managing feedback contexts
class AdminContextListScreen extends ConsumerWidget {
  const AdminContextListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Get organizationId from auth/user state
    const organizationId = 'test-org';

    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Contexts'), elevation: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/admin/contexts/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Context'),
      ),
      body: Column(
        children: [
          // Status filter tabs
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusFilterChip(label: 'All', status: null, onTap: () {}),
                  const SizedBox(width: 8),
                  _StatusFilterChip(
                    label: 'Draft',
                    status: 'draft',
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _StatusFilterChip(
                    label: 'Active',
                    status: 'active',
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _StatusFilterChip(
                    label: 'Paused',
                    status: 'paused',
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _StatusFilterChip(
                    label: 'Closed',
                    status: 'closed',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Contexts list
          Expanded(
            child: ref
                .watch(organizationContextsProvider(organizationId))
                .when(
                  data: (contexts) {
                    if (contexts.isEmpty) {
                      return const EmptyState(
                        icon: Icons.task_alt_outlined,
                        title: 'No Contexts Yet',
                        description:
                            'Create feedback contexts to gather feedback from your team.',
                        actionLabel: 'Create Context',
                      );
                    }

                    // Sort by creation date (newest first)
                    contexts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: contexts.length,
                      itemBuilder: (context, index) {
                        final ctx = contexts[index];
                        return _ContextListItem(
                          context: ctx,
                          onTap: () {
                            context.push('/admin/contexts/${ctx.id}');
                          },
                        );
                      },
                    );
                  },
                  loading: () => const LoadingState(),
                  error: (error, stackTrace) => ErrorState(
                    title: 'Failed to Load Contexts',
                    description: error.toString(),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

/// Individual context list item
class _ContextListItem extends StatelessWidget {
  final Context context;
  final VoidCallback onTap;

  const _ContextListItem({required this.context, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          this.context.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        ContextTypeBadge(type: this.context.type.displayName),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusChip(
                    label: this.context.status.displayName,
                    backgroundColor: _getStatusColor(this.context.status),
                    textColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description preview
              Text(
                (this.context.description ?? '').length > 100
                    ? '${(this.context.description ?? '').substring(0, 100)}...'
                    : (this.context.description ?? ''),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475569),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer with dates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created ${_formatDate(this.context.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ContextStatus status) {
    switch (status) {
      case ContextStatus.draft:
        return const Color(0xFF94A3B8);
      case ContextStatus.active:
        return const Color(0xFF2BB3A9);
      case ContextStatus.paused:
        return const Color(0xFFE8B84B);
      case ContextStatus.closed:
        return const Color(0xFFE25A5A);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Status filter chip
class _StatusFilterChip extends StatelessWidget {
  final String label;
  final String? status;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: status == null
              ? const Color(0xFF1F4D9A)
              : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: status == null ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
