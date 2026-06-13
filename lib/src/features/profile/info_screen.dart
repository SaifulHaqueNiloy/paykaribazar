import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/styles.dart';
import '../../di/providers.dart';
import '../../core/constants/paths.dart';

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

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDark ? Colors.white10 : Colors.grey.shade200,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: (profilePic != null && profilePic.toString().isNotEmpty)
                                    ? NetworkImage(profilePic)
                                    : null,
                                child: (profilePic == null || profilePic.toString().isEmpty)
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                docPath == HubPaths.partners
                                    ? (lang == 'bn' ? 'অফিসিয়াল রিসেলার' : 'Official Reseller')
                                    : role.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: phone.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.phone, color: Colors.green),
                                      onPressed: () async {
                                        final url = 'tel:$phone';
                                        if (await canLaunchUrl(Uri.parse(url))) {
                                          await launchUrl(Uri.parse(url));
                                        }
                                      },
                                    )
                                  : null,
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
