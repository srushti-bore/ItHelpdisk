import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';

/// NextAssist Unified Theme Configuration
/// Strictly governed by `Design.md`:
/// - Indigo (#6366F1) primary accent, Soft Blue (#3B82F6) & Soft Purple (#8B5CF6)
/// - Light Background: #FAFAFA, Surface: #FFFFFF, Text: #111827
/// - Dark Background: #0F172A, Surface: #111827, CardDark: #1E293B, Text: #E5E7EB
/// - Space Grotesk for Headers & Metrics; Public Sans for UI & Body
/// - 1px Subtle Hairlines, 8pt/12pt dynamic grid foundation
class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.publicSansTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary, // Indigo (#6366F1)
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryTint,
        secondary: AppColors.secondary, // Soft Blue (#3B82F6)
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryTint,
        tertiary: AppColors.slateTeal, // Slate-Teal (#0D9488)
        onTertiary: AppColors.onTertiary,
        surface: AppColors.surface, // Clean Pure White (#FFFFFF)
        onSurface: AppColors.onSurface, // #111827
        onSurfaceVariant: AppColors.onSurfaceVariant, // #6B7280
        outline: AppColors.outline,
        outlineVariant: AppColors.hairlineBorder, // #E5E7EB
        error: AppColors.dangerRose,
        onError: AppColors.onError,
        errorContainer: AppColors.dangerTint,
      ),
      scaffoldBackgroundColor: AppColors.background, // #FAFAFA
      canvasColor: AppColors.background,

      // Dual Typography: Space Grotesk for Headers/Metrics, Public Sans for UI & Body
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.onSurface, letterSpacing: -0.8),
        headlineLarge: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.onSurface, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.onSurface, letterSpacing: -0.3),
        headlineSmall: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        titleLarge: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        titleMedium: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        titleSmall: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        bodyLarge: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface, height: 1.5),
        bodyMedium: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.onSurface, height: 1.45),
        bodySmall: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
        labelLarge: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        labelMedium: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
        labelSmall: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
      ),

      // Architectural Depth System: Flat White Card with 1px Hairline Rule
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.hairlineBorder, width: 1),
        ),
      ),

      // Input Fields: Fluid Padding, 8px Radius, 1px Hairline Border, Focus Accent
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.publicSans(color: AppColors.textMuted, fontSize: 13),
        labelStyle: GoogleFonts.publicSans(color: AppColors.onSurfaceVariant, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.hairlineBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.hairlineBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.dangerRose, width: 1),
        ),
      ),

      // Buttons: Indigo Accent, Sentence Case, 8px Radius, Subtle Shadow
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
          textStyle: GoogleFonts.publicSans(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.hairlineBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
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
        primary: AppColors.primaryContainer,
        onPrimary: AppColors.onPrimary,
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
        displayLarge: GoogleFonts.spaceGrotesk(fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark, letterSpacing: -0.8),
        headlineLarge: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textPrimaryDark, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark, letterSpacing: -0.3),
        headlineSmall: GoogleFonts.spaceGrotesk(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        titleLarge: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        titleMedium: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        titleSmall: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimaryDark),
        bodyLarge: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimaryDark, height: 1.5),
        bodyMedium: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textPrimaryDark, height: 1.45),
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
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.publicSans(color: AppColors.textSecondaryDark, fontSize: 13),
        labelStyle: GoogleFonts.publicSans(color: AppColors.textSecondaryDark, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
          textStyle: GoogleFonts.publicSans(fontWeight: FontWeight.w600, fontSize: 13),
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
