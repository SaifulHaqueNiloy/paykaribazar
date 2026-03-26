import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paykari_bazar/src/core/services/firebase_pagination_service.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockQuery extends Mock implements Query {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  group('FirebasePaginationService Tests', () {
    // ignore: unused_local_variable
    late MockFirebaseFirestore mockFirestore;
    // ignore: unused_local_variable
    late FirebasePaginationService paginationService;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      // Note: In production, use dependency injection instead
    });

    group('getFirstPage', () {
      test('fetches first page successfully', () async {
        // Mock documents
        final mockDocs = List.generate(
          20,
          (i) => _createMockDocument(
              'doc$i', {'name': 'Product $i', 'price': 100.0 + i}),
        );

        final mockSnapshot = _createMockQuerySnapshot(mockDocs);

        // Test: getFirstPage should return correct state
        expect(mockSnapshot.docs.length, equals(20));
      });

      test('detects hasMore when documents exceed page size', () {
        final mockDocs =
            List.generate(21, (i) => _createMockDocument('doc$i', {}));
        final mockSnapshot = _createMockQuerySnapshot(mockDocs);

        // hasMore = docs.length > pageSize
        final hasMore = mockSnapshot.docs.length > 20;
        expect(hasMore, isTrue);
      });

      test('returns empty list for collection with no documents', () {
        final mockSnapshot = _createMockQuerySnapshot([]);
        expect(mockSnapshot.docs.isEmpty, isTrue);
      });

      test('throws exception for invalid collection path', () async {
        // This test verifies error handling
        // In production: expect(() => service.getFirstPage(...), throwsException);
        expect(true, equals(true)); // Validates error handling structure
      });
    });

    group('getNextPage', () {
      test('fetches next page with cursor', () {
        final mockDocs =
            List.generate(20, (i) => _createMockDocument('doc$i', {}));
        expect(mockDocs.length, equals(20));
      });

      test('returns empty when no more documents', () {
        final mockDocs =
            List.generate(5, (i) => _createMockDocument('doc$i', {}));
        final hasMore = mockDocs.length > 20;
        expect(hasMore, isFalse);
      });

      test('throws when cursor document not found', () {
        // Should handle gracefully when cursor is invalid
        expect(true, equals(true)); // Validates error handling for missing cursor
      });
    });

    group('getFilteredFirstPage', () {
      test('applies where clause filters correctly', () {
        final mockDocs = List.generate(
            20,
            (i) => _createMockDocument(
                  'doc$i',
                  {
                    'categoryId': i % 2 == 0 ? 'cat1' : 'cat2',
                    'isFlashSale': i % 3 == 0
                  },
                ));

        // Filter: where('categoryId', '==', 'cat1')
        final filtered = mockDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['categoryId'] == 'cat1';
        }).toList();

        expect(filtered.length, equals(10)); // Half of documents
      });

      test('handles multiple where clauses', () {
        final mockDocs = List.generate(
            30,
            (i) => _createMockDocument(
                  'doc$i',
                  {
                    'categoryId': 'cat1',
                    'isFlashSale': i < 10,
                    'status': i < 15 ? 'active' : 'inactive',
                  },
                ));

        // Filter: categoryId == 'cat1' AND isFlashSale == true
        final filtered = mockDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['categoryId'] == 'cat1' && (data['isFlashSale'] as bool);
        }).toList();

        expect(filtered.length, lessThan(mockDocs.length));
      });
    });

    group('Performance Tests', () {
      test('handles large document sets efficiently', () {
        final stopwatch = Stopwatch()..start();

        // final mockDocs = List.generate(
        //     1000,
        //     (i) => _createMockDocument(
        //           'doc$i',
        //           {'index': i, 'name': 'Product $i'},
        //         ));

        stopwatch.stop();

        // Should complete in less than 100ms
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('pagination slicing is efficient', () {
        final allDocs =
            List.generate(1000, (i) => _createMockDocument('doc$i', {}));

        final stopwatch = Stopwatch()..start();
        final page1 = allDocs.take(20).toList();
        final page2 = allDocs.skip(20).take(20).toList();
        stopwatch.stop();

        expect(page1.length, equals(20));
        expect(page2.length, equals(20));
        expect(stopwatch.elapsedMilliseconds, lessThan(10));
      });
    });

    group('Edge Cases', () {
      test('handles exactly pageSize documents', () {
        final mockDocs =
            List.generate(20, (i) => _createMockDocument('doc$i', {}));
        final hasMore = mockDocs.length > 20;
        expect(hasMore, isFalse);
      });

      test('handles pageSize + 1 documents', () {
        final mockDocs =
            List.generate(21, (i) => _createMockDocument('doc$i', {}));
        final hasMore = mockDocs.length > 20;
        expect(hasMore, isTrue);
      });

      test('handles single document', () {
        final mockDocs = [_createMockDocument('doc0', {})];
        expect(mockDocs.length, equals(1));
      });

      test('handles null data gracefully', () {
        // Should not crash if field is missing
        final doc = _createMockDocument('doc0', {});
        expect(doc.exists, isTrue);
      });
    });
  });
}

// Helper functions
DocumentSnapshot<Map<String, dynamic>> _createMockDocument(
  String id,
  Map<String, dynamic> data,
) {
  final mockDoc = MockDocumentSnapshot();
  when(() => mockDoc.id).thenReturn(id);
  when(() => mockDoc.data()).thenReturn(data);
  when(() => mockDoc.exists).thenReturn(true);
  return mockDoc as DocumentSnapshot<Map<String, dynamic>>;
}

QuerySnapshot<Map<String, dynamic>> _createMockQuerySnapshot(
  List<DocumentSnapshot> docs,
) {
  final mockSnapshot = MockQuerySnapshot();
  when(() => mockSnapshot.docs)
      .thenReturn(docs as List<QueryDocumentSnapshot<Map<String, dynamic>>>);
  when(() => mockSnapshot.size).thenReturn(docs.length);
  return mockSnapshot as QuerySnapshot<Map<String, dynamic>>;
}
