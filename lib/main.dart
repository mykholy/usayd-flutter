import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/flavor_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // If already initialized by flavor runner or test, keep it; otherwise default to dev
  if (!FlavorConfig.isInitialized) {
    const flavorEnv = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

    switch (flavorEnv.toLowerCase()) {
      case 'prod':
      case 'production':
        FlavorConfig.init(
          flavor: AppFlavor.prod,
          name: 'أكاديمية أُسَيْد',
          apiBaseUrl: 'https://api.usayd.academy/api/v1',
          appIdentifier: 'academy.usayd.learner',
          enableLogging: false,
        );
        break;
      case 'staging':
      case 'stg':
        FlavorConfig.init(
          flavor: AppFlavor.staging,
          name: 'Usayd Staging',
          apiBaseUrl: 'https://staging-api.usayd.academy/api/v1',
          appIdentifier: 'academy.usayd.learner.stg',
          enableLogging: true,
        );
        break;
      default:
        FlavorConfig.init(
          flavor: AppFlavor.dev,
          name: 'Usayd Dev',
          apiBaseUrl: 'http://10.0.2.2:8000/api/v1',
          appIdentifier: 'academy.usayd.learner.dev',
          enableLogging: true,
        );
        break;
    }
  }

  runApp(const UsaydApp());
}
