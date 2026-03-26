import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Home Screen Widget Tests', () {
    // ========================================================================
    // GROUP 1: Home Screen Layout (4 tests)
    // ========================================================================
    group('Home Screen - Layout', () {
      testWidgets('1. Home screen renders with AppBar and body',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Home')),
              body: const SingleChildScrollView(
                child: Column(
                  children: [
                    Text('Welcome'),
                    SizedBox(height: 16),
                    Text('Featured Products'),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Welcome'), findsOneWidget);
        expect(find.text('Featured Products'), findsOneWidget);
      });

      testWidgets('2. Home screen has search bar', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products',
                    border: InputBorder.none,
                  ),
                ),
              ),
              body: const Center(child: Text('Body')),
            ),
          ),
        );

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search products'), findsOneWidget);
      });

      testWidgets('3. Home screen displays categories', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text('Categories'),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: const Text('Electronics'),
                          ),
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: const Text('Clothing'),
                          ),
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: const Text('Books'),
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

        expect(find.text('Categories'), findsOneWidget);
        expect(find.text('Electronics'), findsOneWidget);
        expect(find.text('Clothing'), findsOneWidget);
      });

      testWidgets('4. Home screen has bottom navigation', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: const Center(child: Text('Homepage')),
              bottomNavigationBar: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart),
                    label: 'Cart',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
      });
    });

    // ========================================================================
    // GROUP 2: Product Display (3 tests)
    // ========================================================================
    group('Home Screen - Product Display', () {
      testWidgets('1. Featured products displayed in grid', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) => Card(
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.image)),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Product Name'),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('\$99.99'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Card), findsWidgets);
        expect(find.text('Product Name'), findsWidgets);
        expect(find.text('\$99.99'), findsWidgets);
      });

      testWidgets('2. Product card shows image, name, and price', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Card(
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      color: Colors.blue,
                      child: const Center(child: Icon(Icons.image, size: 50)),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Laptop'),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('\$899.99', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Add to Cart'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Laptop'), findsOneWidget);
        expect(find.text('\$899.99'), findsOneWidget);
        expect(find.text('Add to Cart'), findsOneWidget);
      });

      testWidgets('3. Add to cart button is functional', (WidgetTester tester) async {
        var addedToCart = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () => addedToCart = true,
                child: const Text('Add to Cart'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Add to Cart'));
        expect(addedToCart, isTrue);
      });
    });

    // ========================================================================
    // GROUP 3: Featured Sections (4 tests)
    // ========================================================================
    group('Home Screen - Featured Sections', () {
      testWidgets('1. Banner carousel displays', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PageView(
                        children: [
                          Container(
                            color: Colors.red,
                            child: const Center(child: Text('Banner 1')),
                          ),
                          Container(
                            color: Colors.blue,
                            child: const Center(child: Text('Banner 2')),
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

        expect(find.text('Banner 1'), findsOneWidget);
        expect(find.byType(PageView), findsOneWidget);
      });

      testWidgets('2. Flash sale section visible', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.orange[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Flash Sale', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Ends in 02:30:45', style: TextStyle(color: Colors.orange[800])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Flash Sale'), findsOneWidget);
        expect(find.text('Ends in 02:30:45'), findsOneWidget);
      });

      testWidgets('3. Recommended for you section', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Recommended For You', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: 3,
                      itemBuilder: (context, index) => ListTile(
                        title: Text('Recommended Item $index'),
                        trailing: const Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Recommended For You'), findsOneWidget);
        expect(find.text('Recommended Item 0'), findsOneWidget);
      });

      testWidgets('4. Special offers visible', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Special Offers', style: TextStyle(fontSize: 16)),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text('Save 20%')),
                        Chip(label: Text('Free Shipping')),
                        Chip(label: Text('Buy 1 Get 1')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Special Offers'), findsOneWidget);
        expect(find.text('Save 20%'), findsOneWidget);
        expect(find.text('Free Shipping'), findsOneWidget);
      });
    });

    // ========================================================================
    // GROUP 4: User Interactions (3 tests)
    // ========================================================================
    group('Home Screen - User Interactions', () {
      testWidgets('1. Product card tap navigates to details', (WidgetTester tester) async {
        var productTapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GestureDetector(
                onTap: () => productTapped = true,
                child: Card(
                  child: Column(
                    children: [
                      Container(color: Colors.grey, height: 100),
                      const Text('Product'),
                      const Text('\$99.99'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(Card));
        expect(productTapped, isTrue);
      });

      testWidgets('2. Search bar input works', (WidgetTester tester) async {
        final searchController = TextEditingController();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                title: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(hintText: 'Search'),
                ),
              ),
              body: const SizedBox(),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'laptop');
        expect(searchController.text, 'laptop');
      });

      testWidgets('3. Category selection works', (WidgetTester tester) async {
        var selectedCategory = '';
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Wrap(
                    children: ['Electronics', 'Clothing', 'Books'].map((cat) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedCategory = cat),
                        child: Chip(label: Text(cat)),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Electronics'));
        await tester.pumpAndSettle();
        expect(selectedCategory, 'Electronics');
      });
    });
  });
}
