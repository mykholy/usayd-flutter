import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/flavor_config.dart';

void main() {
  group('FlavorConfig Unit Tests', () {
    test('Dev flavor initializes with dev bundle ID and base URL', () {
      FlavorConfig.init(
        flavor: AppFlavor.dev,
        name: 'Usayd Dev',
        apiBaseUrl: 'http://10.0.2.2:8000/api/v1',
        appIdentifier: 'academy.usayd.learner.dev',
        enableLogging: true,
      );

      expect(FlavorConfig.isDev, isTrue);
      expect(FlavorConfig.isStaging, isFalse);
      expect(FlavorConfig.isProd, isFalse);
      expect(
        FlavorConfig.instance.appIdentifier,
        equals('academy.usayd.learner.dev'),
      );
      expect(
        FlavorConfig.instance.apiBaseUrl,
        equals('http://10.0.2.2:8000/api/v1'),
      );
      expect(FlavorConfig.instance.name, equals('Usayd Dev'));
    });

    test('Staging flavor initializes with staging bundle ID and base URL', () {
      FlavorConfig.init(
        flavor: AppFlavor.staging,
        name: 'Usayd Staging',
        apiBaseUrl: 'https://staging-api.usayd.academy/api/v1',
        appIdentifier: 'academy.usayd.learner.stg',
        enableLogging: true,
      );

      expect(FlavorConfig.isDev, isFalse);
      expect(FlavorConfig.isStaging, isTrue);
      expect(FlavorConfig.isProd, isFalse);
      expect(
        FlavorConfig.instance.appIdentifier,
        equals('academy.usayd.learner.stg'),
      );
      expect(
        FlavorConfig.instance.apiBaseUrl,
        equals('https://staging-api.usayd.academy/api/v1'),
      );
    });

    test('Prod flavor initializes with production bundle ID and base URL', () {
      FlavorConfig.init(
        flavor: AppFlavor.prod,
        name: 'أكاديمية أُسَيْد',
        apiBaseUrl: 'https://api.usayd.academy/api/v1',
        appIdentifier: 'academy.usayd.learner',
        enableLogging: false,
      );

      expect(FlavorConfig.isDev, isFalse);
      expect(FlavorConfig.isStaging, isFalse);
      expect(FlavorConfig.isProd, isTrue);
      expect(
        FlavorConfig.instance.appIdentifier,
        equals('academy.usayd.learner'),
      );
      expect(
        FlavorConfig.instance.apiBaseUrl,
        equals('https://api.usayd.academy/api/v1'),
      );
    });

    test('Prod flavor rejects insecure HTTP URL', () {
      expect(
        () => FlavorConfig.init(
          flavor: AppFlavor.prod,
          name: 'أكاديمية أُسَيْد',
          apiBaseUrl: 'http://api.usayd.academy/api/v1',
          appIdentifier: 'academy.usayd.learner',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Prod flavor rejects localhost, staging, or test endpoints', () {
      expect(
        () => FlavorConfig.init(
          flavor: AppFlavor.prod,
          name: 'أكاديمية أُسَيْد',
          apiBaseUrl: 'https://staging-api.usayd.academy/api/v1',
          appIdentifier: 'academy.usayd.learner',
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => FlavorConfig.init(
          flavor: AppFlavor.prod,
          name: 'أكاديمية أُسَيْد',
          apiBaseUrl: 'https://localhost:8000/api/v1',
          appIdentifier: 'academy.usayd.learner',
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => FlavorConfig.init(
          flavor: AppFlavor.prod,
          name: 'أكاديمية أُسَيْد',
          apiBaseUrl: 'https://10.0.2.2:8000/api/v1',
          appIdentifier: 'academy.usayd.learner',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
