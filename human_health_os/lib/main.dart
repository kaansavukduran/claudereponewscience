import 'package:flutter/material.dart';

import 'src/app/bootstrap.dart';
import 'src/app/human_os_app.dart';
import 'src/config/app_config.dart';
import 'src/core/capabilities.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await bootstrap(
    AppConfig.fromEnvironment(),
    detectHostPlatform(),
  );
  runApp(HumanOsApp(services: services));
}
