import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';

/// Background Task Service - Cross-platform background task scheduling
class BackgroundTaskService {
  BackgroundTaskService();

  Future<void> initialize() async {
    // Workmanager initialization is handled in main.dart/main_customer.dart 
    // to ensure the callbackDispatcher is at the top level.
  }

  Future<void> schedulePeriodicTask(String taskId, String taskName, {Duration frequency = const Duration(minutes: 15)}) async {
    if (kIsWeb) return;
    try {
      await Workmanager().registerPeriodicTask(
        taskId,
        taskName,
        frequency: frequency,
        existingWorkPolicy: ExistingWorkPolicy.keep,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
      );
    } catch (e) {
      debugPrint('Schedule Task Error: $e');
    }
  }

  Future<void> cancelTask(String taskId) async {
    if (kIsWeb) return;
    await Workmanager().cancelByUniqueName(taskId);
  }

  Future<void> cancelAllTasks() async {
    if (kIsWeb) return;
    await Workmanager().cancelAll();
  }
}
