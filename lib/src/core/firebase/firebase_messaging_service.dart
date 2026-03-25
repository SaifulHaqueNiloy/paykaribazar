import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _fcm.requestPermission();
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;
}
