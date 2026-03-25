import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PaginationState<T> {
  final List<T> items;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  final String? cursor;
  
  PaginationState({
    required this.items,
    this.lastDocument,
    this.hasMore = true,
    this.cursor,
  });
}

/// Firebase Cursor-Based Pagination Service
/// Handles efficient pagination for large collections using cursor-based approach
class FirebasePaginationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch first page of documents
  /// 
  /// [collectionPath] - Path to Firestore collection (e.g., 'hub/data/products')
  /// [pageSize] - Number of documents per page (default: 20)
  /// [converter] - Function to convert DocumentSnapshot to model
  /// [orderBy] - Field to order by (default: 'createdAt')
  /// [descending] - Order direction (default: true for newest first)
  Future<PaginationState<T>> getFirstPage<T>({
    required String collectionPath,
    required T Function(DocumentSnapshot) converter,
    int pageSize = 20,
    String orderBy = 'createdAt',
    bool descending = true,
  }) async {
    try {
      final query = _firestore
          .collection(collectionPath)
          .orderBy(orderBy, descending: descending)
          .limit(pageSize + 1); // Fetch one extra to detect hasMore

      final snapshot = await query.get();
      final hasMore = snapshot.docs.length > pageSize;
      final docs = hasMore
          ? snapshot.docs.take(pageSize).toList()
          : snapshot.docs;

      final items = docs.map((doc) => converter(doc)).toList();
      final lastDoc = docs.isNotEmpty ? docs.last : null;
      final cursor = lastDoc?.id;

      return PaginationState<T>(
        items: items,
        lastDocument: lastDoc,
        hasMore: hasMore,
        cursor: cursor,
      );
    } catch (e) {
      debugPrint('❌ Pagination error (first page): $e');
      rethrow;
    }
  }

  /// Fetch next page using cursor
  /// 
  /// [collectionPath] - Path to Firestore collection
  /// [cursor] - Last document ID from previous page
  /// [converter] - Function to convert DocumentSnapshot to model
  /// [pageSize] - Number of documents per page
  /// [orderBy] - Field to order by
  /// [descending] - Order direction
  Future<PaginationState<T>> getNextPage<T>({
    required String collectionPath,
    required String cursor,
    required T Function(DocumentSnapshot) converter,
    int pageSize = 20,
    String orderBy = 'createdAt',
    bool descending = true,
  }) async {
    try {
      // Get the last document
      final lastDocSnapshot = await _firestore
          .collection(collectionPath)
          .doc(cursor)
          .get();

      if (!lastDocSnapshot.exists) {
        throw Exception('Cursor document not found');
      }

      // Query starting after the cursor
      final query = _firestore
          .collection(collectionPath)
          .orderBy(orderBy, descending: descending)
          .startAfterDocument(lastDocSnapshot)
          .limit(pageSize + 1);

      final snapshot = await query.get();
      final hasMore = snapshot.docs.length > pageSize;
      final docs = hasMore
          ? snapshot.docs.take(pageSize).toList()
          : snapshot.docs;

      final items = docs.map((doc) => converter(doc)).toList();
      final lastDoc = docs.isNotEmpty ? docs.last : null;
      final newCursor = lastDoc?.id;

      return PaginationState<T>(
        items: items,
        lastDocument: lastDoc,
        hasMore: hasMore,
        cursor: newCursor,
      );
    } catch (e) {
      debugPrint('❌ Pagination error (next page): $e');
      rethrow;
    }
  }

  /// Fetch page with filters
  /// Supports complex queries with where clauses and pagination
  /// 
  /// [collectionPath] - Collection path
  /// [whereClause] - Function that receives Query and returns filtered Query
  /// [converter] - Document converter function
  /// [pageSize] - Items per page
  /// [orderBy] - Sort field
  /// [descending] - Sort direction
  Future<PaginationState<T>> getFilteredFirstPage<T>({
    required String collectionPath,
    required Query Function(Query) whereClause,
    required T Function(DocumentSnapshot) converter,
    int pageSize = 20,
    String orderBy = 'createdAt',
    bool descending = true,
  }) async {
    try {
      var query = _firestore.collection(collectionPath) as Query;
      
      // Apply filters
      query = whereClause(query);
      
      // Apply ordering and pagination
      query = query
          .orderBy(orderBy, descending: descending)
          .limit(pageSize + 1);

      final snapshot = await query.get();
      final hasMore = snapshot.docs.length > pageSize;
      final docs = hasMore
          ? snapshot.docs.take(pageSize).toList()
          : snapshot.docs;

      final items = docs.map((doc) => converter(doc)).toList();
      final lastDoc = docs.isNotEmpty ? docs.last : null;

      return PaginationState<T>(
        items: items,
        lastDocument: lastDoc,
        hasMore: hasMore,
        cursor: lastDoc?.id,
      );
    } catch (e) {
      debugPrint('❌ Pagination error (filtered first page): $e');
      rethrow;
    }
  }

  /// Fetch filtered next page with cursor
  Future<PaginationState<T>> getFilteredNextPage<T>({
    required String collectionPath,
    required String cursor,
    required Query Function(Query) whereClause,
    required T Function(DocumentSnapshot) converter,
    int pageSize = 20,
    String orderBy = 'createdAt',
    bool descending = true,
  }) async {
    try {
      // Get cursor document
      final lastDocSnapshot = await _firestore
          .collection(collectionPath)
          .doc(cursor)
          .get();

      if (!lastDocSnapshot.exists) {
        throw Exception('Cursor document not found');
      }

      // Build filtered query with cursor
      var query = _firestore.collection(collectionPath) as Query;
      query = whereClause(query);
      query = query
          .orderBy(orderBy, descending: descending)
          .startAfterDocument(lastDocSnapshot)
          .limit(pageSize + 1);

      final snapshot = await query.get();
      final hasMore = snapshot.docs.length > pageSize;
      final docs = hasMore
          ? snapshot.docs.take(pageSize).toList()
          : snapshot.docs;

      final items = docs.map((doc) => converter(doc)).toList();
      final lastDoc = docs.isNotEmpty ? docs.last : null;

      return PaginationState<T>(
        items: items,
        lastDocument: lastDoc,
        hasMore: hasMore,
        cursor: lastDoc?.id,
      );
    } catch (e) {
      debugPrint('❌ Pagination error (filtered next page): $e');
      rethrow;
    }
  }

  /// Get total count of documents in collection
  /// Warning: Counts trigger read operations, use sparingly
  Future<int> getCollectionCount(String collectionPath) async {
    try {
      final snapshot = await _firestore.collection(collectionPath).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ Count error: $e');
      rethrow;
    }
  }

  /// Stream-based real-time pagination
  /// Useful for live updates on first page
  Stream<PaginationState<T>> watchFirstPage<T>({
    required String collectionPath,
    required T Function(DocumentSnapshot) converter,
    int pageSize = 20,
    String orderBy = 'createdAt',
    bool descending = true,
  }) {
    return _firestore
        .collection(collectionPath)
        .orderBy(orderBy, descending: descending)
        .limit(pageSize + 1)
        .snapshots()
        .map((snapshot) {
      final hasMore = snapshot.docs.length > pageSize;
      final docs = hasMore
          ? snapshot.docs.take(pageSize).toList()
          : snapshot.docs;

      final items = docs.map((doc) => converter(doc)).toList();
      final lastDoc = docs.isNotEmpty ? docs.last : null;

      return PaginationState<T>(
        items: items,
        lastDocument: lastDoc,
        hasMore: hasMore,
        cursor: lastDoc?.id,
      );
    }).handleError((e) {
      debugPrint('❌ Stream pagination error: $e');
    });
  }
}
