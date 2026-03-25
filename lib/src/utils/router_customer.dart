import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'globals.dart';
import '../features/main_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/products/product_list_screen.dart'; 
import '../features/products/product_detail_screen.dart';
import '../features/products/medicine_order_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/wishlist/wishlist_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/chat/private_chat_screen.dart';
import '../features/chat/chat_history_list_screen.dart';
import '../features/profile/application_form_screen.dart';
import '../features/profile/wallet_screen.dart';
import '../features/profile/backup_screen.dart';
import '../features/products/category_navigation_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/notifications/notification_screen.dart';
import '../features/orders/emergency_details_screen.dart';
import '../features/profile/how_to_use_screen.dart'; 
import '../features/search/search_screen.dart';
import '../features/orders/order_tracking_screen.dart';
import '../di/providers.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final customerRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (context, state) {
    final auth = FirebaseAuth.instance;
    final loggedIn = auth.currentUser != null;
    final path = state.uri.path;
    final isAuthPage = path == '/login' || path == '/signup' || path == '/forgot-password';

    if (!loggedIn && !isAuthPage) return '/login';
    if (loggedIn && isAuthPage) return '/';

    if (loggedIn) {
      final container = ProviderScope.containerOf(context);
      final userData = container.read(actualUserDataProvider).value;
      
      if (userData != null) {
        final role = userData['role'] ?? 'customer';
        if (role != 'admin' && role != 'customer' && role != 'reseller' && role != 'staff' && role != 'logistic') {
          auth.signOut();
          return '/login';
        }
      }
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MainScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(path: '/medicine-order', builder: (context, state) => const MedicineOrderScreen()),
    GoRoute(path: '/emergency', builder: (context, state) => const EmergencyDetailsScreen()),
    GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
    GoRoute(path: '/wishlist', builder: (context, state) => const WishlistScreen()),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
    GoRoute(path: '/chat-history', builder: (context, state) => const ChatHistoryListScreen()),
    GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen()),
    GoRoute(path: '/backup', builder: (context, state) => const BackupScreen()),
    GoRoute(path: '/edit-profile', builder: (context, state) => const EditProfileScreen()),
    GoRoute(path: '/notifications', builder: (context, state) => const NotificationScreen()),
    GoRoute(path: '/how-to-use', builder: (context, state) => const HowToUseScreen()), 
    
    GoRoute(
      path: '/apply', 
      builder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'reseller';
        return ApplicationFormScreen(role: role);
      }
    ),

    GoRoute(
      path: '/search', 
      builder: (context, state) {
        final query = state.uri.queryParameters['q'];
        final action = state.uri.queryParameters['action'];
        return SearchScreen(initialQuery: query, initialAction: action);
      }
    ),
    
    GoRoute(path: '/admin', redirect: (context, state) => '/'),
    GoRoute(path: '/staff', redirect: (context, state) => '/'),

    GoRoute(
      path: '/private-chat',
      builder: (context, state) {
        final chatId = state.uri.queryParameters['chatId'] ?? '';
        final name = state.uri.queryParameters['name'] ?? 'Chat';
        final isStaff = state.uri.queryParameters['isStaff'] == 'true';
        final receiverId = state.uri.queryParameters['receiverId'];
        return PrivateChatScreen(chatId: chatId, receiverName: name, isStaffChat: isStaff, receiverId: receiverId);
      },
    ),

    GoRoute(
      path: '/order-tracking',
      builder: (context, state) {
        final orderId = state.uri.queryParameters['orderId'] ?? '';
        final riderUid = state.uri.queryParameters['riderUid'];
        return OrderTrackingScreen(orderId: orderId, riderUid: riderUid);
      },
    ),

    GoRoute(
      path: '/categories/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final name = state.uri.queryParameters['name'] ?? 'Category';
        return CategoryNavigationScreen(categoryId: id, categoryName: name);
      },
    ),
    GoRoute(
      path: '/products/:category',
      builder: (context, state) {
        final category = state.pathParameters['category']!;
        return ProductListScreen(categoryId: category);
      },
    ),
    GoRoute(
      path: '/product-details',
      builder: (context, state) {
        final productId = state.uri.queryParameters['productId'] ?? '';
        return ProductDetailScreen(productId: productId);
      },
    ),
  ],
);
