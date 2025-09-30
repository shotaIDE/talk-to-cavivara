import 'package:flutter/material.dart';

ThemeData getDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.dark,
    ),
  );
}
