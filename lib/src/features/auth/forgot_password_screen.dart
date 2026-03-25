import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../services/language_provider.dart';
import '../../utils/styles.dart';
import '../../utils/app_strings.dart';
import '../../utils/error_handler.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _idCtrl = TextEditingController();
  final _a1Ctrl = TextEditingController();
  final _a2Ctrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  
  bool _isLoading = false, _isEmailMode = false;
  int _step = 1; // 1: Identify, 2: Security Questions, 3: Reset Password, 4: Staff Contact
  Map<String, dynamic>? _foundUser;
  String? _foundUid;

  String _t(String k) => AppStrings.get(k, ref.watch(languageProvider).languageCode);

  Future<void> _findUser() async {
    final id = _idCtrl.text.trim();
    if (id.isEmpty) {
      ErrorHandler.handleError(_t('fillAllFields'));
      return;
    }

    setState(() => _isLoading = true);
    try {
      QuerySnapshot q;
      String searchId = id;
      
      if (!_isEmailMode) {
        final String p = id.replaceAll(RegExp(r'[^0-9]'), '');
        if (p.length == 10) {
          searchId = '0$p';
        } else if (p.length == 11) searchId = p;
        else throw _t('invalidPhoneError');
      }

      final col = FirebaseFirestore.instance.collection('users');
      if (_isEmailMode) {
        q = await col.where('email', isEqualTo: id).limit(1).get();
      } else {
        q = await col.where('phone', isEqualTo: searchId).limit(1).get();
      }

      if (q.docs.isEmpty) throw _t('userNotFound');

      final data = q.docs.first.data() as Map<String, dynamic>;
      _foundUid = q.docs.first.id;
      _foundUser = data;

      final role = data['role'] ?? 'customer';
      if (role == 'customer') {
        if (data['q1'] == null || data['q2'] == null) {
          throw _t('securityQuestionsNotSet');
        }
        setState(() => _step = 2);
      } else {
        setState(() => _step = 4);
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _verifyQuestions() {
    if (_a1Ctrl.text.isEmpty || _a2Ctrl.text.isEmpty) {
      ErrorHandler.handleError(_t('fillAllAnswers'));
      return;
    }

    final String correctA1 = (_foundUser?['a1'] ?? '').toString().toLowerCase().trim();
    final String correctA2 = (_foundUser?['a2'] ?? '').toString().toLowerCase().trim();

    if (_a1Ctrl.text.toLowerCase().trim() == correctA1 && 
        _a2Ctrl.text.toLowerCase().trim() == correctA2) {
      setState(() => _step = 3);
    } else {
      ErrorHandler.handleError(_t('answersMismatch'));
    }
  }

  Future<void> _resetPassword() async {
    if (_newPassCtrl.text.length < 6) {
      ErrorHandler.handleError(_t('passwordTooShort'));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('password_reset_requests').doc(_foundUid).set({
        'uid': _foundUid,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'verified_by_questions',
        'newPassword': _newPassCtrl.text.trim(),
        'phone': _foundUser?['phone'],
        'name': _foundUser?['name'],
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => AlertDialog(
            title: Text(_t('requestSent')),
            content: Text(_t('resetRequestSuccessMsg')),
            actions: [ElevatedButton(onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            }, child: Text(_t('ok')))],
          ),
        );
      }
    } catch (e) {
      ErrorHandler.handleError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('forgotPassword')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step > 1) {
              setState(() => _step = 1);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            if (_step == 1) _buildStep1(isDark),
            if (_step == 2) _buildStep2(isDark),
            if (_step == 3) _buildStep3(isDark),
            if (_step == 4) _buildStep4(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(bool isDark) => Column(children: [
    const Icon(Icons.person_search_rounded, size: 80, color: AppStyles.primaryColor),
    const SizedBox(height: 20),
    Text(_t('findAccount'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    const SizedBox(height: 30),
    
    Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _toggleBtn(_t('mobile'), !_isEmailMode, () => setState(() => _isEmailMode = false), isDark),
          _toggleBtn(_t('email'), _isEmailMode, () => setState(() => _isEmailMode = true), isDark),
        ],
      ),
    ),
    const SizedBox(height: 24),

    TextField(
      controller: _idCtrl,
      keyboardType: _isEmailMode ? TextInputType.emailAddress : TextInputType.phone,
      decoration: InputDecoration(
        hintText: _isEmailMode ? 'example@mail.com' : '1XXXXXXXXX',
        prefixIcon: Icon(_isEmailMode ? Icons.email_outlined : Icons.phone_android_rounded, color: AppStyles.primaryColor),
        prefixText: !_isEmailMode ? '+880 ' : null,
        prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppStyles.primaryColor),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    ),
    const SizedBox(height: 30),
    SizedBox(
      width: double.infinity, 
      height: 55, 
      child: ElevatedButton(
        onPressed: _isLoading ? null : _findUser, 
        style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_t('nextStep'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
    ),
  ]);

  Widget _toggleBtn(String label, bool isSelected, VoidCallback onTap, bool isDark) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: isSelected ? AppStyles.primaryColor : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white60 : Colors.black54), fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    ),
  );

  Widget _buildStep2(bool isDark) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(_t('identityVerification'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    const SizedBox(height: 10),
    Text(_t('securityQuestionsDesc'), style: const TextStyle(color: Colors.grey)),
    const SizedBox(height: 30),
    _qRow(_t('question1'), _foundUser?['q1'] ?? 'Security Question 1'),
    TextField(
      controller: _a1Ctrl,
      decoration: InputDecoration(hintText: _t('yourAnswer'), filled: true, fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    ),
    const SizedBox(height: 20),
    _qRow(_t('question2'), _foundUser?['q2'] ?? 'Security Question 2'),
    TextField(
      controller: _a2Ctrl,
      decoration: InputDecoration(hintText: _t('yourAnswer'), filled: true, fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    ),
    const SizedBox(height: 30),
    SizedBox(
      width: double.infinity, 
      height: 55, 
      child: ElevatedButton(
        onPressed: _verifyQuestions, 
        style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: Text(_t('verify'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
    ),
  ]);

  Widget _buildStep3(bool isDark) => Column(children: [
    const Icon(Icons.verified_user_rounded, size: 80, color: Colors.green),
    const SizedBox(height: 20),
    Text(_t('verificationSuccess'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
    const SizedBox(height: 30),
    TextField(
      controller: _newPassCtrl, 
      obscureText: true, 
      decoration: InputDecoration(hintText: _t('enterNewPassword'), prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppStyles.primaryColor), filled: true, fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    ),
    const SizedBox(height: 30),
    SizedBox(
      width: double.infinity, 
      height: 55, 
      child: ElevatedButton(
        onPressed: _isLoading ? null : _resetPassword, 
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_t('sendResetRequest'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      )
    ),
  ]);

  Widget _buildStep4() => Column(children: [
    const Icon(Icons.admin_panel_settings_rounded, size: 80, color: Colors.indigo),
    const SizedBox(height: 20),
    Text(_t('staffIdIdentified'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    const SizedBox(height: 10),
    Text(_t('staffResetPolicy'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
    const SizedBox(height: 40),
    _contactBtn(Icons.phone_rounded, _t('callAdmin'), Colors.green, () => launchUrl(Uri.parse('tel:01700000000'))),
    const SizedBox(height: 12),
    _contactBtn(Icons.chat_bubble_rounded, _t('contactWhatsApp'), Colors.teal, () => launchUrl(Uri.parse('https://wa.me/8801700000000'))),
    const SizedBox(height: 20),
    TextButton(onPressed: () => setState(() => _step = 1), child: Text(_t('searchAgain'), style: const TextStyle(color: Colors.grey))),
  ]);

  Widget _qRow(String label, String q) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppStyles.primaryColor)),
    Text(q, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  ]));

  Widget _contactBtn(IconData i, String l, Color c, VoidCallback t) => InkWell(onTap: t, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: c.withValues(alpha: 0.3))), child: Row(children: [Icon(i, color: c), const SizedBox(width: 16), Text(l, style: TextStyle(color: c, fontWeight: FontWeight.bold)), const Spacer(), const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey)])));
}

