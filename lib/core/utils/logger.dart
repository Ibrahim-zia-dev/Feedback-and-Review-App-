import 'dart:developer' as developer;

/// Simple logger for non-sensitive information
class Logger {
  static const String _prefix = '[FeedRe]';

  static void debug(String message, [StackTrace? stackTrace]) {
    developer.log('[DEBUG] $message', name: _prefix);
    if (stackTrace != null) {
      developer.log('$stackTrace', name: _prefix);
    }
  }

  static void info(String message) {
    developer.log('[INFO] $message', name: _prefix);
  }

  static void warning(String message, [StackTrace? stackTrace]) {
    developer.log('[WARNING] $message', name: _prefix);
    if (stackTrace != null) {
      developer.log('$stackTrace', name: _prefix);
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log('[ERROR] $message', name: _prefix);
    if (error != null) {
      developer.log('Error: $error', name: _prefix);
    }
    if (stackTrace != null) {
      developer.log('$stackTrace', name: _prefix);
    }
  }
}
