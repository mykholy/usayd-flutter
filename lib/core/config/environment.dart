import 'package:flutter/foundation.dart';

import 'flavor_config.dart';

/// Build-time environment mapping shared by all entrypoints.
void configureEnvironment(
  AppFlavor flavor, {
  required TargetPlatform platform,
  String devApiBaseUrl = '',
}) {
  final localUrl = platform == TargetPlatform.android
      ? 'http://10.0.2.2:8000/api/v1'
      : 'http://127.0.0.1:8000/api/v1';
  switch (flavor) {
    case AppFlavor.dev:
      final url = devApiBaseUrl.isEmpty ? localUrl : devApiBaseUrl;
      final uri = Uri.tryParse(url);
      final host = uri?.host.toLowerCase().replaceFirst(RegExp(r'\.
          !['http', 'https'].contains(uri.scheme) ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty ||
          host == 'api.usayd.academy' ||
          host == 'staging-api.usayd.academy') {
        throw ArgumentError('Invalid development API endpoint');
      }
      FlavorConfig.init(
        flavor: flavor,
        name: 'Usayd Dev',
        apiBaseUrl: url,
        appIdentifier: 'academy.usayd.learner.dev',
        enableLogging: true,
      );
    case AppFlavor.staging:
      FlavorConfig.init(
        flavor: flavor,
        name: 'Usayd Staging',
        apiBaseUrl: 'https://staging-api.usayd.academy/api/v1',
        appIdentifier: 'academy.usayd.learner.stg',
        enableLogging: true,
      );
    case AppFlavor.prod:
      FlavorConfig.init(
        flavor: flavor,
        name: 'أكاديمية أُسَيْد',
        apiBaseUrl: 'https://api.usayd.academy/api/v1',
        appIdentifier: 'academy.usayd.learner',
      );
  }
}

/// Reject a mismatched native flavor before initializing networking.
AppFlavor resolveEnvironment({
  required String? nativeFlavor,
  AppFlavor? requested,
  required bool release,
}) {
  if (nativeFlavor == null) {
    if (release || (requested != null && requested != AppFlavor.dev)) {
      throw StateError('Run with an explicit native --flavor');
    }
    return AppFlavor.dev;
  }
  final flavor = AppFlavor.values.byName(nativeFlavor);
  if (requested != null && requested != flavor) {
    throw StateError('Native flavor and Dart entrypoint do not match');
  }
  return flavor;
}
), '');
      if (uri == null ||
          !['http', 'https'].contains(uri.scheme) ||
          uri.host.isEmpty ||
          uri.userInfo.isNotEmpty ||
          uri.host.toLowerCase() == 'api.usayd.academy' ||
          uri.host.toLowerCase() == 'staging-api.usayd.academy') {
        throw ArgumentError('Invalid development API endpoint');
      }
      FlavorConfig.init(
        flavor: flavor,
        name: 'Usayd Dev',
        apiBaseUrl: url,
        appIdentifier: 'academy.usayd.learner.dev',
        enableLogging: true,
      );
    case AppFlavor.staging:
      FlavorConfig.init(
        flavor: flavor,
        name: 'Usayd Staging',
        apiBaseUrl: 'https://staging-api.usayd.academy/api/v1',
        appIdentifier: 'academy.usayd.learner.stg',
        enableLogging: true,
      );
    case AppFlavor.prod:
      FlavorConfig.init(
        flavor: flavor,
        name: 'أكاديمية أُسَيْد',
        apiBaseUrl: 'https://api.usayd.academy/api/v1',
        appIdentifier: 'academy.usayd.learner',
      );
  }
}

/// Reject a mismatched native flavor before initializing networking.
AppFlavor resolveEnvironment({
  required String? nativeFlavor,
  AppFlavor? requested,
  required bool release,
}) {
  if (nativeFlavor == null) {
    if (release || (requested != null && requested != AppFlavor.dev)) {
      throw StateError('Run with an explicit native --flavor');
    }
    return AppFlavor.dev;
  }
  final flavor = AppFlavor.values.byName(nativeFlavor);
  if (requested != null && requested != flavor) {
    throw StateError('Native flavor and Dart entrypoint do not match');
  }
  return flavor;
}
