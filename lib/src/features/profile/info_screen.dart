import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: HtmlWidget(
              content,
              textStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          );
        },
      ),
    );
  }
}
