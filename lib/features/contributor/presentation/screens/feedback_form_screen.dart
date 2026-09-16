import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/presentation/widgets/input_widgets.dart';
import '../../providers/contributor_providers.dart';

/// Feedback form screen for contributors
class FeedbackFormScreen extends ConsumerStatefulWidget {
  final String contextId;

  const FeedbackFormScreen({super.key, required this.contextId});

  @override
  ConsumerState<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends ConsumerState<FeedbackFormScreen> {
  late TextEditingController _reviewController;
  late TextEditingController _suggestionController;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController();
    _suggestionController = TextEditingController();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final formNotifier = ref.read(feedbackFormProvider.notifier);

    // Validate form
    if (!ref.read(feedbackFormProvider).isFormValid) {
      _showErrorDialog('Please rate and provide feedback');
      return;
    }

    try {
      // TODO: Get userId from auth state
      const userId = 'test-user';

      await ref.read(
        submitFeedbackProvider((
          contextId: widget.contextId,
          userId: userId,
        )).future,
      );

      formNotifier.reset();
      _reviewController.clear();
      _suggestionController.clear();

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submission Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thank You!'),
        content: const Text('Your feedback has been submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/contributor/my-feedback');
            },
            child: const Text('View Feedback'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(feedbackFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Feedback'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share Your Feedback',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Help us improve by sharing your honest feedback',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF475569)),
            ),
            const SizedBox(height: 32),

            // Rating section
            Text(
              'How would you rate your experience?',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            RatingInput(
              initialValue: formState.rating,
              onRatingChanged: (rating) {
                ref.read(feedbackFormProvider.notifier).setRating(rating);
              },
            ),
            const SizedBox(height: 32),

            // Review section
            Text(
              'What did you think?',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Required • Max 500 characters',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              maxLength: 500,
              onChanged: (value) {
                ref.read(feedbackFormProvider.notifier).setReview(value);
              },
              decoration: const InputDecoration(
                hintText: 'Share your thoughts, observations, or concerns...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Suggestion section
            Text(
              'Any suggestions?',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Optional • Max 500 characters',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _suggestionController,
              maxLines: 3,
              maxLength: 500,
              onChanged: (value) {
                ref
                    .read(feedbackFormProvider.notifier)
                    .setSuggestion(value.isEmpty ? null : value);
              },
              decoration: const InputDecoration(
                hintText: 'Ideas for improvement...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: formState.isSubmitting ? null : _handleSubmit,
                child: formState.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Feedback'),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (formState.review.isNotEmpty ||
                      formState.suggestion != null) {
                    _showConfirmDialog();
                  } else {
                    context.pop();
                  }
                },
                child: const Text('Cancel'),
              ),
            ),

            const SizedBox(height: 24),

            // Privacy notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF1F4D9A),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your feedback is confidential and will only be shared with administrators.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF1F4D9A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Draft?'),
        content: const Text(
          'Your feedback draft will be lost. Are you sure you want to cancel?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Draft'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(feedbackFormProvider.notifier).reset();
              _reviewController.clear();
              _suggestionController.clear();
              context.pop();
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}
