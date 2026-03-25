import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// A generic paginator for Firestore collections to handle large datasets (100K+ users/products)
/// Implements Cursor-based pagination for high performance and cost efficiency.
class FirestorePaginator<T> {
  final String collectionPath;
  final int pageSize;
  final T Function(DocumentSnapshot doc) fromFirestore;
  final Query Function(Query query)? queryBuilder;
  final String orderByField;
  final bool descending;

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;
  final List<T> _items = [];

  FirestorePaginator({
    required this.collectionPath,
    required this.fromFirestore,
    this.pageSize = 20,
    this.queryBuilder,
    this.orderByField = 'createdAt',
    this.descending = true,
  });

  List<T> get items => List.unmodifiable(_items);
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  /// Fetch the first page of data
  Future<List<T>> fetchFirstPage() async {
    if (_isLoading) return _items;
    
    _isLoading = true;
    _items.clear();
    _lastDocument = null;
    _hasMore = true;

    try {
      Query query = FirebaseFirestore.instance
          .collection(collectionPath)
          .orderBy(orderByField, descending: descending)
          .limit(pageSize);

      if (queryBuilder != null) {
        query = queryBuilder!(query);
      }

      final snapshot = await query.get();
      
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _items.addAll(snapshot.docs.map((doc) => fromFirestore(doc)).toList());
        _hasMore = snapshot.docs.length == pageSize;
      } else {
        _hasMore = false;
      }

      debugPrint('✅ Initialized paginator for $collectionPath: ${_items.length} items');
      return _items;
    } catch (e) {
      debugPrint('❌ Error fetching first page: $e');
      _hasMore = false;
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Fetch the next page of data using the last document cursor
  Future<List<T>> fetchNextPage() async {
    if (_isLoading || !_hasMore || _lastDocument == null) return _items;

    _isLoading = true;

    try {
      Query query = FirebaseFirestore.instance
          .collection(collectionPath)
          .orderBy(orderByField, descending: descending)
          .startAfterDocument(_lastDocument!)
          .limit(pageSize);

      if (queryBuilder != null) {
        query = queryBuilder!(query);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _items.addAll(snapshot.docs.map((doc) => fromFirestore(doc)).toList());
        _hasMore = snapshot.docs.length == pageSize;
      } else {
        _hasMore = false;
      }

      debugPrint('✅ Loaded next page for $collectionPath: Total ${_items.length} items');
      return _items;
    } catch (e) {
      debugPrint('❌ Error fetching next page: $e');
      _hasMore = false;
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Reset and refresh the data
  void refresh() {
    _items.clear();
    _lastDocument = null;
    _hasMore = true;
    _isLoading = false;
  }
}
