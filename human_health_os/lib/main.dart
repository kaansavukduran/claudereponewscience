import 'package:flutter/material.dart';

import 'src/app/appearance_scope.dart';
import 'src/app/bootstrap.dart';
import 'src/app/human_os_app.dart';
import 'src/app/startup_error_app.dart';
import 'src/config/app_config.dart';
import 'src/core/capabilities.dart';
import 'src/core/redact.dart';
import 'src/data/local/appearance_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Every framework and uncaught error is reported redacted (master §37).
  installRedactedErrorReporting();
  try {
    final config = AppConfig.fromEnvironment();
    final platform = detectHostPlatform();
    final startup = await startApp(config, platform);
    final store = await openAppearanceStore(config, platform);
    final appearance = AppearanceController(store, await store.load());
    // The introduction is offered only where seeing it can be remembered
    // (desktop development builds today; G-62).
    runApp(
      HumanOsApp.start(
        startup,
        appearance: appearance,
        offerFirstRun: store.persistent,
      ),
    );
  } catch (e) {
    // startApp() already falls back to memory when the vault cannot be
    // opened; anything else that fails here is shown, never a blank window.
    logEvent('startup_failed', error: e);
    runApp(StartupErrorApp(error: e));
  }
}
