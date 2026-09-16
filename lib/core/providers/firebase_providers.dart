import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/environment_config.dart';
import '../services/firebase_service.dart';

// Environment configuration provider
final environmentProvider = Provider<EnvironmentConfig>((ref) {
  // TODO: Change this based on build configuration
  return EnvironmentConfig.development;
});

// Firebase Service provider
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  final config = ref.watch(environmentProvider);
  return FirebaseService(config: config);
});

// Firebase Auth provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Firestore provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.userChanges();
});

// Is authenticated provider
final isAuthenticatedProvider = StreamProvider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.when(
    data: (user) => Stream.value(user != null),
    error: (error, stackTrace) => Stream.value(false),
    loading: () => Stream.value(false),
  );
});
