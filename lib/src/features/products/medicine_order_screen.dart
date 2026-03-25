import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/providers.dart';
import '../../utils/styles.dart';

class MedicineOrderScreen extends ConsumerStatefulWidget {
  const MedicineOrderScreen({super.key});

  @override
  ConsumerState<MedicineOrderScreen> createState() =>
      _MedicineOrderScreenState();
}

class _MedicineOrderScreenState extends ConsumerState<MedicineOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLocation;
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicineListController = TextEditingController();
  bool _isEmergency = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _medicineListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(locationsProvider);
    final userAsync = ref.watch(actualUserDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppStyles.darkBackgroundColor : AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text('Emergency Medicine',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: locationsAsync.when(
        data: (locations) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildLocationDropdown(locations, isDark),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: AppStyles.inputDecoration('Phone Number', isDark,
                      prefix: const Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: AppStyles.inputDecoration('Full Address', isDark,
                      prefix: const Icon(Icons.location_on)),
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _medicineListController,
                  decoration: AppStyles.inputDecoration(
                      'Medicine List / Symptoms', isDark,
                      hint: 'e.g. Napa 500mg (10 pcs)'),
                  maxLines: 4,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildEmergencyToggle(isDark),
                const SizedBox(height: 32),
                userAsync.when(
                  data: (user) => ElevatedButton(
                    onPressed: () => _submitOrder(user?['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('SUBMIT EMERGENCY REQUEST',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading user data: $e'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.medical_services_outlined,
                color: Colors.redAccent, size: 32),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emergency Medicine Order',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.redAccent)),
                  Text('Available for verified locations only.',
                      style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildLocationDropdown(
          List<Map<String, dynamic>> locations, bool isDark) =>
      DropdownButtonFormField<String>(
        initialValue: _selectedLocation,
        decoration: AppStyles.inputDecoration('Select Area', isDark,
            prefix: const Icon(Icons.map_outlined)),
        items: locations
            .map((l) => DropdownMenuItem(
                value: l['id'].toString(), child: Text(l['name'] ?? 'Unknown')))
            .toList(),
        onChanged: (val) => setState(() => _selectedLocation = val),
        validator: (v) => v == null ? 'Please select area' : null,
      );

  Widget _buildEmergencyToggle(bool isDark) => SwitchListTile(
        title: const Text('Instant Emergency Delivery',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Additional charges may apply for speed delivery'),
        value: _isEmergency,
        activeThumbColor: Colors.redAccent,
        onChanged: (val) => setState(() => _isEmergency = val),
      );

  void _submitOrder(String? userId) {
    if (_formKey.currentState!.validate() && userId != null) {
      // Implementation for order submission
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Processing emergency request...')));
    }
  }
}

