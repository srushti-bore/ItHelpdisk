import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';

/// NextAssist Interactive Elevated Liquid Glass Card
/// Strictly adheres to `NextAssist — Design.md`:
/// - GSAP-Style Ease-Based Hover Motion (Curves.easeOutCubic)
/// - Authentic Liquid Glassmorphism (BackdropFilter blur 18-24)
/// - Sub-1.02 subtle scale lift on hover
/// - Glowing border transition on mouse enter
/// - Tactile click/tap response
class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final bool enableHover;
  final double hoverScale;
  final double hoverLift;
  final double blur;
  final Gradient? customGradient;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.enableHover = true,
    this.hoverScale = 1.012, // Sub-1.02 subtle scale per design system
    this.hoverLift = -3.0,
    this.blur = 18.0,
    this.customGradient,
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius = widget.borderRadius ?? AppRadius.borderLg;
    
    final effectiveBg = widget.backgroundColor ??
        (isDark ? AppColors.glassSurfaceDark : AppColors.glassSurface);
        
    final effectiveBorder = widget.borderColor ??
        (_isHovered
            ? AppColors.glassBorderHover
            : (isDark ? AppColors.glassBorderDark : AppColors.glassBorder));

    final isInteractive = widget.onTap != null || widget.enableHover;
    final double targetTranslation = _isPressed ? 1.0 : (_isHovered ? widget.hoverLift : 0.0);
    final double targetScale = _isPressed ? 0.988 : (_isHovered ? widget.hoverScale : 1.0);

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (widget.enableHover) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (widget.enableHover) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (widget.onTap != null) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (widget.onTap != null) {
            setState(() => _isPressed = false);
            widget.onTap!();
          }
        },
        onTapCancel: () {
          if (widget.onTap != null) setState(() => _isPressed = false);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          margin: widget.margin,
          transform: Matrix4.diagonal3Values(targetScale, targetScale, 1.0)
            ..setTranslationRaw(0.0, targetTranslation, 0.0),
          decoration: BoxDecoration(
            borderRadius: effectiveRadius,
            boxShadow: [
              if (_isHovered && isInteractive) ...[
                BoxShadow(
                  color: isDark
                      ? AppColors.primaryContainer.withValues(alpha: 0.20)
                      : AppColors.primaryContainer.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.30)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ] else ...[
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : AppColors.primaryContainer.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ],
          ),
          child: ClipRRect(
            borderRadius: effectiveRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding: widget.padding ?? AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: effectiveBg,
                  gradient: widget.customGradient ??
                      (isDark
                          ? AppColors.glassCardGradientDark
                          : AppColors.glassCardGradient),
                  borderRadius: effectiveRadius,
                  border: Border.all(
                    color: effectiveBorder,
                    width: widget.borderWidth,
                  ),
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
