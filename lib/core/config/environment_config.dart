enum Environment { development, staging, production }

class EnvironmentConfig {
  final Environment environment;
  final String firebaseProjectId;
  final bool useEmulator;
  final String emulatorHost;
  final bool enableCrashlytics;
  final bool enableAnalytics;

  const EnvironmentConfig({
    required this.environment,
    required this.firebaseProjectId,
    required this.useEmulator,
    required this.emulatorHost,
    required this.enableCrashlytics,
    required this.enableAnalytics,
  });

  static final EnvironmentConfig development = EnvironmentConfig(
    environment: Environment.development,
    firebaseProjectId: 'feedback-1b5a2',
    useEmulator: const bool.fromEnvironment(
      'USE_FIREBASE_EMULATOR',
      defaultValue: false,
    ),
    emulatorHost: String.fromEnvironment(
      'FIREBASE_EMULATOR_HOST',
      defaultValue: '10.0.2.2',
    ),
    enableCrashlytics: false,
    enableAnalytics: false,
  );

  static final EnvironmentConfig staging = EnvironmentConfig(
    environment: Environment.staging,
    firebaseProjectId: 'feed-re-staging',
    useEmulator: false,
    emulatorHost: 'localhost',
    enableCrashlytics: true,
    enableAnalytics: true,
  );

  static final EnvironmentConfig production = EnvironmentConfig(
    environment: Environment.production,
    firebaseProjectId: 'feed-re-prod',
    useEmulator: false,
    emulatorHost: 'localhost',
    enableCrashlytics: true,
    enableAnalytics: true,
  );

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;
}
