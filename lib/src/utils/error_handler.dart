import 'package:flutter/material.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'globals.dart';

class ErrorHandler {
  /// [DNA-SYS-ERR-PROTOCOL]: Global error handler using local notifications
  static void handleError(dynamic error, {String? title}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    String message = error.toString();
    if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    }

    try {
      final container = ProviderScope.containerOf(context);
      final notifier = container.read(notificationServiceProvider);
      
      notifier.showNotification(
        title: title ?? 'দুঃখিত! একটি সমস্যা হয়েছে',
        body: message,
        isEm: true,
      );
    } catch (e) {
      debugPrint('ErrorHandler fail: $e');
    }
  }

  static void showSuccess(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
