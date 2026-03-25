import 'package:cloud_firestore/cloud_firestore.dart';

class BloodDonor {
  final String id;
  final String name;
  final String bloodGroup;
  final String? contactNumber;
  final DateTime? lastDonated;
  final String? userUid;
  final String? imageUrl;
  final String district;
  final String upazila;
  final String? phone;
  final bool isVisible;

  BloodDonor({
    required this.id,
    required this.name,
    required this.bloodGroup,
    this.contactNumber,
    this.lastDonated,
    this.userUid,
    this.imageUrl,
    this.district = '',
    this.upazila = '',
    this.phone,
    this.isVisible = true,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'bloodGroup': bloodGroup,
    'contactNumber': contactNumber ?? phone,
    'lastDonated': lastDonated,
    'userUid': userUid,
    'imageUrl': imageUrl,
    'district': district,
    'upazila': upazila,
    'phone': phone ?? contactNumber,
    'isVisible': isVisible,
  };

  factory BloodDonor.fromMap(Map<String, dynamic> map) => BloodDonor(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    bloodGroup: map['bloodGroup'] ?? '',
    contactNumber: map['contactNumber'] ?? map['phone'] ?? '',
    lastDonated: map['lastDonated'] != null ? (map['lastDonated'] as Timestamp).toDate() : null,
    userUid: map['userUid'],
    imageUrl: map['imageUrl'],
    district: map['district'] ?? '',
    upazila: map['upazila'] ?? '',
    phone: map['phone'] ?? map['contactNumber'] ?? '',
    isVisible: map['isVisible'] ?? true,
  );
}
