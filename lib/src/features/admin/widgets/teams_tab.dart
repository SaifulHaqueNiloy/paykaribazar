import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/firebase/firestore_service.dart';
import '../../../services/role_simulator_provider.dart';
import '../../../models/user_model.dart';
import '../../../utils/styles.dart';
import '../../../core/constants/paths.dart';

class TeamsTab extends ConsumerStatefulWidget {
  const TeamsTab({super.key});
  @override
  ConsumerState<TeamsTab> createState() => _TeamsTabState();
}

class _TeamsTabState extends ConsumerState<TeamsTab> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usersAsync = ref.watch(allUsersProvider);
    final shopsAsync = ref.watch(storesProvider);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
            decoration: AppStyles.inputDecoration('ইউজার খুঁজুন...', isDark).copyWith(prefixIcon: const Icon(Icons.search)),
          ),
        ),
        Expanded(child: usersAsync.when(
          data: (allUsers) => shopsAsync.when(
            data: (shops) {
              final filtered = allUsers.where((u) => (u['name'] ?? '').toString().toLowerCase().contains(_search) || (u['phone'] ?? '').toString().contains(_search)).toList();
              final Map<String, List<Map<String, dynamic>>> groups = {};
              for (var u in filtered) {
                final String r = u['role'] ?? 'customer';
                if (!groups.containsKey(r)) groups[r] = [];
                groups[r]!.add(u);
              }
              final sortedRoles = ['admin', 'staff', 'logistic', 'reseller', 'marketing', 'accountsFinance', 'customer'];
              final activeRoles = sortedRoles.where((r) => groups.containsKey(r)).toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: activeRoles.length,
                itemBuilder: (c, i) {
                  final role = activeRoles[i];
                  final users = groups[role]!;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.white10 : Colors.grey[200]!)),
                    child: ExpansionTile(
                      initiallyExpanded: role != 'customer',
                      leading: CircleAvatar(backgroundColor: _getCol(role).withOpacity(0.1), child: Icon(_getIcon(role), color: _getCol(role), size: 20)),
                      title: Text(role.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                      children: users.map((u) => _buildUserTile(u, shops, isDark)).toList(),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Shop Load Error: $e')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        )),
      ]),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, List<Map<String, dynamic>> shops, bool isDark) {
    final int points = (user['points'] ?? 0).toInt();
    final role = user['role'] ?? 'customer';
    final List approvedShops = user['approvedShops'] as List? ?? [];
    
    // Format Last Login Time
    String lastLoginStr = 'Never';
    final lastLogin = user['lastLoginAt'] as Timestamp?;
    if (lastLogin != null) {
      lastLoginStr = DateFormat('dd MMM, hh:mm a').format(lastLogin.toDate());
    }
    
    return ListTile(
      onLongPress: () => _showRoleShopDialog(user, shops),
      title: Text(user['name'] ?? 'Guest', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${user['phone'] ?? ''} • Points: $points", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text('Last Login: $lastLoginStr', style: TextStyle(fontSize: 10, color: Colors.blueGrey.withOpacity(0.7), fontWeight: FontWeight.bold)),
          if (role == 'reseller' && approvedShops.isNotEmpty)
            Padding(padding: const EdgeInsets.only(top: 4), child: Wrap(spacing: 4, children: approvedShops.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(s.toString(), style: const TextStyle(color: Colors.teal, fontSize: 9, fontWeight: FontWeight.bold)))).toList())),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () => _startSimulation(user),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12), textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        child: const Text('SIMULATE'),
      ),
    );
  }

  void _startSimulation(Map<String, dynamic> user) {
    ref.read(simulatedUserUidProvider.notifier).state = user['uid'] ?? user['id'];
    
    final roleStr = user['role'] ?? 'customer';
    final userRole = UserRole.values.firstWhere((e) => e.name == roleStr, orElse: () => UserRole.customer);
    
    ref.read(simulatedRoleProvider.notifier).state = userRole;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Simulating as ${user['name']}... Admin can now order on their behalf.')));
  }

  void _showRoleShopDialog(Map<String, dynamic> user, List<Map<String, dynamic>> allShops) {
    String selectedRole = user['role'] ?? 'customer';
    final List<String> selectedShops = List<String>.from(user['approvedShops'] ?? []);
    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      title: const Text('Edit User Role & Shops', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(initialValue: selectedRole, items: ['admin', 'staff', 'logistic', 'reseller', 'marketing', 'accountsFinance', 'customer'].map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(), onChanged: (v) => setDialogState(() => selectedRole = v!), decoration: const InputDecoration(labelText: 'User Role')),
        if (selectedRole == 'reseller') ...[const SizedBox(height: 20), const Align(alignment: Alignment.centerLeft, child: Text('Assign Approved Shops:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))), const SizedBox(height: 8), ...allShops.map((shop) { final String name = shop['name']; return CheckboxListTile(title: Text(name, style: const TextStyle(fontSize: 13)), value: selectedShops.contains(name), onChanged: (val) { setDialogState(() { if (val == true) {
          selectedShops.add(name);
        } else {
          selectedShops.remove(name);
        } }); }, controlAffinity: ListTileControlAffinity.leading, dense: true); })]
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('CANCEL')), ElevatedButton(onPressed: () async { await FirebaseFirestore.instance.collection(HubPaths.users).doc(user['uid'] ?? user['id']).update({'role': selectedRole, 'approvedShops': selectedRole == 'reseller' ? selectedShops : FieldValue.delete()}); Navigator.pop(c); }, child: const Text('UPDATE'))],
    )));
  }

  Color _getCol(String r) => r == 'admin' ? Colors.red : (r == 'staff' ? Colors.blue : (r == 'logistic' ? Colors.orange : (r == 'marketing' ? Colors.pink : (r == 'accountsFinance' ? Colors.purple : (r == 'reseller' ? Colors.teal : Colors.grey)))));
  IconData _getIcon(String r) => r == 'admin' ? Icons.admin_panel_settings : (r == 'staff' ? Icons.assignment_ind : (r == 'logistic' ? Icons.delivery_dining : (r == 'marketing' ? Icons.campaign : (r == 'reseller' ? Icons.store : Icons.person))));
}
