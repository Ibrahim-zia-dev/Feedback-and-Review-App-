import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../../shared/domain/entities/context_entity.dart';
import '../../shared/providers/context_providers.dart';

// Feedback form state
class FeedbackFormState {
  final int? rating;
  final String review;
  final String? suggestion;
  final bool isSubmitting;
  final String? error;
  final bool isSuccess;

  const FeedbackFormState({
    this.rating,
    this.review = '',
    this.suggestion,
    this.isSubmitting = false,
    this.error,
    this.isSuccess = false,
  });

  FeedbackFormState copyWith({
    int? rating,
    String? review,
    String? suggestion,
    bool? isSubmitting,
    String? error,
    bool? isSuccess,
  }) {
    return FeedbackFormState(
      rating: rating ?? this.rating,
      review: review ?? this.review,
      suggestion: suggestion ?? this.suggestion,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  bool get isFormValid => rating != null && review.isNotEmpty;
}

// Feedback form provider
final feedbackFormProvider =
    StateNotifierProvider<FeedbackFormNotifier, FeedbackFormState>((ref) {
      return FeedbackFormNotifier();
    });

class FeedbackFormNotifier extends StateNotifier<FeedbackFormState> {
  FeedbackFormNotifier() : super(const FeedbackFormState());

  void setRating(int rating) {
    state = state.copyWith(rating: rating);
  }

  void setReview(String review) {
    if (review.length <= 500) {
      state = state.copyWith(review: review);
    }
  }

  void setSuggestion(String? suggestion) {
    if (suggestion == null || suggestion.length <= 500) {
      state = state.copyWith(suggestion: suggestion);
    }
  }

  void reset() {
    state = const FeedbackFormState();
  }
}

// Submit feedback provider
final submitFeedbackProvider =
    FutureProvider.family<void, ({String contextId, String userId})>((
      ref,
      params,
    ) async {
      final form = ref.watch(feedbackFormProvider);
      final repository = ref.watch(responseRepositoryProvider);

      if (!form.isFormValid) {
        throw Exception('Form is not valid');
      }

      try {
        final response = Response(
          id: '${params.contextId}_${params.userId}',
          contextId: params.contextId,
          organizationId: '', // Will be fetched from context
          contributorId: params.userId,
          rating: form.rating!,
          review: form.review,
          suggestion: form.suggestion,
          status: ResponseStatus.submitted,
          submittedAt: DateTime.now(),
        );

        await repository.createResponse(response);
        Logger.info('Feedback submitted successfully');
      } catch (e) {
        Logger.error('Failed to submit feedback', e);
        rethrow;
      }
    });

// User's submitted responses provider
final userFeedbackListProvider = FutureProvider.family<List<Response>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(responseRepositoryProvider);
  return repository.getUserResponses(userId);
});

// Filter responses by status
final filteredUserFeedbackProvider =
    FutureProvider.family<
      List<Response>,
      ({String userId, String? statusFilter})
    >((ref, params) async {
      final allResponses = await ref.watch(
        userFeedbackListProvider(params.userId).future,
      );

      if (params.statusFilter == null) {
        return allResponses;
      }

      return allResponses
          .where((response) => response.status.value == params.statusFilter)
          .toList();
    });

// Response detail provider
final responseDetailProvider = FutureProvider.family<Response?, String>((
  ref,
  responseId,
) async {
  final repository = ref.watch(responseRepositoryProvider);
  return repository.getResponseById(responseId);
});

// Check if user can submit response for context
final canSubmitResponseProvider =
    FutureProvider.family<bool, ({String userId, String contextId})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(responseRepositoryProvider);
      return !(await repository.hasUserSubmittedResponse(
        userId: params.userId,
        contextId: params.contextId,
      ));
    });

// Get active context for contributor
final activeContextForContributorProvider =
    FutureProvider.family<Context?, String>((ref, organizationId) async {
      final repository = ref.watch(contextRepositoryProvider);
      final contexts = await repository.getActiveContexts(organizationId);

      if (contexts.isEmpty) {
        return null;
      }

      // Return the most recently created active context
      contexts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return contexts.first;
    });
