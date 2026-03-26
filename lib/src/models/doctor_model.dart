class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String? chamber;
  final String? visitingDays;
  final String? visitingHours;
  final String? visitFee;
  final String? contactNumber;
  final String? imageUrl;
  final String district;
  final String upazila;
  final String? phone;
  final bool isVisible;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    this.chamber,
    this.visitingDays,
    this.visitingHours,
    this.visitFee,
    this.contactNumber,
    this.imageUrl,
    this.district = '',
    this.upazila = '',
    this.phone,
    this.isVisible = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'specialization': specialization,
    'chamber': chamber,
    'visitingDays': visitingDays,
    'visitingHours': visitingHours,
    'visitFee': visitFee,
    'contactNumber': contactNumber,
    'imageUrl': imageUrl,
    'district': district,
    'upazila': upazila,
    'phone': phone,
    'isVisible': isVisible,
  };

  factory Doctor.fromMap(Map<String, dynamic> map) => Doctor(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    specialization: map['specialization'] ?? map['specialty'] ?? '',
    chamber: map['chamber'] ?? '',
    visitingDays: map['visitingDays'] ?? '',
    visitingHours: map['visitingHours'] ?? '',
    visitFee: map['visitFee'] ?? '',
    contactNumber: map['contactNumber'] ?? '',
    imageUrl: map['imageUrl'],
    district: map['district'] ?? '',
    upazila: map['upazila'] ?? '',
    phone: map['phone'] ?? map['contactNumber'] ?? '',
    isVisible: map['isVisible'] ?? true,
  );

  // Getter for backward compatibility
  String get specialty => specialization;
}
