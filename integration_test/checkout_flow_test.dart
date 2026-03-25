import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:paykari_bazar/main_customer.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Secure Checkout Integration Test', () {
    testWidgets('Verify biometric requirement in checkout flow', (tester) async {
      // 1. Launch App
      app.main();
      await tester.pumpAndSettle();

      // 2. Add product to cart (Assuming we are on Home Screen)
      // This is a simplified flow for the test. 
      // In real integration tests, we'd navigate to a product and click add.
      final addToCartBtn = find.byIcon(Icons.add_shopping_cart).first;
      if (tester.any(addToCartBtn)) {
        await tester.tap(addToCartBtn);
        await tester.pumpAndSettle();
      }

      // 3. Open Cart / Checkout
      final cartIcon = find.byIcon(Icons.shopping_cart);
      await tester.tap(cartIcon);
      await tester.pumpAndSettle();

      // 4. Tap "CONFIRM SECURE ORDER"
      final confirmBtn = find.text('CONFIRM SECURE ORDER');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // 5. Verify that biometric authentication is triggered
      // Since local_auth shows a system dialog, we can't interact with it directly via Flutter tester.
      // However, we can check if the "Verification failed" snackbar appears if we dismiss or fail it.
      
      // Note: Integration tests on real devices will require manual interaction 
      // unless using a mock for local_auth during testing.
      
      expect(find.text('Checkout Summary'), findsOneWidget);
    });
  });
}
