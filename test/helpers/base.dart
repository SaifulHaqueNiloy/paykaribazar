/// Core test base class and fundamental test infrastructure
///
/// Provides the basic test setup with ProviderContainer management.
/// This is the foundation for all other test base classes.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Create a test ProviderContainer with optional overrides
ProviderContainer createTestProviderContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(overrides: overrides);
}

/// Base test class for unit/service tests
///
/// Handles ProviderContainer setup and teardown, making it easy to test
/// Riverpod-based code without needing a full widget tree.
///
/// Usage:
/// ```dart
/// class MyServiceTest extends BaseTest {
///   @override
///   List<Override> get providerOverrides => [
///     myServiceProvider.overrideWithValue(mockService),
///   ];
///
///   void test('service works', () {
///     final result = read(myServiceProvider);
///     expect(result, equals(expected));
///   });
/// }
/// ```
abstract class BaseTest {
  late ProviderContainer container;

  /// Override this to provide custom provider overrides
  List<Override> get providerOverrides => [];

  void setUp() {
    container = createTestProviderContainer(overrides: providerOverrides);
    _baseBefore();
  }

  void tearDown() {
    _baseAfter();
  }

  void _baseBefore() {
    // Initialize any global state
  }

  void _baseAfter() {
    // Clean up any test state
    container.dispose();
  }

  /// Helper to read a provider value
  T read<T>(ProviderListenable<T> provider) {
    return container.read(provider);
  }
}
