import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../../../utils/styles.dart';

class QiblaIndicator extends StatefulWidget {
  final double size;
  const QiblaIndicator({super.key, this.size = 200});

  @override
  State<QiblaIndicator> createState() => _QiblaIndicatorState();
}

class _QiblaIndicatorState extends State<QiblaIndicator> {
  // Sensor Data
  double _heading = 0;
  
  // Qibla Data
  double _qiblaAngle = 292.5; // Default for Dhaka
  double _distanceToKaaba = 0;
  
  // UI State
  bool _isCalibrating = false;
  String _statusMessage = 'কিবলা নির্ণয় হচ্ছে...';
  bool _isAligned = false;
  
  StreamSubscription? _magSub;
  StreamSubscription? _posSub;

  // Smoothing Factor
  double _currentSmoothHeading = 0;
  final double _alpha = 0.2; 

  // Kaaba Coordinates
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  @override
  void initState() {
    super.initState();
    _initQibla();
  }

  Future<void> _initQibla() async {
    await _setupLocation();
    _startSensors();
  }

  Future<void> _setupLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _statusMessage = 'লোকেশন সার্ভিস অফ');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _statusMessage = 'পারমিশন প্রয়োজন');
        return;
      }
    }

    // Start real-time location stream for precision
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _qiblaAngle = _calculateQiblaAngle(position.latitude, position.longitude);
          _distanceToKaaba = Geolocator.distanceBetween(position.latitude, position.longitude, _kaabaLat, _kaabaLng) / 1000;
          _statusMessage = 'GPS সিগন্যাল অ্যাক্টিভ';
        });
      }
    });
  }

  double _calculateQiblaAngle(double lat, double lng) {
    final double lat1 = lat * (math.pi / 180);
    final double lng1 = lng * (math.pi / 180);
    const double lat2 = _kaabaLat * (math.pi / 180);
    const double lng2 = _kaabaLng * (math.pi / 180);

    final double dLng = lng2 - lng1;
    final double y = math.sin(dLng) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    final double bearing = math.atan2(y, x) * (180 / math.pi);
    return (bearing + 360) % 360;
  }

  void _startSensors() {
    // Magnetometer for Heading
    _magSub = magnetometerEventStream().listen((MagnetometerEvent event) {
      // Simplified Heading logic
      double heading = math.atan2(-event.x, event.y) * (180 / math.pi);
      heading = (heading + 360) % 360;

      // Circular Interpolation for smooth wrap-around
      final double diff = (heading - _currentSmoothHeading + 180) % 360 - 180;
      _currentSmoothHeading = (_currentSmoothHeading + _alpha * diff + 360) % 360;

      final double relativeAngle = (_qiblaAngle - _currentSmoothHeading + 360) % 360;
      final bool aligned = relativeAngle < 5 || relativeAngle > 355;

      if (mounted) {
        setState(() {
          _heading = _currentSmoothHeading;
          _isAligned = aligned;
        });
      }
    });
  }

  void _startCalibration() {
    setState(() => _isCalibrating = true);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isCalibrating = false);
    });
  }

  @override
  void dispose() {
    _magSub?.cancel();
    _posSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double relativeAngle = (_qiblaAngle - _heading + 360) % 360;
    final double turns = -relativeAngle / 360;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _startCalibration,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Compass Base
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                      ? [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.02)]
                      : [Colors.grey[100]!, Colors.grey[300]!],
                  ),
                  border: Border.all(
                    color: _isAligned ? Colors.green.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.2), 
                    width: 2
                  ),
                  boxShadow: [
                    if (_isAligned) 
                      BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 25, spreadRadius: 5),
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
              ),

              // Degree Markers
              ..._buildMarkers(isDark),

              // Qibla Needle
              AnimatedRotation(
                turns: turns,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 15,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isAligned ? Colors.green : (isDark ? Colors.amber : AppStyles.primaryColor),
                                shape: BoxShape.circle,
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                              ),
                              child: Text('🕋', style: TextStyle(fontSize: widget.size * 0.12)),
                            ),
                            Icon(Icons.arrow_drop_up_rounded, 
                              color: _isAligned ? Colors.green : AppStyles.primaryColor, 
                              size: 30
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Calibration Overlay
              if (_isCalibrating)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 2 * math.pi),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) => Transform.rotate(
                    angle: value,
                    child: Icon(Icons.sync_problem_rounded, color: Colors.blue.withValues(alpha: 0.5), size: 60),
                  ),
                ),
                
              // Distance display
              if (_distanceToKaaba > 0)
                Positioned(
                  bottom: widget.size * 0.25,
                  child: Text(
                    '${_distanceToKaaba.toStringAsFixed(0)} KM',
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.w900, 
                      color: isDark ? Colors.white38 : Colors.black38,
                      letterSpacing: 1
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _isAligned ? Colors.green.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isAligned ? Icons.gps_fixed_rounded : Icons.compass_calibration_rounded,
                size: 14,
                color: _isAligned ? Colors.green : (isDark ? Colors.white54 : Colors.grey),
              ),
              const SizedBox(width: 8),
              Text(
                _isAligned ? 'নিখুঁত কিবলা মুখী' : _statusMessage.toUpperCase(),
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 0.5,
                  color: _isAligned ? Colors.green : (isDark ? Colors.white54 : Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMarkers(bool isDark) {
    return List.generate(8, (i) {
      return Transform.rotate(
        angle: (i * 45) * (math.pi / 180),
        child: Container(
          height: widget.size - 20,
          width: 2,
          alignment: Alignment.topCenter,
          child: Container(
            height: 6,
            width: 2,
            decoration: BoxDecoration(
              color: i == 0 ? Colors.red : (isDark ? Colors.white24 : Colors.black12),
              borderRadius: BorderRadius.circular(2)
            ),
          ),
        ),
      );
    });
  }
}
