/// Test data builders for fluent test data construction
///
/// Provides builder classes for creating complex test data with sensible defaults.
/// Makes test data creation more readable and maintainable.

import 'package:mocktail/mocktail.dart';

/// Builder for creating test data with fluent API
///
/// Example usage:
/// ```dart
/// final user = UserBuilder()
///   .withId('123')
///   .withEmail('test@example.com')
///   .build();
/// ```
abstract class TestDataBuilder<T> {
  /// Build and return the test object
  T build();

  /// Create a copy with modifications
  TestDataBuilder<T> copy();
}

/// Helper function to register fallback values for mocks
///
/// Prevents "No fallback value found" errors in mocktail when dealing with
/// custom types.
///
/// Usage:
/// ```dart
/// registerFallbackValues(
///   User.empty(),
///   Product.empty(),
/// );
/// ```
void registerFallbackValues(List<dynamic> values) {
  for (final value in values) {
    if (value is Mock) {
      registerFallbackValue(value);
    }
  }
}

/// Helper extension for creating mock objects
extension MockBuilder on Object {
  /// Create a mock of this type with fallback value registration
  ///
  /// Usage:
  /// ```dart
  /// final mockUser = User.empty().asMock();
  /// ```
  T asMock<T>() {
    return this as T;
  }
}

/// Factory for common test data instantiation patterns
abstract class TestDataFactory {
  /// Create default/empty test data
  static T createEmpty<T>() {
    throw UnimplementedError('Override in subclass');
  }

  /// Create test data with specific id
  static T createWithId<T>(String id) {
    throw UnimplementedError('Override in subclass');
  }

  /// Create multiple test items
  static List<T> createBatch<T>(int count, {T Function(int)? builder}) {
    return List.generate(
      count,
      (i) => builder?.call(i) ?? createWithId<T>('id-$i'),
    );
  }
}

/// Helper for building list test data
class TestListBuilder<T> {
  final List<T> _items = [];

  /// Add an item to the list
  TestListBuilder<T> add(T item) {
    _items.add(item);
    return this;
  }

  /// Add multiple items to the list
  TestListBuilder<T> addAll(List<T> items) {
    _items.addAll(items);
    return this;
  }

  /// Generate items using a builder function
  TestListBuilder<T> generate(int count, T Function(int) builder) {
    for (int i = 0; i < count; i++) {
      _items.add(builder(i));
    }
    return this;
  }

  /// Get the built list
  List<T> build() => List.unmodifiable(_items);

  /// Get the count of items
  int get length => _items.length;

  /// Clear all items
  TestListBuilder<T> clear() {
    _items.clear();
    return this;
  }
}

/// Helper for building map test data
class TestMapBuilder<K, V> {
  final Map<K, V> _map = {};

  /// Add a key-value pair
  TestMapBuilder<K, V> put(K key, V value) {
    _map[key] = value;
    return this;
  }

  /// Add multiple key-value pairs
  TestMapBuilder<K, V> putAll(Map<K, V> entries) {
    _map.addAll(entries);
    return this;
  }

  /// Get the built map
  Map<K, V> build() => Map.unmodifiable(_map);

  /// Get a value by key
  V? get(K key) => _map[key];

  /// Clear all entries
  TestMapBuilder<K, V> clear() {
    _map.clear();
    return this;
  }
}

/// Assertion helper for common test patterns
class TestAssertions {
  /// Assert list is not empty
  static void assertNonEmpty<T>(List<T> list, [String? reason]) {
    expect(list, isNotEmpty, reason: reason ?? 'List should not be empty');
  }

  /// Assert list has specific length
  static void assertLength<T>(List<T> list, int expected, [String? reason]) {
    expect(list.length, equals(expected),
        reason: reason ?? 'Expected length $expected but got ${list.length}');
  }

  /// Assert map contains key
  static void assertContainsKey<K, V>(Map<K, V> map, K key, [String? reason]) {
    expect(map.containsKey(key), isTrue,
        reason: reason ?? 'Map should contain key $key');
  }

  /// Assert all items in list match condition
  static void assertAll<T>(
    List<T> list,
    bool Function(T) condition, [
    String? reason,
  ]) {
    for (int i = 0; i < list.length; i++) {
      expect(condition(list[i]), isTrue,
          reason: reason ?? 'Item at index $i does not match condition');
    }
  }

  /// Assert at least one item matches condition
  static void assertAny<T>(
    List<T> list,
    bool Function(T) condition, [
    String? reason,
  ]) {
    final found = list.any(condition);
    expect(found, isTrue,
        reason: reason ?? 'No items matched the condition');
  }
}
