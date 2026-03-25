import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paykari_bazar/src/di/providers.dart'; // MASTER HUB

class StaffSecurityTab extends ConsumerStatefulWidget {
  const StaffSecurityTab({super.key});
  @override
  ConsumerState<StaffSecurityTab> createState() => _StaffSecurityTabState();
}

class _StaffSecurityTabState extends ConsumerState<StaffSecurityTab> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final staffAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: staffAsync.when(
        data: (users) {
          final staff = users
              .where((u) => [
                    'admin',
                    'staff',
                    'logistic',
                    'marketing',
                    'accountsFinance'
                  ].contains(u['role']))
              .toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: staff.length + 1,
            itemBuilder: (c, i) {
              if (i == 0) return _buildAddStaffCard(isDark);
              return _buildStaffTile(staff[i - 1], isDark);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildAddStaffCard(bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
      child: ListTile(
        onTap: () => _showAddStaffSheet(),
        leading: const CircleAvatar(
            backgroundColor: Colors.teal,
            child: Icon(Icons.add, color: Colors.white)),
        title: const Text('Add New Staff',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Register a new team member'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildStaffTile(Map<String, dynamic> user, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!)),
      child: ListTile(
        leading: CircleAvatar(child: Text(user['name']?[0] ?? 'S')),
        title: Text(user['name'] ?? 'Staff',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${user['role']} • ${user['phone']}"),
        trailing: IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditStaffSheet(user)),
      ),
    );
  }

  void _showAddStaffSheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final staffIdCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String role = 'staff';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(c).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Register New Staff',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name')),
          TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone Number')),
          TextField(
              controller: staffIdCtrl,
              decoration: const InputDecoration(labelText: 'Staff ID')),
          TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Password')),
          DropdownButtonFormField<String>(
              initialValue: role,
              items: [
                'admin',
                'staff',
                'logistic',
                'marketing',
                'accountsFinance'
              ]
                  .map((r) =>
                      DropdownMenuItem(value: r, child: Text(r.toUpperCase())))
                  .toList(),
              onChanged: (v) => role = v!,
              decoration: const InputDecoration(labelText: 'Role')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(authServiceProvider).registerStaff(
                    name: nameCtrl.text,
                    phone: phoneCtrl.text,
                    staffId: staffIdCtrl.text,
                    password: passCtrl.text,
                    role: role);
                if (mounted) Navigator.pop(c);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text('REGISTER STAFF'),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  void _showEditStaffSheet(Map<String, dynamic> user) {
    final phoneCtrl = TextEditingController(text: user['phone']);
    showModalBottomSheet(
      context: context,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Edit ${user['name']}',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Update Phone')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authServiceProvider).updateStaffCredentials(
                  user['uid'] ?? user['id'],
                  phone: phoneCtrl.text);
              if (mounted) Navigator.pop(c);
            },
            child: const Text('UPDATE CREDENTIALS'),
          ),
        ]),
      ),
    );
  }
}
