import 'package:flutter/material.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';
import 'package:it_helpdesk_client/shared/widgets/liquid_glass_panel.dart';

/// NextAssist Interactive Elevated 3D Card
/// Strictly adheres to `Design.md` Sections 5 & 6:
/// - Solid, clean surface by default (#FFFFFF in Light, #1E293B in Dark)
/// - GSAP-Style Ease Hover Motion (Curves.easeOutCubic)
/// - Subtle 3D Hover Lift (scale <= 1.015, hoverLift <= 3px)
/// - Soft Shadow Expansion
/// - Optional Glass Mode (useGlass = true) for highlight components
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
  final bool useGlass;
  final double blur;

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
    this.hoverLift = -2.5,
    this.useGlass = false,
    this.blur = 12.0,
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
        (isDark ? AppColors.cardDark : AppColors.surface);
        
    final effectiveBorder = widget.borderColor ??
        (_isHovered
            ? (isDark ? AppColors.borderDarkHover : AppColors.primaryContainer.withValues(alpha: 0.5))
            : (isDark ? AppColors.borderDark : AppColors.border));

    final isInteractive = widget.onTap != null || widget.enableHover;
    final double targetTranslation = _isPressed ? 1.0 : (_isHovered ? widget.hoverLift : 0.0);
    final double targetScale = _isPressed ? 0.99 : (_isHovered ? widget.hoverScale : 1.0);

    if (widget.useGlass) {
      return LiquidGlassPanel(
        blur: widget.blur,
        margin: widget.margin,
        padding: widget.padding,
        borderRadius: effectiveRadius,
        backgroundColor: effectiveBg,
        borderColor: effectiveBorder,
        borderWidth: widget.borderWidth,
        onTap: widget.onTap,
        child: widget.child,
      );
    }

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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: widget.margin,
          transform: Matrix4.diagonal3Values(targetScale, targetScale, 1.0)
            ..setTranslationRaw(0.0, targetTranslation, 0.0),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: effectiveRadius,
            border: Border.all(
              color: effectiveBorder,
              width: widget.borderWidth,
            ),
            boxShadow: [
              if (_isHovered && isInteractive) ...[
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ] else ...[
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.20)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ],
          ),
          child: Padding(
            padding: widget.padding ?? AppSpacing.cardPadding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
