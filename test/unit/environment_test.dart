import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usayd_flutter/core/config/environment.dart';
import 'package:usayd_flutter/core/config/flavor_config.dart';

void main() {
  test('development uses the correct simulator host', () {
    configureEnvironment(AppFlavor.dev, platform: TargetPlatform.android);
    expect(FlavorConfig.instance.apiBaseUrl, 'http://10.0.2.2:8000/api/v1');
    configureEnvironment(AppFlavor.dev, platform: TargetPlatform.iOS);
    expect(FlavorConfig.instance.apiBaseUrl, 'http://127.0.0.1:8000/api/v1');
  });

  test('development override cannot change production or staging', () {
    configureEnvironment(
      AppFlavor.staging,
      platform: TargetPlatform.android,
      devApiBaseUrl: 'http://localhost:8000/api/v1',
    );
    expect(
      FlavorConfig.instance.apiBaseUrl,
      'https://staging-api.usayd.academy/api/v1',
    );
    configureEnvironment(
      AppFlavor.prod,
      platform: TargetPlatform.android,
      devApiBaseUrl: 'http://localhost:8000/api/v1',
    );
    expect(FlavorConfig.instance.apiBaseUrl, 'https://api.usayd.academy/api/v1');
    expect(FlavorConfig.instance.enableLogging, isFalse);
  });

  test('native flavor controls default entrypoint', () {
    for (final flavor in AppFlavor.values) {
      expect(
        resolveEnvironment(nativeFlavor: flavor.name, release: true),
        flavor,
      );
    }
  });

  test('rejects a mismatched entrypoint and missing release flavor', () {
    expect(
      () => resolveEnvironment(
        nativeFlavor: 'prod',
        requested: AppFlavor.dev,
        release: true,
      ),
      throwsStateError,
    );
    expect(
      () => resolveEnvironment(nativeFlavor: null, release: true),
      throwsStateError,
    );
  });
}
