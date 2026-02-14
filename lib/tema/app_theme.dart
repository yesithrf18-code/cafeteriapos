import 'package:flutter/material.dart';

class AppTheme {
  static const Color naranjaPrincipal = Colors.orange;

  // TEMA CLARO
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: naranjaPrincipal,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
    ),
    // EL CAMBIO ESTÁ AQUÍ: CardThemeData en lugar de CardTheme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    colorScheme: ColorScheme.light(
      primary: naranjaPrincipal,
      secondary: Colors.teal,
      surface: Colors.white,
    ),
  );

  // TEMA OSCURO
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: naranjaPrincipal,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
    ),
    // EL CAMBIO ESTÁ AQUÍ: CardThemeData en lugar de CardTheme
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    ),
    colorScheme: ColorScheme.dark(
      primary: naranjaPrincipal,
      secondary: Colors.orangeAccent,
      surface: const Color(0xFF1E1E1E),
    ),
  );
}