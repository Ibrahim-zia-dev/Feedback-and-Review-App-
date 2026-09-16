/// Represents a feedback context (request for feedback)
class Context {
  final String id;
  final String organizationId;
  final String ownerId;
  final String title;
  final String? description;
  final ContextType type;
  final ContextStatus status;
  final bool isIdentifiable;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> assignedReviewerIds;

  Context({
    required this.id,
    required this.organizationId,
    required this.ownerId,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    required this.isIdentifiable,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.assignedReviewerIds,
  });

  Context copyWith({
    String? id,
    String? organizationId,
    String? ownerId,
    String? title,
    String? description,
    ContextType? type,
    ContextStatus? status,
    bool? isIdentifiable,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? assignedReviewerIds,
  }) {
    return Context(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      isIdentifiable: isIdentifiable ?? this.isIdentifiable,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedReviewerIds: assignedReviewerIds ?? this.assignedReviewerIds,
    );
  }

  bool get isActive => status == ContextStatus.active;
  bool get isOpen => endDate == null || endDate!.isAfter(DateTime.now());
}

enum ContextType { feature, product, design, service, other }

extension ContextTypeExtension on ContextType {
  String get displayName {
    switch (this) {
      case ContextType.feature:
        return 'Feature';
      case ContextType.product:
        return 'Product';
      case ContextType.design:
        return 'Design';
      case ContextType.service:
        return 'Service';
      case ContextType.other:
        return 'Other';
    }
  }

  String get value => name;

  static ContextType fromString(String value) {
    return ContextType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContextType.other,
    );
  }
}

enum ContextStatus { draft, active, paused, closed }

extension ContextStatusExtension on ContextStatus {
  String get displayName {
    switch (this) {
      case ContextStatus.draft:
        return 'Draft';
      case ContextStatus.active:
        return 'Active';
      case ContextStatus.paused:
        return 'Paused';
      case ContextStatus.closed:
        return 'Closed';
    }
  }

  String get value => name;

  static ContextStatus fromString(String value) {
    return ContextStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContextStatus.draft,
    );
  }
}

/// Represents a response/feedback submission
class Response {
  final String id;
  final String contextId;
  final String organizationId;
  final String contributorId;
  final int rating;
  final String review;
  final String? suggestion;
  final ResponseStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewerNote;
  final String? assignedTo;

  Response({
    required this.id,
    required this.contextId,
    required this.organizationId,
    required this.contributorId,
    required this.rating,
    required this.review,
    this.suggestion,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewerNote,
    this.assignedTo,
  });

  Response copyWith({
    String? id,
    String? contextId,
    String? organizationId,
    String? contributorId,
    int? rating,
    String? review,
    String? suggestion,
    ResponseStatus? status,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewerNote,
    String? assignedTo,
  }) {
    return Response(
      id: id ?? this.id,
      contextId: contextId ?? this.contextId,
      organizationId: organizationId ?? this.organizationId,
      contributorId: contributorId ?? this.contributorId,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      suggestion: suggestion ?? this.suggestion,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewerNote: reviewerNote ?? this.reviewerNote,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}

enum ResponseStatus {
  submitted,
  reviewing,
  reviewed,
  actionable,
  resolved,
  archived,
}

extension ResponseStatusExtension on ResponseStatus {
  String get displayName {
    switch (this) {
      case ResponseStatus.submitted:
        return 'Submitted';
      case ResponseStatus.reviewing:
        return 'Reviewing';
      case ResponseStatus.reviewed:
        return 'Reviewed';
      case ResponseStatus.actionable:
        return 'Actionable';
      case ResponseStatus.resolved:
        return 'Resolved';
      case ResponseStatus.archived:
        return 'Archived';
    }
  }

  String get value => name;

  static ResponseStatus fromString(String value) {
    return ResponseStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ResponseStatus.submitted,
    );
  }
}

/// Represents aggregated metrics for a context
class ContextAggregate {
  final String id;
  final String contextId;
  final String organizationId;
  final int totalResponses;
  final double averageRating;
  final Map<int, int> ratingDistribution;
  final int statusCounts;
  final DateTime lastUpdatedAt;

  ContextAggregate({
    required this.id,
    required this.contextId,
    required this.organizationId,
    required this.totalResponses,
    required this.averageRating,
    required this.ratingDistribution,
    required this.statusCounts,
    required this.lastUpdatedAt,
  });
}
