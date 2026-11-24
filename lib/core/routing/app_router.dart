import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/shell/presentation/routed_adaptive_shell.dart';
import 'app_route.dart';
import 'auth_state_notifier.dart';
import 'route_guard.dart';

/// Configures and creates the GoRouter instance for Usayd Academy.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNav');
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellNav');

  static GoRouter createRouter(
    AuthStateNotifier authNotifier, {
    String initialLocation = AppRoute.splash,
  }) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialLocation,
      refreshListenable: authNotifier,
      redirect: (context, state) =>
          RouteGuard.redirect(context, state, authNotifier),
      routes: [
        // Public Auth & System Routes
        GoRoute(
          path: AppRoute.splash,
          builder: (context, state) => const _RoutePlaceholderScreen(
            key: Key('screen_splash'),
            title: 'Splash Screen',
            routeName: AppRoute.splash,
          ),
        ),
        GoRoute(
          path: AppRoute.login,
          builder: (context, state) => const _RoutePlaceholderScreen(
            key: Key('screen_login'),
            title: 'Login Screen',
            routeName: AppRoute.login,
          ),
        ),
        GoRoute(
          path: AppRoute.register,
          builder: (context, state) => const _RoutePlaceholderScreen(
            key: Key('screen_register'),
            title: 'Register Screen',
            routeName: AppRoute.register,
          ),
        ),
        GoRoute(
          path: AppRoute.unauthorized,
          builder: (context, state) => const _RoutePlaceholderScreen(
            key: Key('screen_unauthorized'),
            title: 'Access Denied / Unauthorized',
            routeName: AppRoute.unauthorized,
          ),
        ),

        // Standalone Restricted Routes (Outside Shell)
        GoRoute(
          path: AppRoute.teacherRoom,
          builder: (context, state) => const _RoutePlaceholderScreen(
            key: Key('screen_teacher_room'),
            title: 'Teacher Live Session Room',
            routeName: AppRoute.teacherRoom,
          ),
        ),
        GoRoute(
          path: AppRoute.adminSettings,
          builder: (context, state) => const _RoutePlaceholderScreen(
            key: Key('screen_admin_settings'),
            title: 'Admin Governance Settings',
            routeName: AppRoute.adminSettings,
          ),
        ),

        // Main Shell Route hosting age-adaptive tabs
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) {
            return RoutedAdaptiveShell(
              preferences: authNotifier.preferences,
              onLocaleChanged: (locale) => authNotifier.updatePreferences(
                authNotifier.preferences.copyWith(locale: locale),
              ),
              onThemeModeChanged: (themeMode) => authNotifier.updatePreferences(
                authNotifier.preferences.copyWith(themeMode: themeMode),
              ),
              onModeChanged: (mode) {
                authNotifier.updateMode(mode);
                final target = AppRoute.defaultRouteForMode(mode.name);
                context.go(target);
              },
              child: child,
            );
          },
          routes: [
            // Pro Mode routes
            GoRoute(
              path: AppRoute.proHome,
              builder: (context, state) => HomeScreen(
                key: const Key('screen_pro_home'),
                preferences: authNotifier.preferences,
                onLocaleChanged: (locale) => authNotifier.updatePreferences(
                  authNotifier.preferences.copyWith(locale: locale),
                ),
                onThemeModeChanged: (themeMode) =>
                    authNotifier.updatePreferences(
                      authNotifier.preferences.copyWith(themeMode: themeMode),
                    ),
                onModeChanged: (mode) {
                  authNotifier.updateMode(mode);
                  final target = AppRoute.defaultRouteForMode(mode.name);
                  context.go(target);
                },
              ),
            ),
            GoRoute(
              path: AppRoute.proLessons,
              builder: (context, state) => const _RoutePlaceholderScreen(
                key: Key('screen_pro_lessons'),
                title: 'Professional Lessons',
                routeName: AppRoute.proLessons,
              ),
            ),
            GoRoute(
              path: AppRoute.proRecite,
              builder: (context, state) => const _RoutePlaceholderScreen(
                key: Key('screen_pro_recite'),
                title: 'Professional Recitation',
                routeName: AppRoute.proRecite,
              ),
            ),
            GoRoute(
              path: AppRoute.proProgress,
              builder: (context, state) => const _RoutePlaceholderScreen(
                key: Key('screen_pro_progress'),
                title: 'Professional Progress',
                routeName: AppRoute.proProgress,
              ),
            ),
            GoRoute(
              path: AppRoute.proProfile,
              builder: (context, state) => const _RoutePlaceholderScreen(
                key: Key('screen_pro_profile'),
                title: 'User Profile & Settings',
                routeName: AppRoute.proProfile,
              ),
            ),

            // Kids Mode routes
            GoRoute(
              path: AppRoute.kidsMission,
              builder: (context, state) => HomeScreen(
                key: const Key('screen_kids_mission'),
                preferences: authNotifier.preferences,
                onLocaleChanged: (locale) => authNotifier.updatePreferences(
                  authNotifier.preferences.copyWith(locale: locale),
                ),
                onThemeModeChanged: (themeMode) =>
                    authNotifier.updatePreferences(
                      authNotifier.preferences.copyWith(themeMode: themeMode),
                    ),
                onModeChanged: (mode) {
                  authNotifier.updateMode(mode);
                  final target = AppRoute.defaultRouteForMode(mode.name);
                  context.go(target);
                },
              ),
            ),
            GoRoute(
              path: AppRoute.kidsPath,
              builder: (context, state) => const _RoutePlaceholderScreen(
                key: Key('screen_kids_path'),
                title: 'Kids Learning Path',
                routeName: AppRoute.kidsPath,
              ),
            ),
            GoRoute(
              path: AppRoute.kidsStars,
              builder: (context, state) => const _RoutePlaceholderScreen(
                key: Key('screen_kids_stars'),
                title: 'Kids Stars & Rewards',
                routeName: AppRoute.kidsStars,
              ),
            ),
            GoRoute(
              path: AppRoute.kidsMe,
              builder: (context, state) => const _RoutePlaceholderScreen(
                key: Key('screen_kids_me'),
                title: 'Kids Profile (Me)',
                routeName: AppRoute.kidsMe,
              ),
            ),

            // Simple Mode routes
            GoRoute(
              path: AppRoute.simpleToday,
              builder: (context, state) => HomeScreen(
                key: const Key('screen_simple_today'),
                preferences: authNotifier.preferences,
                onLocaleChanged: (locale) => authNotifier.updatePreferences(
                  authNotifier.preferences.copyWith(locale: locale),
                ),
                onThemeModeChanged: (themeMode) =>
                    authNotifier.updatePreferences(
                      authNotifier.preferences.copyWith(themeMode: themeMode),
                    ),
                onModeChanged: (mode) {
                  authNotifier.updateMode(mode);
                  final target = AppRoute.defaultRouteForMode(mode.name);
                  context.go(target);
                },
              ),
            ),
            GoRoute(
              path: AppRoute.simpleLessons,
              builder: (context, state) => const _RoutePlaceholderScreen(
                key: Key('screen_simple_lessons'),
                title: 'Simple Lessons',
                routeName: AppRoute.simpleLessons,
              ),
            ),
            GoRoute(
              path: AppRoute.simpleHelp,
              builder: (context, state) => const _RoutePlaceholderScreen(
                key: Key('screen_simple_help'),
                title: 'Simple Help & Assistance',
                routeName: AppRoute.simpleHelp,
              ),
            ),

            // Adult Billing Route (Child-restricted)
            GoRoute(
              path: AppRoute.billing,
              builder: (context, state) => const _RoutePlaceholderScreen(
                key: Key('screen_billing'),
                title: 'Billing & Subscriptions (Adults)',
                routeName: AppRoute.billing,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Generic placeholder screen for routed destinations during foundation testing
class _RoutePlaceholderScreen extends StatelessWidget {
  final String title;
  final String routeName;

  const _RoutePlaceholderScreen({
    super.key,
    required this.title,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    final segment = routeName.split('/').last.toUpperCase();
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8.0),
            Text(
              '$segment SCREEN',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4.0),
            Text(
              'Route: $routeName',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
