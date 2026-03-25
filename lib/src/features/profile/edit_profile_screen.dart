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
  String? _selectedDistrict, _selectedUpazila;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userData = ref.read(currentUserDataProvider).value;
    if (userData != null) {
      _nameCtrl.text = userData['name'] ?? '';
      _phoneCtrl.text = userData['phone'] ?? '';
      _emailCtrl.text = userData['email'] ?? '';
      _selectedDistrict = userData['districtId'];
      _selectedUpazila = userData['upazilaId'];
    }
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
                    final districts = locations.where((l) => l['type'] == 'district').toList();
                    final upazilas = locations.where((l) => l['type'] == 'upazila' && l['parentId'] == _selectedDistrict).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('locationAdded'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 12),
                        _buildDropdown(t('selectDistrict'), _selectedDistrict, districts, (v) {
                          setState(() {
                            _selectedDistrict = v;
                            _selectedUpazila = null;
                          });
                        }, isDark),
                        const SizedBox(height: 12),
                        _buildDropdown(t('selectUpazila'), _selectedUpazila, upazilas, (v) {
                          setState(() => _selectedUpazila = v);
                        }, isDark, enabled: _selectedDistrict != null),
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
