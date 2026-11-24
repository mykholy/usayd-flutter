/// Canonical route path constants for Usayd Academy mobile application
/// Source: `02_design_system/AGE_ADAPTIVE_UI.md`, `03_screens/SCREEN_INVENTORY.csv`
class AppRoute {
  AppRoute._();

  // Public / Authentication routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String unauthorized = '/unauthorized';

  // Shell base & common tabs (Pro mode)
  static const String proHome = '/app/home';
  static const String proLessons = '/app/lessons';
  static const String proRecite = '/app/recite';
  static const String proProgress = '/app/progress';
  static const String proProfile = '/app/profile';

  // Kids Mode tabs
  static const String kidsMission = '/app/mission';
  static const String kidsPath = '/app/path';
  static const String kidsStars = '/app/stars';
  static const String kidsMe = '/app/me';

  // Simple Mode tabs
  static const String simpleToday = '/app/today';
  static const String simpleLessons = '/app/simple-lessons';
  static const String simpleHelp = '/app/help';

  // Role & Permission Restricted Routes
  static const String teacherRoom = '/teacher/room';
  static const String adminSettings = '/admin/settings';
  static const String billing = '/app/billing'; // Restricted for minors (O-04)

  /// Public routes that do not require authentication
  static const Set<String> publicRoutes = {
    splash,
    login,
    register,
    unauthorized,
  };

  /// Routes strictly forbidden for minors (requiring adult/guardian authentication)
  static const Set<String> adultOnlyRoutes = {billing};

  /// Resolves the default home route for a given interface mode
  static String defaultRouteForMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'kids':
        return kidsMission;
      case 'simple':
        return simpleToday;
      case 'pro':
      default:
        return proHome;
    }
  }
}
