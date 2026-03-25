import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'globals.dart';
import '../features/admin/admin_screen.dart';
import '../features/reseller/reseller_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/notifications/notification_screen.dart';
import '../features/profile/how_to_use_screen.dart';
import '../di/providers.dart';

final adminRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final auth = FirebaseAuth.instance;
    final loggedIn = auth.currentUser != null;
    final isAuthPage = state.uri.path == '/login';

    if (!loggedIn && !isAuthPage) return '/login';
    if (loggedIn && isAuthPage) return '/';

    if (loggedIn) {
      final container = ProviderScope.containerOf(context);
      final userData = container.read(actualUserDataProvider).value;
      
      if (userData != null) {
        final role = userData['role'] ?? 'customer';
        if (role == 'customer') {
          auth.signOut(); 
          return '/login';
        }
      }
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/', 
      builder: (context, state) {
        final container = ProviderScope.containerOf(context);
        final userData = container.read(actualUserDataProvider).value;
        final role = userData?['role'] ?? 'customer';

        if (role == 'reseller') {
          return const ResellerScreen();
        }
        return const AdminScreen(isAdmin: true);
      },
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
    GoRoute(path: '/notifications', builder: (context, state) => const NotificationScreen()),
    GoRoute(path: '/how-to-use', builder: (context, state) => const HowToUseScreen()),
  ],
);
