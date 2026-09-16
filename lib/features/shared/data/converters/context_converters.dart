import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/context_entity.dart';

/// Converter for Context to/from Firestore
class ContextConverter {
  static const String _collectionPath = 'contexts';

  static String get collectionPath => _collectionPath;

  static Context fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Context(
      id: doc.id,
      organizationId: data['organizationId'] as String,
      ownerId: data['ownerId'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      type: ContextTypeExtension.fromString(data['type'] as String),
      status: ContextStatusExtension.fromString(data['status'] as String),
      isIdentifiable: data['isIdentifiable'] as bool? ?? false,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      assignedReviewerIds: List<String>.from(
        data['assignedReviewerIds'] as List? ?? [],
      ),
    );
  }

  static Map<String, dynamic> toFirestore(Context entity) {
    return {
      'organizationId': entity.organizationId,
      'ownerId': entity.ownerId,
      'title': entity.title,
      'description': entity.description,
      'type': entity.type.value,
      'status': entity.status.value,
      'isIdentifiable': entity.isIdentifiable,
      'startDate': Timestamp.fromDate(entity.startDate),
      'endDate': entity.endDate != null
          ? Timestamp.fromDate(entity.endDate!)
          : null,
      'createdAt': Timestamp.fromDate(entity.createdAt),
      'updatedAt': Timestamp.fromDate(entity.updatedAt),
      'assignedReviewerIds': entity.assignedReviewerIds,
    };
  }
}

/// Converter for Response to/from Firestore
class ResponseConverter {
  static const String _collectionPath = 'responses';

  static String get collectionPath => _collectionPath;

  static Response fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Response(
      id: doc.id,
      contextId: data['contextId'] as String,
      organizationId: data['organizationId'] as String,
      contributorId: data['contributorId'] as String,
      rating: data['rating'] as int,
      review: data['review'] as String,
      suggestion: data['suggestion'] as String?,
      status: ResponseStatusExtension.fromString(data['status'] as String),
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      reviewedAt: data['reviewedAt'] != null
          ? (data['reviewedAt'] as Timestamp).toDate()
          : null,
      reviewerNote: data['reviewerNote'] as String?,
      assignedTo: data['assignedTo'] as String?,
    );
  }

  static Map<String, dynamic> toFirestore(Response entity) {
    return {
      'contextId': entity.contextId,
      'organizationId': entity.organizationId,
      'contributorId': entity.contributorId,
      'rating': entity.rating,
      'review': entity.review,
      'suggestion': entity.suggestion,
      'status': entity.status.value,
      'submittedAt': Timestamp.fromDate(entity.submittedAt),
      'reviewedAt': entity.reviewedAt != null
          ? Timestamp.fromDate(entity.reviewedAt!)
          : null,
      'reviewerNote': entity.reviewerNote,
      'assignedTo': entity.assignedTo,
    };
  }
}
