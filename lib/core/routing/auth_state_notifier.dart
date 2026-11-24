import 'package:flutter/foundation.dart';
import '../config/interface_mode.dart';
import '../config/user_preferences.dart';
import '../network/models/user_profile.dart';

/// Reactive authentication and account authorization state notifier
/// Triggers route recalculation on authentication, role changes, or mode switching.
class AuthStateNotifier extends ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  UserProfile? _user;
  UserPreferences _preferences;

  AuthStateNotifier({
    bool isAuthenticated = false,
    UserProfile? user,
    UserPreferences? preferences,
    bool isLoading = false,
  }) : _isAuthenticated = isAuthenticated,
       _user = user,
       _preferences = preferences ?? const UserPreferences(),
       _isLoading = isLoading;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  UserProfile? get user => _user;
  UserPreferences get preferences => _preferences;
  InterfaceMode get currentMode => _preferences.interfaceMode;

  bool get isMinor => _user?.isMinor ?? false;
  String get role => _user?.role ?? 'learner';

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setAuthenticated(UserProfile user, {UserPreferences? preferences}) {
    _isAuthenticated = true;
    _user = user;
    if (preferences != null) {
      _preferences = preferences;
    }
    _isLoading = false;
    notifyListeners();
  }

  void setUnauthenticated() {
    _isAuthenticated = false;
    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  void updatePreferences(UserPreferences newPreferences) {
    _preferences = newPreferences;
    notifyListeners();
  }

  void updateMode(InterfaceMode mode) {
    _preferences = _preferences.copyWith(interfaceMode: mode);
    notifyListeners();
  }
}
