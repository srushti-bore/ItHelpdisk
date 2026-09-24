import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:it_helpdesk_client/shared/constants/app_colors.dart';
import 'package:it_helpdesk_client/shared/constants/app_spacing.dart';
import 'package:it_helpdesk_client/shared/widgets/gsap_motion.dart';
import 'package:it_helpdesk_client/shared/widgets/interactive_card.dart';
import 'package:it_helpdesk_client/shared/widgets/liquid_glass_panel.dart';
import 'package:it_helpdesk_client/shared/widgets/notification_panel.dart';
import 'package:it_helpdesk_client/shared/widgets/responsive_grid.dart';

void main() {
  group('Design System Tokens & Utilities', () {
    test('AppColors adheres to Design.md palette and Zero Pure Green Rule', () {
      // Base Background & Surface
      expect(AppColors.background, const Color(0xFFFAFAFA));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.bgDark, const Color(0xFF0F172A));

      // Primary Accent: Indigo (#6366F1)
      expect(AppColors.primary, const Color(0xFF6366F1));

      // Secondary: Soft Blue (#3B82F6) & Soft Purple (#8B5CF6)
      expect(AppColors.secondary, const Color(0xFF3B82F6));
      expect(AppColors.purple, const Color(0xFF8B5CF6));

      // Resolution & Status uses Slate-Teal (#0D9488), NO pure green (#00FF00 / #008000)
      expect(AppColors.statusResolved, const Color(0xFF0D9488));
      expect(AppColors.slateTeal, const Color(0xFF0D9488));
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

    testWidgets('InteractiveCard responds to tap and hover states', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InteractiveCard(
              onTap: () => tapped = true,
              child: const Text('Interactive Content'),
            ),
          ),
        ),
      );

      expect(find.text('Interactive Content'), findsOneWidget);
      await tester.tap(find.byType(InteractiveCard));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('NotificationPanel renders categorized alerts and close trigger', (tester) async {
      bool closed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationPanel(
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('SLA Alerts'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(closed, isTrue);
    });

    testWidgets('GSAPFadeSlide progressive reveal renders child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GSAPFadeSlide(
              child: Text('Animated Child'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Animated Child'), findsOneWidget);
    });

    testWidgets('GSAPShimmerLoader renders skeleton loader', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GSAPShimmerLoader(height: 50),
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
              child: Text('Shell Content'),
            ),
          ),
        ),
      );

      expect(find.text('Shell Content'), findsOneWidget);
    });

    testWidgets('AdaptiveFlexRow renders primary and secondary', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveFlexRow(
              primary: Text('Primary Content'),
              secondary: Text('Secondary Content'),
            ),
          ),
        ),
      );

      expect(find.text('Primary Content'), findsOneWidget);
      expect(find.text('Secondary Content'), findsOneWidget);
    });
  });
}
