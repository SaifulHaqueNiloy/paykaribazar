/// test/helpers/test_setup.dart
/// Centralized test setup and initialization - re-exports all test utilities
///
/// This file provides backwards compatibility by re-exporting all modularized
/// test utilities. New code should import from the specific modules instead:
/// - base_test.dart: Core BaseTest class
/// - firebase_test.dart: Firebase-specific testing
/// - snapshot_test.dart: Async/AsyncValue testing
/// - test_builders.dart: Test data builders
/// - performance_tracker.dart: Performance measurement
///
/// Legacy imports using this file will continue to work.

// Core test infrastructure
export 'base_test.dart' show BaseTest, createTestProviderContainer;

// Firebase testing
export 'firebase_test.dart'
    show BaseFirebaseTest, setupHiveForTesting, tearDownHiveForTesting;

// Async/Snapshot testing
export 'snapshot_test.dart' show BaseSnapshotTest;

// Test data builders
export 'test_builders.dart'
    show
        TestDataBuilder,
        TestDataFactory,
        TestListBuilder,
        TestMapBuilder,
        TestAssertions,
        registerFallbackValues,
        MockBuilder;

// Performance tracking
export 'performance_tracker.dart'
    show
        PerformanceMetric,
        PerformanceStats,
        PerformanceTracker,
        AutoStopwatch;

/// Legacy extension for cleaner mock verification syntax
extension MockVerification on void Function() {
  void verifyCalledOnce() {
    // For use with mocktail
  }
}
