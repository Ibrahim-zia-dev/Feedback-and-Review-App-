import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../domain/entities/context_entity.dart';
import '../domain/repositories/context_repository.dart';
import '../data/repositories/firestore_context_repository.dart';

// Context Repository provider
final contextRepositoryProvider = Provider<ContextRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreContextRepository(firestore: firestore);
});

// Response Repository provider
final responseRepositoryProvider = Provider<ResponseRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreResponseRepository(firestore: firestore);
});

// Aggregate Repository provider
final aggregateRepositoryProvider = Provider<AggregateRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreAggregateRepository(firestore: firestore);
});

// Context list provider
final organizationContextsProvider =
    FutureProvider.family<List<Context>, String>((ref, organizationId) async {
      final repository = ref.watch(contextRepositoryProvider);
      return repository.getOrganizationContexts(organizationId);
    });

// Active contexts provider
final activeContextsProvider = FutureProvider.family<List<Context>, String>((
  ref,
  organizationId,
) async {
  final repository = ref.watch(contextRepositoryProvider);
  return repository.getActiveContexts(organizationId);
});

// Context detail provider
final contextDetailProvider = FutureProvider.family<Context?, String>((
  ref,
  contextId,
) async {
  final repository = ref.watch(contextRepositoryProvider);
  return repository.getContextById(contextId);
});

// Context stream provider
final contextStreamProvider = StreamProvider.family<Context?, String>((
  ref,
  contextId,
) async* {
  final repository = ref.watch(contextRepositoryProvider);
  yield* repository.getContextStream(contextId);
});

// Responses for context provider
final contextResponsesProvider = FutureProvider.family<List<Response>, String>((
  ref,
  contextId,
) async {
  final repository = ref.watch(responseRepositoryProvider);
  return repository.getContextResponses(contextId);
});

// User responses provider
final userResponsesProvider = FutureProvider.family<List<Response>, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(responseRepositoryProvider);
  return repository.getUserResponses(userId);
});

// Check if user submitted response provider
final hasUserSubmittedProvider =
    FutureProvider.family<bool, ({String userId, String contextId})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(responseRepositoryProvider);
      return repository.hasUserSubmittedResponse(
        userId: params.userId,
        contextId: params.contextId,
      );
    });

// Response stream provider
final responseStreamProvider = StreamProvider.family<Response?, String>((
  ref,
  responseId,
) async* {
  final repository = ref.watch(responseRepositoryProvider);
  yield* repository.getResponseStream(responseId);
});

// Context aggregate provider
final contextAggregateProvider =
    FutureProvider.family<ContextAggregate?, String>((ref, contextId) async {
      final repository = ref.watch(aggregateRepositoryProvider);
      return repository.getContextAggregate(contextId);
    });
