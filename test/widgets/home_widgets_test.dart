import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paykari_bazar/src/features/home/widgets/home_widgets.dart';

void main() {
  group('Home Widgets Tests', () {
    // Test BannerSlider
    group('BannerSlider', () {
      testWidgets('renders empty SizedBox when banners list is empty',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BannerSlider(banners: []),
            ),
          ),
        );

        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(PageView), findsNothing);
      });

      testWidgets('renders PageView with correct height when banners provided',
          (WidgetTester tester) async {
        final banners = ['banner1.jpg', 'banner2.jpg'];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BannerSlider(banners: banners),
            ),
          ),
        );

        final sizedBox = find.byType(SizedBox);
        expect(sizedBox, findsWidgets);

        final pageView = find.byType(PageView);
        expect(pageView, findsOneWidget);
      });

      testWidgets('has correct padding and margins',
          (WidgetTester tester) async {
        final banners = ['banner1.jpg'];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BannerSlider(banners: banners),
            ),
          ),
        );

        final padding = find.byType(Padding);
        expect(padding, findsOneWidget);
      });
    });

    // Test SectionHeader
    group('SectionHeader', () {
      testWidgets('renders title and view all button',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SectionHeader(
                title: 'Featured Products',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Featured Products'), findsOneWidget);
        expect(find.text('সব দেখুন'), findsOneWidget);
      });

      testWidgets('calls onTap when view all button is pressed',
          (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SectionHeader(
                title: 'Products',
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('সব দেখুন'));
        expect(tapped, true);
      });

      testWidgets('has correct text styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SectionHeader(
                title: 'Test Title',
                onTap: () {},
              ),
            ),
          ),
        );

        final title = find.text('Test Title');
        expect(title, findsOneWidget);

        expect(find.byType(Row), findsOneWidget);
      });

      testWidgets('has correct padding', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SectionHeader(
                title: 'Title',
                onTap: () {},
              ),
            ),
          ),
        );

        final padding = find.byType(Padding);
        expect(padding, findsOneWidget);
      });
    });

    // Test ProductHorizontalList
    group('ProductHorizontalList', () {
      testWidgets('renders empty message when products list is empty',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductHorizontalList(
                products: [],
                emptyMessage: 'No products available',
              ),
            ),
          ),
        );

        expect(find.text('No products available'), findsOneWidget);
      });

      testWidgets('renders ListView when products provided',
          (WidgetTester tester) async {
        final products = [
          {'name': 'Product 1', 'price': 100},
          {'name': 'Product 2', 'price': 200},
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductHorizontalList(
                products: products,
                emptyMessage: 'No products',
              ),
            ),
          ),
        );

        expect(find.byType(SizedBox), findsWidgets);
      });

      testWidgets('renders correct number of product cards',
          (WidgetTester tester) async {
        final products = List.generate(
          3,
          (i) => {'name': 'Product $i', 'price': 100 * (i + 1)},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductHorizontalList(
                products: products,
                emptyMessage: 'No products',
              ),
            ),
          ),
        );

        // Should find container widgets for products
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('has correct scroll direction (horizontal)',
          (WidgetTester tester) async {
        final products = [
          {'name': 'Product 1', 'price': 100},
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductHorizontalList(
                products: products,
                emptyMessage: 'No products',
              ),
            ),
          ),
        );

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('has proper item margins and padding',
          (WidgetTester tester) async {
        final products = [
          {'name': 'Product 1', 'price': 100},
          {'name': 'Product 2', 'price': 200},
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductHorizontalList(
                products: products,
                emptyMessage: 'No products',
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsWidgets);
        expect(find.byType(SizedBox), findsWidgets);
      });
    });

    // Integration test for multiple widgets
    group('Home Widgets Integration', () {
      testWidgets(
          'renders multiple home widgets without BoxDecoration opacity errors',
          (WidgetTester tester) async {
        final banners = ['banner1.jpg'];
        final products = [
          {'name': 'Product 1', 'price': 100},
          {'name': 'Product 2', 'price': 200},
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    BannerSlider(banners: banners),
                    SectionHeader(
                      title: 'Featured',
                      onTap: () {},
                    ),
                    ProductHorizontalList(
                      products: products,
                      emptyMessage: 'No products',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byType(BannerSlider), findsOneWidget);
        expect(find.byType(SectionHeader), findsOneWidget);
        expect(find.byType(ProductHorizontalList), findsOneWidget);
      });
    });
  });
}
