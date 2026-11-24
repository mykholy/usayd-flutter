import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';

void main() {
  group('InterfaceMode Adaptive Tests', () {
    test('Age recommendation recommends Kids mode for ages 6 to 12', () {
      expect(InterfaceMode.recommendForAge(6), equals(InterfaceMode.kids));
      expect(InterfaceMode.recommendForAge(9), equals(InterfaceMode.kids));
      expect(InterfaceMode.recommendForAge(12), equals(InterfaceMode.kids));
    });

    test(
      'Age recommendation recommends Professional mode for ages 13 to 59',
      () {
        expect(InterfaceMode.recommendForAge(13), equals(InterfaceMode.pro));
        expect(InterfaceMode.recommendForAge(25), equals(InterfaceMode.pro));
        expect(InterfaceMode.recommendForAge(59), equals(InterfaceMode.pro));
      },
    );

    test('Age recommendation recommends Simple mode for ages 60 and above', () {
      expect(InterfaceMode.recommendForAge(60), equals(InterfaceMode.simple));
      expect(InterfaceMode.recommendForAge(75), equals(InterfaceMode.simple));
    });

    test('InterfaceMode provides Arabic and English display labels', () {
      expect(InterfaceMode.kids.displayNameArabic, contains('البراعم'));
      expect(InterfaceMode.kids.displayNameEnglish, equals('Kids Mode'));

      expect(InterfaceMode.pro.displayNameArabic, contains('المتقدم'));
      expect(InterfaceMode.pro.displayNameEnglish, equals('Professional Mode'));

      expect(InterfaceMode.simple.displayNameArabic, contains('الميسر'));
      expect(InterfaceMode.simple.displayNameEnglish, equals('Simple Mode'));
    });
  });
}
