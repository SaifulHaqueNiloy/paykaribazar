import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paykari_bazar/main_customer.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Updated to use CustomerApp as per latest DNA alignment
    await tester.pumpWidget(const ProviderScope(child: CustomerApp()));

    // Check if initial loading indicator or home screen is present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
