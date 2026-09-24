import 'package:flutter/material.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';

/// NextAssist Interactive Elevated Card
/// Strictly adheres to `NextAssist — Design.md` Sections 9 & 10:
/// - GSAP-Style Ease-Based Hover Motion
/// - Hover Lift (scale <= 1.02)
/// - Smooth Shadow Expansion & Subtle 3D Depth
/// - Tactile Click/Tap Response
/// - 100% Flexible Sizing & Margin
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
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? AppRadius.borderLg;
    final effectiveBg = widget.backgroundColor ?? AppColors.surface;
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
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: widget.margin,
          transform: Matrix4.diagonal3Values(targetScale, targetScale, 1.0)
            ..setTranslationRaw(0.0, targetTranslation, 0.0),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: effectiveRadius,
            border: Border.all(
              color: _isHovered
                  ? (widget.borderColor ?? AppColors.primaryContainer.withValues(alpha: 0.45))
                  : (widget.borderColor ?? AppColors.border),
              width: widget.borderWidth,
            ),
            boxShadow: [
              if (_isHovered && isInteractive) ...[
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ] else ...[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
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
