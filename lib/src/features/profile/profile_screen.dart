import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../di/providers.dart';
import '../../utils/app_strings.dart';
import '../../utils/styles.dart';
import 'info_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    final configAsync = ref.watch(appConfigProvider);
    final isDark = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);
    final lang = locale.languageCode;

    String t(String key) => AppStrings.get(key, lang);

    return Scaffold(
      backgroundColor:
          isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      body: userAsync.when(
        data: (data) {
          if (data == null) return const Center(child: Text('Please login'));

          final String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
          final String currentMode =
              data['currentMode']?.toString() ?? 'shopping';
          final int points = (data['points'] ?? 0).toInt();
          final String name = data['name'] ?? 'User';
          final String phone = data['phone'] ?? '';
          final String? profilePic = data['profilePic'];
          final String roleStr = data['role'] ?? 'customer';

          final bool isReseller = roleStr == 'reseller';
          final bool isRider = roleStr == 'logistic';
          final bool isStaff = roleStr == 'staff' || roleStr == 'admin';

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, ref, uid, name, phone, profilePic,
                    currentMode, isDark, t),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _buildUnifiedTopCard(points, isDark),
                      _buildSectionHeader(t('personalHub'), isDark),
                      _buildXRow([
                        _gridItem(
                            Icons.shopping_bag_rounded,
                            t('hubActionOrders'),
                            () => context.push('/orders'),
                            Colors.blue,
                            isDark),
                        _gridItem(
                            Icons.favorite_rounded,
                            t('hubActionWishlist'),
                            () => context.push('/wishlist'),
                            Colors.red,
                            isDark),
                        _gridItem(
                            Icons.account_balance_wallet_rounded,
                            t('hubActionWallet'),
                            () => context.push('/wallet'),
                            Colors.teal,
                            isDark),
                        _gridItem(
                            Icons.manage_accounts_rounded,
                            t('hubActionEdit'),
                            () => context.push('/edit-profile'),
                            Colors.orange,
                            isDark),
                      ]),
                      if (roleStr == 'customer') ...[
                        _buildSectionHeader('আয় করুন ও আমাদের সাথে যুক্ত হন', isDark),
                        _buildXRow([
                          _gridItem(
                              Icons.storefront_rounded,
                              'Apply for Reseller',
                              () => context.push('/apply?role=reseller'),
                              Colors.purple,
                              isDark),
                          _gridItem(
                              Icons.delivery_dining_rounded,
                              'Apply for Delivery Person',
                              () => context.push('/apply?role=rider'),
                              Colors.deepOrange,
                              isDark),
                          _gridItem(
                              Icons.badge_rounded,
                              'Apply for Office Staff',
                              () => context.push('/apply?role=staff'),
                              Colors.indigo,
                              isDark),
                        ]),
                      ],
                      if (isReseller) ...[
                        _buildSectionHeader('RESELLER PANEL', isDark),
                        _buildXRow([
                          _gridItem(
                              Icons.dashboard_rounded,
                              'ড্যাশবোর্ড',
                              () => context.push('/reseller'),
                              Colors.purple,
                              isDark),
                          _gridItem(
                              Icons.add_shopping_cart_rounded,
                              'অর্ডার করুন',
                              () => context.push('/'),
                              Colors.orange,
                              isDark),
                          _gridItem(
                              Icons.history_edu_rounded,
                              'সেলস হিস্ট্রি',
                              () => context.push('/orders'),
                              Colors.blue,
                              isDark),
                          _gridItem(
                              Icons.payments_rounded,
                              'পেমেন্ট রিকোয়েস্ট',
                              () => context.push('/wallet'),
                              Colors.green,
                              isDark),
                        ]),
                      ],
                      if (isRider) ...[
                        _buildSectionHeader('DELIVERY PANEL', isDark),
                        _buildXRow([
                          _gridItem(
                              Icons.moped_rounded,
                              'ডেলিভারি টাস্ক',
                              () => context.push('/rider'),
                              Colors.deepOrange,
                              isDark),
                          _gridItem(
                              Icons.map_rounded,
                              'লাইভ ম্যাপ',
                              () => context.push('/rider'),
                              Colors.blue,
                              isDark),
                          _gridItem(
                              Icons.fact_check_rounded,
                              'সম্পন্ন টাস্ক',
                              () => context.push('/orders'),
                              Colors.teal,
                              isDark),
                        ]),
                      ],
                      if (isStaff) ...[
                        _buildSectionHeader('STAFF PANEL', isDark),
                        _buildXRow([
                          _gridItem(
                              Icons.admin_panel_settings_rounded,
                              'স্টাফ ড্যাশবোর্ড',
                              () => context.push('/staff'),
                              Colors.indigo,
                              isDark),
                          _gridItem(
                              Icons.chat_bubble_rounded,
                              'কাস্টমার সাপোর্ট',
                              () => context.push('/chat-history'),
                              Colors.blue,
                              isDark),
                          _gridItem(
                              Icons.inventory_2_rounded,
                              'ইনভেন্টরি',
                              () => context.push('/admin'),
                              Colors.orange,
                              isDark),
                        ]),
                      ],
                      _buildSectionHeader(t('teamPartners'), isDark),
                      _buildXRow([
                        _gridItem(
                            Icons.handshake_rounded,
                            'আমাদের পার্টনার',
                            () => _navToInfo(context, 'আমাদের পার্টনার',
                                'settings/partners'),
                            Colors.cyan,
                            isDark),
                        _gridItem(
                            Icons.groups_rounded,
                            'আমাদের স্টাফ',
                            () => _navToInfo(
                                context, 'আমাদের স্টাফ', 'settings/staff_list'),
                            Colors.blueGrey,
                            isDark),
                      ]),
                      _buildSectionHeader('DOWNLOADS & LINKS', isDark),
                      _buildXRow([
                        _gridItem(
                            Icons.cloud_download_rounded,
                            'DOWNLOAD',
                            () => _showDownloadPicker(
                                context, configAsync.value ?? {}, isDark),
                            Colors.blue,
                            isDark),
                        // BACKUP button removed as requested
                      ]),
                      _buildSectionHeader(t('conversations'), isDark),
                      _buildXRow([
                        _gridItem(
                            Icons.forum_rounded,
                            'মেসেজ হিস্ট্রি',
                            () => context.push('/chat-history'),
                            Colors.blue,
                            isDark),
                        _gridItem(
                            Icons.history_rounded,
                            'স্টাফ চ্যাট হিস্ট্রি',
                            () => context.push('/chat-history'),
                            Colors.deepPurple,
                            isDark),
                      ]),
                      _buildSectionHeader(t('supportHelp'), isDark),
                      _buildXRow([
                        _gridItem(Icons.support_agent_rounded, 'লতিক চ্যাট',
                            () => context.push('/chat'), Colors.indigo, isDark),
                        _gridItem(Icons.chat_bubble_rounded, 'whatsapp',
                            () => _launchWhatsApp(), Colors.green, isDark),
                        _gridItem(
                            Icons.phone_forwarded_rounded,
                            'callNow',
                            () => _launchPhone('0123456789'),
                            Colors.redAccent,
                            isDark),
                      ]),
                      _buildSectionHeader(t('informationHub'), isDark),
                      _buildXRow([
                        _gridItem(
                            Icons.menu_book_rounded,
                            'কিভাবে ব্যব...',
                            () => context.push('/how-to-use'),
                            Colors.purple,
                            isDark),
                        _gridItem(
                            Icons.quiz_rounded,
                            'সাধারণ জিজ্ঞাসা',
                            () => _navToInfo(context, 'FAQs', HubPaths.faqs),
                            Colors.blue,
                            isDark),
                        _gridItem(
                            Icons.gavel_rounded,
                            'শর্তাবলী',
                            () => _navToInfo(
                                context, 'শর্তাবলী', HubPaths.termsConditions),
                            Colors.blueGrey,
                            isDark),
                        _gridItem(
                            Icons.info_rounded,
                            'আমাদের সম্পর্কে',
                            () => _navToInfo(
                                context, 'আমাদের সম্পর্কে', HubPaths.aboutUs),
                            Colors.orange,
                            isDark),
                      ]),
                      const SizedBox(height: 40),
                      _buildFooter(context, ref, t, isDark),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _navToInfo(BuildContext context, String title, String path) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => InfoScreen(title: title, docPath: path)));
  }

  void _showDownloadPicker(
      BuildContext context, Map<String, dynamic> config, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppStyles.darkSurfaceColor : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Download Paykari Bazar',
                style: TextStyle(
                    color: isDark ? Colors.white : AppStyles.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _downloadTile(Icons.language_rounded, 'Website (Web App)',
                config['website_url'] ?? 'https://paykaribazar.com', isDark),
            _downloadTile(Icons.android_rounded, 'Android App (APK)',
                config['android_url'] ?? '', isDark),
            _downloadTile(Icons.apple_rounded, 'iOS App (AppStore)',
                config['ios_url'] ?? '', isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _downloadTile(IconData icon, String label, String url, bool isDark) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(label,
          style: TextStyle(
              color: isDark ? Colors.white : AppStyles.textPrimary,
              fontSize: 14)),
      trailing: Icon(Icons.open_in_new_rounded,
          color: isDark ? Colors.white24 : Colors.black26, size: 16),
      onTap: () {
        if (url.isNotEmpty) {
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      },
    );
  }

  Widget _buildHeader(
      BuildContext context,
      WidgetRef ref,
      String uid,
      String name,
      String phone,
      String? profilePic,
      String currentMode,
      bool isDark,
      String Function(String) t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        color: isDark
            ? AppStyles.darkSurfaceColor
            : AppStyles.primaryColor, // Branding Header
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          _buildAvatar(profilePic),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 5),
                    const Icon(Icons.verified_rounded,
                        color: Colors.blueAccent, size: 14),
                  ],
                ),
                Text(phone,
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 11)),
                const SizedBox(height: 10),
                _modeToggleButton(uid, currentMode),
              ],
            ),
          ),
          _headerActionButtons(ref, isDark),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? profilePic) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.white24,
          backgroundImage: profilePic != null ? NetworkImage(profilePic) : null,
          child: profilePic == null
              ? const Icon(Icons.person_rounded,
                  size: 35, color: Colors.white54)
              : null,
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
                color: Colors.green, shape: BoxShape.circle),
            child: const Icon(Icons.check, size: 8, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _modeToggleButton(String uid, String currentMode) {
    return InkWell(
      onTap: () => _toggleWorkMode(uid, currentMode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.work_outline, color: Colors.white, size: 10),
            const SizedBox(width: 6),
            Text(
              currentMode == 'work' ? 'SWITCH TO SHOPPING' : 'SWITCH TO WORK',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerActionButtons(WidgetRef ref, bool isDark) {
    return Column(
      children: [
        _circleIconButton(Icons.help_outline, () {}),
        const SizedBox(height: 10),
        _circleIconButton(Icons.translate_rounded,
            () => ref.read(languageProvider.notifier).toggleLanguage()),
        const SizedBox(height: 10),
        _circleIconButton(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            () => ref.read(themeProvider.notifier).toggleTheme()),
      ],
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration:
            const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildUnifiedTopCard(int points, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppStyles.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: !isDark ? AppStyles.softShadow : null,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded,
                        color: Colors.amber, size: 24),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('পয়েন্ট',
                            style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontSize: 8,
                                fontWeight: FontWeight.bold)),
                        Text('$points',
                            style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 18,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
                width: 1,
                color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.qr_code_2_rounded,
                        color: Colors.blueAccent, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ইনভাইট কোড',
                              style: TextStyle(
                                  color:
                                      isDark ? Colors.white60 : Colors.black54,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                          const Text('MASTER',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    Icon(Icons.copy_rounded,
                        color: isDark ? Colors.white24 : Colors.black26,
                        size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 25, 5, 12),
      child: Row(
        children: [
          Container(
              width: 2,
              height: 10,
              decoration: BoxDecoration(
                  color: AppStyles.primaryColor,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title.toUpperCase(),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white60 : Colors.black45,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildXRow(List<Widget> children) {
    return Wrap(
      spacing: 12,
      runSpacing: 15,
      children: children,
    );
  }

  Widget _gridItem(IconData icon, String label, VoidCallback onTap, Color color,
      bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 75,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppStyles.darkSurfaceColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: !isDark ? AppStyles.softShadow : null,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref,
      String Function(String) t, bool isDark) {
    return Column(
      children: [
        Text('Crafted with ❤️ by Saiful Haq Niloy',
            style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38, fontSize: 10)),
        const Text('v1.0.0+9 • UPDATE PENDING',
            style: TextStyle(
                color: Colors.redAccent,
                fontSize: 9,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => FirebaseAuth.instance.signOut(),
          icon: const Icon(Icons.logout_rounded, size: 16),
          label: Text(t('signOut'),
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ],
    );
  }

  void _toggleWorkMode(String uid, String currentMode) {
    final nextMode = currentMode == 'work' ? 'shopping' : 'work';
    FirebaseFirestore.instance
        .collection(HubPaths.users)
        .doc(uid)
        .update({'currentMode': nextMode});
  }

  void _launchWhatsApp() async {
    const url = 'https://wa.me/880123456789';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _launchPhone(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }
}
