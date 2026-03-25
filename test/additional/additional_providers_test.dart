import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// MOCK PROVIDERS
// ============================================================================

class UserState {
  final String id;
  final String name;
  final String email;
  final bool isAuthenticated;

  UserState({
    required this.id,
    required this.name,
    required this.email,
    required this.isAuthenticated,
  });

  UserState copyWith({
    String? id,
    String? name,
    String? email,
    bool? isAuthenticated,
  }) {
    return UserState(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier()
      : super(UserState(
          id: '',
          name: '',
          email: '',
          isAuthenticated: false,
        ));

  void login(String email, String password) {
    state = state.copyWith(
      id: 'user_123',
      name: 'John Doe',
      email: email,
      isAuthenticated: true,
    );
  }

  void logout() {
    state = state.copyWith(
      id: '',
      name: '',
      email: '',
      isAuthenticated: false,
    );
  }

  void updateProfile({required String name, required String email}) {
    state = state.copyWith(name: name, email: email);
  }
}

class ThemeState {
  final bool isDarkMode;
  final String accentColor;

  ThemeState({
    required this.isDarkMode,
    required this.accentColor,
  });

  ThemeState copyWith({
    bool? isDarkMode,
    String? accentColor,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
      : super(ThemeState(
          isDarkMode: false,
          accentColor: 'blue',
        ));

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void setAccentColor(String color) {
    state = state.copyWith(accentColor: color);
  }
}

class NotificationState {
  final List<String> messages;
  final int unreadCount;

  NotificationState({
    required this.messages,
    required this.unreadCount,
  });

  NotificationState copyWith({
    List<String>? messages,
    int? unreadCount,
  }) {
    return NotificationState(
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier()
      : super(NotificationState(
          messages: [],
          unreadCount: 0,
        ));

  void addNotification(String message) {
    state = state.copyWith(
      messages: [...state.messages, message],
      unreadCount: state.unreadCount + 1,
    );
  }

  void markAsRead() {
    state = state.copyWith(unreadCount: 0);
  }

  void clearAll() {
    state = state.copyWith(
      messages: [],
      unreadCount: 0,
    );
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});

// ============================================================================
// TESTS
// ============================================================================

void main() {
  group('Provider Tests - Riverpod State Management', () {
    // ========================================================================
    // GROUP 1: User Provider (3 tests)
    // ========================================================================
    group('User Provider', () {
      test('1. User provider initializes with default state', () {
        final container = ProviderContainer();
        final userState = container.read(userProvider);

        expect(userState.isAuthenticated, isFalse);
        expect(userState.email, isEmpty);
      });

      test('2. User login updates provider state', () {
        final container = ProviderContainer();
        final userNotifier = container.read(userProvider.notifier);

        userNotifier.login('test@example.com', 'password123');

        final userState = container.read(userProvider);
        expect(userState.isAuthenticated, isTrue);
        expect(userState.email, 'test@example.com');
      });

      test('3. User logout clears provider state', () {
        final container = ProviderContainer();
        final userNotifier = container.read(userProvider.notifier);

        userNotifier.login('test@example.com', 'password123');
        userNotifier.logout();

        final userState = container.read(userProvider);
        expect(userState.isAuthenticated, isFalse);
        expect(userState.email, isEmpty);
      });

      test('4. User profile update modifies state', () {
        final container = ProviderContainer();
        final userNotifier = container.read(userProvider.notifier);

        userNotifier.login('old@example.com', 'password');
        userNotifier.updateProfile(
          name: 'Jane Doe',
          email: 'new@example.com',
        );

        final userState = container.read(userProvider);
        expect(userState.name, 'Jane Doe');
        expect(userState.email, 'new@example.com');
      });
    });

    // ========================================================================
    // GROUP 2: Theme Provider (3 tests)
    // ========================================================================
    group('Theme Provider', () {
      test('1. Theme provider initializes with light mode', () {
        final container = ProviderContainer();
        final themeState = container.read(themeProvider);

        expect(themeState.isDarkMode, isFalse);
        expect(themeState.accentColor, 'blue');
      });

      test('2. Theme dark mode toggle works correctly', () {
        final container = ProviderContainer();
        final themeNotifier = container.read(themeProvider.notifier);

        themeNotifier.toggleDarkMode();

        var themeState = container.read(themeProvider);
        expect(themeState.isDarkMode, isTrue);

        themeNotifier.toggleDarkMode();

        themeState = container.read(themeProvider);
        expect(themeState.isDarkMode, isFalse);
      });

      test('3. Theme accent color can be changed', () {
        final container = ProviderContainer();
        final themeNotifier = container.read(themeProvider.notifier);

        themeNotifier.setAccentColor('red');

        var themeState = container.read(themeProvider);
        expect(themeState.accentColor, 'red');

        themeNotifier.setAccentColor('green');

        themeState = container.read(themeProvider);
        expect(themeState.accentColor, 'green');
      });

      test('4. Theme state changes are independent', () {
        final container = ProviderContainer();
        final themeNotifier = container.read(themeProvider.notifier);

        themeNotifier.toggleDarkMode();
        themeNotifier.setAccentColor('purple');

        final themeState = container.read(themeProvider);
        expect(themeState.isDarkMode, isTrue);
        expect(themeState.accentColor, 'purple');
      });
    });

    // ========================================================================
    // GROUP 3: Notification Provider (4 tests)
    // ========================================================================
    group('Notification Provider', () {
      test('1. Notification provider initializes empty', () {
        final container = ProviderContainer();
        final notifState = container.read(notificationProvider);

        expect(notifState.messages, isEmpty);
        expect(notifState.unreadCount, 0);
      });

      test('2. Adding notification increments unread count', () {
        final container = ProviderContainer();
        final notifNotifier = container.read(notificationProvider.notifier);

        notifNotifier.addNotification('New message');

        final notifState = container.read(notificationProvider);
        expect(notifState.messages, hasLength(1));
        expect(notifState.unreadCount, 1);
      });

      test('3. Multiple notifications accumulate correctly', () {
        final container = ProviderContainer();
        final notifNotifier = container.read(notificationProvider.notifier);

        notifNotifier.addNotification('Message 1');
        notifNotifier.addNotification('Message 2');
        notifNotifier.addNotification('Message 3');

        final notifState = container.read(notificationProvider);
        expect(notifState.messages, hasLength(3));
        expect(notifState.unreadCount, 3);
      });

      test('4. Mark as read clears unread count', () {
        final container = ProviderContainer();
        final notifNotifier = container.read(notificationProvider.notifier);

        notifNotifier.addNotification('Message');
        notifNotifier.markAsRead();

        final notifState = container.read(notificationProvider);
        expect(notifState.unreadCount, 0);
        expect(notifState.messages, hasLength(1)); // Messages retained
      });

      test('5. Clear all resets notification state', () {
        final container = ProviderContainer();
        final notifNotifier = container.read(notificationProvider.notifier);

        notifNotifier.addNotification('Message 1');
        notifNotifier.addNotification('Message 2');
        notifNotifier.clearAll();

        final notifState = container.read(notificationProvider);
        expect(notifState.messages, isEmpty);
        expect(notifState.unreadCount, 0);
      });
    });

    // ========================================================================
    // GROUP 4: Provider Container Isolation (1 test)
    // ========================================================================
    group('Provider Isolation', () {
      test('1. Multiple containers maintain separate state', () {
        final container1 = ProviderContainer();
        final container2 = ProviderContainer();

        final notifier1 = container1.read(userProvider.notifier);
        final notifier2 = container2.read(userProvider.notifier);

        notifier1.login('user1@example.com', 'pass1');
        notifier2.login('user2@example.com', 'pass2');

        final state1 = container1.read(userProvider);
        final state2 = container2.read(userProvider);

        expect(state1.email, 'user1@example.com');
        expect(state2.email, 'user2@example.com');
      });
    });
  });
}
