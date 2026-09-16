import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../shared/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository using Firebase Authentication
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository({required FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return _firebaseAuth.currentUser;
    } catch (e, stackTrace) {
      Logger.error('Failed to get current user', e, stackTrace);
      return null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      Logger.info('Password reset email sent to $email');
    } on FirebaseAuthException catch (e, stackTrace) {
      Logger.error('Failed to send password reset email', e, stackTrace);
      throw _mapFirebaseAuthException(e);
    } catch (e, stackTrace) {
      Logger.error(
        'Unexpected error sending password reset email',
        e,
        stackTrace,
      );
      throw AuthFailure.unknown(message: e.toString());
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      Logger.info('Attempting to sign in user: $email');

      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      Logger.info('User signed in successfully: $email');
    } on FirebaseAuthException catch (e, stackTrace) {
      Logger.error('Firebase Auth error during sign in', e, stackTrace);
      throw _mapFirebaseAuthException(e);
    } catch (e, stackTrace) {
      Logger.error('Unexpected error during sign in', e, stackTrace);
      throw AuthFailure.unknown(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      Logger.info('Signing out user');
      await _firebaseAuth.signOut();
      Logger.info('User signed out successfully');
    } catch (e, stackTrace) {
      Logger.error('Failed to sign out', e, stackTrace);
      throw AuthFailure.unknown(message: e.toString());
    }
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      Logger.info('Attempting to sign up user: $email');

      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      Logger.info('User signed up successfully: $email');
    } on FirebaseAuthException catch (e, stackTrace) {
      Logger.error('Firebase Auth error during sign up', e, stackTrace);
      throw _mapFirebaseAuthException(e);
    } catch (e, stackTrace) {
      Logger.error('Unexpected error during sign up', e, stackTrace);
      throw AuthFailure.unknown(message: e.toString());
    }
  }

  /// Maps Firebase Auth exceptions to custom AuthFailure objects
  AuthFailure _mapFirebaseAuthException(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return AuthFailure.invalidEmail();
      case 'user-disabled':
        return AuthFailure.unknown(
          message: 'This user account has been disabled',
        );
      case 'user-not-found':
        return AuthFailure.userNotFound();
      case 'wrong-password':
        return AuthFailure.wrongPassword();
      case 'email-already-in-use':
        return AuthFailure.emailAlreadyInUse();
      case 'operation-not-allowed':
        return AuthFailure.unknown(message: 'This operation is not allowed');
      case 'weak-password':
        return AuthFailure.weakPassword();
      case 'network-request-failed':
        return AuthFailure.networkError();
      default:
        return AuthFailure.unknown(message: exception.message);
    }
  }
}
