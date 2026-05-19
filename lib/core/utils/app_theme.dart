// RF: Complete dark theme for BarrioSeguro
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppConfig.background,
      cardColor: AppConfig.card,
      
      // Primary color
      primaryColor: AppConfig.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppConfig.primary,
        secondary: AppConfig.primaryLight,
        error: AppConfig.error,
        surface: AppConfig.surface,
        onSurface: AppConfig.textPrimary,
        onBackground: AppConfig.textPrimary,
      ),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppConfig.background,
        // elevation: 10,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppConfig.textPrimary,
        ),
      ),
      
      // Text themes
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppConfig.textPrimary,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppConfig.textPrimary,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppConfig.textPrimary,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppConfig.textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppConfig.textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppConfig.textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppConfig.textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppConfig.textSecondary,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppConfig.textTertiary,
        ),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.primary,
          foregroundColor: AppConfig.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConfig.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConfig.primary,
          side: const BorderSide(color: AppConfig.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConfig.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConfig.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConfig.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConfig.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConfig.error),
        ),
        hintStyle: GoogleFonts.outfit(color: AppConfig.textTertiary),
        labelStyle: GoogleFonts.outfit(color: AppConfig.textSecondary),
      ),
      
      // FAB theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppConfig.primary,
        foregroundColor: AppConfig.textPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      
      // Bottom nav theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConfig.card,
        selectedItemColor: AppConfig.primary,
        unselectedItemColor: AppConfig.textTertiary,
        showUnselectedLabels: true,
        elevation: 8,
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: AppConfig.surface,
        selectedColor: AppConfig.primary,
        labelStyle: GoogleFonts.outfit(color: AppConfig.textPrimary),
        secondaryLabelStyle: GoogleFonts.outfit(color: AppConfig.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppConfig.card,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
