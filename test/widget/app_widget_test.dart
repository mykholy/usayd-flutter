import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/app.dart';
import 'package:usayd_flutter/core/config/flavor_config.dart';

import '../helpers/authenticated_app_fixture.dart';

void main() {
  setUp(() {
    FlavorConfig.init(
      flavor: AppFlavor.dev,
      name: 'Usayd Dev',
      apiBaseUrl: 'http://10.0.2.2:8000/api/v1',
      appIdentifier: 'academy.usayd.learner.dev',
      enableLogging: true,
    );
  });

  testWidgets('default app starts unauthenticated in production', (
    tester,
  ) async {
    FlavorConfig.init(
      flavor: AppFlavor.prod,
      name: 'Usayd',
      apiBaseUrl: 'https://api.usayd.academy/api/v1',
      appIdentifier: 'academy.usayd.learner',
      enableLogging: false,
    );
    await tester.pumpWidget(const UsaydApp());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('screen_login')), findsOneWidget);
    expect(find.byKey(const Key('shell_tab_lessons')), findsNothing);
  });

  testWidgets(
    'UsaydApp renders brand name, Arabic tagline, and RTL directionality',
    (tester) async {
      await tester.pumpWidget(authenticatedAppFixture());
      await tester.pumpAndSettle();

      // Verify brand name is rendered
      expect(find.text('أكاديمية أُسَيْد'), findsWidgets);

      // Verify Arabic tagline is rendered
      expect(find.text('«اقرأ بصوتٍ تدنو له الملائكة»'), findsOneWidget);

      // Verify flavor badge is displayed in dev mode
      expect(find.text('DEV'), findsOneWidget);
    },
  );
}
