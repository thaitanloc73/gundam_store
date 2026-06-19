import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  static const Color gundamRed = Color(0xFFE8002D);
  static const Color gundamRedDark = Color(0xFFB0001F);
  static const Color gundamGold = Color(0xFFFFB800);
  static const Color darkBg = Color(0xFF0D0D0F);
  static const Color darkSurface = Color(0xFF1A1A1E);
  static const Color darkCard = Color(0xFF242428);
  static const Color darkBorder = Color(0xFF2E2E34);
  static const Color lightBg = Color(0xFFF0F0F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF8F8FC);

  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: gundamRed,
    colorScheme: const ColorScheme.dark(
      primary: gundamRed,
      secondary: gundamGold,
      surface: darkSurface,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: gundamRed,
      unselectedItemColor: Color(0xFF666670),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: darkBorder, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gundamRed,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: gundamRed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: gundamRed),
      ),
      labelStyle: const TextStyle(color: Color(0xFF888890)),
      hintStyle: const TextStyle(color: Color(0xFF555560)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkCard,
      selectedColor: gundamRed.withOpacity(0.2),
      side: const BorderSide(color: darkBorder),
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    dividerColor: darkBorder,
    iconTheme: const IconThemeData(color: Color(0xFF888890)),
  );

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: gundamRed,
    colorScheme: const ColorScheme.light(
      primary: gundamRed,
      secondary: gundamGold,
      surface: lightSurface,
      onPrimary: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: const Color(0xFF0D0D0F),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        color: Color(0xFF0D0D0F),
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      shadowColor: Colors.black.withOpacity(0.05),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: gundamRed,
      unselectedItemColor: Color(0xFFAAAAAA),
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gundamRed,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: gundamRed, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: gundamRed),
      ),
    ),
    dividerColor: Colors.grey.shade200,
  );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}