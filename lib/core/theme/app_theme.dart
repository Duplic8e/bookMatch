import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Library-inspired palette
  static const Color _bgColor       = Color(0xFFFAF7F1);
  static const Color _woodColor     = Color(0xFF8B5E3C);
  static const Color _accentColor   = Color(0xFFD9B382);
  // A very light container tint derived from woodColor:
  static final Color _woodContainer = _woodColor.withOpacity(0.10);

  // Your display font
  static const String _fontFamily = 'Ancient Medium';

  /// Light theme for library look
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return ThemeData(
      fontFamily: _fontFamily,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _bgColor,
      primaryColor: _woodColor,

      colorScheme: base.colorScheme.copyWith(
        primary: _woodColor,
        onPrimary: Colors.white,
        primaryContainer: _woodContainer,           // ← added
        onPrimaryContainer: _woodColor,             // ← added
        secondary: _accentColor,
        background: _bgColor,
        surface: Colors.white,
        surfaceVariant: _woodContainer,             // ← added
        onSurfaceVariant: _woodColor.withOpacity(0.8),
        error: Colors.redAccent,
      ),

      iconTheme: const IconThemeData(color: _woodColor),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: _woodColor),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: _woodColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontFamily: _fontFamily,
          color: _woodColor,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontFamily: _fontFamily,
          color: _woodColor,
          fontSize: 23,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          color: _woodColor,
          fontSize: 16,
        ),
        bodySmall: TextStyle(
          fontFamily: _fontFamily,
          color: _woodColor,
          fontSize: 14,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          color: _woodColor.withOpacity(0.6),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _woodColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _woodColor,
        unselectedItemColor: _accentColor,
        showUnselectedLabels: true,
      ),
    );
  }

  /// Dark theme fallback (unchanged)
  static ThemeData get darkTheme => ThemeData(
    fontFamily: _fontFamily,
    brightness: Brightness.dark,
    primaryColor: Colors.teal,
    scaffoldBackgroundColor: Colors.grey[900],
    colorScheme: ThemeData.dark().colorScheme.copyWith(
      primary: Colors.teal,
      secondary: _accentColor,
      background: Colors.grey[900]!,
      surface: Colors.grey[800]!,
      error: Colors.redAccent,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily,
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        color: Colors.white70,
        fontSize: 16,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        color: Colors.white70,
        fontSize: 14,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      hintStyle: const TextStyle(
        fontFamily: _fontFamily,
        color: Colors.white54,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.white54,
    ),
  );

  /// Merriweather TextTheme helper
  static TextTheme get merriweatherTextTheme =>
      GoogleFonts.merriweatherTextTheme(lightTheme.textTheme);
}

/// Convenience extension
extension MerriweatherStyles on BuildContext {
  TextTheme get merriweather => AppTheme.merriweatherTextTheme;
}
