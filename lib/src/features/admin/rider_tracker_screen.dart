import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../di/providers.dart';

class RiderTrackerScreen extends ConsumerStatefulWidget {
  const RiderTrackerScreen({super.key});

  @override
  ConsumerState<RiderTrackerScreen> createState() => _RiderTrackerScreenState();
}

class _RiderTrackerScreenState extends ConsumerState<RiderTrackerScreen> {
  GoogleMapController? _mapController;
  final Map<String, Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Rider Tracker',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: () => _fitAllMarkers(),
              icon: const Icon(Icons.zoom_out_map)),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ref.read(locationServiceProvider).getOnlineRiders(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _updateMarkers(snapshot.data!.docs);
          }

          return GoogleMap(
            initialCameraPosition: const CameraPosition(
                target: LatLng(23.8103, 90.4125), zoom: 12),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers.values.toSet(),
            myLocationEnabled: true,
          );
        },
      ),
    );
  }

  void _updateMarkers(List<DocumentSnapshot> docs) {
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint? loc = data['lastLocation'];
      if (loc == null) continue;

      final marker = Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(loc.latitude, loc.longitude),
        infoWindow: InfoWindow(
          title: data['name'] ?? 'Rider',
          snippet: 'Status: Online',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      _markers[doc.id] = marker;
    }
  }

  void _fitAllMarkers() {
    if (_markers.isEmpty) return;
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final m in _markers.values) {
      if (m.position.latitude < minLat) minLat = m.position.latitude;
      if (m.position.latitude > maxLat) maxLat = m.position.latitude;
      if (m.position.longitude < minLng) minLng = m.position.longitude;
      if (m.position.longitude > maxLng) maxLng = m.position.longitude;
    }
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
      LatLngBounds(
          southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)),
      50,
    ));
  }
}
