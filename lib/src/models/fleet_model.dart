import 'package:cloud_firestore/cloud_firestore.dart';

class Rider {
  final String uid;
  final String name;
  final String phone;
  final bool isOnline;
  final bool hasActiveOrder;
  final GeoPoint? location;
  final DateTime? lastUpdate;

  Rider({
    required this.uid,
    required this.name,
    required this.phone,
    required this.isOnline,
    required this.hasActiveOrder,
    this.location,
    this.lastUpdate,
  });

  factory Rider.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Rider(
      uid: doc.id,
      name: data['name'] ?? 'Unknown',
      phone: data['phone'] ?? '',
      isOnline: data['isOnline'] ?? false,
      hasActiveOrder: data['hasActiveOrder'] ?? false,
      location: data['location'] as GeoPoint?,
      lastUpdate: (data['lastUpdate'] as Timestamp?)?.toDate(),
    );
  }
}

class FleetStatus {
  final int activeRiders;
  final int activeVans;
  final int idle;
  final int offline;

  FleetStatus({
    required this.activeRiders,
    required this.activeVans,
    required this.idle,
    required this.offline,
  });

  factory FleetStatus.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FleetStatus(
      activeRiders: data['activeRiders'] ?? 0,
      activeVans: data['activeVans'] ?? 0,
      idle: data['idle'] ?? 0,
      offline: data['offline'] ?? 0,
    );
  }
}

class ShorebirdStatus {
  final String currentVersion;
  final bool patchInstalled;
  final DateTime? lastPatchTime;
  final bool shorebirdAvailable;
  final bool hasUpdateAvailable;

  ShorebirdStatus({
    required this.currentVersion,
    required this.patchInstalled,
    this.lastPatchTime,
    this.shorebirdAvailable = false,
    this.hasUpdateAvailable = false,
  });
}
