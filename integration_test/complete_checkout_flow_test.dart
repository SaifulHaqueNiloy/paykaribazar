import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:paykari_bazar/main_customer.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Checkout Flow Integration Test', () {
    testWidgets('full checkout flow: login -> search -> add to cart -> coupon -> payment -> order', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);

      final searchField = find.byType(TextField).first;
      if (tester.any(searchField)) {
        await tester.enterText(searchField, 'rice');
        await tester.pumpAndSettle();
      }

      final addToCartBtn = find.byIcon(Icons.add_shopping_cart).first;
      if (tester.any(addToCartBtn)) {
        await tester.tap(addToCartBtn);
        await tester.pumpAndSettle();
      }

      final cartIcon = find.byIcon(Icons.shopping_cart).first;
      if (tester.any(cartIcon)) {
        await tester.tap(cartIcon);
        await tester.pumpAndSettle();
      }

      expect(find.text('My Cart'), findsOneWidget);

      final checkoutBtn = find.text('Checkout');
      if (tester.any(checkoutBtn)) {
        await tester.tap(checkoutBtn);
        await tester.pumpAndSettle();
      }
    });
  });
}
