/// test/helpers/mock_providers.dart
/// Common mock implementations for Firebase, services, and providers
library;

import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as fb;

// ============================================================================
// FIREBASE MOCKS
// ============================================================================

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {
  MockDocumentSnapshot({
    String? id,
    Map<String, dynamic>? data,
  })  : _id = id ?? 'test-doc-id',
        _data = data ?? {};

  final String _id;
  final Map<String, dynamic> _data;

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => _data.isNotEmpty;
}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {
  MockQuerySnapshot({
    List<QueryDocumentSnapshot>? docs,
  }) : _docs = docs ?? [];

  final List<QueryDocumentSnapshot> _docs;

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs =>
      _docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();

  @override
  int get size => _docs.length;
}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {
  MockUser({
    String? uid,
    String? email,
    bool? emailVerified,
  })  : _uid = uid ?? 'test-uid',
        _email = email ?? 'test@example.com',
        _emailVerified = emailVerified ?? false;

  final String _uid;
  final String _email;
  final bool _emailVerified;

  @override
  String get uid => _uid;

  @override
  String? get email => _email;

  @override
  bool get emailVerified => _emailVerified;
}

class MockUserCredential extends Mock implements UserCredential {
  MockUserCredential({User? user}) : _user = user;

  final User? _user;

  @override
  User? get user => _user;
}

class MockFirebaseDatabase extends Mock implements fb.FirebaseDatabase {}

class MockDatabaseReference extends Mock implements fb.DatabaseReference {}

class MockDatabaseEvent extends Mock implements fb.DatabaseEvent {
  MockDatabaseEvent({fb.DataSnapshot? snapshot}) : _snapshot = snapshot;

  final fb.DataSnapshot? _snapshot;

  @override
  fb.DataSnapshot get snapshot => _snapshot ?? MockDataSnapshot();
}

class MockDataSnapshot extends Mock implements fb.DataSnapshot {
  MockDataSnapshot({
    String? key,
    dynamic value,
  })  : _key = key ?? 'test-key',
        _value = value;

  final String _key;
  final dynamic _value;

  @override
  String? get key => _key;

  @override
  dynamic get value => _value;
}

// ============================================================================
// SERVICE MOCKS (Removed - use only Firebase mocks for now)
// ============================================================================

// Note: Add service mocks as needed for specific tests

// ============================================================================
// HELPER FUNCTIONS FOR COMMON MOCK SETUP
// ============================================================================

/// Create a mock document snapshot with test data
DocumentSnapshot<Map<String, dynamic>> mockDocSnapshot(
  String id,
  Map<String, dynamic> data,
) {
  return MockDocumentSnapshot(id: id, data: data)
      as DocumentSnapshot<Map<String, dynamic>>;
}

/// Create a mock query snapshot with multiple documents
QuerySnapshot<Map<String, dynamic>> mockQuerySnapshot(
  List<Map<String, dynamic>> documents, {
  List<String>? ids,
}) {
  final docs = <QueryDocumentSnapshot>[];
  for (int i = 0; i < documents.length; i++) {
    docs.add(MockDocumentSnapshot(
      id: ids?[i] ?? 'doc-$i',
      data: documents[i],
    ) as QueryDocumentSnapshot<Map<String, dynamic>>);
  }
  return MockQuerySnapshot(docs: docs)
      as QuerySnapshot<Map<String, dynamic>>;
}

/// Create a mock Firebase user
User mockUser({
  String uid = 'test-uid',
  String email = 'test@example.com',
  bool emailVerified = false,
}) {
  return MockUser(uid: uid, email: email, emailVerified: emailVerified);
}

/// Create a mock user credential
UserCredential mockUserCredential({User? user}) {
  return MockUserCredential(
    user: user ?? mockUser(),
  );
}

/// Common when() setup for Firestore mock
void setupMockFirestoreForTest(
  MockFirebaseFirestore firestore,
  MockCollectionReference collection,
  MockDocumentReference document,
) {
  when(() => firestore.collection(any())).thenReturn(collection);
  when(() => collection.doc(any())).thenReturn(document);
  when(() => collection.add(any())).thenAnswer(
    (_) async => document,
  );
}

/// Register common fallback values to prevent MockTail errors
void registerMocktalFallbackValues() {
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(const Duration());
  registerFallbackValue(DateTime.now());
}
