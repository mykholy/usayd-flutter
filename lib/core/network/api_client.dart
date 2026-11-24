import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/auth_tokens.dart';
import 'models/user_profile.dart';
import 'problem_details_exception.dart';
import 'token_storage.dart';

typedef LocaleProvider = String Function();
typedef UnauthenticatedCallback = void Function();

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final AuthTokenStorage tokenStorage;
  final LocaleProvider? localeProvider;
  final UnauthenticatedCallback? onUnauthenticated;

  bool _isRefreshing = false;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    required this.tokenStorage,
    this.localeProvider,
    this.onUnauthenticated,
  }) : _httpClient = httpClient ?? http.Client();

  String get _normalizedBaseUrl => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

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
  }) async {
    final uri = Uri.parse('$_normalizedBaseUrl/api/v1/auth/register');
    final response = await _httpClient.post(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'locale': locale ?? (localeProvider?.call() ?? 'ar'),
        'device_name': deviceName,
      }),
    );

    final json = _handleResponse(response);
    final tokens = AuthTokens.fromJson(json['data'] as Map<String, dynamic>);
    await tokenStorage.saveTokens(tokens);
    return tokens;
  }

  /// Authenticate with credentials and store returned tokens.
  Future<AuthTokens> login({
    required String email,
    required String password,
    String deviceName = 'flutter-mobile',
  }) async {
    final uri = Uri.parse('$_normalizedBaseUrl/api/v1/auth/login');
    final response = await _httpClient.post(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_name': deviceName,
      }),
    );

    final json = _handleResponse(response);
    final tokens = AuthTokens.fromJson(json['data'] as Map<String, dynamic>);
    await tokenStorage.saveTokens(tokens);
    return tokens;
  }

  /// Rotate refresh token and persist new token pair.
  Future<AuthTokens> refresh({String deviceName = 'flutter-mobile'}) async {
    final currentTokens = await tokenStorage.getTokens();
    if (currentTokens == null || currentTokens.refreshToken.isEmpty) {
      await tokenStorage.clearTokens();
      onUnauthenticated?.call();
      throw const ProblemDetailsException(
        title: 'Unauthorized',
        status: 401,
        detail: 'No refresh token available.',
        code: 'UNAUTHORIZED',
      );
    }

    final uri = Uri.parse('$_normalizedBaseUrl/api/v1/auth/refresh');
    final response = await _httpClient.post(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode({
        'refresh_token': currentTokens.refreshToken,
        'device_name': deviceName,
      }),
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      await tokenStorage.clearTokens();
      onUnauthenticated?.call();
    }

    final json = _handleResponse(response);
    final newTokens = AuthTokens.fromJson(json['data'] as Map<String, dynamic>);
    await tokenStorage.saveTokens(newTokens);
    return newTokens;
  }

  /// Log out and revoke active tokens.
  Future<void> logout({bool allDevices = false}) async {
    final tokens = await tokenStorage.getTokens();
    if (tokens != null) {
      try {
        final uri = Uri.parse('$_normalizedBaseUrl/api/v1/auth/logout');
        await _httpClient.post(
          uri,
          headers: _buildHeaders(token: tokens.accessToken),
          body: jsonEncode({'all_devices': allDevices}),
        );
      } catch (_) {
        // Suppress network errors during logout; local token eviction must proceed.
      }
    }
    await tokenStorage.clearTokens();
  }

  /// Fetch authenticated user profile.
  Future<UserProfile> getProfile() async {
    final response = await get('/api/v1/auth/me');
    return UserProfile.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Perform authenticated GET request with automatic token refresh on 401.
  Future<Map<String, dynamic>> get(String path) async {
    return _sendWithAuth((token) {
      final uri = Uri.parse('$_normalizedBaseUrl$path');
      return _httpClient.get(uri, headers: _buildHeaders(token: token));
    });
  }

  /// Perform authenticated POST request with automatic token refresh on 401.
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _sendWithAuth((token) {
      final uri = Uri.parse('$_normalizedBaseUrl$path');
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
      final uri = Uri.parse('$_normalizedBaseUrl$path');
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
      final uri = Uri.parse('$_normalizedBaseUrl$path');
      return _httpClient.delete(uri, headers: _buildHeaders(token: token));
    });
  }

  /// Internal request execution wrapper providing single-attempt 401 token refresh retry.
  Future<Map<String, dynamic>> _sendWithAuth(
    Future<http.Response> Function(String? token) executeRequest,
  ) async {
    final tokens = await tokenStorage.getTokens();
    var response = await executeRequest(tokens?.accessToken);

    // If 401 encountered and we have a refresh token and not currently refreshing:
    if (response.statusCode == 401 && tokens != null && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final newTokens = await refresh();
        _isRefreshing = false;
        // Retry the original request with the freshly minted access token
        response = await executeRequest(newTokens.accessToken);
      } catch (e) {
        _isRefreshing = false;
        await tokenStorage.clearTokens();
        onUnauthenticated?.call();
        rethrow;
      }
    }

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return <String, dynamic>{};
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }

    // Parse RFC 7807 problem details or fallback
    Map<String, dynamic> errorJson = {};
    try {
      errorJson = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      errorJson = {
        'title': 'HTTP ${response.statusCode}',
        'detail': response.body.isNotEmpty ? response.body : 'Request failed.',
        'status': response.statusCode,
        'code': 'HTTP_${response.statusCode}',
      };
    }

    throw ProblemDetailsException.fromJson(
      errorJson,
      fallbackStatus: response.statusCode,
    );
  }
}
