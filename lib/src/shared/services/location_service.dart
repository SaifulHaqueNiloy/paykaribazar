import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/paths.dart';

class LocationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> checkPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    return permission != LocationPermission.deniedForever;
  }

  Future<Position?> getCurrentLocation() async {
    if (!await checkPermission()) return null;
    return await Geolocator.getCurrentPosition();
  }

  double calculateDistance(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  Stream<Position> get locationStream => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

  Stream<QuerySnapshot<Map<String, dynamic>>> getOnlineRiders() {
    return _db
        .collection(HubPaths.users)
        .where('role', isEqualTo: 'rider')
        .where('isOnline', isEqualTo: true)
        .snapshots();
  }
}
