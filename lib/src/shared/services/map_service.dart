import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapService {
  Future<BitmapDescriptor> getCustomMarker(String type) async {
    // Logic for loading custom markers (Pharmacy, Blood, Store etc)
    return BitmapDescriptor.defaultMarker;
  }

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(23.8103, 90.4125), // Dhaka
    zoom: 12.0,
  );
}
