// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:albert_infinity/widgets/metric_tile.dart';
import 'package:albert_infinity/core/theme.dart';

void main() {
  testWidgets('MetricTile widget displays correctly', (WidgetTester tester) async {
    // Build the MetricTile widget
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const Scaffold(
          body: MetricTile(
            title: "Passos",
            value: "7.268",
            icon: Icons.directions_walk,
          ),
        ),
      ),
    );

    // Verify that the metric tile displays the correct values
    expect(find.text('Passos'), findsOneWidget);
    expect(find.text('7.268'), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsOneWidget);
  });

  testWidgets('MetricTile without icon works', (WidgetTester tester) async {
    // Build the MetricTile widget without icon
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const Scaffold(
          body: MetricTile(
            title: "Calorias",
            value: "415",
          ),
        ),
      ),
    );

    // Verify that the metric tile displays the correct values
    expect(find.text('Calorias'), findsOneWidget);
    expect(find.text('415'), findsOneWidget);
  });

  testWidgets('App theme is configured correctly', (WidgetTester tester) async {
    // Test if the theme is properly configured
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const Scaffold(
          body: Text('Test'),
        ),
      ),
    );

    // Check if the theme was applied
    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.scaffoldBackgroundColor, Colors.black);
    expect(app.theme?.primaryColor, const Color(0xFF7D4FFF));
  });
}
