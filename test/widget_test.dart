import 'package:flutter_test/flutter_test.dart';
import 'package:paykari_bazar/main_customer.dart' as customer;
import 'package:paykari_bazar/main_admin.dart' as admin;

void main() {
  testWidgets('CustomerApp widget exists and is a ConsumerStatefulWidget', (tester) async {
    expect(customer.CustomerApp, isNotNull);
  });

  testWidgets('AdminApp widget exists and is a ConsumerStatefulWidget', (tester) async {
    expect(admin.AdminApp, isNotNull);
  });
}