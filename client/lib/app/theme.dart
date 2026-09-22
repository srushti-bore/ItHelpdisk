import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';

/// Calmdesk IT Service Desk Unified Theme Configuration
/// Governed by DESIGN.md: Space Grotesk + Public Sans, 1px Hairlines, Zero Green.
class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.publicSansTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryContainer, // #8C93E8
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryTint,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceContainerLowest, // #FFFFFF
        onSurface: AppColors.onSurface, // #2B2A28
        onSurfaceVariant: AppColors.onSurfaceVariant, // #6B6862
        outline: AppColors.outline,
        outlineVariant: AppColors.hairlineBorder, // #E7E4DC
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background, // #F7F6F3
      canvasColor: AppColors.background,
      
      // Typography: Space Grotesk for Headers & Numbers; Public Sans for UI & Body
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        headlineLarge: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        headlineMedium: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        headlineSmall: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        titleLarge: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        titleMedium: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        titleSmall: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        bodyLarge: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface),
        bodyMedium: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.onSurface),
        bodySmall: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
        labelLarge: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        labelMedium: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
        labelSmall: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
      ),

      // Architectural Depth System: Flat White Card with 1px Hairline Rule
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest, // #FFFFFF
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.hairlineBorder, width: 1),
        ),
      ),

      // Input Fields: 8px Radius, 1px Hairline Border, Focus Accent
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.publicSans(color: AppColors.textMuted, fontSize: 13),
        labelStyle: GoogleFonts.publicSans(color: AppColors.onSurfaceVariant, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.hairlineBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.hairlineBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.dangerRose, width: 1),
        ),
      ),

      // Buttons: Flat, Sentence Case, 8px Radius, No Ambient Shadow
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer, // #8C93E8
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          textStyle: GoogleFonts.publicSans(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceContainerLowest,
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.hairlineBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          textStyle: GoogleFonts.publicSans(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.hairlineBorder,
        thickness: 1,
        space: 1,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        shape: const Border(bottom: BorderSide(color: AppColors.hairlineBorder, width: 1)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.publicSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
        outline: AppColors.outline,
        outlineVariant: AppColors.borderDark,
        error: AppColors.dangerRose,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      canvasColor: AppColors.bgDark,
      
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
        headlineLarge: GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
        headlineMedium: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
        headlineSmall: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        titleLarge: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        titleMedium: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
        titleSmall: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
        bodyLarge: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimaryDark),
        bodyMedium: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textPrimaryDark),
        bodySmall: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondaryDark),
        labelLarge: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
        labelMedium: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondaryDark),
        labelSmall: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondaryDark),
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.publicSans(color: AppColors.textSecondaryDark, fontSize: 13),
        labelStyle: GoogleFonts.publicSans(color: AppColors.textSecondaryDark, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          textStyle: GoogleFonts.publicSans(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        shape: const Border(bottom: BorderSide(color: AppColors.borderDark, width: 1)),
      ),
    );
  }
}
