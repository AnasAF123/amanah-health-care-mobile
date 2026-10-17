import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_home_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_status_badge.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

void main() {
  group('AmanahPillStyleService Unit Tests', () {
    test('resolves correct dotColor for each variant', () {
      final Color successColor =
          AmanahPillStyleService.dotColorFor(AmanahBadgeVariant.success);
      final Color primaryColor =
          AmanahPillStyleService.dotColorFor(AmanahBadgeVariant.primary);
      final Color liveColor =
          AmanahPillStyleService.dotColorFor(AmanahBadgeVariant.live);
      final Color warningColor =
          AmanahPillStyleService.dotColorFor(AmanahBadgeVariant.warning);
      final Color trendColor =
          AmanahPillStyleService.dotColorFor(AmanahBadgeVariant.trend);

      expect(successColor, AmanahThemeTokens.status(AmanahStatusTone.success).primary);
      expect(primaryColor, AmanahThemeTokens.status(AmanahStatusTone.brand).primary);
      expect(liveColor, AmanahThemeTokens.status(AmanahStatusTone.brand).primary);
      expect(warningColor, AmanahThemeTokens.status(AmanahStatusTone.warning).primary);
      expect(trendColor, AmanahThemeTokens.status(AmanahStatusTone.violet).primary);
    });

    test('resolves comprehensive style for dark and light mode', () {
      final AmanahPillStyle darkStyle = AmanahPillStyleService.resolve(
        AmanahBadgeVariant.primary,
        isDark: true,
      );
      final AmanahPillStyle lightStyle = AmanahPillStyleService.resolve(
        AmanahBadgeVariant.primary,
        isDark: false,
      );

      expect(darkStyle.textColor, AmanahColorTokens.surfaceLight);
      expect(lightStyle.textColor, AmanahColorTokens.neutral900);
      expect(darkStyle.borderColor, AmanahColorTokens.surfaceLight.withValues(alpha: 0.10));
      expect(lightStyle.borderColor, AmanahColorTokens.neutral200);
    });
  });

  group('AmanahStatusBadge Widget Tests', () {
    testWidgets('renders badge text and indicator dot correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahStatusBadge(
              text: 'Sedang Diperiksa',
              variant: AmanahBadgeVariant.trend,
            ),
          ),
        ),
      );

      expect(find.text('Sedang Diperiksa'), findsOneWidget);
      expect(find.byType(AmanahStatusBadge), findsOneWidget);
    });

    testWidgets('respects enableBlur false gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahStatusBadge(
              text: 'Selesai',
              variant: AmanahBadgeVariant.success,
              enableBlur: false,
            ),
          ),
        ),
      );

      expect(find.text('Selesai'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('AmanahPill alias works interchangeably', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AmanahPill(
              text: 'Menunggu',
              variant: AmanahBadgeVariant.primary,
            ),
          ),
        ),
      );

      expect(find.text('Menunggu'), findsOneWidget);
    });
  });
}
