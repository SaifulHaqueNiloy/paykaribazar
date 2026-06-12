import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paykari_bazar/src/features/cart/cart_screen.dart';
import 'package:paykari_bazar/src/features/commerce/services/cart_service.dart';
import 'package:paykari_bazar/src/features/commerce/providers/cart_provider.dart';
import 'package:paykari_bazar/src/di/providers.dart';
import 'package:paykari_bazar/src/services/language_provider.dart';

class MockCartService extends Mock implements CartService {}

void main() {
  group('CartScreen Widget Tests', () {
    late MockCartService mockCartService;

    setUp(() {
      mockCartService = MockCartService();
    });

    testWidgets('renders empty cart state', (WidgetTester tester) async {
      when(() => mockCartService.fetchSavedCart()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languageProvider.overrideWith((ref) {
              final notifier = LanguageNotifier();
              notifier.setLanguage('en');
              return notifier;
            }),
            cartServiceProvider.overrideWithValue(mockCartService),
            cartProvider.overrideWith((ref) => CartNotifier(mockCartService)),
            cartDeliveryFeeProvider.overrideWith((ref) => 0.0),
            cartDiscountProvider.overrideWith((ref) => 0.0),
          ],
          child: const MaterialApp(
            home: CartScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('My Cart'), findsOneWidget);
      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('Start Shopping'), findsOneWidget);
    });

    testWidgets('renders cart items with quantities and prices', (WidgetTester tester) async {
      when(() => mockCartService.fetchSavedCart()).thenAnswer((_) async => [
        {'id': '1', 'name': 'Test Product', 'imageUrl': 'https://example.com/img.jpg', 'price': 100.0, 'quantity': 2, 'unit': 'pcs'},
      ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languageProvider.overrideWith((ref) {
              final notifier = LanguageNotifier();
              notifier.setLanguage('en');
              return notifier;
            }),
            cartServiceProvider.overrideWithValue(mockCartService),
            cartProvider.overrideWith((ref) => CartNotifier(mockCartService)),
            cartDeliveryFeeProvider.overrideWith((ref) => 0.0),
            cartDiscountProvider.overrideWith((ref) => 0.0),
          ],
          child: const MaterialApp(
            home: CartScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('increase quantity when plus button tapped', (WidgetTester tester) async {
      when(() => mockCartService.fetchSavedCart()).thenAnswer((_) async => [
        {'id': '1', 'name': 'Test Product', 'imageUrl': 'https://example.com/img.jpg', 'price': 100.0, 'quantity': 1, 'unit': 'pcs'},
      ]);
      when(() => mockCartService.syncCartToCloud(any())).thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languageProvider.overrideWith((ref) {
              final notifier = LanguageNotifier();
              notifier.setLanguage('en');
              return notifier;
            }),
            cartServiceProvider.overrideWithValue(mockCartService),
            cartProvider.overrideWith((ref) => CartNotifier(mockCartService)),
            cartDeliveryFeeProvider.overrideWith((ref) => 0.0),
            cartDiscountProvider.overrideWith((ref) => 0.0),
          ],
          child: const MaterialApp(
            home: CartScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('decrease quantity when minus button tapped', (WidgetTester tester) async {
      when(() => mockCartService.fetchSavedCart()).thenAnswer((_) async => [
        {'id': '1', 'name': 'Test Product', 'imageUrl': 'https://example.com/img.jpg', 'price': 100.0, 'quantity': 2, 'unit': 'pcs'},
      ]);
      when(() => mockCartService.syncCartToCloud(any())).thenAnswer((_) async => Future.value());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languageProvider.overrideWith((ref) {
              final notifier = LanguageNotifier();
              notifier.setLanguage('en');
              return notifier;
            }),
            cartServiceProvider.overrideWithValue(mockCartService),
            cartProvider.overrideWith((ref) => CartNotifier(mockCartService)),
            cartDeliveryFeeProvider.overrideWith((ref) => 0.0),
            cartDiscountProvider.overrideWith((ref) => 0.0),
          ],
          child: const MaterialApp(
            home: CartScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('displays order summary with totals', (WidgetTester tester) async {
      when(() => mockCartService.fetchSavedCart()).thenAnswer((_) async => [
        {'id': '1', 'name': 'Test Product', 'imageUrl': 'https://example.com/img.jpg', 'price': 100.0, 'quantity': 2, 'unit': 'pcs'},
      ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languageProvider.overrideWith((ref) {
              final notifier = LanguageNotifier();
              notifier.setLanguage('en');
              return notifier;
            }),
            cartServiceProvider.overrideWithValue(mockCartService),
            cartProvider.overrideWith((ref) => CartNotifier(mockCartService)),
            cartSubtotalProvider.overrideWith((ref) => 200.0),
            cartDeliveryFeeProvider.overrideWith((ref) => 20.0),
            cartDiscountProvider.overrideWith((ref) => 0.0),
            cartTotalProvider.overrideWith((ref) => 220.0),
          ],
          child: const MaterialApp(
            home: CartScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('৳220.0'), findsOneWidget);
    });

    testWidgets('displays discount row when discount > 0', (WidgetTester tester) async {
      when(() => mockCartService.fetchSavedCart()).thenAnswer((_) async => [
        {'id': '1', 'name': 'Test Product', 'imageUrl': 'https://example.com/img.jpg', 'price': 100.0, 'quantity': 1, 'unit': 'pcs'},
      ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languageProvider.overrideWith((ref) {
              final notifier = LanguageNotifier();
              notifier.setLanguage('en');
              return notifier;
            }),
            cartServiceProvider.overrideWithValue(mockCartService),
            cartProvider.overrideWith((ref) => CartNotifier(mockCartService)),
            cartSubtotalProvider.overrideWith((ref) => 100.0),
            cartDeliveryFeeProvider.overrideWith((ref) => 10.0),
            cartDiscountProvider.overrideWith((ref) => 20.0),
            cartTotalProvider.overrideWith((ref) => 90.0),
          ],
          child: const MaterialApp(
            home: CartScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('-৳20.0'), findsOneWidget);
    });

    testWidgets('checkout button shows snackbar when tapped', (WidgetTester tester) async {
      when(() => mockCartService.fetchSavedCart()).thenAnswer((_) async => [
        {'id': '1', 'name': 'Test Product', 'imageUrl': 'https://example.com/img.jpg', 'price': 100.0, 'quantity': 1, 'unit': 'pcs'},
      ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languageProvider.overrideWith((ref) {
              final notifier = LanguageNotifier();
              notifier.setLanguage('en');
              return notifier;
            }),
            cartServiceProvider.overrideWithValue(mockCartService),
            cartProvider.overrideWith((ref) => CartNotifier(mockCartService)),
            cartDeliveryFeeProvider.overrideWith((ref) => 0.0),
            cartDiscountProvider.overrideWith((ref) => 0.0),
          ],
          child: const MaterialApp(
            home: CartScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();

      expect(find.text('Proceeding to Checkout...'), findsOneWidget);
    });

    testWidgets('empty cart shop now button navigates home', (WidgetTester tester) async {
      when(() => mockCartService.fetchSavedCart()).thenAnswer((_) async => null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languageProvider.overrideWith((ref) {
              final notifier = LanguageNotifier();
              notifier.setLanguage('en');
              return notifier;
            }),
            cartServiceProvider.overrideWithValue(mockCartService),
            cartProvider.overrideWith((ref) => CartNotifier(mockCartService)),
            cartDeliveryFeeProvider.overrideWith((ref) => 0.0),
            cartDiscountProvider.overrideWith((ref) => 0.0),
          ],
          child: MaterialApp(
            home: const CartScreen(),
            routes: {'/': (context) => const Scaffold(body: Text('Home'))},
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Shopping'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
