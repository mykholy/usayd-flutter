import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_endpoint_resolver.dart';
import 'api_response_decoder.dart';
import 'models/auth_tokens.dart';
import 'models/user_profile.dart';
import 'problem_details_exception.dart';
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

  Future<AuthTokens>? _refreshFuture;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    required this.tokenStorage,
    this.localeProvider,
    this.onUnauthenticated,
  }) : _httpClient = httpClient ?? http.Client(),
       _endpoints = ApiEndpointResolver(baseUrl);

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
    final uri = _endpoints.resolve('/api/v1/auth/register');
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

    final json = _responseDecoder.decode(response);
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
    final uri = _endpoints.resolve('/api/v1/auth/login');
    final response = await _httpClient.post(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_name': deviceName,
      }),
    );

    final json = _responseDecoder.decode(response);
    final tokens = AuthTokens.fromJson(json['data'] as Map<String, dynamic>);
    await tokenStorage.saveTokens(tokens);
    return tokens;
  }

  /// Rotate refresh token and persist new token pair.
  /// Deduplicates concurrent callers to a single in-flight Future.
  Future<AuthTokens> refresh({String deviceName = 'flutter-mobile'}) async {
    final existingFuture = _refreshFuture;
    if (existingFuture != null) {
      return existingFuture;
    }

    final future = _performRefresh(deviceName: deviceName);
    _refreshFuture = future;
    try {
      return await future;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<AuthTokens> _performRefresh({required String deviceName}) async {
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

    final uri = _endpoints.resolve('/api/v1/auth/refresh');
    final http.Response response;
    try {
      response = await _httpClient.post(
        uri,
        headers: _buildHeaders(),
        body: jsonEncode({
          'refresh_token': currentTokens.refreshToken,
          'device_name': deviceName,
        }),
      );
    } catch (_) {
      // Network or socket failure: transient error, do NOT wipe tokens
      rethrow;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      // Explicit authentication rejection: refresh token is expired, revoked, or invalid
      await tokenStorage.clearTokens();
      onUnauthenticated?.call();
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

    // Guard against logout race: if storage was cleared while request was in flight, do not overwrite
    final checkTokens = await tokenStorage.getTokens();
    if (checkTokens != null) {
      await tokenStorage.saveTokens(newTokens);
    }

    return newTokens;
  }

  /// Log out and revoke active tokens.
  Future<void> logout({bool allDevices = false}) async {
    _refreshFuture = null;
    final tokens = await tokenStorage.getTokens();
    if (tokens != null) {
      try {
        final uri = _endpoints.resolve('/api/v1/auth/logout');
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

  /// Perform generic authenticated HTTP request (GET, POST, PUT, PATCH, DELETE)
  /// with optional custom headers and automatic token refresh on 401.
  Future<Map<String, dynamic>> request({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _sendWithAuth((token) {
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
    });
  }

  /// Internal request execution wrapper providing single-attempt 401 token refresh retry.
  Future<Map<String, dynamic>> _sendWithAuth(
    Future<http.Response> Function(String? token) executeRequest,
  ) async {
    final initialTokens = await tokenStorage.getTokens();
    final usedToken = initialTokens?.accessToken;
    var response = await executeRequest(usedToken);

    // If 401 encountered and we have a valid initial token:
    if (response.statusCode == 401 && initialTokens != null) {
      // 1. Detect if another concurrent request already rotated the token in storage:
      final currentTokens = await tokenStorage.getTokens();
      if (currentTokens != null && currentTokens.accessToken != usedToken) {
        // Token was already rotated while this request was in-flight!
        // Retry immediately using the newly rotated access token without re-refreshing.
        response = await executeRequest(currentTokens.accessToken);
        return _responseDecoder.decode(response);
      }

      // 2. Share a single in-flight refresh Future across all concurrent callers:
      try {
        final newTokens = await refresh();
        // Retry the original request with the freshly minted access token
        response = await executeRequest(newTokens.accessToken);
      } on ProblemDetailsException {
        // Explicit 401/403 failure handled inside _performRefresh()
        rethrow;
      } catch (_) {
        // Transient network error during refresh: do NOT clear valid tokens
        rethrow;
      }
    }

    return _responseDecoder.decode(response);
  }
}
