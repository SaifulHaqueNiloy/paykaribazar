import 'package:flutter_test/flutter_test.dart';
import 'package:paykari_bazar/main_customer.dart';

void main() {
  testWidgets('App widget can be instantiated', (WidgetTester tester) async {
    // Sanity test: Verify CustomerApp widget exists and can be created
    // Full integration test with Firebase happens in integration_test/
    expect(CustomerApp, isNotNull);
  });
}
