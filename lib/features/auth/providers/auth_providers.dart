import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../shared/domain/repositories/auth_repository.dart';
import '../data/repositories/firebase_auth_repository.dart';

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(firebaseAuth: firebaseAuth);
});

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

// Auth state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  final user = ref.watch(currentUserProvider);

  return user.when(
    data: (user) => Stream.value(
      user != null
          ? AuthState.authenticated(user)
          : AuthState.unauthenticated(),
    ),
    error: (error, stackTrace) => Stream.value(AuthState.error(error)),
    loading: () => Stream.value(AuthState.loading()),
  );
});

// Sign in provider
final signInProvider = FutureProvider.family<void, SignInRequest>((
  ref,
  request,
) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.signIn(
    email: request.email,
    password: request.password,
  );
});

// Sign up provider
final signUpProvider = FutureProvider.family<void, SignUpRequest>((
  ref,
  request,
) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.signUp(
    email: request.email,
    password: request.password,
  );
});

// Sign out provider
final signOutProvider = FutureProvider<void>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.signOut();
});

// Password reset provider
final passwordResetProvider = FutureProvider.family<void, String>((
  ref,
  email,
) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.sendPasswordResetEmail(email: email);
});

// Is authenticated provider
final isAuthenticatedProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.when(
    data: (user) => Stream.value(user != null),
    error: (_, _) => Stream.value(false),
    loading: () => Stream.value(false),
  );
});

/// Represents the current authentication state
class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final Object? error;

  AuthState._({
    this.user,
    required this.isLoading,
    required this.isAuthenticated,
    this.error,
  });

  factory AuthState.loading() {
    return AuthState._(isLoading: true, isAuthenticated: false);
  }

  factory AuthState.authenticated(User user) {
    return AuthState._(user: user, isLoading: false, isAuthenticated: true);
  }

  factory AuthState.unauthenticated() {
    return AuthState._(isLoading: false, isAuthenticated: false);
  }

  factory AuthState.error(Object error) {
    return AuthState._(isLoading: false, isAuthenticated: false, error: error);
  }
}

/// Request model for sign in
class SignInRequest {
  final String email;
  final String password;

  SignInRequest({required this.email, required this.password});
}

/// Request model for sign up
class SignUpRequest {
  final String email;
  final String password;
  final String confirmPassword;

  SignUpRequest({
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  bool isPasswordMatch() => password == confirmPassword;

  bool isPasswordStrong() => password.length >= 8;
}
