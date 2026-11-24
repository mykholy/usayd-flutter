import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/config/flavor_config.dart';
import 'core/config/interface_mode.dart';
import 'core/config/user_preferences.dart';
import 'core/localization/app_locale.dart';
import 'core/localization/usayd_localizations.dart';
import 'core/theme/usayd_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';

class UsaydApp extends StatefulWidget {
  final UserPreferences? initialPreferences;
  final InterfaceMode? initialMode;

  const UsaydApp({super.key, this.initialPreferences, this.initialMode});

  @override
  State<UsaydApp> createState() => _UsaydAppState();
}

class _UsaydAppState extends State<UsaydApp> {
  late UserPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _preferences =
        widget.initialPreferences ??
        UserPreferences(interfaceMode: widget.initialMode ?? InterfaceMode.pro);
  }

  void _onLocaleChanged(AppLocale newLocale) {
    setState(() {
      _preferences = _preferences.copyWith(locale: newLocale);
    });
  }

  void _onThemeModeChanged(ThemeMode newThemeMode) {
    setState(() {
      _preferences = _preferences.copyWith(themeMode: newThemeMode);
    });
  }

  void _onInterfaceModeChanged(InterfaceMode newInterfaceMode) {
    setState(() {
      _preferences = _preferences.copyWith(interfaceMode: newInterfaceMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أكاديمية أُسَيْد',
      debugShowCheckedModeBanner: FlavorConfig.isDev,
      theme: UsaydTheme.light(_preferences.interfaceMode),
      darkTheme: UsaydTheme.dark(_preferences.interfaceMode),
      themeMode: _preferences.themeMode,
      locale: _preferences.locale.locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        UsaydLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: _preferences.locale.textDirection,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: HomeScreen(
        preferences: _preferences,
        onLocaleChanged: _onLocaleChanged,
        onThemeModeChanged: _onThemeModeChanged,
        onModeChanged: _onInterfaceModeChanged,
      ),
    );
  }
}
