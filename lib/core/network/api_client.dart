import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_endpoint_resolver.dart';
import 'api_response_decoder.dart';
import 'models/auth_tokens.dart';
import 'models/user_profile.dart';
import 'problem_details_exception.dart';
import 'session_coordinator.dart';
import 'token_refresh_coordinator.dart';
import 'token_storage.dart';

typedef LocaleProvider = String Function();
typedef UnauthenticatedCallback = void Function();

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final ApiEndpointResolver _endpoints;
  final ApiResponseDecoder _responseDecoder = const ApiResponseDecoder();
  final AuthTokenStorage tokenStorage;
  final LocaleProvider? localeProvider;
  final UnauthenticatedCallback? onUnauthenticated;

  final SessionCoordinator _session;
  Future<void>? _logoutBarrier;
  final TokenRefreshCoordinator _refreshCoordinator = TokenRefreshCoordinator();

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    required this.tokenStorage,
    this.localeProvider,
    this.onUnauthenticated,
  }) : _httpClient = httpClient ?? http.Client(),
       _endpoints = ApiEndpointResolver(baseUrl),
       _session = SessionCoordinator(tokenStorage);

  Map<String, String> _buildHeaders({String? token}) {
    final locale = localeProvider != null ? localeProvider!() : 'ar';
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Accept-Language': locale,
      'X-Client-Platform': 'flutter',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Register unified learner and store returned tokens.
  Future<AuthTokens> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? locale,
    String deviceName = 'flutter-mobile',
  }) {
    return _authenticate('/api/v1/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'locale': locale ?? (localeProvider?.call() ?? 'ar'),
      'device_name': deviceName,
    });
  }

  /// Authenticate with credentials and store returned tokens.
  Future<AuthTokens> login({
    required String email,
    required String password,
    String deviceName = 'flutter-mobile',
  }) {
    return _authenticate('/api/v1/auth/login', {
      'email': email,
      'password': password,
      'device_name': deviceName,
    });
  }

  Future<AuthTokens> _authenticate(
    String path,
    Map<String, dynamic> body,
  ) async {
    final generation = _session.beginTransition();
    _refreshCoordinator.invalidate();
    try {
      await _session.takeAndClear(generation);
      try {
        await _logoutBarrier;
      } catch (_) {
        // This transition has already cleared the local credentials safely.
      }
      final response = await _httpClient.post(
        _endpoints.resolve(path),
        headers: _buildHeaders(),
        body: jsonEncode(body),
      );
      final json = _responseDecoder.decode(response);
      final tokens = AuthTokens.fromJson(json['data'] as Map<String, dynamic>);
      await _session.saveTransition(generation, tokens);
      return tokens;
    } finally {
      _session.finishTransition(generation);
    }
  }

  /// Rotate refresh tokens once per active session generation.
  Future<AuthTokens> refresh({String deviceName = 'flutter-mobile'}) async {
    return _refreshForGeneration(_session.current, deviceName: deviceName);
  }

  Future<AuthTokens> _refreshForGeneration(
    int generation, {
    String deviceName = 'flutter-mobile',
  }) {
    _session.ensureCurrent(generation);
    return _refreshCoordinator.run(
      generation,
      () => _performRefresh(generation, deviceName: deviceName),
    );
  }

  Future<AuthTokens> _performRefresh(
    int generation, {
    required String deviceName,
  }) async {
    final currentTokens = await _session.read(generation);
    if (currentTokens == null || currentTokens.refreshToken.isEmpty) {
      await _expireSession(generation);
      throw const ProblemDetailsException(
        title: 'Unauthorized',
        status: 401,
        detail: 'No refresh token available.',
        code: 'UNAUTHORIZED',
      );
    }

    _session.ensureCurrent(generation);
    final response = await _httpClient.post(
      _endpoints.resolve('/api/v1/auth/refresh'),
      headers: _buildHeaders(),
      body: jsonEncode({
        'refresh_token': currentTokens.refreshToken,
        'device_name': deviceName,
      }),
    );
    _session.ensureCurrent(generation);

    if (response.statusCode == 401 || response.statusCode == 403) {
      await _expireSession(generation);
    }

    final AuthTokens newTokens;
    try {
      final json = _responseDecoder.decode(response);
      newTokens = AuthTokens.fromJson(json['data'] as Map<String, dynamic>);
    } on FormatException {
      throw const MalformedRefreshResponse();
    } on TypeError {
      throw const MalformedRefreshResponse();
    }

    await _session.saveRefreshed(generation, currentTokens, newTokens);
    return newTokens;
  }

  Future<void> _expireSession(int generation) async {
    _session.ensureCurrent(generation);
    final next = _session.beginTransition();
    _refreshCoordinator.invalidate();
    try {
      await _session.takeAndClear(next);
      _session.finishTransition(next);
      onUnauthenticated?.call();
    } finally {
      _session.finishTransition(next);
    }
  }

  /// Evict local credentials first, then revoke the captured remote session.
  Future<void> logout({bool allDevices = false}) {
    final generation = _session.beginTransition();
    _refreshCoordinator.invalidate();
    final capture = _session.takeForLogout(generation);
    final previous = _logoutBarrier;
    final revocation = _revokeCaptured(
      generation,
      capture,
      previous,
      allDevices,
    );
    _logoutBarrier = revocation;
    return revocation;
  }

  Future<void> _revokeCaptured(
    int generation,
    Future<AuthTokens?> capture,
    Future<void>? previous,
    bool allDevices,
  ) async {
    final AuthTokens? tokens;
    try {
      tokens = await capture;
    } finally {
      _session.finishTransition(generation);
    }
    // Earlier remote logout failures must not prevent a later retry.
    try {
      await previous;
    } catch (_) {}
    if (tokens == null) return;
    try {
      await _httpClient.post(
        _endpoints.resolve('/api/v1/auth/logout'),
        headers: _buildHeaders(token: tokens.accessToken),
        body: jsonEncode({'all_devices': allDevices}),
      );
    } catch (_) {
      // Local logout is already complete.
    }
  }

  /// Fetch authenticated user profile.
  Future<UserProfile> getProfile() async {
    final response = await get('/api/v1/auth/me');
    return UserProfile.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Perform authenticated GET request with automatic token refresh on 401.
  Future<Map<String, dynamic>> get(String path) async {
    return _sendWithAuth((token) {
      final uri = _endpoints.resolve(path);
      return _httpClient.get(uri, headers: _buildHeaders(token: token));
    });
  }

  /// Perform authenticated POST request with automatic token refresh on 401.
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _sendWithAuth((token) {
      final uri = _endpoints.resolve(path);
      return _httpClient.post(
        uri,
        headers: _buildHeaders(token: token),
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  /// Perform authenticated PUT request with automatic token refresh on 401.
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _sendWithAuth((token) {
      final uri = _endpoints.resolve(path);
      return _httpClient.put(
        uri,
        headers: _buildHeaders(token: token),
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  /// Perform authenticated DELETE request with automatic token refresh on 401.
  Future<Map<String, dynamic>> delete(String path) async {
    return _sendWithAuth((token) {
      final uri = _endpoints.resolve(path);
      return _httpClient.delete(uri, headers: _buildHeaders(token: token));
    });
  }

  int captureSessionGeneration() => _session.current;

  /// Perform generic authenticated HTTP request (GET, POST, PUT, PATCH, DELETE)
  /// with optional custom headers and automatic token refresh on 401.
  Future<Map<String, dynamic>> request({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    int? expectedSessionGeneration,
  }) async {
    Future<http.Response> execute(String? token) {
      final uri = _endpoints.resolve(path);
      final combinedHeaders = _buildHeaders(token: token);
      if (headers != null) {
        combinedHeaders.addAll(headers);
      }
      final encodedBody = body != null ? jsonEncode(body) : null;
      switch (method.toUpperCase()) {
        case 'GET':
          return _httpClient.get(uri, headers: combinedHeaders);
        case 'POST':
          return _httpClient.post(
            uri,
            headers: combinedHeaders,
            body: encodedBody,
          );
        case 'PUT':
          return _httpClient.put(
            uri,
            headers: combinedHeaders,
            body: encodedBody,
          );
        case 'PATCH':
          return _httpClient.patch(
            uri,
            headers: combinedHeaders,
            body: encodedBody,
          );
        case 'DELETE':
          return _httpClient.delete(
            uri,
            headers: combinedHeaders,
            body: encodedBody,
          );
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
    }

    return _sendWithAuth(
      execute,
      expectedGeneration: expectedSessionGeneration,
    );
  }

  /// Retry a rejected request only within the session that dispatched it.
  Future<Map<String, dynamic>> _sendWithAuth(
    Future<http.Response> Function(String? token) executeRequest, {
    int? expectedGeneration,
  }) async {
    final generation = expectedGeneration ?? _session.current;
    final initialTokens = await _session.read(generation);
    final usedToken = initialTokens?.accessToken;
    _session.ensureCurrent(generation);
    var response = await _dispatch(generation, executeRequest, usedToken);
    _checkResponseSession(generation, response);

    if (response.statusCode == 401 && initialTokens != null) {
      final currentTokens = await _session.read(generation);
      if (currentTokens == null) throw const SessionChangedException();
      final retryToken = currentTokens.accessToken != usedToken
          ? currentTokens.accessToken
          : (await _refreshForGeneration(generation)).accessToken;
      _session.ensureCurrent(generation);
      response = await _dispatch(generation, executeRequest, retryToken);
      _checkResponseSession(generation, response);
    }

    return _responseDecoder.decode(response);
  }

  Future<http.Response> _dispatch(
    int generation,
    Future<http.Response> Function(String? token) executeRequest,
    String? token,
  ) async {
    _session.ensureCurrent(generation);
    final pending = executeRequest(token);
    try {
      return await pending;
    } catch (_) {
      _session.ensureCurrent(generation, requestMayHaveSucceeded: true);
      rethrow;
    }
  }

  void _checkResponseSession(int generation, http.Response response) {
    try {
      _session.ensureCurrent(
        generation,
        requestMayHaveSucceeded:
            response.statusCode >= 200 && response.statusCode < 300,
      );
    } on SessionChangedException {
      if (response.statusCode == 409) {
        try {
          _responseDecoder.decode(response);
        } on ProblemDetailsException catch (error) {
          throw SessionChangedException(conflictDetails: error.extensions);
        }
        throw const SessionChangedException(conflictDetails: {});
      }
      rethrow;
    }
  }
}
