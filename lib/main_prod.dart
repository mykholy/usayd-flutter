import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/flavor_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig.init(
    flavor: AppFlavor.prod,
    name: 'أكاديمية أُسَيْد',
    apiBaseUrl: 'https://api.usayd.academy/api/v1',
    appIdentifier: 'academy.usayd.learner',
    enableLogging: false,
  );

  runApp(const UsaydApp());
}
