import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/styles.dart';
import '../../../services/database_seeder.dart';

class DeliveryZoneTab extends StatefulWidget {
  const DeliveryZoneTab({super.key});
  @override
  State<DeliveryZoneTab> createState() => _DeliveryZoneTabState();
}

class _DeliveryZoneTabState extends State<DeliveryZoneTab> {
  final _nameController = TextEditingController();
  final _chargeController = TextEditingController(text: '0');
  String _selectedType = 'district'; 
  String? _parentId;

  /// DNA ENFORCED: রাইট অপারেশন কমানোর জন্য ব্যাচ সেভ লজিক ব্যবহার করা যেতে পারে ভবিষ্যতে।
  Future<void> _addLocation() async {
    if (_nameController.text.isEmpty) return;

    final double charge = double.tryParse(_chargeController.text) ?? 0.0;

    await FirebaseFirestore.instance.collection('locations').add({
      'name': _nameController.text.trim(),
      'type': _selectedType,
      'parentId': _parentId,
      'deliveryCharge': charge, 
      'isVisible': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    _nameController.clear();
    _chargeController.text = '0';
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location added successfully')));
  }

  // --- UI PART ---
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('DELIVERY HUB CONFIG', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
              _buildSeedButton(),
            ],
          ),
          const SizedBox(height: 12),
          _buildEntryForm(isDark),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          Expanded(child: _buildLocationList(isDark)),
        ],
      ),
    );
  }

  Widget _buildSeedButton() => ElevatedButton.icon(
    onPressed: () => DatabaseSeeder.seedLocations(),
    icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
    label: const Text('AUTO SEED', style: TextStyle(fontSize: 10)),
    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
  );

  Widget _buildEntryForm(bool isDark) {
    String? parentType;
    if (_selectedType == 'district') parentType = 'division';
    if (_selectedType == 'upazila') parentType = 'district';
    if (_selectedType == 'area') parentType = 'upazila';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppStyles.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  items: ['division', 'district', 'upazila', 'area']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 11)))).toList(),
                  onChanged: (v) => setState(() { _selectedType = v!; _parentId = null; }),
                  decoration: AppStyles.inputDecoration('Type', isDark),
                ),
              ),
              const SizedBox(width: 8),
              if (parentType != null)
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('locations').where('type', isEqualTo: parentType).snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const LinearProgressIndicator();
                      final List<DropdownMenuItem<String>> items = snap.data!.docs.map((p) => DropdownMenuItem(value: p.id, child: Text((p.data() as Map)['name'], style: const TextStyle(fontSize: 10)))).toList();
                      return DropdownButtonFormField<String>(
                        initialValue: items.any((i) => i.value == _parentId) ? _parentId : null,
                        items: items,
                        onChanged: (v) => setState(() => _parentId = v),
                        decoration: AppStyles.inputDecoration('Parent', isDark),
                      );
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(controller: _nameController, decoration: AppStyles.inputDecoration('Name (e.g. Dhaka)', isDark)),
          if (_selectedType == 'area') ...[
            const SizedBox(height: 12),
            TextField(controller: _chargeController, keyboardType: TextInputType.number, decoration: AppStyles.inputDecoration('Delivery Charge ৳', isDark)),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _addLocation,
            style: ElevatedButton.styleFrom(backgroundColor: AppStyles.primaryColor, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('SAVE LOCATION', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('locations').orderBy('updatedAt', descending: true).limit(20).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final nodes = snapshot.data!.docs;
        return ListView.builder(
          itemCount: nodes.length,
          itemBuilder: (context, index) {
            final data = nodes[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${data['type'].toString().toUpperCase()} ${data['deliveryCharge'] > 0 ? '| ৳${data['deliveryCharge']}' : ''}"),
                trailing: IconButton(icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 18), onPressed: () => nodes[index].reference.delete()),
              ),
            );
          },
        );
      },
    );
  }
}
