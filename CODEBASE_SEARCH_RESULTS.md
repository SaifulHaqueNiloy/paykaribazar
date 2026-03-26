# Paykari Bazar - Home & Emergency Screen Implementation Analysis

## 1. FILE PATHS

### Home Screen Files
| Component | File Path |
|-----------|-----------|
| **Main Home Screen** | `lib/src/features/home/home_screen.dart` |
| **Home Widgets** | `lib/src/features/home/widgets/home_widgets.dart` |
| **Home App Bar** | `lib/src/features/home/widgets/home_app_bar.dart` |
| **Notice Slider** | `lib/src/features/home/widgets/notice_slider.dart` |
| **Category Chips** | `lib/src/features/home/widgets/category_chips.dart` |
| **Loyalty Card** | `lib/src/features/home/widgets/loyalty_status_card.dart` |
| **Greeting Widget** | `lib/src/features/home/widgets/greeting_widget.dart` |
| **Flash Sale Timer** | `lib/src/features/home/widgets/flash_sale_timer.dart` |
| **Qibla Indicator** | `lib/src/features/home/widgets/qibla_indicator.dart` |

### Emergency Screen Files
| Component | File Path |
|-----------|-----------|
| **Main Emergency Screen** | `lib/src/features/orders/emergency_details_screen.dart` |
| **Emergency Tab (Admin)** | `lib/src/features/admin/widgets/emergency_tab.dart` |

### Supporting Services & Constants
| Component | File Path |
|-----------|-----------|
| **Notice Service** | `lib/src/services/notice_service.dart` |
| **HubPaths Constants** | `lib/src/core/constants/paths.dart` |
| **Providers (Riverpod)** | `lib/src/di/providers.dart` |

---

## 2. HOME SCREEN STRUCTURE & BANNERS

### Home Screen Implementation
**File:** [lib/src/features/home/home_screen.dart](lib/src/features/home/home_screen.dart)

```dart
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scroll = ScrollController();
  final ValueNotifier<bool> _showStickyHeader = ValueNotifier<bool>(false);
  Timer? _rewardTimer;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _checkAndShowRewards();
  }

  void _onScroll() {
    if (_scroll.hasClients) {
      if (_scroll.offset > 200 && !_showStickyHeader.value) {
        _showStickyHeader.value = true;
      } else if (_scroll.offset <= 200 && _showStickyHeader.value) {
        _showStickyHeader.value = false;
      }
    }
  }
```

