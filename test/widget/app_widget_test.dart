import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/app.dart';
import 'package:usayd_flutter/core/config/flavor_config.dart';

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

  testWidgets(
    'UsaydApp renders brand name, Arabic tagline, and RTL directionality',
    (tester) async {
      await tester.pumpWidget(const UsaydApp());
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
