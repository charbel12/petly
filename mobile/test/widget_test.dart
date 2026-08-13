import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petly/features/auth/presentation/forgot_password_screen.dart';
import 'package:petly/features/auth/presentation/login_screen.dart';
import 'package:petly/features/auth/presentation/register_screen.dart';
import 'package:petly/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('Petly app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PetlyApp()));
    await tester.pump();
    // Allow async user/location/auth providers to settle without hanging on GPS.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Hi,'), findsOneWidget);
  });

  testWidgets('login screen validates empty fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('register screen validates name and short password', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: RegisterScreen()),
      ),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create account'));
    await tester.pump();
    expect(find.text('Enter your name'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Use at least 8 characters'), findsOneWidget);
  });

  testWidgets('forgot password screen validates empty email', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ForgotPasswordScreen()),
      ),
    );
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Send reset link'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Send reset link'));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
  });
}
