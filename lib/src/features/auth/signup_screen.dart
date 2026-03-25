import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../di/providers.dart';
import '../../utils/styles.dart';
import '../../utils/app_strings.dart';
import '../../utils/error_handler.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameCtrl = TextEditingController(),
      _phoneCtrl = TextEditingController(),
      _emailCtrl = TextEditingController(),
      _passCtrl = TextEditingController(),
      _refCtrl = TextEditingController(),
      _bloodPhoneCtrl = TextEditingController();

  String? _selectedDistrict, _selectedUpazila, _selectedBloodGroup;
  bool _isLoading = false, _obscurePassword = true, _isEmailSignup = false;
  bool _isBloodDonor = false;

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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _refCtrl.dispose();
    _bloodPhoneCtrl.dispose();
    super.dispose();
  }

  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  Future<void> _handleSignup() async {
    if (_nameCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty ||
        _selectedDistrict == null ||
        _selectedUpazila == null ||
        (_isEmailSignup ? _emailCtrl.text.isEmpty : _phoneCtrl.text.isEmpty)) {
      ErrorHandler.handleError(_t('fillRequiredFields'));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await ref.read(authServiceProvider).signUp(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.isNotEmpty ? _emailCtrl.text.trim() : null,
          password: _passCtrl.text.trim(),
          referralCode: _refCtrl.text.isNotEmpty ? _refCtrl.text.trim() : null);

      if (res != null) {
        final uid = res.user!.uid;
        await ref.read(firestoreServiceProvider).updateProfile(uid, {
          'districtId': _selectedDistrict,
          'upazilaId': _selectedUpazila,
          'bloodGroup': _selectedBloodGroup,
          'isBloodDonor': _isBloodDonor,
          'bloodContactNumber': _isBloodDonor
              ? (_bloodPhoneCtrl.text.isNotEmpty
                  ? _bloodPhoneCtrl.text.trim()
                  : _phoneCtrl.text.trim())
              : null,
        });

        await ref
            .read(loyaltyServiceProvider)
            .addPoints(uid, 'signupPoints', reason: _t('welcomeBonus'));

        if (_isBloodDonor && _selectedBloodGroup != null) {
          await ref.read(firestoreServiceProvider).registerAsDonor({
            'uid': uid,
            'name': _nameCtrl.text.trim(),
            'group': _selectedBloodGroup,
            'phone': _bloodPhoneCtrl.text.isNotEmpty
                ? _bloodPhoneCtrl.text.trim()
                : _phoneCtrl.text.trim(),
            'districtId': _selectedDistrict,
            'upazilaId': _selectedUpazila,
            'isVisible': true,
            'lastDonated': null,
          });
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_t('signupSuccess')),
            backgroundColor: AppStyles.successColor));
      }
    } catch (e) {
      if (mounted) ErrorHandler.handleError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFF8FAFC), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(_t('signupTitle'),
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppStyles.primaryColor,
                              letterSpacing: -1)),
                      const SizedBox(height: 20),
                      _buildToggle(),
                      const SizedBox(height: 30),
                      _buildStandardField(_t('fullName'),
                          Icons.person_outline_rounded, _nameCtrl,
                          hint: 'e.g. John Doe'),
                      if (_isEmailSignup)
                        _buildStandardField(_t('emailAddress'),
                            Icons.alternate_email_rounded, _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            hint: 'e.g. example@mail.com')
                      else
                        _buildStandardField(_t('mobileNumber'),
                            Icons.phone_android_rounded, _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            hint: 'e.g. 01700000000'),
                      
                      // Optimized StreamBuilder for Locations using HubPaths
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection(HubPaths.locations)
                            .where('isVisible', isEqualTo: true)
                            .where('type', isEqualTo: 'district')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red, fontSize: 10)),
                            );
                          }
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _buildDropdownLoading(_t('selectDistrict'));
                          }
                          
                          final districts = snapshot.data?.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return {
                              'id': doc.id,
                              'name': data.containsKey('name') ? data['name'].toString() : 'Unknown',
                            };
                          }).toList() ?? [];

                          return Column(children: [
                            _buildDropdown(
                                _t('selectDistrict'),
                                _selectedDistrict,
                                districts,
                                (v) => setState(() {
                                      _selectedDistrict = v;
                                      _selectedUpazila = null;
                                    })),
                            const SizedBox(height: 12),
                            
                            if (_selectedDistrict != null)
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection(HubPaths.locations)
                                    .where('isVisible', isEqualTo: true)
                                    .where('type', isEqualTo: 'upazila')
                                    .where('parentId', isEqualTo: _selectedDistrict)
                                    .snapshots(),
                                builder: (context, upSnap) {
                                  if (upSnap.hasError) return const SizedBox();
                                  if (upSnap.connectionState == ConnectionState.waiting) {
                                    return _buildDropdownLoading(_t('selectUpazila'));
                                  }
                                  
                                  final upazilas = upSnap.data?.docs.map((doc) {
                                    final data = doc.data() as Map<String, dynamic>;
                                    return {
                                      'id': doc.id,
                                      'name': data.containsKey('name') ? data['name'].toString() : 'Unknown',
                                    };
                                  }).toList() ?? [];

                                  return _buildDropdown(
                                      _t('selectUpazila'),
                                      _selectedUpazila,
                                      upazilas,
                                      (v) => setState(() => _selectedUpazila = v));
                                },
                              )
                            else
                              _buildDropdown(
                                _t('selectUpazila'),
                                null,
                                [],
                                (v) {},
                                enabled: false),
                            
                            const SizedBox(height: 20),
                          ]);
                        }
                      ),

                      _buildDropdown(
                          _t('bloodGroup'),
                          _selectedBloodGroup,
                          _bloodGroups
                              .map((g) => {'id': g, 'name': g})
                              .toList(),
                          (v) => setState(() => _selectedBloodGroup = v)),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : AppStyles.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: AppStyles.primaryColor.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              value: _isBloodDonor,
                              onChanged: (v) =>
                                  setState(() => _isBloodDonor = v),
                              title: Text(_t('registerAsDonor'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87)),
                              subtitle: Text(_t('donorSearchNote'),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey)),
                              activeThumbColor: AppStyles.primaryColor,
                              contentPadding: EdgeInsets.zero,
                            ),
                            if (_isBloodDonor) ...[
                              const SizedBox(height: 12),
                              _buildStandardField(_t('donorContactNumber'),
                                  Icons.contact_phone_rounded, _bloodPhoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  hint: 'e.g. 01800000000'),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildStandardField(
                          _t('password'), Icons.lock_outline_rounded, _passCtrl,
                          isPassword: true,
                          obscure: _obscurePassword,
                          onToggle: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          hint: 'Enter 8+ characters'),
                      _buildStandardField(_t('referralCode'),
                          Icons.card_giftcard_rounded, _refCtrl,
                          hint: 'e.g. PB1234 (Optional)'),
                      const SizedBox(height: 20),
                      _buildSignupButton(),
                      const SizedBox(height: 30),
                      _buildLoginPrompt(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownLoading(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }

  Widget _buildStandardField(
      String label, IconData icon, TextEditingController controller,
      {bool isPassword = false,
      bool obscure = false,
      VoidCallback? onToggle,
      TextInputType? keyboardType,
      String? hint}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: AppStyles.inputDecoration(label, isDark,
                prefix: Icon(icon, color: AppStyles.primaryColor, size: 20),
                hint: hint)
            .copyWith(
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                      color: isDark ? Colors.grey : null),
                  onPressed: onToggle)
              : null,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value,
      List<Map<String, String>> items, Function(String?) onChanged,
      {bool enabled = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            hint: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600])),
            items: items
                .map((i) => DropdownMenuItem(
                    value: i['id'],
                    child: Text(i['name']!,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 13))))
                .toList(),
            onChanged: enabled ? onChanged : null,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: isDark ? AppStyles.primaryColor : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          style: IconButton.styleFrom(
              backgroundColor: AppStyles.primaryColor.withValues(alpha: 0.1)),
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: AppStyles.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          _toggleItem(_t('withPhone'), !_isEmailSignup,
              () => setState(() => _isEmailSignup = false)),
          _toggleItem(_t('withEmail'), _isEmailSignup,
              () => setState(() => _isEmailSignup = true)),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppStyles.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isSelected ? Colors.white : AppStyles.textSecondary,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignup,
        style: ElevatedButton.styleFrom(
            backgroundColor: AppStyles.primaryColor,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
            shadowColor: AppStyles.primaryColor.withValues(alpha: 0.3)),
        child: _isLoading
            ? const SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3))
            : Text(_t('signupTitle'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_t('alreadyHaveAccount'),
            style: const TextStyle(color: AppStyles.textSecondary)),
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('login'),
                style: const TextStyle(
                    color: AppStyles.primaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16))),
      ],
    );
  }
}
