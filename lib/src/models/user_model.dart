
enum UserRole { admin, staff, vendor, logistic, marketing, accountsFinance, reseller, customer }

class AddressModel {
  final String id;
  final String name; 
  final String district; 
  final String upazila;
  final String station;
  final String area;
  final String? areaId;
  final String detailedAddress;
  final double deliveryCharge; 
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  AddressModel({
    required this.id,
    required this.name,
    required this.district,
    required this.upazila,
    required this.station,
    required this.area,
    this.areaId,
    required this.detailedAddress,
    this.deliveryCharge = 0.0,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'district': district, 'upazila': upazila, 
    'station': station, 'area': area, 'areaId': areaId, 
    'detailedAddress': detailedAddress, 
    'deliveryCharge': deliveryCharge, 'isDefault': isDefault,
    'latitude': latitude, 'longitude': longitude,
  };

  factory AddressModel.fromMap(Map<String, dynamic> map) => AddressModel(
    id: map['id']?.toString() ?? '',
    name: map['name']?.toString() ?? '',
    district: map['district']?.toString() ?? '',
    upazila: map['upazila']?.toString() ?? '',
    station: map['station']?.toString() ?? '',
    area: map['area']?.toString() ?? '',
    areaId: map['areaId']?.toString(),
    detailedAddress: map['detailedAddress']?.toString() ?? '',
    deliveryCharge: (map['deliveryCharge'] ?? 0.0).toDouble(),
    isDefault: map['isDefault'] ?? false,
    latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
    longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
  );

  String get fullAddress => '$detailedAddress, $area, $station, $upazila, $district';
}

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final List<AddressModel> addresses;
  final String? profilePic;
  final int points;
  final String? myReferralCode;
  final String currentMode; // 'shopping' or 'work'
  
  final String? q1, a1, h1, q2, a2, h2, q3, a3, h3;

  final double storageUsed;
  final double storageLimit;
  final bool isSubscribed;

  UserModel({
    required this.id, required this.name, required this.phone,
    this.email = '', this.role = UserRole.customer,
    this.addresses = const [], this.profilePic, this.points = 0,
    this.myReferralCode, 
    this.currentMode = 'shopping',
    this.q1, this.a1, this.h1,
    this.q2, this.a2, this.h2,
    this.q3, this.a3, this.h3,
    this.storageUsed = 0.0,
    this.storageLimit = 100.0,
    this.isSubscribed = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'phone': phone, 'email': email,
    'role': role.name, 'addresses': addresses.map((a) => a.toMap()).toList(),
    'profilePic': profilePic, 'points': points,
    'myReferralCode': myReferralCode,
    'currentMode': currentMode,
    'q1': q1, 'a1': a1, 'h1': h1,
    'q2': q2, 'a2': a2, 'h2': h2,
    'q3': q3, 'a3': a3, 'h3': h3,
    'storageUsed': storageUsed, 'storageLimit': storageLimit,
    'isSubscribed': isSubscribed,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final addrData = map['addresses'] as List? ?? [];
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: UserRole.values.firstWhere((e) => e.name == (map['role'] ?? 'customer'), orElse: () => UserRole.customer),
      addresses: addrData.map((a) => AddressModel.fromMap(Map<String, dynamic>.from(a))).toList(),
      profilePic: map['profilePic']?.toString(),
      points: (map['points'] ?? 0).toInt(),
      myReferralCode: map['myReferralCode']?.toString(),
      currentMode: map['currentMode']?.toString() ?? 'shopping',
      q1: map['q1']?.toString(), a1: map['a1']?.toString(), h1: map['h1']?.toString(),
      q2: map['q2']?.toString(), a2: map['a2']?.toString(), h2: map['h2']?.toString(),
      q3: map['q3']?.toString(), a3: map['a3']?.toString(), h3: map['h3']?.toString(),
      storageUsed: (map['storageUsed'] ?? 0.0).toDouble(),
      storageLimit: (map['storageLimit'] ?? 100.0).toDouble(),
      isSubscribed: map['isSubscribed'] ?? false,
    );
  }

  AddressModel? get defaultAddress {
    try { return addresses.firstWhere((a) => a.isDefault); } catch (_) { return addresses.isNotEmpty ? addresses.first : null; }
  }
}
