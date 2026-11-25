import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/environment.dart';
import 'package:usayd_flutter/core/config/flavor_config.dart';

void main() {
  test('dev uses Android emulator host', () {
    configureEnvironment(AppFlavor.dev, platform: TargetPlatform.android);
    final url = FlavorConfig.instance.apiBaseUrl;
    expect(url, 'http://10.0.2.2:8000/api/v1');
  });

  test('dev uses iOS simulator host', () {
    configureEnvironment(AppFlavor.dev, platform: TargetPlatform.iOS);
    final url = FlavorConfig.instance.apiBaseUrl;
    expect(url, 'http://127.0.0.1:8000/api/v1');
  });

  test('dev override does not affect staging or prod', () {
    const local = 'http://localhost:8000/api/v1';
    configureEnvironment(
      AppFlavor.staging,
      platform: TargetPlatform.android,
      devApiBaseUrl: local,
    );
    final staging = FlavorConfig.instance.apiBaseUrl;
    expect(staging, 'https://staging-api.usayd.academy/api/v1');
    configureEnvironment(
      AppFlavor.prod,
      platform: TargetPlatform.android,
      devApiBaseUrl: local,
    );
    final prod = FlavorConfig.instance.apiBaseUrl;
    expect(prod, 'https://api.usayd.academy/api/v1');
    expect(FlavorConfig.instance.enableLogging, isFalse);
  });

  test('native flavor controls the default entrypoint', () {
    for (final flavor in AppFlavor.values) {
      final name = flavor.name;
      final actual = resolveEnvironment(nativeFlavor: name, release: true);
      expect(actual, flavor);
    }
  });

  test('rejects mismatched native and Dart flavors', () {
    void mismatch() {
      resolveEnvironment(
        nativeFlavor: 'prod',
        requested: AppFlavor.dev,
        release: true,
      );
    }

    expect(mismatch, throwsStateError);
  });

  test('release requires a native flavor', () {
    void missing() {
      resolveEnvironment(nativeFlavor: null, release: true);
    }

    expect(missing, throwsStateError);
  });
}
