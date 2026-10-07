import 'package:flutter/material.dart';

import 'src/app/bootstrap.dart';
import 'src/app/human_os_app.dart';
import 'src/app/startup_error_app.dart';
import 'src/config/app_config.dart';
import 'src/core/capabilities.dart';
import 'src/core/redact.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Every framework and uncaught error is reported redacted (master §37).
  installRedactedErrorReporting();
  try {
    final startup = await startApp(
      AppConfig.fromEnvironment(),
      detectHostPlatform(),
    );
    runApp(HumanOsApp.start(startup));
  } catch (e) {
    // startApp() already falls back to memory when the vault cannot be
    // opened; anything else that fails here is shown, never a blank window.
    logEvent('startup_failed', error: e);
    runApp(StartupErrorApp(error: e));
  }
}
