import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:paykari_bazar/src/di/providers.dart'; // MASTER HUB
import '../../../utils/styles.dart';
import '../../../utils/app_strings.dart';

class MarketingTab extends ConsumerStatefulWidget {
  const MarketingTab({super.key});
  @override
  ConsumerState<MarketingTab> createState() => _MarketingTabState();
}

class _MarketingTabState extends ConsumerState<MarketingTab> {
  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 5,
      child: Column(children: [
        TabBar(
            isScrollable: true,
            labelColor:
                isDark ? AppStyles.darkPrimaryColor : AppStyles.primaryColor,
            indicatorColor:
                isDark ? AppStyles.darkPrimaryColor : AppStyles.primaryColor,
            tabs: [
              Tab(text: _t('masterHub').toUpperCase()),
              Tab(text: _t('faqBonusManager').toUpperCase()),
              Tab(text: _t('coupons').toUpperCase()),
              Tab(text: _t('banners').toUpperCase()),
              Tab(text: _t('notices').toUpperCase()),
            ]),
        Expanded(
            child: TabBarView(children: [
          _buildMasterHub(isDark),
          _buildFaqManager(isDark),
          _buildCouponManager(isDark),
          _buildBannerManager(isDark),
          _buildNoticeManager(isDark),
        ])),
      ]),
    );
  }

  Widget _buildMasterHub(bool isDark) {
    return DefaultTabController(
      length: 3,
      child: Column(children: [
        TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle:
                const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: _t('loyalty').toUpperCase()),
              Tab(text: _t('appInfo').toUpperCase()),
              Tab(text: _t('controls').toUpperCase())
            ]),
        Expanded(
            child: TabBarView(children: [
          _buildLoyaltySubTab(isDark),
          _buildAppInfoSubTab(isDark),
          _buildControlsSubTab(isDark)
        ])),
      ]),
    );
  }

  Widget _buildLoyaltySubTab(bool isDark) {
    final loyaltyAsync = ref.watch(loyaltySettingsProvider);
    return loyaltyAsync.when(
        data: (l) {
          return ListView(padding: const EdgeInsets.all(16), children: [
            _sectionLabel('SPENDING & CONVERSION RULES'),
            _buildEditTile('1 Point = How much BDT?',
                l['pointValueBDT']?.toString() ?? '1.0', 'pointValueBDT'),
            _buildEditTile(
                'Max % of Order Value (Price)',
                l['maxPointUsagePercByPrice']?.toString() ?? '20',
                'maxPointUsagePercByPrice'),
            _buildEditTile(
                'Max % of User Point Balance',
                l['maxPointUsagePercByBalance']?.toString() ?? '50',
                'maxPointUsagePercByBalance'),
            const Divider(height: 32),
            _sectionLabel('HERO & TOP BUYER POINTS'),
            _buildEditTile('1st Top Buyer Points',
                l['buyer1Points']?.toString() ?? '0', 'buyer1Points'),
            _buildEditTile('2nd Top Buyer Points',
                l['buyer2Points']?.toString() ?? '0', 'buyer2Points'),
            _buildEditTile('3rd Top Buyer Points',
                l['buyer3Points']?.toString() ?? '0', 'buyer3Points'),
            _buildEditTile(
                'Blood Hero Points',
                l['bloodDonationPoints']?.toString() ?? '0',
                'bloodDonationPoints'),
            _buildEditTile(
                'Medicine Hero Points',
                l['medicineDeliveryPoints']?.toString() ?? '0',
                'medicineDeliveryPoints'),
            _buildEditTile('Mega Draw Winner Points',
                l['megaDrawPoints']?.toString() ?? '0', 'megaDrawPoints'),
            const Divider(height: 32),
            _sectionLabel('GENERAL LOYALTY RULES'),
            ...l.entries
                .where((e) =>
                    ![
                      'pointValueBDT',
                      'maxPointUsagePercByPrice',
                      'maxPointUsagePercByBalance',
                      'buyer1Points',
                      'buyer2Points',
                      'buyer3Points',
                      'bloodDonationPoints',
                      'medicineDeliveryPoints',
                      'megaDrawPoints'
                    ].contains(e.key) &&
                    e.value is! bool)
                .map((e) => _buildEditTile(e.key, e.value.toString(), e.key,
                    canDelete: true)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _showAddLoyaltyRuleDialog(),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('ADD NEW RULE'),
            ),
          ]);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('${_t('error')}: $e'));
  }

  void _showAddLoyaltyRuleDialog() {
    String? selectedKey;
    final valCtrl = TextEditingController();
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(_t('addLoyaltyRule')),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      onChanged: (v) => selectedKey = v,
                      decoration: const InputDecoration(
                          labelText: 'Setting Key (e.g. signupPoints)')),
                  TextField(
                      controller: valCtrl,
                      decoration: InputDecoration(labelText: _t('pointsValue')))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: Text(_t('cancel').toUpperCase())),
                  ElevatedButton(
                      onPressed: () {
                        if (selectedKey != null && valCtrl.text.isNotEmpty) {
                          ref
                              .read(firestoreServiceProvider)
                              .updateLoyaltySettings({
                            selectedKey!: double.tryParse(valCtrl.text) ??
                                valCtrl.text.trim()
                          });
                          Navigator.pop(c);
                        }
                      },
                      child: Text(_t('save').toUpperCase()))
                ]));
  }

  Widget _buildAppInfoSubTab(bool isDark) {
    final appInfoAsync = ref.watch(appSettingsProvider);
    final promoAsync = ref.watch(promoProvider);

    return ListView(padding: const EdgeInsets.all(16), children: [
      _sectionLabel(_t('appContent').toUpperCase()),
      appInfoAsync.when(
        data: (app) => Column(children: [
          _buildEditTile(
              'About Us (English)', app['about_en'] ?? '...', 'about_en',
              isLoyalty: false, maxLines: 5, docName: 'app_info'),
          _buildEditTile(
              'আমাদের সম্পর্কে (Bangla)', app['about_bn'] ?? '...', 'about_bn',
              isLoyalty: false, maxLines: 5, docName: 'app_info'),
          const Divider(),
          _buildEditTile('Terms & Conditions (English)',
              app['terms_en'] ?? '...', 'terms_en',
              isLoyalty: false, maxLines: 10, docName: 'app_info'),
          _buildEditTile(
              'শর্তাবলী ও নিয়ম (Bangla)', app['terms_bn'] ?? '...', 'terms_bn',
              isLoyalty: false, maxLines: 10, docName: 'app_info'),
        ]),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Error: $e'),
      ),
      const Divider(height: 32),
      _sectionLabel('GIFTS & PRIZES (PHYSICAL REWARDS)'),
      promoAsync.when(
          data: (p) {
            final promoData = p.isNotEmpty ? p[0] : <String, dynamic>{};
            final Map gifts = promoData['heroGifts'] ?? {};
            return Column(children: [
              _buildMegaDrawDateTile(gifts['megaDrawDate'] ?? 'Not Set'),
              _buildGiftOnlyTile('Monthly Top Hero Gift', gifts, '1st'),
              _buildGiftOnlyTile('1st Top Buyer Gift', gifts, 'buyer1'),
              _buildGiftOnlyTile('2nd Top Buyer Gift', gifts, 'buyer2'),
              _buildGiftOnlyTile('3rd Top Buyer Gift', gifts, 'buyer3'),
              _buildGiftOnlyTile('Blood Hero Gift', gifts, 'bloodHero'),
              _buildGiftOnlyTile('Medicine Hero Gift', gifts, 'medicineHero'),
            ]);
          },
          loading: () => const SizedBox(),
          error: (e, _) => Text('${_t('error')}: $e')),
      const Divider(height: 32),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _sectionLabel(_t('megaDrawWinners').toUpperCase()),
        IconButton(
            onPressed: () => _showWinnerDialog(null),
            icon: const Icon(Icons.add_circle, color: Colors.green))
      ]),
      promoAsync.when(
          data: (p) {
            final promoData = p.isNotEmpty ? p[0] : <String, dynamic>{};
            final List winners = promoData['megaDrawWinners'] as List? ?? [];
            return Column(
                children: winners.asMap().entries.map((e) {
              final val = e.value;
              final String name =
                  (val is Map) ? (val['name'] ?? 'Unknown') : val.toString();
              final String gift =
                  (val is Map) ? (val['gift'] ?? 'N/A') : 'Legacy Data';
              return Card(
                  child: ListTile(
                      title: Text(name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(gift),
                      trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 18),
                          onPressed: () => _deleteWinner(e.key))));
            }).toList());
          },
          loading: () => const SizedBox(),
          error: (e, _) => const SizedBox()),
    ]);
  }

  Widget _buildMegaDrawDateTile(String date) {
    return Card(
      color: Colors.amber.withOpacity(0.1),
      child: ListTile(
        leading: const Icon(Icons.calendar_today_rounded, color: Colors.amber),
        title: Text(_t('nextMegaDrawDate'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(date,
            style: const TextStyle(
                fontWeight: FontWeight.w900, color: Colors.amber)),
        trailing: const Icon(Icons.edit, size: 18),
        onTap: () {
          final ctrl = TextEditingController(text: date);
          showDialog(
              context: context,
              builder: (c) => AlertDialog(
                    title: Text(_t('nextMegaDrawDate')),
                    content: TextField(
                        controller: ctrl,
                        decoration: const InputDecoration(
                            hintText: 'e.g. 25 OCT 2023')),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: Text(_t('cancel').toUpperCase())),
                      ElevatedButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('settings')
                                .doc('promotions')
                                .update({
                              'heroGifts.megaDrawDate': ctrl.text.trim()
                            });
                            if (mounted) Navigator.pop(c);
                          },
                          child: Text(_t('save').toUpperCase())),
                    ],
                  ));
        },
      ),
    );
  }

  Widget _buildGiftOnlyTile(String label, Map gifts, String key) {
    final name = gifts[key] ?? 'No Gift Set';
    return Card(
        child: ListTile(
            title: Text(label,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            subtitle: Text('Gift: $name',
                style: const TextStyle(
                    color: AppStyles.primaryColor,
                    fontWeight: FontWeight.w900)),
            trailing: const Icon(Icons.edit, size: 18),
            onTap: () {
              final nCtrl = TextEditingController(text: name);
              showDialog(
                  context: context,
                  builder: (c) => AlertDialog(
                          title: Text('Edit $label'),
                          content: TextField(
                              controller: nCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Physical Gift Name')),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(c),
                                child: Text(_t('cancel').toUpperCase())),
                            ElevatedButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('settings')
                                      .doc('promotions')
                                      .update({
                                    'heroGifts.$key': nCtrl.text.trim()
                                  });
                                  if (mounted) Navigator.pop(c);
                                },
                                child: Text(_t('save').toUpperCase()))
                          ]));
            }));
  }

  Widget _buildControlsSubTab(bool isDark) {
    final appInfoAsync = ref.watch(appSettingsProvider);
    return appInfoAsync.when(
        data: (app) => ListView(padding: const EdgeInsets.all(16), children: [
              _sectionLabel(_t('serviceSwitches').toUpperCase()),
              _buildSwitchTile(_t('emergencyPharmacy'),
                  app['isPharmacyOn'] ?? true, 'isPharmacyOn'),
              _buildSwitchTile(_t('bloodRequestAid'),
                  app['isBloodAidOn'] ?? true, 'isBloodAidOn')
            ]),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('${_t('error')}: $e'));
  }

  Widget _buildFaqManager(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bonus_faqs')
          .orderBy('priority', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
              mini: true,
              backgroundColor: AppStyles.primaryColor,
              onPressed: () => _showFaqDialog(null, docs.length),
              child: const Icon(Icons.add, color: Colors.white)),
          body: ReorderableListView(
            padding: const EdgeInsets.all(16),
            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex -= 1;
              final List<DocumentSnapshot> list = List.from(docs);
              final item = list.removeAt(oldIndex);
              list.insert(newIndex, item);
              for (int i = 0; i < list.length; i++) {
                await list[i].reference.update({'priority': i});
              }
            },
            children: docs.map((doc) {
              final faq = doc.data() as Map<String, dynamic>;
              return Card(
                key: ValueKey(doc.id),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ExpansionTile(
                  leading: const Icon(Icons.drag_handle, color: Colors.grey),
                  title: Text(faq['question'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        icon: const Icon(Icons.edit,
                            size: 18, color: Colors.blue),
                        onPressed: () => _showFaqDialog(doc, docs.length)),
                    IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 18),
                        onPressed: () => doc.reference.delete()),
                  ]),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(faq['answer'] ?? '',
                              style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey[700],
                                  fontSize: 13))),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showFaqDialog(DocumentSnapshot? doc, int currentCount) {
    final qCtrl = TextEditingController(
        text: doc != null ? (doc.data() as Map)['question'] : '');
    final aCtrl = TextEditingController(
        text: doc != null ? (doc.data() as Map)['answer'] : '');
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(doc == null ? _t('addInfo') : _t('editInfo')),
                content: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: qCtrl,
                      decoration: InputDecoration(labelText: _t('title'))),
                  TextField(
                      controller: aCtrl,
                      decoration: InputDecoration(labelText: _t('content')),
                      maxLines: 3)
                ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: Text(_t('cancel').toUpperCase())),
                  ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('bonus_faqs')
                            .doc(doc?.id ??
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString())
                            .set({
                          'question': qCtrl.text.trim(),
                          'answer': aCtrl.text.trim(),
                          'priority': doc != null
                              ? (doc.data() as Map)['priority']
                              : currentCount,
                          'createdAt': FieldValue.serverTimestamp()
                        }, SetOptions(merge: true));
                        if (mounted) Navigator.pop(c);
                      },
                      child: Text(_t('save').toUpperCase()))
                ]));
  }

  Widget _buildEditTile(String label, String val, String key,
      {int maxLines = 1,
      bool canDelete = false,
      bool isLoyalty = true,
      String docName = 'loyalty'}) {
    return Card(
        child: ListTile(
            title: Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold)),
            subtitle: Text(val,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.indigo),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _showEditDialog(
                      label, val, key, maxLines, isLoyalty, docName)),
              if (canDelete)
                IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: Colors.red),
                    onPressed: () => _deleteSetting(key))
            ])));
  }

  void _showEditDialog(String label, String val, String key, int maxLines,
      bool isLoyalty, String docName) {
    final ctrl = TextEditingController(text: val);
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
                title: Text('${_t('edit')} $label'),
                content: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      TextField(
                          controller: ctrl,
                          maxLines: maxLines,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()))
                    ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: Text(_t('cancel').toUpperCase())),
                  ElevatedButton(
                      onPressed: () async {
                        final data = {
                          key: double.tryParse(ctrl.text) ?? ctrl.text.trim()
                        };
                        if (isLoyalty) {
                          await ref
                              .read(firestoreServiceProvider)
                              .updateLoyaltySettings(data);
                        } else {
                          await ref
                              .read(firestoreServiceProvider)
                              .updateAppSettings(docName, data);
                        }
                        if (mounted) Navigator.pop(c);
                      },
                      child: Text(_t('save').toUpperCase()))
                ]));
  }

  Future<void> _deleteSetting(String key) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (c) =>
            AlertDialog(title: Text(_t('deleteItemQuery')), actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: Text(_t('no').toUpperCase())),
              TextButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: Text(_t('delete').toUpperCase()))
            ]));
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('loyalty')
          .update({key: FieldValue.delete()});
    }
  }

  Widget _buildSwitchTile(String l, bool v, String k) =>
      SwitchListTile.adaptive(
          title: Text(l,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          value: v,
          onChanged: (x) => ref
              .read(firestoreServiceProvider)
              .updateAppSettings('app_info', {k: x}),
          activeColor: AppStyles.primaryColor);

  Widget _sectionLabel(String t) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(t,
          style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppStyles.primaryColor,
              fontSize: 12)));

  Widget _buildBannerManager(bool isDark) {
    final promoAsync = ref.watch(promoProvider);
    return promoAsync.when(
        data: (p) {
          final promoData = p.isNotEmpty ? p[0] : <String, dynamic>{};
          final List banners = promoData['banners'] as List? ?? [];
          return ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              Expanded(
                  child: ElevatedButton.icon(
                      onPressed: _uploadBannerFile,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(_t('uploadImage').toUpperCase()))),
              const SizedBox(width: 12),
              Expanded(
                  child: ElevatedButton.icon(
                      onPressed: _addBannerLink,
                      icon: const Icon(Icons.link_rounded),
                      label: Text(_t('addLink').toUpperCase())))
            ]),
            const SizedBox(height: 20),
            ...banners.map((url) => _buildBannerPreviewTile(url))
          ]);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('${_t('error')}: $e'));
  }

  Widget _buildBannerPreviewTile(String url) {
    return Card(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          CachedNetworkImage(
              imageUrl: url,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              errorWidget: (context, url, error) =>
                  const Center(child: Icon(Icons.broken_image, size: 40))),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              color: Colors.black.withOpacity(0.05),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey))),
                    Row(children: [
                      IconButton(
                          icon: const Icon(Icons.edit,
                              size: 18, color: Colors.blue),
                          onPressed: () => _addBannerLink(existing: url)),
                      IconButton(
                          icon: const Icon(Icons.delete,
                              size: 18, color: Colors.red),
                          onPressed: () => _removeBanner(url))
                    ])
                  ]))
        ]));
  }

  Future<void> _uploadBannerFile() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (p != null) {
      final url = await ref
          .read(firestoreServiceProvider)
          .uploadImage(File(p.path), 'banners');
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('promotions')
          .update({
        'banners': FieldValue.arrayUnion([url])
      });
    }
  }

  void _addBannerLink({String? existing}) {
    final ctrl = TextEditingController(text: existing);
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(_t('bannerImageLink')),
                content: TextField(
                    controller: ctrl,
                    decoration: const InputDecoration(
                        hintText: 'https://example.com/image.jpg')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: Text(_t('cancel').toUpperCase())),
                  ElevatedButton(
                      onPressed: () async {
                        if (ctrl.text.isNotEmpty) {
                          if (existing != null) await _removeBanner(existing);
                          await FirebaseFirestore.instance
                              .collection('settings')
                              .doc('promotions')
                              .update({
                            'banners': FieldValue.arrayUnion([ctrl.text.trim()])
                          });
                          if (mounted) Navigator.pop(c);
                        }
                      },
                      child: Text(_t('save').toUpperCase()))
                ]));
  }

  Future<void> _removeBanner(String url) async =>
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('promotions')
          .update({
        'banners': FieldValue.arrayRemove([url])
      });

  Widget _buildNoticeManager(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notices')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notices = snapshot.data!.docs;
          return Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: FloatingActionButton(
                  mini: true,
                  backgroundColor: AppStyles.primaryColor,
                  onPressed: () => _showNoticeDialog(null),
                  child: const Icon(Icons.add, color: Colors.white)),
              body: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notices.length,
                  itemBuilder: (c, i) {
                    final n = notices[i].data() as Map<String, dynamic>;
                    return Card(
                        child: Column(children: [
                      if (n['imageUrl'] != null &&
                          n['imageUrl'].toString().isNotEmpty)
                        CachedNetworkImage(
                            imageUrl: n['imageUrl'],
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (c, e, s) => const SizedBox()),
                      ListTile(
                          title: Text(n['text'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(
                              "Status: ${n['isActive'] == true ? 'Active' : 'Hidden'}",
                              style: TextStyle(
                                  color: n['isActive'] == true
                                      ? Colors.green
                                      : Colors.grey,
                                  fontSize: 11)),
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            Switch(
                                value: n['isActive'] ?? false,
                                onChanged: (v) => notices[i]
                                    .reference
                                    .update({'isActive': v})),
                            IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                onPressed: () => _showNoticeDialog(notices[i])),
                            IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent, size: 18),
                                onPressed: () => notices[i].reference.delete())
                          ]))
                    ]));
                  }));
        });
  }

  void _showNoticeDialog(DocumentSnapshot? doc) {
    final ctrl = TextEditingController(
        text: doc != null ? (doc.data() as Map)['text'] : '');
    final imgUrlCtrl = TextEditingController(
        text: doc != null ? (doc.data() as Map)['imageUrl'] : '');
    File? pickedImg;
    showDialog(
        context: context,
        builder: (c) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                    title:
                        Text(doc == null ? _t('addNotice') : _t('editNotice')),
                    content: SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      TextField(
                          controller: ctrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                              hintText: _t('enterNoticeText'),
                              border: const OutlineInputBorder())),
                      const SizedBox(height: 12),
                      _buildDialogImagePicker(
                          pickedImg,
                          imgUrlCtrl,
                          setDialogState,
                          Theme.of(context).brightness == Brightness.dark),
                      TextField(
                          controller: imgUrlCtrl,
                          decoration:
                              InputDecoration(labelText: _t('pasteImageUrl')))
                    ])),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: Text(_t('cancel').toUpperCase())),
                      ElevatedButton(
                          onPressed: () async {
                            if (ctrl.text.isNotEmpty) {
                              final String finalUrl = imgUrlCtrl.text.trim();
                              final data = {
                                'text': ctrl.text.trim(),
                                'imageUrl': finalUrl,
                                'isActive': true,
                                'createdAt': FieldValue.serverTimestamp()
                              };
                              if (doc == null) {
                                await FirebaseFirestore.instance
                                    .collection('notices')
                                    .add(data);
                              } else {
                                await doc.reference.update({
                                  'text': ctrl.text.trim(),
                                  'imageUrl': finalUrl
                                });
                              }
                              if (mounted) Navigator.pop(c);
                            }
                          },
                          child: Text(_t('save').toUpperCase()))
                    ])));
  }

  Widget _buildDialogImagePicker(File? picked, TextEditingController urlCtrl,
      StateSetter setDialogState, bool isDark) {
    return GestureDetector(
        onTap: () async {
          final p = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (p != null) setDialogState(() => picked = File(p.path));
        },
        child: Container(
            height: 80,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[100],
                borderRadius: BorderRadius.circular(12)),
            child: picked != null
                ? Image.file(picked, fit: BoxFit.cover)
                : (urlCtrl.text.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: urlCtrl.text,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image))
                    : const Icon(Icons.add_a_photo, color: Colors.grey))));
  }

  Widget _buildCouponManager(bool isDark) {
    final promoAsync = ref.watch(promoProvider);
    return promoAsync.when(
        data: (p) {
          final promoData = p.isNotEmpty ? p[0] : <String, dynamic>{};
          final List coupons = List.from(promoData['promoCodes'] ?? []);
          return Scaffold(
              backgroundColor: Colors.transparent,
              floatingActionButton: FloatingActionButton(
                  mini: true,
                  backgroundColor: AppStyles.primaryColor,
                  onPressed: () => _showCouponDialog(null, coupons),
                  child: const Icon(Icons.add, color: Colors.white)),
              body: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: coupons.length,
                  itemBuilder: (c, i) {
                    final coupon = coupons[i], type = coupon['type'] ?? 'fixed';
                    return Card(
                        child: ListTile(
                            leading: const CircleAvatar(
                                child: Icon(Icons.local_offer, size: 20)),
                            title: Text(coupon['code'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                "${type == 'percentage' ? '${coupon['discount']}% OFF' : '৳${coupon['discount']} OFF'} | ${coupon['targetUser']}"),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () =>
                                      _showCouponDialog(coupon, coupons)),
                              IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () =>
                                      _deleteCoupon(coupon, coupons))
                            ])));
                  }));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('${_t('error')}: $e'));
  }

  void _showCouponDialog(Map? coupon, List currentCoupons) {
    final codeCtrl = TextEditingController(text: coupon?['code'] ?? ''),
        discCtrl =
            TextEditingController(text: coupon?['discount']?.toString() ?? ''),
        minCtrl =
            TextEditingController(text: coupon?['minOrder']?.toString() ?? '0'),
        maxDiscCtrl = TextEditingController(
            text: coupon?['maxDiscount']?.toString() ?? ''),
        titleCtrl = TextEditingController(text: coupon?['title'] ?? ''),
        descCtrl = TextEditingController(text: coupon?['description'] ?? '');
    String target = coupon?['targetUser'] ?? 'All Users',
        type = coupon?['type'] ?? 'fixed';
    showDialog(
        context: context,
        builder: (c) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                    title: Text(
                        coupon == null ? _t('addCoupon') : _t('editCoupon')),
                    content: SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      DropdownButtonFormField<String>(
                          initialValue: type,
                          items: [
                            DropdownMenuItem(
                                value: 'fixed', child: Text(_t('fixedAmount'))),
                            DropdownMenuItem(
                                value: 'percentage',
                                child: Text(_t('percentage')))
                          ],
                          onChanged: (v) => setDialogState(() => type = v!),
                          decoration:
                              InputDecoration(labelText: _t('couponType'))),
                      TextField(
                          controller: codeCtrl,
                          decoration:
                              InputDecoration(labelText: _t('couponCodeHint'))),
                      TextField(
                          controller: discCtrl,
                          decoration: InputDecoration(
                              labelText: type == 'percentage'
                                  ? _t('discountPercentage')
                                  : _t('discountAmount')),
                          keyboardType: TextInputType.number),
                      if (type == 'percentage')
                        TextField(
                            controller: maxDiscCtrl,
                            decoration: InputDecoration(
                                labelText: _t('maxDiscountAmount')),
                            keyboardType: TextInputType.number),
                      TextField(
                          controller: minCtrl,
                          decoration:
                              InputDecoration(labelText: _t('minOrderAmount')),
                          keyboardType: TextInputType.number),
                      TextField(
                          controller: titleCtrl,
                          decoration: InputDecoration(labelText: _t('title'))),
                      TextField(
                          controller: descCtrl,
                          decoration: InputDecoration(labelText: _t('content')),
                          maxLines: 2),
                      DropdownButtonFormField<String>(
                          initialValue: target,
                          items: [
                            'All Users',
                            'New Users',
                            'Blood Hero',
                            'Local Hero'
                          ]
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) => target = v!,
                          decoration:
                              InputDecoration(labelText: _t('targetUserGroup')))
                    ])),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: Text(_t('cancel').toUpperCase())),
                      ElevatedButton(
                          onPressed: () async {
                            final newCoupon = {
                              'code': codeCtrl.text.trim().toUpperCase(),
                              'type': type,
                              'discount': double.tryParse(discCtrl.text) ?? 0,
                              'maxDiscount': type == 'percentage'
                                  ? (double.tryParse(maxDiscCtrl.text) ??
                                      999999)
                                  : (double.tryParse(discCtrl.text) ?? 0),
                              'minOrder': double.tryParse(minCtrl.text) ?? 0,
                              'title': titleCtrl.text.trim(),
                              'description': descCtrl.text.trim(),
                              'targetUser': target
                            };
                            final List updated = List.from(currentCoupons);
                            if (coupon != null) {
                              final idx = updated.indexWhere(
                                  (x) => x['code'] == coupon['code']);
                              if (idx != -1) updated[idx] = newCoupon;
                            } else {
                              updated.add(newCoupon);
                            }
                            await FirebaseFirestore.instance
                                .collection('settings')
                                .doc('promotions')
                                .update({'promoCodes': updated});
                            if (mounted) Navigator.pop(c);
                          },
                          child: Text(_t('save').toUpperCase()))
                    ])));
  }

  Future<void> _deleteCoupon(Map coupon, List current) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(_t('deleteCoupon')),
                content: Text('${_t('areYouSure')} ${coupon['code']}?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: Text(_t('no').toUpperCase())),
                  TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: Text(_t('yes').toUpperCase()))
                ]));
    if (confirm == true) {
      final updated =
          current.where((x) => x['code'] != coupon['code']).toList();
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('promotions')
          .update({'promoCodes': updated});
    }
  }

  void _showWinnerDialog(int? index) {
    final promoList = ref.read(promoProvider).value ?? [];
    final promo = promoList.isNotEmpty ? promoList[0] : <String, dynamic>{};
    final List winners = List.from(promo['megaDrawWinners'] as List? ?? []);
    final nameCtrl = TextEditingController(
        text: index != null
            ? (winners[index] is Map
                ? winners[index]['name']
                : winners[index].toString())
            : '');
    final giftCtrl = TextEditingController(
        text: index != null
            ? (winners[index] is Map ? winners[index]['gift'] : '')
            : '');

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(index == null ? _t('addWinner') : _t('editWinner')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: _t('winnerName'))),
            TextField(
                controller: giftCtrl,
                decoration: InputDecoration(labelText: _t('giftPrize'))),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text(_t('cancel').toUpperCase())),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'name': nameCtrl.text.trim(),
                'gift': giftCtrl.text.trim()
              };
              if (index == null) {
                winners.add(data);
              } else {
                winners[index] = data;
              }
              await FirebaseFirestore.instance
                  .collection('settings')
                  .doc('promotions')
                  .update({'megaDrawWinners': winners});
              if (mounted) Navigator.pop(c);
            },
            child: Text(_t('save').toUpperCase()),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWinner(int index) async {
    final promoList = ref.read(promoProvider).value ?? [];
    final promo = promoList.isNotEmpty ? promoList[0] : <String, dynamic>{};
    final List winners = List.from(promo['megaDrawWinners'] as List? ?? []);
    winners.removeAt(index);
    await FirebaseFirestore.instance
        .collection('settings')
        .doc('promotions')
        .update({'megaDrawWinners': winners});
  }
}
