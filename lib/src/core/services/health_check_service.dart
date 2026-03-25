import 'package:cloud_firestore/cloud_firestore.dart';
import 'connectivity_service.dart';
import '../../di/service_locator.dart';

class HealthCheckService {
  Future<Map<String, dynamic>> checkSystemHealth() async {
    final connectivity = getIt<ConnectivityService>();
    final isOnline = await connectivity.isConnected;

    bool firebaseLive = false;
    try {
      await FirebaseFirestore.instance
          .collection('health_check')
          .doc('ping')
          .get()
          .timeout(const Duration(seconds: 5));
      firebaseLive = true;
    } catch (_) {}

    return {
      'isOnline': isOnline,
      'firebaseLive': firebaseLive,
      'timestamp': DateTime.now(),
      'status': (isOnline && firebaseLive) ? 'Healthy' : 'Degraded',
    };
  }
}
