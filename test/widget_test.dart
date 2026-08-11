// Trillion Chats tests: auth + chat flows.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/State/AppState.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppState.instance.init();
  });

  testWidgets('Login screen shows and demo account login works',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Trillion Chats'), findsWidgets);
    expect(find.byKey(const Key('login_button')), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('login_username')), 'alice');
    await tester.enterText(
        find.byKey(const Key('login_password')), 'alice123');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('CHATS'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
  });

  testWidgets('Wrong password shows an error', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('login_username')), 'alice');
    await tester.enterText(
        find.byKey(const Key('login_password')), 'wrongpass');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.text('Invalid username or password'), findsOneWidget);
  });

  testWidgets('Signup creates an account and opens chats',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('signup_username')), 'Yuvanesh');
    await tester.enterText(
        find.byKey(const Key('signup_password')), 'secret123');
    await tester.enterText(
        find.byKey(const Key('signup_confirm')), 'secret123');
    await tester.ensureVisible(find.byKey(const Key('signup_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('signup_button')));
    await tester.pumpAndSettle();

    expect(find.text('CHATS'), findsOneWidget);
    expect(AppState.instance.currentUser?.username, 'Yuvanesh');
  });

  testWidgets('Search finds a user by name and opens a chat',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('login_username')), 'alice');
    await tester.enterText(
        find.byKey(const Key('login_password')), 'alice123');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextField, 'Search by name'), 'sara');
    await tester.pumpAndSettle();

    expect(find.text('Sara'), findsOneWidget);

    await tester.tap(find.text('Sara'));
    await tester.pumpAndSettle();

    expect(find.text('Message'), findsOneWidget);
  });
}
