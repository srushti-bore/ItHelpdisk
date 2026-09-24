import 'package:flutter/material.dart';

/// NextAssist Fluid Spacing & Responsive Grid System
/// Strictly adheres to `NextAssist — Design.md`:
/// - 8pt / 12pt Grid Foundation
/// - Spacious Layout, Intentional Whitespace, Zero Crowding
/// - Fully Dynamic & Flexible across Mobile, Tablet, Desktop, and Ultra-wide Web.
class AppSpacing {
  // Base Spacing Tokens (8pt/12pt Multiples)
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
  static const double huge = 64.0;

  // Fluid / Responsive Padding Helper
  static EdgeInsets screenPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppBreakpoints.mobile) {
      return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
    } else if (width < AppBreakpoints.tablet) {
      return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0);
    } else if (width < AppBreakpoints.desktop) {
      return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0);
    }
  }

  static double horizontalScreenPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppBreakpoints.mobile) return 16.0;
    if (width < AppBreakpoints.tablet) return 24.0;
    if (width < AppBreakpoints.desktop) return 32.0;
    return 48.0;
  }

  // Card Content Padding
  static const EdgeInsets cardPaddingSm = EdgeInsets.all(12.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(18.0);
  static const EdgeInsets cardPaddingLg = EdgeInsets.all(24.0);

  // Dialog / Modal Padding
  static const EdgeInsets dialogPadding = EdgeInsets.all(28.0);
}

/// Standard Responsive Breakpoint Definitions
class AppBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 960.0;
  static const double desktop = 1280.0;
  static const double ultraWide = 1600.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobile && w < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static bool isUltraWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= ultraWide;

  // Max readable content constraints
  static const double maxContentWidthCompact = 720.0;
  static const double maxContentWidth = 1140.0;
  static const double maxContentWidthWide = 1440.0;
}

/// Border Radius Tokens (Tactile & Soft UI)
class AppRadius {
  static const double xs = 4.0;
  static const double sm = 6.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double pill = 999.0;

  static final BorderRadius borderXs = BorderRadius.circular(xs);
  static final BorderRadius borderSm = BorderRadius.circular(sm);
  static final BorderRadius borderMd = BorderRadius.circular(md);
  static final BorderRadius borderLg = BorderRadius.circular(lg);
  static final BorderRadius borderXl = BorderRadius.circular(xl);
  static final BorderRadius borderXxl = BorderRadius.circular(xxl);
  static final BorderRadius borderPill = BorderRadius.circular(pill);
}
