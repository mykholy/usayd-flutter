import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import 'package:usayd_flutter/core/localization/app_locale.dart';
import 'package:usayd_flutter/core/network/problem_details_exception.dart';
import '../fixtures/screen_fixtures.dart';
import '../helpers/test_harness.dart';

void main() {
  setUp(() {
    TestHarness.initFlavor();
  });

  group('Canonical Screen State Fixtures Tests', () {
    // -------------------------------------------------------------------------
    // 1. Loading State Fixture
    // -------------------------------------------------------------------------
    group('Loading State Fixture', () {
      testWidgets('renders loading state in Kids mode with joyful message', (
        tester,
      ) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.loading(mode: InterfaceMode.kids),
          mode: InterfaceMode.kids,
          settle: false,
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('جارٍ تجهيز مهامك الجميلة...'), findsOneWidget);
      });

      testWidgets('renders loading state in Pro mode with calm spinner', (
        tester,
      ) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.loading(mode: InterfaceMode.pro),
          mode: InterfaceMode.pro,
          settle: false,
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('جارٍ تحميل البيانات...'), findsOneWidget);
      });

      testWidgets(
        'renders loading state in Simple mode with high-contrast indicator',
        (tester) async {
          await TestHarness.pumpUsaydWidget(
            tester,
            ScreenFixtures.loading(mode: InterfaceMode.simple),
            mode: InterfaceMode.simple,
            settle: false,
          );

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(find.text('جارٍ التحميل... يرجى الانتظار'), findsOneWidget);
        },
      );
    });

    // -------------------------------------------------------------------------
    // 2. Empty State Fixture
    // -------------------------------------------------------------------------
    group('Empty State Fixture', () {
      testWidgets(
        'renders empty state in Kids mode and invokes onAction callback',
        (tester) async {
          bool actionInvoked = false;

          await TestHarness.pumpUsaydWidget(
            tester,
            ScreenFixtures.empty(
              mode: InterfaceMode.kids,
              onAction: () => actionInvoked = true,
              actionLabel: 'ابدأ المغامرة',
            ),
            mode: InterfaceMode.kids,
          );

          expect(find.text('لا توجد مهام جديدة اليوم!'), findsOneWidget);
          expect(
            find.text('أحسنت! أكملت كل المهام المقررة. واصل إشراقك ✨'),
            findsOneWidget,
          );
          expect(find.text('ابدأ المغامرة'), findsOneWidget);

          await tester.tap(find.text('ابدأ المغامرة'));
          await tester.pumpAndSettle();
          expect(actionInvoked, isTrue);
        },
      );

      testWidgets('renders empty state in Pro mode with standard copy', (
        tester,
      ) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.empty(mode: InterfaceMode.pro),
          mode: InterfaceMode.pro,
        );

        expect(find.text('لا توجد عناصر لعرضها'), findsOneWidget);
        expect(
          find.text('يمكنك البدء بحفظ جديد أو تصفح الدروس المتاحة.'),
          findsOneWidget,
        );
      });

      testWidgets('renders empty state in Simple mode with large target', (
        tester,
      ) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.empty(mode: InterfaceMode.simple),
          mode: InterfaceMode.simple,
        );

        expect(find.text('لا توجد دروس مسجلة'), findsOneWidget);
      });
    });

    // -------------------------------------------------------------------------
    // 3. Error State Fixture
    // -------------------------------------------------------------------------
    group('Error State Fixture', () {
      testWidgets(
        'renders error state with ProblemDetailsException and triggers onRetry',
        (tester) async {
          bool retryInvoked = false;
          final exception = ProblemDetailsException(
            title: 'خطأ في المصادقة',
            status: 401,
            detail: 'انتهت صلاحية جلسة التسجيل، يرجى إعادة المحاولة.',
            code: 'SESSION_EXPIRED',
          );

          await TestHarness.pumpUsaydWidget(
            tester,
            ScreenFixtures.error(
              mode: InterfaceMode.pro,
              error: exception,
              onRetry: () => retryInvoked = true,
            ),
            mode: InterfaceMode.pro,
          );

          expect(find.text('تعذر تحميل البيانات'), findsOneWidget);
          expect(
            find.text('انتهت صلاحية جلسة التسجيل، يرجى إعادة المحاولة.'),
            findsOneWidget,
          );
          expect(find.text('إعادة المحاولة'), findsOneWidget);

          await tester.tap(find.text('إعادة المحاولة'));
          await tester.pumpAndSettle();
          expect(retryInvoked, isTrue);
        },
      );

      testWidgets('renders generic error fallback message', (tester) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.error(
            mode: InterfaceMode.kids,
            message: 'حدث انقطاع بسيط، لا تقلق سنحاول مجدداً!',
          ),
          mode: InterfaceMode.kids,
        );

        expect(
          find.text('حدث انقطاع بسيط، لا تقلق سنحاول مجدداً!'),
          findsOneWidget,
        );
      });
    });

    // -------------------------------------------------------------------------
    // 4. Content State Fixture
    // -------------------------------------------------------------------------
    group('Content State Fixture', () {
      testWidgets('renders Kids mode sample content card', (tester) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.content(mode: InterfaceMode.kids),
          mode: InterfaceMode.kids,
        );

        expect(find.text('مهمة اليوم: سورة الفجر (١-١٤)'), findsOneWidget);
        expect(find.text('ابدأ المهمة الآن'), findsOneWidget);
        expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      });

      testWidgets('renders Pro mode sample content card', (tester) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.content(mode: InterfaceMode.pro),
          mode: InterfaceMode.pro,
        );

        expect(find.text('جلسة الحفظ الأسبوعية'), findsOneWidget);
        expect(find.text('مكتمل ٨٠٪'), findsOneWidget);
        expect(find.text('متابعة التسميع'), findsOneWidget);
      });

      testWidgets('renders Simple mode sample content card', (tester) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.content(mode: InterfaceMode.simple),
          mode: InterfaceMode.simple,
        );

        expect(find.text('درس اليوم'), findsOneWidget);
        expect(find.text('دخول حلقة الدرس'), findsOneWidget);
      });
    });

    // -------------------------------------------------------------------------
    // 5. Offline Banner State Fixture
    // -------------------------------------------------------------------------
    group('Offline Banner State Fixture', () {
      testWidgets(
        'renders offline banner with queued actions count and sync button',
        (tester) async {
          bool syncInvoked = false;

          await TestHarness.pumpUsaydWidget(
            tester,
            ScreenFixtures.offlineBanner(
              mode: InterfaceMode.pro,
              pendingActionsCount: 4,
              onSync: () => syncInvoked = true,
            ),
            mode: InterfaceMode.pro,
          );

          expect(
            find.text('وضع غير متصل — 4 عملية بانتظار المزامنة'),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
          expect(find.byIcon(Icons.sync_rounded), findsOneWidget);

          await tester.tap(find.byIcon(Icons.sync_rounded));
          await tester.pumpAndSettle();
          expect(syncInvoked, isTrue);
        },
      );

      testWidgets('renders offline banner when no actions pending', (
        tester,
      ) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.offlineBanner(
            mode: InterfaceMode.simple,
            pendingActionsCount: 0,
          ),
          mode: InterfaceMode.simple,
        );

        expect(
          find.text('أنت تعمل في وضع عدم الاتصال — البيانات محفوظة محلياً'),
          findsOneWidget,
        );
      });
    });

    // -------------------------------------------------------------------------
    // 6. Permission Denied State Fixture
    // -------------------------------------------------------------------------
    group('Permission Denied State Fixture', () {
      testWidgets('renders permission denied and invokes grant callback', (
        tester,
      ) async {
        bool permissionGranted = false;

        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.permissionDenied(
            mode: InterfaceMode.pro,
            title: 'إذن الميكروفون مطلوب',
            message: 'يلزم إذن الميكروفون لتسجيل تلاوتك وتحليل أحكام التجويد.',
            actionLabel: 'السماح بالميكروفون',
            onAction: () => permissionGranted = true,
          ),
          mode: InterfaceMode.pro,
        );

        expect(find.text('إذن الميكروفون مطلوب'), findsOneWidget);
        expect(
          find.text('يلزم إذن الميكروفون لتسجيل تلاوتك وتحليل أحكام التجويد.'),
          findsOneWidget,
        );
        expect(find.text('السماح بالميكروفون'), findsOneWidget);

        await tester.tap(find.text('السماح بالميكروفون'));
        await tester.pumpAndSettle();
        expect(permissionGranted, isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // Localization & Theme Mode Independence
    // -------------------------------------------------------------------------
    group('English Locale & Dark Theme Compatibility', () {
      testWidgets('renders screen states in English (LTR)', (tester) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.empty(
            mode: InterfaceMode.pro,
            title: 'No Lessons Found',
            message: 'Get started by exploring our courses.',
            actionLabel: 'Browse Courses',
            onAction: () {},
          ),
          locale: AppLocale.en,
          mode: InterfaceMode.pro,
        );

        expect(find.text('No Lessons Found'), findsOneWidget);
        expect(find.text('Browse Courses'), findsOneWidget);
      });

      testWidgets('renders screen states cleanly in Dark theme', (
        tester,
      ) async {
        await TestHarness.pumpUsaydWidget(
          tester,
          ScreenFixtures.content(mode: InterfaceMode.pro),
          themeMode: ThemeMode.dark,
          mode: InterfaceMode.pro,
        );

        expect(find.text('جلسة الحفظ الأسبوعية'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}
