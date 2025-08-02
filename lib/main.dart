import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'widgets/auth_wrapper.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/test_image_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AlbertInfinityApp());
}

class AlbertInfinityApp extends StatelessWidget {
  const AlbertInfinityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Albert Infinity',
      theme: appTheme,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/test-images': (context) => const TestImageWidget(),
      },
    );
  }
}
