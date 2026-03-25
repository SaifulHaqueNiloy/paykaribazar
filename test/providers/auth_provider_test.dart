import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock Auth Model
class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final bool isEmailVerified;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.isEmailVerified = false,
  });
}

// Mock Auth State Notifier
class AuthStateNotifier extends StateNotifier<User?> {
  AuthStateNotifier() : super(null);

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password required');
    }
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    state = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: email.split('@')[0],
      isEmailVerified: true,
    );
  }

  Future<void> logout() async {
    state = null;
  }

  Future<void> signup(String email, String password, String name) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('All fields required');
    }
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    state = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      isEmailVerified: false,
    );
  }

  Future<void> verifyEmail() async {
    if (state != null) {
      state = User(
        id: state!.id,
        email: state!.email,
        name: state!.name,
        photoUrl: state!.photoUrl,
        isEmailVerified: true,
      );
    }
  }

  Future<void> updateProfile({String? name, String? photoUrl}) async {
    if (state != null) {
      state = User(
        id: state!.id,
        email: state!.email,
        name: name ?? state!.name,
        photoUrl: photoUrl ?? state!.photoUrl,
        isEmailVerified: state!.isEmailVerified,
      );
    }
  }
}

// Mock providers
final authProvider = StateNotifierProvider<AuthStateNotifier, User?>((ref) {
  return AuthStateNotifier();
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider);
});

void main() {
  group('Auth Provider Tests', () {
    // ========================================================================
    // GROUP 1: Login (4 tests)
    // ========================================================================
    group('Auth - Login', () {
      test('1. User not logged in initially', () {
        final container = ProviderContainer();

        expect(container.read(authProvider), isNull);
        expect(container.read(isLoggedInProvider), isFalse);
      });

      test('2. Successful login sets user state', () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authProvider.notifier);

        await authNotifier.login('test@example.com', 'password123');

        expect(container.read(isLoggedInProvider), isTrue);
        expect(container.read(currentUserProvider)?.email, 'test@example.com');
      });

      test('3. Login fails with invalid email', () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authProvider.notifier);

        expect(
          () => authNotifier.login('invalidemail', 'password123'),
          throwsA(isA<Exception>()),
        );
      });

      test('4. Login fails with short password', () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authProvider.notifier);

        expect(
          () => authNotifier.login('test@example.com', '123'),
          throwsA(isA<Exception>()),
        );
      });
    });

    // ========================================================================
    // GROUP 2: Logout (3 tests)
    // ========================================================================
    group('Auth - Logout', () {
      test('1. Logout clears user state', () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authProvider.notifier);

        await authNotifier.login('test@example.com', 'password123');
        expect(container.read(isLoggedInProvider), isTrue);

        await authNotifier.logout();
        expect(container.read(isLoggedInProvider), isFalse);
        expect(container.read(authProvider), isNull);
      });

      test('2. Logout when not logged in', () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authProvider.notifier);

        expect(container.read(isLoggedInProvider), isFalse);
        await authNotifier.logout();
        expect(container.read(isLoggedInProvider), isFalse);
      });

      test('3. Multiple logout calls safe', () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authProvider.notifier);

        await authNotifier.login('test@example.com', 'password123');
        await authNotifier.logout();
        await authNotifier.logout(); // Second logout should not throw

        expect(container.read(isLoggedInProvider), isFalse);
      });
    });

    // ========================================================================
    // GROUP 3: Signup (3 tests)
    // ========================================================================
    group('Auth - Signup', () {
      test('1. Successful signup creates user', () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authProvider.notifier);

        await authNotifier.signup('newuser@example.com', 'password123', 'John Doe');

        expect(container.read(isLoggedInProvider), isTrue);
        expect(container.read(currentUserProvider)?.email, 'newuser@example.com');
        expect(container.read(currentUserProvider)?.name, 'John Doe');
      });

      test('2. Signup fails with missing fields', () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authProvider.notifier);

        expect(
          () => authNotifier.signup('', 'password123', 'John'),
          throwsA(isA<Exception>()),
        );
      });

      test('3. New user email not verified initially', () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authProvider.notifier);

        await authNotifier.signup('newuser@example.com', 'password123', 'Jane');

        expect(container.read(currentUserProvider)?.isEmailVerified, isFalse);
      });
    });

    // ========================================================================
    // GROUP 4: User Management (3 tests)
    // ========================================================================
    group('Auth - User Management', () {
      test('1. Verify email after signup', () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authProvider.notifier);

        await authNotifier.signup('user@example.com', 'password123', 'User');
        expect(container.read(currentUserProvider)?.isEmailVerified, isFalse);

        await authNotifier.verifyEmail();
        expect(container.read(currentUserProvider)?.isEmailVerified, isTrue);
      });

      test('2. Update user profile', () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authProvider.notifier);

        await authNotifier.login('test@example.com', 'password123');
        await authNotifier.updateProfile(name: 'Updated Name', photoUrl: 'https://example.com/photo.jpg');

        expect(container.read(currentUserProvider)?.name, 'Updated Name');
        expect(container.read(currentUserProvider)?.photoUrl, 'https://example.com/photo.jpg');
      });

      test('3. Update profile preserves existing data', () async {
        final container = ProviderContainer();
        final authNotifier = container.read(authProvider.notifier);

        await authNotifier.signup('original@example.com', 'password123', 'Original Name');
        final originalEmail = container.read(currentUserProvider)?.email;

        await authNotifier.updateProfile(name: 'New Name');

        expect(container.read(currentUserProvider)?.email, originalEmail);
        expect(container.read(currentUserProvider)?.name, 'New Name');
      });
    });
  });
}
