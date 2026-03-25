import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../di/providers.dart';
import '../../../utils/styles.dart';
import '../../../utils/app_strings.dart';

class StaffManagementTab extends ConsumerWidget {
  const StaffManagementTab({super.key});

  String _t(WidgetRef ref, String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStaffForm(context, ref),
        backgroundColor: AppStyles.primaryColor,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(_t(ref, 'addNewStaff'),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', whereNotIn: ['customer', 'guest']).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final staffs = snapshot.data!.docs;

          if (staffs.isEmpty) {
            return Center(child: Text(_t(ref, 'noItemsFound')));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: staffs.length,
            itemBuilder: (context, index) {
              final data = staffs[index].data() as Map<String, dynamic>;
              final id = staffs[index].id;
              return _buildStaffCard(context, ref, id, data, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, WidgetRef ref, String id,
      Map<String, dynamic> data, bool isDark) {
    final String role = data['role'] ?? 'staff';
    final bool multiDevice = data['allowMultipleDevices'] ?? false;
    final String staffId = data['staffId'] ?? '---';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration(isDark),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getCol(role).withOpacity(0.1),
            child: Icon(_getIcon(role), color: _getCol(role), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data['name'] ?? _t(ref, 'noName'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text('ID: $staffId',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Text(role.toUpperCase(),
                        style: TextStyle(
                            color: _getCol(role),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5)),
                    const SizedBox(width: 8),
                    if (multiDevice)
                      const Icon(Icons.all_inclusive_rounded,
                          size: 12, color: Colors.green),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
            onPressed: () =>
                _showStaffForm(context, ref, id: id, currentData: data),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded,
                color: Colors.red, size: 20),
            onPressed: () => _deleteStaff(id),
          ),
        ],
      ),
    );
  }

  void _showStaffForm(BuildContext context, WidgetRef ref,
      {String? id, Map<String, dynamic>? currentData}) {
    final nameCtrl = TextEditingController(text: currentData?['name']);
    final phoneCtrl = TextEditingController(text: currentData?['phone']);
    final staffIdCtrl = TextEditingController(text: currentData?['staffId']);
    final passCtrl = TextEditingController();
    String role = currentData?['role'] ?? 'staff';
    bool allowMultipleDevices = currentData?['allowMultipleDevices'] ?? false;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 30,
              left: 24,
              right: 24),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    id == null
                        ? _t(ref, 'addNewStaff')
                        : _t(ref, 'editProfile'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 0.5)),
                const SizedBox(height: 24),
                TextField(
                    controller: nameCtrl,
                    decoration: AppStyles.inputDecoration(_t(ref, 'fullName'),
                        Theme.of(context).brightness == Brightness.dark,
                        prefix: const Icon(Icons.person_rounded))),
                const SizedBox(height: 12),
                TextField(
                    controller: phoneCtrl,
                    decoration: AppStyles.inputDecoration(
                        _t(ref, 'mobileNumber'),
                        Theme.of(context).brightness == Brightness.dark,
                        prefix: const Icon(Icons.phone_iphone_rounded))),
                const SizedBox(height: 12),

                // NEW STAFF ID FIELD
                TextField(
                  controller: staffIdCtrl,
                  decoration: AppStyles.inputDecoration(
                      'Staff ID (e.g. log_rahim_01)',
                      Theme.of(context).brightness == Brightness.dark,
                      prefix: const Icon(Icons.badge_rounded)),
                  enabled:
                      id == null, // ID should not be changed after creation
                ),

                if (id == null) ...[
                  const SizedBox(height: 12),
                  TextField(
                      controller: passCtrl,
                      decoration: AppStyles.inputDecoration(_t(ref, 'password'),
                          Theme.of(context).brightness == Brightness.dark,
                          prefix: const Icon(Icons.lock_rounded)),
                      obscureText: true),
                ],
                const SizedBox(height: 20),
                Text(_t(ref, 'assignOrganizationalRole'),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  items: [
                    'admin',
                    'staff',
                    'logistic',
                    'marketing',
                    'accountsFinance',
                    'reseller'
                  ]
                      .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold))))
                      .toList(),
                  onChanged: (v) => setModalState(() => role = v!),
                  decoration: AppStyles.inputDecoration(
                      _t(ref, 'chooseRuleType'),
                      Theme.of(context).brightness == Brightness.dark),
                ),
                const SizedBox(height: 20),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Allow Multiple Devices?',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text(
                      'If disabled, user is locked to approved devices only.',
                      style: TextStyle(fontSize: 11)),
                  value: allowMultipleDevices,
                  onChanged: (v) =>
                      setModalState(() => allowMultipleDevices = v),
                  activeColor: AppStyles.primaryColor,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameCtrl.text.isEmpty ||
                                phoneCtrl.text.isEmpty ||
                                staffIdCtrl.text.isEmpty) {
                              return;
                            }
                            if (id == null && passCtrl.text.isEmpty) return;

                            setModalState(() => isLoading = true);
                            try {
                              if (id == null) {
                                await ref
                                    .read(authServiceProvider)
                                    .registerStaff(
                                      name: nameCtrl.text.trim(),
                                      phone: phoneCtrl.text.trim(),
                                      staffId: staffIdCtrl.text.trim(),
                                      password: passCtrl.text.trim(),
                                      role: role,
                                      allowMultipleDevices:
                                          allowMultipleDevices,
                                    );
                              } else {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(id)
                                    .update({
                                  'name': nameCtrl.text.trim(),
                                  'phone': phoneCtrl.text.trim(),
                                  'role': role,
                                  'allowMultipleDevices': allowMultipleDevices,
                                });
                              }
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: Colors.red));
                              }
                            } finally {
                              setModalState(() => isLoading = false);
                            }
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(id == null
                            ? _t(ref, 'add').toUpperCase()
                            : _t(ref, 'updateSuccess').toUpperCase()),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteStaff(String id) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'role': 'customer'});
  }

  Color _getCol(String r) {
    switch (r) {
      case 'admin':
        return Colors.red;
      case 'staff':
        return Colors.blue;
      case 'logistic':
        return Colors.orange;
      case 'marketing':
        return Colors.pink;
      case 'accountsFinance':
        return Colors.purple;
      case 'reseller':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon(String r) {
    switch (r) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'staff':
        return Icons.assignment_ind;
      case 'logistic':
        return Icons.delivery_dining;
      case 'marketing':
        return Icons.campaign;
      case 'accountsFinance':
        return Icons.payments;
      case 'reseller':
        return Icons.store;
      default:
        return Icons.person;
    }
  }
}
