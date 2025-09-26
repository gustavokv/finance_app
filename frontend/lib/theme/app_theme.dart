import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // fromSeed generates a complete color pallete starting with the seedColor
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFB497D6),
      brightness: Brightness.light,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF251351),
      brightness: Brightness.dark,
    ),
  );
}
