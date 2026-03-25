// --- USER & IDENTITY MODELS ---

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
    required this.id, required this.name, required this.district, required this.upazila, 
    required this.station, required this.area, this.areaId, required this.detailedAddress, 
    this.deliveryCharge = 0.0, this.isDefault = false, this.latitude, this.longitude,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'district': district, 'upazila': upazila, 
    'station': station, 'area': area, 'areaId': areaId, 
    'detailedAddress': detailedAddress, 'deliveryCharge': deliveryCharge, 
    'isDefault': isDefault, 'latitude': latitude, 'longitude': longitude,
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
  final String currentMode;

  UserModel({
    required this.id, required this.name, required this.phone, this.email = '', 
    this.role = UserRole.customer, this.addresses = const [], this.profilePic, 
    this.points = 0, this.currentMode = 'shopping',
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'phone': phone, 'email': email, 'role': role.name, 
    'addresses': addresses.map((a) => a.toMap()).toList(), 'profilePic': profilePic, 
    'points': points, 'currentMode': currentMode,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id']?.toString() ?? '',
    name: map['name']?.toString() ?? '',
    phone: map['phone']?.toString() ?? '',
    email: map['email']?.toString() ?? '',
    role: UserRole.values.firstWhere((e) => e.name == (map['role'] ?? 'customer'), orElse: () => UserRole.customer),
    addresses: (map['addresses'] as List? ?? []).map((a) => AddressModel.fromMap(Map<String, dynamic>.from(a))).toList(),
    profilePic: map['profilePic'],
    points: (map['points'] ?? 0).toInt(),
    currentMode: map['currentMode']?.toString() ?? 'shopping',
  );
}

// --- COMMERCE & PRODUCT MODELS ---

class Variant {
  final String id, name, nameBn;
  final double price;
  final int stock;

  Variant({required this.id, required this.name, required this.nameBn, required this.price, required this.stock});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'nameBn': nameBn, 'price': price, 'stock': stock};
  factory Variant.fromMap(Map<String, dynamic> map) => Variant(
    id: map['id'] ?? '', name: map['name'] ?? '', nameBn: map['nameBn'] ?? '',
    price: (map['price'] ?? 0.0).toDouble(), stock: (map['stock'] ?? 0).toInt(),
  );
}

class Product {
  final String id, sku, name, nameBn, categoryId, categoryName, imageUrl;
  final double price, oldPrice;
  final int stock;
  final List<Variant> variants;

  Product({
    required this.id, required this.sku, required this.name, required this.nameBn, 
    required this.categoryId, required this.categoryName, required this.imageUrl,
    required this.price, this.oldPrice = 0, required this.stock, this.variants = const [],
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) => Product(
    id: id, sku: map['sku'] ?? '', name: map['name'] ?? '', nameBn: map['nameBn'] ?? '',
    categoryId: map['categoryId'] ?? '', categoryName: map['categoryName'] ?? '',
    imageUrl: map['imageUrl'] ?? '', price: (map['price'] ?? 0.0).toDouble(),
    oldPrice: (map['oldPrice'] ?? 0.0).toDouble(), stock: (map['stock'] ?? 0).toInt(),
    variants: (map['variants'] as List? ?? []).map((v) => Variant.fromMap(Map<String, dynamic>.from(v))).toList(),
  );
}

// --- LOGISTICS & MISC MODELS ---

class BloodDonor {
  final String id, name, bloodGroup;
  final String? phone;
  final String district, upazila;

  BloodDonor({required this.id, required this.name, required this.bloodGroup, this.phone, required this.district, required this.upazila});

  factory BloodDonor.fromMap(Map<String, dynamic> map) => BloodDonor(
    id: map['id'] ?? '', name: map['name'] ?? '', bloodGroup: map['bloodGroup'] ?? '',
    phone: map['phone'], district: map['district'] ?? '', upazila: map['upazila'] ?? '',
  );
}
