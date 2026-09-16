import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';

/// Converter for UserEntity to/from Firestore
class UserEntityConverter {
  static const String _collectionPath = 'users';

  static String get collectionPath => _collectionPath;

  static UserEntity fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserEntity(
      id: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> toFirestore(UserEntity entity) {
    return {
      'email': entity.email,
      'displayName': entity.displayName,
      'photoUrl': entity.photoUrl,
      'createdAt': Timestamp.fromDate(entity.createdAt),
      'updatedAt': Timestamp.fromDate(entity.updatedAt),
      'isActive': entity.isActive,
    };
  }
}

/// Converter for Membership to/from Firestore
class MembershipConverter {
  static const String _collectionPath = 'memberships';

  static String get collectionPath => _collectionPath;

  static Membership fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Membership(
      id: doc.id,
      userId: data['userId'] as String,
      organizationId: data['organizationId'] as String,
      role: MembershipRoleExtension.fromString(data['role'] as String),
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> toFirestore(Membership entity) {
    return {
      'userId': entity.userId,
      'organizationId': entity.organizationId,
      'role': entity.role.value,
      'joinedAt': Timestamp.fromDate(entity.joinedAt),
      'updatedAt': entity.updatedAt != null
          ? Timestamp.fromDate(entity.updatedAt!)
          : null,
      'isActive': entity.isActive,
    };
  }
}

/// Converter for Organization to/from Firestore
class OrganizationConverter {
  static const String _collectionPath = 'organizations';

  static String get collectionPath => _collectionPath;

  static Organization fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return Organization(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String?,
      ownerId: data['ownerId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> toFirestore(Organization entity) {
    return {
      'name': entity.name,
      'description': entity.description,
      'ownerId': entity.ownerId,
      'createdAt': Timestamp.fromDate(entity.createdAt),
      'updatedAt': Timestamp.fromDate(entity.updatedAt),
      'isActive': entity.isActive,
    };
  }
}
