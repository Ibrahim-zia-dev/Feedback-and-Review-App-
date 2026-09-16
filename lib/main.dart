import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/environment_config.dart';
import 'core/services/firebase_service.dart';
import 'core/utils/logger.dart';

export 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.info('Initializing FeedRe Application...');
  Object? startupError;

  // Initialize Firebase
  final firebaseService = FirebaseService(
    config: EnvironmentConfig.development,
  );

  try {
    await firebaseService.initialize().timeout(const Duration(seconds: 8));

    // Emulator use is opt-in so physical devices use the configured Firebase project.
    if (firebaseService.config.useEmulator) {
      await firebaseService.connectToEmulator().timeout(
        const Duration(seconds: 3),
      );
    }

    Logger.info('Firebase initialized successfully');
  } catch (e, stackTrace) {
    Logger.error('Firebase startup skipped or timed out', e, stackTrace);
    startupError = e;
  }

  runApp(
    ProviderScope(
      child: startupError == null
          ? const FeedReApp()
          : FirebaseStartupErrorApp(error: startupError),
    ),
  );
}

class FirebaseStartupErrorApp extends StatelessWidget {
  const FirebaseStartupErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FeedRe',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 64),
                  const SizedBox(height: 20),
                  const Text(
                    'Firebase could not start',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Check your Firebase configuration or emulator connection, then restart the app.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
