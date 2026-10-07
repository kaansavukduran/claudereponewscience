import 'package:flutter/material.dart';

import 'src/app/bootstrap.dart';
import 'src/app/human_os_app.dart';
import 'src/app/startup_error_app.dart';
import 'src/config/app_config.dart';
import 'src/core/capabilities.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final services = await bootstrap(
      AppConfig.fromEnvironment(),
      detectHostPlatform(),
    );
    runApp(HumanOsApp(services: services));
  } catch (e) {
    // bootstrap() already falls back to memory when the vault cannot be
    // opened; anything else that fails here is shown, never a blank window.
    runApp(StartupErrorApp(error: e));
  }
}
