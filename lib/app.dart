import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'core/config/flavor_config.dart';
import 'core/config/interface_mode.dart';
import 'core/config/user_preferences.dart';
import 'core/localization/usayd_localizations.dart';
import 'core/network/models/user_profile.dart';
import 'core/routing/app_route.dart';
import 'core/routing/app_router.dart';
import 'core/routing/auth_state_notifier.dart';
import 'core/theme/usayd_theme.dart';

class UsaydApp extends StatefulWidget {
  final UserPreferences? initialPreferences;
  final InterfaceMode? initialMode;
  final AuthStateNotifier? authNotifier;
  final GoRouter? router;

  const UsaydApp({
    super.key,
    this.initialPreferences,
    this.initialMode,
    this.authNotifier,
    this.router,
  });

  @override
  State<UsaydApp> createState() => _UsaydAppState();
}

class _UsaydAppState extends State<UsaydApp> {
  late final AuthStateNotifier _authNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final prefs =
        widget.initialPreferences ??
        UserPreferences(interfaceMode: widget.initialMode ?? InterfaceMode.pro);

    _authNotifier =
        widget.authNotifier ??
        AuthStateNotifier(
          isAuthenticated: true,
          user: const UserProfile(
            id: 1,
            name: 'أكاديمية أُسَيْد',
            email: 'learner@usayd.academy',
            locale: 'ar',
            country: 'EG',
            timezone: 'Africa/Cairo',
            status: 'active',
            role: 'learner',
            isMinor: false,
          ),
          preferences: prefs,
        );

    _router =
        widget.router ??
        AppRouter.createRouter(
          _authNotifier,
          initialLocation: AppRoute.defaultRouteForMode(
            _authNotifier.currentMode.name,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authNotifier,
      builder: (context, _) {
        final prefs = _authNotifier.preferences;
        return MaterialApp.router(
          routerConfig: _router,
          title: 'أكاديمية أُسَيْد',
          debugShowCheckedModeBanner: FlavorConfig.isDev,
          theme: UsaydTheme.light(prefs.interfaceMode),
          darkTheme: UsaydTheme.dark(prefs.interfaceMode),
          themeMode: prefs.themeMode,
          locale: prefs.locale.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            UsaydLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return Directionality(
              textDirection: prefs.locale.textDirection,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
