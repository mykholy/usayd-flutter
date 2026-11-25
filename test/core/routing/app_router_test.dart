import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import 'package:usayd_flutter/core/config/user_preferences.dart';
import 'package:usayd_flutter/core/network/models/user_profile.dart';
import 'package:usayd_flutter/core/routing/app_route.dart';
import 'package:usayd_flutter/core/routing/app_router.dart';
import 'package:usayd_flutter/core/routing/auth_state_notifier.dart';
import 'package:usayd_flutter/core/routing/route_guard.dart';
import 'package:usayd_flutter/features/home/presentation/screens/home_screen.dart';

import '../../helpers/authenticated_app_fixture.dart';

void main() {
  group('RouteGuard Unit Tests', () {
    test('unauthenticated user is allowed on public routes', () {
      final auth = AuthStateNotifier(isAuthenticated: false);

      expect(RouteGuard.evaluate(AppRoute.splash, auth), isNull);
      expect(RouteGuard.evaluate(AppRoute.login, auth), isNull);
      expect(RouteGuard.evaluate(AppRoute.register, auth), isNull);
      expect(RouteGuard.evaluate(AppRoute.unauthorized, auth), isNull);
    });

    test('unauthenticated user on protected route is redirected to login', () {
      final auth = AuthStateNotifier(isAuthenticated: false);

      expect(
        RouteGuard.evaluate(AppRoute.proHome, auth),
        equals(AppRoute.login),
      );
      expect(
        RouteGuard.evaluate(AppRoute.kidsMission, auth),
        equals(AppRoute.login),
      );
      expect(
        RouteGuard.evaluate(AppRoute.teacherRoom, auth),
        equals(AppRoute.login),
      );
    });

    test(
      'authenticated user on auth routes is redirected to default home for mode',
      () {
        final user = _mockUser(role: 'learner');
        final auth = AuthStateNotifier(
          isAuthenticated: true,
          user: user,
          preferences: const UserPreferences(interfaceMode: InterfaceMode.pro),
        );

        expect(
          RouteGuard.evaluate(AppRoute.login, auth),
          equals(AppRoute.proHome),
        );
        expect(
          RouteGuard.evaluate(AppRoute.register, auth),
          equals(AppRoute.proHome),
        );

        // In Kids mode, redirects to kidsMission
        auth.updateMode(InterfaceMode.kids);
        expect(
          RouteGuard.evaluate(AppRoute.login, auth),
          equals(AppRoute.kidsMission),
        );

        // In Simple mode, redirects to simpleToday
        auth.updateMode(InterfaceMode.simple);
        expect(
          RouteGuard.evaluate(AppRoute.login, auth),
          equals(AppRoute.simpleToday),
        );
      },
    );

    test('minor user is blocked from adult billing route (O-04)', () {
      final minorUser = _mockUser(role: 'learner', isMinor: true);
      final auth = AuthStateNotifier(
        isAuthenticated: true,
        user: minorUser,
        preferences: const UserPreferences(interfaceMode: InterfaceMode.kids),
      );

      expect(
        RouteGuard.evaluate(AppRoute.billing, auth),
        equals(AppRoute.kidsMission),
      );
    });

    test('adult user is allowed on billing route', () {
      final adultUser = _mockUser(role: 'learner', isMinor: false);
      final auth = AuthStateNotifier(
        isAuthenticated: true,
        user: adultUser,
        preferences: const UserPreferences(interfaceMode: InterfaceMode.pro),
      );

      expect(RouteGuard.evaluate(AppRoute.billing, auth), isNull);
    });

    test(
      'learner is blocked from teacher room and redirected to unauthorized',
      () {
        final learner = _mockUser(role: 'learner');
        final auth = AuthStateNotifier(isAuthenticated: true, user: learner);

        expect(
          RouteGuard.evaluate(AppRoute.teacherRoom, auth),
          equals(AppRoute.unauthorized),
        );
      },
    );

    test('teacher is allowed in teacher room', () {
      final teacher = _mockUser(role: 'teacher');
      final auth = AuthStateNotifier(isAuthenticated: true, user: teacher);

      expect(RouteGuard.evaluate(AppRoute.teacherRoom, auth), isNull);
    });

    test('non-admin is blocked from admin settings', () {
      final teacher = _mockUser(role: 'teacher');
      final auth = AuthStateNotifier(isAuthenticated: true, user: teacher);

      expect(
        RouteGuard.evaluate(AppRoute.adminSettings, auth),
        equals(AppRoute.unauthorized),
      );
    });

    test('admin is allowed in admin settings', () {
      final admin = _mockUser(role: 'admin');
      final auth = AuthStateNotifier(isAuthenticated: true, user: admin);

      expect(RouteGuard.evaluate(AppRoute.adminSettings, auth), isNull);
    });

    test('authenticated with null profile fails closed to login', () {
      final auth = AuthStateNotifier(isAuthenticated: true, user: null);
      expect(
        RouteGuard.evaluate(AppRoute.proHome, auth),
        equals(AppRoute.login),
      );
    });

    test('missing role or non-active status fails closed to unauthorized', () {
      final noRoleUser = _mockUser(role: '');
      final authNoRole = AuthStateNotifier(
        isAuthenticated: true,
        user: noRoleUser,
      );
      expect(
        RouteGuard.evaluate(AppRoute.proHome, authNoRole),
        equals(AppRoute.unauthorized),
      );

      final suspendedUser = const UserProfile(
        id: 1,
        name: 'Suspended',
        email: 'suspended@usayd.com',
        locale: 'ar',
        country: 'EG',
        timezone: 'UTC',
        status: 'suspended',
        role: 'learner',
      );
      final authSuspended = AuthStateNotifier(
        isAuthenticated: true,
        user: suspendedUser,
      );
      expect(
        RouteGuard.evaluate(AppRoute.proHome, authSuspended),
        equals(AppRoute.unauthorized),
      );
    });
  });

  group('AppRouter Widget & Navigation Tests', () {
    testWidgets('unauthenticated user starting at /app/home lands on /login', (
      tester,
    ) async {
      final auth = AuthStateNotifier(isAuthenticated: false);
      final router = AppRouter.createRouter(
        auth,
        initialLocation: AppRoute.proHome,
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('screen_login')), findsOneWidget);
    });

    testWidgets('authenticated user lands on home and can switch tabs', (
      tester,
    ) async {
      final user = _mockUser(role: 'learner');
      final auth = AuthStateNotifier(
        isAuthenticated: true,
        user: user,
        preferences: const UserPreferences(interfaceMode: InterfaceMode.pro),
      );
      final router = AppRouter.createRouter(auth);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Pro mode starts at proHome which renders HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Tap on Lessons tab
      final lessonsTab = find.byKey(const Key('shell_tab_lessons'));
      expect(lessonsTab, findsOneWidget);
      await tester.tap(lessonsTab);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('screen_pro_lessons')), findsOneWidget);
    });

    testWidgets('switching mode updates shell tabs appropriately', (
      tester,
    ) async {
      final user = _mockUser(role: 'learner');
      final auth = AuthStateNotifier(
        isAuthenticated: true,
        user: user,
        preferences: const UserPreferences(interfaceMode: InterfaceMode.kids),
      );
      final router = AppRouter.createRouter(auth);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Kids mode starts at kidsMission
      expect(find.byKey(const Key('screen_kids_mission')), findsOneWidget);
      expect(find.byKey(const Key('shell_tab_mission')), findsOneWidget);
      expect(find.byKey(const Key('shell_tab_path')), findsOneWidget);
      expect(find.byKey(const Key('shell_tab_stars')), findsOneWidget);
      expect(find.byKey(const Key('shell_tab_me')), findsOneWidget);
    });

    testWidgets(
      'UsaydApp root widget renders via MaterialApp.router and route guard',
      (tester) async {
        await tester.pumpWidget(authenticatedAppFixture());
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byKey(const Key('shell_tab_lessons')), findsOneWidget);
      },
    );
  });
}

UserProfile _mockUser({required String role, bool isMinor = false}) {
  return UserProfile(
    id: 1,
    name: 'Test User',
    email: 'test@usayd.com',
    locale: 'ar',
    country: 'SA',
    timezone: 'Asia/Riyadh',
    status: 'active',
    role: role,
    isMinor: isMinor,
  );
}
