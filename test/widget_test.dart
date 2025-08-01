// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:albert_infinity/main.dart';

void main() {
  testWidgets('App loads login page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AlbertInfinityApp());

    // Verify that the login page is displayed
    expect(find.text('Albert Infinity'), findsOneWidget);
    expect(find.text('Seu personal trainer digital'), findsOneWidget);
    expect(find.text('Usuário'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('Login navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AlbertInfinityApp());

    // Tap the login button
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    // Verify that we navigated to the home page
    expect(find.text('Olá, João Silva! 👋'), findsOneWidget);
    expect(find.text('Vamos treinar hoje?'), findsOneWidget);
  });
}
