import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../../../../core/utils/logger.dart';
import '../converters/firestore_converters.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';

/// Firestore implementation of UserRepository
class FirestoreUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirestoreUserRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<UserEntity?> getUserById(String userId) async {
    try {
      Logger.info('Fetching user: $userId');

      final doc = await _firestore
          .collection(UserEntityConverter.collectionPath)
          .doc(userId)
          .get();

      if (!doc.exists) {
        Logger.warning('User not found: $userId');
        return null;
      }

      return UserEntityConverter.fromFirestore(doc);
    } catch (e, stackTrace) {
      Logger.error('Failed to get user', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> createOrUpdateUser(UserEntity user) async {
    try {
      Logger.info('Creating or updating user: ${user.id}');

      await _firestore
          .collection(UserEntityConverter.collectionPath)
          .doc(user.id)
          .set(UserEntityConverter.toFirestore(user), SetOptions(merge: true));

      Logger.info('User created/updated successfully: ${user.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to create/update user', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      Logger.info('Deleting user: $userId');

      await _firestore
          .collection(UserEntityConverter.collectionPath)
          .doc(userId)
          .delete();

      Logger.info('User deleted successfully: $userId');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete user', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      Logger.info('Updating user profile: $userId');

      await _firestore
          .collection(UserEntityConverter.collectionPath)
          .doc(userId)
          .update(updates);

      Logger.info('User profile updated successfully: $userId');
    } catch (e, stackTrace) {
      Logger.error('Failed to update user profile', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Stream<UserEntity?> getUserStream(String userId) {
    return _firestore
        .collection(UserEntityConverter.collectionPath)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return UserEntityConverter.fromFirestore(doc);
        });
  }
}

/// Firestore implementation of OrganizationRepository
class FirestoreOrganizationRepository implements OrganizationRepository {
  final FirebaseFirestore _firestore;

  FirestoreOrganizationRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<String> createOrganization(Organization organization) async {
    try {
      Logger.info('Creating organization: ${organization.name}');

      final docRef = await _firestore
          .collection('organizations')
          .add(OrganizationConverter.toFirestore(organization));

      Logger.info('Organization created: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      Logger.error('Failed to create organization', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> deleteOrganization(String organizationId) async {
    try {
      Logger.info('Deleting organization: $organizationId');

      await _firestore.collection('organizations').doc(organizationId).delete();

      Logger.info('Organization deleted: $organizationId');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete organization', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<Organization?> getOrganizationById(String organizationId) async {
    try {
      Logger.info('Fetching organization: $organizationId');

      final doc = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .get();

      if (!doc.exists) {
        Logger.warning('Organization not found: $organizationId');
        return null;
      }

      return OrganizationConverter.fromFirestore(doc);
    } catch (e, stackTrace) {
      Logger.error('Failed to get organization', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Stream<Organization?> getOrganizationStream(String organizationId) {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return OrganizationConverter.fromFirestore(doc);
        });
  }

  @override
  Future<List<Organization>> getUserOrganizations(String userId) async {
    try {
      Logger.info('Fetching organizations for user: $userId');

      final snapshot = await _firestore
          .collection('organizations')
          .where('ownerId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => OrganizationConverter.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get user organizations', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> updateOrganization(Organization organization) async {
    try {
      Logger.info('Updating organization: ${organization.id}');

      await _firestore
          .collection('organizations')
          .doc(organization.id)
          .update(OrganizationConverter.toFirestore(organization));

      Logger.info('Organization updated: ${organization.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update organization', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }
}

/// Firestore implementation of MembershipRepository
class FirestoreMembershipRepository implements MembershipRepository {
  final FirebaseFirestore _firestore;

  FirestoreMembershipRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<String> addMember({
    required String userId,
    required String organizationId,
    required MembershipRole role,
  }) async {
    try {
      Logger.info(
        'Adding member $userId to organization $organizationId with role ${role.name}',
      );

      final now = DateTime.now();
      final membership = Membership(
        id: '', // Will be set by Firestore
        userId: userId,
        organizationId: organizationId,
        role: role,
        joinedAt: now,
        updatedAt: now,
        isActive: true,
      );

      final docRef = await _firestore
          .collection(MembershipConverter.collectionPath)
          .add(MembershipConverter.toFirestore(membership));

      Logger.info('Member added: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      Logger.error('Failed to add member', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<Membership?> getMembershipById(String membershipId) async {
    try {
      Logger.info('Fetching membership: $membershipId');

      final doc = await _firestore
          .collection(MembershipConverter.collectionPath)
          .doc(membershipId)
          .get();

      if (!doc.exists) {
        Logger.warning('Membership not found: $membershipId');
        return null;
      }

      return MembershipConverter.fromFirestore(doc);
    } catch (e, stackTrace) {
      Logger.error('Failed to get membership', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<List<Membership>> getOrganizationMembers(String organizationId) async {
    try {
      Logger.info('Fetching members for organization: $organizationId');

      final snapshot = await _firestore
          .collection(MembershipConverter.collectionPath)
          .where('organizationId', isEqualTo: organizationId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => MembershipConverter.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get organization members', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Stream<Membership?> getMembershipStream(String membershipId) {
    return _firestore
        .collection(MembershipConverter.collectionPath)
        .doc(membershipId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return MembershipConverter.fromFirestore(doc);
        });
  }

  @override
  Future<List<Membership>> getUserMemberships(String userId) async {
    try {
      Logger.info('Fetching memberships for user: $userId');

      final snapshot = await _firestore
          .collection(MembershipConverter.collectionPath)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => MembershipConverter.fromFirestore(doc))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get user memberships', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> removeMember(String membershipId) async {
    try {
      Logger.info('Removing member: $membershipId');

      await _firestore
          .collection(MembershipConverter.collectionPath)
          .doc(membershipId)
          .update({'isActive': false, 'updatedAt': DateTime.now()});

      Logger.info('Member removed: $membershipId');
    } catch (e, stackTrace) {
      Logger.error('Failed to remove member', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }

  @override
  Future<void> updateMemberRole({
    required String membershipId,
    required MembershipRole role,
  }) async {
    try {
      Logger.info('Updating member role: $membershipId to ${role.name}');

      await _firestore
          .collection(MembershipConverter.collectionPath)
          .doc(membershipId)
          .update({'role': role.value, 'updatedAt': DateTime.now()});

      Logger.info('Member role updated: $membershipId');
    } catch (e, stackTrace) {
      Logger.error('Failed to update member role', e, stackTrace);
      throw app_exceptions.FirebaseException(message: e.toString());
    }
  }
}
