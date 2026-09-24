import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';

/// NextAssist Liquid Aurora Ambient Background
/// Provides the vibrant atmospheric mesh orbs that shine through
/// `BackdropFilter` glass panels to produce authentic Liquid Glassmorphism.
class LiquidAuroraBackground extends StatelessWidget {
  final Widget child;
  final bool enableAura;

  const LiquidAuroraBackground({
    super.key,
    required this.child,
    this.enableAura = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!enableAura) {
      return Container(
        color: isDark ? AppColors.bgDark : AppColors.background,
        child: child,
      );
    }

    return Container(
      color: isDark ? AppColors.bgDark : AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Top-Left: Soft Lavender Glow Orb
          Positioned(
            top: -120,
            left: -100,
            width: 480,
            height: 480,
            child: _GlowOrb(
              color: isDark
                  ? const Color(0x355B61B9)
                  : AppColors.auroraLavender,
              blurSigma: 120,
            ),
          ),

          // 2. Top-Right: Warm Peach Aurora Orb
          Positioned(
            top: -80,
            right: -80,
            width: 520,
            height: 520,
            child: _GlowOrb(
              color: isDark
                  ? const Color(0x28F4A28C)
                  : AppColors.auroraPeach,
              blurSigma: 140,
            ),
          ),

          // 3. Center-Left: Mineral Slate-Teal Organic Aura
          Positioned(
            top: 350,
            left: -120,
            width: 450,
            height: 450,
            child: _GlowOrb(
              color: isDark
                  ? const Color(0x255E9392)
                  : AppColors.auroraTeal,
              blurSigma: 130,
            ),
          ),

          // 4. Bottom-Right: Muted Royal Blue Glow
          Positioned(
            bottom: -100,
            right: 50,
            width: 500,
            height: 500,
            child: _GlowOrb(
              color: isDark
                  ? const Color(0x254B72C7)
                  : AppColors.auroraBlue,
              blurSigma: 140,
            ),
          ),

          // 5. Middle-Right: Dusty Amber Subtle Tint
          Positioned(
            top: 250,
            right: 200,
            width: 320,
            height: 320,
            child: _GlowOrb(
              color: isDark
                  ? const Color(0x18E3B15C)
                  : AppColors.auroraAmber,
              blurSigma: 110,
            ),
          ),

          // Foreground Interactive Content
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double blurSigma;

  const _GlowOrb({
    required this.color,
    required this.blurSigma,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
        tileMode: TileMode.decal,
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
