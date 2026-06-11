import 'package:flutter_test/flutter_test.dart';
import 'package:paykari_bazar/src/features/commerce/services/coupon_service.dart';

void main() {
  group('CouponService Tests', () {
    late CouponService couponService;

    setUp(() {
      couponService = CouponService();
    });

    group('calculateDiscount', () {
      test('percentage discount', () {
        final discount = couponService.calculateDiscount(
          discountType: 'percentage',
          discountValue: 10.0,
          cartTotal: 100.0,
        );
        expect(discount, closeTo(10.0, 0.01));
      });

      test('fixed discount', () {
        final discount = couponService.calculateDiscount(
          discountType: 'fixed',
          discountValue: 50.0,
          cartTotal: 100.0,
        );
        expect(discount, equals(50.0));
      });

      test('discount capped at cartTotal', () {
        final discount = couponService.calculateDiscount(
          discountType: 'fixed',
          discountValue: 200.0,
          cartTotal: 100.0,
        );
        expect(discount, equals(100.0));
      });

      test('percentage discount respects maxDiscount', () {
        final discount = couponService.calculateDiscount(
          discountType: 'percentage',
          discountValue: 50.0,
          cartTotal: 100.0,
          maxDiscount: 30.0,
        );
        expect(discount, equals(30.0));
      });

      test('percentage discount without maxDiscount', () {
        final discount = couponService.calculateDiscount(
          discountType: 'percentage',
          discountValue: 20.0,
          cartTotal: 500.0,
        );
        expect(discount, equals(100.0));
      });

      test('fixed discount smaller than cartTotal', () {
        final discount = couponService.calculateDiscount(
          discountType: 'fixed',
          discountValue: 25.0,
          cartTotal: 200.0,
        );
        expect(discount, equals(25.0));
      });
    });

    group('validateCoupon edge cases', () {
      test('empty couponCode returns null', () async {
        final result = await couponService.validateCoupon(
          couponCode: '',
          cartTotal: 100.0,
          userId: 'user1',
        );
        expect(result, isNull);
      });

      test('zero cartTotal with percentage coupon', () {
        final discount = couponService.calculateDiscount(
          discountType: 'percentage',
          discountValue: 10.0,
          cartTotal: 0.0,
        );
        expect(discount, equals(0.0));
      });
    });
  });
}
