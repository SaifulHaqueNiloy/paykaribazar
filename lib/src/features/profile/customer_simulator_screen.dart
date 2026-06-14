import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/role_simulator_provider.dart';
import '../../utils/styles.dart';
import '../../di/providers.dart';

/// অ্যাডমিনকে যেকোনো ইউজারের মত অ্যাপ ব্যবহার করার সুযোগ দেয়
class CustomerSimulatorScreen extends ConsumerStatefulWidget {
  const CustomerSimulatorScreen({super.key});

  @override
  ConsumerState<CustomerSimulatorScreen> createState() => _CustomerSimulatorScreenState();
}

class _CustomerSimulatorScreenState extends ConsumerState<CustomerSimulatorScreen> {
  String _searchQuery = '';

  /// প্রো-টিপ: সিকিউরিটি অডিটিং। সিমুলেশন শুরু হলে তা লগ করা জরুরি।
  Future<void> _auditSimulationStart(String targetUid, String targetName) async {
    final admin = FirebaseAuth.instance.currentUser;
    if (admin == null) return;

    await FirebaseFirestore.instance.collection('ai_audit_logs').add({
      'type': 'USER_SIMULATION_START',
      'adminId': admin.uid,
      'targetUid': targetUid,
      'targetName': targetName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'success',
    });
  }

  @override
  Widget build(BuildContext context) {
    // বর্তমান সিমুলেটেড ইউজার আইডি চেক করা
    final simulatedId = ref.watch(simulatedUserUidProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer App Simulator'),
        actions: [
          if (simulatedId != null)
            TextButton.icon(
              onPressed: () => ref.read(simulatedUserUidProvider.notifier).state = null,
              icon: const Icon(Icons.exit_to_app, color: Colors.red),
              label: const Text('Stop', style: TextStyle(color: Colors.red)),
            )
        ],
      ),
      body: Column(
        children: [
          if (simulatedId != null)
            Container(
              color: Colors.amber.shade100,
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              child: Text(
                'বর্তমানে UID: $simulatedId এর ডাটা দেখা হচ্ছে।',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ইউজার নাম বা ফোন নাম্বার দিয়ে খুঁজুন...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = ''))
                  : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _searchQuery.length > 5 && RegExp(r'^[0-9]+$').hasMatch(_searchQuery)
                  ? FirebaseFirestore.instance
                      .collection(HubPaths.users)
                      .where('phone', isGreaterThanOrEqualTo: _searchQuery)
                      .where('phone', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                      .limit(20)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection(HubPaths.users)
                      .where('role', isEqualTo: 'customer')
                      .limit(50)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var users = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  final phone = data['phone']?.toString() ?? '';
                  return name.contains(_searchQuery.toLowerCase()) || phone.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userData = user.data() as Map<String, dynamic>;
                    final bool isCurrent = simulatedId == user.id;

                    return ListTile(
                      selected: isCurrent,
                      selectedTileColor: AppStyles.primaryColor.withOpacity(0.05),
                      leading: CircleAvatar(
                        backgroundColor: isCurrent ? AppStyles.primaryColor : Colors.grey.shade200,
                        backgroundImage: userData['profilePic'] != null 
                            ? NetworkImage(userData['profilePic']) 
                            : null,
                        child: userData['profilePic'] == null 
                            ? Icon(Icons.person, color: isCurrent ? Colors.white : Colors.grey) 
                            : null,
                      ),
                      title: Text(
                        userData['name'] ?? 'Unknown User',
                        style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
                      ),
                      subtitle: Text(userData['phone'] ?? 'No Phone'),
                      trailing: isCurrent 
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppStyles.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                                  // এখানে আমরা সিমুলেটেড আইডি সেট করছি
                                  ref.read(simulatedUserUidProvider.notifier).state = user.id;
                                  
                                  // অডিট লগ তৈরি করা (Pro logic)
                                  _auditSimulationStart(user.id, userData['name'] ?? 'Unknown');

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${userData['name']} হিসেবে সিমুলেশন শুরু হয়েছে'),
                                      behavior: SnackBarBehavior.floating,
                                      action: SnackBarAction(
                                        label: 'হোমে যান',
                                        onPressed: () {
                                          // Pro-tip: Automatically navigate to home to see the changes
                                          Navigator.of(context).popUntil((route) => route.isFirst);
                                          ref.read(navProvider.notifier).setIndex(0); // Set to Home tab
                                        },
                                      ),
                                    ),
                                  );
                                },
                            child: const Text('Simulate'),
                          ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}