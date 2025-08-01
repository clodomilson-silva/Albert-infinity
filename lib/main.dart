import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'pages/login_page.dart';

void main() => runApp(const AlbertInfinityApp());

class AlbertInfinityApp extends StatelessWidget {
  const AlbertInfinityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Albert Infinity',
      theme: appTheme,
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
