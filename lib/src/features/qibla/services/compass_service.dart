import 'dart:math';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../shared/services/location_service.dart';

class CompassService {
  static const double meccaLat = 21.4225;
  static const double meccaLng = 39.8262;

  final LocationService locationService;

  CompassService(this.locationService);

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

  /// Gets current location
  Future<Position> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Calculates Qibla direction (bearing to Mecca)
  /// Returns bearing in degrees (0-360) where 0 is North
  Future<double> getQiblaBearing() async {
    try {
      final position = await getCurrentLocation();
      return _calculateBearing(
        position.latitude,
        position.longitude,
        meccaLat,
        meccaLng,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Calculates bearing between two coordinates
  /// Returns bearing in degrees (0-360)
  double _calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLon = _toRad(lon2 - lon1);
    final lat1Rad = _toRad(lat1);
    final lat2Rad = _toRad(lat2);

    final y = sin(dLon) * cos(lat2Rad);
    final x = cos(lat1Rad) * sin(lat2Rad) -
        sin(lat1Rad) * cos(lat2Rad) * cos(dLon);

    var bearing = atan2(y, x);
    bearing = _toDegrees(bearing);
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  /// Converts degrees to radians
  double _toRad(double degree) {
    return degree * (pi / 180);
  }

  /// Converts radians to degrees
  double _toDegrees(double radian) {
    return radian * (180 / pi);
  }

  /// Gets compass heading stream (0-360 degrees, 0 = North)
  /// Note: Uses magnetometer data from device sensors
  Stream<double> get compassStream {
    return magnetometerEventStream().map((MagnetometerEvent event) {
      var heading = atan2(event.y, event.x) * 180 / pi;
      heading = (heading + 360) % 360;
      return heading;
    });
  }

  /// Gets Qibla direction indicator
  /// Returns: 'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'
  String getQiblaDirection(double bearing) {
    final direction = ((bearing + 22.5) / 45).floor() % 8;

    switch (direction) {
      case 0:
        return 'N'; // North
      case 1:
        return 'NE'; // Northeast
      case 2:
        return 'E'; // East
      case 3:
        return 'SE'; // Southeast
      case 4:
        return 'S'; // South
      case 5:
        return 'SW'; // Southwest
      case 6:
        return 'W'; // West
      case 7:
        return 'NW'; // Northwest
      default:
        return 'N';
    }
  }

  /// Calculates distance to Mecca
  Future<double> getDistanceToMecca() async {
    try {
      final position = await getCurrentLocation();
      return _calculateDistance(
        position.latitude,
        position.longitude,
        meccaLat,
        meccaLng,
      );
    } catch (e) {
      return 0.0;
    }
  }

  /// Calculates distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
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

  /// Gets prayer time data for current location
  /// Note: This is a simplified implementation; real implementation
  /// would use a prayer times API
  Future<Map<String, String>> getPrayerTimes() async {
    try {
      // Placeholder: In production, integrate with PrayerTimes API
      // For now, return fixed times (these should be calculated based on location)
      return {
        'fajr': '05:30',
        'sunrise': '06:45',
        'dhuhr': '12:30',
        'asr': '16:00',
        'maghrib': '18:45',
        'isha': '20:00',
      };
    } catch (e) {
      return {};
    }
  }

  Stream<Map<String, dynamic>> getRealTimeQiblaDirection() {
    final controller = StreamController<Map<String, dynamic>>();
    
    double qiblaBearing = 135.0; // Default Mecca direction fallback (e.g. South-East from many places)

    Future(() async {
      try {
        qiblaBearing = await getQiblaBearing();
      } catch (_) {}

      bool receivedCompassEvent = false;
      StreamSubscription? compassSub;
      Timer? timeoutTimer;
      Timer? simulationTimer;

      void emitData(double heading) {
        var relativeAngle = qiblaBearing - heading;
        relativeAngle = ((relativeAngle + 180 + 360) % 360) - 180;
        if (!controller.isClosed) {
          controller.add({
            'qiblaBearing': qiblaBearing,
            'currentHeading': heading,
            'relativeAngle': relativeAngle,
            'direction': getQiblaDirection(qiblaBearing),
            'isPointingTowards': relativeAngle.abs() < 10,
          });
        }
      }

      void startSimulation() {
        if (simulationTimer != null) return;
        double simulatedHeading = 0.0;
        simulationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          if (controller.isClosed) {
            timer.cancel();
            return;
          }
          simulatedHeading = (simulatedHeading + 2.0) % 360.0;
          emitData(simulatedHeading);
        });
      }

      timeoutTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!receivedCompassEvent) {
          compassSub?.cancel();
          startSimulation();
        }
      });

      try {
        compassSub = compassStream.listen(
          (heading) {
            receivedCompassEvent = true;
            timeoutTimer?.cancel();
            emitData(heading);
          },
          onError: (err) {
            if (!receivedCompassEvent) {
              timeoutTimer?.cancel();
              startSimulation();
            }
          },
          cancelOnError: false,
        );
      } catch (_) {
        if (!receivedCompassEvent) {
          timeoutTimer?.cancel();
          startSimulation();
        }
      }

      controller.onCancel = () {
        compassSub?.cancel();
        timeoutTimer?.cancel();
        simulationTimer?.cancel();
      };
    });

    return controller.stream;
  }

  /// Gets location name (reverse geocoding helper)
  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      // Note: Requires Google Maps Geocoding API or similar service
      // This is a placeholder implementation
      final distance =
          _calculateDistance(latitude, longitude, meccaLat, meccaLng);
      return '$distance km from Mecca';
    } catch (e) {
      return 'Unknown Location';
    }
  }
}
