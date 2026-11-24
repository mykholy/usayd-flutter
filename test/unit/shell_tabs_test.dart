import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import 'package:usayd_flutter/core/localization/app_locale.dart';
import 'package:usayd_flutter/features/shell/domain/shell_tab.dart';

void main() {
  group('ShellTab Domain Tests (AGE_ADAPTIVE_UI.md)', () {
    test('Kids mode defines exactly 4 canonical tabs', () {
      final tabs = ShellTab.tabsForMode(InterfaceMode.kids);
      expect(tabs.length, 4);

      final ids = tabs.map((t) => t.id).toList();
      expect(ids, ['mission', 'path', 'stars', 'me']);
    });

    test('Professional mode defines exactly 5 canonical tabs', () {
      final tabs = ShellTab.tabsForMode(InterfaceMode.pro);
      expect(tabs.length, 5);

      final ids = tabs.map((t) => t.id).toList();
      expect(ids, ['home', 'lessons', 'recite', 'progress', 'profile']);
    });

    test('Simple mode defines exactly 3 canonical tabs for seniors', () {
      final tabs = ShellTab.tabsForMode(InterfaceMode.simple);
      expect(tabs.length, 3);

      final ids = tabs.map((t) => t.id).toList();
      expect(ids, ['today', 'lessons', 'help']);
    });

    test('ShellTab localizedLabel provides Arabic and English labels', () {
      const tab = ShellTab(
        id: 'home',
        labelArabic: 'الرئيسية',
        labelEnglish: 'Home',
        icon: Icons.home,
        activeIcon: Icons.home_filled,
      );

      expect(tab.localizedLabel(AppLocale.ar), 'الرئيسية');
      expect(tab.localizedLabel(AppLocale.en), 'Home');
    });
  });
}
