import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/config/environment.dart';
import 'core/config/flavor_config.dart';

void bootstrap({AppFlavor? requested}) {
  WidgetsFlutterBinding.ensureInitialized();
  final flavor = resolveEnvironment(
    nativeFlavor: appFlavor,
    requested: requested,
    release: kReleaseMode,
  );
  configureEnvironment(
    flavor,
    platform: defaultTargetPlatform,
    devApiBaseUrl: const String.fromEnvironment('DEV_API_BASE_URL'),
  );
  runApp(const UsaydApp());
}
