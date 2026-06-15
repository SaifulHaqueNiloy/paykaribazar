import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import 'package:paykari_bazar/src/features/home/widgets/home_widgets.dart';
import '../../utils/app_strings.dart';
import '../../utils/styles.dart';

enum GroupMode { shop, category }

class ProductGroupedScreen extends ConsumerStatefulWidget {
  const ProductGroupedScreen({super.key});

  @override
  ConsumerState<ProductGroupedScreen> createState() => _ProductGroupedScreenState();
}

class _ProductGroupedScreenState extends ConsumerState<ProductGroupedScreen> {
  GroupMode _mode = GroupMode.shop;
  bool _isLoading = true;
  List<QueryDocumentSnapshot> _docs = [];
  String? _error;

  // Selection states
  String? _selectedShopId;
  String? _selectedShopName;
  String? _selectedCategoryName;
  bool _inResellerSubView = false;

  // Grid Format: '3*3', '4*3', '4*4'
  String _gridFormat = '3*3';

  // Sorting Options: 'name_asc', 'name_desc', 'count_desc', 'count_asc', 'price_asc', 'price_desc'
  String _sortBy = 'name_asc';

  // Resellers map: resellerUid -> shopName
  List<Map<String, dynamic>> _allResellersFromDb = [];

  // Category Names Cache: categoryId -> name
  Map<String, String> _categoryNames = {};

