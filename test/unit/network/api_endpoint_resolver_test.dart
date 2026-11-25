import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/network/api_endpoint_resolver.dart';

void main() {
  group('ApiEndpointResolver', () {
    test('supports host-only and versioned base URLs', () {
      const bases = [
        'https://api.usayd.academy',
        'https://api.usayd.academy/',
        'https://api.usayd.academy/api/v1',
        'https://api.usayd.academy/api/v1/',
      ];
      for (final base in bases) {
        expect(
          ApiEndpointResolver(base).resolve('/api/v1/auth/login').toString(),
          'https://api.usayd.academy/api/v1/auth/login',
        );
      }
    });

    test('preserves query parameters', () {
      const resolver = ApiEndpointResolver('https://api.usayd.academy/api/v1');
      final uri = resolver.resolve('/api/v1/lessons?page=2');
      expect(uri.path, '/api/v1/lessons');
      expect(uri.queryParameters, {'page': '2'});
    });

    test('preserves queries on the version root', () {
      const resolver = ApiEndpointResolver('https://api.usayd.academy/api/v1');
      expect(
        resolver.resolve('/api/v1?page=2#section').toString(),
        'https://api.usayd.academy/api/v1?page=2#section',
      );
    });

    test('supports relative API paths with a versioned base', () {
      const resolver = ApiEndpointResolver('https://api.usayd.academy/api/v1');
      expect(resolver.resolve('/auth/me').path, '/api/v1/auth/me');
    });
  });
}
