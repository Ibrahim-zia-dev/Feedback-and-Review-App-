import '../entities/user_entity.dart';

/// Repository interface for user-related operations
abstract class UserRepository {
  /// Get user by ID
  Future<UserEntity?> getUserById(String userId);

  /// Create or update user
  Future<void> createOrUpdateUser(UserEntity user);

  /// Update user profile
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  });

  /// Delete user
  Future<void> deleteUser(String userId);

  /// Listen to user changes
  Stream<UserEntity?> getUserStream(String userId);
}

/// Repository interface for organization-related operations
abstract class OrganizationRepository {
  /// Get organization by ID
  Future<Organization?> getOrganizationById(String organizationId);

  /// Get all organizations for a user
  Future<List<Organization>> getUserOrganizations(String userId);

  /// Create organization
  Future<String> createOrganization(Organization organization);

  /// Update organization
  Future<void> updateOrganization(Organization organization);

  /// Delete organization
  Future<void> deleteOrganization(String organizationId);

  /// Listen to organization changes
  Stream<Organization?> getOrganizationStream(String organizationId);
}

/// Repository interface for membership-related operations
abstract class MembershipRepository {
  /// Get membership by ID
  Future<Membership?> getMembershipById(String membershipId);

  /// Get user's memberships
  Future<List<Membership>> getUserMemberships(String userId);

  /// Get organization's members
  Future<List<Membership>> getOrganizationMembers(String organizationId);

  /// Add member to organization
  Future<String> addMember({
    required String userId,
    required String organizationId,
    required MembershipRole role,
  });

  /// Update member role
  Future<void> updateMemberRole({
    required String membershipId,
    required MembershipRole role,
  });

  /// Remove member from organization
  Future<void> removeMember(String membershipId);

  /// Listen to membership changes
  Stream<Membership?> getMembershipStream(String membershipId);
}
