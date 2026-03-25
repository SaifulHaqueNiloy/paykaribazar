import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../di/providers.dart';
import '../../../utils/styles.dart';
import '../../../utils/app_strings.dart';

class EmergencyTab extends ConsumerStatefulWidget {
  const EmergencyTab({super.key});
  @override
  ConsumerState<EmergencyTab> createState() => _EmergencyTabState();
}

class _EmergencyTabState extends ConsumerState<EmergencyTab>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  String _t(String k) =>
      AppStrings.get(k, ref.watch(languageProvider).languageCode);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(children: [
      TabBar(
          controller: _tabCtrl,
          labelColor:
              isDark ? AppStyles.darkPrimaryColor : AppStyles.primaryColor,
          indicatorColor:
              isDark ? AppStyles.darkPrimaryColor : AppStyles.primaryColor,
          tabs: [
            Tab(text: _t('bloodDonors').toUpperCase()),
            Tab(text: _t('doctors').toUpperCase()),
            Tab(text: _t('helplines').toUpperCase()),
          ]),
      Expanded(
          child: TabBarView(controller: _tabCtrl, children: [
        _buildDonorList(isDark),
        _buildDoctorList(isDark),
        _buildHelplineList(isDark),
      ])),
    ]);
  }

  Widget _buildDonorList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection(HubPaths.donors).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final donors = snapshot.data!.docs;
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.redAccent,
              onPressed: () => _showDonorDialog(null),
              child: const Icon(Icons.add, color: Colors.white)),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: donors.length,
            itemBuilder: (c, i) => _donorCard(donors[i], isDark),
          ),
        );
      },
    );
  }

  Widget _donorCard(DocumentSnapshot doc, bool isDark) {
    final data = doc.data() as Map<String, dynamic>;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: Colors.red.withOpacity(0.1),
            child: Text(data['group'] ?? '?',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold))),
        title: Text(data['name'] ?? 'Anonymous',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(data['location'] ?? 'Unknown Location'),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
              onPressed: () => _showDonorDialog(doc)),
          IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.redAccent),
              onPressed: () => doc.reference.delete()),
        ]),
      ),
    );
  }

  void _showDonorDialog(DocumentSnapshot? doc) {
    final name = TextEditingController(text: doc != null ? doc['name'] : '');
    final phone = TextEditingController(text: doc != null ? doc['phone'] : '');
    final location =
        TextEditingController(text: doc != null ? doc['location'] : '');
    String group = doc != null ? doc['group'] : 'O+';

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(doc == null ? 'Add Donor' : 'Edit Donor'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name')),
          TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Phone')),
          TextField(
              controller: location,
              decoration: const InputDecoration(labelText: 'Location')),
          DropdownButton<String>(
            value: group,
            items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => group = v!),
          )
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('CANCEL')),
          ElevatedButton(
              onPressed: () async {
                final data = {
                  'name': name.text.trim(),
                  'phone': phone.text.trim(),
                  'location': location.text.trim(),
                  'group': group,
                  'updatedAt': FieldValue.serverTimestamp(),
                };
                if (doc == null) {
                  await FirebaseFirestore.instance
                      .collection(HubPaths.donors)
                      .add(data);
                } else {
                  await doc.reference.update(data);
                }
                if (mounted) Navigator.pop(c);
              },
              child: const Text('SAVE')),
        ],
      ),
    );
  }

  Widget _buildDoctorList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection(HubPaths.doctors).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final doctors = snapshot.data!.docs;
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.indigo,
              onPressed: () => _showDoctorDialog(null),
              child: const Icon(Icons.add, color: Colors.white)),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (c, i) => _doctorCard(doctors[i], isDark),
          ),
        );
      },
    );
  }

  Widget _doctorCard(DocumentSnapshot doc, bool isDark) {
    final data = doc.data() as Map<String, dynamic>;
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(data['name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(data['specialty'] ?? ''),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
              onPressed: () => _showDoctorDialog(doc)),
          IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.redAccent),
              onPressed: () => doc.reference.delete()),
        ]),
      ),
    );
  }

  void _showDoctorDialog(DocumentSnapshot? doc) {
    final name = TextEditingController(text: doc != null ? doc['name'] : '');
    final spec =
        TextEditingController(text: doc != null ? doc['specialty'] : '');
    final phone = TextEditingController(text: doc != null ? doc['phone'] : '');

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(doc == null ? 'Add Doctor' : 'Edit Doctor'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name')),
          TextField(
              controller: spec,
              decoration: const InputDecoration(labelText: 'Specialty')),
          TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Phone')),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('CANCEL')),
          ElevatedButton(
              onPressed: () async {
                final data = {
                  'name': name.text.trim(),
                  'specialty': spec.text.trim(),
                  'phone': phone.text.trim(),
                  'updatedAt': FieldValue.serverTimestamp(),
                };
                if (doc == null) {
                  await FirebaseFirestore.instance
                      .collection(HubPaths.doctors)
                      .add(data);
                } else {
                  await doc.reference.update(data);
                }
                if (mounted) Navigator.pop(c);
              },
              child: const Text('SAVE')),
        ],
      ),
    );
  }

  Widget _buildHelplineList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection(HubPaths.helplines).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final helplines = snapshot.data!.docs;
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.orange,
              onPressed: () => _showHelplineDialog(null),
              child: const Icon(Icons.add, color: Colors.white)),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: helplines.length,
            itemBuilder: (c, i) => _helplineCard(helplines[i], isDark),
          ),
        );
      },
    );
  }

  Widget _helplineCard(DocumentSnapshot doc, bool isDark) {
    final data = doc.data() as Map<String, dynamic>;
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.phone)),
        title: Text(data['name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(data['phone'] ?? ''),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
              onPressed: () => _showHelplineDialog(doc)),
          IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.redAccent),
              onPressed: () => doc.reference.delete()),
        ]),
      ),
    );
  }

  void _showHelplineDialog(DocumentSnapshot? doc) {
    final name = TextEditingController(text: doc != null ? doc['name'] : '');
    final phone = TextEditingController(text: doc != null ? doc['phone'] : '');

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(doc == null ? 'Add Helpline' : 'Edit Helpline'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name')),
          TextField(
              controller: phone,
              decoration: const InputDecoration(labelText: 'Phone')),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('CANCEL')),
          ElevatedButton(
              onPressed: () async {
                final data = {
                  'name': name.text.trim(),
                  'phone': phone.text.trim(),
                  'updatedAt': FieldValue.serverTimestamp(),
                };
                if (doc == null) {
                  await FirebaseFirestore.instance
                      .collection(HubPaths.helplines)
                      .add(data);
                } else {
                  await doc.reference.update(data);
                }
                if (mounted) Navigator.pop(c);
              },
              child: const Text('SAVE')),
        ],
      ),
    );
  }
}
