import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/styles.dart';
import '../../../services/language_provider.dart';
import '../../../services/theme_provider.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool isEn;
  final bool isDark;
  final Color primaryClr;

  const HomeAppBar({
    super.key,
    required this.isEn,
    required this.isDark,
    required this.primaryClr,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // 1. LOGO or BRAND ICON (Replacing Drawer Menu)
          Icon(Icons.shopping_bag_rounded, color: primaryClr, size: 28),
          const SizedBox(width: 12),
          
          // 2. EXPANDED PREMIUM SEARCH BAR
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/search'),
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppStyles.darkSurfaceColor : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: isDark ? null : [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, size: 20, color: Colors.grey[400]),
                    const SizedBox(width: 10),
                    Text(
                      isEn ? 'Search market...' : 'পণ্য খুঁজুন...',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        // 3. WISHLIST ICON (Moved from Sidebar)
        IconButton(
          icon: Icon(Icons.favorite_outline_rounded, color: Colors.grey[600], size: 22),
          onPressed: () => context.push('/wishlist'),
        ),
        
        // 4. LANGUAGE SWITCHER
        TextButton(
          onPressed: () => ref.read(languageProvider.notifier).toggleLanguage(),
          style: TextButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 8)),
          child: Text(
            isEn ? 'BN' : 'EN',
            style: TextStyle(color: primaryClr, fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ),
        
        // 5. DARK MODE TOGGLE
        IconButton(
          icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: Colors.grey[600], size: 20),
          onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
