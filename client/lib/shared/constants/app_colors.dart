import 'package:flutter/material.dart';

/// Calmdesk IT Service Desk Design Tokens & Color Palette
/// Strictly adheres to DESIGN.md: Zero Green Rule, 1px Hairlines, Architectural Calm.
class AppColors {
  // Canvas & Surface Foundations (Light Mode)
  static const Color background = Color(0xFFF7F6F3); // Warm paper canvas
  static const Color surface = Color(0xFFFDF9F5);
  static const Color surfaceDim = Color(0xFFDDD9D6);
  static const Color surfaceBright = Color(0xFFFDF9F5);

  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // Flat white card
  static const Color surfaceContainerLow = Color(0xFFF7F3EF);
  static const Color surfaceContainer = Color(0xFFF1EDEA);
  static const Color surfaceContainerHigh = Color(0xFFECE7E4);
  static const Color surfaceContainerHighest = Color(0xFFE6E2DE);

  // Hairline Framing & Outlines
  static const Color hairlineBorder = Color(0xFFE7E4DC); // 1px hairline rule
  static const Color outline = Color(0xFF767682);
  static const Color outlineVariant = Color(0xFFE7E4DC);
  static const Color borderLight = Color(0xFFE7E4DC);
  static const Color border = Color(0xFFE7E4DC);

  // Typography Tones (Light)
  static const Color onSurface = Color(0xFF2B2A28); // High contrast text
  static const Color onSurfaceVariant = Color(0xFF6B6862); // Muted annotations
  static const Color textPrimary = Color(0xFF2B2A28);
  static const Color textSecondary = Color(0xFF6B6862);
  static const Color textMuted = Color(0xFF9E9B94);
  static const Color textPrimaryLight = Color(0xFF2B2A28);
  static const Color textSecondaryLight = Color(0xFF6B6862);

  // Primary / Focus / AI Anchor (Dusty Periwinkle-Indigo)
  static const Color primary = Color(0xFF5057A7);
  static const Color primaryContainer = Color(0xFF8C93E8); // 2px AI left anchor
  static const Color onPrimaryContainer = Color(0xFF212878);
  static const Color primaryFixed = Color(0xFFE0E0FF);
  static const Color primaryTint = Color(0xFFE4E6FA); // AI highlight tint
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFF383E8D);
  static const Color primaryLight = Color(0xFF8C93E8);

  // Secondary / System Info (Muted Clay-Coral)
  static const Color secondary = Color(0xFF894F3C);
  static const Color secondaryContainer = Color(0xFFFDB29A);
  static const Color secondaryTint = Color(0xFFF7E5DE);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Tertiary / Resolution / Health / Slate-Teal (TOTAL GREEN PROHIBITION)
  static const Color tertiary = Color(0xFF386665);
  static const Color slateTeal = Color(0xFF6E9C9B); // Replaces green universally
  static const Color slateTealTint = Color(0xFFDDEBEA); // Resolution chip background
  static const Color slateTealText = Color(0xFF4D7574);
  static const Color tertiaryContainer = Color(0xFF74A2A1);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Warning (Dusty Amber)
  static const Color warning = Color(0xFFE3B15C);
  static const Color warningTint = Color(0xFFF8ECD6);
  static const Color warningText = Color(0xFF966F2A);

  // Critical / Danger (Desaturated Rose / Crimson)
  static const Color error = Color(0xFFBA1A1A);
  static const Color dangerRose = Color(0xFFD8848C);
  static const Color dangerTint = Color(0xFFF6DEE1);
  static const Color dangerText = Color(0xFF96474E);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);

  // Semantic Priorities (Calmdesk Muted Semantic Accents)
  static const Color priorityP1 = Color(0xFFD8848C); // Critical (Desaturated Rose)
  static const Color priorityP2 = Color(0xFFE39B84); // High (Clay-Coral)
  static const Color priorityP3 = Color(0xFFE3B15C); // Medium (Dusty Amber)
  static const Color priorityP4 = Color(0xFF6E9C9B); // Low (Slate-Teal)

  static const Color priorityCritical = Color(0xFFD8848C);
  static const Color priorityHigh = Color(0xFFE39B84);
  static const Color priorityMedium = Color(0xFFE3B15C);
  static const Color priorityLow = Color(0xFF6E9C9B);

  // Semantic Statuses (Calmdesk Slate & Mineral Tones)
  static const Color statusNew = Color(0xFF8C93E8);
  static const Color statusInProgress = Color(0xFF5057A7);
  static const Color statusAssigned = Color(0xFF5057A7);
  static const Color statusAwaiting = Color(0xFFE3B15C);
  static const Color statusResolved = Color(0xFF6E9C9B); // Slate-teal (No green)
  static const Color statusClosed = Color(0xFF767682);
  static const Color statusCancelled = Color(0xFF9E9B94);

  // Risk Badges
  static const Color riskCritical = Color(0xFFD8848C);
  static const Color riskHigh = Color(0xFFE39B84);
  static const Color riskModerate = Color(0xFFE3B15C);
  static const Color riskLow = Color(0xFF6E9C9B);

  // Dark Mode Foundations
  static const Color bgDark = Color(0xFF17181B);
  static const Color surfaceDark = Color(0xFF1F2023);
  static const Color cardDark = Color(0xFF1F2023);
  static const Color borderDark = Color(0xFF2C2D31);
  static const Color textPrimaryDark = Color(0xFFEDEBE6);
  static const Color textSecondaryDark = Color(0xFFA3A19B);
  static const Color inverseSurface = Color(0xFF31302E);
  static const Color inverseOnSurface = Color(0xFFF4F0EC);

  // Convenient Palette Aliases
  static const Color rose = Color(0xFFD8848C);
  static const Color roseTint = Color(0xFFF6DEE1);
  static const Color coral = Color(0xFFE39B84);
  static const Color coralTint = Color(0xFFF7E5DE);
  static const Color amber = Color(0xFFE3B15C);
  static const Color amberTint = Color(0xFFF8ECD6);
  static const Color textTertiary = Color(0xFF9E9B94);

  // Legacy Aliases for backward compatibility
  static const Color bgLight = Color(0xFFF7F6F3);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color backgroundPrimary = Color(0xFFF7F6F3);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  static const Color accentBlue = Color(0xFF8C93E8);
  static const Color card = Color(0xFFFFFFFF);
}
