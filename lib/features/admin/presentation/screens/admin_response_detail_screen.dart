import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/presentation/widgets/input_widgets.dart';
import '../../../shared/presentation/widgets/state_widgets.dart';
import '../../../shared/domain/entities/context_entity.dart';
import '../../providers/admin_inbox_providers.dart';

/// Response detail screen with admin capabilities
class AdminResponseDetailScreen extends ConsumerStatefulWidget {
  final String responseId;

  const AdminResponseDetailScreen({super.key, required this.responseId});

  @override
  ConsumerState<AdminResponseDetailScreen> createState() =>
      _AdminResponseDetailScreenState();
}

class _AdminResponseDetailScreenState
    extends ConsumerState<AdminResponseDetailScreen> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleStatusChange(ResponseStatus newStatus) async {
    try {
      await ref.read(
        updateResponseStatusProvider((
          responseId: widget.responseId,
          status: newStatus,
        )).future,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Status updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _handleAddNote() async {
    if (_noteController.text.isEmpty) return;

    try {
      await ref.read(
        addInternalNoteProvider((
          responseId: widget.responseId,
          note: _noteController.text,
        )).future,
      );

      _noteController.clear();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note added')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Response Detail'), elevation: 0),
      body: ref
          .watch(responseDetailProvider(widget.responseId))
          .when(
            data: (response) {
              if (response == null) {
                return const ErrorState(
                  title: 'Response Not Found',
                  description: 'This response no longer exists.',
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating
                    Text(
                      'Rating',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.star,
                            size: 32,
                            color: index < response.rating
                                ? const Color(0xFFE8B84B)
                                : const Color(0xFFE2E8F0),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Status
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ResponseStatusBadge(status: response.status.value),
                        const SizedBox(width: 16),
                        PopupMenuButton<ResponseStatus>(
                          onSelected: _handleStatusChange,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: ResponseStatus.submitted,
                              child: Text('Submitted'),
                            ),
                            const PopupMenuItem(
                              value: ResponseStatus.reviewing,
                              child: Text('Reviewing'),
                            ),
                            const PopupMenuItem(
                              value: ResponseStatus.reviewed,
                              child: Text('Reviewed'),
                            ),
                          ],
                          child: const Chip(
                            label: Text('Change Status'),
                            avatar: Icon(Icons.edit),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submitted date
                    Text(
                      'Submitted',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${response.submittedAt.month}/${response.submittedAt.day}/${response.submittedAt.year} at ${response.submittedAt.hour}:${response.submittedAt.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Review
                    Text(
                      'Feedback',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        response.review,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Suggestion
                    if (response.suggestion != null) ...[
                      Text(
                        'Suggestion',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAFBF7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2BB3A9),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          response.suggestion!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Internal notes section
                    Text(
                      'Internal Notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add a note...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _handleAddNote,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          // TODO: Assign reviewer dialog
                        },
                        child: const Text('Assign Reviewer'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const LoadingState(),
            error: (error, _) => ErrorState(
              title: 'Failed to Load Response',
              description: error.toString(),
            ),
          ),
    );
  }
}
