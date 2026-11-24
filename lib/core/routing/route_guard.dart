import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'app_route.dart';
import 'auth_state_notifier.dart';

/// Route guard evaluating authentication status, role boundaries, and minor protections.
/// Source: `02_design_system/AGE_ADAPTIVE_UI.md`, `DECISION_REQUIRED_FROM_OWNER.md` (O-04)
///
/// Architectural Security Note:
/// Client-side route guards provide UX guidance and navigation state consistency only.
/// They NEVER constitute server authorization. The authoritative Laravel 13 backend
/// strictly enforces token abilities, RBAC policies, and gate boundaries on every request.
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

    // 3. Fail closed: If marked authenticated but user profile is null, require login
    final user = auth.user;
    if (user == null) {
      return AppRoute.login;
    }

    // 4. Fail closed: Missing role or non-active account status
    if (user.role.isEmpty || user.status != 'active') {
      return AppRoute.unauthorized;
    }

    // 5. Authenticated user attempting to visit guest/auth screens
    if (location == AppRoute.login ||
        location == AppRoute.register ||
        location == AppRoute.splash) {
      return AppRoute.defaultRouteForMode(auth.currentMode.name);
    }

    // 6. Minor Protection Guard (O-04): Minors restricted from adult/paid learning settings
    if (auth.isMinor && AppRoute.adultOnlyRoutes.contains(location)) {
      return AppRoute.defaultRouteForMode(auth.currentMode.name);
    }

    // 7. Role-based Access Control (Teacher namespace)
    if (location.startsWith('/teacher') &&
        auth.role != 'teacher' &&
        auth.role != 'admin') {
      return AppRoute.unauthorized;
    }

    // 8. Role-based Access Control (Admin namespace)
    if (location.startsWith('/admin') && auth.role != 'admin') {
      return AppRoute.unauthorized;
    }

    // Authorized
    return null;
  }
}
