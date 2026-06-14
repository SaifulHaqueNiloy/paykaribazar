import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../di/providers.dart';

class InfoScreen extends ConsumerWidget {
  final String title;
  final String docKey;

  const InfoScreen({
    super.key,
    required this.title,
    required this.docKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider).value ?? {};
    final content = appConfig[docKey] ?? 'Content not available.';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: HtmlWidget(
          content,
          textStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
