import 'package:flutter/material.dart';

/// App Theme Configuration
/// Menyimpan tema aplikasi untuk konsistensi UI
class AppTheme {
  // Colors - Warm & Cozy Palette (Updated to Brown Theme)
  static const Color primaryColor = Color(0xFFA23900);      // Brown/Burnt Orange (PRIMARY)
  static const Color secondaryColor = Color(0xFFF4B942);    // Golden Yellow
  static const Color accentColor = Color(0xFF2D7D87);       // Deep Teal
  static const Color errorColor = Color(0xFFE84C3D);        // Coral Red
  static const Color successColor = Color(0xFF00C9A7);      // Mint Green
  static const Color warningColor = Color(0xFFFFB347);      // Peach
  
  static const Color backgroundColor = Color(0xFFFAF9F6);   // Warm White
  static const Color surfaceColor = Color(0xFFFFF8F0);      // Cream White
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF1A1A1A);  // Warm Black
  static const Color textSecondaryColor = Color(0xFF58423A); // Brown Grey
  static const Color borderColor = Color(0xFFE8DED2);       // Warm Grey
  
  // Status Colors - Non-standard
  static const Color statusPaid = Color(0xFF00C9A7);        // Mint (Lunas)
  static const Color statusPending = Color(0xFFC77DFF);     // Purple (Pending)
  static const Color statusRejected = Color(0xFF6B4423);    // Brown (Ditolak)
  static const Color statusOverdue = Color(0xFFE84C3D);     // Coral Red (Terlambat)
  static const Color statusInProgress = Color(0xFFFFB347);  // Peach (Diproses)
  static const Color statusCompleted = Color(0xFF046670);   // Teal (Selesai)
  
  // Text Styles - Odd sizes
  static const TextStyle displayText = TextStyle(
    fontSize: 37,
    fontWeight: FontWeight.w800,
    color: textPrimaryColor,
    letterSpacing: -0.37,
  );
  
  static const TextStyle heading1 = TextStyle(
    fontSize: 29,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    color: textPrimaryColor,
    height: 1.30,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    height: 1.26,
  );
  
  static const TextStyle bodyText1 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textPrimaryColor,
    height: 1.47,
  );
  
  static const TextStyle bodyText2 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondaryColor,
    height: 1.38,
    letterSpacing: 0.13,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textSecondaryColor,
    height: 1.27,
    letterSpacing: 0.22,
  );
  
  static const TextStyle smallText = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: textSecondaryColor,
    height: 1.50,
  );
  
  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 23,
          fontWeight: FontWeight.w700,
          height: 1.30,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: borderColor),
          borderRadius: BorderRadius.circular(17),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 19, vertical: 13),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withValues(alpha: 0.5);
          }
          return null;
        }),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
    );
  }
}
