import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paykari_bazar/src/di/providers.dart'; // MASTER HUB
import '../../../utils/styles.dart';

class AddressFormSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? userData;
  const AddressFormSheet({super.key, this.userData});
  @override
  ConsumerState<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<AddressFormSheet> {
  final _details = TextEditingController();
  String _nameTag = 'Home';
  String? _distId, _upaId, _stationId, _areaId;
  String? _distName, _upaName, _areaName;
  double _charge = 0;

  @override // Keep this override
  void initState() {
    super.initState();
    _distId = widget.userData?['districtId'];
    _upaId = widget.userData?['upazilaId'];
    _stationId = widget.userData?['stationId'];
    _areaId = widget.userData?['areaId'];
    _details.text = widget.userData?['details'] ?? '';
    _nameTag = widget.userData?['nameTag'] ?? 'Home';
    _charge = (widget.userData?['charge'] ?? 0.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final locs = ref.watch(visibleLocationsProvider).value ?? [];

    final districts = locs.where((l) => l['type']?.toString().toLowerCase() == 'district').toList();
    final upazilas = locs
        .where((l) => l['type']?.toString().toLowerCase() == 'upazila' && l['parentId'] == _distId)
        .toList();
    final stations = locs
        .where((l) => l['type']?.toString().toLowerCase() == 'station' && l['parentId'] == _upaId)
        .toList();
    final areas = locs
        .where((l) => l['type']?.toString().toLowerCase() == 'area' && l['parentId'] == _stationId)
        .toList();

    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 20),
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('SET DELIVERY ADDRESS',
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
        const SizedBox(height: 20),
        CupertinoSlidingSegmentedControl(
            groupValue: _nameTag,
            children: const {
              'Home': Text('Home', style: TextStyle(fontSize: 12)),
              'Office': Text('Office', style: TextStyle(fontSize: 12))
            },
            onValueChanged: (v) => setState(() => _nameTag = v ?? 'Home')),
        const SizedBox(height: 20),
        _dropdown('Select District', districts, _distId, (v) {
          final d = districts.firstWhere((e) => e['id'] == v);
          setState(() {
            _distId = v;
            _distName = d['name'];
            _upaId = null;
            _stationId = null;
            _areaId = null;
            _charge = (d['baseCharge'] ?? 50.0).toDouble();
          });
        }),
        const SizedBox(height: 12),
        _dropdown('Select Upazila', upazilas, _upaId, (v) {
          final u = upazilas.firstWhere((e) => e['id'] == v);
          final d = districts.firstWhere((e) => e['id'] == _distId);
          setState(() {
            _upaId = v;
            _upaName = u['name'];
            _stationId = null;
            _areaId = null;
            _charge = (u['baseCharge'] ?? d['baseCharge'] ?? 50.0).toDouble();
          });
        }, enabled: _distId != null),
        const SizedBox(height: 12),
        _dropdown('Select Station / Bazar', stations, _stationId, (v) {
          final s = stations.firstWhere((e) => e['id'] == v);
          final u = upazilas.firstWhere((e) => e['id'] == _upaId);
          final d = districts.firstWhere((e) => e['id'] == _distId);
          setState(() {
            _stationId = v;
            _areaId = null;
            _charge = (s['baseCharge'] ?? u['baseCharge'] ?? d['baseCharge'] ?? 50.0).toDouble();
          });
        }, enabled: _upaId != null),
        const SizedBox(height: 12),
        _dropdown('Select Specific Area', areas, _areaId, (v) {
          final a = areas.firstWhere((e) => e['id'] == v);
          final s = stations.firstWhere((e) => e['id'] == _stationId);
          final u = upazilas.firstWhere((e) => e['id'] == _upaId, 
              orElse: () => {'baseCharge': null});
          final d = districts.firstWhere((e) => e['id'] == _distId, 
              orElse: () => {'baseCharge': 50.0});
              
          setState(() {
            _areaId = v;
            _areaName = a['name'];
            _charge = (a['baseCharge'] ?? s['baseCharge'] ?? u['baseCharge'] ?? d['baseCharge'] ?? 50.0).toDouble();
          });
        }, enabled: _stationId != null),
        const SizedBox(height: 20),
        TextField(
            controller: _details,
            decoration: AppStyles.inputDecoration(
                    'House No, Road No, Landmark', false)
                .copyWith(
                    prefixIcon:
                        const Icon(Icons.maps_home_work_outlined, size: 20))),
        const SizedBox(height: 24),
        ElevatedButton(
            onPressed: _distId == null ? null : _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryColor,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: Text(_distId == null ? 'SELECT LOCATION' : 'CONFIRM & SAVE (৳${_charge.toInt()})',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5)))
      ])),
    );
  }

  void _saveAddress() async {
    final locs = ref.read(locationsProvider).value ?? [];
    _distName ??= locs.firstWhere((l) => l['id'] == _distId,
        orElse: () => {'name': ''})['name'];
    _upaName ??= locs.firstWhere((l) => l['id'] == _upaId,
        orElse: () => {'name': ''})['name'];
    final String stationName = _stationId != null
        ? (locs.firstWhere((l) => l['id'] == _stationId, orElse: () => {'name': ''})['name'] ?? '')
        : '';
    _areaName ??= _areaId != null
        ? (locs.firstWhere((l) => l['id'] == _areaId, orElse: () => {'name': ''})['name'] ?? '')
        : '';

    final current = List<Map<String, dynamic>>.from(
        ref.read(currentUserDataProvider).value?['addresses'] ?? []);
    final String targetUid =
        widget.userData?['uid'] ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    final String? editAddressId = widget.userData?['addressId'];

    if (targetUid.isNotEmpty) {
      final List<Map<String, dynamic>> newList = [];
      bool replaced = false;

      final newAddressMap = {
        'id': editAddressId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _nameTag,
        'district': _distName,
        'upazila': _upaName,
        'station': stationName,
        'area': _areaName,
        'areaId': _areaId ?? _stationId ?? _upaId ?? _distId,
        'details': _details.text.trim(),
        'charge': _charge,
        'deliveryCharge': _charge,
      };

      if (editAddressId != null) {
        for (final item in current) {
          if (item['id'] == editAddressId) {
            newList.add(newAddressMap);
            replaced = true;
          } else {
            newList.add(item);
          }
        }
      }

      if (!replaced) {
        newList.addAll(current);
        newList.add(newAddressMap);
      }

      await ref.read(firestoreServiceProvider).updateProfile(targetUid, {
        'addresses': newList,
        'districtId': _distId,
        'upazilaId': _upaId,
        'stationId': _stationId,
        'areaId': _areaId,
      });
    }

    if (mounted) Navigator.pop(context);
  }

  Widget _dropdown(String hint, List items, String? val, Function(String?) onC,
          {bool enabled = true}) =>
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                      enabled ? Colors.grey.shade300 : Colors.grey.shade200)),
          child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  hint: Text(hint,
                      style: TextStyle(
                          fontSize: 13,
                          color: enabled ? Colors.black87 : Colors.grey[400])),
                  value: val,
                  isExpanded: true,
                  items: items
                      .map((i) => DropdownMenuItem(
                          value: i['id'].toString(),
                          child: Text(i['name'],
                              style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: enabled ? onC : null)));
}
