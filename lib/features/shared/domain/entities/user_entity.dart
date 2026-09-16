/// Represents a user in the system
class UserEntity {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Represents a user's profile/extended information
class UserProfile extends UserEntity {
  final String? phoneNumber;
  final String? bio;
  final Map<String, dynamic>? metadata;

  UserProfile({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
    this.phoneNumber,
    this.bio,
    this.metadata,
  });
}

/// Represents an organization
class Organization {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Organization({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  Organization copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Represents a membership relationship between a user and an organization
class Membership {
  final String id;
  final String userId;
  final String organizationId;
  final MembershipRole role;
  final DateTime joinedAt;
  final DateTime? updatedAt;
  final bool isActive;

  Membership({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.role,
    required this.joinedAt,
    this.updatedAt,
    required this.isActive,
  });

  Membership copyWith({
    String? id,
    String? userId,
    String? organizationId,
    MembershipRole? role,
    DateTime? joinedAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Membership(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      organizationId: organizationId ?? this.organizationId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Enumeration of membership roles
enum MembershipRole { owner, administrator, reviewer, contributor }

extension MembershipRoleExtension on MembershipRole {
  String get displayName {
    switch (this) {
      case MembershipRole.owner:
        return 'Owner';
      case MembershipRole.administrator:
        return 'Administrator';
      case MembershipRole.reviewer:
        return 'Reviewer';
      case MembershipRole.contributor:
        return 'Contributor';
    }
  }

  String get value => name;

  static MembershipRole fromString(String value) {
    return MembershipRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MembershipRole.contributor,
    );
  }
}
