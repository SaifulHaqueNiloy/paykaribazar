import 'package:flutter/material.dart';
import '../../../di/service_locator.dart';
import '../../ai/services/ai_service.dart';

/// A widget that fetches and displays an AI-generated summary of product reviews.
/// It presents the overall sentiment, pros, and cons in a clean Card layout.
class ReviewSummaryCard extends StatefulWidget {
  final List<String> reviews;

  const ReviewSummaryCard({super.key, required this.reviews});

  @override
  State<ReviewSummaryCard> createState() => _ReviewSummaryCardState();
}

class _ReviewSummaryCardState extends State<ReviewSummaryCard> {
  late Future<String> _summaryFuture;
  final AIService _aiService = getIt<AIService>();

  @override
  void initState() {
    super.initState();
    _summaryFuture = _aiService.summarizeProductReviews(widget.reviews);
  }

  @override
  void didUpdateWidget(ReviewSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reviews != widget.reviews) {
      setState(() {
        _summaryFuture = _aiService.summarizeProductReviews(widget.reviews);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reviews.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<String>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final summary = _parseSummary(snapshot.data!);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.indigo, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'AI রিভিউ সারাংশ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                if (summary.overall.isNotEmpty) ...[
                  Text(
                    summary.overall,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildSection(
                  context,
                  title: 'ইতিবাচক দিক (Pros)',
                  items: summary.pros,
                  icon: Icons.add_circle_outline,
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 12),
                _buildSection(
                  context,
                  title: 'নেতিবাচক দিক (Cons)',
                  items: summary.cons,
                  icon: Icons.remove_circle_outline,
                  color: Colors.red.shade700,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(strokeWidth: 2),
              SizedBox(height: 12),
              Text('AI রিভিউ বিশ্লেষণ করছে...', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<String> items,
    required IconData icon,
    required Color color,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 4),
              child: Text(
                '• $item',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            )),
      ],
    );
  }

  _ParsedSummary _parseSummary(String text) {
    String overall = "";
    final List<String> pros = [];
    final List<String> cons = [];

    final lines = text.split('\n');
    int mode = 0; // 1: overall, 2: pros, 3: cons

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.contains('সামগ্রিক সারাংশ:')) {
        mode = 1;
        overall = trimmed.split(':').last.trim();
        continue;
      } else if (trimmed.contains('ইতিবাচক দিক:')) {
        mode = 2;
        final content = trimmed.split(':').last.trim();
        if (content.isNotEmpty && content != '...') pros.add(content);
        continue;
      } else if (trimmed.contains('নেতিবাচক দিক:')) {
        mode = 3;
        final content = trimmed.split(':').last.trim();
        if (content.isNotEmpty && content != '...') cons.add(content);
        continue;
      }

      final cleanLine = trimmed.startsWith('-') || trimmed.startsWith('•') 
          ? trimmed.substring(1).trim() 
          : trimmed;
      
      if (cleanLine.isEmpty) continue;

      if (mode == 1) overall += " $cleanLine";
      if (mode == 2) pros.add(cleanLine);
      if (mode == 3) cons.add(cleanLine);
    }

    return _ParsedSummary(overall.trim(), pros, cons);
  }
}

class _ParsedSummary {
  final String overall;
  final List<String> pros;
  final List<String> cons;
  _ParsedSummary(this.overall, this.pros, this.cons);
}
