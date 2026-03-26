/// Firebase-specific test base class and utilities
///
/// Provides Firebase initialization and cleanup for tests that depend on
/// Firebase services (Firestore, Auth, Storage, etc.).
library;

import 'dart:io';
import 'package:hive/hive.dart';
import 'base.dart';

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

/// Base test class for Firebase/Hive dependent tests
///
/// Handles Hive initialization and Firebase mock setup.
/// Use this for tests that verify behavior with Firebase services.
///
/// Usage:
/// ```dart
/// class FirebaseServiceTest extends BaseFirebaseTest {
///   void test('reads from firestore', () async {
///     final result = read(firestoreProvider);
///     expect(result, isNotEmpty);
///   });
/// }
/// ```
abstract class BaseFirebaseTest extends BaseTest {

}
