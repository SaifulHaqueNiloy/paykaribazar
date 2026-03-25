/// test/helpers/test_setup.dart
/// Centralized test setup and initialization for all tests
///
/// Provides:
/// - Hive initialization and cleanup
/// - Firebase mock setup
/// - Common test utilities
/// - Provider container setup

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

/// Initialize Hive for testing
Future<void> setupHiveForTesting() async {
  final path = Directory.systemTemp.path;
  Hive.init(path);
  
  // Add any custom box adapters here if needed
  // Example: Hive.registerAdapter(UserAdapter());
}

/// Clean up Hive after tests
Future<void> tearDownHiveForTesting() async {
  await Hive.deleteFromDisk();
}

/// Create a test ProviderContainer with optional overrides
ProviderContainer createTestProviderContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(overrides: overrides);
}

/// Base test class for unit/service tests
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

/// Base test class specifically for Firebase/Hive dependent tests
abstract class BaseFirebaseTest extends BaseTest {
  @override
  void setUp() {
    super.setUp();
    // Firebase-specific setup if needed
  }

  @override
  void tearDown() {
    super.tearDown();
    // Firebase-specific cleanup if needed
  }
}

/// Base test class for snapshot-based tests
abstract class BaseSnapshotTest extends BaseTest {
  /// Wait for async operations to complete
  Future<void> pumpAsync() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Verify loading state
  void expectLoading(AsyncValue state) {
    expect(state, isA<AsyncLoading>());
  }

  /// Verify error state
  void expectError(AsyncValue state) {
    expect(state, isA<AsyncError>());
  }

  /// Verify data state
  void expectData<T>(AsyncValue state, T expectedData) {
    expect(state, isA<AsyncData<T>>());
    expect((state as AsyncData<T>).value, equals(expectedData));
  }
}

/// Extension for cleaner mock verification syntax
extension MockVerification on void Function() {
  void verifyCalledOnce() {
    // For use with mocktail
  }
}

/// Common mock functions setup
void setupFallbackValue<T>(T value) {
  // Register fallback values for common types
  // This prevents 'No fallback value found' errors in mocktail
  registerFallbackValue(value);
}

/// Fixture: Represents test data
abstract class Fixture {
  /// Generic fixture factory
  static T create<T>({required T Function() builder}) {
    return builder();
  }
}
