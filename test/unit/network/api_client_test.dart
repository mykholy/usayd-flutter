import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:usayd_flutter/core/network/api_client.dart';
import 'package:usayd_flutter/core/network/models/auth_tokens.dart';
import 'package:usayd_flutter/core/network/problem_details_exception.dart';
import 'package:usayd_flutter/core/network/token_storage.dart';

void main() {
  group('ApiClient', () {
    late InMemoryAuthTokenStorage tokenStorage;

    setUp(() {
      tokenStorage = InMemoryAuthTokenStorage();
    });

    test('login sends credentials and stores returned tokens', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/login');
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'student@usayd.academy');
        expect(body['password'], 'secret123');

        return http.Response(
          jsonEncode({
            'data': {
              'access_token': 'new-access-token',
              'expires_in': 3600,
              'refresh_token': 'new-refresh-token',
              'token_type': 'Bearer',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.usayd.academy',
        httpClient: mockClient,
        tokenStorage: tokenStorage,
      );

      final tokens = await apiClient.login(
        email: 'student@usayd.academy',
        password: 'secret123',
      );

      expect(tokens.accessToken, 'new-access-token');
      expect(tokens.refreshToken, 'new-refresh-token');

      // Assert tokens were persisted in storage
      final stored = await tokenStorage.getTokens();
      expect(stored, isNotNull);
      expect(stored!.accessToken, 'new-access-token');
    });

    test('register creates unified learner and stores tokens', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/auth/register');
        return http.Response(
          jsonEncode({
            'data': {
              'access_token': 'reg-access',
              'expires_in': 3600,
              'refresh_token': 'reg-refresh',
              'token_type': 'Bearer',
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.usayd.academy',
        httpClient: mockClient,
        tokenStorage: tokenStorage,
      );

      final tokens = await apiClient.register(
        name: 'أُسَيْد',
        email: 'new@usayd.academy',
        password: 'Password123!',
      );

      expect(tokens.accessToken, 'reg-access');
      expect(await tokenStorage.hasAccessToken(), isTrue);
    });

    test(
      'automatic 401 interceptor rotates token and retries request',
      () async {
        var profileCallCount = 0;
        var refreshCalled = false;

        await tokenStorage.saveTokens(
          const AuthTokens(
            accessToken: 'stale-access-token',
            expiresIn: 3600,
            refreshToken: 'valid-refresh-token',
          ),
        );

        final mockClient = MockClient((request) async {
          if (request.url.path == '/api/v1/auth/refresh') {
            refreshCalled = true;
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body['refresh_token'], 'valid-refresh-token');

            return http.Response(
              jsonEncode({
                'data': {
                  'access_token': 'fresh-access-token',
                  'expires_in': 3600,
                  'refresh_token': 'rotated-refresh-token',
                  'token_type': 'Bearer',
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }

          if (request.url.path == '/api/v1/auth/me') {
            profileCallCount++;
            if (profileCallCount == 1) {
              // First attempt with stale token receives 401
              expect(
                request.headers['authorization'],
                'Bearer stale-access-token',
              );
              return http.Response(
                jsonEncode({
                  'title': 'Unauthorized',
                  'status': 401,
                  'detail': 'Token expired.',
                  'code': 'UNAUTHORIZED',
                }),
                401,
                headers: {'content-type': 'application/problem+json'},
              );
            } else {
              // Second attempt after refresh receives 200 with new token
              expect(
                request.headers['authorization'],
                'Bearer fresh-access-token',
              );
              return http.Response(
                jsonEncode({
                  'data': {
                    'id': 42,
                    'name': 'Usayd Learner',
                    'email': 'learner@usayd.academy',
                    'locale': 'ar',
                    'country': 'EG',
                    'timezone': 'Africa/Cairo',
                    'status': 'active',
                  },
                }),
                200,
                headers: {'content-type': 'application/json'},
              );
            }
          }

          return http.Response('Not Found', 404);
        });

        final apiClient = ApiClient(
          baseUrl: 'https://api.usayd.academy',
          httpClient: mockClient,
          tokenStorage: tokenStorage,
        );

        final profile = await apiClient.getProfile();

        expect(profile.id, 42);
        expect(profile.name, 'Usayd Learner');
        expect(profileCallCount, 2);
        expect(refreshCalled, isTrue);

        // Verify that storage was updated with rotated tokens
        final updatedTokens = await tokenStorage.getTokens();
        expect(updatedTokens!.accessToken, 'fresh-access-token');
        expect(updatedTokens.refreshToken, 'rotated-refresh-token');
      },
    );

    test(
      'when refresh fails with 401, clears tokens and fires onUnauthenticated',
      () async {
        var unauthenticatedFired = false;

        await tokenStorage.saveTokens(
          const AuthTokens(
            accessToken: 'expired-access',
            expiresIn: 3600,
            refreshToken: 'expired-refresh',
          ),
        );

        final mockClient = MockClient((request) async {
          if (request.url.path == '/api/v1/auth/refresh') {
            return http.Response(
              jsonEncode({
                'title': 'Unauthorized',
                'status': 401,
                'detail': 'Refresh token has expired.',
                'code': 'UNAUTHORIZED',
              }),
              401,
              headers: {'content-type': 'application/problem+json'},
            );
          }

          return http.Response(
            jsonEncode({
              'title': 'Unauthorized',
              'status': 401,
              'detail': 'Token expired.',
              'code': 'UNAUTHORIZED',
            }),
            401,
            headers: {'content-type': 'application/problem+json'},
          );
        });

        final apiClient = ApiClient(
          baseUrl: 'https://api.usayd.academy',
          httpClient: mockClient,
          tokenStorage: tokenStorage,
          onUnauthenticated: () {
            unauthenticatedFired = true;
          },
        );

        await expectLater(
          () => apiClient.getProfile(),
          throwsA(isA<ProblemDetailsException>()),
        );

        // Assert local storage was purged
        expect(await tokenStorage.getTokens(), isNull);
        expect(unauthenticatedFired, isTrue);
      },
    );

    test('logout revokes tokens on server and purges storage', () async {
      var logoutCalled = false;
      await tokenStorage.saveTokens(
        const AuthTokens(
          accessToken: 'active-token',
          expiresIn: 3600,
          refreshToken: 'active-refresh',
        ),
      );

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/auth/logout') {
          logoutCalled = true;
          expect(request.headers['authorization'], 'Bearer active-token');
          return http.Response(jsonEncode({'status': 'success'}), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.usayd.academy',
        httpClient: mockClient,
        tokenStorage: tokenStorage,
      );

      await apiClient.logout();

      expect(logoutCalled, isTrue);
      expect(await tokenStorage.getTokens(), isNull);
    });

    test('throws ProblemDetailsException on validation error 422', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'title': 'Validation Failed',
            'status': 422,
            'detail': 'Email already registered.',
            'code': 'VALIDATION_FAILED',
            'invalidParams': {
              'email': ['The email has already been taken.'],
            },
          }),
          422,
          headers: {'content-type': 'application/problem+json'},
        );
      });

      final apiClient = ApiClient(
        baseUrl: 'https://api.usayd.academy',
        httpClient: mockClient,
        tokenStorage: tokenStorage,
      );

      try {
        await apiClient.register(
          name: 'Test',
          email: 'duplicate@usayd.academy',
          password: 'pass',
        );
        fail('Expected ProblemDetailsException was not thrown');
      } on ProblemDetailsException catch (e) {
        expect(e.status, 422);
        expect(e.code, 'VALIDATION_FAILED');
        expect(
          e.invalidParams['email'],
          contains('The email has already been taken.'),
        );
      }
    });
  });
}
