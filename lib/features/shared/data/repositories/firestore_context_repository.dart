import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../../../../core/utils/logger.dart';
import '../converters/context_converters.dart';
import '../../domain/entities/context_entity.dart';
import '../../domain/repositories/context_repository.dart';

/// Firestore implementation of ContextRepository
class FirestoreContextRepository implements ContextRepository {
  final FirebaseFirestore _firestore;

  FirestoreContextRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<String> createContext(Context context) async {
    try {
      Logger.info('Creating context: ${context.title}');

      final docRef = await _firestore
          .collection(ContextConverter.collectionPath)
          .add(ContextConverter.toFirestore(context));

      Logger.info('Context created: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      Logger.error('Failed to create context', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> deleteContext(String contextId) async {
    try {
      Logger.info('Deleting context: $contextId');

      await _firestore
          .collection(ContextConverter.collectionPath)
          .doc(contextId)
          .delete();

      Logger.info('Context deleted: $contextId');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete context', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<List<Context>> getActiveContexts(String organizationId) async {
    try {
      Logger.info('Fetching active contexts for org: $organizationId');

      final snapshot = await _firestore
          .collection(ContextConverter.collectionPath)
          .where('organizationId', isEqualTo: organizationId)
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs
          .map((doc) => ContextConverter.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get active contexts', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<Context?> getContextById(String contextId) async {
    try {
      Logger.info('Fetching context: $contextId');

      final doc = await _firestore
          .collection(ContextConverter.collectionPath)
          .doc(contextId)
          .get();

      if (!doc.exists) {
        Logger.warning('Context not found: $contextId');
        return null;
      }

      return ContextConverter.fromFirestore(doc);
    } catch (e, stackTrace) {
      Logger.error('Failed to get context', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Stream<Context?> getContextStream(String contextId) {
    return _firestore
        .collection(ContextConverter.collectionPath)
        .doc(contextId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return ContextConverter.fromFirestore(doc);
        });
  }

  @override
  Future<List<Context>> getOrganizationContexts(String organizationId) async {
    try {
      Logger.info('Fetching contexts for org: $organizationId');

      final snapshot = await _firestore
          .collection(ContextConverter.collectionPath)
          .where('organizationId', isEqualTo: organizationId)
          .get();

      return snapshot.docs
          .map((doc) => ContextConverter.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get organization contexts', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Stream<List<Context>> getOrganizationContextsStream(String organizationId) {
    return _firestore
        .collection(ContextConverter.collectionPath)
        .where('organizationId', isEqualTo: organizationId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ContextConverter.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> updateContext(Context context) async {
    try {
      Logger.info('Updating context: ${context.id}');

      await _firestore
          .collection(ContextConverter.collectionPath)
          .doc(context.id)
          .update(ContextConverter.toFirestore(context));

      Logger.info('Context updated: ${context.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update context', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> updateContextStatus({
    required String contextId,
    required ContextStatus newStatus,
  }) async {
    try {
      Logger.info('Updating context status: $contextId to ${newStatus.name}');

      await _firestore
          .collection(ContextConverter.collectionPath)
          .doc(contextId)
          .update({'status': newStatus.value, 'updatedAt': Timestamp.now()});

      Logger.info('Context status updated: $contextId');
    } catch (e, stackTrace) {
      Logger.error('Failed to update context status', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }
}

/// Firestore implementation of ResponseRepository
class FirestoreResponseRepository implements ResponseRepository {
  final FirebaseFirestore _firestore;

  FirestoreResponseRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<List<Response>> getOrganizationResponsesList(
    String organizationId,
  ) async {
    final snapshot = await _firestore
        .collection(ResponseConverter.collectionPath)
        .where('organizationId', isEqualTo: organizationId)
        .get();
    return snapshot.docs
        .map((doc) => ResponseConverter.fromFirestore(doc))
        .toList();
  }

  @override
  Stream<List<Response>> getOrganizationResponses(
    String organizationId, {
    int? pageSize,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(ResponseConverter.collectionPath)
        .where('organizationId', isEqualTo: organizationId)
        .orderBy('submittedAt', descending: true);
    if (pageSize != null) query = query.limit(pageSize);
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => ResponseConverter.fromFirestore(doc))
          .toList(),
    );
  }

  @override
  Future<String> createResponse(Response response) async {
    try {
      Logger.info('Creating response for context: ${response.contextId}');

      // Generate deterministic response ID for idempotency
      final responseId = _generateResponseId(
        response.contextId,
        response.contributorId,
      );

      // Use transaction to ensure idempotency
      await _firestore
          .collection(ResponseConverter.collectionPath)
          .doc(responseId)
          .set(ResponseConverter.toFirestore(response));

      Logger.info('Response created: $responseId');
      return responseId;
    } catch (e, stackTrace) {
      Logger.error('Failed to create response', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> deleteResponse(String responseId) async {
    try {
      Logger.info('Deleting response: $responseId');

      await _firestore
          .collection(ResponseConverter.collectionPath)
          .doc(responseId)
          .delete();

      Logger.info('Response deleted: $responseId');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete response', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> addInternalNote({
    required String responseId,
    required String note,
  }) async {
    try {
      Logger.info('Adding internal note to response: $responseId');

      await _firestore
          .collection(ResponseConverter.collectionPath)
          .doc(responseId)
          .update({'reviewerNote': note, 'updatedAt': Timestamp.now()});

      Logger.info('Internal note added: $responseId');
    } catch (e, stackTrace) {
      Logger.error('Failed to add internal note', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> assignResponse({
    required String responseId,
    required String reviewerId,
  }) async {
    try {
      Logger.info('Assigning response: $responseId to reviewer: $reviewerId');

      await _firestore
          .collection(ResponseConverter.collectionPath)
          .doc(responseId)
          .update({'assignedTo': reviewerId, 'updatedAt': Timestamp.now()});

      Logger.info('Response assigned: $responseId');
    } catch (e, stackTrace) {
      Logger.error('Failed to assign response', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<List<Response>> getContextResponses(String contextId) async {
    try {
      Logger.info('Fetching responses for context: $contextId');

      final snapshot = await _firestore
          .collection(ResponseConverter.collectionPath)
          .where('contextId', isEqualTo: contextId)
          .get();

      return snapshot.docs
          .map((doc) => ResponseConverter.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get context responses', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Stream<List<Response>> getContextResponsesStream(String contextId) {
    return _firestore
        .collection(ResponseConverter.collectionPath)
        .where('contextId', isEqualTo: contextId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ResponseConverter.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<Response?> getResponseById(String responseId) async {
    try {
      Logger.info('Fetching response: $responseId');

      final doc = await _firestore
          .collection(ResponseConverter.collectionPath)
          .doc(responseId)
          .get();

      if (!doc.exists) {
        Logger.warning('Response not found: $responseId');
        return null;
      }

      return ResponseConverter.fromFirestore(doc);
    } catch (e, stackTrace) {
      Logger.error('Failed to get response', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Stream<Response?> getResponseStream(String responseId) {
    return _firestore
        .collection(ResponseConverter.collectionPath)
        .doc(responseId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return ResponseConverter.fromFirestore(doc);
        });
  }

  @override
  Future<List<Response>> getUserResponses(String userId) async {
    try {
      Logger.info('Fetching responses for user: $userId');

      final snapshot = await _firestore
          .collection(ResponseConverter.collectionPath)
          .where('contributorId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => ResponseConverter.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get user responses', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<bool> hasUserSubmittedResponse({
    required String userId,
    required String contextId,
  }) async {
    try {
      Logger.info(
        'Checking if user $userId submitted response for context $contextId',
      );

      final snapshot = await _firestore
          .collection(ResponseConverter.collectionPath)
          .where('contextId', isEqualTo: contextId)
          .where('contributorId', isEqualTo: userId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e, stackTrace) {
      Logger.error('Failed to check user response', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> updateResponse(Response response) async {
    try {
      Logger.info('Updating response: ${response.id}');

      await _firestore
          .collection(ResponseConverter.collectionPath)
          .doc(response.id)
          .update(ResponseConverter.toFirestore(response));

      Logger.info('Response updated: ${response.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update response', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> updateResponseStatus({
    required String responseId,
    required ResponseStatus newStatus,
  }) async {
    try {
      Logger.info('Updating response status: $responseId to ${newStatus.name}');

      await _firestore
          .collection(ResponseConverter.collectionPath)
          .doc(responseId)
          .update({'status': newStatus.value, 'updatedAt': Timestamp.now()});

      Logger.info('Response status updated: $responseId');
    } catch (e, stackTrace) {
      Logger.error('Failed to update response status', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  // Generate deterministic ID for idempotency
  String _generateResponseId(String contextId, String contributorId) {
    return '${contextId}_$contributorId';
  }
}

/// Firestore implementation of AggregateRepository
class FirestoreAggregateRepository implements AggregateRepository {
  final FirebaseFirestore _firestore;

  FirestoreAggregateRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<ContextAggregate?> getContextAggregate(String contextId) async {
    try {
      Logger.info('Fetching aggregate for context: $contextId');

      final doc = await _firestore
          .collection('aggregates')
          .doc(contextId)
          .get();

      if (!doc.exists) {
        Logger.warning('Aggregate not found: $contextId');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      return ContextAggregate(
        id: doc.id,
        contextId: data['contextId'] as String,
        organizationId: data['organizationId'] as String,
        totalResponses: data['totalResponses'] as int,
        averageRating: (data['averageRating'] as num).toDouble(),
        ratingDistribution: Map<int, int>.from(
          (data['ratingDistribution'] as Map<dynamic, dynamic>).map(
            (k, v) => MapEntry(int.parse(k.toString()), v as int),
          ),
        ),
        statusCounts: data['statusCounts'] as int,
        lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp).toDate(),
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to get aggregate', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Stream<ContextAggregate?> getAggregateStream(String contextId) {
    return _firestore.collection('aggregates').doc(contextId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return ContextAggregate(
        id: doc.id,
        contextId: data['contextId'] as String,
        organizationId: data['organizationId'] as String,
        totalResponses: data['totalResponses'] as int,
        averageRating: (data['averageRating'] as num).toDouble(),
        ratingDistribution: Map<int, int>.from(
          (data['ratingDistribution'] as Map<dynamic, dynamic>).map(
            (k, v) => MapEntry(int.parse(k.toString()), v as int),
          ),
        ),
        statusCounts: data['statusCounts'] as int,
        lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp).toDate(),
      );
    });
  }

  @override
  Future<void> rebuildOrganizationAggregates(String organizationId) async {
    try {
      Logger.info('Rebuilding aggregates for organization: $organizationId');

      // Get all contexts for organization
      final contexts = await _firestore
          .collection('contexts')
          .where('organizationId', isEqualTo: organizationId)
          .get();

      // Rebuild aggregate for each context
      for (final contextDoc in contexts.docs) {
        final contextId = contextDoc.id;
        await _rebuildContextAggregate(contextId);
      }

      Logger.info('Aggregates rebuilt for organization: $organizationId');
    } catch (e, stackTrace) {
      Logger.error('Failed to rebuild aggregates', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> updateContextAggregate({
    required String contextId,
    required int totalResponses,
    required double averageRating,
    required Map<int, int> ratingDistribution,
  }) async {
    try {
      Logger.info('Updating aggregate for context: $contextId');

      await _firestore.collection('aggregates').doc(contextId).set({
        'contextId': contextId,
        'totalResponses': totalResponses,
        'averageRating': averageRating,
        'ratingDistribution': ratingDistribution,
        'lastUpdatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      Logger.info('Aggregate updated: $contextId');
    } catch (e, stackTrace) {
      Logger.error('Failed to update aggregate', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  Future<void> _rebuildContextAggregate(String contextId) async {
    try {
      // Get all responses for context
      final responses = await _firestore
          .collection('responses')
          .where('contextId', isEqualTo: contextId)
          .get();

      int totalResponses = responses.docs.length;
      double totalRating = 0;
      final ratingDistribution = <int, int>{};

      for (final responseDoc in responses.docs) {
        final rating = responseDoc['rating'] as int;
        totalRating += rating;
        ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;
      }

      final averageRating = totalResponses > 0
          ? totalRating / totalResponses
          : 0.0;

      // Update aggregate
      await _firestore.collection('aggregates').doc(contextId).set({
        'totalResponses': totalResponses,
        'averageRating': averageRating,
        'ratingDistribution': ratingDistribution,
        'lastUpdatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      Logger.info('Context aggregate rebuilt: $contextId');
    } catch (e, stackTrace) {
      Logger.error('Failed to rebuild context aggregate', e, stackTrace);
    }
  }
}
