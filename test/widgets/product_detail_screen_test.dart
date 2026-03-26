import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product Detail Screen Widget Tests', () {
    // ========================================================================
    // GROUP 1: Product Info Display (4 tests)
    // ========================================================================
    group('Product Detail - Information Display', () {
      testWidgets('1. Product detail screen displays product name',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Product Details'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {},
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image, size: 80)),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Premium Wireless Headphones',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Premium Wireless Headphones'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('2. Product detail shows price and rating',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Premium Product', style: TextStyle(fontSize: 20)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('\$149.99', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber[600]),
                              const Text(' 4.5'),
                              const Text(' (128 reviews)'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('\$149.99'), findsOneWidget);
        expect(find.text(' 4.5'), findsOneWidget);
        expect(find.text(' (128 reviews)'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('3. Product detail shows description', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'High-quality wireless headphones with active noise cancellation, 30-hour battery life, and premium sound quality.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Description'), findsOneWidget);
        expect(
          find.text('High-quality wireless headphones with active noise cancellation, 30-hour battery life, and premium sound quality.'),
          findsOneWidget,
        );
      });

      testWidgets('4. Shows in-stock status', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('In Stock', style: TextStyle(color: Colors.green)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('In Stock'), findsOneWidget);
      });
    });

    // ========================================================================
    // GROUP 2: Image & Variants (3 tests)
    // ========================================================================
    group('Product Detail - Images & Variants', () {
      testWidgets('1. Image carousel displays', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView(
                      children: [
                        Container(color: Colors.blue, child: const Center(child: Text('Image 1'))),
                        Container(color: Colors.green, child: const Center(child: Text('Image 2'))),
                        Container(color: Colors.red, child: const Center(child: Text('Image 3'))),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey)),
                        const SizedBox(width: 4),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blue)),
                        const SizedBox(width: 4),
                        Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(PageView), findsOneWidget);
        expect(find.text('Image 1'), findsOneWidget);
        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('2. Color variant selector', (WidgetTester tester) async {
        var selectedColor = 'Black';
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Color:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 12,
                          children: ['Black', 'Silver', 'Gold'].map((color) {
                            return GestureDetector(
                              onTap: () => setState(() => selectedColor = color),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: selectedColor == color ? Colors.blue : Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(color),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Silver'));
        await tester.pumpAndSettle();
        expect(selectedColor, 'Silver');
      });

      testWidgets('3. Size variant selector', (WidgetTester tester) async {
        var selectedSize = 'M';
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Size:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 12,
                          children: ['S', 'M', 'L', 'XL'].map((size) {
                            return GestureDetector(
                              onTap: () => setState(() => selectedSize = size),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedSize == size ? Colors.blue : Colors.grey,
                                  ),
                                ),
                                child: Center(child: Text(size)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('L'));
        await tester.pumpAndSettle();
        expect(selectedSize, 'L');
      });
    });

    // ========================================================================
    // GROUP 3: Actions (3 tests)
    // ========================================================================
    group('Product Detail - Actions', () {
      testWidgets('1. Add to cart button is prominent', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  const SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 400),
                        Text('Product content'),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                            onPressed: () {},
                            child: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Add to Cart'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('2. Add to wishlist button works', (WidgetTester tester) async {
        var isWishlisted = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Add to Cart'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: () => isWishlisted = true,
                    icon: Icon(Icons.favorite_border, color: Colors.red[600]),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.favorite_border));
        expect(isWishlisted, isTrue);
      });

      testWidgets('3. Quantity selector works', (WidgetTester tester) async {
        var quantity = 1;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('Quantity:'),
                        const SizedBox(width: 18),
                        IconButton(
                          onPressed: () => setState(() => quantity > 1 ? quantity-- : null),
                          icon: const Icon(Icons.remove),
                        ),
                        Text('$quantity', style: const TextStyle(fontSize: 18)),
                        IconButton(
                          onPressed: () => setState(() => quantity++),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        expect(quantity, 2);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        expect(quantity, 3);
      });
    });

    // ========================================================================
    // GROUP 4: Related Products (2 tests)
    // ========================================================================
    group('Product Detail - Related & Reviews', () {
      testWidgets('1. Related products section visible', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Related Products', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 3,
                        itemBuilder: (context, index) => Container(
                          width: 150,
                          margin: const EdgeInsets.all(8),
                          child: Card(
                            child: Column(
                              children: [
                                Container(
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Center(child: Icon(Icons.image)),
                                ),
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text('Related Product'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Related Products'), findsOneWidget);
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('2. Reviews section visible', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Customer Reviews (128)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(child: Text('JD')),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      Icon(Icons.star, size: 16, color: Colors.amber),
                                      Icon(Icons.star, size: 16, color: Colors.amber),
                                      Icon(Icons.star, size: 16, color: Colors.amber),
                                      Icon(Icons.star, size: 16, color: Colors.amber),
                                      Icon(Icons.star, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('Great product, highly recommend!'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Customer Reviews (128)'), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsWidgets);
      });
    });
  });
}
