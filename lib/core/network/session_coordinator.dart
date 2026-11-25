import 'models/auth_tokens.dart';
import 'token_storage.dart';

class SessionChangedException implements Exception {
  const SessionChangedException({this.requestMayHaveSucceeded = false});

  final bool requestMayHaveSucceeded;

  @override
  String toString() => 'Authentication session changed.';
}

/// Owns credential storage transitions for one application API client.
class SessionCoordinator {
  SessionCoordinator(this._storage);

  final AuthTokenStorage _storage;
  int _generation = 0;
  bool _transitioning = false;
  Future<void> _tail = Future<void>.value();

  int get current {
    ensureCurrent(_generation);
    return _generation;
  }

  int beginTransition() {
    _transitioning = true;
    return ++_generation;
  }

  void finishTransition(int generation) {
    if (generation == _generation) _transitioning = false;
  }

  void ensureCurrent(int generation, {bool requestMayHaveSucceeded = false}) {
    if (_generation != generation || _transitioning) {
      throw SessionChangedException(
        requestMayHaveSucceeded: requestMayHaveSucceeded,
      );
    }
  }

  void _ensureTransition(int generation) {
    if (_generation != generation || !_transitioning) {
      throw const SessionChangedException();
    }
  }

  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = _tail.then((_) => operation());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<AuthTokens?> read(int generation) => _serialize(() async {
    ensureCurrent(generation);
    final tokens = await _storage.getTokens();
    ensureCurrent(generation);
    return tokens;
  });

  Future<AuthTokens?> takeAndClear(int generation) => _serialize(() async {
    _ensureTransition(generation);
    final tokens = await _storage.getTokens();
    _ensureTransition(generation);
    await _storage.clearTokens();
    _ensureTransition(generation);
    return tokens;
  });

  Future<void> saveTransition(int generation, AuthTokens tokens) {
    return _serialize(() async {
      _ensureTransition(generation);
      await _storage.saveTokens(tokens);
      _ensureTransition(generation);
    });
  }

  Future<void> saveRefreshed(
    int generation,
    AuthTokens previous,
    AuthTokens tokens,
  ) => _serialize(() async {
    ensureCurrent(generation);
    final current = await _storage.getTokens();
    ensureCurrent(generation);
    if (current != previous) throw const SessionChangedException();
    await _storage.saveTokens(tokens);
    ensureCurrent(generation);
  });
}
