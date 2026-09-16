import '../entities/context_entity.dart';

/// Repository interface for context-related operations
abstract class ContextRepository {
  /// Get context by ID
  Future<Context?> getContextById(String contextId);

  /// Get all contexts for an organization
  Future<List<Context>> getOrganizationContexts(String organizationId);

  /// Get active contexts for an organization
  Future<List<Context>> getActiveContexts(String organizationId);

  /// Create context
  Future<String> createContext(Context context);

  /// Update context
  Future<void> updateContext(Context context);

  /// Update context status
  Future<void> updateContextStatus({
    required String contextId,
    required ContextStatus newStatus,
  });

  /// Delete context
  Future<void> deleteContext(String contextId);

  /// Listen to context changes
  Stream<Context?> getContextStream(String contextId);

  /// Listen to organization contexts
  Stream<List<Context>> getOrganizationContextsStream(String organizationId);
}

/// Repository interface for response-related operations
abstract class ResponseRepository {
  /// Get all responses for an organization.
  Future<List<Response>> getOrganizationResponsesList(String organizationId);

  /// Listen to all responses for an organization.
  Stream<List<Response>> getOrganizationResponses(
    String organizationId, {
    int? pageSize,
  });

  /// Get response by ID
  Future<Response?> getResponseById(String responseId);

  /// Get responses for a context
  Future<List<Response>> getContextResponses(String contextId);

  /// Get user's responses
  Future<List<Response>> getUserResponses(String userId);

  /// Create response
  Future<String> createResponse(Response response);

  /// Update response
  Future<void> updateResponse(Response response);

  /// Update response status
  Future<void> updateResponseStatus({
    required String responseId,
    required ResponseStatus newStatus,
  });

  /// Add internal note to response
  Future<void> addInternalNote({
    required String responseId,
    required String note,
  });

  /// Assign response to reviewer
  Future<void> assignResponse({
    required String responseId,
    required String reviewerId,
  });

  /// Delete response
  Future<void> deleteResponse(String responseId);

  /// Listen to response changes
  Stream<Response?> getResponseStream(String responseId);

  /// Listen to context responses
  Stream<List<Response>> getContextResponsesStream(String contextId);

  /// Check if user already submitted response for context
  Future<bool> hasUserSubmittedResponse({
    required String userId,
    required String contextId,
  });
}

/// Repository interface for aggregate metrics
abstract class AggregateRepository {
  /// Get context aggregate metrics
  Future<ContextAggregate?> getContextAggregate(String contextId);

  /// Update context aggregate metrics
  Future<void> updateContextAggregate({
    required String contextId,
    required int totalResponses,
    required double averageRating,
    required Map<int, int> ratingDistribution,
  });

  /// Rebuild all aggregates for an organization
  Future<void> rebuildOrganizationAggregates(String organizationId);

  /// Listen to aggregate changes
  Stream<ContextAggregate?> getAggregateStream(String contextId);
}
