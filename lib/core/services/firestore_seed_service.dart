import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/logger.dart';

/// Service to seed Firestore with test data
class FirestoreSeedService {
  final FirebaseFirestore _firestore;

  FirestoreSeedService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  /// Seed database with test data for development
  Future<void> seedDatabase({
    required String ownerId,
    required String organizationId,
  }) async {
    try {
      Logger.info('Starting database seeding...');

      // Create test users
      await _seedUsers(ownerId);

      // Create organization
      await _seedOrganization(organizationId, ownerId);

      // Create memberships
      await _seedMemberships(organizationId, ownerId);

      // Create contexts
      await _seedContexts(organizationId, ownerId);

      // Create responses
      await _seedResponses(organizationId);

      Logger.info('Database seeding completed successfully');
    } catch (e, stackTrace) {
      Logger.error('Failed to seed database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _seedUsers(String ownerId) async {
    Logger.info('Seeding users...');

    final now = DateTime.now();

    // Owner user
    await _firestore.collection('users').doc(ownerId).set({
      'email': 'owner@feedre.com',
      'displayName': 'Organization Owner',
      'photoUrl': null,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'isActive': true,
    }, SetOptions(merge: true));

    // Administrator user
    await _firestore.collection('users').doc('admin-user-001').set({
      'email': 'admin@feedre.com',
      'displayName': 'Administrator',
      'photoUrl': null,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'isActive': true,
    }, SetOptions(merge: true));

    // Reviewer users
    for (int i = 1; i <= 2; i++) {
      await _firestore.collection('users').doc('reviewer-user-00$i').set({
        'email': 'reviewer$i@feedre.com',
        'displayName': 'Reviewer $i',
        'photoUrl': null,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'isActive': true,
      }, SetOptions(merge: true));
    }

    // Contributor users
    for (int i = 1; i <= 5; i++) {
      await _firestore.collection('users').doc('contributor-user-00$i').set({
        'email': 'contributor$i@feedre.com',
        'displayName': 'Contributor $i',
        'photoUrl': null,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
        'isActive': true,
      }, SetOptions(merge: true));
    }

    Logger.info('Users seeded');
  }

  Future<void> _seedOrganization(String organizationId, String ownerId) async {
    Logger.info('Seeding organization...');

    final now = DateTime.now();

    await _firestore.collection('organizations').doc(organizationId).set({
      'name': 'Test Organization',
      'description': 'A test organization for development',
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'isActive': true,
    }, SetOptions(merge: true));

    Logger.info('Organization seeded');
  }

  Future<void> _seedMemberships(String organizationId, String ownerId) async {
    Logger.info('Seeding memberships...');

    final now = DateTime.now();

    // Owner membership
    await _firestore
        .collection('memberships')
        .doc('${ownerId}_$organizationId')
        .set({
          'userId': ownerId,
          'organizationId': organizationId,
          'role': 'owner',
          'joinedAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
          'isActive': true,
        }, SetOptions(merge: true));

    // Admin membership
    await _firestore
        .collection('memberships')
        .doc('admin-user-001_$organizationId')
        .set({
          'userId': 'admin-user-001',
          'organizationId': organizationId,
          'role': 'administrator',
          'joinedAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
          'isActive': true,
        }, SetOptions(merge: true));

    // Reviewer memberships
    for (int i = 1; i <= 2; i++) {
      await _firestore
          .collection('memberships')
          .doc('reviewer-user-00${i}_$organizationId')
          .set({
            'userId': 'reviewer-user-00$i',
            'organizationId': organizationId,
            'role': 'reviewer',
            'joinedAt': Timestamp.fromDate(now),
            'updatedAt': Timestamp.fromDate(now),
            'isActive': true,
          }, SetOptions(merge: true));
    }

    // Contributor memberships
    for (int i = 1; i <= 5; i++) {
      await _firestore
          .collection('memberships')
          .doc('contributor-user-00${i}_$organizationId')
          .set({
            'userId': 'contributor-user-00$i',
            'organizationId': organizationId,
            'role': 'contributor',
            'joinedAt': Timestamp.fromDate(now),
            'updatedAt': Timestamp.fromDate(now),
            'isActive': true,
          }, SetOptions(merge: true));
    }

    Logger.info('Memberships seeded');
  }

  Future<void> _seedContexts(String organizationId, String ownerId) async {
    Logger.info('Seeding contexts...');

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 7));

    // Active context 1
    await _firestore.collection('contexts').add({
      'organizationId': organizationId,
      'ownerId': ownerId,
      'title': 'Customer Experience Review',
      'description': 'Share your experience with our onboarding and support.',
      'type': 'product',
      'status': 'active',
      'isIdentifiable': false,
      'startDate': Timestamp.fromDate(now),
      'endDate': Timestamp.fromDate(nextWeek),
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'assignedReviewerIds': ['reviewer-user-001'],
    });

    // Active context 2
    await _firestore.collection('contexts').add({
      'organizationId': organizationId,
      'ownerId': ownerId,
      'title': 'New Feature Feedback',
      'description': 'Tell us what you think about the new dashboard.',
      'type': 'feature',
      'status': 'active',
      'isIdentifiable': true,
      'startDate': Timestamp.fromDate(now),
      'endDate': Timestamp.fromDate(nextWeek),
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'assignedReviewerIds': ['reviewer-user-002'],
    });

    // Draft context
    await _firestore.collection('contexts').add({
      'organizationId': organizationId,
      'ownerId': ownerId,
      'title': 'Design System Review',
      'description': 'Feedback on our updated design system.',
      'type': 'design',
      'status': 'draft',
      'isIdentifiable': false,
      'startDate': Timestamp.fromDate(tomorrow),
      'endDate': null,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'assignedReviewerIds': [],
    });

    Logger.info('Contexts seeded');
  }

