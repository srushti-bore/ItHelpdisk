import 'package:flutter/material.dart';

/// NextAssist Design System — Advanced Professional Palette & Glassmorphic Tokens
/// Strictly adheres to `Design.md`:
/// - Primary Accent: Indigo (#6366F1)
/// - Secondary Accents: Soft Blue (#3B82F6) & Soft Purple (#8B5CF6)
/// - Base Light: Background (#FAFAFA), Surface (#FFFFFF), Text (#111827)
/// - Base Dark: Background (#0F172A), Surface (#111827), Text (#E5E7EB)
/// - Selective Glassmorphism: Highlight layer only (AI Panel, Notifications, Modals)
/// - Total Prohibition on Harsh Green & Over-Pastel/Faded UI
class AppColors {
  // --- 1. Primary Accent — Indigo ---
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryContainer = Color(0xFF818CF8); // Soft Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFFA5B4FC);
  static const Color primaryTint = Color(0xFFEEF2FF); // 50-tint Indigo
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF312E81);

  // --- 2. Secondary Accents — Soft Blue & Soft Purple ---
  static const Color secondary = Color(0xFF3B82F6); // Soft Blue
  static const Color secondaryContainer = Color(0xFF60A5FA);
  static const Color secondaryTint = Color(0xFFEFF6FF);
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color purple = Color(0xFF8B5CF6); // Soft Purple
  static const Color purpleTint = Color(0xFFF5F3FF);

  // --- 3. Base Light Mode Foundations ---
  static const Color background = Color(0xFFFAFAFA); // Crisp neutral light canvas
  static const Color backgroundSecondary = Color(0xFFF3F4F6);
  static const Color surface = Color(0xFFFFFFFF); // Pure white solid card
  static const Color surfaceSecondary = Color(0xFFF3F4F6);
  static const Color surfaceDim = Color(0xFFF3F4F6);
  static const Color surfaceBright = Color(0xFFFFFFFF);

  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF9FAFB);
  static const Color surfaceContainer = Color(0xFFF3F4F6);
  static const Color surfaceContainerHigh = Color(0xFFE5E7EB);
  static const Color surfaceContainerHighest = Color(0xFFD1D5DB);

  static const Color border = Color(0xFFE5E7EB); // Subtle hairline
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderHover = Color(0xFFD1D5DB);
  static const Color hairlineBorder = Color(0xFFE5E7EB);
  static const Color outline = Color(0xFF9CA3AF);
  static const Color outlineVariant = Color(0xFFE5E7EB);

  // --- 4. Base Dark Mode Foundations ---
  static const Color bgDark = Color(0xFF0F172A); // Deep slate neutral dark
  static const Color surfaceDark = Color(0xFF111827); // Dark surface
  static const Color cardDark = Color(0xFF1E293B); // Elevated card in dark mode
  static const Color borderDark = Color(0xFF334155); // Dark hairline border
  static const Color borderDarkHover = Color(0xFF475569);

  // --- 5. Typography Tones ---
  static const Color onSurface = Color(0xFF111827); // High contrast dark text
  static const Color onSurfaceVariant = Color(0xFF6B7280); // Muted annotations
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFE5E7EB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // --- 6. Semantic Statuses & Priorities (ZERO HARSH GREEN RULE) ---
  // Using Slate-Teal/Cyan (#0D9488) for Resolved/Healthy states
  static const Color slateTeal = Color(0xFF0D9488); // Deep Slate-Teal
  static const Color slateTealTint = Color(0xFFCCFBF1);
  static const Color slateTealText = Color(0xFF115E59);
  static const Color tertiary = Color(0xFF0D9488);
  static const Color tertiaryContainer = Color(0xFF5EEAD4);
  static const Color onTertiary = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningTint = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFF92400E);

  static const Color dangerRose = Color(0xFFF43F5E); // Rose/Red
  static const Color dangerTint = Color(0xFFFFE4E6);
  static const Color dangerText = Color(0xFF9F1239);
  static const Color error = Color(0xFFF43F5E);
  static const Color errorContainer = Color(0xFFFFE4E6);
  static const Color onError = Color(0xFFFFFFFF);

  // Priorities
  static const Color priorityP1 = Color(0xFFF43F5E); // Critical (Rose)
  static const Color priorityP2 = Color(0xFFFB923C); // High (Orange)
  static const Color priorityP3 = Color(0xFFF59E0B); // Medium (Amber)
  static const Color priorityP4 = Color(0xFF0D9488); // Low (Slate-Teal)

  static const Color priorityCritical = Color(0xFFF43F5E);
  static const Color priorityHigh = Color(0xFFFB923C);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF0D9488);

  // Statuses
  static const Color statusNew = Color(0xFF6366F1); // Indigo
  static const Color statusInProgress = Color(0xFF3B82F6); // Soft Blue
  static const Color statusAssigned = Color(0xFF8B5CF6); // Soft Purple
  static const Color statusAwaiting = Color(0xFFF59E0B); // Amber
  static const Color statusResolved = Color(0xFF0D9488); // Slate-Teal (No pure green)
  static const Color statusClosed = Color(0xFF6B7280); // Gray
  static const Color statusCancelled = Color(0xFF9CA3AF);

  // --- 7. Selective Liquid Glassmorphism Tokens (Design.md Section 5) ---
  // Light Mode Glass: rgba(255, 255, 255, 0.60) / Border: rgba(255, 255, 255, 0.30)
  static const Color glassSurfaceLight = Color(0x99FFFFFF); // 60% opacity white
  static const Color glassBorderLight = Color(0x4DFFFFFF); // 30% opacity white
  static const Color glassBorderLightAccent = Color(0x336366F1); // Subtle indigo glow border

  // Dark Mode Glass: rgba(17, 24, 39, 0.60) / Border: rgba(255, 255, 255, 0.08)
  static const Color glassSurfaceDark = Color(0x99111827); // 60% opacity dark slate
  static const Color glassBorderDark = Color(0x14FFFFFF); // 8% opacity white
  static const Color glassBorderDarkAccent = Color(0x40818CF8); // Subtle indigo glow

  static const Color glassSurface = Color(0x99FFFFFF);
  static const Color glassBorder = Color(0x4DFFFFFF);
  static const Color glassBorderSubtle = Color(0x336366F1);
  static const Color glassGlow = Color(0x206366F1);

  // Ambient Aurora Orbs
  static const Color auroraLavender = Color(0x256366F1);
  static const Color auroraPeach = Color(0x20FB923C);
  static const Color auroraTeal = Color(0x200D9488);
  static const Color auroraBlue = Color(0x203B82F6);
  static const Color auroraAmber = Color(0x18F59E0B);

  // --- 8. Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
    ],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF60A5FA),
    ],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D9488),
      Color(0xFF14B8A6),
    ],
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xB3FFFFFF),
      Color(0x80FFFFFF),
    ],
  );

  static const LinearGradient glassCardGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xB31E293B),
      Color(0x80111827),
    ],
  );

  // Convenient Aliases for compatibility
  static const Color mutedBlue = Color(0xFF3B82F6);
  static const Color mutedBlueTint = Color(0xFFEFF6FF);
  static const Color warmPeach = Color(0xFFFB923C);
  static const Color warmPeachTint = Color(0xFFFFEDD5);
  static const Color warmPeachText = Color(0xFF9A3412);
  static const Color sandBeige = Color(0xFFF3F4F6);

  static const Color rose = Color(0xFFF43F5E);
  static const Color roseTint = Color(0xFFFFE4E6);
  static const Color coral = Color(0xFFFB923C);
  static const Color coralTint = Color(0xFFFFEDD5);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberTint = Color(0xFFFEF3C7);
  static const Color bgLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color backgroundPrimary = Color(0xFFFAFAFA);
  static const Color accentBlue = Color(0xFF6366F1);
  static const Color card = Color(0xFFFFFFFF);
}
