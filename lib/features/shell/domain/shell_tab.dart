import 'package:flutter/material.dart';
import '../../../core/config/interface_mode.dart';
import '../../../core/localization/app_locale.dart';

/// Navigation tab representation for Usayd Academy mobile shells
/// Source: `02_design_system/AGE_ADAPTIVE_UI.md`
class ShellTab {
  final String id;
  final String labelArabic;
  final String labelEnglish;
  final IconData icon;
  final IconData activeIcon;

  const ShellTab({
    required this.id,
    required this.labelArabic,
    required this.labelEnglish,
    required this.icon,
    required this.activeIcon,
  });

  String localizedLabel(AppLocale locale) =>
      locale == AppLocale.ar ? labelArabic : labelEnglish;

  /// Kids Mode Tabs (4 tabs): Mission, Path, Stars, Me
  static const List<ShellTab> kidsTabs = [
    ShellTab(
      id: 'mission',
      labelArabic: 'مهمتي',
      labelEnglish: 'Mission',
      icon: Icons.flag_outlined,
      activeIcon: Icons.flag_rounded,
    ),
    ShellTab(
      id: 'path',
      labelArabic: 'طريقي',
      labelEnglish: 'Path',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
    ),
    ShellTab(
      id: 'stars',
      labelArabic: 'نجومي',
      labelEnglish: 'Stars',
      icon: Icons.star_border_rounded,
      activeIcon: Icons.star_rounded,
    ),
    ShellTab(
      id: 'me',
      labelArabic: 'أنا',
      labelEnglish: 'Me',
      icon: Icons.face_outlined,
      activeIcon: Icons.face_rounded,
    ),
  ];

  /// Professional Mode Tabs (5 tabs): Home, Lessons, Recite, Progress, Profile
  static const List<ShellTab> proTabs = [
    ShellTab(
      id: 'home',
      labelArabic: 'الرئيسية',
      labelEnglish: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    ShellTab(
      id: 'lessons',
      labelArabic: 'الدروس',
      labelEnglish: 'Lessons',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
    ),
    ShellTab(
      id: 'recite',
      labelArabic: 'التلاوة',
      labelEnglish: 'Recite',
      icon: Icons.mic_none_rounded,
      activeIcon: Icons.mic_rounded,
    ),
    ShellTab(
      id: 'progress',
      labelArabic: 'تقدمي',
      labelEnglish: 'Progress',
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
    ),
    ShellTab(
      id: 'profile',
      labelArabic: 'حسابي',
      labelEnglish: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  /// Simple Mode Tabs (3 tabs): Today, Lessons, Help
  static const List<ShellTab> simpleTabs = [
    ShellTab(
      id: 'today',
      labelArabic: 'ورد اليوم',
      labelEnglish: 'Today',
      icon: Icons.wb_sunny_outlined,
      activeIcon: Icons.wb_sunny_rounded,
    ),
    ShellTab(
      id: 'lessons',
      labelArabic: 'الدروس',
      labelEnglish: 'Lessons',
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
    ),
    ShellTab(
      id: 'help',
      labelArabic: 'المساعدة',
      labelEnglish: 'Help',
      icon: Icons.help_outline_rounded,
      activeIcon: Icons.help_rounded,
    ),
  ];

  /// Returns the canonical tabs for a given interface mode
  static List<ShellTab> tabsForMode(InterfaceMode mode) {
    switch (mode) {
      case InterfaceMode.kids:
        return kidsTabs;
      case InterfaceMode.pro:
        return proTabs;
      case InterfaceMode.simple:
        return simpleTabs;
    }
  }
}
