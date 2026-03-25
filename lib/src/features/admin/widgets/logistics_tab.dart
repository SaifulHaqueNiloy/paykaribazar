import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/providers.dart';
import '../../../utils/styles.dart';
import '../../../utils/app_strings.dart';

class LogisticsTab extends ConsumerStatefulWidget {
  const LogisticsTab({super.key});
  @override
  ConsumerState<LogisticsTab> createState() => _LogisticsTabState();
}

class _LogisticsTabState extends ConsumerState<LogisticsTab> {
  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(locationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: locationsAsync.when(
        data: (allLocs) {
          final activeDistricts = allLocs
              .where((l) => l['type'] == 'district' && l['isVisible'] != false)
              .toList();
          final hiddenLocs =
              allLocs.where((l) => l['isVisible'] == false).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_t('manageLocations').toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1)),
                  IconButton(
                      onPressed: () => _showLocationForm(type: 'district'),
                      icon: const Icon(Icons.add_circle_rounded,
                          color: AppStyles.primaryColor, size: 28)),
                ],
              ),
              const SizedBox(height: 16),

              // ACTIVE LOCATIONS GROUP
              if (activeDistricts.isEmpty && hiddenLocs.isEmpty)
                Center(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(children: [
                          const Icon(Icons.map_outlined,
                              size: 60, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(_t('noInfoAvailable'),
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold))
                        ])))
              else ...[
                ...activeDistricts
                    .map((dist) => _buildDistrictTile(dist, allLocs, isDark)),

                // HIDDEN / DEACTIVATED GROUP
                if (hiddenLocs.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off_rounded,
                            color: Colors.grey, size: 18),
                        SizedBox(width: 10),
                        Text('HIDDEN / DEACTIVATED LOCATIONS',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 1)),
                      ],
                    ),
                  ),
                  ...hiddenLocs.map((loc) => _buildHiddenTile(loc, isDark)),
                ]
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${_t('error')}: $e')),
      ),
    );
  }

  Widget _buildDistrictTile(Map<String, dynamic> dist,
      List<Map<String, dynamic>> allLocs, bool isDark) {
    final upazilas = allLocs
        .where((l) => l['type'] == 'upazila' && l['parentId'] == dist['id'])
        .toList();
    final bool isVisible = dist['isVisible'] ?? true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: Icon(Icons.map_rounded,
            color: isVisible ? Colors.indigo : Colors.grey),
        title: Text(dist['name'],
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isVisible ? null : Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: isVisible,
                onChanged: (v) => ref
                    .read(firestoreService)
                    .updateLocation(dist['id'], {'isVisible': v}),
                activeThumbColor: AppStyles.primaryColor,
              ),
            ),
            IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => _showLocationForm(
                    type: 'upazila',
                    parentId: dist['id'],
                    districtId: dist['id'])),
            _buildActionMenu(dist),
          ],
        ),
        children: upazilas
            .map((upa) => _buildUpazilaTile(upa, allLocs, isDark, dist['id']))
            .toList(),
      ),
    );
  }

  Widget _buildUpazilaTile(Map<String, dynamic> upa,
      List<Map<String, dynamic>> allLocs, bool isDark, String districtId) {
    final stations = allLocs
        .where((l) => l['type'] == 'station' && l['parentId'] == upa['id'])
        .toList();
    final bool isVisible = upa['isVisible'] ?? true;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ExpansionTile(
        title: Text(upa['name'],
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isVisible ? Colors.blueGrey : Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
                scale: 0.7,
                child: Switch(
                    value: isVisible,
                    onChanged: (v) => ref
                        .read(firestoreService)
                        .updateLocation(upa['id'], {'isVisible': v}),
                    activeThumbColor: Colors.blueGrey)),
            IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 18),
                onPressed: () => _showLocationForm(
                    type: 'station',
                    parentId: upa['id'],
                    districtId: districtId,
                    upazilaId: upa['id'])),
            _buildActionMenu(upa),
          ],
        ),
        children: stations
            .map((sta) =>
                _buildStationTile(sta, allLocs, isDark, districtId, upa['id']))
            .toList(),
      ),
    );
  }

  Widget _buildStationTile(
      Map<String, dynamic> sta,
      List<Map<String, dynamic>> allLocs,
      bool isDark,
      String distId,
      String upaId) {
    final areas = allLocs
        .where((l) => l['type'] == 'area' && l['parentId'] == sta['id'])
        .toList();
    final bool isVisible = sta['isVisible'] ?? true;

    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: ExpansionTile(
        title: Text(sta['name'],
            style: TextStyle(
                fontSize: 13, color: isVisible ? Colors.teal : Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
                scale: 0.6,
                child: Switch(
                    value: isVisible,
                    onChanged: (v) => ref
                        .read(firestoreService)
                        .updateLocation(sta['id'], {'isVisible': v}),
                    activeThumbColor: Colors.teal)),
            IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 18),
                onPressed: () => _showLocationForm(
                    type: 'area',
                    parentId: sta['id'],
                    districtId: distId,
                    upazilaId: upaId,
                    stationId: sta['id'])),
            _buildActionMenu(sta),
          ],
        ),
        children: areas
            .map((area) => ListTile(
                  contentPadding: const EdgeInsets.only(left: 48, right: 16),
                  title: Text(area['name'],
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: (area['isVisible'] ?? true)
                              ? null
                              : Colors.grey)),
                  subtitle: Text(
                      "৳${area['baseCharge'] ?? 0} | Rider: ৳${area['riderCommission'] ?? 0}",
                      style: const TextStyle(fontSize: 10)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                          scale: 0.6,
                          child: Switch(
                              value: area['isVisible'] ?? true,
                              onChanged: (v) => ref
                                  .read(firestoreService)
                                  .updateLocation(area['id'], {'isVisible': v}),
                              activeThumbColor: Colors.orange)),
                      _buildActionMenu(area),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildHiddenTile(Map<String, dynamic> loc, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      child: ListTile(
        dense: true,
        leading: Icon(Icons.location_off_rounded,
            color: Colors.grey.shade400, size: 20),
        title: Text(loc['name'],
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(loc['type'].toString().toUpperCase(),
            style: const TextStyle(fontSize: 9, color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.visibility_rounded,
                    color: Colors.blue, size: 18),
                onPressed: () => ref
                    .read(firestoreService)
                    .updateLocation(loc['id'], {'isVisible': true})),
            _buildActionMenu(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(Map<String, dynamic> loc) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert, size: 18),
      onSelected: (val) {
        if (val == 'edit') _showLocationForm(existing: loc);
        if (val == 'delete') _confirmDelete(loc);
      },
      itemBuilder: (c) => [
        PopupMenuItem(value: 'edit', child: Text(_t('edit'))),
        PopupMenuItem(
            value: 'delete',
            child:
                Text(_t('delete'), style: const TextStyle(color: Colors.red))),
      ],
    );
  }

  void _showLocationForm(
      {String? type,
      String? parentId,
      String? districtId,
      String? upazilaId,
      String? stationId,
      Map<String, dynamic>? existing}) {
    final nameCtrl = TextEditingController(text: existing?['name']);
    final baseChargeCtrl = TextEditingController(
        text: (existing?['baseCharge'] ?? '60').toString());
    final maxChargeCtrl = TextEditingController(
        text: (existing?['maxCharge'] ?? '200').toString());
    final maxBaseWeightCtrl = TextEditingController(
        text: (existing?['maxBaseWeight'] ?? '2').toString());
    final maxBaseQtyCtrl = TextEditingController(
        text: (existing?['maxBaseQty'] ?? '5').toString());
    final extraWeightChargeCtrl = TextEditingController(
        text: (existing?['extraWeightCharge'] ?? '10').toString());
    final extraQtyChargeCtrl = TextEditingController(
        text: (existing?['extraQtyCharge'] ?? '2').toString());
    final riderCommissionCtrl = TextEditingController(
        text: (existing?['riderCommission'] ?? '20').toString());

    final isArea = (type == 'area' || existing?['type'] == 'area');

    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Text(existing == null
                  ? '${_t('add')} ${type?.toUpperCase()}'
                  : '${_t('edit')} ${existing['type'].toString().toUpperCase()}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(labelText: _t('fullName'))),
                    if (isArea) ...[
                      const SizedBox(height: 16),
                      Text(_t('deliveryRiderSettings'),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppStyles.primaryColor)),
                      const Divider(),
                      Row(children: [
                        Expanded(
                            child: TextField(
                                controller: baseChargeCtrl,
                                decoration: InputDecoration(
                                    labelText: _t('baseCharge')),
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: TextField(
                                controller: maxChargeCtrl,
                                decoration:
                                    InputDecoration(labelText: _t('maxCharge')),
                                keyboardType: TextInputType.number)),
                      ]),
                      Row(children: [
                        Expanded(
                            child: TextField(
                                controller: maxBaseWeightCtrl,
                                decoration: InputDecoration(
                                    labelText: _t('baseWeight')),
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: TextField(
                                controller: extraWeightChargeCtrl,
                                decoration: InputDecoration(
                                    labelText: _t('extraKgCharge')),
                                keyboardType: TextInputType.number)),
                      ]),
                      Row(children: [
                        Expanded(
                            child: TextField(
                                controller: maxBaseQtyCtrl,
                                decoration:
                                    InputDecoration(labelText: _t('baseQty')),
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: TextField(
                                controller: extraQtyChargeCtrl,
                                decoration: InputDecoration(
                                    labelText: _t('extraItemCharge')),
                                keyboardType: TextInputType.number)),
                      ]),
                      TextField(
                          controller: riderCommissionCtrl,
                          decoration:
                              InputDecoration(labelText: _t('riderCommission')),
                          keyboardType: TextInputType.number),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c),
                    child: Text(_t('cancel').toUpperCase())),
                ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty) return;
                      final Map<String, dynamic> data = {
                        'name': nameCtrl.text.trim(),
                        'type': type ?? existing?['type']
                      };

                      if (isArea) {
                        data.addAll({
                          'baseCharge':
                              double.tryParse(baseChargeCtrl.text) ?? 0,
                          'maxCharge': double.tryParse(maxChargeCtrl.text) ?? 0,
                          'maxBaseWeight':
                              double.tryParse(maxBaseWeightCtrl.text) ?? 0,
                          'maxBaseQty': int.tryParse(maxBaseQtyCtrl.text) ?? 0,
                          'extraWeightCharge':
                              double.tryParse(extraWeightChargeCtrl.text) ?? 0,
                          'extraQtyCharge':
                              double.tryParse(extraQtyChargeCtrl.text) ?? 0,
                          'riderCommission':
                              double.tryParse(riderCommissionCtrl.text) ?? 0,
                        });
                      }

                      if (existing != null) {
                        await ref
                            .read(firestoreService)
                            .updateLocation(existing['id'], data);
                      } else {
                        data.addAll({
                          'parentId': parentId,
                          'districtId': districtId,
                          'upazilaId': upazilaId,
                          'stationId': stationId,
                        });
                        await ref.read(firestoreService).addLocation(data);
                      }
                      if (mounted) Navigator.pop(c);
                    },
                    child: Text(_t('save').toUpperCase())),
              ],
            ));
  }

  void _confirmDelete(Map<String, dynamic> loc) async {
    final String type = (loc['type'] ?? 'item').toString().toUpperCase();
    final String name = loc['name'] ?? '';
    final bool isParent = loc['type'] != 'area';
    final confirmCtrl = TextEditingController();

    final confirm = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
              title: Row(children: [
                Icon(
                    isParent
                        ? Icons.report_problem_rounded
                        : Icons.delete_forever_rounded,
                    color: isParent ? Colors.red : Colors.orange),
                const SizedBox(width: 10),
                Text(isParent
                    ? 'CRITICAL SYSTEM WARNING'
                    : _t('deleteItemQuery'))
              ]),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isParent
                      ? 'WARNING: You are deleting a PARENT location ($type). Deleting "$name" will IMMEDIATELY ORPHAN or DELETE all sub-locations and areas underneath it! Checkout for users in this $type will BREAK.'
                      : '${_t('areYouSure')} "$name"? This area will no longer be available for delivery.'),
                  if (isParent) ...[
                    const SizedBox(height: 20),
                    Text('To confirm, type the name "$name" below:',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 10),
                    TextField(
                        controller: confirmCtrl,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Type location name here...')),
                  ]
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c, false),
                    child: Text(_t('cancel').toUpperCase())),
                ElevatedButton(
                    onPressed: () {
                      if (isParent) {
                        if (confirmCtrl.text.trim() == name) {
                          Navigator.pop(c, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Verification failed! Name must match exactly.')));
                        }
                      } else {
                        Navigator.pop(c, true);
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text(_t('delete').toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
              ],
            ));

    if (confirm == true) {
      await ref.read(firestoreService).deleteLocation(loc['id']);
    }
  }
}

