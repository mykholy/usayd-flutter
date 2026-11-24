import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/app.dart';
import 'package:usayd_flutter/core/config/flavor_config.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';

void main() {
  setUp(() {
    FlavorConfig.init(
      flavor: AppFlavor.prod,
      name: 'أكاديمية أُسَيْد',
      apiBaseUrl: 'https://api.usayd.academy/api/v1',
      appIdentifier: 'academy.usayd.learner',
      enableLogging: false,
    );
  });

  testWidgets('Interface mode toggle switches between Kids, Pro, and Simple', (
    tester,
  ) async {
    await tester.pumpWidget(const UsaydApp(initialMode: InterfaceMode.pro));
    await tester.pumpAndSettle();

    // Initially in Pro mode
    expect(find.textContaining('Professional Mode'), findsOneWidget);

    // Tap on Kids mode segment
    final kidsBtn = find.text(InterfaceMode.kids.displayNameArabic);
    await tester.ensureVisible(kidsBtn);
    await tester.tap(kidsBtn);
    await tester.pumpAndSettle();

    // Verifies Kids mode is active
    expect(find.textContaining('Kids Mode'), findsOneWidget);

    // Tap on Simple mode segment
    final simpleBtn = find.text(InterfaceMode.simple.displayNameArabic);
    await tester.ensureVisible(simpleBtn);
    await tester.tap(simpleBtn);
    await tester.pumpAndSettle();

    // Verifies Simple mode is active
    expect(find.textContaining('Simple Mode'), findsOneWidget);
  });
}
