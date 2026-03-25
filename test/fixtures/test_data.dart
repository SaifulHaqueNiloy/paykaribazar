/// test/fixtures/test_data.dart
/// Common test data and fixtures used across all tests

import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
// USER FIXTURES
// ============================================================================

const testUserId = 'test-user-123';
const testUserEmail = 'testuser@example.com';
const testUserPhone = '+1234567890';
const testUserName = 'Test User';

final testUserMap = {
  'id': testUserId,
  'email': testUserEmail,
  'phone': testUserPhone,
  'name': testUserName,
  'createdAt': Timestamp.now(),
  'role': 'user',
};

// ============================================================================
// PRODUCT FIXTURES
// ============================================================================

const testProductId = 'prod-123';
const testProductName = 'Test Product';
const testProductPrice = 99.99;
const testProductStock = 100;

final testProductMap = {
  'id': testProductId,
  'name': testProductName,
  'description': 'A test product for unit testing',
  'price': testProductPrice,
  'stock': testProductStock,
  'category': 'test-category',
  'image': 'https://example.com/image.jpg',
  'rating': 4.5,
  'reviews': 42,
  'createdAt': Timestamp.now(),
};

final testProductList = [
  {
    ...testProductMap,
    'id': 'prod-1',
    'name': 'Product 1',
    'price': 10.0,
  },
  {
    ...testProductMap,
    'id': 'prod-2',
    'name': 'Product 2',
    'price': 20.0,
  },
  {
    ...testProductMap,
    'id': 'prod-3',
    'name': 'Product 3',
    'price': 30.0,
  },
];

// ============================================================================
// ORDER FIXTURES
// ============================================================================

const testOrderId = 'order-123';
const testOrderStatus = 'pending';
const testOrderTotal = 199.98;

final testOrderMap = {
  'id': testOrderId,
  'userId': testUserId,
  'status': testOrderStatus,
  'items': [
    {
      'productId': testProductId,
      'quantity': 2,
      'price': testProductPrice,
      'subtotal': testProductPrice * 2,
    }
  ],
  'total': testOrderTotal,
  'discount': 0.0,
  'tax': 0.0,
  'createdAt': Timestamp.now(),
  'updatedAt': Timestamp.now(),
};

// ============================================================================
// AI REQUEST/RESPONSE FIXTURES
// ============================================================================

const testAiQuery = 'What is Flutter?';
const testAiResponse =
    'Flutter is a cross-platform mobile app development framework.';
const testAiCacheKey = 'query_hash_12345';

final testAiAuditMap = {
  'query': testAiQuery,
  'response': testAiResponse,
  'provider': 'gemini',
  'latency': 150,
  'tokensUsed': 45,
  'timestamp': Timestamp.now(),
};

// ============================================================================
// CART FIXTURES
// ============================================================================

final testCartItemMap = {
  'productId': testProductId,
  'name': testProductName,
  'quantity': 2,
  'price': testProductPrice,
  'subtotal': testProductPrice * 2,
  'addedAt': Timestamp.now(),
};

final testCartMap = {
  'userId': testUserId,
  'items': [testCartItemMap],
  'total': testProductPrice * 2,
  'itemCount': 2,
  'updatedAt': Timestamp.now(),
};

// ============================================================================
// COUPON/DISCOUNT FIXTURES
// ============================================================================

const testCouponCode = 'TEST20';
const testCouponDiscount = 20.0; // 20%

final testCouponMap = {
  'code': testCouponCode,
  'type': 'percentage',
  'value': testCouponDiscount,
  'maxUses': 100,
  'currentUses': 10,
  'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 30))),
  'status': 'active',
};

// ============================================================================
// APPOINTMENT FIXTURES
// ============================================================================

const testAppointmentId = 'appt-123';
const testDoctorId = 'doctor-456';

final testAppointmentMap = {
  'id': testAppointmentId,
  'userId': testUserId,
  'doctorId': testDoctorId,
  'status': 'scheduled',
  'dateTime': Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
  'duration': 30,
  'notes': 'Test appointment notes',
  'createdAt': Timestamp.now(),
};

// ============================================================================
// DELIVERY FIXTURES
// ============================================================================

const testDeliveryId = 'dlv-123';

final testDeliveryMap = {
  'id': testDeliveryId,
  'orderId': testOrderId,
  'status': 'dispatched',
  'driverName': 'John Doe',
  'driverPhone': '+1234567890',
  'latitude': 37.7749,
  'longitude': -122.4194,
  'estimatedArrival': Timestamp.fromDate(DateTime.now().add(Duration(hours: 2))),
  'createdAt': Timestamp.now(),
};

// ============================================================================
// PAYMENT FIXTURES
// ============================================================================

const testPaymentId = 'pay-123';
const testPaymentAmount = 199.98;

final testPaymentMap = {
  'id': testPaymentId,
  'orderId': testOrderId,
  'userId': testUserId,
  'amount': testPaymentAmount,
  'status': 'completed',
  'method': 'card',
  'transactionId': 'txn-xyz-789',
  'createdAt': Timestamp.now(),
};

// ============================================================================
// BACKUP FIXTURES
// ============================================================================

final testBackupMap = {
  'id': 'backup-123',
  'userId': testUserId,
  'dataSize': 1024,
  'fileCount': 25,
  'status': 'completed',
  'createdAt': Timestamp.now(),
  'expiryDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 90))),
};

// ============================================================================
// ERROR/EXCEPTION FIXTURES
// ============================================================================

const testErrorMessage = 'Test error message';
const testErrorCode = 'test_error_code';

// ============================================================================
// PAGINATION FIXTURES
// ============================================================================

const testPageSize = 10;
final testCursor = Timestamp.now();

// ============================================================================
// CONFIG FIXTURES
// ============================================================================

final testConfigMap = {
  'apiVersion': '1.0.0',
  'minSupportedVersion': '0.9.0',
  'features': {
    'aiEnabled': true,
    'biometricEnabled': true,
    'offlineMode': true,
  },
  'updatedAt': Timestamp.now(),
};
