import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import '../../utils/app_strings.dart';
import '../../utils/styles.dart';
import 'widgets/greeting_widget.dart';
import 'widgets/notice_slider.dart';
import 'widgets/home_widgets.dart';
import 'widgets/flash_sale_timer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<bool> _showStickyHeader = ValueNotifier<bool>(false);
  Timer? _rewardTimer;

  final GlobalKey _flashKey = GlobalKey();
  final GlobalKey _comboKey = GlobalKey();
  final GlobalKey _hotKey = GlobalKey();
  final GlobalKey _newKey = GlobalKey();
  final GlobalKey _specialKey = GlobalKey();
  final GlobalKey _justForYouKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _checkAndShowRewards();
  }

  void _onScroll() {
    if (_scroll.hasClients) {
      if (_scroll.offset > 200 && !_showStickyHeader.value) {
        _showStickyHeader.value = true;
      } else if (_scroll.offset <= 200 && _showStickyHeader.value) {
        _showStickyHeader.value = false;
      }
    }
  }

  // DNA ENFORCED: Reward Notification Logic
  void _checkAndShowRewards() {
    _rewardTimer = Timer(const Duration(seconds: 30), () async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || !mounted) return;

      final points = await ref.read(loyaltyServiceProvider).getPointsEarnedSinceLastSeen(user.uid);
      if (points > 0 && mounted) {
        _showRewardPopup(points);
      }
    });
  }

  void _showRewardPopup(int points) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(colors: [AppStyles.primaryColor, AppStyles.accentColor]),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 50),
              const SizedBox(height: 16),
              const Text('অভিনন্দন! 🎁', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text(
                'আপনি নতুন $points লয়্যালটি পয়েন্ট অর্জন করেছেন!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppStyles.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('ধন্যবাদ', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _showStickyHeader.dispose();
    _rewardTimer?.cancel();
    super.dispose();
  }

  String _t(String k) {
    final locale = ref.watch(languageProvider);
    return AppStrings.get(k, locale.languageCode);
  }

  void _navigateToAllProducts() {
    ref.read(navProvider.notifier).setIndex(2);
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildSectionShortcuts(bool isDark) {
    final shortcuts = [
      {'label': _t('flashDeals'), 'icon': Icons.bolt_rounded, 'color': Colors.amber, 'key': _flashKey},
      {'label': _t('comboPack'), 'icon': Icons.card_giftcard_rounded, 'color': Colors.purpleAccent, 'key': _comboKey},
      {'label': _t('topSellingProducts'), 'icon': Icons.local_fire_department_rounded, 'color': Colors.deepOrange, 'key': _hotKey},
      {'label': _t('newArrivals'), 'icon': Icons.auto_awesome_rounded, 'color': Colors.teal, 'key': _newKey},
      {'label': _t('specialOffers'), 'icon': Icons.local_offer_rounded, 'color': Colors.redAccent, 'key': _specialKey},
      {'label': _t('justForYou'), 'icon': Icons.favorite_rounded, 'color': Colors.pinkAccent, 'key': _justForYouKey},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: shortcuts.map((shortcut) {
          final label = shortcut['label'] as String;
          final icon = shortcut['icon'] as IconData;
          final color = shortcut['color'] as Color;
          final key = shortcut['key'] as GlobalKey;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => _scrollToSection(key),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [color.withOpacity(0.12), color.withOpacity(0.04)] 
                        : [color.withOpacity(0.08), color.withOpacity(0.02)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: color.withOpacity(isDark ? 0.3 : 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final promoAsync = ref.watch(promoProvider);
    
    // 🔵 Performance Optimization: Watch single productsProvider and filter locally.
    // This replaces 6 separate Firestore listeners with one, significantly reducing listener overhead.
    final productsAsync = ref.watch(productsProvider);

    AsyncValue<List<Map<String, dynamic>>> filterProducts(String type) {
      return productsAsync.whenData((list) {
        switch (type) {
          case 'flash': return list.where((p) => p['isFlashSale'] == true).toList();
          case 'new': return list.where((p) => p['isNewArrival'] == true || p['isNew'] == true).toList();
          case 'hot': return list.where((p) => p['isHotSelling'] == true || p['isHot'] == true).toList();
          case 'combo': return list.where((p) => p['categoryId'] == 'combo' || p['categoryName'] == 'Combo' || p['categoryNameBn'] == 'কম্বো' || p['isCombo'] == true).toList();
          case 'special': return list.where((p) => (p['oldPrice'] ?? 0) > (p['price'] ?? 0)).toList();
          case 'justForYou': return list.where((p) => p['isRecommended'] == true).toList();
          default: return [];
        }
      });
    }

    return Scaffold(
      backgroundColor: isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                expandedHeight: 0,
                backgroundColor: isDark ? AppStyles.darkBackgroundColor : AppStyles.primaryColor,
                title: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppStyles.accentColor),
                    const SizedBox(width: 8),
                    Text(_t('appName'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                      onPressed: () {
                        // 💡 Issue 15: Placeholder until NotificationsScreen is implemented
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('কোনো নতুন নোটিফিকেশন নেই')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: NoticeSlider()),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    productsAsync.when(
                      data: (_) => const SizedBox.shrink(),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator(color: AppStyles.primaryColor)),
                      ),
                      error: (err, stack) => Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 30),
                            const SizedBox(height: 8),
                            Text(
                              'প্রোডাক্ট লোড করতে সমস্যা হয়েছে: $err',
                              style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const GreetingWidget(),
                    promoAsync.when(
                      data: (promo) {
                        if (promo.isEmpty) return const SizedBox.shrink();
                        final firstPromo = promo.first;
                        final banners = firstPromo['banners'];
                        if (banners == null || banners is! List || banners.isEmpty) return const SizedBox.shrink();
                        return BannerSlider(banners: List<String>.from(banners));
                      },
                      loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                      error: (e, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: StaticSearchBar(isDark: isDark, t: _t),
                    ),
                    _buildSectionShortcuts(isDark),
                    
                    // Product Sections using optimized providers
                    filterProducts('flash').when(
                      data: (flashDeals) {
                        return Column(
                          key: _flashKey,
                          children: [
                            if (flashDeals.isNotEmpty) ...[
                              SectionHeader(title: _t('flashDeals'), onTap: _navigateToAllProducts),
                              Builder(
                                builder: (context) {
                                  final endTimeRaw = flashDeals.first['flashSaleEndTime'];
                                  DateTime endTime;
                                  if (endTimeRaw is Timestamp) {
                                    endTime = endTimeRaw.toDate();
                                  } else if (endTimeRaw is String) {
                                    endTime = DateTime.tryParse(endTimeRaw) ?? DateTime.now().add(const Duration(hours: 4));
                                  } else {
                                    endTime = DateTime.now().add(const Duration(hours: 4));
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: FlashSaleTimer(endTime: endTime),
                                  );
                                }
                              ),
                            ],
                            if (flashDeals.isNotEmpty)
                              ProductHorizontalList(
                                products: flashDeals,
                                emptyMessage: _t('noFlashSales'),
                              ),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    
                    // Combo Packs Section
                    filterProducts('combo').when(
                      data: (comboPacks) {
                        if (comboPacks.isEmpty) return const SizedBox.shrink();
                        return Column(
                          key: _comboKey,
                          children: [
                            SectionHeader(
                              title: _t('comboPack'),
                              onTap: _navigateToAllProducts,
                            ),
                            ProductHorizontalList(
                              products: comboPacks,
                              emptyMessage: _t('noProductsFound'),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    
                    // Top Selling Products Section
                    filterProducts('hot').when(
                      data: (hotSelling) {
                        if (hotSelling.isEmpty) return const SizedBox.shrink();
                        return Column(
                          key: _hotKey,
                          children: [
                            SectionHeader(
                              title: _t('topSellingProducts'),
                              onTap: _navigateToAllProducts,
                            ),
                            ProductHorizontalList(
                              products: hotSelling,
                              emptyMessage: _t('noProductsFound'),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    
                    // New Arrivals Section
                    filterProducts('new').when(
                      data: (newArrivals) {
                        if (newArrivals.isEmpty) return const SizedBox.shrink();
                        return Column(
                          key: _newKey,
                          children: [
                            SectionHeader(
                              title: _t('newArrivals'),
                              onTap: _navigateToAllProducts,
                            ),
                            ProductHorizontalList(
                              products: newArrivals,
                              emptyMessage: _t('noProductsFound'),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    
                    // Special Offers Section
                    filterProducts('special').when(
                      data: (specialOffers) {
                        if (specialOffers.isEmpty) return const SizedBox.shrink();
                        return Column(
                          key: _specialKey,
                          children: [
                            SectionHeader(
                              title: _t('specialOffers'),
                              onTap: _navigateToAllProducts,
                            ),
                            ProductHorizontalList(
                              products: specialOffers,
                              emptyMessage: _t('noProductsFound'),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    // Just For You Section
                    filterProducts('justForYou').when(
                      data: (justForYou) {
                        if (justForYou.isEmpty) return const SizedBox.shrink();
                        return Column(
                          key: _justForYouKey,
                          children: [
                            SectionHeader(
                              title: _t('justForYou'),
                              onTap: _navigateToAllProducts,
                            ),
                            ProductHorizontalList(
                              products: justForYou,
                              emptyMessage: _t('noProductsFound'),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _showStickyHeader,
            builder: (context, show, child) {
              return IgnorePointer(
                ignoring: !show,
                child: AnimatedOpacity(
                  opacity: show ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: StickyHeader(isDark: isDark, t: _t),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
