import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/styles.dart';

class ApplicationFormScreen extends StatefulWidget {
  final String role; // 'reseller', 'rider', 'staff'
  const ApplicationFormScreen({super.key, required this.role});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _shopNameCtrl = TextEditingController();
  final _nidCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameCtrl.text = user?.displayName ?? '';
    _phoneCtrl.text = user?.phoneNumber ?? '';
    _emailCtrl.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _shopNameCtrl.dispose();
    _nidCtrl.dispose();
    _expCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isD = Theme.of(context).brightness == Brightness.dark;
    
    String title = 'Apply for ';
    if (widget.role == 'reseller') title += 'Reseller';
    else if (widget.role == 'rider') title += 'Delivery Person';
    else title += 'Office Staff';

    return Scaffold(
      backgroundColor: isD ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isD),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Personal Information'),
              _buildField('আপনার পূর্ণ নাম', _nameCtrl, Icons.person),
              _buildField('ফোন নম্বর', _phoneCtrl, Icons.phone, TextInputType.phone),
              _buildField('ইমেইল অ্যাড্রেস', _emailCtrl, Icons.email, TextInputType.emailAddress),
              _buildField('আপনার বর্তমান ঠিকানা', _addressCtrl, Icons.location_on, TextInputType.multiline, 3),
              
              const SizedBox(height: 12),
              _buildSectionTitle('Professional Details'),
              
              if (widget.role == 'reseller') ...[
                _buildField('দোকানের নাম (যদি থাকে)', _shopNameCtrl, Icons.store),
                _buildField('ব্যবসায়িক অভিজ্ঞতা (বছর)', _expCtrl, Icons.history, TextInputType.number),
              ],
              
              if (widget.role == 'rider' || widget.role == 'staff') ...[
                _buildField('এনআইডি (NID) নম্বর', _nidCtrl, Icons.badge, TextInputType.number),
                _buildField('পূর্ব অভিজ্ঞতা বর্ণনা করুন', _expCtrl, Icons.work_history, TextInputType.multiline, 3),
              ],
              
              if (widget.role == 'rider') 
                _buildField('বাহনের ধরন (সাইকেল/বাইক)', _shopNameCtrl, Icons.directions_bike),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('আবেদন জমা দিন', 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text('Your application will be reviewed by our team.',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppStyles.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppStyles.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppStyles.primaryColor,
            radius: 25,
            child: Icon(_getRoleIcon(), color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Join Our Team!', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppStyles.primaryColor)),
                Text('Fill out the form to become a ${widget.role}.', 
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon() {
    if (widget.role == 'reseller') return Icons.storefront_rounded;
    if (widget.role == 'rider') return Icons.delivery_dining_rounded;
    return Icons.badge_rounded;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(title.toUpperCase(), 
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.5)),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, [TextInputType type = TextInputType.text, int maxLines = 1]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14),
        decoration: AppStyles.inputDecoration(label, isDark, prefix: Icon(icon, size: 20)),
        validator: (v) => v == null || v.isEmpty ? 'এই ঘরটি পূরণ করুন' : null,
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('applications').add({
        'userId': user?.uid,
        'role': widget.role,
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'shopName': _shopNameCtrl.text.trim(),
        'nid': _nidCtrl.text.trim(),
        'experience': _expCtrl.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('আপনার আবেদনটি সফলভাবে জমা হয়েছে। আমাদের টিম আপনার সাথে যোগাযোগ করবে।'), 
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          )
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

