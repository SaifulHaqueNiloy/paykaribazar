import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/product_model.dart';

/// Products pagination state provider
class ProductsPaginationNotifier
    extends StateNotifier<AsyncValue<ProductsPaginationState>> {
  final dynamic productService;
  final dynamic paginationService;

  ProductsPaginationNotifier({
    required this.productService,
    required this.paginationService,
  }) : super(const AsyncValue.loading());

  /// Initialize and fetch first page of products
  Future<void> fetchFirstPage({
    int pageSize = 20,
    String category = '',
    bool flashSaleOnly = false,
  }) async {
    try {
      state = const AsyncValue.loading();

      final pageState;
      if (category.isEmpty && !flashSaleOnly) {
        pageState = await paginationService.getFirstPage<ProductModel>(
          collectionPath: 'hub/data/products',
          converter: (doc) => ProductModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
          pageSize: pageSize,
          orderBy: 'createdAt',
          descending: true,
        );
      } else {
        pageState = await paginationService.getFilteredFirstPage<ProductModel>(
          collectionPath: 'hub/data/products',
          whereClause: (query) {
            var q = query;
            if (category.isNotEmpty) {
              q = q.where('categoryId', isEqualTo: category);
            }
            if (flashSaleOnly) {
              q = q.where('isFlashSale', isEqualTo: true);
            }
            return q;
          },
          converter: (doc) => ProductModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
          pageSize: pageSize,
        );
      }

      state = AsyncValue.data(
        ProductsPaginationState(
          items: pageState.items,
          cursor: pageState.cursor,
          hasMore: pageState.hasMore,
          pageSize: pageSize,
          category: category,
          flashSaleOnly: flashSaleOnly,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Load next page
  Future<void> fetchNextPage() async {
    final currentState = state.value;
    if (currentState == null || currentState.cursor == null || !currentState.hasMore) return;

    try {
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

      final pageState;
      if (currentState.category.isEmpty && !currentState.flashSaleOnly) {
        pageState = await paginationService.getNextPage<ProductModel>(
          collectionPath: 'hub/data/products',
          cursor: currentState.cursor!,
          converter: (doc) => ProductModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
          pageSize: currentState.pageSize,
        );
      } else {
        pageState = await paginationService.getFilteredNextPage<ProductModel>(
          collectionPath: 'hub/data/products',
          cursor: currentState.cursor!,
          whereClause: (query) {
            var q = query;
            if (currentState.category.isNotEmpty) {
              q = q.where('categoryId', isEqualTo: currentState.category);
            }
            if (currentState.flashSaleOnly) {
              q = q.where('isFlashSale', isEqualTo: true);
            }
            return q;
          },
          converter: (doc) => ProductModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
          pageSize: currentState.pageSize,
        );
      }

      state = AsyncValue.data(
        ProductsPaginationState(
          items: [...currentState.items, ...pageState.items],
          cursor: pageState.cursor,
          hasMore: pageState.hasMore,
          currentPage: currentState.currentPage + 1,
          pageSize: currentState.pageSize,
          category: currentState.category,
          flashSaleOnly: currentState.flashSaleOnly,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reset pagination to initial state
  void reset() {
    state = const AsyncValue.loading();
  }
}

class ProductsPaginationState {
  final List<ProductModel> items;
  final String? cursor;
  final bool hasMore;
  final int currentPage;
  final int pageSize;
  final String category;
  final bool flashSaleOnly;
  final bool isLoadingMore;

  ProductsPaginationState({
    required this.items,
    this.cursor,
    required this.hasMore,
    this.currentPage = 1,
    this.pageSize = 20,
    this.category = '',
    this.flashSaleOnly = false,
    this.isLoadingMore = false,
  });

  ProductsPaginationState copyWith({
    List<ProductModel>? items,
    String? cursor,
    bool? hasMore,
    int? currentPage,
    int? pageSize,
    String? category,
    bool? flashSaleOnly,
    bool? isLoadingMore,
  }) {
    return ProductsPaginationState(
      items: items ?? this.items,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      category: category ?? this.category,
      flashSaleOnly: flashSaleOnly ?? this.flashSaleOnly,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
