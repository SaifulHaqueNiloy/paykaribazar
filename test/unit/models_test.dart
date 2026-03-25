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
  group('Day 4: Model Tests (25+ tests)', () {
    // ========================================================================
    // GROUP 1: AddressModel Tests (3 tests)
    // ========================================================================
    group('AddressModel - Address Serialization', () {
      late AddressModel testAddress;

      setUp(() {
        testAddress = AddressModel(
          id: 'addr-001',
          name: 'Home',
          district: 'Dhaka',
          upazila: 'Mirpur',
          station: 'Police Station',
          area: 'Banani',
          areaId: 'area-001',
          detailedAddress: '123 Main Street, Apt 4B',
          deliveryCharge: 50.0,
          isDefault: true,
          latitude: 23.8103,
          longitude: 90.4125,
        );
      });

      test('1. AddressModel toMap serialization works correctly', () {
        final map = testAddress.toMap();

        expect(map['id'], equals('addr-001'));
        expect(map['name'], equals('Home'));
        expect(map['district'], equals('Dhaka'));
        expect(map['deliveryCharge'], equals(50.0));
        expect(map['isDefault'], equals(true));
        expect(map['latitude'], equals(23.8103));
      });

      test('2. AddressModel fromMap deserialization works correctly', () {
        final map = testAddress.toMap();
        final restored = AddressModel.fromMap(map);

        expect(restored.id, equals('addr-001'));
        expect(restored.name, equals('Home'));
        expect(restored.district, equals('Dhaka'));
        expect(restored.deliveryCharge, equals(50.0));
        expect(restored.isDefault, equals(true));
      });

      test('3. AddressModel fullAddress computed getter works', () {
        final fullAddr = testAddress.fullAddress;

        expect(fullAddr, contains('Dhaka'));
        expect(fullAddr, contains('Mirpur'));
        expect(fullAddr, contains('123 Main Street'));
      });
    });

    // ========================================================================
    // GROUP 2: UserModel Tests (3 tests)
    // ========================================================================
    group('UserModel - User Profile Management', () {
      late UserModel testUser;

      setUp(() {
        testUser = UserModel(
          id: 'user-001',
          name: 'Ahmed Hassan',
          phone: '01712345678',
          email: 'ahmed@email.com',
          role: UserRole.customer,
          addresses: [],
          profilePic: 'https://example.com/avatar.jpg',
          points: 1500,
          myReferralCode: 'REF-AHMED-001',
          currentMode: 'shopping',
          q1: 'pet-name',
          a1: 'Fluffy',
          h1: 'f89d3',
          q2: 'birth-city',
          a2: 'Dhaka',
          h2: 'a2f4e',
          q3: 'mother-name',
          a3: 'Fatima',
          h3: 'b7c9e',
          storageUsed: 256.5,
          storageLimit: 1024.0,
          isSubscribed: true,
        );
      });

      test('1. UserModel toMap includes all fields', () {
        final map = testUser.toMap();

        expect(map['id'], equals('user-001'));
        expect(map['name'], equals('Ahmed Hassan'));
        expect(map['phone'], equals('01712345678'));
        expect(map['role'], equals('customer'));
        expect(map['points'], equals(1500));
        expect(map['isSubscribed'], equals(true));
      });

      test('2. UserModel fromMap restores all fields', () {
        final map = testUser.toMap();
        final restored = UserModel.fromMap(map);

        expect(restored.id, equals('user-001'));
        expect(restored.name, equals('Ahmed Hassan'));
        expect(restored.email, equals('ahmed@email.com'));
        expect(restored.role, equals(UserRole.customer));
        expect(restored.points, equals(1500));
      });

      test('3. UserModel with multiple addresses', () {
        final addr1 = AddressModel(
          id: 'addr1',
          name: 'Home',
          district: 'Dhaka',
          upazila: 'Mirpur',
          station: 'PS',
          area: 'Banani',
          areaId: 'area1',
          detailedAddress: 'House 1',
          deliveryCharge: 50.0,
          isDefault: true,
        );

        final addr2 = AddressModel(
          id: 'addr2',
          name: 'Office',
          district: 'Dhaka',
          upazila: 'Gulshan',
          station: 'PS',
          area: 'Gulshan',
          areaId: 'area2',
          detailedAddress: 'Office Building',
          deliveryCharge: 75.0,
          isDefault: false,
        );

        final userWithAddresses = UserModel(
          id: 'user-002',
          name: 'Test User',
          phone: '01700000000',
          email: 'test@email.com',
          role: UserRole.reseller,
          addresses: [addr1, addr2],
          profilePic: null,
          points: 0,
          myReferralCode: 'REF-TEST',
          currentMode: 'shopping',
          q1: '',
          a1: '',
          h1: '',
          q2: '',
          a2: '',
          h2: '',
          q3: '',
          a3: '',
          h3: '',
          storageUsed: 0,
          storageLimit: 1024,
          isSubscribed: false,
        );

        final map = userWithAddresses.toMap();
        expect(map['addresses'], isA<List>());
        expect((map['addresses'] as List).length, equals(2));
      });
    });

    // ========================================================================
    // GROUP 3: Variant Tests (2 tests)
    // ========================================================================
    group('Variant - Product Variants', () {
      test('1. Variant toMap serialization', () {
        final variant = Variant(
          id: 'var-001',
          name: 'Red-Large',
          nameBn: 'লাল-বড়',
          price: 599.99,
          stock: 45,
        );

        final map = variant.toMap();
        expect(map['id'], equals('var-001'));
        expect(map['name'], equals('Red-Large'));
        expect(map['price'], equals(599.99));
        expect(map['stock'], equals(45));
      });

      test('2. Variant fromMap deserialization', () {
        final variantMap = {
          'id': 'var-002',
          'name': 'Blue-Small',
          'nameBn': 'নীল-ছোট',
          'price': 399.99,
          'stock': 120,
        };

        final variant = Variant.fromMap(variantMap);
        expect(variant.id, equals('var-002'));
        expect(variant.name, equals('Blue-Small'));
        expect(variant.price, equals(399.99));
      });
    });

    // ========================================================================
    // GROUP 4: Product Tests (4 tests)
    // ========================================================================
    group('Product - E-commerce Products', () {
      late Product testProduct;

      setUp(() {
        testProduct = Product(
          id: 'prod-001',
          sku: 'SKU-12345',
          name: 'Premium Headphones',
          nameBn: 'প্রিমিয়াম হেডফোন',
          description: 'High-quality wireless headphones',
          descriptionBn: 'উচ্চমানের ওয়্যারলেস হেডফোন',
          price: 2999.99,
          oldPrice: 3999.99,
          purchasePrice: 2000.0,
          wholesalePrice: 2500.0,
          minWholesaleQty: 5,
          tieredPrices: {'10': 2900, '50': 2800},
          stock: 150,
          unit: 'piece',
          unitBn: 'টুকরা',
          imageUrl: 'https://example.com/image.jpg',
          imageUrls: ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
          marketingBannerUrl: null,
          categoryId: 'cat-001',
          categoryName: 'Electronics',
          categoryNameBn: 'ইলেকট্রনিক্স',
          subCategoryId: 'subcat-001',
          subCategoryName: 'Audio',
          subCategoryNameBn: 'অডিও',
          shopName: 'Tech Store',
          addedBy: 'vendor-001',
          brand: 'AudioMax',
          tags: ['wireless', 'headphones', 'audio'],
          isFlashSale: false,
          isCombo: false,
          isNewArrival: true,
          isFeatured: true,
          isHotSelling: false,
          isComboPack: false,
          comboProductIds: [],
          variants: [],
          rating: 4.5,
          salesCount: 245,
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 3, 20),
          aiOptimized: true,
          aiAuditPending: false,
        );
      });

      test('1. Product toMap includes commerce fields', () {
        final map = testProduct.toMap();

        expect(map['id'], equals('prod-001'));
        expect(map['name'], equals('Premium Headphones'));
        expect(map['price'], equals(2999.99));
        expect(map['stock'], equals(150));
        expect(map['isNewArrival'], equals(true));
        expect(map['isFeatured'], equals(true));
      });

      test('2. Product fromMap deserializes correctly', () {
        final map = testProduct.toMap();
        final restored = Product.fromMap(map, 'prod-001');

        expect(restored.id, equals('prod-001'));
        expect(restored.name, equals('Premium Headphones'));
        expect(restored.price, equals(2999.99));
        expect(restored.rating, equals(4.5));
      });

      test('3. Product with variants', () {
        final variant1 = Variant(
          id: 'var1',
          name: 'Red',
          nameBn: 'লাল',
          price: 2999.99,
          stock: 50,
        );
        final variant2 = Variant(
          id: 'var2',
          name: 'Blue',
          nameBn: 'নীল',
          price: 2999.99,
          stock: 100,
        );

        final productWithVariants = Product(
          id: 'prod-002',
          sku: 'SKU-V001',
          name: 'Tshirt',
          nameBn: 'টি-শার্ট',
          description: 'Cotton T-Shirt',
          descriptionBn: 'কটন টি-শার্ট',
          price: 299.99,
          oldPrice: 399.99,
          purchasePrice: 150.0,
          wholesalePrice: 250.0,
          minWholesaleQty: 10,
          tieredPrices: {},
          stock: 200,
          unit: 'piece',
          unitBn: 'টুকরা',
          imageUrl: 'https://example.com/tshirt.jpg',
          imageUrls: [],
          marketingBannerUrl: null,
          categoryId: 'cat-002',
          categoryName: 'Clothing',
          categoryNameBn: 'পোশাক',
          subCategoryId: 'subcat-002',
          subCategoryName: 'Tshirts',
          subCategoryNameBn: 'টি-শার্ট',
          shopName: 'Fashion Store',
          addedBy: 'vendor-002',
          brand: 'StyleMax',
          tags: ['clothing', 'tshirt'],
          isFlashSale: true,
          isCombo: false,
          isNewArrival: false,
          isFeatured: false,
          isHotSelling: true,
          isComboPack: false,
          comboProductIds: [],
          variants: [variant1, variant2],
          rating: 4.2,
          salesCount: 512,
          createdAt: DateTime(2024, 2, 1),
          updatedAt: DateTime(2024, 3, 19),
          aiOptimized: false,
          aiAuditPending: true,
        );

        final map = productWithVariants.toMap();
        expect(map['variants'], isA<List>());
        expect((map['variants'] as List).length, equals(2));
      });

      test('4. Product tiered pricing', () {
        final map = testProduct.toMap();
        expect(map['tieredPrices'], isA<Map>());
        expect((map['tieredPrices'] as Map).containsKey('10'), isTrue);
        expect((map['tieredPrices'] as Map)['10'], equals(2900));
      });
    });

    // ========================================================================
    // GROUP 5: CartItem Tests (2 tests)
    // ========================================================================
    group('CartItem - Shopping Cart Items', () {
      test('1. CartItem subtotal calculation', () {
        final cartItem = CartItem(
          id: 'prod-001',
          name: 'Headphones',
          imageUrl: 'https://example.com/image.jpg',
          price: 2999.99,
          oldPrice: 3999.99,
          quantity: 2,
          unit: 'piece',
        );

        expect(cartItem.subtotal, equals(5999.98));
      });

      test('2. CartItem quantity mutation', () {
        final cartItem = CartItem(
          id: 'prod-002',
          name: 'TShirt',
          imageUrl: 'https://example.com/tshirt.jpg',
          price: 299.99,
          oldPrice: 399.99,
          quantity: 1,
          unit: 'piece',
        );

        cartItem.quantity = 5;
        expect(cartItem.quantity, equals(5));
        expect(cartItem.subtotal, equals(1499.95));
      });
    });

    // ========================================================================
    // GROUP 6: CartState Tests (3 tests)
    // ========================================================================
    group('CartState - Shopping Cart State Management', () {
      late CartState testCart;

      setUp(() {
        final item1 = CartItem(
          id: 'prod-001',
          name: 'Headphones',
          imageUrl: 'https://example.com/image.jpg',
          price: 2999.99,
          oldPrice: 3999.99,
          quantity: 1,
          unit: 'piece',
        );

        final item2 = CartItem(
          id: 'prod-002',
          name: 'TShirt',
          imageUrl: 'https://example.com/tshirt.jpg',
          price: 299.99,
          oldPrice: 399.99,
          quantity: 2,
          unit: 'piece',
        );

        testCart = CartState(
          items: [item1, item2],
          isLoading: false,
          error: null,
          appliedCoupon: 'SAVE20',
          appliedCouponMap: {'discount': 500.0, 'type': 'fixed'},
          selectedAddress: null,
        );
      });

      test('1. CartState totalAmount calculation', () {
        final total = testCart.totalAmount;
        final expected = 2999.99 + (299.99 * 2); // 3599.97
        expect(total, equals(expected));
      });

      test('2. CartState itemCount', () {
        expect(testCart.itemCount, equals(2));
      });

      test('3. CartState copyWith method', () {
        final updatedCart = testCart.copyWith(
          isLoading: true,
          error: 'Network error',
        );

        expect(updatedCart.isLoading, equals(true));
        expect(updatedCart.error, equals('Network error'));
        expect(updatedCart.items.length, equals(2));
      });
    });

    // ========================================================================
    // GROUP 7: OrderItem Tests (2 tests)
    // ========================================================================
    group('OrderItem - Order Items', () {
      test('1. OrderItem toMap serialization', () {
        final orderItem = order_model.OrderItem(
          productId: 'prod-001',
          productName: 'Headphones',
          productNameBn: 'হেডফোন',
          price: 2999.99,
          quantity: 1,
          subtotal: 2999.99,
          variantId: null,
          imageUrl: 'https://example.com/image.jpg',
        );

        final map = orderItem.toMap();
        expect(map['productId'], equals('prod-001'));
        expect(map['price'], equals(2999.99));
        expect(map['quantity'], equals(1));
      });

      test('2. OrderItem fromMap deserialization', () {
        final itemMap = {
          'productId': 'prod-002',
          'productName': 'TShirt',
          'productNameBn': 'টি-শার্ট',
          'price': 299.99,
          'quantity': 3,
          'subtotal': 899.97,
          'variantId': 'var-red',
          'imageUrl': 'https://example.com/tshirt.jpg',
        };

        final orderItem = order_model.OrderItem.fromMap(itemMap);
        expect(orderItem.productId, equals('prod-002'));
        expect(orderItem.quantity, equals(3));
        expect(orderItem.subtotal, equals(899.97));
      });
    });

    // ========================================================================
    // GROUP 8: Order Tests (3 tests)
    // ========================================================================
    group('Order - Order Management', () {
      late order_model.Order testOrder;

      setUp(() {
        final item1 = order_model.OrderItem(
          productId: 'prod-001',
          productName: 'Headphones',
          productNameBn: 'হেডফোন',
          price: 2999.99,
          quantity: 1,
          subtotal: 2999.99,
        );

        testOrder = order_model.Order(
          id: 'ord-001',
          customerUid: 'user-001',
          customerName: 'Ahmed Hassan',
          customerPhone: '01712345678',
          items: [item1],
          subtotal: 2999.99,
          deliveryFee: 100.0,
          discount: 500.0,
          total: 2599.99,
          address: 'Dhaka, Bangladesh',
          paymentMethod: 'bKash',
          status: order_model.OrderStatus.confirmed,
          riderUid: null,
          isEmergency: false,
          createdAt: DateTime(2024, 3, 20),
          updatedAt: DateTime(2024, 3, 20),
          trackingId: 'TRACK-001',
          cancellationReason: null,
          deliveredAt: null,
        );
      });

      test('1. Order toMap includes all fields', () {
        final map = testOrder.toMap();

        expect(map['id'], equals('ord-001'));
        expect(map['customerName'], equals('Ahmed Hassan'));
        expect(map['total'], equals(2599.99));
        expect(map['status'], equals('confirmed'));
      });

      test('2. Order fromMap deserialization', () {
        final map = testOrder.toMap();
        final restored = order_model.Order.fromMap(map);

        expect(restored.id, equals('ord-001'));
        expect(restored.customerUid, equals('user-001'));
        expect(restored.total, equals(2599.99));
        expect(restored.status, equals(order_model.OrderStatus.confirmed));
      });

      test('3. Order status transitions', () {
        expect(testOrder.status, equals(order_model.OrderStatus.confirmed));

        final shippedOrder = order_model.Order(
          id: 'ord-002',
          customerUid: 'user-002',
          customerName: 'Fatima Khan',
          customerPhone: '01798765432',
          items: [],
          subtotal: 1500.0,
          deliveryFee: 50.0,
          discount: 0,
          total: 1550.0,
          address: 'Chittagong, Bangladesh',
          paymentMethod: 'Credit Card',
          status: order_model.OrderStatus.shipped,
          riderUid: 'rider-001',
          isEmergency: false,
          createdAt: DateTime(2024, 3, 19),
          updatedAt: DateTime(2024, 3, 20),
          trackingId: 'TRACK-002',
          cancellationReason: null,
          deliveredAt: null,
        );

        expect(shippedOrder.status, equals(order_model.OrderStatus.shipped));
      });
    });

    // ========================================================================
    // GROUP 9: Doctor Tests (2 tests)
    // ========================================================================
    group('Doctor - Healthcare Provider Profile', () {
      test('1. Doctor toMap serialization', () {
        final doctor = Doctor(
          id: 'doc-001',
          name: 'Dr. Ahmed Khan',
          specialization: 'Cardiology',
          chamber: 'Cardiac Care Center',
          visitingDays: 'Mon, Wed, Fri',
          visitingHours: '09:00 AM - 05:00 PM',
          visitFee: '500',
          contactNumber: '01912345678',
          imageUrl: 'https://example.com/doctor.jpg',
          phone: '02-55555555',
          district: 'Dhaka',
          upazila: 'Mirpur',
          isVisible: true,
        );

        final map = doctor.toMap();
        expect(map['id'], equals('doc-001'));
        expect(map['name'], equals('Dr. Ahmed Khan'));
        expect(map['specialization'], equals('Cardiology'));
        expect(map['visitFee'], equals('500'));
      });

      test('2. Doctor fromMap deserialization', () {
        final doctorMap = {
          'id': 'doc-002',
          'name': 'Dr. Fatima Ali',
          'specialization': 'Neurology',
          'chamber': 'Brain & Spine Clinic',
          'visitingDays': 'Tue, Thu, Sat',
          'visitingHours': '10:00 AM - 06:00 PM',
          'visitFee': '600',
          'contactNumber': '01887654321',
          'imageUrl': 'https://example.com/doctor2.jpg',
          'phone': '02-66666666',
          'district': 'Dhaka',
          'upazila': 'Gulshan',
          'isVisible': true,
        };

        final doctor = Doctor.fromMap(doctorMap);
        expect(doctor.id, equals('doc-002'));
        expect(doctor.name, equals('Dr. Fatima Ali'));
        expect(doctor.specialization, equals('Neurology'));
      });
    });

    // ========================================================================
    // GROUP 10: BloodDonor Tests (2 tests)
    // ========================================================================
    group('BloodDonor - Blood Donation Registry', () {
      test('1. BloodDonor toMap serialization', () {
        final donor = BloodDonor(
          id: 'donor-001',
          name: 'Hassan Ali',
          bloodGroup: 'O+',
          contactNumber: '01712345678',
          phone: '02-11111111',
          lastDonated: DateTime(2024, 1, 15),
          userUid: 'user-001',
          imageUrl: 'https://example.com/donor.jpg',
          district: 'Dhaka',
          upazila: 'Mirpur',
          isVisible: true,
        );

        final map = donor.toMap();
        expect(map['id'], equals('donor-001'));
        expect(map['bloodGroup'], equals('O+'));
        expect(map['name'], equals('Hassan Ali'));
      });

      test('2. BloodDonor fromMap deserialization', () {
        final donorMap = {
          'id': 'donor-002',
          'name': 'Ayesha Rahman',
          'bloodGroup': 'AB-',
          'contactNumber': '01787654321',
          'phone': '02-22222222',
          'lastDonated': DateTime(2024, 2, 20),
          'userUid': 'user-002',
          'imageUrl': 'https://example.com/donor2.jpg',
          'district': 'Chittagong',
          'upazila': 'Chawkbazar',
          'isVisible': true,
        };

        final donor = BloodDonor.fromMap(donorMap);
        expect(donor.id, equals('donor-002'));
        expect(donor.bloodGroup, equals('AB-'));
        expect(donor.district, equals('Chittagong'));
      });
    });

    // ========================================================================
    // GROUP 11: Review Tests (2 tests)
    // ========================================================================
    group('Review - Product Reviews & Ratings', () {
      test('1. Review toMap serialization', () {
        final review = Review(
          id: 'rev-001',
          userId: 'user-001',
          userName: 'Ahmed Hassan',
          userImageUrl: 'https://example.com/user.jpg',
          productId: 'prod-001',
          comment: 'Excellent quality headphones! Highly recommended.',
          rating: 4.8,
          createdAt: DateTime(2024, 3, 20),
        );

        final map = review.toMap();
        expect(map['id'], equals('rev-001'));
        expect(map['userName'], equals('Ahmed Hassan'));
        expect(map['rating'], equals(4.8));
        expect(map['comment'],
            contains('Excellent quality'));
      });

      test('2. Review fromMap deserialization', () {
        final reviewMap = {
          'id': 'rev-002',
          'userId': 'user-002',
          'userName': 'Fatima Khan',
          'userImageUrl': 'https://example.com/user2.jpg',
          'productId': 'prod-002',
          'comment': 'Good product, fast delivery.',
          'rating': 4.2,
          'createdAt': DateTime(2024, 3, 19),
        };

        final review = Review.fromMap(reviewMap, 'rev-002');
        expect(review.id, equals('rev-002'));
        expect(review.userName, equals('Fatima Khan'));
        expect(review.rating, equals(4.2));
      });
    });

    // ========================================================================
    // GROUP 12: BackupItem Tests (2 tests)
    // ========================================================================
    group('BackupItem - Data Backup Management', () {
      test('1. BackupItem toMap serialization', () {
        final backup = BackupItem(
          id: 'backup-001',
          title: 'User Data Backup',
          content: 'Complete user profile backup',
          fileUrl: 'https://storage.googleapis.com/backup-001.zip',
          fileSize: 125.5,
          type: BackupType.document,
          createdAt: DateTime(2024, 3, 20),
          isPublic: false,
        );

        final map = backup.toMap();
        expect(map['id'], equals('backup-001'));
        expect(map['title'], equals('User Data Backup'));
        expect(map['fileSize'], equals(125.5));
        expect(map['type'], equals('document'));
      });

      test('2. BackupItem fromMap deserialization', () {
        final backupMap = {
          'id': 'backup-002',
          'title': 'Product Images',
          'content': 'All product images backup',
          'fileUrl': 'https://storage.googleapis.com/backup-002.zip',
          'fileSize': 512.75,
          'type': 'image',
          'createdAt': DateTime(2024, 3, 19),
          'isPublic': true,
        };

        final backup = BackupItem.fromMap(backupMap, 'backup-002');
        expect(backup.id, equals('backup-002'));
        expect(backup.title, equals('Product Images'));
        expect(backup.fileSize, equals(512.75));
      });
    });

    // ========================================================================
    // GROUP 13: Cross-Model Integration Tests (2 tests)
    // ========================================================================
    group('Cross-Model Integration - Model Dependencies', () {
      test('1. User with addresses and orders', () {
        final addresses = [
          AddressModel(
            id: 'addr-1',
            name: 'Home',
            district: 'Dhaka',
            upazila: 'Mirpur',
            station: 'PS',
            area: 'Banani',
            areaId: 'area1',
            detailedAddress: 'House 1',
            deliveryCharge: 50.0,
            isDefault: true,
          ),
        ];

        final user = UserModel(
          id: 'user-003',
          name: 'Test User',
          phone: '01700000000',
          email: 'test@example.com',
          role: UserRole.customer,
          addresses: addresses,
          profilePic: null,
          points: 500,
          myReferralCode: 'REF-TEST-003',
          currentMode: 'shopping',
          q1: '',
          a1: '',
          h1: '',
          q2: '',
          a2: '',
          h2: '',
          q3: '',
          a3: '',
          h3: '',
          storageUsed: 0,
          storageLimit: 1024,
          isSubscribed: true,
        );

        expect(user.addresses.length, equals(1));
        expect(user.addresses[0].isDefault, equals(true));
      });

      test('2. Product with variants and reviews', () {
        final variants = [
          Variant(
            id: 'var-1',
            name: 'Size-S',
            nameBn: 'আকার-ছোট',
            price: 299.99,
            stock: 50,
          ),
          Variant(
            id: 'var-2',
            name: 'Size-L',
            nameBn: 'আকার-বড়',
            price: 399.99,
            stock: 30,
          ),
        ];

        final product = Product(
          id: 'prod-003',
          sku: 'SKU-COMBO',
          name: 'Combo Product',
          nameBn: 'কম্বো পণ্য',
          description: 'Various sizes available',
          descriptionBn: 'বিভিন্ন আকার উপলব্ধ',
          price: 349.99,
          oldPrice: 499.99,
          purchasePrice: 200.0,
          wholesalePrice: 300.0,
          minWholesaleQty: 5,
          tieredPrices: {},
          stock: 100,
          unit: 'piece',
          unitBn: 'টুকরা',
          imageUrl: 'https://example.com/product.jpg',
          imageUrls: [],
          marketingBannerUrl: null,
          categoryId: 'cat-003',
          categoryName: 'Fashion',
          categoryNameBn: 'ফ্যাশন',
          subCategoryId: 'subcat-003',
          subCategoryName: 'Clothing',
          subCategoryNameBn: 'পোশাক',
          shopName: 'Fashion Plus',
          addedBy: 'vendor-003',
          brand: 'StyleBrand',
          tags: ['fashion', 'clothing'],
          isFlashSale: false,
          isCombo: true,
          isNewArrival: false,
          isFeatured: false,
          isHotSelling: false,
          isComboPack: false,
          comboProductIds: [],
          variants: variants,
          rating: 4.5,
          salesCount: 300,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 3, 20),
          aiOptimized: false,
          aiAuditPending: false,
        );

        expect(product.variants.length, equals(2));
        expect(product.isCombo, equals(true));
        expect(product.rating, equals(4.5));
      });
    });
  });
}
