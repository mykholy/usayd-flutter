import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/interface_mode.dart';
import '../../../core/config/user_preferences.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/routing/app_route.dart';
import '../../../core/theme/usayd_colors.dart';
import '../../../core/theme/usayd_radii.dart';
import '../../../core/theme/usayd_typography.dart';
import '../domain/shell_tab.dart';

/// Routed version of the Adaptive Shell that synchronizes active tabs with GoRouter location.
class RoutedAdaptiveShell extends StatelessWidget {
  final Widget child;
  final UserPreferences preferences;
  final ValueChanged<AppLocale>? onLocaleChanged;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final ValueChanged<InterfaceMode>? onModeChanged;

  const RoutedAdaptiveShell({
    super.key,
    required this.child,
    required this.preferences,
    this.onLocaleChanged,
    this.onThemeModeChanged,
    this.onModeChanged,
  });

  static String routeForTab(ShellTab tab, InterfaceMode mode) {
    switch (mode) {
      case InterfaceMode.kids:
        switch (tab.id) {
          case 'mission':
            return AppRoute.kidsMission;
          case 'path':
            return AppRoute.kidsPath;
          case 'stars':
            return AppRoute.kidsStars;
          case 'me':
            return AppRoute.kidsMe;
        }
        return AppRoute.kidsMission;
      case InterfaceMode.simple:
        switch (tab.id) {
          case 'today':
            return AppRoute.simpleToday;
          case 'lessons':
            return AppRoute.simpleLessons;
          case 'help':
            return AppRoute.simpleHelp;
        }
        return AppRoute.simpleToday;
      case InterfaceMode.pro:
        switch (tab.id) {
          case 'home':
            return AppRoute.proHome;
          case 'lessons':
            return AppRoute.proLessons;
          case 'recite':
            return AppRoute.proRecite;
          case 'progress':
            return AppRoute.proProgress;
          case 'profile':
            return AppRoute.proProfile;
        }
        return AppRoute.proHome;
    }
  }

  int _calculateSelectedIndex(BuildContext context, List<ShellTab> tabs) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < tabs.length; i++) {
      if (location == routeForTab(tabs[i], preferences.interfaceMode)) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.extension<UsaydColorScheme>() ?? UsaydColorScheme.light;
    final tabs = ShellTab.tabsForMode(preferences.interfaceMode);
    final selectedIndex = _calculateSelectedIndex(context, tabs);

    final double barHeight = switch (preferences.interfaceMode) {
      InterfaceMode.kids => 70.0,
      InterfaceMode.pro => 64.0,
      InterfaceMode.simple => 76.0,
    };

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(top: false, bottom: false, child: child),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.bgRaised,
          border: Border(
            top: BorderSide(
              color: preferences.interfaceMode == InterfaceMode.simple
                  ? colors.lineStrong
                  : colors.line,
              width: preferences.interfaceMode == InterfaceMode.simple
                  ? 1.5
                  : 1.0,
            ),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            height: barHeight,
            backgroundColor: colors.bgRaised,
            indicatorColor: preferences.interfaceMode == InterfaceMode.kids
                ? colors.lamp
                : colors.bgSubtle,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: UsaydRadii.full,
            ),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: preferences.interfaceMode == InterfaceMode.simple
                    ? 14.0
                    : 12.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colors.txBrand : colors.tx2,
                fontFamily: UsaydTypography.fontFamilyBody,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return IconThemeData(
                size: preferences.interfaceMode == InterfaceMode.simple
                    ? 28.0
                    : 24.0,
                color: isSelected ? colors.act : colors.tx2,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              final targetPath = routeForTab(
                tabs[index],
                preferences.interfaceMode,
              );
              context.go(targetPath);
            },
            destinations: [
              for (final tab in tabs)
                NavigationDestination(
                  key: Key('shell_tab_${tab.id}'),
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.activeIcon),
                  label: tab.localizedLabel(preferences.locale),
                  tooltip: tab.localizedLabel(preferences.locale),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
