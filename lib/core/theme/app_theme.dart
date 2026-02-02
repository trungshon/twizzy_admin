import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF1DA1F2);
  static const Color primaryDark = Color(0xFF0D8BD9);
  static const Color primaryLight = Color(0xFF71C9F8);

  // Background Colors
  static const Color backgroundColor = Color(0xFF15202B);
  static const Color surfaceColor = Color(0xFF192734);
  static const Color cardColor = Color(0xFF22303C);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8899A6);

  // Status Colors
  static const Color successColor = Color(0xFF17BF63);
  static const Color warningColor = Color(0xFFFFAD1F);
  static const Color errorColor = Color(0xFFE0245E);
  static const Color infoColor = Color(0xFF1DA1F2);

  // Verify Status Colors
  static const Color verifiedColor = Color(0xFF17BF63);
  static const Color unverifiedColor = Color(0xFFFFAD1F);
  static const Color bannedColor = Color(0xFFE0245E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryLight,
        surface: surfaceColor,
        error: errorColor,
      ),
      cardTheme: const CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: surfaceColor,
        selectedIconTheme: IconThemeData(color: primaryColor),
        unselectedIconTheme: IconThemeData(color: textSecondary),
        selectedLabelTextStyle: TextStyle(color: primaryColor),
        unselectedLabelTextStyle: TextStyle(
          color: textSecondary,
        ),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(cardColor),
        dataRowColor: WidgetStateProperty.all(surfaceColor),
        headingTextStyle: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle: const TextStyle(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        hintStyle: const TextStyle(color: textSecondary),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      iconTheme: const IconThemeData(color: textSecondary),
      dividerColor: cardColor,
    );
  }
}
