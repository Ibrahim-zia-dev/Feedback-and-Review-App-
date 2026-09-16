import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../../shared/domain/entities/context_entity.dart';
import '../../shared/providers/context_providers.dart';

// Filter parameters
class InboxFilterParams {
  final String? contextId;
  final int? minRating;
  final int? maxRating;
  final ResponseStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? assignedToReviewerId;
  final String? searchQuery;

  const InboxFilterParams({
    this.contextId,
    this.minRating,
    this.maxRating,
    this.status,
    this.startDate,
    this.endDate,
    this.assignedToReviewerId,
    this.searchQuery,
  });
}

// Real-time inbox provider with filtering
final adminInboxProvider =
    StreamProvider.family<
      List<Response>,
      ({String organizationId, int pageSize})
    >((ref, params) async* {
      final repository = ref.watch(responseRepositoryProvider);

      try {
        yield* repository.getOrganizationResponses(
          params.organizationId,
          pageSize: params.pageSize,
        );
      } catch (e) {
        Logger.error('Failed to load inbox', e);
        yield [];
      }
    });

// Filtered inbox provider
final filteredInboxProvider =
    FutureProvider.family<
      List<Response>,
      ({String organizationId, InboxFilterParams filters})
    >((ref, params) async {
      final repository = ref.watch(responseRepositoryProvider);

      try {
        // Fetch all responses for organization
        final responses = await repository.getOrganizationResponsesList(
          params.organizationId,
        );

        // Apply filters
        var filtered = responses;

        if (params.filters.contextId != null) {
          filtered = filtered
              .where((r) => r.contextId == params.filters.contextId)
              .toList();
        }

        if (params.filters.status != null) {
          filtered = filtered
              .where((r) => r.status == params.filters.status)
              .toList();
        }

        if (params.filters.minRating != null) {
          filtered = filtered
              .where((r) => r.rating >= params.filters.minRating!)
              .toList();
        }

        if (params.filters.maxRating != null) {
          filtered = filtered
              .where((r) => r.rating <= params.filters.maxRating!)
              .toList();
        }

        if (params.filters.startDate != null) {
          filtered = filtered
              .where((r) => r.submittedAt.isAfter(params.filters.startDate!))
              .toList();
        }

        if (params.filters.endDate != null) {
          filtered = filtered
              .where((r) => r.submittedAt.isBefore(params.filters.endDate!))
              .toList();
        }

        // Sort by submitted date (newest first)
        filtered.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

        return filtered;
      } catch (e) {
        Logger.error('Failed to filter inbox', e);
        rethrow;
      }
    });

// Keyword search (bounded to 100 results)
final inboxSearchProvider =
    FutureProvider.family<
      List<Response>,
      ({String organizationId, String query})
    >((ref, params) async {
      final repository = ref.watch(responseRepositoryProvider);

      try {
        final responses = await repository.getOrganizationResponsesList(
          params.organizationId,
        );

        final query = params.query.toLowerCase();
        final matches = responses
            .where(
              (response) =>
                  response.review.toLowerCase().contains(query) ||
                  (response.suggestion?.toLowerCase().contains(query) ?? false),
            )
            .take(100)
            .toList();

        return matches;
      } catch (e) {
        Logger.error('Search failed', e);
        rethrow;
      }
    });

// Response detail with visibility-aware contributor info
final responseDetailProvider = FutureProvider.family<Response?, String>((
  ref,
  responseId,
) async {
  final repository = ref.watch(responseRepositoryProvider);
  return repository.getResponseById(responseId);
});

// Update response status
final updateResponseStatusProvider =
    FutureProvider.family<void, ({String responseId, ResponseStatus status})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(responseRepositoryProvider);

      try {
        await repository.updateResponseStatus(
          responseId: params.responseId,
          newStatus: params.status,
        );
        Logger.info(
          'Response status updated: ${params.responseId} → ${params.status}',
        );
      } catch (e) {
        Logger.error('Failed to update response status', e);
        rethrow;
      }
    });

// Assign reviewer
final assignReviewerProvider =
    FutureProvider.family<void, ({String responseId, String reviewerId})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(responseRepositoryProvider);

      try {
        await repository.assignResponse(
          responseId: params.responseId,
          reviewerId: params.reviewerId,
        );
        Logger.info('Reviewer assigned: ${params.responseId}');
      } catch (e) {
        Logger.error('Failed to assign reviewer', e);
        rethrow;
      }
    });

// Unassign reviewer
final unassignReviewerProvider = FutureProvider.family<void, String>((
  ref,
  responseId,
) async {
  final repository = ref.watch(responseRepositoryProvider);

  try {
    await repository.assignResponse(responseId: responseId, reviewerId: '');
    Logger.info('Reviewer unassigned: $responseId');
  } catch (e) {
    Logger.error('Failed to unassign reviewer', e);
    rethrow;
  }
});

// Add internal note (append-only)
final addInternalNoteProvider =
    FutureProvider.family<void, ({String responseId, String note})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(responseRepositoryProvider);

      try {
        await repository.addInternalNote(
          responseId: params.responseId,
          note: params.note,
        );
        Logger.info('Note added to response: ${params.responseId}');
      } catch (e) {
        Logger.error('Failed to add note', e);
        rethrow;
      }
    });

// Get inbox statistics
final inboxStatsProvider = FutureProvider.family<InboxStats, String>((
  ref,
  organizationId,
) async {
  final repository = ref.watch(responseRepositoryProvider);

  try {
    final responses = await repository.getOrganizationResponsesList(
      organizationId,
    );

    return InboxStats(
      totalCount: responses.length,
      submittedCount: responses
          .where((r) => r.status == ResponseStatus.submitted)
          .length,
      reviewingCount: responses
          .where((r) => r.status == ResponseStatus.reviewing)
          .length,
      reviewedCount: responses
          .where((r) => r.status == ResponseStatus.reviewed)
          .length,
      avgRating: responses.isNotEmpty
          ? responses.fold<double>(0, (sum, r) => sum + r.rating) /
                responses.length
          : 0.0,
    );
  } catch (e) {
    Logger.error('Failed to get inbox stats', e);
    rethrow;
  }
});

// Inbox statistics data class
class InboxStats {
  final int totalCount;
  final int submittedCount;
  final int reviewingCount;
  final int reviewedCount;
  final double avgRating;

  const InboxStats({
    required this.totalCount,
    required this.submittedCount,
    required this.reviewingCount,
    required this.reviewedCount,
    required this.avgRating,
  });
}
