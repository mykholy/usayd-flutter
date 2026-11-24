import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'app_route.dart';
import 'auth_state_notifier.dart';

/// Route guard evaluating authentication status, role boundaries, and minor protections.
/// Source: `02_design_system/AGE_ADAPTIVE_UI.md`, `DECISION_REQUIRED_FROM_OWNER.md` (O-04)
class RouteGuard {
  RouteGuard._();

  /// Evaluates navigation and returns a redirect target path if access is restricted,
  /// or null if the navigation is authorized to proceed.
  static String? redirect(
    BuildContext context,
    GoRouterState state,
    AuthStateNotifier auth,
  ) {
    return evaluate(state.matchedLocation, auth);
  }

  /// Pure logical evaluation of navigation location against auth state.
  static String? evaluate(String location, AuthStateNotifier auth) {
    final isLoading = auth.isLoading;
    final isAuthenticated = auth.isAuthenticated;

    // 1. If still loading, stay on or redirect to splash screen
    if (isLoading) {
      return location == AppRoute.splash ? null : AppRoute.splash;
    }

    // 2. Unauthenticated access control
    if (!isAuthenticated) {
      if (AppRoute.publicRoutes.contains(location)) {
        return null;
      }
      return AppRoute.login;
    }

    // 3. Authenticated user attempting to visit guest/auth screens
    if (location == AppRoute.login ||
        location == AppRoute.register ||
        location == AppRoute.splash) {
      return AppRoute.defaultRouteForMode(auth.currentMode.name);
    }

    // 4. Minor Protection Guard (O-04): Minors restricted from adult/paid learning settings
    if (auth.isMinor && AppRoute.adultOnlyRoutes.contains(location)) {
      return AppRoute.defaultRouteForMode(auth.currentMode.name);
    }

    // 5. Role-based Access Control (Teacher namespace)
    if (location.startsWith('/teacher') &&
        auth.role != 'teacher' &&
        auth.role != 'admin') {
      return AppRoute.unauthorized;
    }

    // 6. Role-based Access Control (Admin namespace)
    if (location.startsWith('/admin') && auth.role != 'admin') {
      return AppRoute.unauthorized;
    }

    // Authorized
    return null;
  }
}
