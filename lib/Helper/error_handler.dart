import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class GlobalErrorHandler {
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        // In debug mode, show the error
        FlutterError.presentError(details);
      } else {
        // In release mode, log the error silently
        _logError(details.exception, details.stack);
      }
    };

    // Handle errors not caught by Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      if (_shouldIgnoreError(error)) {
        return true; // Ignore harmless errors
      }

      _logError(error, stack);
      return true; // Prevent crash
    };
  }

  static bool _shouldIgnoreError(Object error) {
    final errorString = error.toString().toLowerCase();

    // Common harmless errors to ignore
    return errorString.contains('scroll position') ||
        errorString.contains('renderflex overflowed') ||
        errorString.contains('ticker is not ticking') ||
        errorString.contains('a renderflex overflowed') ||
        errorString.contains('unable to load asset');
  }

  static void _logError(Object error, StackTrace? stack) {
    debugPrint('🔴 Error caught: $error');
    if (stack != null) {
      debugPrint('Stack trace:\n$stack');
    }

    // TODO: Send to crash reporting service (Firebase Crashlytics, Sentry, etc.)
    // Example:
    // FirebaseCrashlytics.instance.recordError(error, stack);
  }

  /// Handle scroll-related errors specifically
  static void handleScrollError(Object error, StackTrace? stack) {
    if (_shouldIgnoreError(error)) {
      debugPrint('🟡 Ignored scroll error: $error');
      return;
    }
    _logError(error, stack);
  }

  /// Safe execution wrapper
  static T? safeExecute<T>(T Function() function, {T? fallback}) {
    try {
      return function();
    } catch (error, stack) {
      _logError(error, stack);
      return fallback;
    }
  }

  /// Safe async execution wrapper
  static Future<T?> safeExecuteAsync<T>(Future<T> Function() function, {
    T? fallback,
  }) async {
    try {
      return await function();
    } catch (error, stack) {
      _logError(error, stack);
      return fallback;
    }
  }
}