import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/app.dart';
import 'package:usayd_flutter/core/config/interface_mode.dart';
import 'package:usayd_flutter/core/config/user_preferences.dart';
import 'package:usayd_flutter/core/network/models/user_profile.dart';
import 'package:usayd_flutter/core/routing/auth_state_notifier.dart';

/// Explicit test-only authenticated session for visual and navigation tests.
UsaydApp authenticatedAppFixture({
  UserPreferences? initialPreferences,
  InterfaceMode? initialMode,
}) {
  final preferences =
      initialPreferences ??
      UserPreferences(interfaceMode: initialMode ?? InterfaceMode.pro);
  final auth = AuthStateNotifier(
    isAuthenticated: true,
    user: const UserProfile(
      id: 1,
      name: 'Fixture Learner',
      email: 'fixture@example.invalid',
      locale: 'ar',
      country: 'EG',
      timezone: 'Africa/Cairo',
      status: 'active',
      role: 'learner',
      isMinor: false,
    ),
    preferences: preferences,
  );
  addTearDown(auth.dispose);
  return UsaydApp(authNotifier: auth);
}
