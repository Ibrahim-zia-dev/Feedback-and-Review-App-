import 'package:firebase_auth/firebase_auth.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Get current authenticated user
  Future<User?> getCurrentUser();

  /// Sign up with email and password
  Future<void> signUp({required String email, required String password});

  /// Sign in with email and password
  Future<void> signIn({required String email, required String password});

  /// Sign out
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email});

  /// Listen to auth state changes
  Stream<User?> authStateChanges();
}
