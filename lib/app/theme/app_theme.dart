import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color customerPrimary = Color(0xFFFF5E00); // Orange
  static const Color restaurantPrimary = Color(0xFF00A859); // Green
  
  static const Color background = Color(0xFFF9FAFB); // Light background gray
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1F2937); // Charcoal
  static const Color textLight = Color(0xFF6B7280); // Gray text
  static const Color border = Color(0xFFE5E7EB); // Cool gray border
  
  static ThemeData getTheme({required bool isRestaurant}) {
    final primaryColor = isRestaurant ? restaurantPrimary : customerPrimary;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        background: background,
        surface: surface,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textDark),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textDark),
        displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textDark),
        headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textDark),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textDark),
        headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: textDark),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: textDark),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: textDark),
        titleSmall: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: textLight),
        bodyLarge: GoogleFonts.outfit(fontWeight: FontWeight.normal, color: textDark),
        bodyMedium: GoogleFonts.outfit(fontWeight: FontWeight.normal, color: textLight),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: GoogleFonts.outfit(color: textLight, fontSize: 14),
        hintStyle: GoogleFonts.outfit(color: textLight.withOpacity(0.6), fontSize: 14),
        prefixIconColor: textLight,
        suffixIconColor: textLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          alignment: Alignment.center,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
