import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/flavor_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig.init(
    flavor: AppFlavor.staging,
    name: 'Usayd Staging',
    apiBaseUrl: 'https://staging-api.usayd.academy/api/v1',
    appIdentifier: 'academy.usayd.learner.stg',
    enableLogging: true,
  );

  runApp(const UsaydApp());
}
