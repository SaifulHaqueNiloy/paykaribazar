import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/providers.dart';

class InventoryForecastingWidget extends ConsumerWidget {
  const InventoryForecastingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.indigo.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_graph_rounded,
                    color: Colors.indigo, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI INVENTORY FORECAST',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          fontSize: 12,
                          color: Colors.indigo),
                    ),
                    Text(
                      'Predicting stock-out risks...',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          FutureBuilder<String>(
            future: ref.read(forecastingServiceProvider).predictRestockNeed(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.indigo),
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                );
              }

              final result = snapshot.data ?? 'No data available.';
              return Text(
                result,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.5,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                // Future: Detailed analysis page
              },
              icon: const Icon(Icons.analytics_outlined, size: 14),
              label: const Text('FULL ANALYSIS',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
              style: TextButton.styleFrom(foregroundColor: Colors.indigo),
            ),
          ),
        ],
      ),
    );
  }
}

