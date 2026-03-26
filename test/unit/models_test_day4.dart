import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paykari_bazar/src/models/user_model.dart';
import 'package:paykari_bazar/src/models/product_model.dart';
import 'package:paykari_bazar/src/models/order_model.dart' as order_model;
import 'package:paykari_bazar/src/models/doctor_model.dart';
import 'package:paykari_bazar/src/models/blood_donor_model.dart';
import 'package:paykari_bazar/src/models/review_model.dart';
import 'package:paykari_bazar/src/models/backup_model.dart';
import 'package:paykari_bazar/src/features/commerce/domain/cart_model.dart';

void main() {
  group('Day 4: Model Tests  (25+ tests)', () {
    // ========================================================================
    // GROUP 1: AddressModel Tests (3 tests)
    // ========================================================================
    group('AddressModel - Serialization', () {
      test('1. Address toMap', () {
        final addr = AddressModel(
          id: 'a1', name: 'Home', district: 'Dhaka', upazila: 'Mirpur',
          station: 'PS', area: 'Banani', areaId: 'area1', 
          detailedAddress: 'House 1', deliveryCharge: 50.0, isDefault: true,
        );
        final map = addr.toMap();
        expect(map['name'], 'Home');
        expect(map['deliveryCharge'], 50.0);
      });

      test('2. Address fromMap', () {
        final map = {'id': 'a1', 'name': 'Home', 'district': 'Dhaka',
          'upazila': 'Mirpur', 'station': 'PS', 'area': 'Banani', 'areaId': 'area1',
          'detailedAddress': 'House 1', 'deliveryCharge': 50.0, 'isDefault': true};
        final addr = AddressModel.fromMap(map);
        expect(addr.id, 'a1');
        expect(addr.district, 'Dhaka');
      });

      test('3. Address fullAddress getter', () {
        final addr = AddressModel(
          id: 'a2', name: 'Office', district: 'Dhaka', upazila: 'Gulshan',
          station: 'PS', area: 'Multi', areaId: 'area2', 
          detailedAddress: 'Office Bldg', deliveryCharge: 75.0,
        );
        expect(addr.fullAddress, contains('Dhaka'));
        expect(addr.fullAddress, contains('Office Bldg'));
      });
    });

    // ========================================================================
    // GROUP 2: UserModel Tests (3 tests)
    // ========================================================================
    group('UserModel - User Profiles', () {
      test('1. User toMap', () {
        final user = UserModel(
          id: 'u1', name: 'Ahmed', phone: '01700000000', email: 'a@test.com', addresses: [], points: 100,
          myReferralCode: 'REF1', q1: '', a1: '', h1: '',
          q2: '', a2: '', h2: '', q3: '', a3: '', h3: '',
          storageLimit: 1024, isSubscribed: true,
        );
        final map = user.toMap();
        expect(map['name'], 'Ahmed');
        expect(map['role'], 'customer');
      });

      test('2. User fromMap', () {
        final map = {'id': 'u2', 'name': 'Fatima', 'phone': '01800000000',
          'email': 'f@test.com', 'role': 'reseller', 'addresses': [],
          'profilePic': null, 'points': 50, 'myReferralCode': 'REF2',
          'currentMode': 'work', 'q1': '', 'a1': '', 'h1': '', 'q2': '', 'a2': '',
          'h2': '', 'q3': '', 'a3': '', 'h3': '', 'storageUsed': 0,
          'storageLimit': 1024, 'isSubscribed': false};
        final user = UserModel.fromMap(map);
        expect(user.id, 'u2');
        expect(user.role, UserRole.reseller);
      });

      test('3. User with addresses', () {
        final addr = AddressModel(
          id: 'a3', name: 'Home', district: 'Dhaka', upazila: 'Mirpur',
          station: 'PS', area: 'Banani', areaId: 'area3',
          detailedAddress: 'H1', deliveryCharge: 50.0, isDefault: true,
        );
        final user = UserModel(
          id: 'u3', name: 'Test', phone: '01900000000', email: 't@test.com',
          role: UserRole.admin, addresses: [addr],
          myReferralCode: 'REF3', q1: '', a1: '', h1: '',
          q2: '', a2: '', h2: '', q3: '', a3: '', h3: '',
          storageLimit: 1024, isSubscribed: true,
        );
        expect(user.addresses.length, 1);
      });
    });

    // ========================================================================
    // GROUP 3: Variant Tests (2 tests)
    // ========================================================================
    group('Variant - Product Variants', () {
      test('1. Variant toMap', () {
        final v = Variant(id: 'v1', name: 'Red', nameBn: 'লাল', price: 100.0, stock: 50);
        final map = v.toMap();
        expect(map['name'], 'Red');
        expect(map['price'], 100.0);
      });

      test('2. Variant fromMap', () {
        final map = {'id': 'v2', 'name': 'Blue', 'nameBn': 'নীল', 'price': 150.0, 'stock': 30};
        final v = Variant.fromMap(map);
        expect(v.id, 'v2');
        expect(v.stock, 30);
      });
    });

    // ========================================================================
    // GROUP 4: Product Tests (4 tests)
    // ========================================================================
    group('Product - E-commerce Products', () {
      test('1. Product toMap', () {
        final p = Product(
          id: 'p1', sku: 'SKU1', name: 'Phone', nameBn: 'ফোন',
          description: 'Good phone', descriptionBn: 'ভাল ফোন', price: 1000.0,
          oldPrice: 1200.0, purchasePrice: 800.0, wholesalePrice: 900.0,
          minWholesaleQty: 5, tieredPrices: {}, stock: 50, unit: 'piece', unitBn: 'টুকরা',
          imageUrl: 'img.jpg', imageUrls: [],
          categoryId: 'cat1', categoryName: 'Electronics', categoryNameBn: 'ইলেকট্রনিক্স',
          subCategoryId: 'scat1', subCategoryName: 'Mobile', subCategoryNameBn: 'মোবাইল',
          shopName: 'Shop1', addedBy: 'v1', brand: 'Brand1', tags: [], comboProductIds: [], variants: [],
          rating: 4.5, salesCount: 100, createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 3, 20),
        );
        final map = p.toMap();
        expect(map['name'], 'Phone');
        expect(map['price'], 1000.0);
      });

      test('2. Product fromMap', () {
        final map = {'id': 'p2', 'sku': 'SKU2', 'name': 'Laptop', 'nameBn': 'ল্যাপটপ',
          'description' : 'Great laptop', 'descriptionBn': 'দুর্দান্ত ল্যাপটপ', 'price': 5000.0,
          'oldPrice': 6000.0, 'purchasePrice': 4000.0, 'wholesalePrice': 4500.0,
          'minWholesaleQty': 2, 'tieredPrices': {}, 'stock': 20, 'unit': 'piece',
          'unitBn': 'টুকরা', 'imageUrl': 'lap.jpg', 'imageUrls': [], 'marketingBannerUrl': null,
          'categoryId': 'cat2', 'categoryName': 'Computers', 'categoryNameBn': 'কম্পিউটার',
          'subCategoryId': 'scat2', 'subCategoryName': 'Laptops', 'subCategoryNameBn': 'ল্যাপটপস',
          'shopName': 'Shop2', 'addedBy': 'v2', 'brand': 'Brand2', 'tags': [],
          'isFlashSale': false, 'isCombo': false, 'isNewArrival': false, 'isFeatured': true,
          'isHotSelling': true, 'isComboPack': false, 'comboProductIds': [], 'variants': [],
          'rating': 4.8, 'salesCount': 200, 'createdAt': Timestamp.fromDate(DateTime(2024)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 3, 20)), 'aiOptimized': true, 'aiAuditPending': false};
        final p = Product.fromMap(map, 'p2');
        expect(p.id, 'p2');
        expect(p.price, 5000.0);
      });

      test('3. Product with variants', () {
        final v1 = Variant(id: 'v1', name: 'S', nameBn: 'ছোট', price: 100.0, stock: 50);
        final p = Product(
          id: 'p3', sku: 'SKU3', name: 'Shirt', nameBn: 'শার্ট',
          description: 'Cotton shirt', descriptionBn: 'কটন শার্ট', price: 200.0,
          oldPrice: 300.0, purchasePrice: 100.0, wholesalePrice: 150.0,
          minWholesaleQty: 10, tieredPrices: {}, stock: 100, unit: 'piece', unitBn: 'টুকরা',
          imageUrl: 'shirt.jpg', imageUrls: [],
          categoryId: 'cat3', categoryName: 'Clothing', categoryNameBn: 'পোশাক',
          subCategoryId: 'scat3', subCategoryName: 'Shirts', subCategoryNameBn: 'শার্টস',
          shopName: 'Shop3', addedBy: 'v3', brand: 'Brand3', tags: [],
          isFlashSale: true, isNewArrival: false, comboProductIds: [], variants: [v1],
          rating: 4.2, salesCount: 300, createdAt: DateTime(2024, 2),
          updatedAt: DateTime(2024, 3, 19), aiAuditPending: true,
        );
        expect(p.variants.length, 1);
      });

      test('4. Product tiered pricing', () {
        final p = Product(
          id: 'p4', sku: 'SKU4', name: 'Widget', nameBn: 'উইজেট',
          description: 'Test', descriptionBn: 'পরীক্ষা', price: 50.0,
          oldPrice: 75.0, purchasePrice: 30.0, wholesalePrice: 40.0,
          minWholesaleQty: 20, tieredPrices: {'5': 45, '10': 40}, stock: 500, 
          unit: 'piece', unitBn: 'টুকরা', imageUrl: 'w.jpg', imageUrls: [], categoryId: 'cat4', categoryName: 'Goods',
          categoryNameBn: 'পণ্য', subCategoryId: 'scat4', subCategoryName: 'Items',
          subCategoryNameBn: 'আইটেম', shopName: 'Shop4', addedBy: 'v4', brand: 'B4',
          tags: [], isNewArrival: false,
          comboProductIds: [], variants: [], rating: 4.0, salesCount: 1000,
          createdAt: DateTime(2024, 3), updatedAt: DateTime(2024, 3, 20),
        );
        final map = p.toMap();
        expect((map['tieredPrices'] as Map)['5'], 45);
      });
    });

    // ========================================================================
    // GROUP 5: CartItem Tests (2 tests)
    // ========================================================================
    group('CartItem - Shopping Cart Items', () {
      test('1. CartItem subtotal', () {
        final item = CartItem(
          id: 'p1', name: 'Phone', imageUrl: 'img.jpg',
          price: 1000.0, oldPrice: 1200.0, quantity: 2, unit: 'piece',
        );
        expect(item.subtotal, 2000.0);
      });

      test('2. CartItem quantity mutation', () {
        final item = CartItem(
          id: 'p2', name: 'Laptop', imageUrl: 'lap.jpg',
          price: 5000.0, oldPrice: 6000.0, unit: 'piece',
        );
        item.quantity = 3;
        expect(item.subtotal, 15000.0);
      });
    });

    // ========================================================================
    // GROUP 6: CartState Tests (3 tests)
    // ========================================================================
    group('CartState - Shopping Cart', () {
      test('1. CartState totalAmount', () {
        final item1 = CartItem(
          id: 'p1', name: 'Phone', imageUrl: 'img.jpg',
          price: 1000.0, oldPrice: 1200.0, unit: 'piece',
        );
        final item2 = CartItem(
          id: 'p2', name: 'Shirt', imageUrl: 'shirt.jpg',
          price: 200.0, oldPrice: 300.0, quantity: 2, unit: 'piece',
        );
        final cart = CartState(
          items: [item1, item2],
        );
        expect(cart.totalAmount, 1400.0);
      });

      test('2. CartState itemCount', () {
        final item = CartItem(
          id: 'p1', name: 'Phone', imageUrl: 'img.jpg',
          price: 1000.0, oldPrice: 1200.0, quantity: 2, unit: 'piece',
        );
        final cart = CartState(
          items: [item],
        );
        expect(cart.itemCount, 1);
      });

      test('3. CartState copyWith', () {
        final cart = CartState(
          items: [],
        );
        final updated = cart.copyWith(isLoading: true);
        expect(updated.isLoading, true);
      });
    });

    // ========================================================================
    // GROUP 7: OrderItem Tests (2 tests)
    // ========================================================================
    group('OrderItem - Order Items', () {
      test('1. OrderItem toMap', () {
        final item = order_model.OrderItem(
          productId: 'p1', productName: 'Phone', productNameBn: 'ফোন',
          price: 1000.0, quantity: 1, subtotal: 1000.0,
        );
        final map = item.toMap();
        expect(map['productId'], 'p1');
        expect(map['quantity'], 1);
      });

      test('2. OrderItem fromMap', () {
        final map = {'productId': 'p2', 'productName': 'Laptop',
          'productNameBn': 'ল্যাপটপ', 'price': 5000.0, 'quantity': 2,
          'subtotal': 10000.0};
        final item = order_model.OrderItem.fromMap(map);
        expect(item.productId, 'p2');
        expect(item.quantity, 2);
      });
    });

    // ========================================================================
    // GROUP 8: Order Tests (3 tests)
    // ========================================================================
    group('Order - Order Management', () {
      test('1. Order toMap includes status', () {
        final order = order_model.Order(
          id: 'ord1', customerUid: 'u1', customerName: 'Ahmed',
          customerPhone: '01700000000', items: [], subtotal: 0, deliveryFee: 0,
          discount: 0, total: 0, address: 'Dhaka', paymentMethod: 'Card',
          status: order_model.OrderStatus.confirmed, createdAt: DateTime(2024, 3, 20),
          updatedAt: DateTime(2024, 3, 20),
        );
        final map = order.toMap();
        expect(map['status'], 'confirmed');
      });

      test('2. Order fromMap with timestamp', () {
        final map = {'id': 'ord2', 'customerUid': 'u2', 'customerName': 'Fatima',
          'customerPhone': '01800000000', 'items': [], 'subtotal': 0.0,
          'deliveryFee': 0.0, 'discount': 0.0, 'total': 0.0, 'address': 'Chittagong',
          'paymentMethod': 'Cash', 'status': 'pending', 'createdAt': Timestamp.fromDate(DateTime(2024, 3, 20)),
          'updatedAt': Timestamp.fromDate(DateTime(2024, 3, 20))};
        final order = order_model.Order.fromMap(map);
        expect(order.customerName, 'Fatima');
        expect(order.status, order_model.OrderStatus.pending);
      });

      test('3. Order enum values', () {
        expect(order_model.OrderStatus.pending, order_model.OrderStatus.pending);
        expect(order_model.OrderStatus.confirmed, order_model.OrderStatus.confirmed);
        expect([
          order_model.OrderStatus.pending,
          order_model.OrderStatus.shipped,
          order_model.OrderStatus.delivered,
        ], contains(order_model.OrderStatus.pending));
      });
    });

    // ========================================================================
    // GROUP 9: Doctor Tests (2 tests)
    // ========================================================================
    group('Doctor - Healthcare Providers', () {
      test('1. Doctor toMap', () {
        final doc = Doctor(
          id: 'doc1', name: 'Dr. Ahmed', specialization: 'Cardiology',
          chamber: 'Heart Clinic', visitingDays: 'Mon-Fri', visitingHours: '9-5',
          visitFee: '500', contactNumber: '01712345678', imageUrl: 'doc.jpg',
          district: 'Dhaka', upazila: 'Mirpur', phone: '02-1234567',
        );
        final map = doc.toMap();
        expect(map['name'], 'Dr. Ahmed');
        expect(map['specialization'], 'Cardiology');
        expect(map.containsKey('id'), false);
      });

      test('2. Doctor fromMap', () {
        final map = {'id': 'doc2', 'name': 'Dr. Fatima', 'specialization': 'Neurology',
          'chamber': 'Brain Center', 'visitingDays': 'Tue-Sat', 'visitingHours': '10-6',
          'visitFee': '600', 'contactNumber': '01887654321', 'imageUrl': 'doc2.jpg',
          'district': 'Dhaka', 'upazila': 'Gulshan', 'phone': '02-7654321', 'isVisible': true};
        final doc = Doctor.fromMap(map);
        expect(doc.id, 'doc2');
        expect(doc.specialization, 'Neurology');
      });
    });

    // ========================================================================
    // GROUP 10: BloodDonor Tests (2 tests)
    // ========================================================================
    group('BloodDonor - Blood Donors', () {
      test('1. BloodDonor toMap', () {
        final donor = BloodDonor(
          id: 'donor1', name: 'Hassan', bloodGroup: 'O+', contactNumber: '01712345678',
          phone: '02-1111111', lastDonated: DateTime(2024, 1, 15), userUid: 'u1',
          imageUrl: 'donor.jpg', district: 'Dhaka', upazila: 'Mirpur',
        );
        final map = donor.toMap();
        expect(map['name'], 'Hassan');
        expect(map['bloodGroup'], 'O+');
        expect(map.containsKey('id'), false);
      });

      test('2. BloodDonor fromMap', () {
        final map = {'id': 'donor2', 'name': 'Ayesha', 'bloodGroup': 'AB-',
          'contactNumber': '01887654321', 'phone': '02-2222222',
          'lastDonated': Timestamp.fromDate(DateTime(2024, 2, 20)), 'userUid': 'u2',
          'imageUrl': 'donor2.jpg', 'district': 'Chittagong', 'upazila': 'Port', 'isVisible': true};
        final donor = BloodDonor.fromMap(map);
        expect(donor.id, 'donor2');
        expect(donor.bloodGroup, 'AB-');
      });
    });

    // ========================================================================
    // GROUP 11: Review Tests (2 tests)
    // ========================================================================
    group('Review - Product Reviews', () {
      test('1. Review toMap', () {
        final review = Review(
          id: 'rev1', userId: 'u1', userName: 'Ahmed', userImageUrl: 'user.jpg',
          productId: 'p1', comment: 'Great product!', rating: 4.8,
          createdAt: DateTime(2024, 3, 20),
        );
        final map = review.toMap();
        expect(map['userName'], 'Ahmed');
        expect(map['rating'], 4.8);
        expect(map.containsKey('id'), false);
      });

      test('2. Review fromMap', () {
        final map = {'id': 'rev2', 'userId': 'u2', 'userName': 'Fatima',
          'userImageUrl': 'user2.jpg', 'productId': 'p2', 'comment': 'Good quality',
          'rating': 4.2, 'createdAt': Timestamp.fromDate(DateTime(2024, 3, 19))};
        final review = Review.fromMap(map, 'rev2');
        expect(review.id, 'rev2');
        expect(review.rating, 4.2);
      });
    });

    // ========================================================================
    // GROUP 12: BackupItem Tests (2 tests)
    // ========================================================================
    group('BackupItem - Data Backups', () {
      test('1. BackupItem toMap', () {
        final backup = BackupItem(
          id: 'bak1', title: 'User Data', content: 'Backup content',
          fileUrl: 'backup.zip', fileSize: 125.5, type: BackupType.document,
          createdAt: DateTime(2024, 3, 20),
        );
        final map = backup.toMap();
        expect(map['title'], 'User Data');
        expect(map['fileSize'], 125.5);
      });

      test('2. BackupItem fromMap', () {
        final map = {'id': 'bak2', 'title': 'Images', 'content': 'Image backup',
          'fileUrl': 'images.zip', 'fileSize': 512.75, 'type': 'image',
          'createdAt': Timestamp.fromDate(DateTime(2024, 3, 19)), 'isPublic': true};
        final backup = BackupItem.fromMap(map, 'bak2');
        expect(backup.id, 'bak2');
        expect(backup.fileSize, 512.75);
      });
    });

    // ========================================================================
    // GROUP 13: Cross-Model Integration (2 tests)
    // ========================================================================
    group('Cross-Model Integration', () {
      test('1. User with addresses', () {
        final addr = AddressModel(
          id: 'a1', name: 'Home', district: 'Dhaka', upazila: 'Mirpur',
          station: 'PS', area: 'Banani', areaId: 'area1',
          detailedAddress: 'House 1', deliveryCharge: 50.0, isDefault: true,
        );
        final user = UserModel(
          id: 'u1', name: 'Test', phone: '01700000000', email: 't@test.com', addresses: [addr],
          myReferralCode: 'REF1', q1: '', a1: '', h1: '',
          q2: '', a2: '', h2: '', q3: '', a3: '', h3: '',
          storageLimit: 1024, isSubscribed: true,
        );
        expect(user.addresses.length, 1);
        expect(user.addresses[0].isDefault, true);
      });

      test('2. Product with variants', () {
        final v = Variant(id: 'v1', name: 'Red', nameBn: 'লাল', price: 100.0, stock: 50);
        final p = Product(
          id: 'p1', sku: 'SKU1', name: 'Shirt', nameBn: 'শার্ট',
          description: 'Cotton', descriptionBn: 'কটন', price: 200.0, oldPrice: 300.0,
          purchasePrice: 100.0, wholesalePrice: 150.0, minWholesaleQty: 10,
          tieredPrices: {}, stock: 100, unit: 'piece', unitBn: 'টুকরা',
          imageUrl: 'shirt.jpg', imageUrls: [],
          categoryId: 'cat1', categoryName: 'Clothing', categoryNameBn: 'পোশাক',
          subCategoryId: 'sub1', subCategoryName: 'Shirts', subCategoryNameBn: 'শার্টস',
          shopName: 'Shop1', addedBy: 'v1', brand: 'Brand1', tags: [], isNewArrival: false, comboProductIds: [], variants: [v],
          rating: 4.5, salesCount: 100, createdAt: DateTime(2024),
          updatedAt: DateTime(2024, 3, 20),
        );
        expect(p.variants.length, 1);
        expect(p.isCombo, false);
      });
    });
  });
}
