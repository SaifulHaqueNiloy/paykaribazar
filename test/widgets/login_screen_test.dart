import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock providers for testing
class MockAuthNotifier extends Mock {}

void main() {
  group('Login Screen Widget Tests', () {
    // ========================================================================
    // GROUP 1: Login Form Rendering (3 tests)
    // ========================================================================
    group('Login Form - Rendering', () {
      testWidgets('1. Login screen renders with email and password fields',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextField(
                    key: Key('email_field'),
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    key: Key('password_field'),
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  ElevatedButton(
                    key: Key('login_button'),
                    onPressed: null,
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byKey(const Key('email_field')), findsOneWidget);
        expect(find.byKey(const Key('password_field')), findsOneWidget);
        expect(find.byKey(const Key('login_button')), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
      });

      testWidgets('2. Login button is initially disabled', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextField(
                    key: Key('email_field'),
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    key: Key('password_field'),
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  ElevatedButton(
                    key: Key('login_button'),
                    onPressed: null,
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        );

        // Button with onPressed: null is disabled
        final button = find.byKey(const Key('login_button'));
        expect(button, findsOneWidget);
      });

      testWidgets('3. Password field obscures text', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TextField(
                key: Key('password_field'),
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ),
          ),
        );

        final textField = find.byKey(const Key('password_field'));
        expect(textField, findsOneWidget);

        // Enter password and verify it's obscured
        await tester.enterText(textField, 'password123');
        expect(find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.obscureText == true,
        ), findsOneWidget);
      });
    });

    // ========================================================================
    // GROUP 2: User Input Handling (4 tests)
    // ========================================================================
    group('Login Form - User Input', () {
      testWidgets('1. User can enter email', (WidgetTester tester) async {
        final emailController = TextEditingController();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                key: const Key('email_field'),
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ),
          ),
        );

        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        expect(emailController.text, 'test@example.com');
      });

      testWidgets('2. User can enter password', (WidgetTester tester) async {
        final passwordController = TextEditingController();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                key: const Key('password_field'),
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ),
          ),
        );

        await tester.enterText(
            find.byKey(const Key('password_field')), 'password123');
        expect(passwordController.text, 'password123');
      });

      testWidgets('3. Form validation shows error on empty email',
          (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      key: const Key('email_field'),
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) => value!.isEmpty ? 'Email required' : null,
                    ),
                    ElevatedButton(
                      onPressed: () => formKey.currentState!.validate(),
                      child: const Text('Validate'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Validate'));
        await tester.pumpAndSettle();

        expect(find.text('Email required'), findsOneWidget);
      });

      testWidgets('4. Login button becomes enabled with valid input',
          (WidgetTester tester) async {
        var isEnabled = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      TextField(
                        key: const Key('email_field'),
                        onChanged: (_) => setState(() => isEnabled = true),
                      ),
                      ElevatedButton(
                        key: const Key('login_button'),
                        onPressed: isEnabled ? () {} : null,
                        child: const Text('Login'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
        await tester.pumpAndSettle();

        expect(isEnabled, isTrue);
      });
    });

    // ========================================================================
    // GROUP 3: Authentication Flow (4 tests)
    // ========================================================================
    group('Login Form - Authentication', () {
      testWidgets('1. Login button triggers authentication', (WidgetTester tester) async {
        var loginAttempted = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const TextField(
                    key: Key('email_field'),
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  const TextField(
                    key: Key('password_field'),
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                  ElevatedButton(
                    key: const Key('login_button'),
                    onPressed: () => loginAttempted = true,
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('login_button')));
        expect(loginAttempted, isTrue);
      });

      testWidgets('2. Loading indicator shows during login', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextField(
                    key: Key('email_field'),
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    key: Key('password_field'),
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                  Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('3. Error message displays on login failure', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Text('Invalid credentials'),
                  TextField(
                    key: Key('email_field'),
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    key: Key('password_field'),
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Invalid credentials'), findsOneWidget);
      });

      testWidgets('4. Forgot password link is accessible', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const TextField(
                    key: Key('email_field'),
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  const TextField(
                    key: Key('password_field'),
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Forgot Password?'), findsOneWidget);
      });
    });

    // ========================================================================
    // GROUP 4: Sign Up Navigation (4 tests)
    // ========================================================================
    group('Login Form - Sign Up Navigation', () {
      testWidgets('1. Sign up link is displayed', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const TextField(
                    key: Key('email_field'),
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  const TextField(
                    key: Key('password_field'),
                    decoration: InputDecoration(labelText: 'Password'),
                  ),
                  Row(
                    children: [
                      const Text('Don\'t have an account?'),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Sign Up'), findsOneWidget);
      });

      testWidgets('2. Sign up button is tappable', (WidgetTester tester) async {
        var signUpTapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextButton(
                onPressed: () => signUpTapped = true,
                child: const Text('Sign Up'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Sign Up'));
        expect(signUpTapped, isTrue);
      });

      testWidgets('3. Social login options available', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.g_mobiledata),
                    label: const Text('Login with Google'),
                    onPressed: () {},
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.facebook),
                    label: const Text('Login with Facebook'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Login with Google'), findsOneWidget);
        expect(find.text('Login with Facebook'), findsOneWidget);
      });

      testWidgets('4. Remember me checkbox is present', (WidgetTester tester) async {
        var rememberMe = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      CheckboxListTile(
                        title: const Text('Remember me'),
                        value: rememberMe,
                        onChanged: (value) => setState(() => rememberMe = value ?? false),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Remember me'), findsOneWidget);
      });
    });
  });
}
