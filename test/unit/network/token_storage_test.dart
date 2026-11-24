import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/network/models/auth_tokens.dart';
import 'package:usayd_flutter/core/network/token_storage.dart';

void main() {
  group('InMemoryAuthTokenStorage', () {
    late InMemoryAuthTokenStorage storage;

    setUp(() {
      storage = InMemoryAuthTokenStorage();
    });

    test('initially returns null and hasAccessToken is false', () async {
      expect(await storage.getTokens(), isNull);
      expect(await storage.hasAccessToken(), isFalse);
    });

    test('saves tokens and retrieves them accurately', () async {
      const tokens = AuthTokens(
        accessToken: 'access-123',
        expiresIn: 3600,
        refreshToken: 'refresh-456',
        tokenType: 'Bearer',
      );

      await storage.saveTokens(tokens);

      expect(await storage.hasAccessToken(), isTrue);
      final retrieved = await storage.getTokens();
      expect(retrieved, isNotNull);
      expect(retrieved!.accessToken, 'access-123');
      expect(retrieved.refreshToken, 'refresh-456');
      expect(retrieved.expiresIn, 3600);
      expect(retrieved.tokenType, 'Bearer');
    });

    test('clears tokens successfully', () async {
      const tokens = AuthTokens(
        accessToken: 'access-999',
        expiresIn: 1800,
        refreshToken: 'refresh-999',
      );

      await storage.saveTokens(tokens);
      expect(await storage.hasAccessToken(), isTrue);

      await storage.clearTokens();
      expect(await storage.hasAccessToken(), isFalse);
      expect(await storage.getTokens(), isNull);
    });
  });
}
