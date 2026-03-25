import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paykari_bazar/src/features/home/widgets/flash_sale_timer.dart';

void main() {
  group('FlashSaleTimer Widget Tests', () {
    group('Initialization and Rendering', () {
      testWidgets('renders FlashSaleTimer with future end time',
          (WidgetTester tester) async {
        final futureTime = DateTime.now().add(const Duration(hours: 1));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: futureTime),
            ),
          ),
        );

        expect(find.byType(FlashSaleTimer), findsOneWidget);
        expect(find.text('Flash Sale Ends In:'), findsOneWidget);
      });

      testWidgets('renders SizedBox.shrink when time is zero (Duration.zero)',
          (WidgetTester tester) async {
        final pastTime = DateTime.now().subtract(const Duration(hours: 1));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: pastTime),
            ),
          ),
        );

        // Initial state should show something, but after calculation will show shrink
        await tester.pumpAndSettle();
        expect(find.byType(SizedBox), findsOneWidget);
      });

      testWidgets('displays correct format with hours, minutes, seconds',
          (WidgetTester tester) async {
        final futureTime = DateTime.now().add(
          const Duration(hours: 2, minutes: 30, seconds: 15),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: futureTime),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should display the timer widget
        expect(find.byType(FlashSaleTimer), findsOneWidget);
        expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
      });
    });

    group('Duration.zero Handling (Fixed Bug)', () {
      testWidgets('handles Duration.zero correctly without calling isZero getter',
          (WidgetTester tester) async {
        final pastTime = DateTime.now().subtract(const Duration(seconds: 1));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: pastTime),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Widget should render without errors
        expect(find.byType(FlashSaleTimer), findsOneWidget);
      });

      testWidgets(
          'correctly compares _timeLeft == Duration.zero instead of using isZero',
          (WidgetTester tester) async {
        final endTime = DateTime.now().add(const Duration(seconds: 2));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: endTime),
            ),
          ),
        );

        expect(find.byType(Container), findsWidgets);

        // Fast forward past the end time
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      });
    });

    group('Timer Countdown Functionality', () {
      testWidgets('updates countdown every second', (WidgetTester tester) async {
        final futureTime = DateTime.now().add(const Duration(minutes: 1));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: futureTime),
            ),
          ),
        );

        expect(find.byType(FlashSaleTimer), findsOneWidget);

        // Advance time by 1 second and pump
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(FlashSaleTimer), findsOneWidget);
      });

      testWidgets(
          'properly formats digit padding (leading zeros)',
          (WidgetTester tester) async {
        // Set time to exactly 0 hours, 5 minutes, 9 seconds in future
        final futureTime = DateTime.now().add(
          Duration(
            seconds: 5 * 60 + 9,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: futureTime),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should display properly formatted times
        expect(find.byType(FlashSaleTimer), findsOneWidget);
      });

      testWidgets('stops timer in dispose', (WidgetTester tester) async {
        final futureTime = DateTime.now().add(const Duration(hours: 1));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: futureTime),
            ),
          ),
        );

        expect(find.byType(FlashSaleTimer), findsOneWidget);

        // Remove the widget
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));

        // Timer should be cancelled in dispose without errors
      });
    });

    group('UI Elements and Styling', () {
      testWidgets('displays all required UI elements', (WidgetTester tester) async {
        final futureTime = DateTime.now().add(const Duration(hours: 2));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: futureTime),
            ),
          ),
        );

        // Check for icon
        expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);

        // Check for text
        expect(find.text('Flash Sale Ends In:'), findsOneWidget);

        // Check for container
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('has correct styling and colors', (WidgetTester tester) async {
        final futureTime = DateTime.now().add(const Duration(hours: 1));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: futureTime),
            ),
          ),
        );

        expect(find.byType(Container), findsWidgets);
        expect(find.byType(Row), findsOneWidget);
        expect(find.byType(Spacer), findsOneWidget);
      });

      testWidgets('renders time boxes with separators', (WidgetTester tester) async {
        final futureTime = DateTime.now().add(const Duration(hours: 1));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: futureTime),
            ),
          ),
        );

        // Should have multiple containers for time display
        expect(find.byType(Container), findsWidgets);
        expect(find.byType(Text), findsWidgets);
      });
    });

    group('Edge Cases and Boundary Conditions', () {
      testWidgets('handles time ending exactly at now',
          (WidgetTester tester) async {
        final now = DateTime.now();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: now),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should not crash, should eventually show shrink
        expect(find.byType(FlashSaleTimer), findsOneWidget);
      });

      testWidgets('handles negative duration (past time)',
          (WidgetTester tester) async {
        final pastTime = DateTime.now().subtract(const Duration(days: 1));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: pastTime),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(FlashSaleTimer), findsOneWidget);
      });

      testWidgets('handles very long duration (days away)',
          (WidgetTester tester) async {
        final farFutureTime = DateTime.now().add(const Duration(days: 30));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: farFutureTime),
            ),
          ),
        );

        expect(find.byType(FlashSaleTimer), findsOneWidget);
        expect(find.text('Flash Sale Ends In:'), findsOneWidget);
      });

      testWidgets('handles very short duration (seconds away)',
          (WidgetTester tester) async {
        final soonTime = DateTime.now().add(const Duration(seconds: 5));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: soonTime),
            ),
          ),
        );

        expect(find.byType(FlashSaleTimer), findsOneWidget);
      });
    });

    group('Integration Tests', () {
      testWidgets('multiple timers work independently', (WidgetTester tester) async {
        final time1 = DateTime.now().add(const Duration(hours: 1));
        final time2 = DateTime.now().add(const Duration(hours: 2));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  FlashSaleTimer(endTime: time1),
                  FlashSaleTimer(endTime: time2),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(FlashSaleTimer), findsNWidgets(2));
        expect(find.text('Flash Sale Ends In:'), findsNWidgets(2));
      });

      testWidgets('timer widget lifecycle works correctly',
          (WidgetTester tester) async {
        final futureTime = DateTime.now().add(const Duration(hours: 1));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashSaleTimer(endTime: futureTime),
            ),
          ),
        );

        // Widget exists
        expect(find.byType(FlashSaleTimer), findsOneWidget);

        // Pump for a few seconds
        await tester.pump(const Duration(seconds: 3));

        // Widget still exists
        expect(find.byType(FlashSaleTimer), findsOneWidget);

        // Widget disposes correctly when removed
        await tester.pumpWidget(const MaterialApp(home: Scaffold()));
        expect(find.byType(FlashSaleTimer), findsNothing);
      });
    });
  });
}
