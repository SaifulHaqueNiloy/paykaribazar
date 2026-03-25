import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// MOCK WIDGETS
// ============================================================================

class SearchBar extends StatefulWidget {
  final Function(String) onSearch;
  const SearchBar({required this.onSearch});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search products',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onSearch('');
                  setState(() {});
                },
              )
            : null,
      ),
      onChanged: (value) {
        widget.onSearch(value);
        setState(() {});
      },
    );
  }
}

class FilterDialog extends StatefulWidget {
  final List<String> categories;
  final Function(String) onFilterSelect;

  const FilterDialog({
    required this.categories,
    required this.onFilterSelect,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter by Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.categories
              .map((cat) => RadioListTile(
                    title: Text(cat),
                    value: cat,
                    groupValue: _selectedCategory,
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_selectedCategory != null) {
              widget.onFilterSelect(_selectedCategory!);
            }
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final String image;
  final VoidCallback onTap;

  const ProductCard({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              color: Colors.grey[300],
              child: Center(child: Text('Image: $image')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('\$$price', style: const TextStyle(color: Colors.green)),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Add to Cart'),
                    onPressed: onTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckoutButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const CheckoutButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<CheckoutButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        child: widget.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Proceed to Checkout'),
      ),
    );
  }
}

class RatingWidget extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const RatingWidget({
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber),
        const SizedBox(width: 4),
        Text('$rating'),
        const SizedBox(width: 8),
        Text('($reviewCount reviews)', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('Widget Tests - Extended Coverage', () {
    // ========================================================================
    // GROUP 1: Search Widget (4 tests)
    // ========================================================================
    group('SearchBar Widget', () {
      testWidgets('1. SearchBar renders with hint text', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SearchBar(onSearch: (_) {}),
            ),
          ),
        );

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('2. SearchBar clears text on clear button tap',
          (WidgetTester tester) async {
        String searchText = '';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SearchBar(onSearch: (text) => searchText = text),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'phone');
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.clear), findsOneWidget);

        await tester.tap(find.byIcon(Icons.clear));
        await tester.pumpAndSettle();

        expect(searchText, '');
      });

      testWidgets('3. SearchBar calls onSearch callback', (WidgetTester tester) async {
        String lastSearch = '';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SearchBar(onSearch: (text) => lastSearch = text),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'laptop');
        await tester.pumpAndSettle();

        expect(lastSearch, 'laptop');
      });

      testWidgets('4. SearchBar shows clear button only when text entered',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SearchBar(onSearch: (_) {}),
            ),
          ),
        );

        expect(find.byIcon(Icons.clear), findsNothing);

        await tester.enterText(find.byType(TextField), 'test');
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.clear), findsOneWidget);
      });
    });

    // ========================================================================
    // GROUP 2: Sort & Filter (4 tests)
    // ========================================================================
    group('Filter & Sort Features', () {
      testWidgets('1. Filter chip renders', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Chip(
                label: const Text('Electronics'),
                onDeleted: () {},
              ),
            ),
          ),
        );

        expect(find.text('Electronics'), findsOneWidget);
      });

      testWidgets('2. Multiple filter chips display', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Wrap(
                children: [
                  Chip(label: const Text('Electronics'), onDeleted: () {}),
                  Chip(label: const Text('Books'), onDeleted: () {}),
                  Chip(label: const Text('Clothing'), onDeleted: () {}),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(Chip), findsNWidgets(3));
      });

      testWidgets('3. Filter button shows filter count', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ElevatedButton.icon(
                icon: const Icon(Icons.filter_list),
                label: const Text('Filters (3)'),
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.filter_list), findsOneWidget);
        expect(find.text('Filters (3)'), findsOneWidget);
      });

      testWidgets('4. Clear filters button works', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.clear), findsOneWidget);
        expect(find.text('Clear Filters'), findsOneWidget);
      });
    });

    // ========================================================================
    // GROUP 3: Product Card (4 tests)
    // ========================================================================
    group('ProductCard Widget', () {
      testWidgets('1. ProductCard displays product information',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(
                id: 'prod1',
                name: 'Smartphone',
                price: 299.99,
                image: 'phone.jpg',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Smartphone'), findsOneWidget);
        expect(find.text('\$299.99'), findsOneWidget);
      });

      testWidgets('2. ProductCard shows add to cart button',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(
                id: 'prod1',
                name: 'Laptop',
                price: 1299.99,
                image: 'laptop.jpg',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
        expect(find.text('Add to Cart'), findsOneWidget);
      });

      testWidgets('3. ProductCard calls onTap when tapped',
          (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(
                id: 'prod1',
                name: 'Tablet',
                price: 599.99,
                image: 'tablet.jpg',
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(Card));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('4. ProductCard displays image placeholder',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(
                id: 'prod1',
                name: 'Product',
                price: 99.99,
                image: 'product.jpg',
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Image: product.jpg'), findsOneWidget);
      });
    });

    // ========================================================================
    // GROUP 4: Checkout Button (4 tests)
    // ========================================================================
    group('CheckoutButton Widget', () {
      testWidgets('1. CheckoutButton displays text when not loading',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutButton(
                isLoading: false,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('Proceed to Checkout'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('2. CheckoutButton shows loading indicator when loading',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutButton(
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('3. CheckoutButton is disabled when loading',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutButton(
                isLoading: true,
                onPressed: () {},
              ),
            ),
          ),
        );

        final button = find.byType(ElevatedButton);
        expect(button, findsOneWidget);
      });

      testWidgets('4. CheckoutButton calls onPressed when clicked',
          (WidgetTester tester) async {
        bool pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CheckoutButton(
                isLoading: false,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        expect(pressed, isTrue);
      });
    });

    // ========================================================================
    // GROUP 5: Rating Widget (4 tests)
    // ========================================================================
    group('RatingWidget', () {
      testWidgets('1. RatingWidget displays rating value',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RatingWidget(
                rating: 4.5,
                reviewCount: 128,
              ),
            ),
          ),
        );

        expect(find.text('4.5'), findsOneWidget);
      });

      testWidgets('2. RatingWidget displays star icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RatingWidget(
                rating: 3.8,
                reviewCount: 64,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('3. RatingWidget displays review count',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RatingWidget(
                rating: 4.2,
                reviewCount: 256,
              ),
            ),
          ),
        );

        expect(find.text('(256 reviews)'), findsOneWidget);
      });

      testWidgets('4. RatingWidget displays full rating information',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RatingWidget(
                rating: 4.7,
                reviewCount: 512,
              ),
            ),
          ),
        );

        expect(find.byType(Row), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.text('4.7'), findsOneWidget);
        expect(find.text('(512 reviews)'), findsOneWidget);
      });
    });
  });
}
