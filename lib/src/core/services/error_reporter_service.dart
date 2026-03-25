import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ErrorReporterService {
  Future<void> reportError(dynamic error, StackTrace stack) async {
    debugPrint('Captured Error: $error');
    if (!kDebugMode) {
      await Sentry.captureException(error, stackTrace: stack);
    }
  }

  Future<void> reportMessage(String msg) async {
    if (!kDebugMode) await Sentry.captureMessage(msg);
  }
}
