import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/firestore_seed_service.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/user_repository.dart';
import '../data/repositories/firestore_user_repository.dart';

// User Repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreUserRepository(firestore: firestore);
});

// Organization Repository provider
final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreOrganizationRepository(firestore: firestore);
});

// Membership Repository provider
final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreMembershipRepository(firestore: firestore);
});

// Firestore Seed Service provider
final firestoreSeedServiceProvider = Provider<FirestoreSeedService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreSeedService(firestore: firestore);
});

// User detail provider
final userDetailProvider = FutureProvider.family<UserEntity?, String>((
  ref,
  userId,
) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserById(userId);
});

// User stream provider
final userStreamProvider = StreamProvider.family<UserEntity?, String>((
  ref,
  userId,
) async* {
  final repository = ref.watch(userRepositoryProvider);
  yield* repository.getUserStream(userId);
});

// Organization detail provider
final organizationDetailProvider = FutureProvider.family<Organization?, String>(
  (ref, organizationId) async {
    final repository = ref.watch(organizationRepositoryProvider);
    return repository.getOrganizationById(organizationId);
  },
);

// User organizations provider
final userOrganizationsProvider =
    FutureProvider.family<List<Organization>, String>((ref, userId) async {
      final repository = ref.watch(organizationRepositoryProvider);
      return repository.getUserOrganizations(userId);
    });

// User memberships provider
final userMembershipsProvider = FutureProvider.family<List<Membership>, String>(
  (ref, userId) async {
    final repository = ref.watch(membershipRepositoryProvider);
    return repository.getUserMemberships(userId);
  },
);

// Organization members provider
final organizationMembersProvider =
    FutureProvider.family<List<Membership>, String>((
      ref,
      organizationId,
    ) async {
      final repository = ref.watch(membershipRepositoryProvider);
      return repository.getOrganizationMembers(organizationId);
    });

// Membership detail provider
final membershipDetailProvider = FutureProvider.family<Membership?, String>((
  ref,
  membershipId,
) async {
  final repository = ref.watch(membershipRepositoryProvider);
  return repository.getMembershipById(membershipId);
});

// Membership stream provider
final membershipStreamProvider = StreamProvider.family<Membership?, String>((
  ref,
  membershipId,
) async* {
  final repository = ref.watch(membershipRepositoryProvider);
  yield* repository.getMembershipStream(membershipId);
});
