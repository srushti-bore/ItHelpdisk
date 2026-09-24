import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';

/// NextAssist Pro Liquid Glassmorphism Panel
/// Strictly adheres to `Design.md` Section 5:
/// - Highlight layer only (AI Assistant, Notification Panel, Modals, Floating Overlays)
/// - Light Mode: rgba(255, 255, 255, 0.60), blur 12-16px, border rgba(255, 255, 255, 0.30)
/// - Dark Mode: rgba(17, 24, 39, 0.60), blur 12-18px, border rgba(255, 255, 255, 0.08)
class LiquidGlassPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const LiquidGlassPanel({
    super.key,
    required this.child,
    this.blur = 14.0,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius = borderRadius ?? AppRadius.borderLg;
    
    // Light Mode: rgba(255, 255, 255, 0.60) / Dark Mode: rgba(17, 24, 39, 0.60)
    final effectiveBg = backgroundColor ??
        (isDark ? AppColors.glassSurfaceDark : AppColors.glassSurfaceLight);
        
    // Light Mode Border: rgba(255, 255, 255, 0.30) / Dark Mode: rgba(255, 255, 255, 0.08)
    final effectiveBorder = borderColor ??
        (isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight);

    final defaultShadows = [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.40)
            : AppColors.primary.withValues(alpha: 0.08),
        blurRadius: isDark ? 24 : 16,
        offset: const Offset(0, 6),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.black.withValues(alpha: 0.02),
        blurRadius: 6,
        offset: const Offset(0, 2),
        spreadRadius: 0,
      ),
    ];

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: shadows ?? defaultShadows,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: effectiveBg,
              borderRadius: effectiveRadius,
              border: Border.all(
                color: effectiveBorder,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
