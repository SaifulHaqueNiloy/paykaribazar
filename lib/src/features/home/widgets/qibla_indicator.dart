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
  final double _alpha = 0.15; 

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
    try {
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

      // Initial position
      final Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _qiblaAngle = _calculateQiblaAngle(position.latitude, position.longitude);
          _distanceToKaaba = Geolocator.distanceBetween(position.latitude, position.longitude, _kaabaLat, _kaabaLng) / 1000;
        });
      }

      // Stream for updates
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
    } catch (e) {
      if (mounted) setState(() => _statusMessage = 'ত্রুটি: $e');
    }
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
    _magSub = magnetometerEventStream().listen((MagnetometerEvent event) {
      double heading = math.atan2(-event.x, event.y) * (180 / math.pi);
      heading = (heading + 360) % 360;

      final double diff = (heading - _currentSmoothHeading + 180) % 360 - 180;
      _currentSmoothHeading = (_currentSmoothHeading + _alpha * diff + 360) % 360;

      final double relativeAngle = (_qiblaAngle - _currentSmoothHeading + 360) % 360;
      final bool aligned = relativeAngle < 8 || relativeAngle > 352;

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
    Future.delayed(const Duration(seconds: 3), () {
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration(isDark),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QIBLA FINDER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                  Text('দিক নির্ণয় করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                onPressed: _startCalibration,
                icon: Icon(Icons.refresh_rounded, color: isDark ? Colors.white38 : Colors.black26),
              )
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              // Compass Base
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey[50],
                  border: Border.all(
                    color: _isAligned ? Colors.teal.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.1), 
                    width: 2
                  ),
                  boxShadow: [
                    if (_isAligned) 
                      BoxShadow(color: Colors.teal.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5),
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
                                color: _isAligned ? Colors.teal : AppStyles.primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                              ),
                              child: Text('🕋', style: TextStyle(fontSize: widget.size * 0.1)),
                            ),
                            Icon(Icons.arrow_drop_up_rounded, 
                              color: _isAligned ? Colors.teal : AppStyles.primaryColor, 
                              size: 30
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isCalibrating)
                const CircularProgressIndicator(strokeWidth: 2, color: Colors.teal),
                
              if (_distanceToKaaba > 0)
                Positioned(
                  bottom: widget.size * 0.25,
                  child: Text(
                    '${_distanceToKaaba.toStringAsFixed(0)} KM TO MECCA',
                    style: TextStyle(
                      fontSize: 8, 
                      fontWeight: FontWeight.w900, 
                      color: isDark ? Colors.white24 : Colors.black26,
                      letterSpacing: 1
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isAligned ? Colors.teal.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isAligned ? 'নিখুঁত কিবলা মুখী' : _statusMessage.toUpperCase(),
              style: TextStyle(
                fontSize: 11, 
                fontWeight: FontWeight.bold, 
                color: _isAligned ? Colors.teal : Colors.grey,
              ),
            ),
          ),
        ],
      ),
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
            height: 8,
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

