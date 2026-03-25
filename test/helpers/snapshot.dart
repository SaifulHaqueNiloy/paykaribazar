/// Snapshot and async-based test utilities
///
/// Provides utilities for testing async operations and AsyncValue states
/// from Riverpod's AsyncValue pattern.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base.dart';

/// Base test class for snapshot-based tests
///
/// Specialized for testing async operations and state transitions.
/// Handles AsyncValue states (loading, data, error) and async timing.
///
/// Usage:
/// ```dart
/// class MyAsyncServiceTest extends BaseSnapshotTest {
///   void test('async operation completes', () async {
///     final state = read(asyncServiceProvider);
///     expectLoading(state);
///
///     await pumpAsync();
///
///     final newState = read(asyncServiceProvider);
///     expectData(newState, expectedValue);
///   });
/// }
/// ```
abstract class BaseSnapshotTest extends BaseTest {
  /// Wait for async operations to complete
  ///
  /// Simulates async operation completion with a small delay.
  /// Useful when testing Future-based providers that need time to resolve.
  Future<void> pumpAsync({Duration delay = const Duration(milliseconds: 100)}) async {
    await Future.delayed(delay);
  }

  /// Verify loading state
  ///
  /// Asserts that the given AsyncValue is in the loading state.
  void expectLoading(AsyncValue state) {
    expect(state, isA<AsyncLoading>());
  }

  /// Verify error state
  ///
  /// Asserts that the given AsyncValue is in the error state.
  void expectError(AsyncValue state) {
    expect(state, isA<AsyncError>());
  }

  /// Verify data state and value
  ///
  /// Asserts that the given AsyncValue contains data and matches the expected value.
  void expectData<T>(AsyncValue state, dynamic expectedData) {
    expect(state, isA<AsyncData<T>>());
    expect((state as AsyncData<T>).value, equals(expectedData));
  }

  /// Verify data state only (without checking value)
  ///
  /// Useful when you want to verify the state is resolved but don't care about the exact value.
  void expectHasData(AsyncValue state) {
    expect(state, isA<AsyncData>());
  }

  /// Verify data state and validate with custom matcher
  ///
  /// Allows custom validation of the resolved data.
  void expectDataMatches<T>(AsyncValue state, Matcher matcher) {
    expect(state, isA<AsyncData<T>>());
    expect((state as AsyncData<T>).value, matcher);
  }

  /// Extract value from AsyncData state
  ///
  /// Safely extracts the data value from an AsyncData state.
  /// Throws if the state is not AsyncData.
  T getDataValue<T>(AsyncValue state) {
    if (state is! AsyncData<T>) {
      throw StateError('Expected AsyncData<$T> but got $state');
    }
    return (state as AsyncData<T>).value;
  }

  /// Extract error from AsyncError state
  ///
  /// Safely extracts the error from an AsyncError state.
  /// Throws if the state is not AsyncError.
  Object getErrorValue(AsyncValue state) {
    if (state is! AsyncError) {
      throw StateError('Expected AsyncError but got $state');
    }
    return (state as AsyncError).error;
  }
}
