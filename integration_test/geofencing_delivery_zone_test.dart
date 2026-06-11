import 'package:flutter_test/flutter_test.dart';
import 'package:paykari_bazar/src/features/logistics/services/geofencing_service.dart';

void main() {
  group('Geofencing Delivery Zone Tests', () {
    test('GeofencingService can be instantiated', () {
      final service = GeofencingService();
      expect(service, isNotNull);
    });

    test('distance calculation returns 0 for same coordinates', () {
      final service = GeofencingService();
      final distance = service._calculateDistance(23.8103, 90.4125, 23.8103, 90.4125);
      expect(distance, closeTo(0.0, 0.01));
    });

    test('distance calculation for known locations', () {
      final service = GeofencingService();
      final distance = service._calculateDistance(23.8103, 90.4125, 23.8200, 90.4200);
      expect(distance, greaterThan(0.0));
      expect(distance, lessThan(5.0));
    });

    test('distance increases with coordinate difference', () {
      final service = GeofencingService();
      final shortDist = service._calculateDistance(23.8103, 90.4125, 23.8150, 90.4150);
      final longDist = service._calculateDistance(23.8103, 90.4125, 24.0000, 91.0000);
      expect(longDist, greaterThan(shortDist));
    });
  });
}