  Future<void> _seedResponses(String organizationId) async {
    Logger.info('Seeding responses...');

    final now = DateTime.now();

    // Get active contexts
    final contextSnapshot = await _firestore
        .collection('contexts')
        .where('organizationId', isEqualTo: organizationId)
        .where('status', isEqualTo: 'active')
        .get();

    if (contextSnapshot.docs.isEmpty) {
      Logger.warning('No active contexts found for seeding responses');
      return;
    }

    final contextId = contextSnapshot.docs.first.id;

    // Create responses from contributors
    for (int i = 1; i <= 3; i++) {
      final responseId = '${contextId}_contributor-user-00$i';
      final rating = 3 + (i % 3);

      await _firestore.collection('responses').doc(responseId).set({
        'contextId': contextId,
        'organizationId': organizationId,
        'contributorId': 'contributor-user-00$i',
        'rating': rating,
        'review': 'This is test feedback response number $i.',
        'suggestion': 'I suggest improving the ${'ABCDE'[i % 5]} feature.',
        'status': i == 1 ? 'reviewing' : 'submitted',
        'submittedAt': Timestamp.fromDate(now),
        'reviewedAt': i == 1 ? Timestamp.fromDate(now) : null,
        'reviewerNote': i == 1 ? 'This is a good suggestion' : null,
        'assignedTo': i == 1 ? 'reviewer-user-001' : null,
      }, SetOptions(merge: true));
    }

    Logger.info('Responses seeded');
  }

  /// Clear all test data
  Future<void> clearDatabase() async {
    try {
      Logger.info('Clearing database...');

      final collections = [
        'users',
        'organizations',
        'memberships',
        'contexts',
        'responses',
        'activity',
        'aggregates',
      ];

      for (final collection in collections) {
        final snapshot = await _firestore.collection(collection).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      Logger.info('Database cleared successfully');
    } catch (e, stackTrace) {
      Logger.error('Failed to clear database', e, stackTrace);
      rethrow;
    }
  }
}
