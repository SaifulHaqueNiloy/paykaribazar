import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/styles.dart';
import '../../di/providers.dart';

class InfoScreen extends ConsumerWidget {
  final String title;
  final String docPath;
  const InfoScreen({super.key, required this.title, required this.docPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final lang = ref.watch(languageProvider).languageCode;

    return Scaffold(
      backgroundColor: isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.doc(docPath).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No information available.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final content = lang == 'bn' 
              ? (data['contentBn'] ?? data['content'] ?? 'তথ্য পাওয়া যায়নি।')
              : (data['content'] ?? 'Information not available.');

          final showDynamicList = docPath == HubPaths.partners || docPath == HubPaths.staffList;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HtmlWidget(
                  content,
                  textStyle: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                if (showDynamicList) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: docPath == HubPaths.partners
                        ? FirebaseFirestore.instance
                            .collection(HubPaths.users)
                            .where('role', isEqualTo: 'reseller')
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection(HubPaths.users)
                            .where('role', whereIn: ['admin', 'staff', 'logistic', 'marketing', 'accountsFinance'])
                            .snapshots(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (userSnapshot.hasError) {
                        return Text('Error: ${userSnapshot.error}',
                            style: const TextStyle(color: Colors.red));
                      }
                      final users = userSnapshot.data?.docs ?? [];
                      if (users.isEmpty) {
                        return Center(
                          child: Text(
                            lang == 'bn' ? 'কোনো তালিকা পাওয়া যায়নি।' : 'No entries found.',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index].data() as Map<String, dynamic>;
                          final name = user['name'] ?? 'User';
                          final phone = user['phone'] ?? '';
                          final role = user['role'] ?? '';
                          final profilePic = user['profilePic'];

                          Color roleColor = Colors.grey;
                          IconData roleIcon = Icons.person;
                          String roleName = role.toUpperCase();

                          if (docPath == HubPaths.partners) {
                            roleColor = Colors.teal;
                            roleIcon = Icons.storefront;
                            roleName = lang == 'bn' ? 'অফিসিয়াল রিসেলার' : 'Official Reseller';
                          } else {
                            if (role == 'admin') {
                              roleColor = Colors.redAccent;
                              roleIcon = Icons.admin_panel_settings;
                              roleName = lang == 'bn' ? 'এডমিন' : 'ADMIN';
                            } else if (role == 'staff') {
                              roleColor = Colors.blue;
                              roleIcon = Icons.assignment_ind;
                              roleName = lang == 'bn' ? 'স্টাফ' : 'STAFF';
                            } else if (role == 'logistic') {
                              roleColor = Colors.orange;
                              roleIcon = Icons.delivery_dining;
                              roleName = lang == 'bn' ? 'রাইডার' : 'RIDER';
                            } else if (role == 'marketing') {
                              roleColor = Colors.pink;
                              roleIcon = Icons.campaign;
                              roleName = lang == 'bn' ? 'মার্কেটিং' : 'MARKETING';
                            } else if (role == 'accountsFinance') {
                              roleColor = Colors.purple;
                              roleIcon = Icons.payments;
                              roleName = lang == 'bn' ? 'অ্যাকাউন্টস' : 'FINANCE';
                            }
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                              border: Border.all(
                                color: isDark ? Colors.white10 : Colors.grey.shade100,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: roleColor, width: 5),
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: roleColor.withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 26,
                                        backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                                        backgroundImage: (profilePic != null && profilePic.toString().isNotEmpty)
                                            ? NetworkImage(profilePic)
                                            : null,
                                        child: (profilePic == null || profilePic.toString().isEmpty)
                                            ? Icon(Icons.person, color: isDark ? Colors.white70 : Colors.black54, size: 24)
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: roleColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(roleIcon, size: 12, color: roleColor),
                                                const SizedBox(width: 4),
                                                Text(
                                                  roleName,
                                                  style: TextStyle(
                                                    color: roleColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (phone.isNotEmpty)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.phone_rounded, color: Colors.green, size: 20),
                                          onPressed: () async {
                                            final url = 'tel:$phone';
                                            if (await canLaunchUrl(Uri.parse(url))) {
                                              await launchUrl(Uri.parse(url));
                                            }
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
