import 'package:flutter/material.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';

/// NextAssist Fluid Responsive Grid System
/// Strictly adheres to `NextAssist — Design.md` Section 7:
/// - No hardcoded column counts or rigid pixel widths
/// - Automatically computes optimal columns based on parent constraints
/// - Seamless across Mobile (1 col), Tablet (2 col), Desktop (3-4 col), Ultra-wide
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double targetItemWidth;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.targetItemWidth = 280.0,
    this.mainAxisSpacing = AppSpacing.lg,
    this.crossAxisSpacing = AppSpacing.lg,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Compute dynamic column count
        int columnCount = (availableWidth / targetItemWidth).floor();
        if (columnCount < 1) columnCount = 1;
        if (columnCount > 6) columnCount = 6;

        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: _calculateAspectRatio(availableWidth, columnCount),
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  double _calculateAspectRatio(double width, int columns) {
    if (columns == 1) return 2.6;
    if (columns == 2) return 1.65;
    if (columns == 3) return 1.45;
    return 1.35;
  }
}

/// Adaptive Two/Three-Column Container that stacks gracefully on smaller screens
class AdaptiveFlexRow extends StatelessWidget {
  final Widget primary;
  final Widget secondary;
  final int primaryFlex;
  final int secondaryFlex;
  final double breakpoint;
  final double spacing;

  const AdaptiveFlexRow({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 65,
    this.secondaryFlex = 35,
    this.breakpoint = AppBreakpoints.tablet,
    this.spacing = AppSpacing.xl,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isExpanded = constraints.maxWidth >= breakpoint;

        if (isExpanded) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: primaryFlex, child: primary),
              SizedBox(width: spacing),
              Expanded(flex: secondaryFlex, child: secondary),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            primary,
            SizedBox(height: spacing),
            secondary,
          ],
        );
      },
    );
  }
}

/// Dynamic Max-Width Center Shell ensuring non-crowded spacious reading
class ResponsiveContentShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContentShell({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding ?? AppSpacing.screenPadding(context),
        child: child,
      ),
    );
  }
}
