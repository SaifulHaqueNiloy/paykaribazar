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

  @override
  void initState() {
    super.initState();
    _distId = widget.userData?['districtId'];
    _upaId = widget.userData?['upazilaId'];
  }

  @override
  Widget build(BuildContext context) {
    final locs = ref.watch(locationsProvider).value ?? [];

    final districts = locs.where((l) => l['type'] == 'district').toList();
    final upazilas = locs
        .where((l) => l['type'] == 'upazila' && l['parentId'] == _distId)
        .toList();
    final stations = locs
        .where((l) => l['type'] == 'station' && l['parentId'] == _upaId)
        .toList();
    final areas = locs
        .where((l) => l['type'] == 'area' && l['parentId'] == _stationId)
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
            _charge = 0;
          });
        }),
        const SizedBox(height: 12),
        _dropdown('Select Upazila', upazilas, _upaId, (v) {
          final u = upazilas.firstWhere((e) => e['id'] == v);
          setState(() {
            _upaId = v;
            _upaName = u['name'];
            _stationId = null;
            _areaId = null;
            _charge = 0;
          });
        }, enabled: _distId != null),
        const SizedBox(height: 12),
        _dropdown('Select Station / Bazar', stations, _stationId, (v) {
          setState(() {
            _stationId = v;
            _areaId = null;
            _charge = 0;
          });
        }, enabled: _upaId != null),
        const SizedBox(height: 12),
        _dropdown('Select Specific Area', areas, _areaId, (v) {
          final a = areas.firstWhere((e) => e['id'] == v);
          setState(() {
            _areaId = v;
            _areaName = a['name'];
            _charge = (a['baseCharge'] ?? 0).toDouble();
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
            onPressed: _areaId == null ? null : _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryColor,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: Text('CONFIRM ADDRESS (৳${_charge.toInt()})',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)))
      ])),
    );
  }

  void _saveAddress() async {
    final locs = ref.read(locationsProvider).value ?? [];
    _distName ??= locs.firstWhere((l) => l['id'] == _distId,
        orElse: () => {'name': ''})['name'];
    _upaName ??= locs.firstWhere((l) => l['id'] == _upaId,
        orElse: () => {'name': ''})['name'];

    final current = List<Map<String, dynamic>>.from(
        ref.read(currentUserDataProvider).value?['addresses'] ?? []);
    final String targetUid =
        widget.userData?['uid'] ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    if (targetUid.isNotEmpty) {
      await ref.read(firestoreServiceProvider).updateProfile(targetUid, {
        'addresses': [
          ...current,
          {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'name': _nameTag,
            'district': _distName,
            'upazila': _upaName,
            'area': _areaName,
            'details': _details.text.trim(),
            'charge': _charge,
          }
        ]
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
