import 'package:flutter/material.dart';
import '../../../core/config/interface_mode.dart';
import '../../../core/config/user_preferences.dart';
import '../../../core/localization/app_locale.dart';
import '../../../core/localization/usayd_localizations.dart';
import '../../../core/theme/usayd_colors.dart';
import '../../../core/theme/usayd_mode_theme.dart';
import '../../../core/theme/usayd_radii.dart';
import '../../../core/theme/usayd_spacing.dart';
import '../../../core/theme/usayd_typography.dart';
import '../../home/presentation/screens/home_screen.dart';
import '../domain/shell_tab.dart';

/// Responsive mobile shell adapting navigation, safe-areas, and keyboard handling
/// per Age-Adaptive Interface Mode (Kids: 4 tabs, Pro: 5 tabs, Simple: 3 tabs).
/// Source: `02_design_system/AGE_ADAPTIVE_UI.md`
class AdaptiveShell extends StatefulWidget {
  final UserPreferences preferences;
  final ValueChanged<AppLocale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<InterfaceMode> onModeChanged;

  const AdaptiveShell({
    super.key,
    required this.preferences,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
    required this.onModeChanged,
  });

  @override
  State<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends State<AdaptiveShell> {
  int _selectedIndex = 0;

  @override
  void didUpdateWidget(AdaptiveShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When interface mode changes, clamp the active tab index within the new mode's tab bounds
    final newTabs = ShellTab.tabsForMode(widget.preferences.interfaceMode);
    if (_selectedIndex >= newTabs.length) {
      _selectedIndex = 0;
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.extension<UsaydColorScheme>() ?? UsaydColorScheme.light;
    final modeTheme =
        theme.extension<UsaydModeTheme>() ??
        UsaydModeTheme.forMode(widget.preferences.interfaceMode);
    final tabs = ShellTab.tabsForMode(widget.preferences.interfaceMode);

    return Scaffold(
      // Responsive keyboard handling: prevents bottom bar overflow when keyboard opens
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false, // Let AppBar handle top notch safely
        bottom: false,
        child: _buildTabBody(tabs[_selectedIndex]),
      ),
      bottomNavigationBar: _buildNavigationBar(colors, modeTheme, tabs),
    );
  }

  Widget _buildTabBody(ShellTab currentTab) {
    // Tab 0 is always the Home / Dashboard screen
    if (_selectedIndex == 0) {
      return HomeScreen(
        preferences: widget.preferences,
        onLocaleChanged: widget.onLocaleChanged,
        onThemeModeChanged: widget.onThemeModeChanged,
        onModeChanged: widget.onModeChanged,
      );
    }

    // Secondary placeholder views with safe responsive containers
    final l10n = UsaydLocalizations.of(context);
    final colors =
        Theme.of(context).extension<UsaydColorScheme>() ??
        UsaydColorScheme.light;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentTab.localizedLabel(widget.preferences.locale),
          style: UsaydTypography.headingM.copyWith(color: colors.txOnBrand),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(UsaydSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(currentTab.activeIcon, size: 64, color: colors.act),
                const SizedBox(height: UsaydSpacing.md),
                Text(
                  currentTab.localizedLabel(widget.preferences.locale),
                  style: UsaydTypography.headingL.copyWith(color: colors.tx),
                ),
                const SizedBox(height: UsaydSpacing.sm),
                Text(
                  '${l10n.brandName} · ${currentTab.id.toUpperCase()}',
                  style: UsaydTypography.bodyM.copyWith(color: colors.tx2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationBar(
    UsaydColorScheme colors,
    UsaydModeTheme modeTheme,
    List<ShellTab> tabs,
  ) {
    // Mode-adaptive height and styling
    final double barHeight = switch (widget.preferences.interfaceMode) {
      InterfaceMode.kids => 70.0,
      InterfaceMode.pro => 64.0,
      InterfaceMode.simple => 76.0,
    };

    return Container(
      decoration: BoxDecoration(
        color: colors.bgRaised,
        border: Border(
          top: BorderSide(
            color: widget.preferences.interfaceMode == InterfaceMode.simple
                ? colors.lineStrong
                : colors.line,
            width: widget.preferences.interfaceMode == InterfaceMode.simple
                ? 1.5
                : 1.0,
          ),
        ),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: barHeight,
          backgroundColor: colors.bgRaised,
          indicatorColor: widget.preferences.interfaceMode == InterfaceMode.kids
              ? colors.lamp
              : colors.bgSubtle,
          indicatorShape: RoundedRectangleBorder(borderRadius: UsaydRadii.full),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: widget.preferences.interfaceMode == InterfaceMode.simple
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
              size: widget.preferences.interfaceMode == InterfaceMode.simple
                  ? 28.0
                  : 24.0,
              color: isSelected ? colors.act : colors.tx2,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onTabSelected,
          destinations: [
            for (final tab in tabs)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.activeIcon),
                label: tab.localizedLabel(widget.preferences.locale),
                tooltip: tab.localizedLabel(widget.preferences.locale),
              ),
          ],
        ),
      ),
    );
  }
}
