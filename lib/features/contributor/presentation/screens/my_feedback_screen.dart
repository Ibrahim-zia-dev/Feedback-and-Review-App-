import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/presentation/widgets/input_widgets.dart';
import '../../../shared/presentation/widgets/state_widgets.dart';
import '../../../shared/domain/entities/context_entity.dart';
import '../../providers/contributor_providers.dart';

/// Screen showing user's submitted feedback history
class MyFeedbackScreen extends ConsumerWidget {
  const MyFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Get userId from auth state
    const userId = 'test-user';

    return Scaffold(
      appBar: AppBar(title: const Text('My Feedback'), elevation: 0),
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
                  _FilterChip(
                    label: 'All',
                    isSelected: true,
                    onTap: () {
                      // TODO: Clear filter
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Submitted',
                    isSelected: false,
                    onTap: () {
                      // TODO: Filter by status
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Reviewing',
                    isSelected: false,
                    onTap: () {
                      // TODO: Filter by status
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Reviewed',
                    isSelected: false,
                    onTap: () {
                      // TODO: Filter by status
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Feedback list
          Expanded(
            child: ref
                .watch(userFeedbackListProvider(userId))
                .when(
                  data: (responses) {
                    if (responses.isEmpty) {
                      return const EmptyState(
                        icon: Icons.feedback_outlined,
                        title: 'No Feedback Yet',
                        description:
                            'You haven\'t submitted any feedback. Look for active feedback requests and share your thoughts.',
                        actionLabel: 'Submit Feedback',
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: responses.length,
                      itemBuilder: (context, index) {
                        final response = responses[index];
                        return _FeedbackListItem(
                          response: response,
                          onTap: () {
                            context.push('/feedback/${response.id}');
                          },
                        );
                      },
                    );
                  },
                  loading: () => const LoadingState(),
                  error: (error, stackTrace) => ErrorState(
                    title: 'Failed to Load Feedback',
                    description: error.toString(),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

/// Individual feedback list item
class _FeedbackListItem extends StatelessWidget {
  final Response response;
  final VoidCallback onTap;

  const _FeedbackListItem({required this.response, required this.onTap});

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
              // Header with rating and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Rating
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 18,
                        color: index < response.rating
                            ? const Color(0xFFE8B84B)
                            : const Color(0xFFE2E8F0),
                      );
                    }),
                  ),
                  ResponseStatusBadge(status: response.status.value),
                ],
              ),
              const SizedBox(height: 12),

              // Review preview
              Text(
                response.review.length > 100
                    ? '${response.review.substring(0, 100)}...'
                    : response.review,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer with date and arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(response.submittedAt),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

/// Filter chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F4D9A) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
