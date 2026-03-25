import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock Cart Item Model
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}

// Mock Cart State Notifier
class CartStateNotifier extends StateNotifier<List<CartItem>> {
  CartStateNotifier() : super([]);

  void addItem(CartItem item) {
    final index = state.indexWhere((element) => element.id == item.id);
    if (index >= 0) {
      final updatedItem = state[index].copyWith(
        quantity: state[index].quantity + item.quantity,
      );
      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, item];
    }
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void updateQuantity(String id, int quantity) {
    final index = state.indexWhere((element) => element.id == id);
    if (index >= 0) {
      if (quantity <= 0) {
        removeItem(id);
      } else {
        final updatedItem = state[index].copyWith(quantity: quantity);
        state = [
          ...state.sublist(0, index),
          updatedItem,
          ...state.sublist(index + 1),
        ];
      }
    }
  }

  void clearCart() {
    state = [];
  }

  double getTotalPrice() {
    return state.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  int getTotalItems() {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }
}

// Mock provider
final cartProvider = StateNotifierProvider<CartStateNotifier, List<CartItem>>((ref) {
  return CartStateNotifier();
});

final cartTotalPriceProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + (item.price * item.quantity));
});

final cartTotalItemsProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

void main() {
  group('Cart Provider Tests', () {
    // ========================================================================
    // GROUP 1: Add to Cart (4 tests)
    // ========================================================================
    group('Cart - Add to Cart', () {
      test('1. Add single item to empty cart', () async {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        expect(container.read(cartProvider), isEmpty);

        final item = CartItem(id: '1', name: 'Laptop', price: 999.99, quantity: 1);
        cartNotifier.addItem(item);

        expect(container.read(cartProvider), isNotEmpty);
        expect(container.read(cartProvider).length, 1);
        expect(container.read(cartProvider)[0].name, 'Laptop');
      });

      test('2. Add duplicate items increases quantity', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        final item1 = CartItem(id: '1', name: 'Mouse', price: 29.99, quantity: 1);
        cartNotifier.addItem(item1);
        expect(container.read(cartProvider).length, 1);

        final item2 = CartItem(id: '1', name: 'Mouse', price: 29.99, quantity: 2);
        cartNotifier.addItem(item2);

        expect(container.read(cartProvider).length, 1);
        expect(container.read(cartProvider)[0].quantity, 3);
      });

      test('3. Add multiple different items', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        final item1 = CartItem(id: '1', name: 'Keyboard', price: 79.99, quantity: 1);
        final item2 = CartItem(id: '2', name: 'Mouse', price: 29.99, quantity: 1);
        final item3 = CartItem(id: '3', name: 'Monitor', price: 299.99, quantity: 1);

        cartNotifier.addItem(item1);
        cartNotifier.addItem(item2);
        cartNotifier.addItem(item3);

        expect(container.read(cartProvider).length, 3);
      });

      test('4. Add item with quantity > 1', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        final item = CartItem(id: '1', name: 'Book', price: 15.99, quantity: 5);
        cartNotifier.addItem(item);

        expect(container.read(cartProvider)[0].quantity, 5);
        expect(container.read(cartTotalItemsProvider), 5);
      });
    });

    // ========================================================================
    // GROUP 2: Remove from Cart (3 tests)
    // ========================================================================
    group('Cart - Remove from Cart', () {
      test('1. Remove item from cart', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        final item1 = CartItem(id: '1', name: 'Item1', price: 10.0, quantity: 1);
        final item2 = CartItem(id: '2', name: 'Item2', price: 20.0, quantity: 1);

        cartNotifier.addItem(item1);
        cartNotifier.addItem(item2);
        expect(container.read(cartProvider).length, 2);

        cartNotifier.removeItem('1');
        expect(container.read(cartProvider).length, 1);
        expect(container.read(cartProvider)[0].name, 'Item2');
      });

      test('2. Remove non-existent item does nothing', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        final item = CartItem(id: '1', name: 'Item', price: 10.0, quantity: 1);
        cartNotifier.addItem(item);

        cartNotifier.removeItem('999');
        expect(container.read(cartProvider).length, 1);
      });

      test('3. Remove all items one by one', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        final item1 = CartItem(id: '1', name: 'Item1', price: 10.0, quantity: 1);
        final item2 = CartItem(id: '2', name: 'Item2', price: 20.0, quantity: 1);

        cartNotifier.addItem(item1);
        cartNotifier.addItem(item2);

        cartNotifier.removeItem('1');
        cartNotifier.removeItem('2');
        expect(container.read(cartProvider), isEmpty);
      });
    });

    // ========================================================================
    // GROUP 3: Cart Calculations (5 tests)
    // ========================================================================
    group('Cart - Calculations', () {
      test('1. Calculate total price correctly', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        final item1 = CartItem(id: '1', name: 'Item1', price: 10.0, quantity: 2);
        final item2 = CartItem(id: '2', name: 'Item2', price: 20.0, quantity: 3);

        cartNotifier.addItem(item1);
        cartNotifier.addItem(item2);

        final total = container.read(cartTotalPriceProvider);
        expect(total, 80.0); // (10 * 2) + (20 * 3)
      });

      test('2. Calculate total items', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        final item1 = CartItem(id: '1', name: 'Item1', price: 10.0, quantity: 2);
        final item2 = CartItem(id: '2', name: 'Item2', price: 20.0, quantity: 3);

        cartNotifier.addItem(item1);
        cartNotifier.addItem(item2);

        final total = container.read(cartTotalItemsProvider);
        expect(total, 5);
      });

      test('3. Total is zero for empty cart', () {
        final container = ProviderContainer();

        expect(container.read(cartTotalPriceProvider), 0.0);
        expect(container.read(cartTotalItemsProvider), 0);
      });

      test('4. Update total after quantity change', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        final item = CartItem(id: '1', name: 'Item', price: 50.0, quantity: 2);
        cartNotifier.addItem(item);
        expect(container.read(cartTotalPriceProvider), 100.0);

        cartNotifier.updateQuantity('1', 5);
        expect(container.read(cartTotalPriceProvider), 250.0);
      });

      test('5. Total updates after item removal', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        final item1 = CartItem(id: '1', name: 'Item1', price: 30.0, quantity: 1);
        final item2 = CartItem(id: '2', name: 'Item2', price: 70.0, quantity: 1);

        cartNotifier.addItem(item1);
        cartNotifier.addItem(item2);
        expect(container.read(cartTotalPriceProvider), 100.0);

        cartNotifier.removeItem('2');
        expect(container.read(cartTotalPriceProvider), 30.0);
      });
    });

    // ========================================================================
    // GROUP 4: Cart Management (3 tests)
    // ========================================================================
    group('Cart - Management', () {
      test('1. Update item quantity', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        final item = CartItem(id: '1', name: 'Item', price: 10.0, quantity: 1);
        cartNotifier.addItem(item);

        cartNotifier.updateQuantity('1', 5);
        expect(container.read(cartProvider)[0].quantity, 5);
      });

      test('2. Clear entire cart', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        final item1 = CartItem(id: '1', name: 'Item1', price: 10.0, quantity: 1);
        final item2 = CartItem(id: '2', name: 'Item2', price: 20.0, quantity: 1);

        cartNotifier.addItem(item1);
        cartNotifier.addItem(item2);
        expect(container.read(cartProvider).length, 2);

        cartNotifier.clearCart();
        expect(container.read(cartProvider), isEmpty);
      });

      test('3. Quantity of 0 removes item', () {
        final container = ProviderContainer();
        final cartNotifier = container.read(cartProvider.notifier);

        final item = CartItem(id: '1', name: 'Item', price: 10.0, quantity: 1);
        cartNotifier.addItem(item);

        cartNotifier.updateQuantity('1', 0);
        expect(container.read(cartProvider), isEmpty);
      });
    });
  });
}
