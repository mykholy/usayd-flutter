import 'models/auth_tokens.dart';

/// Shares refresh work only among requests belonging to the same session.
class TokenRefreshCoordinator {
  int? _generation;
  Future<AuthTokens>? _inFlight;

  Future<AuthTokens> run(
    int generation,
    Future<AuthTokens> Function() operation,
  ) {
    final existing = _inFlight;
    if (_generation == generation && existing != null) return existing;

    late final Future<AuthTokens> flight;
    flight = Future<AuthTokens>.sync(operation).whenComplete(() {
      if (identical(_inFlight, flight)) invalidate();
    });
    _generation = generation;
    _inFlight = flight;
    return flight;
  }

  void invalidate() {
    _generation = null;
    _inFlight = null;
  }
}
