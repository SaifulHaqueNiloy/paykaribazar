import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/providers.dart';
import '../../../utils/styles.dart';

class LoyaltyStatusCard extends ConsumerWidget {
  const LoyaltyStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return userAsync.when(
      data: (data) {
        if (data == null) return const SizedBox.shrink();
        
        final int points = (data['points'] ?? 0).toInt();
        String tier = 'BRONZE';
        double progress = (points % 1000) / 1000;
        Color tierColor = Colors.brown;

        if (points >= 5000) {
          tier = 'PLATINUM';
          tierColor = Colors.cyan;
          progress = 1.0;
        } else if (points >= 2500) {
          tier = 'GOLD';
          tierColor = Colors.amber;
          progress = (points - 2500) / 2500;
        } else if (points >= 1000) {
          tier = 'SILVER';
          tierColor = Colors.grey;
          progress = (points - 1000) / 1500;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppStyles.darkSurfaceColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppStyles.softShadow,
            border: Border.all(color: tierColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LOYALTY STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey[500], letterSpacing: 1)),
                      Text(tier, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: tierColor)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: tierColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text('$points Points', style: TextStyle(color: tierColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: tierColor.withValues(alpha: 0.1),
                  color: tierColor,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.stars_rounded, color: tierColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tier == 'PLATINUM' ? 'You are at the highest tier! Enjoy all benefits.' : 'Earn ${(1000 - (points % 1000))} more points to reach next level.',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

