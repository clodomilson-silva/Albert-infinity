import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final appTheme = ThemeData(
  scaffoldBackgroundColor: Colors.black,
  textTheme: GoogleFonts.poppinsTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
  primaryColor: const Color(0xFF7D4FFF),
  colorScheme: ColorScheme.dark().copyWith(
    primary: const Color(0xFF7D4FFF),
    secondary: const Color(0xFFBA9CFF),
  ),
);