### Banner Display Implementation
**File:** [lib/src/features/home/widgets/home_widgets.dart](lib/src/features/home/widgets/home_widgets.dart#L1-L100)

```dart
class BannerSlider extends StatefulWidget {
  final List<String> banners;
  const BannerSlider({super.key, required this.banners});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 160.0,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.92,
            aspectRatio: 2.0,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: widget.banners.map((url) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[900],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Carousel Indicators (Dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.banners.asMap().entries.map((entry) {
            return Container(
              width: _current == entry.key ? 12.0 : 6.0,
              height: 6.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: AppStyles.primaryColor.withValues(
                  alpha: _current == entry.key ? 1.0 : 0.2,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
```

### Banner Data Source (Riverpod Provider)
**File:** [lib/src/di/providers.dart](lib/src/di/providers.dart#L242)

```dart
final promoProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('promos')
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList());
});
```

### How Banners Are Used in Home Screen
```dart
promoAsync.when(
  data: (promo) {
    if (promo.isEmpty) return const SizedBox.shrink();
    final firstPromo = promo.first;
    final banners = firstPromo['banners'];
    if (banners == null || banners is! List || banners.isEmpty) 
      return const SizedBox.shrink();
    return BannerSlider(banners: List<String>.from(banners));
  },
  loading: () => const SizedBox(
    height: 150,
    child: Center(child: CircularProgressIndicator()),
  ),
  error: (e, _) => const SizedBox.shrink(),
),
```

---

## 3. NOTICE SLIDER IMPLEMENTATION

### Notice Widget
**File:** [lib/src/features/home/widgets/notice_slider.dart](lib/src/features/home/widgets/notice_slider.dart)

```dart
class NoticeSlider extends ConsumerWidget {
  const NoticeSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notices')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) 
          return const SizedBox();

        final notices = snapshot.data!.docs;
        return Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 5),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 45.0,
              autoPlay: true,
              viewportFraction: 1.0,
              scrollDirection: Axis.vertical,
            ),
            items: notices.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final String text = data['text'] ?? '';
              
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.campaign_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            text,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
```

### Notice Service
**File:** [lib/src/services/notice_service.dart](lib/src/services/notice_service.dart)

```dart
class NoticeModel {
  final String id;
  final String title;
  final String message;
  final String? imageUrl;
  final DateTime createdAt;

  NoticeModel({
    required this.id,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.createdAt,
  });

  factory NoticeModel.fromMap(Map<String, dynamic> map, String id) {
    return NoticeModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class NoticeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NoticeModel>> getNotices() {
    return _firestore
        .collection('notices')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NoticeModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addNotice(String title, String message, [String? imageUrl]) async {
    await _firestore.collection('notices').add({
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNotice(String id) async {
    await _firestore.collection('notices').doc(id).delete();
  }
}
```

---

## 4. EMERGENCY SCREEN IMPLEMENTATION

### Emergency Details Screen
**File:** [lib/src/features/orders/emergency_details_screen.dart](lib/src/features/orders/emergency_details_screen.dart#L1-L100)

```dart
class EmergencyDetailsScreen extends ConsumerStatefulWidget {
  final String? category;
  const EmergencyDetailsScreen({super.key, this.category});

  @override
  ConsumerState<EmergencyDetailsScreen> createState() =>
      _EmergencyDetailsScreenState();
}

class _EmergencyDetailsScreenState
    extends ConsumerState<EmergencyDetailsScreen> {
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _bagsController = TextEditingController();

  String _selectedService = 'pharmacy';  // ⭐ STATE: Tracks selected button
  String? _selectedBloodGroup;
  String? _selectedPatientType;
  File? _prescriptionImage;

  String? _selectedDistrict, _selectedUpazila;
  bool _isSubmitting = false;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];
  final List<String> _patientTypes = [
    'child', 'youth', 'elderly', 'pregnantMother', 'seriouslyIll', 'criticallyInjured'
  ];
```

### Emergency Screen Header with Button Switching
**File:** [lib/src/features/orders/emergency_details_screen.dart](lib/src/features/orders/emergency_details_screen.dart#L110-L160)

```dart
  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFF4D4D),  // Emergency Red
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      child: Column(
        children: [
          Text(
            _t('emergencyService'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 25),
          // ⭐ THREE BUTTON ROW - MEDICINE / BLOOD / HELPLINE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _serviceHeaderBtn(
                Icons.medical_services, 
                _t('pharmacy'), 
                'pharmacy',
              ),
              _serviceHeaderBtn(
                Icons.bloodtype, 
                _t('bloodAid'), 
                'blood',
              ),
              _serviceHeaderBtn(
                Icons.phone_in_talk, 
                _t('helpline'), 
                'helpline',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ⭐ BUTTON STATE MANAGEMENT LOGIC
  Widget _serviceHeaderBtn(IconData icon, String label, String service) {
    final bool isSelected = _selectedService == service;
    return GestureDetector(
      onTap: () => setState(() => _selectedService = service),  // ⭐ STATE UPDATE
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: 26,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          // ⭐ SELECTED INDICATOR - White underline
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 6),
              height: 3,
              width: 15,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            )
        ],
      ),
    );
  }
```

### STATE MANAGEMENT APPROACH: SetState Pattern

```dart
// The state variable holds the current service selection
String _selectedService = 'pharmacy';  // Default value

// When button is tapped, setState rebuilds with new value
GestureDetector(
  onTap: () => setState(() => _selectedService = service),
  child: Column(
    children: [
      Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white70,
        size: 26,
      ),
      // Button UI updates based on _selectedService value
    ],
  ),
)

// In build() method, conditional rendering shows different forms
if (_selectedService == 'pharmacy')
  _buildDetailedMedicineForm(isDark),
if (_selectedService == 'blood')
  _buildDetailedBloodForm(isDark),
if (_selectedService == 'helpline')
  _buildHelplineSection(isDark),
```

### Conditional Form Rendering Based on Button State
**File:** [lib/src/features/orders/emergency_details_screen.dart](lib/src/features/orders/emergency_details_screen.dart#L200-L260)

```dart
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F2F5),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(isDark),
                const SizedBox(height: 16),
                // ⭐ CONDITIONAL RENDERING BASED ON _selectedService STATE
                if (_selectedService == 'pharmacy')
                  _buildDetailedMedicineForm(isDark),
                if (_selectedService == 'blood')
                  _buildDetailedBloodForm(isDark),
                if (_selectedService == 'helpline')
                  _buildHelplineSection(isDark),
                const SizedBox(height: 8),
                _buildDoctorsListSection(isDark),
                const SizedBox(height: 100),
              ],
            ),
          ),
```

### Medicine Form Implementation
**File:** [lib/src/features/orders/emergency_details_screen.dart](lib/src/features/orders/emergency_details_screen.dart#L280-L330)

```dart
  Widget _buildDetailedMedicineForm(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('medicineDetails'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _medicineController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: _t('medicineNamesHint'),
              hintStyle: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 12),
          _buildImagePicker(isDark),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : () => _submitOrder('medicine'),
              icon: const Icon(Icons.shopping_cart_rounded, size: 16),
              label: Text(
                _t('reorderBtn').toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6200EE),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
```

### Blood Request Form Implementation
**File:** [lib/src/features/orders/emergency_details_screen.dart](lib/src/features/orders/emergency_details_screen.dart#L333-L390)

```dart
  Widget _buildDetailedBloodForm(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('bloodRequest'),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _formDropdown(
                  _t('bloodGroup'),
                  _selectedBloodGroup,
                  _bloodGroups,
                  (v) => setState(() => _selectedBloodGroup = v),
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _bagsController,
                  keyboardType: TextInputType.number,
                  decoration: AppStyles.inputDecoration(
                    _t('bagsNeeded'),
                    isDark,
                  ).copyWith(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _formDropdown(
            _t('patientType'),
            _selectedPatientType,
            _patientTypes,
            (v) => setState(() => _selectedPatientType = v),
            isDark,
            isTranslatable: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _hospitalController,
            decoration: AppStyles.inputDecoration(_t('hospitalArea'), isDark),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : () => _submitOrder('blood'),
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text(
                _t('bloodRequest').toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
```

### Submit Order Logic
**File:** [lib/src/features/orders/emergency_details_screen.dart](lib/src/features/orders/emergency_details_screen.dart#L520-L600)

```dart
  Future<void> _submitOrder(String type) async {
    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(actualUserDataProvider).value;
      final Map<String, dynamic> orderData = {
        'userId': user?['uid'],
        'userName': user?['name'],
        'phone': user?['phone'],
        'districtId': _selectedDistrict,
        'upazilaId': _selectedUpazila,
        'orderType': type,  // 'medicine', 'blood', or 'helpline'
        'isEmergency': true,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (type == 'medicine') {
        if (_medicineController.text.isEmpty && _prescriptionImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_t('fillRequiredFields')),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        orderData['details'] = _medicineController.text;
      } else if (type == 'blood') {
        if (_selectedBloodGroup == null || 
            _hospitalController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_t('fillRequiredFields')),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        orderData['bloodGroup'] = _selectedBloodGroup;
        orderData['bagsNeeded'] = _bagsController.text;
        orderData['hospitalArea'] = _hospitalController.text;
        orderData['patientType'] = _selectedPatientType;
      }

      await FirebaseFirestore.instance
          .collection(HubPaths.orders)
          .add(orderData);

      // Clear forms after successful submission
      _medicineController.clear();
      _hospitalController.clear();
      _bagsController.clear();
      setState(() {
        _prescriptionImage = null;
        _selectedBloodGroup = null;
        _selectedPatientType = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              type == 'medicine'
                  ? _t('orderPlacedSuccess')
                  : 'রক্তের আবেদন পাঠানো হয়েছে',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
```

---

## 5. ADMIN EMERGENCY TAB

### Emergency Tab for Admin Dashboard
**File:** [lib/src/features/admin/widgets/emergency_tab.dart](lib/src/features/admin/widgets/emergency_tab.dart)

```dart
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        // ⭐ TAB BAR with 3 tabs
        TabBar(
          controller: _tabCtrl,
          labelColor: isDark 
            ? AppStyles.darkPrimaryColor 
            : AppStyles.primaryColor,
          indicatorColor: isDark 
            ? AppStyles.darkPrimaryColor 
            : AppStyles.primaryColor,
          tabs: [
            Tab(text: _t('bloodDonors').toUpperCase()),
            Tab(text: _t('doctors').toUpperCase()),
            Tab(text: _t('helplines').toUpperCase()),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildDonorList(isDark),
              _buildDoctorList(isDark),
              _buildHelplineList(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonorList(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(HubPaths.donors)
          .snapshots(),
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
            child: const Icon(Icons.add, color: Colors.white),
          ),
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
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          child: Text(
            data['group'] ?? '?',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          data['name'] ?? 'Anonymous',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(data['location'] ?? 'Unknown Location'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
              onPressed: () => _showDonorDialog(doc),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
              onPressed: () => doc.reference.delete(),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 6. STATE MANAGEMENT SUMMARY

### Current State Management Approach

| Feature | Pattern | Details |
|---------|---------|---------|
| **Emergency Screen Services** | `ConsumerStatefulWidget` + `setState()` | Local widget state using `_selectedService` variable |
| **Button Switching** | Simple setState rebuid | `GestureDetector` → `setState(() => _selectedService = service)` |
| **Form Fields** | TextEditingController | Blood group, bags, hospital area stored in `_selectedBloodGroup`, `_bagsController`, etc. |
| **Admin Emergency Tab** | `ConsumerStatefulWidget` + `TabController` | Manages 3 tabs (Blood Donors, Doctors, Helplines) |
| **Home Banners** | Riverpod `StreamProvider` | `promoProvider` from Firestore 'promos' collection |
| **Notices** | Firestore StreamBuilder | Direct Firestore query in `NoticeSlider` widget |

### Button State Flow Diagram

```
┌─────────────────────────────────────────────┐
│ Emergency Screen (_selectedService = 'pharmacy')
└─────────────────────────────────────────────┘
                    ↓
        ┌───────────────────────────┐
        │  _buildHeader()           │
        │  3 Buttons in Row         │
        └───────────────────────────┘
        ↓              ↓              ↓
    Medicine        Blood          Helpline
    Button          Button         Button
        ↓              ↓              ↓
  GestureDetector (onTap: setState(() => _selectedService = 'pharmacy'))
        ↓
    setState() triggers rebuild
        ↓
    if (_selectedService == 'pharmacy')
      _buildDetailedMedicineForm(isDark)
    if (_selectedService == 'blood')
      _buildDetailedBloodForm(isDark)
    if (_selectedService == 'helpline')
      _buildHelplineSection(isDark)
        ↓
    Only matching form is displayed
```

---

## 7. DATABASE PATHS (HubPaths)

**File:** [lib/src/core/constants/paths.dart](lib/src/core/constants/paths.dart)

```dart
class HubPaths {
  static const String root = 'hub';
  static const String users = 'users';
  static const String orders = 'orders';
  static const String products = '$root/data/products';
  static const String categories = '$root/data/categories';
  static const String stores = '$root/data/stores';
  static const String locations = '$root/data/locations';
  static const String notifications = 'notifications';
  static const String secretsDoc = 'settings/secrets';
  static const String configDoc = 'settings/app_config';
  static const String loyaltyDoc = 'settings/loyalty';
  static const String localizationDoc = 'settings/localization';
  static const String staffCommissions = 'staff_commissions';
  
  // ⭐ EMERGENCY PATHS
  static const String donors = '$root/emergency/donors';        // hub/emergency/donors
  static const String doctors = '$root/emergency/doctors';      // hub/emergency/doctors
  static const String helplines = '$root/emergency/helplines';  // hub/emergency/helplines
  
  static const String privateChats = 'private_chats';
  static const String coupons = 'settings/coupons';
  static const String deliveryZones = 'settings/delivery_zones';
}
```

---

## 8. KEY OBSERVATIONS & ISSUES

### ✅ Strengths
1. **Clean Button State Management** - Uses simple `setState()` pattern for emergency service selection
2. **Conditional Rendering** - Different forms appear based on `_selectedService` value
3. **Firestore Integration** - Direct integration with Firebase for orders, doctors, blood donors
4. **User Feedback** - SnackBars show success/error messages after form submission
5. **Image Handling** - Prescription image picker support for medicine orders

### ⚠️ Potential Issues & TODOs

1. **No Validation Before Submit**
   - Medicine form checks if empty, but could have more robust validation
   - Blood form only checks blood group and hospital, missing validation for bags count

2. **Hard-coded Patient Types**
   ```dart
   final List<String> _patientTypes = [
     'child', 'youth', 'elderly', 'pregnantMother', 'seriouslyIll', 'criticallyInjured'
   ];
   ```
   - Should be fetched from `AppStrings` for i18n support

3. **Prescription Image Not Uploaded**
   - Image is selected but never uploaded to Firebase Storage
   - Only filename is stored, not actual file data

4. **No Rate Limiting**
   - Users can spam multiple orders without rate limiting
   - Consider adding cooldown or submission limits

5. **Helpline Section Not Implemented**
   ```dart
   Widget _buildHelplineSection(bool isDark) {
     return Container(
       margin: const EdgeInsets.symmetric(horizontal: 16),
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: isDark ? const Color(0xFF1E293B) : Colors.white,
         borderRadius: BorderRadius.circular(15),
       ),
       child: const Center(
         child: Text('Emergency Helplines are listed below')
       ),
     );
   }
   ```
   - Only shows placeholder text, no actual helplines displayed

6. **State Not Persisted**
   - Form data lost if user navigates away
   - Could use Riverpod StateNotifier for better state persistence

7. **No Offline Support**
   - No caching of submitted orders
   - Orders only work with active internet connection

### 🔧 Recommended Improvements
1. Implement proper validation for all form fields
2. Add image upload to Firebase Storage
3. Implement helpline listing with calling integration
4. Add order history/tracking after submission
5. Use Riverpod StateNotifier instead of setState for better state management
6. Add rate limiting for emergency requests
7. Implement offline caching with Hive

---

## 9. QUICK REFERENCE

### Home Screen Components Order
```
1. AppBar (with notifications icon, language toggle, dark mode)
2. NoticeSlider (vertical carousel of notices)
3. GreetingWidget (personalized greeting)
4. LoyaltyStatusCard (points display)
5. CategoryChips (product categories)
6. FlashSaleTimer (countdown timer for flash sales)
7. StaticSearchBar (search functionality)
8. QiblaIndicator (prayer direction)
9. BannerSlider (horizontal carousel of promos)
10. Product Sections:
    - Flash Deals
    - Combo Packs
    - Top Selling Products
    - Price Dropped
    - New Arrivals
    - Just For You
11. FloatingCartBar (sticky cart at bottom)
```

### Emergency Service Flow
```
User clicks Emergency (/emergency route)
  ↓
EmergencyDetailsScreen loads with default 'pharmacy'
  ↓
User clicks Medicine/Blood/Helpline button
  ↓
setState(() => _selectedService = 'medicine'|'blood'|'helpline')
  ↓
Widget rebuilds with conditional rendering
  ↓
User fills appropriate form
  ↓
User clicks submit button
  ↓
Validation checks
  ↓
Order added to Firestore 'orders' collection
  ↓
Success SnackBar shown
  ↓
Forms cleared, ready for new submission
```

---

## 10. FILE STRUCTURE SUMMARY

```
lib/src/
├── features/
│   ├── home/
│   │   ├── home_screen.dart ⭐
│   │   └── widgets/
│   │       ├── home_app_bar.dart
│   │       ├── home_widgets.dart ⭐ (BannerSlider)
│   │       ├── notice_slider.dart ⭐
│   │       ├── category_chips.dart
│   │       ├── greeting_widget.dart
│   │       ├── loyalty_status_card.dart
│   │       ├── flash_sale_timer.dart
│   │       └── qibla_indicator.dart
│   ├── orders/
│   │   ├── emergency_details_screen.dart ⭐
│   │   ├── order_details_screen.dart
│   │   ├── order_tracking_screen.dart
│   │   └── orders_screen.dart
│   └── admin/
│       └── widgets/
│           └── emergency_tab.dart ⭐
├── core/
│   ├── constants/
│   │   └── paths.dart (HubPaths)
│   └── services/
├── services/
│   └── notice_service.dart ⭐
└── di/
    └── providers.dart ⭐ (promoProvider)
```

---

**Generated:** March 26, 2026
**Status:** Complete analysis with all code snippets and state management documentation
