import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import '../../../utils/styles.dart';

class CouponListScreen extends ConsumerWidget {
  const CouponListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEn = ref.watch(languageProvider).languageCode == 'en';
    final promoStream = ref.watch(promoProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      appBar: AppBar(
        title: Text(isEn ? 'Voucher Center' : 'কুপন ও ভাউচার', 
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: promoStream.when(
        data: (coupons) {
          if (coupons.isEmpty) return _buildEmptyState(isEn);

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: coupons.length,
            itemBuilder: (context, index) => _buildVoucherCard(context, coupons[index], isEn, isDark),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _buildVoucherCard(BuildContext context, Map<String, dynamic> coupon, bool isEn, bool isDark) {
    const themeColor = AppStyles.primaryColor;
    final code = coupon['code'] ?? '';
    final discount = coupon['discount'] ?? '0';
    final String target = coupon['targetUser'] ?? 'All Users';
    final String description = coupon['description'] ?? (isEn ? 'Use this code to save money' : 'এই কোডটি ব্যবহার করে টাকা সাশ্রয় করুন');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppStyles.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 110,
                color: themeColor.withValues(alpha: 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('৳$discount', style: const TextStyle(color: themeColor, fontWeight: FontWeight.w900, fontSize: 22)),
                    Text(isEn ? 'OFF' : 'ছাড়', style: const TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                            child: Text(_getTargetLabel(target, isEn), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 10)),
                          ),
                          Icon(Icons.new_releases_rounded, color: Colors.amber[700], size: 16),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(coupon['title'] ?? (isEn ? 'Special Discount' : 'বিশেষ ছাড়'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(description, style: TextStyle(color: Colors.grey[500], fontSize: 11, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _copyCode(context, code, isEn),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : Colors.grey[100], 
                                  borderRadius: BorderRadius.circular(12), 
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1))
                                ),
                                alignment: Alignment.center,
                                child: Text(code, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _copyCode(context, code, isEn),
                            icon: const Icon(Icons.copy_all_rounded, color: Colors.indigo),
                            style: IconButton.styleFrom(
                              backgroundColor: themeColor.withValues(alpha: 0.1), 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyCode(BuildContext context, String code, bool isEn) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Text(isEn ? 'Coupon "$code" copied!' : 'কুপন "$code" কপি করা হয়েছে!'),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  String _getTargetLabel(String target, bool isEn) {
    final t = target.toLowerCase();
    if (t.contains('new')) return isEn ? 'NEW USER' : 'নতুন ইউজার';
    if (t.contains('blood')) return isEn ? 'BLOOD HERO' : 'রক্তদাতা';
    if (t.contains('local')) return isEn ? 'LOCAL HERO' : 'এলাকার বীর';
    return isEn ? 'FOR ALL' : 'সবার জন্য';
  }

  Widget _buildEmptyState(bool isEn) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(isEn ? 'No Vouchers Found' : 'কোনো কুপন পাওয়া যায়নি', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

