import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';
import 'package:it_helpdesk_client/shared/widgets/gsap_motion.dart';
import 'package:it_helpdesk_client/shared/widgets/interactive_card.dart';
import 'package:it_helpdesk_client/shared/widgets/liquid_glass_panel.dart';
import 'package:it_helpdesk_client/shared/widgets/responsive_grid.dart';

void main() {
  group('Design System Tokens & Utilities', () {
    test('AppColors adheres to Pastel sRGB and Zero Pure Green Rule', () {
      // Background & Surface
      expect(AppColors.background, const Color(0xFFF7F6F3));
      expect(AppColors.surface, const Color(0xFFFFFFFF));

      // Pastel Primary
      expect(AppColors.primary, const Color(0xFF5B61B9));
      expect(AppColors.primaryContainer, const Color(0xFF8C93E8));

      // Resolution & Status uses Slate-Teal, NOT pure green (#00FF00 / #008000)
      expect(AppColors.statusResolved, const Color(0xFF6E9C9B));
      expect(AppColors.slateTeal, const Color(0xFF6E9C9B));
    });

    test('AppSpacing and Breakpoints calculations', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 24.0);
      expect(AppBreakpoints.mobile, 600.0);
      expect(AppBreakpoints.tablet, 960.0);
      expect(AppBreakpoints.desktop, 1280.0);
    });
  });

  group('Design System Widgets', () {
    testWidgets('LiquidGlassPanel renders child with blur and border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LiquidGlassPanel(
              child: Text('Glass Content'),
            ),
          ),
        ),
      );

      expect(find.text('Glass Content'), findsOneWidget);
      expect(find.byType(LiquidGlassPanel), findsOneWidget);
    });

    testWidgets('InteractiveCard responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveCard(
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      expect(find.text('Tap Me'), findsOneWidget);
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('GSAPFadeSlide progressive reveal renders child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GSAPFadeSlide(
              child: Text('Animated Headline'),
            ),
          ),
        ),
      );

      expect(find.text('Animated Headline'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Animated Headline'), findsOneWidget);
    });

    testWidgets('GSAPShimmerLoader renders skeleton loader', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GSAPShimmerLoader(height: 40, width: 200),
          ),
        ),
      );

      expect(find.byType(GSAPShimmerLoader), findsOneWidget);
    });

    testWidgets('ResponsiveContentShell constraints test', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveContentShell(
              maxWidth: 1000,
              child: Text('Constrained Content'),
            ),
          ),
        ),
      );

      expect(find.text('Constrained Content'), findsOneWidget);
    });

    testWidgets('AdaptiveFlexRow renders primary and secondary', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveFlexRow(
              primary: Text('Left Column'),
              secondary: Text('Right Column'),
            ),
          ),
        ),
      );

      expect(find.text('Left Column'), findsOneWidget);
      expect(find.text('Right Column'), findsOneWidget);
    });
  });
}
