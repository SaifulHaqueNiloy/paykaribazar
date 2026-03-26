import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_pagination_service.dart';
import '../domain/order_model.dart';

/// Orders pagination state provider
class OrdersPaginationNotifier
    extends StateNotifier<AsyncValue<OrdersPaginationState>> {
  final dynamic orderService;
  final dynamic paginationService;
  final String? userId; // For filtering user's orders

  OrdersPaginationNotifier({
    required this.orderService,
    required this.paginationService,
    this.userId,
  }) : super(const AsyncValue.loading());

  /// Initialize and fetch first page of orders
  Future<void> fetchFirstPage({
    int pageSize = 15,
    String status = '',
    bool userOrdersOnly = true,
  }) async {
    try {
      state = const AsyncValue.loading();

      final PaginationState<OrderModel> pageState;
      if (userOrdersOnly && userId != null) {
        pageState = await paginationService.getFilteredFirstPage<OrderModel>(
          collectionPath: 'orders',
          whereClause: (query) {
            var q = query.where('customerUid', isEqualTo: userId);
            if (status.isNotEmpty) {
              q = q.where('status', isEqualTo: status);
            }
            return q;
          },
          converter: (doc) => OrderModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
          pageSize: pageSize,
          orderBy: 'createdAt',
          descending: true,
        );
      } else {
        pageState = await paginationService.getFilteredFirstPage<OrderModel>(
          collectionPath: 'orders',
          whereClause: (query) {
            var q = query;
            if (status.isNotEmpty) {
              q = q.where('status', isEqualTo: status);
            }
            return q;
          },
          converter: (doc) => OrderModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
          pageSize: pageSize,
          orderBy: 'createdAt',
          descending: true,
        );
      }

      state = AsyncValue.data(
        OrdersPaginationState(
          items: pageState.items,
          cursor: pageState.cursor,
          hasMore: pageState.hasMore,
          pageSize: pageSize,
          status: status,
          userOrdersOnly: userOrdersOnly,
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

      final PaginationState<OrderModel> pageState;
      if (currentState.userOrdersOnly && userId != null) {
        pageState = await paginationService.getFilteredNextPage<OrderModel>(
          collectionPath: 'orders',
          cursor: currentState.cursor!,
          whereClause: (query) {
            var q = query.where('customerUid', isEqualTo: userId);
            if (currentState.status.isNotEmpty) {
              q = q.where('status', isEqualTo: currentState.status);
            }
            return q;
          },
          converter: (doc) => OrderModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
          pageSize: currentState.pageSize,
          orderBy: 'createdAt',
          descending: true,
        );
      } else {
        pageState = await paginationService.getFilteredNextPage<OrderModel>(
          collectionPath: 'orders',
          cursor: currentState.cursor!,
          whereClause: (query) {
            var q = query;
            if (currentState.status.isNotEmpty) {
              q = q.where('status', isEqualTo: currentState.status);
            }
            return q;
          },
          converter: (doc) => OrderModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
          pageSize: currentState.pageSize,
          orderBy: 'createdAt',
          descending: true,
        );
      }

      state = AsyncValue.data(
        OrdersPaginationState(
          items: [...currentState.items, ...pageState.items],
          cursor: pageState.cursor,
          hasMore: pageState.hasMore,
          currentPage: currentState.currentPage + 1,
          pageSize: currentState.pageSize,
          status: currentState.status,
          userOrdersOnly: currentState.userOrdersOnly,
        ),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

class OrdersPaginationState {
  final List<OrderModel> items;
  final String? cursor;
  final bool hasMore;
  final int currentPage;
  final int pageSize;
  final String status;
  final bool userOrdersOnly;
  final bool isLoadingMore;

  OrdersPaginationState({
    required this.items,
    this.cursor,
    required this.hasMore,
    this.currentPage = 1,
    this.pageSize = 15,
    this.status = '',
    this.userOrdersOnly = true,
    this.isLoadingMore = false,
  });

  OrdersPaginationState copyWith({
    List<OrderModel>? items,
    String? cursor,
    bool? hasMore,
    int? currentPage,
    int? pageSize,
    String? status,
    bool? userOrdersOnly,
    bool? isLoadingMore,
  }) {
    return OrdersPaginationState(
      items: items ?? this.items,
      cursor: cursor ?? this.cursor,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      status: status ?? this.status,
      userOrdersOnly: userOrdersOnly ?? this.userOrdersOnly,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
