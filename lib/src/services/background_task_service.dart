import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import '../../../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'backup_service.dart';
import 'user_media_service.dart';
import '../di/service_locator.dart';
import '../features/ai/services/ai_automation_service.dart';
import '../shared/services/notification_service.dart';

class BackgroundTaskService {
  static const String backupTask = 'pb_backup_task_v3';
  static const String aiAuditTask = 'pb_ai_audit_task_v1';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  static Future<void> scheduleAll() async {
    if (kIsWeb) return;
    await _scheduleBackup();
    await _scheduleAiAudit();
  }

  static Future<void> _scheduleBackup() async {
    await Workmanager().registerPeriodicTask(
      backupTask,
      backupTask,
      frequency: const Duration(hours: 3),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static Future<void> _scheduleAiAudit() async {
    await Workmanager().registerPeriodicTask(
      aiAuditTask,
      aiAuditTask,
      frequency: const Duration(minutes: 30),
      initialDelay: const Duration(minutes: 2),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }

  // Instance methods for compatibility with Service Locator registrations
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

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final stopwatch = Stopwatch()..start();

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final bool result = await _routeTask(task, inputData);
      debugPrint('Task $task completed in ${stopwatch.elapsedMilliseconds}ms with result: $result');
      return result;
    } catch (e) {
      debugPrint('Task $task failed: $e');
      return false;
    } finally {
      stopwatch.stop();
    }
  });
}

Future<bool> _routeTask(String task, Map<String, dynamic>? data) async {
  switch (task) {
    case BackgroundTaskService.backupTask:
    case 'PB_SYSTEM_BACKUP':
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return false;
      
      // Perform database backup
      await BackupService.performBackgroundBackup(uid);
      
      // Perform automatic user media backup to Cloudinary
      try {
        final userMediaService = getIt<UserMediaService>();
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userDoc.exists) {
          await userMediaService.runAutomaticBackup(uid);
        }
      } catch (e) {
        debugPrint('Background Media Backup failed: $e');
      }
      return true;

    case BackgroundTaskService.aiAuditTask:
    case 'backgroundBackup':
      final aiAutomation = getIt<AiAutomationService>();
      final notificationService = getIt<NotificationService>();
      await notificationService.init();
      await aiAutomation.checkAndRun();
      await notificationService.showNotification(
        title: 'পাইকারী বাজার: অডিট রিপোর্ট',
        body: 'ব্যাকগ্রাউন্ড এআই স্ক্যান সম্পন্ন হয়েছে। সিস্টেম স্ট্যাবল আছে।',
      );
      return true;

    default:
      debugPrint('Unknown task: $task');
      return false;
  }
}
