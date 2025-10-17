import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // 1. Define base text theme with Poppins
    final TextTheme baseTextTheme = GoogleFonts.poppinsTextTheme(
      const TextTheme(
        // Set all base text colors to a darker color for contrast on the light background
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        // ... and so on for other text styles
      ),
    );

    return ThemeData(
      // 2. Color Palette
      primaryColor: AppColors.primarySkyBlue,
      scaffoldBackgroundColor: AppColors.backgroundLightGray,
      brightness: Brightness.light,
      
      colorScheme: ColorScheme.light(
        primary: AppColors.primarySkyBlue,
        secondary: AppColors.secondaryBlue,
        background: AppColors.backgroundLightGray,
        onPrimary: AppColors.textWhite,
      ),

      // 3. Typography (Poppins + weights)
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: baseTextTheme.copyWith(
        // Apply weights based on your spec
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w600), // Headings
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500), // Subtitles
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400), // Body Text
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
      ),

      // 4. UI Components (Buttons and Cards)
      cardTheme: CardTheme(
        color: AppColors.secondaryBlue, // Blue (#007BFF) for card background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4, // Soft, low elevation
        shadowColor: AppColors.secondaryBlue.withOpacity(0.5),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.textWhite,
          backgroundColor: AppColors.primarySkyBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners (12)
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: baseTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600, // Semi-bold button text
          ),
          elevation: 5, // Elevated style
        ),
      ),
    );
  }
}