import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import '../fixtures/screen_fixtures.dart';
import '../helpers/test_harness.dart';

void main() {
  setUp(() {
    TestHarness.initFlavor();
  });

  group('Responsive Breakpoint Tests (320px / 390px / 768px)', () {
    final breakpoints = [
      ScreenBreakpoint.compactPhone,
      ScreenBreakpoint.standardPhone,
      ScreenBreakpoint.tablet,
    ];

    for (final bp in breakpoints) {
      group(
        'Breakpoint: ${bp.name} (${bp.logicalSize.width.toInt()}x${bp.logicalSize.height.toInt()})',
        () {
          testWidgets('Content state renders without overflow in Kids mode', (
            tester,
          ) async {
            await TestHarness.pumpUsaydWidget(
              tester,
              SingleChildScrollView(
                child: ScreenFixtures.content(mode: InterfaceMode.kids),
              ),
              breakpoint: bp,
              mode: InterfaceMode.kids,
            );

            expect(tester.takeException(), isNull);
            expect(find.text('مهمة اليوم: سورة الفجر (١-١٤)'), findsOneWidget);
          });

          testWidgets('Content state renders without overflow in Pro mode', (
            tester,
          ) async {
            await TestHarness.pumpUsaydWidget(
              tester,
              SingleChildScrollView(
                child: ScreenFixtures.content(mode: InterfaceMode.pro),
              ),
              breakpoint: bp,
              mode: InterfaceMode.pro,
            );

            expect(tester.takeException(), isNull);
            expect(find.text('جلسة الحفظ الأسبوعية'), findsOneWidget);
          });

          testWidgets('Content state renders without overflow in Simple mode', (
            tester,
          ) async {
            await TestHarness.pumpUsaydWidget(
              tester,
              SingleChildScrollView(
                child: ScreenFixtures.content(mode: InterfaceMode.simple),
              ),
              breakpoint: bp,
              mode: InterfaceMode.simple,
            );

            expect(tester.takeException(), isNull);
            expect(find.text('درس اليوم'), findsOneWidget);
          });

          testWidgets(
            'All canonical states render without overflow on ${bp.name}',
            (tester) async {
              final states = [
                ScreenFixtures.loading(mode: InterfaceMode.pro),
                ScreenFixtures.empty(mode: InterfaceMode.pro, onAction: () {}),
                ScreenFixtures.error(mode: InterfaceMode.pro, onRetry: () {}),
                ScreenFixtures.offlineBanner(
                  mode: InterfaceMode.pro,
                  pendingActionsCount: 2,
                  onSync: () {},
                ),
                ScreenFixtures.permissionDenied(
                  mode: InterfaceMode.pro,
                  onAction: () {},
                ),
              ];

              for (final stateWidget in states) {
                await TestHarness.pumpUsaydWidget(
                  tester,
                  SingleChildScrollView(child: stateWidget),
                  breakpoint: bp,
                  mode: InterfaceMode.pro,
                  settle: false,
                );
                expect(tester.takeException(), isNull);
              }
            },
          );
        },
      );
    }

    // -------------------------------------------------------------------------
    // Target Size & Token Verification across Modes
    // -------------------------------------------------------------------------
    group('Age-Adaptive Token Verification', () {
      testWidgets(
        'Kids mode button has exact 56px height per AGE_ADAPTIVE_UI',
        (tester) async {
          await TestHarness.pumpUsaydWidget(
            tester,
            ScreenFixtures.empty(
              mode: InterfaceMode.kids,
              actionLabel: 'زر الأطفال',
              onAction: () {},
            ),
            breakpoint: ScreenBreakpoint.standardPhone,
            mode: InterfaceMode.kids,
          );

          final btnFinder = find.widgetWithText(ElevatedButton, 'زر الأطفال');
          expect(btnFinder, findsOneWidget);

          final Size btnSize = tester.getSize(btnFinder);
          expect(btnSize.height, 56.0);
        },
      );

      testWidgets('Pro mode button has 48px height per AGE_ADAPTIVE_UI', (
        tester,
      ) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.empty(
            mode: InterfaceMode.pro,
            actionLabel: 'زر المحترفين',
            onAction: () {},
          ),
          breakpoint: ScreenBreakpoint.standardPhone,
          mode: InterfaceMode.pro,
        );

        final btnFinder = find.widgetWithText(ElevatedButton, 'زر المحترفين');
        expect(btnFinder, findsOneWidget);

        final Size btnSize = tester.getSize(btnFinder);
        expect(btnSize.height, 48.0);
      });

      testWidgets('Simple mode button has 60px height per AGE_ADAPTIVE_UI', (
        tester,
      ) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.empty(
            mode: InterfaceMode.simple,
            actionLabel: 'زر الميسر',
            onAction: () {},
          ),
          breakpoint: ScreenBreakpoint.standardPhone,
          mode: InterfaceMode.simple,
        );

        final btnFinder = find.widgetWithText(ElevatedButton, 'زر الميسر');
        expect(btnFinder, findsOneWidget);

        final Size btnSize = tester.getSize(btnFinder);
        expect(btnSize.height, 60.0);
      });
    });
  });
}
