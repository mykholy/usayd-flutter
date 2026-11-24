import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/flavor_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig.init(
    flavor: AppFlavor.dev,
    name: 'Usayd Dev',
    apiBaseUrl: 'http://10.0.2.2:8000/api/v1',
    appIdentifier: 'academy.usayd.learner.dev',
    enableLogging: true,
  );

  runApp(const UsaydApp());
}
