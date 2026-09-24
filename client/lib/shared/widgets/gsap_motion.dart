import 'package:flutter/material.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';

/// NextAssist GSAP-Style Motion Utilities
/// Strictly adheres to `NextAssist — Design.md` Section 9:
/// - Smooth 60 FPS transitions
/// - Ease-based natural curves (easeOutCubic)
/// - Progressive reveal & step-by-step animations
/// - Skeleton loaders & shimmer (avoids raw spinners)

enum SlideDirection { up, down, left, right, none }

/// Progressive reveal component with customizable timeline delay
class GSAPFadeSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final SlideDirection direction;
  final double offset;
  final Curve curve;

  const GSAPFadeSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 360),
    this.delay = Duration.zero,
    this.direction = SlideDirection.up,
    this.offset = 18.0,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<GSAPFadeSlide> createState() => _GSAPFadeSlideState();
}

class _GSAPFadeSlideState extends State<GSAPFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Offset startOffset;
    switch (widget.direction) {
      case SlideDirection.up:
        startOffset = Offset(0.0, widget.offset / 100.0);
        break;
      case SlideDirection.down:
        startOffset = Offset(0.0, -widget.offset / 100.0);
        break;
      case SlideDirection.left:
        startOffset = Offset(widget.offset / 100.0, 0.0);
        break;
      case SlideDirection.right:
        startOffset = Offset(-widget.offset / 100.0, 0.0);
        break;
      case SlideDirection.none:
        startOffset = Offset.zero;
        break;
    }

    _slide = Tween<Offset>(begin: startOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: FractionalTranslation(
            translation: _slide.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Shimmer skeleton loader replacing jarring spinners per Section 9.2
class GSAPShimmerLoader extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const GSAPShimmerLoader({
    super.key,
    this.width,
    this.height = 20.0,
    this.borderRadius,
    this.margin,
  });

  @override
  State<GSAPShimmerLoader> createState() => _GSAPShimmerLoaderState();
}

class _GSAPShimmerLoaderState extends State<GSAPShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? AppRadius.borderSm;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: effectiveRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                AppColors.surfaceContainerLow,
                AppColors.surfaceContainerHigh,
                AppColors.surfaceContainerLow,
              ],
              stops: [
                0.0,
                _controller.value,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
