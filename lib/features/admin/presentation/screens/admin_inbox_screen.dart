import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/presentation/widgets/input_widgets.dart';
import '../../../shared/presentation/widgets/state_widgets.dart';
import '../../../shared/domain/entities/context_entity.dart';
import '../../providers/admin_inbox_providers.dart';

/// Admin inbox screen for reviewing and triaging responses
class AdminInboxScreen extends ConsumerStatefulWidget {
  const AdminInboxScreen({super.key});

  @override
  ConsumerState<AdminInboxScreen> createState() => _AdminInboxScreenState();
}

class _AdminInboxScreenState extends ConsumerState<AdminInboxScreen> {
  late TextEditingController _searchController;
  ResponseStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Get organizationId from auth state
    const organizationId = 'test-org';

    final inboxAsync = ref.watch(
      adminInboxProvider((organizationId: organizationId, pageSize: 50)),
    );

    final statsAsync = ref.watch(inboxStatsProvider(organizationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        elevation: 0,
        actions: [
          statsAsync.when(
            data: (stats) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${stats.totalCount}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const Text('responses', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search feedback...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedStatus == null,
                  onTap: () {
                    setState(() => _selectedStatus = null);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Submitted',
                  isSelected: _selectedStatus == ResponseStatus.submitted,
                  onTap: () {
                    setState(() => _selectedStatus = ResponseStatus.submitted);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Reviewing',
                  isSelected: _selectedStatus == ResponseStatus.reviewing,
                  onTap: () {
                    setState(() => _selectedStatus = ResponseStatus.reviewing);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Reviewed',
                  isSelected: _selectedStatus == ResponseStatus.reviewed,
                  onTap: () {
                    setState(() => _selectedStatus = ResponseStatus.reviewed);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // Inbox list
          Expanded(
            child: inboxAsync.when(
              data: (responses) {
                if (responses.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'Inbox Empty',
                    description:
                        'No feedback responses yet. Share the context with your team.',
                  );
                }

                // Filter by status
                var filtered = responses;
                if (_selectedStatus != null) {
                  filtered = filtered
                      .where((r) => r.status == _selectedStatus)
                      .toList();
                }

                // Sort by submitted date (newest first)
                filtered.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final response = filtered[index];
                    return _ResponseListItem(
                      response: response,
                      onTap: () {
                        context.push('/admin/responses/${response.id}');
                      },
                    );
                  },
                );
              },
              loading: () => const LoadingState(),
              error: (error, _) => ErrorState(
                title: 'Failed to Load Inbox',
                description: error.toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual response list item for inbox
class _ResponseListItem extends StatelessWidget {
  final Response response;
  final VoidCallback onTap;

  const _ResponseListItem({required this.response, required this.onTap});

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
                        size: 16,
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

              // Footer with date and action indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(response.submittedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      if (response.suggestion != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '💡 Has suggestion',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: const Color(0xFF2BB3A9)),
                          ),
                        ),
                    ],
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
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
