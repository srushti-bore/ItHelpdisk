import 'package:flutter/material.dart';

/// NextAssist Design System — Pastel sRGB Palette & Glassmorphic Tokens
/// Strictly adheres to `NextAssist — Design.md`:
/// - Soft Lavender, Muted Blue, Warm Peach, Light Beige / Sand
/// - Total Ban on Harsh Green & Neon Gradients
/// - Low Saturation, Soft Contrast, High Readability
/// - Liquid Glassmorphism & Subtle Glow Support
class AppColors {
  // --- 1. Canvas & Surface Foundations (Light Beige / Sand / Off-White) ---
  static const Color background = Color(0xFFF7F6F3); // Warm Sand/Off-White canvas
  static const Color backgroundSecondary = Color(0xFFFAF9F6);
  static const Color surface = Color(0xFFFFFFFF); // Clean pure white card
  static const Color surfaceDim = Color(0xFFEFECE6);
  static const Color surfaceBright = Color(0xFFFAF9F6);

  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF7F5F0);
  static const Color surfaceContainer = Color(0xFFF1EFEA);
  static const Color surfaceContainerHigh = Color(0xFFEAE6DF);
  static const Color surfaceContainerHighest = Color(0xFFE2DDD5);

  // --- 2. Hairline Framing & Outlines ---
  static const Color hairlineBorder = Color(0xFFE5E2DA); // 1px subtle hairline rule
  static const Color border = Color(0xFFE5E2DA);
  static const Color borderLight = Color(0xFFECEAE3);
  static const Color borderHover = Color(0xFFD4CFCA);
  static const Color outline = Color(0xFF767682);
  static const Color outlineVariant = Color(0xFFE5E2DA);

  // --- 3. Typography Tones ---
  static const Color onSurface = Color(0xFF2B2A28); // High readability dark charcoal
  static const Color onSurfaceVariant = Color(0xFF6B6862); // Muted annotations
  static const Color textPrimary = Color(0xFF2B2A28);
  static const Color textSecondary = Color(0xFF6B6862);
  static const Color textTertiary = Color(0xFF9E9B94);
  static const Color textMuted = Color(0xFF9E9B94);
  static const Color textPrimaryLight = Color(0xFF2B2A28);
  static const Color textSecondaryLight = Color(0xFF6B6862);

  // --- 4. Primary Accent — Soft Lavender (Pastel sRGB) ---
  static const Color primary = Color(0xFF5B61B9); // Deep Soft Lavender for text/icons
  static const Color primaryContainer = Color(0xFF8C93E8); // Soft Lavender accent
  static const Color onPrimaryContainer = Color(0xFF212878);
  static const Color primaryLight = Color(0xFFA5ABF2);
  static const Color primaryTint = Color(0xFFECEEFE); // Soft Lavender background tint
  static const Color primaryFixed = Color(0xFFE0E0FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFF3E4496);

  // --- 5. Secondary Accent — Muted Blue ---
  static const Color mutedBlue = Color(0xFF4B72C7);
  static const Color mutedBlueTint = Color(0xFFE8EFFC);
  static const Color secondary = Color(0xFF4B72C7);
  static const Color secondaryContainer = Color(0xFF8EA9E8);
  static const Color secondaryTint = Color(0xFFE8EFFC);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // --- 6. Warm Accent — Warm Peach / Sand ---
  static const Color warmPeach = Color(0xFFF4A28C);
  static const Color warmPeachTint = Color(0xFFFDEEE9);
  static const Color warmPeachText = Color(0xFFB85D47);
  static const Color sandBeige = Color(0xFFF0ECE1);

  // --- 7. Tertiary / Resolution / Health / Slate-Teal (ZERO PURE GREEN RULE) ---
  static const Color slateTeal = Color(0xFF6E9C9B); // Mineral Slate-Teal (Replaces harsh green)
  static const Color slateTealTint = Color(0xFFDDEBEA); // Resolution chip background
  static const Color slateTealText = Color(0xFF416867);
  static const Color tertiary = Color(0xFF6E9C9B);
  static const Color tertiaryContainer = Color(0xFF8CBAB9);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // --- 8. Warning — Dusty Amber ---
  static const Color warning = Color(0xFFE3B15C);
  static const Color warningTint = Color(0xFFF8ECD6);
  static const Color warningText = Color(0xFF966F2A);

  // --- 9. Critical / Danger — Desaturated Rose ---
  static const Color dangerRose = Color(0xFFD8848C);
  static const Color dangerTint = Color(0xFFF6DEE1);
  static const Color dangerText = Color(0xFF96474E);
  static const Color error = Color(0xFFD8848C);
  static const Color errorContainer = Color(0xFFF6DEE1);
  static const Color onError = Color(0xFFFFFFFF);

  // --- 10. Semantic Priorities ---
  static const Color priorityP1 = Color(0xFFD8848C); // Critical (Desaturated Rose)
  static const Color priorityP2 = Color(0xFFF4A28C); // High (Warm Peach)
  static const Color priorityP3 = Color(0xFFE3B15C); // Medium (Dusty Amber)
  static const Color priorityP4 = Color(0xFF6E9C9B); // Low (Slate-Teal)

  static const Color priorityCritical = Color(0xFFD8848C);
  static const Color priorityHigh = Color(0xFFF4A28C);
  static const Color priorityMedium = Color(0xFFE3B15C);
  static const Color priorityLow = Color(0xFF6E9C9B);

  // --- 11. Semantic Statuses (Mineral & Pastel Tones) ---
  static const Color statusNew = Color(0xFF8C93E8); // Soft Lavender
  static const Color statusInProgress = Color(0xFF5B61B9);
  static const Color statusAssigned = Color(0xFF4B72C7); // Muted Blue
  static const Color statusAwaiting = Color(0xFFE3B15C); // Dusty Amber
  static const Color statusResolved = Color(0xFF6E9C9B); // Slate-Teal (No green)
  static const Color statusClosed = Color(0xFF767682);
  static const Color statusCancelled = Color(0xFF9E9B94);

  // --- 12. Risk Badges ---
  static const Color riskCritical = Color(0xFFD8848C);
  static const Color riskHigh = Color(0xFFF4A28C);
  static const Color riskModerate = Color(0xFFE3B15C);
  static const Color riskLow = Color(0xFF6E9C9B);

  // --- 13. Liquid Glassmorphism & Soft Glow Tokens ---
  static const Color glassSurface = Color(0xD8FFFFFF); // 85% transparent white
  static const Color glassBorder = Color(0x60FFFFFF); // Soft white edge glow
  static const Color glassBorderSubtle = Color(0x308C93E8); // Lavender glow border
  static const Color glassTint = Color(0x158C93E8);
  static const Color glassGlow = Color(0x208C93E8);

  // --- 14. Dark Mode Foundations ---
  static const Color bgDark = Color(0xFF17181B);
  static const Color surfaceDark = Color(0xFF1F2023);
  static const Color cardDark = Color(0xFF1F2023);
  static const Color borderDark = Color(0xFF2C2D31);
  static const Color textPrimaryDark = Color(0xFFEDEBE6);
  static const Color textSecondaryDark = Color(0xFFA3A19B);
  static const Color inverseSurface = Color(0xFF31302E);
  static const Color inverseOnSurface = Color(0xFFF4F0EC);

  // --- 15. Convenient Palette Aliases ---
  static const Color rose = Color(0xFFD8848C);
  static const Color roseTint = Color(0xFFF6DEE1);
  static const Color coral = Color(0xFFF4A28C);
  static const Color coralTint = Color(0xFFFDEEE9);
  static const Color amber = Color(0xFFE3B15C);
  static const Color amberTint = Color(0xFFF8ECD6);
  static const Color bgLight = Color(0xFFF7F6F3);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color backgroundPrimary = Color(0xFFF7F6F3);
  static const Color accentBlue = Color(0xFF8C93E8);
  static const Color card = Color(0xFFFFFFFF);
}
