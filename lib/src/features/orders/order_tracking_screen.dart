import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/styles.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String? riderUid;

  const OrderTrackingScreen({super.key, required this.orderId, this.riderUid});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  final Set<Marker> _markers = {};

  void _makeCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('লাইভ ট্র্যাকিং (Live Tracking)')),
      body: widget.riderUid == null
          ? const Center(
              child: Text('এই অর্ডারের জন্য কোনো রাইডার এখনো নির্ধারিত হয়নি।'))
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.riderUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data?.data() as Map<String, dynamic>?;
                if (data == null || data['location'] == null) {
                  return const Center(
                      child: Text('রাইডারের লোকেশন পাওয়া যাচ্ছে না।'));
                }

                final GeoPoint pos = data['location'];
                final LatLng riderLatLng = LatLng(pos.latitude, pos.longitude);

                _markers.add(
                  Marker(
                    markerId: const MarkerId('rider'),
                    position: riderLatLng,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure),
                    infoWindow: const InfoWindow(title: 'আপনার রাইডার এখানে'),
                  ),
                );

                return Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition:
                          CameraPosition(target: riderLatLng, zoom: 15),
                      markers: _markers,
                      myLocationEnabled: true,
                      style: isDark ? AppStyles.googleMapDarkStyle : null,
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10)
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: data['profilePic'] != null
                                  ? NetworkImage(data['profilePic'])
                                  : null,
                              child: data['profilePic'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(data['name'] ?? 'রাইডার',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const Text('আপনার অর্ডার নিয়ে আসছেন',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.phone, color: Colors.green),
                              onPressed: () => _makeCall(data['phone']),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