  String _t(String k) {
    final locale = ref.watch(languageProvider);
    return AppStrings.get(k, locale.languageCode);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final snapshot = await FirebaseFirestore.instance.collection(HubPaths.products).get();
      
      // বাংলা: ডাটাবেজ থেকে সকল রিসেলারদের শপ নেম লোড করা হচ্ছে
      final resellerSnap = await FirebaseFirestore.instance
          .collection(HubPaths.users)
          .where('role', isEqualTo: 'reseller')
          .get();
      
      final resellersList = <Map<String, dynamic>>[];
      for (final doc in resellerSnap.docs) {
        final data = doc.data();
        data['uid'] = doc.id;
        final name = data['name'] ?? 'Reseller';
        final shopName = data['shopName'] ?? name;
        data['shopName'] = shopName;
        resellersList.add(data);
      }

      // Pre-fetch Category Names
      final catSnapshot = await FirebaseFirestore.instance.collection(HubPaths.categories).get();
      final catMap = <String, String>{};
      for (final doc in catSnapshot.docs) {
        final data = doc.data();
        catMap[doc.id] = data['name']?.toString() ?? doc.id;
      }

      if (mounted) {
        setState(() {
          _docs = snapshot.docs;
          _allResellersFromDb = resellersList;
          _categoryNames = catMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Calculate layout columns dynamically based on selected format
  int get _layoutColumns {
    if (_gridFormat == '3*3') return 3;
    if (_gridFormat == '4*3') return 4;
    if (_gridFormat == '4*4') return 4;
    return 3;
  }

  // Calculate child aspect ratio for main lists (Shops/Categories grid)
  double get _mainGridAspectRatio {
    if (_gridFormat == '3*3') return 0.9; 
    if (_gridFormat == '4*3') return 0.75; 
    if (_gridFormat == '4*4') return 0.75; 
    return 0.9;
  }

  // Calculate child aspect ratio for product cards
  double get _productAspectRatio {
    if (_gridFormat == '3*3') return 0.55; 
    if (_gridFormat == '4*3') return 0.46; 
    if (_gridFormat == '4*4') return 0.56; 
    return 0.55;
  }

  // Group products by ShopId (standard)
  Map<String, List<Map<String, dynamic>>> get _groupedStandardShops {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final doc in _docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      final resellerId = data['resellerId']?.toString();
      if (resellerId == null || resellerId.isEmpty) {
        final shopId = data['shopId']?.toString() ?? 'unknown';
        map.putIfAbsent(shopId, () => []).add(data);
      }
    }
    return map;
  }

  // Group products by ResellerId
  Map<String, List<Map<String, dynamic>>> get _groupedResellerShops {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final doc in _docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      final resellerId = data['resellerId']?.toString();
      if (resellerId != null && resellerId.isNotEmpty) {
        map.putIfAbsent(resellerId, () => []).add(data);
      }
    }
    return map;
  }

  // Group products by Category
  Map<String, List<Map<String, dynamic>>> get _groupedCategories {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final doc in _docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      final catId = data['categoryId']?.toString() ?? 'uncategorized';
      map.putIfAbsent(catId, () => []).add(data);
    }
    return map;
  }

  void _resetSelection() {
    setState(() {
      _selectedShopId = null;
      _selectedShopName = null;
      _selectedCategoryName = null;
      _inResellerSubView = false;
      // Reset sort to default for main pages
      _sortBy = 'name_asc';
    });
  }
  Widget _buildCapsuleTabs(bool isDark) {
    return Container(
      width: 190,
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: _mode == GroupMode.shop ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppStyles.darkSurfaceColor : Colors.white,
                  borderRadius: BorderRadius.circular(23),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _resetSelection();
                    setState(() => _mode = GroupMode.shop);
                  },
                  borderRadius: BorderRadius.circular(23),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          size: 14,
                          color: _mode == GroupMode.shop ? AppStyles.primaryColor : (isDark ? Colors.white70 : Colors.black54),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Shop',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _mode == GroupMode.shop ? (isDark ? Colors.white : AppStyles.primaryColor) : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    _resetSelection();
                    setState(() => _mode = GroupMode.category);
                  },
                  borderRadius: BorderRadius.circular(23),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: 14,
                          color: _mode == GroupMode.category ? AppStyles.primaryColor : (isDark ? Colors.white70 : Colors.black54),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _mode == GroupMode.category ? (isDark ? Colors.white : AppStyles.primaryColor) : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridFormatSelector(bool isDark) {
    Widget buildSelectorItem(String format, IconData icon) {
      final isSelected = _gridFormat == format;
      return GestureDetector(
        onTap: () => setState(() => _gridFormat = format),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppStyles.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 12,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(width: 4),
              Text(
                format,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        buildSelectorItem('3*3', Icons.grid_3x3_rounded),
        const SizedBox(width: 6),
        buildSelectorItem('4*3', Icons.grid_4x4_rounded),
        const SizedBox(width: 6),
        buildSelectorItem('4*4', Icons.grid_on_rounded),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      appBar: AppBar(
        title: Text(
          _selectedShopName ?? _selectedCategoryName ?? 'Products',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        leading: (_selectedShopId != null || _selectedCategoryName != null || _inResellerSubView)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (_selectedShopId != null && _inResellerSubView) {
                    setState(() {
                      _selectedShopId = null;
                      _selectedShopName = null;
                    });
                  } else {
                    _resetSelection();
                  }
                },
              )
            : null,
        backgroundColor: isDark ? AppStyles.darkSurfaceColor : AppStyles.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedShopId == null && _selectedCategoryName == null && !_inResellerSubView)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildCapsuleTabs(isDark),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: StaticSearchBar(isDark: isDark, t: _t),
          ),
          _buildToolbar(isDark),
          Expanded(
            child: RefreshIndicator(
              color: AppStyles.primaryColor,
              onRefresh: _load,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppStyles.primaryColor))
                  : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _docs.isEmpty
                          ? const Center(child: Text('No products found'))
                          : _buildContent(isDark),
            ),
          ),
        ],
      ),
    );
  }

  // Dynamic toolbar for Grid layout selector & Sort dropdown
  Widget _buildToolbar(bool isDark) {
    final isViewingProducts = _selectedShopId != null || _selectedCategoryName != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Format Selector
          Row(
            children: [
              const Text('Grid:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(width: 8),
              _buildGridFormatSelector(isDark),
            ],
          ),
          
          // Sort Dropdown
          Row(
            children: [
              const Icon(Icons.sort_rounded, size: 16, color: AppStyles.primaryColor),
              const SizedBox(width: 4),
              DropdownButton<String>(
                value: _sortBy,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.arrow_drop_down, size: 18),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                dropdownColor: isDark ? AppStyles.darkSurfaceColor : Colors.white,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _sortBy = val);
                  }
                },
                items: isViewingProducts
                    ? const [
                        DropdownMenuItem(value: 'name_asc', child: Text('Name (A-Z)')),
                        DropdownMenuItem(value: 'name_desc', child: Text('Name (Z-A)')),
                        DropdownMenuItem(value: 'price_asc', child: Text('Price: Low-High')),
                        DropdownMenuItem(value: 'price_desc', child: Text('Price: High-Low')),
                      ]
                    : const [
                        DropdownMenuItem(value: 'name_asc', child: Text('Name (A-Z)')),
                        DropdownMenuItem(value: 'name_desc', child: Text('Name (Z-A)')),
                        DropdownMenuItem(value: 'count_desc', child: Text('Products (Max-Min)')),
                        DropdownMenuItem(value: 'count_asc', child: Text('Products (Min-Max)')),
                      ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_mode == GroupMode.shop) {
      if (_selectedShopId != null) {
        // Show Products Grid of Selected Shop
        final products = _selectedShopId!.startsWith('reseller_')
            ? (_groupedResellerShops[_selectedShopId!.replaceFirst('reseller_', '')] ?? [])
            : (_groupedStandardShops[_selectedShopId] ?? []);
        return _buildProductGrid(products, isDark);
      } else if (_inResellerSubView) {
        // Show Reseller Shops Sub-Grid
        return _buildResellerShopsGrid(isDark);
      } else {
        // Show Shops Grid
        return _buildShopsGrid(isDark);
      }
    } else {
      if (_selectedCategoryName != null) {
        // Show Products Grid of Selected Category
        final products = _groupedCategories[_selectedCategoryName] ?? [];
        return _buildProductGrid(products, isDark);
      } else {
        // Show Categories Grid
        return _buildCategoriesGrid(isDark);
      }
    }
  }

  // 1. Grid of Shops (Standard Shops + Reseller Card)
  Widget _buildShopsGrid(bool isDark) {
    final standardShops = _groupedStandardShops.keys.toList();
    
    // Sort standard shops based on preference
    // বাংলা: পছন্দ অনুযায়ী সাধারণ শপ তালিকা সর্ট করা হচ্ছে
    standardShops.sort((a, b) {
      final aName = a == 'unknown' ? 'Default Shop' : a;
      final bName = b == 'unknown' ? 'Default Shop' : b;
      final aCount = _groupedStandardShops[a]?.length ?? 0;
      final bCount = _groupedStandardShops[b]?.length ?? 0;

      if (_sortBy == 'name_asc') return aName.compareTo(bName);
      if (_sortBy == 'name_desc') return bName.compareTo(aName);
      if (_sortBy == 'count_desc') return bCount.compareTo(aCount);
      if (_sortBy == 'count_asc') return aCount.compareTo(bCount);
      return 0;
    });

    final totalItems = standardShops.length + 1; // +1 for Reseller category card

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _layoutColumns,
        childAspectRatio: _mainGridAspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (index < standardShops.length) {
          final shopId = standardShops[index];
          final products = _groupedStandardShops[shopId]!;
          final displayTitle = shopId == 'unknown' ? 'Default Shop' : shopId.toUpperCase();
          
          return _buildGridCard(
            title: displayTitle,
            subtitle: '${products.length} Products',
            icon: Icons.store_rounded,
            iconColor: Colors.blueAccent,
            isDark: isDark,
            onTap: () {
              setState(() {
                _selectedShopId = shopId;
                _selectedShopName = displayTitle;
                // Switch default sort for products page
                _sortBy = 'name_asc';
              });
            },
          );
        } else {
          // Special Reseller Card
          return _buildGridCard(
            title: 'Reseller',
            subtitle: '${_allResellersFromDb.length} Shops',
            icon: Icons.group_work_rounded,
            iconColor: Colors.purple,
            isDark: isDark,
            onTap: () {
              setState(() {
                _inResellerSubView = true;
                // Reset sub-view sorting
                _sortBy = 'name_asc';
              });
            },
          );
        }
      },
    );
  }

  // 2. Sub-Grid of all Reseller Shops from database
  Widget _buildResellerShopsGrid(bool isDark) {
    if (_allResellersFromDb.isEmpty) {
      return const Center(child: Text('No resellers registered.'));
    }

    final resellers = List<Map<String, dynamic>>.from(_allResellersFromDb);

    // Sort resellers
    // বাংলা: পছন্দ অনুযায়ী রিসেলার শপের তালিকা সর্ট করা হচ্ছে
    resellers.sort((a, b) {
      final aName = a['shopName']?.toString() ?? a['name']?.toString() ?? '';
      final bName = b['shopName']?.toString() ?? b['name']?.toString() ?? '';
      final aCount = _groupedResellerShops[a['uid']]?.length ?? 0;
      final bCount = _groupedResellerShops[b['uid']]?.length ?? 0;

      if (_sortBy == 'name_asc') return aName.compareTo(bName);
      if (_sortBy == 'name_desc') return bName.compareTo(aName);
      if (_sortBy == 'count_desc') return bCount.compareTo(aCount);
      if (_sortBy == 'count_asc') return aCount.compareTo(bCount);
      return 0;
    });

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _layoutColumns,
        childAspectRatio: _mainGridAspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: resellers.length,
      itemBuilder: (context, index) {
        final reseller = resellers[index];
        final uid = reseller['uid'] as String;
        final shopName = reseller['shopName'] as String;
        final products = _groupedResellerShops[uid] ?? [];

        return _buildGridCard(
          title: shopName,
          subtitle: '${products.length} Products',
          icon: Icons.storefront_rounded,
          iconColor: Colors.purpleAccent,
          isDark: isDark,
          onTap: () {
            setState(() {
              _selectedShopId = 'reseller_$uid';
              _selectedShopName = shopName;
              _sortBy = 'name_asc';
            });
          },
        );
      },
    );
  }

  // 3. Grid of Categories
  Widget _buildCategoriesGrid(bool isDark) {
    final categories = _groupedCategories.keys.toList();

    // Sort Categories based on pref
    // বাংলা: ক্যাটাগরি তালিকা সর্ট করা হচ্ছে
    categories.sort((a, b) {
      final aName = _categoryNames[a] ?? a;
      final bName = _categoryNames[b] ?? b;
      final aCount = _groupedCategories[a]?.length ?? 0;
      final bCount = _groupedCategories[b]?.length ?? 0;

      if (_sortBy == 'name_asc') return aName.compareTo(bName);
      if (_sortBy == 'name_desc') return bName.compareTo(aName);
      if (_sortBy == 'count_desc') return bCount.compareTo(aCount);
      if (_sortBy == 'count_asc') return aCount.compareTo(bCount);
      return 0;
    });

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _layoutColumns,
        childAspectRatio: _mainGridAspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final categoryId = categories[index];
        final products = _groupedCategories[categoryId]!;
        final name = _categoryNames[categoryId] ?? categoryId;

        return _buildGridCard(
          title: name,
          subtitle: '${products.length} Products',
          icon: Icons.category_rounded,
          iconColor: Colors.teal,
          isDark: isDark,
          onTap: () {
            setState(() {
              _selectedCategoryName = categoryId;
              _sortBy = 'name_asc';
            });
          },
        );
      },
    );
  }

  // Helper Widget for Shop / Category cards in the GridView
  Widget _buildGridCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final titleSize = _layoutColumns == 4 ? 10.0 : 12.0;
    final subtitleSize = _layoutColumns == 4 ? 8.0 : 10.0;
    final iconSize = _layoutColumns == 4 ? 24.0 : 34.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 150),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.03)]
                    : [Colors.white, Colors.grey.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: !isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      )
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: iconSize, color: iconColor),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: titleSize,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 4. Products Grid with 3x3, 4x3, 4x4 options selector
  Widget _buildProductGrid(List<Map<String, dynamic>> products, bool isDark) {
    if (products.isEmpty) {
      return const Center(child: Text('No products available under this section.'));
    }

    final sortedList = List<Map<String, dynamic>>.from(products);

    // Sort products based on selected option
    // বাংলা: ইউজার অপশন অনুযায়ী প্রোডাক্ট তালিকা সর্ট করা হচ্ছে
    sortedList.sort((a, b) {
      final aName = a['nameBn']?.toString().isNotEmpty == true ? a['nameBn'] : (a['name'] ?? '');
      final bName = b['nameBn']?.toString().isNotEmpty == true ? b['nameBn'] : (b['name'] ?? '');
      final aPrice = (a['price'] as num? ?? 0.0).toDouble();
      final bPrice = (b['price'] as num? ?? 0.0).toDouble();

      if (_sortBy == 'name_asc') return aName.compareTo(bName);
      if (_sortBy == 'name_desc') return bName.compareTo(aName);
      if (_sortBy == 'price_asc') return aPrice.compareTo(bPrice);
      if (_sortBy == 'price_desc') return bPrice.compareTo(aPrice);
      return 0;
    });

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _layoutColumns,
        childAspectRatio: _productAspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: sortedList.length,
      itemBuilder: (context, i) => ProductCard(productMap: sortedList[i]),
    );
  }
}
