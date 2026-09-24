import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';

/// NextAssist Liquid Glassmorphism Panel
/// Strictly adheres to `NextAssist — Design.md` Section 6:
/// - Background blur (BackdropFilter)
/// - Controlled transparency
/// - Soft glow edges & layered depth
/// - Ideal for AI Assistant Panel, Modals, Floating overlays
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
    this.blur = 16.0,
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
    final effectiveRadius = borderRadius ?? AppRadius.borderLg;
    final effectiveBg = backgroundColor ?? AppColors.glassSurface;
    final effectiveBorder = borderColor ?? AppColors.glassBorderSubtle;

    final defaultShadows = [
      BoxShadow(
        color: AppColors.primaryContainer.withValues(alpha: 0.08),
        blurRadius: 24,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 8,
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
