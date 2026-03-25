import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/styles.dart';
import '../../utils/app_strings.dart';
import '../../di/providers.dart';

class EmergencyDetailsScreen extends ConsumerStatefulWidget {
  final String? category;
  const EmergencyDetailsScreen({super.key, this.category});

  @override
  ConsumerState<EmergencyDetailsScreen> createState() =>
      _EmergencyDetailsScreenState();
}

class _EmergencyDetailsScreenState
    extends ConsumerState<EmergencyDetailsScreen> {
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _bagsController = TextEditingController();

  String _selectedService = 'pharmacy';
  String? _selectedBloodGroup;
  String? _selectedPatientType;
  File? _prescriptionImage;

  String? _selectedDistrict, _selectedUpazila;
  bool _isSubmitting = false;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-'
  ];
  final List<String> _patientTypes = [
    'child',
    'youth',
    'elderly',
    'pregnantMother',
    'seriouslyIll',
    'criticallyInjured'
  ];

  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  void dispose() {
    _medicineController.dispose();
    _hospitalController.dispose();
    _bagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _prescriptionImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F2F5),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 16),
                if (_selectedService == 'pharmacy')
                  _buildDetailedMedicineForm(isDark),
                if (_selectedService == 'blood')
                  _buildDetailedBloodForm(isDark),
                if (_selectedService == 'helpline')
                  _buildHelplineSection(isDark),
                const SizedBox(height: 8),
                _buildDoctorsListSection(isDark),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 25,
            right: 20,
            child: _buildFloatingCart(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFF4D4D),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      child: Column(
        children: [
          Text(
            _t('emergencyService'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _serviceHeaderBtn(
                  Icons.medical_services, _t('pharmacy'), 'pharmacy'),
              _serviceHeaderBtn(Icons.bloodtype, _t('bloodAid'), 'blood'),
              _serviceHeaderBtn(
                  Icons.phone_in_talk, _t('helpline'), 'helpline'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceHeaderBtn(IconData icon, String label, String service) {
    final bool isSelected = _selectedService == service;
    return GestureDetector(
      onTap: () => setState(() => _selectedService = service),
      child: Column(
        children: [
          Icon(icon,
              color: isSelected ? Colors.white : Colors.white70, size: 26),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 6),
              height: 3,
              width: 15,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(2)),
            )
        ],
      ),
    );
  }

  Widget _buildDetailedMedicineForm(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_t('medicineDetails'),
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: _medicineController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: _t('medicineNamesHint'),
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 12),
          _buildImagePicker(isDark),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : () => _submitOrder('medicine'),
              icon: const Icon(Icons.shopping_cart_rounded, size: 16),
              label: Text(_t('reorderBtn').toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6200EE),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBloodForm(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_t('bloodRequest'),
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _formDropdown(
                    _t('bloodGroup'),
                    _selectedBloodGroup,
                    _bloodGroups,
                    (v) => setState(() => _selectedBloodGroup = v),
                    isDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _bagsController,
                  keyboardType: TextInputType.number,
                  decoration:
                      AppStyles.inputDecoration(_t('bagsNeeded'), isDark)
                          .copyWith(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _formDropdown(_t('patientType'), _selectedPatientType, _patientTypes,
              (v) => setState(() => _selectedPatientType = v), isDark,
              isTranslatable: true),
          const SizedBox(height: 12),
          TextField(
            controller: _hospitalController,
            decoration: AppStyles.inputDecoration(_t('hospitalArea'), isDark),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : () => _submitOrder('blood'),
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text(_t('bloodRequest').toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formDropdown(String label, String? value, List<String> items,
      Function(String?) onChanged, bool isDark,
      {bool isTranslatable = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(label, style: const TextStyle(fontSize: 12)),
          value: value,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          items: items
              .map<DropdownMenuItem<String>>((e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(isTranslatable ? _t(e) : e,
                      style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isDark) {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _prescriptionImage != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Text('Prescription Attached',
                      style: TextStyle(fontSize: 12)),
                  IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () =>
                          setState(() => _prescriptionImage = null)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded,
                      size: 20, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Text(_t('attachPrescription'),
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
      ),
    );
  }

  Widget _buildHelplineSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(child: Text('Emergency Helplines are listed below')),
    );
  }

  Widget _buildDoctorsListSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.people_alt_rounded,
                  size: 18, color: Color(0xFF6200EE)),
              const SizedBox(width: 8),
              Text(_t('doctors'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
        ),
        _buildFilters(isDark),
        const SizedBox(height: 16),
        _buildDocsStream(isDark),
      ],
    );
  }

  Widget _buildFilters(bool isDark) {
    final locationsAsync = ref.watch(visibleLocationsProvider);

    return locationsAsync.when(
      data: (locations) {
        final districts =
            locations.where((l) => l['type'] == 'district').toList();
        final upazilas = locations
            .where((l) =>
                l['type'] == 'upazila' && l['parentId'] == _selectedDistrict)
            .toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _filterDropdown(
                  _t('selectDistrict'), _selectedDistrict, districts, (v) {
                setState(() {
                  _selectedDistrict = v;
                  _selectedUpazila = null;
                });
              }, isDark),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _filterDropdown(
                        _t('selectUpazila'), _selectedUpazila, upazilas, (v) {
                      setState(() => _selectedUpazila = v);
                    }, isDark, enabled: _selectedDistrict != null),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (e, s) => Text('Error loading locations: $e'),
    );
  }

  Widget _filterDropdown(
      String hint,
      String? value,
      List<Map<String, dynamic>> items,
      Function(String?) onChanged,
      bool isDark,
      {bool enabled = true}) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(hint,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
            value: value,
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            items: items
                .map<DropdownMenuItem<String>>((i) => DropdownMenuItem<String>(
                      value: i['id'].toString(),
                      child: Text(i['name'] ?? 'Unknown',
                          style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDocsStream(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection(HubPaths.doctors).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator()));
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(
              child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text('লোকাল ডাটা নেই',
                      style: TextStyle(color: Colors.grey.shade400))));
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (c, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    child:
                        const Icon(Icons.person, color: Colors.blue, size: 20)),
                title: Text(data['name'] ?? 'Doctor Name',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(data['specialty'] ?? 'Specialty',
                    style: const TextStyle(fontSize: 11)),
                trailing: IconButton(
                    icon:
                        const Icon(Icons.phone, color: Colors.green, size: 20),
                    onPressed: () {}),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFloatingCart() {
    return Container(
      height: 65,
      width: 75,
      decoration: BoxDecoration(
        color: const Color(0xFF6200EE),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.deepPurple.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('1 items', style: TextStyle(color: Colors.white70, fontSize: 9)),
          Text('৳ 1450',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Future<void> _submitOrder(String type) async {
    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(actualUserDataProvider).value;
      final Map<String, dynamic> orderData = {
        'userId': user?['uid'],
        'userName': user?['name'],
        'phone': user?['phone'],
        'districtId': _selectedDistrict,
        'upazilaId': _selectedUpazila,
        'orderType': type,
        'isEmergency': true,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (type == 'medicine') {
        if (_medicineController.text.isEmpty && _prescriptionImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(_t('fillRequiredFields')),
              backgroundColor: Colors.red));
          return;
        }
        orderData['details'] = _medicineController.text;
      } else if (type == 'blood') {
        if (_selectedBloodGroup == null || _hospitalController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(_t('fillRequiredFields')),
              backgroundColor: Colors.red));
          return;
        }
        orderData['bloodGroup'] = _selectedBloodGroup;
        orderData['bagsNeeded'] = _bagsController.text;
        orderData['hospitalArea'] = _hospitalController.text;
        orderData['patientType'] = _selectedPatientType;
      }

      await FirebaseFirestore.instance
          .collection(HubPaths.orders)
          .add(orderData);

      _medicineController.clear();
      _hospitalController.clear();
      _bagsController.clear();
      setState(() {
        _prescriptionImage = null;
        _selectedBloodGroup = null;
        _selectedPatientType = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(type == 'medicine'
                  ? _t('orderPlacedSuccess')
                  : 'রক্তের আবেদন পাঠানো হয়েছে'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

