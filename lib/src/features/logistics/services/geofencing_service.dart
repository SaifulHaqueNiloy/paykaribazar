import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/paths.dart';
import 'dart:math';

class GeofencingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  GeofencingService();

  Future<void> initialize() async {
    await _requestLocationPermission();
  }

  /// Request location permissions
  Future<void> _requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }
  }

  /// Checks if current location is within delivery zone
  Future<bool> isWithinDeliveryZone(String areaId) async {
    try {
      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final zone = await _db
          .collection(HubPaths.deliveryZones)
          .doc(areaId)
          .get();

      if (!zone.exists) {
        return false;
      }

      final zoneData = zone.data()!;
      final centerLat = zoneData['centerLatitude'] as double;
      final centerLng = zoneData['centerLongitude'] as double;
      final radiusKm = zoneData['radiusKm'] as double;

      final distance = _calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        centerLat,
        centerLng,
      );

      return distance <= radiusKm;
    } catch (e) {
      return false;
    }
  }

  /// Calculates distance between two coordinates using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371; // Earth's radius in kilometers
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRad(double degree) {
    return degree * (pi / 180);
  }

  /// Gets nearest delivery zone
  Future<Map<String, dynamic>?> getNearestDeliveryZone() async {
    try {
      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final zones =
          await _db.collection(HubPaths.deliveryZones).get();

      if (zones.docs.isEmpty) {
        return null;
      }

      Map<String, dynamic>? nearest;
      double nearestDistance = double.infinity;

      for (var doc in zones.docs) {
        final zoneData = doc.data();
        final centerLat = zoneData['centerLatitude'] as double;
        final centerLng = zoneData['centerLongitude'] as double;

        final distance = _calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          centerLat,
          centerLng,
        );

        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearest = {'id': doc.id, ...zoneData};
        }
      }

      return nearest;
    } catch (e) {
      return null;
    }
  }

  /// Gets all delivery zones within range
  Future<List<Map<String, dynamic>>> getDeliveryZonesInRange(
      {double rangeKm = 10}) async {
    try {
      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final zones =
          await _db.collection(HubPaths.deliveryZones).get();

      final List<Map<String, dynamic>> inRange = [];

      for (var doc in zones.docs) {
        final zoneData = doc.data();
        final centerLat = zoneData['centerLatitude'] as double;
        final centerLng = zoneData['centerLongitude'] as double;

        final distance = _calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          centerLat,
          centerLng,
        );

        if (distance <= rangeKm) {
          inRange.add({'id': doc.id, ...zoneData, 'distance': distance});
        }
      }

      // Sort by distance
      inRange.sort((a, b) => (a['distance'] as double)
          .compareTo(b['distance'] as double));

      return inRange;
    } catch (e) {
      return [];
    }
  }

  /// Monitors real-time geofence status
  Stream<bool> monitorGeofence(String areaId) async* {
    try {
      while (true) {
        final isInZone = await isWithinDeliveryZone(areaId);
        yield isInZone;
        await Future.delayed(Duration(seconds: 10)); // Check every 10 seconds
      }
    } catch (e) {
      yield false;
    }
  }

  /// Creates new delivery zone
  Future<String> createDeliveryZone({
    required String zoneName,
    required double centerLatitude,
    required double centerLongitude,
    required double radiusKm,
    required double deliveryCharge,
    required int estimatedMinutes,
  }) async {
    try {
      final docRef = await _db
          .collection(HubPaths.deliveryZones)
          .add({
            'zoneName': zoneName,
            'centerLatitude': centerLatitude,
            'centerLongitude': centerLongitude,
            'radiusKm': radiusKm,
            'deliveryCharge': deliveryCharge,
            'estimatedMinutes': estimatedMinutes,
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          });

      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Updates delivery zone
  Future<void> updateDeliveryZone({
    required String zoneId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _db.collection(HubPaths.deliveryZones).doc(zoneId).update(updates);
    } catch (e) {
      rethrow;
    }
  }

  /// Gets delivery charge and ETA for location
  Future<Map<String, dynamic>?> getDeliveryInfo(
    double latitude,
    double longitude,
  ) async {
    try {
      final zones =
          await _db.collection(HubPaths.deliveryZones).get();

      for (var doc in zones.docs) {
        final zoneData = doc.data();
        final centerLat = zoneData['centerLatitude'] as double;
        final centerLng = zoneData['centerLongitude'] as double;
        final radiusKm = zoneData['radiusKm'] as double;

        final distance = _calculateDistance(latitude, longitude, centerLat, centerLng);

        if (distance <= radiusKm) {
          return {
            'zoneId': doc.id,
            'zoneName': zoneData['zoneName'],
            'deliveryCharge': zoneData['deliveryCharge'],
            'estimatedMinutes': zoneData['estimatedMinutes'],
            'distance': distance,
          };
        }
      }

      return null; // Outside all zones
    } catch (e) {
      return null;
    }
  }

  /// Disables geofence for a zone
  Future<void> disableZone(String zoneId) async {
    try {
      await _db
          .collection(HubPaths.deliveryZones)
          .doc(zoneId)
          .update({'isActive': false});
    } catch (e) {
      rethrow;
    }
  }
}
