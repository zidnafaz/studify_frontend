import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class AuthRobot {
  final WidgetTester tester;

  AuthRobot(this.tester);

  // Finders
  Finder get loginButtonOnWelcome => find.byKey(const Key('welcome_login_btn'));
  Finder get registerButtonOnWelcome =>
      find.byKey(const Key('welcome_register_btn'));

  // Login Finders
  Finder get emailField => find.byKey(const Key('login_email_field'));
  Finder get passwordField => find.byKey(const Key('login_password_field'));
  Finder get loginSubmitButton => find.byKey(const Key('login_submit_btn'));

  // Register Screen Finders
  Finder get registerNameField => find.byKey(const Key('register_name_field'));
  Finder get registerEmailField =>
      find.byKey(const Key('register_email_field'));
  Finder get registerPasswordField =>
      find.byKey(const Key('register_password_field'));
  Finder get registerConfirmPasswordField =>
      find.byKey(const Key('register_confirm_password_field'));
  Finder get registerSubmitButton =>
      find.byKey(const Key('register_submit_btn'));

  // Actions
  Future<void> navigateToLogin() async {
    await tester.tap(loginButtonOnWelcome);
    await tester.pumpAndSettle();
  }

  Future<void> navigateToRegister() async {
    await tester.tap(registerButtonOnWelcome);
    await tester.pumpAndSettle();
  }

  Future<void> login(String email, String password) async {
    // Fill email
    await tester.enterText(emailField, email);
    await tester.pump(); // Minor pump to process text input events if needed

    // Fill password
    await tester.enterText(passwordField, password);
    await tester.pump();

    // Tap Submit
    await tester.tap(loginSubmitButton);
    await tester.pumpAndSettle();
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    await tester.enterText(registerNameField, name);
    await tester.pump();
    await tester.enterText(registerEmailField, email);
    await tester.pump();
    await tester.enterText(registerPasswordField, password);
    await tester.pump();
    await tester.enterText(registerConfirmPasswordField, confirmPassword);
    await tester.pump();

    await tester.tap(registerSubmitButton);
    await tester.pumpAndSettle();
  }

  Future<void> verifyOnWelcomeScreen() async {
    expect(loginButtonOnWelcome, findsOneWidget);
  }

  Future<void> tapLoginButton() async {
    await tester.tap(loginButtonOnWelcome);
    await tester.pumpAndSettle();
  }

  Future<void> tapRegisterButton() async {
    await tester.tap(registerButtonOnWelcome);
    await tester.pumpAndSettle();
  }

  Future<void> verifyOnLoginScreen() async {
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
  }

  Future<void> verifyOnRegisterScreen() async {
    expect(registerNameField, findsOneWidget);
    expect(registerEmailField, findsOneWidget);
  }

  Future<void> verifyHomeVisible() async {
    expect(find.text('Studify'), findsOneWidget); // App Bar title
    expect(find.byIcon(Icons.home), findsOneWidget); // Bottom Nav
  }

  Future<void> verifyErrorSnackBar() async {
    expect(find.byType(SnackBar), findsOneWidget);
    // Optional: check color or text if possible
  }
}
