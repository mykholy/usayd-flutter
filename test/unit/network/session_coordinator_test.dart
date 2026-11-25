import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:usayd_flutter/core/network/api_client.dart';
import 'package:usayd_flutter/core/network/models/auth_tokens.dart';
import 'package:usayd_flutter/core/network/session_coordinator.dart';
import 'package:usayd_flutter/core/network/token_storage.dart';

const _old = AuthTokens(
  accessToken: 'old-access',
  refreshToken: 'old-refresh',
  expiresIn: 3600,
);
const _new = AuthTokens(
  accessToken: 'new-access',
  refreshToken: 'new-refresh',
  expiresIn: 3600,
);

http.Response _tokens(AuthTokens tokens) {
  return http.Response(jsonEncode({'data': tokens.toJson()}), 200);
}

void main() {
  test('late refresh cannot overwrite a newer login', () async {
    final storage = InMemoryAuthTokenStorage();
    await storage.saveTokens(_old);
    final started = Completer<void>();
    final reply = Completer<http.Response>();
    final api = ApiClient(
      baseUrl: 'https://api.usayd.academy',
      tokenStorage: storage,
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/refresh')) {
          started.complete();
          return reply.future;
        }
        return _tokens(_new);
      }),
    );
    final refresh = expectLater(
      api.refresh(),
      throwsA(isA<SessionChangedException>()),
    );
    await started.future;
    await api.login(email: 'new@example.invalid', password: 'fixture');
    reply.complete(_tokens(_old));
    await refresh;
    expect(await storage.getTokens(), _new);
  });

  test('late 401 does not replay under the new user', () async {
    final storage = InMemoryAuthTokenStorage();
    await storage.saveTokens(_old);
    final started = Completer<void>();
    final reply = Completer<http.Response>();
    var calls = 0;
    final api = ApiClient(
      baseUrl: 'https://api.usayd.academy',
      tokenStorage: storage,
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/login')) return _tokens(_new);
        calls++;
        if (calls == 1) {
          started.complete();
          return reply.future;
        }
        return http.Response('{}', 200);
      }),
    );
    final pending = expectLater(
      api.post('/api/v1/notes'),
      throwsA(isA<SessionChangedException>()),
    );
    await started.future;
    await api.login(email: 'new@example.invalid', password: 'fixture');
    reply.complete(http.Response('{"status":401}', 401));
    await pending;
    expect(calls, 1);
    expect(await storage.getTokens(), _new);
  });

  test('late successful request is flagged as possibly committed', () async {
    final storage = InMemoryAuthTokenStorage();
    await storage.saveTokens(_old);
    final started = Completer<void>();
    final reply = Completer<http.Response>();
    final api = ApiClient(
      baseUrl: 'https://api.usayd.academy',
      tokenStorage: storage,
      httpClient: MockClient((request) async {
        if (request.url.path.endsWith('/logout')) {
          return http.Response('{}', 200);
        }
        started.complete();
        return reply.future;
      }),
    );
    final pending = expectLater(
      api.post('/api/v1/notes'),
      throwsA(
        isA<SessionChangedException>().having(
          (error) => error.requestMayHaveSucceeded,
          'requestMayHaveSucceeded',
          isTrue,
        ),
      ),
    );
    await started.future;
    await api.logout();
    reply.complete(http.Response('{}', 200));
    await pending;
    expect(await storage.getTokens(), isNull);
  });
}
