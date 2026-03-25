import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import '../../utils/styles.dart';
import '../../utils/app_strings.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});
  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  String _t(String k) => AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final promoAsync = ref.watch(promoProvider);
    final topBuyersAsync = ref.watch(monthlyTopBuyersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(monthlyTopBuyersProvider);
          ref.invalidate(promoProvider);
          ref.invalidate(heroRecordsProvider);
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // --- TOP BUYERS PODIUM ---
              _buildSectionTitle(_t('topBuyersMonth'), Icons.emoji_events_rounded),
              promoAsync.when(
                data: (promoList) {
                  final promo = promoList.isNotEmpty ? promoList.first : <String, dynamic>{};
                  return topBuyersAsync.when(
                    data: (users) => _buildTopBuyersPodium(List<Map<String, dynamic>>.from(users), promo, isDark),
                    loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => _buildErrorWidget(e), 
                  );
                },
                loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => _buildErrorWidget(e),
              ),
              const SizedBox(height: 30),

              // --- TOP BUYERS PERFORMANCE GRAPH ---
              _buildSectionTitle(_t('topBuyersPerformance'), Icons.analytics_rounded),
              topBuyersAsync.when(
                data: (users) => _buildTopBuyersPerformanceGraph(List<Map<String, dynamic>>.from(users), isDark),
                loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => _buildErrorWidget(e),
              ),
              const SizedBox(height: 30),

              // --- BLOOD HEROES ---
              _buildSectionTitle(_t('bloodHeroesMonth'), Icons.favorite_rounded),
              promoAsync.when(
                data: (promoList) {
                  final promo = promoList.isNotEmpty ? promoList.first : <String, dynamic>{};
                  return _buildHeroSegment('blood', Colors.redAccent, isDark, promo);
                },
                loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => _buildErrorWidget(e),
              ),
              const SizedBox(height: 30),

              // --- MEDICINE HEROES ---
              _buildSectionTitle(_t('emergencyHeroesMonth'), Icons.medical_services_rounded),
              promoAsync.when(
                data: (promoList) {
                  final promo = promoList.isNotEmpty ? promoList.first : <String, dynamic>{};
                  return _buildHeroSegment('medicine', Colors.blueAccent, isDark, promo);
                },
                loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => _buildErrorWidget(e),
              ),
              const SizedBox(height: 30),

              // --- AVAILABLE COUPONS ---
              _buildSectionTitle(_t('availableCoupons'), Icons.confirmation_number_rounded),
              promoAsync.when(
                data: (promoList) {
                  final promo = promoList.isNotEmpty ? promoList.first : <String, dynamic>{};
                  return _buildLiveCoupons(promo['promoCodes'] as List? ?? [], isDark);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _buildErrorWidget(e),
              ),
              const SizedBox(height: 30),

              // --- NEXT MEGA DRAW ---
              _buildSectionTitle(_t('nextMegaDraw'), Icons.stars_rounded),
              promoAsync.when(
                data: (promoList) {
                  final promo = promoList.isNotEmpty ? promoList.first : <String, dynamic>{};
                  return _buildMegaDrawHeader(promo, isDark);
                },
                loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => _buildErrorWidget(e),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBuyersPodium(List<Map<String, dynamic>> buyers, Map<String, dynamic> promo, bool isDark) {
    if (buyers.isEmpty) return Container(height: 100, alignment: Alignment.center, decoration: AppStyles.cardDecoration(isDark), child: Text(_t('noTopBuyers'), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)));
    
    final gifts = promo['heroGifts'] as Map<String, dynamic>? ?? {};
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (buyers.length > 1) 
          _podiumItem(buyers[1], 2, (gifts['buyer2'] ?? 'Silver').toString(), const Color(0xFFC0C0C0), isDark), 
        if (buyers.isNotEmpty) 
          _podiumItem(buyers[0], 1, (gifts['buyer1'] ?? 'Gold').toString(), const Color(0xFFFFD700), isDark),
        if (buyers.length > 2) 
          _podiumItem(buyers[2], 3, (gifts['buyer3'] ?? 'Bronze').toString(), const Color(0xFFCD7F32), isDark),
      ],
    );
  }

  Widget _podiumItem(Map<String, dynamic> buyer, int rank, String gift, Color color, bool isDark) {
    final double avatarSize = rank == 1 ? 80 : 65;
    final String? imageUrl = buyer['profilePic']?.toString() ?? buyer['photoUrl']?.toString() ?? buyer['image']?.toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
              ),
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                backgroundImage: (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith('http')) 
                    ? CachedNetworkImageProvider(imageUrl) 
                    : null,
                child: (imageUrl == null || imageUrl.isEmpty || !imageUrl.startsWith('http')) 
                    ? Text(buyer['name']?.toString().isNotEmpty == true ? buyer['name'][0] : '?', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: rank == 1 ? 24 : 18)) 
                    : null,
              ),
            ),
            Positioned(
              top: -15,
              child: Text(rank == 1 ? '👑' : (rank == 2 ? '🥈' : '🥉'), style: const TextStyle(fontSize: 24)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          buyer['name']?.toString().split(' ').first ?? 'Winner',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Text(
            gift,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: -0.2),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: rank == 1 ? 90 : 80,
          height: rank == 1 ? 60 : (rank == 2 ? 45 : 35),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: Center(
            child: Text(
              rank.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBuyersPerformanceGraph(List<Map<String, dynamic>> buyers, bool isDark) {
    if (buyers.isEmpty) return Container(height: 100, alignment: Alignment.center, decoration: AppStyles.cardDecoration(isDark), child: Text(_t('noData'), style: const TextStyle(color: Colors.grey, fontSize: 12)));

    final top5 = buyers.take(5).toList();
    final double firstAmount = (top5.first['points'] as num? ?? 0).toDouble();
    final double maxAmount = firstAmount > 0 ? firstAmount : 1000.0;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: AppStyles.cardDecoration(isDark),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxAmount * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppStyles.primaryColor,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${top5[groupIndex]['name']}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  children: [
                    TextSpan(
                      text: '${rod.toY.toInt()} pts',
                      style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final int index = value.toInt();
                  if (index >= 0 && index < top5.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        top5[index]['name']?.toString().split(' ').first ?? '',
                        style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(top5.length, (i) {
            final double amount = (top5[i]['points'] as num? ?? 0).toDouble();
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: amount,
                  gradient: LinearGradient(
                    colors: [AppStyles.primaryColor, AppStyles.primaryColor.withOpacity(0.6)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeroSegment(String type, Color color, bool isDark, Map<String, dynamic> promo) {
    final heroRecordsAsync = ref.watch(heroRecordsProvider);
    final now = DateTime.now();
    final firstDayCurrentMonth = DateTime(now.year, now.month);
    final lastMonthDate = firstDayCurrentMonth.subtract(const Duration(days: 1));
    final monthKey = DateFormat('yyyy-MM', 'en').format(lastMonthDate);
    
    final gifts = promo['heroGifts'] as Map<String, dynamic>? ?? {};
    final prize = gifts[type == 'blood' ? 'bloodHero' : 'medicineHero'] ?? gifts['1st'] ?? 'Special Reward';

    return Column(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('monthly_stats').doc(monthKey).collection('heroes').where('type', isEqualTo: type).orderBy('earnedPoints', descending: true).limit(1).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final d = snapshot.data!.docs.first.data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withOpacity(0.2), color.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(25), 
                  border: Border.all(color: color.withOpacity(0.3))
                ),
                child: Column(
                  children: [
                    Row(children: [
                      _heroAvatar(d['profilePic']?.toString() ?? d['photoUrl']?.toString() ?? d['image']?.toString(), d['name']?.toString().isNotEmpty == true ? d['name'][0] : '?', color),
                      const SizedBox(width: 15),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('LAST MONTH CHAMPION', style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        Text(d['name']?.toString() ?? 'Winner', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5)),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), 
                        child: const Text('WINNER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                      ),
                    ]),
                    const Divider(height: 24),
                    Row(children: [
                      Icon(Icons.card_giftcard_rounded, size: 16, color: color.withOpacity(0.7)),
                      const SizedBox(width: 8),
                      Text('REWARD: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color.withOpacity(0.8))),
                      Text(prize.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppStyles.primaryColor)),
                      const Spacer(),
                      Text("${d['earnedPoints'] ?? 0} PTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
                    ]),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        heroRecordsAsync.when(
          data: (records) => _buildLiveHeroList(List<Map<String, dynamic>>.from(records), type, color, isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildErrorWidget(e),
        ),
      ],
    );
  }

  Widget _heroAvatar(String? url, String initial, Color color) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: color.withOpacity(0.1),
        backgroundImage: (url != null && url.isNotEmpty && url.startsWith('http')) 
            ? CachedNetworkImageProvider(url) 
            : null,
        child: (url == null || url.isEmpty || !url.startsWith('http')) 
            ? Text(initial, style: TextStyle(color: color, fontWeight: FontWeight.bold)) 
            : null,
      ),
    );
  }

  Widget _buildLiveHeroList(List<Map<String, dynamic>> records, String type, Color color, bool isDark) {
    final currentMonthKey = DateFormat('yyyy-MM', 'en').format(DateTime.now());
    final filtered = records.where((r) {
      final createdAt = r['createdAt'] as Timestamp?;
      if (createdAt == null) return false;
      final recordMonth = DateFormat('yyyy-MM', 'en').format(createdAt.toDate());
      return r['type'] == type && recordMonth == currentMonthKey;
    }).toList();

    final Map<String, Map<String, dynamic>> grouped = {};
    for (var r in filtered) {
      final String uid = r['userId']?.toString() ?? r['userName']?.toString() ?? 'Hero';
      if (!grouped.containsKey(uid)) {
        grouped[uid] = {'name': r['userName'] ?? 'Hero', 'points': 0};
      }
      grouped[uid]!['points'] = (grouped[uid]!['points'] as int) + ((r['earnedPoints'] ?? 0) as int);
    }
    
    final sorted = grouped.values.toList()..sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));

    if (sorted.isEmpty) return Container(padding: const EdgeInsets.all(20), width: double.infinity, decoration: AppStyles.cardDecoration(isDark), child: Center(child: Text(_t('noActiveHeroes'), style: const TextStyle(color: Colors.grey, fontSize: 12))));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration(isDark),
      child: Column(children: sorted.take(5).map((e) => _buildHeroRow(e['name']?.toString() ?? 'Hero', '${e['points']} pts', color)).toList()),
    );
  }

  Widget _buildHeroRow(String name, String points, Color color, {int? rank}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      if (rank != null) Container(width: 24, height: 24, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Center(child: Text(rank.toString(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)))),
      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const Spacer(),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(points, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11))),
    ]),
  );

  Widget _buildLiveCoupons(List coupons, bool isDark) {
    if (coupons.isEmpty) return Container(padding: const EdgeInsets.all(20), width: double.infinity, decoration: AppStyles.cardDecoration(isDark), child: Center(child: Text(_t('noActiveCoupons'), style: const TextStyle(color: Colors.grey, fontSize: 12))));
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          final coupon = Map<String, dynamic>.from(coupons[index] as Map);
          return _buildCouponCard(coupon, isDark, index);
        },
      ),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> c, bool isDark, int index) {
    final lightColors = [const Color(0xFFE3F2FD), const Color(0xFFF1F8E9), const Color(0xFFFFF3E0)];
    final discountValue = c['discount'] ?? 0;
    final discount = c['type'] == 'percentage' ? '$discountValue%' : '৳$discountValue';
    final bgColor = isDark ? Colors.white.withOpacity(0.05) : lightColors[index % lightColors.length];
    
    return Container(
      width: 220, margin: const EdgeInsets.only(right: 15), padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.white10 : Colors.white.withOpacity(0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${_t('save')} $discount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
        Text("${_t('onOrdersAbove_label')} ${c['minOrder']}", style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.grey)),
        const Spacer(),
        Row(children: [
          Text(c['code']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppStyles.primaryColor)),
          const Spacer(),
          IconButton(onPressed: () { Clipboard.setData(ClipboardData(text: c['code']?.toString() ?? '')); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('copyCode')))); }, icon: const Icon(Icons.copy_rounded, size: 18, color: AppStyles.primaryColor), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
        ]),
      ]),
    );
  }

  Widget _buildMegaDrawHeader(Map<String, dynamic> promo, bool isDark) {
    final gifts = promo['heroGifts'] as Map<String, dynamic>? ?? {};
    final String date = (gifts['megaDrawDate'] ?? 'Coming Soon').toString();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppStyles.primaryGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: AppStyles.primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
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
                  Text(_t('prize').toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Text((gifts['1st'] ?? 'Special Mega Prize').toString(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.stars_rounded, color: Colors.white, size: 40),
            ],
          ),
          const Divider(color: Colors.white24, height: 32),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(date, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: Text(_t('megaDrawPool'), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(children: [
        Icon(icon, size: 20, color: AppStyles.primaryColor),
        const SizedBox(width: 10),
        Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
      ]),
    );
  }

  Widget _buildErrorWidget(dynamic error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text('${_t('errorOccurred')}: $error', style: const TextStyle(color: Colors.red, fontSize: 11))),
        ],
      ),
    );
  }
}
