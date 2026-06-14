import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../di/providers.dart';
import '../../utils/styles.dart';
import '../../utils/app_strings.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String? _selectedDistrict, _selectedUpazila, _selectedStation, _selectedArea;
  File? _imageFile;
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  void _loadUserData(Map<String, dynamic>? userData) {
    if (_initialized || userData == null) return;
    _nameCtrl.text = userData['name'] ?? '';
    _phoneCtrl.text = userData['phone'] ?? '';
    _emailCtrl.text = userData['email'] ?? '';
    _selectedDistrict = userData['districtId'];
    _selectedUpazila = userData['upazilaId'];
    _selectedStation = userData['stationId'];
    _selectedArea = userData['areaId'];
    _initialized = true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await ref.read(firestoreServiceProvider).uploadImage(_imageFile!, 'profiles');
      }

      final updates = {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'districtId': _selectedDistrict,
        'upazilaId': _selectedUpazila,
        'stationId': _selectedStation,
        'areaId': _selectedArea,
        if (imageUrl != null) 'profilePic': imageUrl,
      };

      await ref.read(firestoreServiceProvider).updateProfile(uid, updates);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.get('updateSuccess', ref.read(languageProvider).languageCode)), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider).languageCode;
    final userData = ref.watch(currentUserDataProvider).value;
    if (!_initialized && userData != null) {
      _loadUserData(userData);
    }
    String t(String k) => AppStrings.get(k, lang);

    return Scaffold(
      backgroundColor: isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      appBar: AppBar(
        title: Text(t('hubActionEdit'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageFile != null 
                        ? FileImage(_imageFile!) 
                        : (userData?['profilePic'] != null 
                            ? NetworkImage(userData!['profilePic']) 
                            : null) as ImageProvider?,
                    child: _imageFile == null && userData?['profilePic'] == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: AppStyles.primaryColor,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameCtrl,
              decoration: AppStyles.inputDecoration(t('fullName'), isDark, prefix: const Icon(Icons.person)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneCtrl,
              enabled: false,
              decoration: AppStyles.inputDecoration(t('mobileNumber'), isDark, prefix: const Icon(Icons.phone)).copyWith(
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              decoration: AppStyles.inputDecoration(t('emailAddress'), isDark, prefix: const Icon(Icons.email)),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Synced Location Selection
            Consumer(
              builder: (context, ref, child) {
                final locationsAsync = ref.watch(visibleLocationsProvider);
                return locationsAsync.when(
                  data: (locations) {
                    final districts = locations.where((l) => 
                      l['type']?.toString().toLowerCase() == 'district'
                    ).toList();

                    // SMART MATCHING: Resolve Name to ID if needed
                    // বাংলা: নাম থেকে আইডি কনভার্ট করে সঠিক অপশন সিলেক্ট করা হচ্ছে
                    if (_selectedDistrict != null && !districts.any((d) => d['id'] == _selectedDistrict)) {
                      final match = districts.firstWhere(
                        (d) => d['name'] == _selectedDistrict, 
                        orElse: () => <String, dynamic>{}
                      );
                      if (match.isNotEmpty) {
                        _selectedDistrict = match['id'];
                      }
                    }
                    
                    final upazilas = locations.where((l) {
                      final isUpazila = l['type']?.toString().toLowerCase() == 'upazila';
                      final matchesParentId = l['parentId'] == _selectedDistrict;
                      
                      bool matchesParentName = false;
                      if (!matchesParentId && _selectedDistrict != null) {
                        final parentDist = districts.firstWhere(
                          (d) => d['id'] == _selectedDistrict, 
                          orElse: () => <String, dynamic>{}
                        );
                        matchesParentName = l['parentId'] == parentDist['name'];
                      }
                      return isUpazila && (matchesParentId || matchesParentName);
                    }).toList();

                    // SMART MATCHING for Upazila
                    if (_selectedUpazila != null && !upazilas.any((u) => u['id'] == _selectedUpazila)) {
                      final match = upazilas.firstWhere(
                        (u) => u['name'] == _selectedUpazila, 
                        orElse: () => <String, dynamic>{}
                      );
                      if (match.isNotEmpty) {
                        _selectedUpazila = match['id'];
                      }
                    }

                    final stations = locations.where((l) =>
                      l['type']?.toString().toLowerCase() == 'station' && l['parentId'] == _selectedUpazila
                    ).toList();

                    if (_selectedStation != null && !stations.any((s) => s['id'] == _selectedStation)) {
                      final match = stations.firstWhere(
                        (s) => s['name'] == _selectedStation, 
                        orElse: () => <String, dynamic>{}
                      );
                      if (match.isNotEmpty) {
                        _selectedStation = match['id'];
                      }
                    }

                    final areas = locations.where((l) =>
                      l['type']?.toString().toLowerCase() == 'area' && l['parentId'] == _selectedStation
                    ).toList();

                    if (_selectedArea != null && !areas.any((a) => a['id'] == _selectedArea)) {
                      final match = areas.firstWhere(
                        (a) => a['name'] == _selectedArea, 
                        orElse: () => <String, dynamic>{}
                      );
                      if (match.isNotEmpty) {
                        _selectedArea = match['id'];
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('locationAdded'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 12),
                        _buildDropdown(t('selectDistrict'), _selectedDistrict, districts, (v) {
                          setState(() {
                            _selectedDistrict = v;
                            _selectedUpazila = null;
                            _selectedStation = null;
                            _selectedArea = null;
                          });
                        }, isDark),
                        const SizedBox(height: 12),
                        _buildDropdown(t('selectUpazila'), _selectedUpazila, upazilas, (v) {
                          setState(() {
                            _selectedUpazila = v;
                            _selectedStation = null;
                            _selectedArea = null;
                          });
                        }, isDark, enabled: _selectedDistrict != null),
                        const SizedBox(height: 12),
                        _buildDropdown(lang == 'bn' ? 'স্টেশন / বাজার নির্বাচন করুন' : 'Select Station / Bazar', _selectedStation, stations, (v) {
                          setState(() {
                            _selectedStation = v;
                            _selectedArea = null;
                          });
                        }, isDark, enabled: _selectedUpazila != null),
                        const SizedBox(height: 12),
                        _buildDropdown(lang == 'bn' ? 'সাবস্টেশন / এলাকা নির্বাচন করুন' : 'Select Substation / Specific Area', _selectedArea, areas, (v) {
                          setState(() {
                            _selectedArea = v;
                          });
                        }, isDark, enabled: _selectedStation != null),
                        if (_selectedArea != null) ...[
                          const SizedBox(height: 8),
                          Builder(builder: (context) {
                            final matchArea = areas.firstWhere((a) => a['id'] == _selectedArea, orElse: () => <String, dynamic>{});
                            final baseCharge = matchArea['baseCharge'] ?? 30.0;
                            return Text(
                              lang == 'bn' ? 'ডেলিভারি চার্জ: ৳${baseCharge.toInt()}' : 'Delivery Charge: ৳${baseCharge.toInt()}',
                              style: const TextStyle(color: AppStyles.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
                            );
                          }),
                        ],
                      ],
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, s) => Text('Error loading locations: $e'),
                );
              },
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(t('save'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<Map<String, dynamic>> items, Function(String?) onChanged, bool isDark, {bool enabled = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(label, style: const TextStyle(fontSize: 14)),
            value: value,
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            items: items.map<DropdownMenuItem<String>>((i) => DropdownMenuItem<String>(
              value: i['id']?.toString(),
              child: Text(i['name'] ?? 'Unknown', style: const TextStyle(fontSize: 14)),
            )).toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ),
    );
  }
}

