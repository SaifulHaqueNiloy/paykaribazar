import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paykari_bazar/src/features/commerce/providers/products_pagination_provider.dart';
import 'package:paykari_bazar/src/features/commerce/providers/orders_pagination_provider.dart';
import 'package:paykari_bazar/src/core/services/firebase_pagination_service.dart';
import 'package:paykari_bazar/src/models/product_model.dart';
import 'package:paykari_bazar/src/models/order_model.dart';

class MockPaginationService extends Mock implements FirebasePaginationService {}

class FakePaginationState<T> extends Fake implements PaginationState<T> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakePaginationState<Product>());
    registerFallbackValue(FakePaginationState<Order>());
  });

  group('ProductsPaginationNotifier Tests', () {
    late ProductsPaginationNotifier notifier;
    late MockPaginationService mockPagination;

    setUp(() {
      mockPagination = MockPaginationService();
    });

    test('initial state is loading', () {
      notifier = ProductsPaginationNotifier(
        productService: null,
        paginationService: mockPagination,
      );
      expect(notifier.state.value, isNull);
      expect(notifier.state.isLoading, isTrue);
    });

    group('fetchFirstPage', () {
      test('success updates state with data', () async {
        final now = DateTime.now();
        final products = [
          _createProduct('p1', 'SKU1', now),
          _createProduct('p2', 'SKU2', now),
        ];
        final pageState = PaginationState<Product>(
          items: products,
          cursor: 'cursor1',
          hasMore: true,
        );

        notifier = ProductsPaginationNotifier(
          productService: null,
          paginationService: mockPagination,
        );

        when(() => mockPagination.getFirstPage<Product>(
          collectionPath: any(named: 'collectionPath'),
          converter: any(named: 'converter'),
          pageSize: any(named: 'pageSize'),
          orderBy: any(named: 'orderBy'),
          descending: any(named: 'descending'),
        )).thenAnswer((_) async => pageState);

        await notifier.fetchFirstPage(pageSize: 20);
        expect(notifier.state.value, isNotNull);
        expect(notifier.state.value!.items.length, equals(2));
        expect(notifier.state.value!.cursor, equals('cursor1'));
        expect(notifier.state.value!.hasMore, isTrue);
      });

      test('error updates state to error', () async {
        notifier = ProductsPaginationNotifier(
          productService: null,
          paginationService: mockPagination,
        );

        when(() => mockPagination.getFirstPage<Product>(
          collectionPath: any(named: 'collectionPath'),
          converter: any(named: 'converter'),
          pageSize: any(named: 'pageSize'),
          orderBy: any(named: 'orderBy'),
          descending: any(named: 'descending'),
        )).thenThrow(Exception('Network error'));

        await notifier.fetchFirstPage(pageSize: 20);
        expect(notifier.state.hasError, isTrue);
      });
    });

    group('fetchNextPage', () {
      test('appends items when hasMore is true', () async {
        final now = DateTime.now();
        final firstPage = PaginationState<Product>(
          items: [_createProduct('p1', 'SKU1', now)],
          cursor: 'cursor1',
          hasMore: true,
        );
        final secondPage = PaginationState<Product>(
          items: [_createProduct('p2', 'SKU2', now)],
          cursor: 'cursor2',
          hasMore: false,
        );

        notifier = ProductsPaginationNotifier(
          productService: null,
          paginationService: mockPagination,
        );

        when(() => mockPagination.getFirstPage<Product>(
          collectionPath: any(named: 'collectionPath'),
          converter: any(named: 'converter'),
          pageSize: any(named: 'pageSize'),
          orderBy: any(named: 'orderBy'),
          descending: any(named: 'descending'),
        )).thenAnswer((_) async => firstPage);

        await notifier.fetchFirstPage(pageSize: 20);
        expect(notifier.state.value!.items.length, equals(1));

        when(() => mockPagination.getNextPage<Product>(
          collectionPath: any(named: 'collectionPath'),
          cursor: any(named: 'cursor'),
          converter: any(named: 'converter'),
          pageSize: any(named: 'pageSize'),
          orderBy: any(named: 'orderBy'),
          descending: any(named: 'descending'),
        )).thenAnswer((_) async => secondPage);

        await notifier.fetchNextPage();
        expect(notifier.state.value!.items.length, equals(2));
        expect(notifier.state.value!.cursor, equals('cursor2'));
        expect(notifier.state.value!.hasMore, isFalse);
        expect(notifier.state.value!.isLoadingMore, isFalse);
      });

      test('does nothing when hasMore is false', () async {
        final now = DateTime.now();
        final firstPage = PaginationState<Product>(
          items: [_createProduct('p1', 'SKU1', now)],
          cursor: 'cursor1',
          hasMore: false,
        );

        notifier = ProductsPaginationNotifier(
          productService: null,
          paginationService: mockPagination,
        );

        when(() => mockPagination.getFirstPage<Product>(
          collectionPath: any(named: 'collectionPath'),
          converter: any(named: 'converter'),
          pageSize: any(named: 'pageSize'),
          orderBy: any(named: 'orderBy'),
          descending: any(named: 'descending'),
        )).thenAnswer((_) async => firstPage);

        await notifier.fetchFirstPage(pageSize: 20);
        await notifier.fetchNextPage();

        expect(notifier.state.value!.items.length, equals(1));
        expect(notifier.state.value!.hasMore, isFalse);
      });
    });

    group('reset', () {
      test('clears state back to loading', () async {
        final now = DateTime.now();
        final pageState = PaginationState<Product>(
          items: [_createProduct('p1', 'SKU1', now)],
          cursor: 'cursor1',
          hasMore: true,
        );

        notifier = ProductsPaginationNotifier(
          productService: null,
          paginationService: mockPagination,
        );

        when(() => mockPagination.getFirstPage<Product>(
          collectionPath: any(named: 'collectionPath'),
          converter: any(named: 'converter'),
          pageSize: any(named: 'pageSize'),
          orderBy: any(named: 'orderBy'),
          descending: any(named: 'descending'),
        )).thenAnswer((_) async => pageState);

        await notifier.fetchFirstPage(pageSize: 20);
        notifier.reset();
        expect(notifier.state.value, isNull);
        expect(notifier.state.isLoading, isTrue);
      });
    });
  });

  group('OrdersPaginationNotifier Tests', () {
    late OrdersPaginationNotifier notifier;
    late MockPaginationService mockPagination;

    setUp(() {
      mockPagination = MockPaginationService();
    });

    test('initial state is loading', () {
      notifier = OrdersPaginationNotifier(
        orderService: null,
        paginationService: mockPagination,
        userId: 'user1',
      );
      expect(notifier.state.value, isNull);
      expect(notifier.state.isLoading, isTrue);
    });

    group('fetchFirstPage', () {
      test('success with user orders filter', () async {
        final now = DateTime.now();
        final orders = [
          _createOrder('o1', 'user1', now),
          _createOrder('o2', 'user1', now),
        ];
        final pageState = PaginationState<Order>(
          items: orders,
          cursor: 'cursor1',
          hasMore: true,
        );

        notifier = OrdersPaginationNotifier(
          orderService: null,
          paginationService: mockPagination,
          userId: 'user1',
        );

        when(() => mockPagination.getFilteredFirstPage<Order>(
          collectionPath: any(named: 'collectionPath'),
          whereClause: any(named: 'whereClause'),
          converter: any(named: 'converter'),
          pageSize: any(named: 'pageSize'),
          orderBy: any(named: 'orderBy'),
          descending: any(named: 'descending'),
        )).thenAnswer((_) async => pageState);

        await notifier.fetchFirstPage(pageSize: 15, userOrdersOnly: true);
        expect(notifier.state.value, isNotNull);
        expect(notifier.state.value!.items.length, equals(2));
      });

      test('admin view ignores userId filter', () async {
        final now = DateTime.now();
        final orders = [
          _createOrder('o1', 'user1', now),
          _createOrder('o2', 'user2', now),
        ];
        final pageState = PaginationState<Order>(
          items: orders,
          cursor: 'cursor1',
          hasMore: false,
        );

        notifier = OrdersPaginationNotifier(
          orderService: null,
          paginationService: mockPagination,
          userId: null,
        );

        when(() => mockPagination.getFilteredFirstPage<Order>(
          collectionPath: any(named: 'collectionPath'),
          whereClause: any(named: 'whereClause'),
          converter: any(named: 'converter'),
          pageSize: any(named: 'pageSize'),
          orderBy: any(named: 'orderBy'),
          descending: any(named: 'descending'),
        )).thenAnswer((_) async => pageState);

        await notifier.fetchFirstPage(pageSize: 15, userOrdersOnly: false);
        expect(notifier.state.value!.items.length, equals(2));
      });
    });
  });

  group('Pagination State CopyWith', () {
    test('ProductsPaginationState copyWith', () {
      final original = ProductsPaginationState(
        items: <Product>[],
        hasMore: true,
        category: 'electronics',
      );

      final updated = original.copyWith(
        isLoadingMore: true,
        currentPage: 2,
      );

      expect(updated.isLoadingMore, isTrue);
      expect(updated.currentPage, equals(2));
      expect(updated.category, equals('electronics'));
      expect(updated.pageSize, equals(20));
    });

    test('OrdersPaginationState copyWith', () {
      final original = OrdersPaginationState(
        items: <Order>[],
        hasMore: true,
        status: 'pending',
      );

      final updated = original.copyWith(
        isLoadingMore: true,
        currentPage: 3,
      );

      expect(updated.isLoadingMore, isTrue);
      expect(updated.currentPage, equals(3));
      expect(updated.status, equals('pending'));
    });
  });
}

Product _createProduct(String id, String sku, DateTime now) {
  return Product(
    id: id,
    sku: sku,
    name: 'Product $id',
    nameBn: 'পণ্য $id',
    description: 'Description $id',
    descriptionBn: 'বর্ণনা $id',
    price: 100.0,
    stock: 10,
    unit: 'pc',
    unitBn: 'পিস',
    imageUrl: '',
    categoryId: 'c1',
    categoryName: 'Cat',
    createdAt: now,
    updatedAt: now,
  );
}

Order _createOrder(String id, String customerUid, DateTime now) {
  return Order(
    id: id,
    customerUid: customerUid,
    customerName: 'User $customerUid',
    customerPhone: '01700000000',
    items: [],
    subtotal: 100.0,
    deliveryFee: 10.0,
    discount: 0.0,
    total: 110.0,
    address: 'Addr',
    paymentMethod: 'COD',
    status: OrderStatus.pending,
    createdAt: now,
    updatedAt: now,
  );
}
