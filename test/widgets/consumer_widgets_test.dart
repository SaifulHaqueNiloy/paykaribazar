import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes for testing consumer widgets
class MockCartProvider extends Mock {}

class MockProductProvider extends Mock {}

class MockOrderProvider extends Mock {}

void main() {
  group('Day 5: Advanced Consumer Widget Tests (20+ tests)', () {
    // ========================================================================
    // GROUP 1: ConsumerWidget Basic Tests (3 tests)
    // ========================================================================
    group('ConsumerWidget - Riverpod Integration', () {
      testWidgets('1. ConsumerWidget renders with provider data', (WidgetTester tester) async {
        // Mock provider
        final testProvider = StateProvider<String>((ref) => 'Test Value');

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    final value = ref.watch(testProvider);
                    return Text(value);
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.text('Test Value'), findsOneWidget);
      });

      testWidgets('2. ConsumerStatefulWidget lifecycle', (WidgetTester tester) async {
        var mounted = false;

        final lifecycleProvider = StateProvider<int>((ref) {
          mounted = true;
          return 0;
        });

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    final value = ref.watch(lifecycleProvider);
                    return Text('Value: $value');
                  },
                ),
              ),
            ),
          ),
        );

        expect(mounted, isTrue);
        expect(find.text('Value: 0'), findsOneWidget);
      });

      testWidgets('3. Multiple ConsumerWidgets with same provider', (WidgetTester tester) async {
        final sharedProvider = StateProvider<String>((ref) => 'Shared');

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final value = ref.watch(sharedProvider);
                        return Text('Widget 1: $value');
                      },
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final value = ref.watch(sharedProvider);
                        return Text('Widget 2: $value');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Widget 1: Shared'), findsOneWidget);
        expect(find.text('Widget 2: Shared'), findsOneWidget);
      });
    });

    // ========================================================================
    // GROUP 2: Mock Cart Provider Tests (4 tests)
    // ========================================================================
    group('Mock Cart - Shopping Cart Widgets', () {
      testWidgets('1. CartWidget displays empty cart', (WidgetTester tester) async {
        final mockCart = StateProvider<List<String>>((ref) => []);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    final items = ref.watch(mockCart);
                    return Center(
                      child: items.isEmpty
                          ? const Text('Cart is empty')
                          : ListView(
                              children: items
                                  .map((item) => ListTile(title: Text(item)))
                                  .toList(),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.text('Cart is empty'), findsOneWidget);
      });

      testWidgets('2. CartWidget displays items', (WidgetTester tester) async {
        final mockCart = StateProvider<List<String>>((ref) => ['Item 1', 'Item 2', 'Item 3']);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    final items = ref.watch(mockCart);
                    return ListView(
                      children: items
                          .map((item) => ListTile(title: Text(item)))
                          .toList(),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
        expect(find.text('Item 3'), findsOneWidget);
      });

      testWidgets('3. CartWidget add item button', (WidgetTester tester) async {
        final mockCart = StateProvider<List<String>>((ref) => []);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final items = ref.watch(mockCart);
                        return Text('${items.length} items');
                      },
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        return ElevatedButton(
                          onPressed: () {
                            ref.read(mockCart.notifier).state = [...ref.read(mockCart), 'New Item'];
                          },
                          child: const Text('Add Item'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('0 items'), findsOneWidget);
        await tester.tap(find.text('Add Item'));
        await tester.pumpAndSettle();
        expect(find.text('1 items'), findsOneWidget);
      });

      testWidgets('4. CartWidget remove item button', (WidgetTester tester) async {
        final mockCart = StateProvider<List<String>>((ref) => ['Item 1', 'Item 2']);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, child) {
                    final items = ref.watch(mockCart);
                    return ListView(
                      children: items.asMap().entries.map((entry) {
                        return ListTile(
                          title: Text(entry.value),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              final updated = [...items];
                              updated.removeAt(entry.key);
                              ref.read(mockCart.notifier).state = updated;
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.text('Item 1'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.delete).first);
        await tester.pumpAndSettle();
        expect(find.text('Item 1'), findsNothing);
      });
    });

    // ========================================================================
    // GROUP 3: Product Display Tests (4 tests)
    // ========================================================================
    group('Product Display - Product List & Details', () {
      testWidgets('1. ProductCard renders with image and price', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Card(
                child: Column(
                  children: [
                    Container(
                      color: Colors.blue,
                      height: 200,
                      child: const Center(child: Text('Product Image')),
                    ),
                    const ListTile(
                      title: Text('Product Name'),
                      subtitle: Text('\$99.99'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Product Image'), findsOneWidget);
        expect(find.text('Product Name'), findsOneWidget);
        expect(find.text('\$99.99'), findsOneWidget);
      });

      testWidgets('2. ProductCard with favorite button', (WidgetTester tester) async {
        var isFavorite = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Product'),
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                            ),
                            onPressed: () => isFavorite = !isFavorite,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        await tester.tap(find.byIcon(Icons.favorite_border));
        expect(isFavorite, isTrue);
      });

      testWidgets('3. Product filter chips', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text('All')),
                  Chip(label: Text('Electronics')),
                  Chip(label: Text('Clothing')),
                  Chip(label: Text('Books')),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(Chip), findsWidgets);
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Electronics'), findsOneWidget);
      });

      testWidgets('4. Product list grid view', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(color: Colors.grey),
                      ),
                      Text('Product ${index + 1}'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Card), findsWidgets);
        expect(find.text('Product 1'), findsOneWidget);
      });
    });

    // ========================================================================
    // GROUP 4: Order Display Tests (3 tests)
    // ========================================================================
    group('Order Display - Order Screen', () {
      testWidgets('1. OrderCard displays order details', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order #12345'),
                          Chip(label: Text('Delivered')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Items: 3'),
                      const SizedBox(height: 8),
                      const Text('Total: \$199.99'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(onPressed: () {}, child: const Text('Track')),
                          const SizedBox(width: 8),
                          ElevatedButton(onPressed: () {}, child: const Text('Details')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Order #12345'), findsOneWidget);
        expect(find.text('Delivered'), findsOneWidget);
        expect(find.text('Items: 3'), findsOneWidget);
        expect(find.text('Total: \$199.99'), findsOneWidget);
      });

      testWidgets('2. OrdersList renders multiple orders', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text('Order #${1000 + index}'),
                    subtitle: const Text('Pending'),
                    trailing: const Icon(Icons.arrow_forward),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(Card), findsWidgets);
        expect(find.text('Order #1000'), findsOneWidget);
        expect(find.text('Order #1001'), findsOneWidget);
      });

      testWidgets('3. OrdersScreen empty state', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text('No Orders'),
                    SizedBox(height: 8),
                    Text('You haven\'t placed any orders yet'),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
        expect(find.text('No Orders'), findsOneWidget);
      });
    });

    // ========================================================================
    // GROUP 5: Input & Checkout Tests (3 tests)
    // ========================================================================
    group('Checkout - Payment & Address Forms', () {
      testWidgets('1. Address selection dropdown', (WidgetTester tester) async {
        var selectedAddress = 'Home';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DropdownButton<String>(
                value: selectedAddress,
                items: ['Home', 'Work', 'Other'].map((addr) {
                  return DropdownMenuItem<String>(
                    value: addr,
                    child: Text(addr),
                  );
                }).toList(),
                onChanged: (value) => selectedAddress = value!,
              ),
            ),
          ),
        );

        expect(find.text('Home'), findsOneWidget);
      });

      testWidgets('2. Payment method selection', (WidgetTester tester) async {
        // const selectedPayment = 'Credit Card';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ListTile(title: Text('Credit Card')),
                  ListTile(title: Text('Debit Card')),
                  ListTile(title: Text('Paypal')),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(ListTile), findsWidgets);
        expect(find.text('Credit Card'), findsOneWidget);
        expect(find.text('Paypal'), findsOneWidget);
      });

      testWidgets('3. Checkout summary display', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const ListTile(
                      title: Text('Subtotal'),
                      trailing: Text('\$150.00'),
                    ),
                    const ListTile(
                      title: Text('Tax'),
                      trailing: Text('\$15.00'),
                    ),
                    const ListTile(
                      title: Text('Shipping'),
                      trailing: Text('\$5.00'),
                    ),
                    const Divider(),
                    const ListTile(
                      title: Text('Total'),
                      trailing: Text('\$170.00'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Place Order'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Subtotal'), findsOneWidget);
        expect(find.text('\$150.00'), findsOneWidget);
        expect(find.text('Total'), findsOneWidget);
        expect(find.text('\$170.00'), findsOneWidget);
        expect(find.text('Place Order'), findsOneWidget);
      });
    });

    // ========================================================================
    // GROUP 6: Profile & Settings Tests (3 tests)
    // ========================================================================
    group('Profile & Settings - User Account', () {
      testWidgets('1. Profile header with user info', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Container(color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  const Text('John Doe'),
                  const Text('john@example.com'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('john@example.com'), findsOneWidget);
        expect(find.text('Edit Profile'), findsOneWidget);
      });

      testWidgets('2. Profile settings menu', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Personal Info'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text('Addresses'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Security'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.byIcon(Icons.location_on), findsOneWidget);
        expect(find.byIcon(Icons.security), findsOneWidget);
        expect(find.byIcon(Icons.logout), findsOneWidget);
      });

      testWidgets('3. Profile edit form', (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => formKey.currentState!.validate(),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsWidgets);
        expect(find.text('Save Changes'), findsOneWidget);
      });
    });
  });
}
