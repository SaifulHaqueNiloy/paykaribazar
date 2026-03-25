import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../../utils/globals.dart';
import '../../core/constants/paths.dart';

class NotificationService {
  final _fcm = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;
  final _local = FlutterLocalNotificationsPlugin();
  StreamSubscription? _notifSub;

  NotificationService();

  Future<void> init() async {
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      
      await _local.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationTap(response.payload);
        },
      );
      
      if (!kIsWeb) {
        await _requestPermissions();
        const channel = AndroidNotificationChannel(
          'high_importance_channel', 
          'High Importance Notifications', 
          importance: Importance.max,
        );
        await _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
      }
      
      FirebaseMessaging.onMessage.listen((m) {
        if (m.notification != null) {
          showNotification(
            title: m.notification!.title!, 
            body: m.notification!.body!, 
            data: m.data,
            imageUrl: m.notification?.android?.imageUrl ?? m.data['imageUrl'],
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((m) {
        _handleNotificationTap(m.data.toString());
      });

      FirebaseAuth.instance.authStateChanges().listen((user) {
        _notifSub?.cancel();
        if (user != null) {
          _listenToUserNotifications(user.uid);
        }
      });

    } catch (e) { debugPrint('Notification Init Error: $e'); }
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null) return;
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    try {
      if (payload.contains('type: order')) {
        GoRouter.of(ctx).push('/orders');
      } else if (payload.contains('type: chat')) {
        GoRouter.of(ctx).push('/chat');
      } else if (payload.contains('type: blood')) {
        GoRouter.of(ctx).push('/emergency');
      } else {
        GoRouter.of(ctx).push('/notifications');
      }
    } catch (e) {
      debugPrint('Routing Error: $e');
    }
  }

  void _listenToUserNotifications(String uid) {
    _notifSub = _db.collection(HubPaths.notifications)
       .where('userId', isEqualTo: uid)
       .where('status', isEqualTo: 'pending')
       .snapshots()
       .listen((snap) {
         for (var doc in snap.docs) {
           final data = doc.data();
           showNotification(
             title: data['title'] ?? 'Notice', 
             body: data['body'] ?? '', 
             data: data,
             imageUrl: data['imageUrl'],
           );
           doc.reference.update({'status': 'delivered'});
         }
       });
  }

  Future<void> showNotification({
    required String title, 
    required String body, 
    Map<String, dynamic>? data, 
    bool isEm = false,
    String? imageUrl,
  }) async {
    
    BigPictureStyleInformation? bigPictureStyle;
    if (imageUrl != null && !kIsWeb) {
      final String? filePath = await _downloadAndSaveFile(imageUrl, 'notification_img');
      if (filePath != null) {
        bigPictureStyle = BigPictureStyleInformation(
          FilePathAndroidBitmap(filePath),
          largeIcon: FilePathAndroidBitmap(filePath),
          contentTitle: title,
          summaryText: body,
        );
      }
    }

    if (!kIsWeb) {
      await _local.show(
        DateTime.now().millisecond, 
        title, body, 
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel', 
            'High Importance Notifications', 
            importance: Importance.max, 
            priority: Priority.max,
            color: isEm ? Colors.red : Colors.indigo,
            icon: '@mipmap/ic_launcher',
            styleInformation: bigPictureStyle,
          ),
        ),
        payload: data?.toString(),
      );
    }
  }

  Future<void> broadcastNotification(String title, String body, {String? relatedId}) async {
    // Specifically targeted to internal management roles
    await sendNotificationToRole(
      roles: ['admin', 'staff', 'marketing'],
      title: title,
      body: body,
      data: {'type': 'order', 'relatedId': relatedId},
    );
  }

  Future<void> sendNotificationToRole({
    required List<String> roles, 
    required String title, 
    required String body, 
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    final snap = await _db.collection(HubPaths.users).where('role', whereIn: roles).get();
    for (var doc in snap.docs) {
      await sendDirectNotification(
        userId: doc.id,
        title: title,
        body: body,
        data: data,
        imageUrl: imageUrl,
      );
    }
  }

  Future<void> sendBloodRequestAlert({String? requestId, String? group, String? location, int? bags}) async {
    if (group == null) return;
    final donorSnap = await _db.collection(HubPaths.donors).where('group', isEqualTo: group).get();
    for (var doc in donorSnap.docs) {
      await sendDirectNotification(
        userId: doc.id,
        title: '🔴 Emergency Blood Needed!',
        body: '$group Blood needed at ${location ?? "Hospital"} ($bags bags).',
        data: {'type': 'blood', 'requestId': requestId},
      );
    }
  }

  Future<void> sendDirectNotification({required String userId, required String title, required String body, Map<String, dynamic>? data, String? imageUrl}) async {
    await _db.collection(HubPaths.notifications).add({
      'userId': userId, 'title': title, 'body': body, 'data': data ?? {},
      'imageUrl': imageUrl, 'status': 'pending', 'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deactivateAlerts(String orderId) async {
    final alerts = await _db.collection(HubPaths.notifications).where('data.relatedId', isEqualTo: orderId).get();
    for (var doc in alerts.docs) {
      await doc.reference.update({'status': 'inactive'});
    }
  }

  Future<String?> _downloadAndSaveFile(String url, String fileName) async {
    if (kIsWeb) return null;
    try {
      final Directory directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/$fileName';
      final http.Response response = await http.get(Uri.parse(url));
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e) { return null; }
  }

  Future<void> _requestPermissions() async { 
    if (kIsWeb) return;
    await _fcm.requestPermission();
    await Permission.notification.request();
  }
}
