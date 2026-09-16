import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../config/environment_config.dart';
import '../utils/logger.dart';

/// Service for initializing and managing Firebase
class FirebaseService {
  static FirebaseService? _instance;

  final EnvironmentConfig config;

  FirebaseService._({required this.config});

  factory FirebaseService({required EnvironmentConfig config}) {
    _instance ??= FirebaseService._(config: config);
    return _instance!;
  }

  static FirebaseService? get instance => _instance;

  Future<void> initialize() async {
    try {
      Logger.info(
        'Initializing Firebase for ${config.environment.name} environment',
      );

      // Use the native Firebase configuration for the active platform.
      await Firebase.initializeApp();

      // Set up Firestore
      _setupFirestore();

      // Set up Firebase Auth
      _setupAuth();

      // Set up Analytics
      if (config.enableAnalytics) {
        _setupAnalytics();
      }

      Logger.info('Firebase initialized successfully');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize Firebase', e, stackTrace);
      rethrow;
    }
  }

  Future<void> connectToEmulator() async {
    if (!config.useEmulator) return;

    try {
      Logger.info('Connecting to Firebase emulators...');

      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;

      // Connect Firestore emulator
      await firestore.terminate();
      firestore.useFirestoreEmulator(config.emulatorHost, 8080);

      // Connect Auth emulator
      await auth.useAuthEmulator(config.emulatorHost, 9099);

      Logger.info('Connected to Firebase emulators at ${config.emulatorHost}');
    } catch (e, stackTrace) {
      Logger.warning('Failed to connect to emulators', stackTrace);
    }
  }

  void _setupFirestore() {
    final firestore = FirebaseFirestore.instance;

    // Configure Firestore settings
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    Logger.info('Firestore configured');
  }

  void _setupAuth() {
    final auth = FirebaseAuth.instance;

    // Configure auth state persistence
    auth.setPersistence(Persistence.LOCAL);

    Logger.info('Firebase Auth configured');
  }

  void _setupAnalytics() {
    final analytics = FirebaseAnalytics.instance;
    analytics.logAppOpen();
    Logger.info('Firebase Analytics configured');
  }
}
