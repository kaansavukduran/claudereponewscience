import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../features/vault/vault_gate_screen.dart';
import '../navigation/app_shell.dart';
import '../presentation/theme/human_os_theme.dart';
import 'app_services.dart';
import 'bootstrap.dart';

/// The app. Builds that keep an encrypted vault start at the vault gate
/// ([gate]); the shell appears once the gate hands over [AppServices].
class HumanOsApp extends StatefulWidget {
  const HumanOsApp({super.key, this.services, this.gate})
    : assert(services != null || gate != null);

  factory HumanOsApp.start(AppStartup startup) =>
      HumanOsApp(services: startup.services, gate: startup.gate);

  final AppServices? services;
  final VaultGate? gate;

  @override
  State<HumanOsApp> createState() => _HumanOsAppState();
}

class _HumanOsAppState extends State<HumanOsApp> {
  AppServices? _services;

  @override
  void initState() {
    super.initState();
    _services = widget.services;
  }

  @override
  void didUpdateWidget(HumanOsApp old) {
    super.didUpdateWidget(old);
    // A new app instance (a test's "relaunch") starts from its own inputs.
    if (widget.services != old.services || widget.gate != old.gate) {
      _services = widget.services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = _services;
    return MaterialApp(
      title: 'Human OS',
      debugShowCheckedModeBanner: false,
      theme: buildHumanOsTheme(Brightness.light),
      darkTheme: buildHumanOsTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: services != null
          ? AppShell(key: ObjectKey(services), services: services)
          : VaultGateScreen(
              key: ObjectKey(widget.gate),
              gate: widget.gate!,
              onReady: (s) => setState(() => _services = s),
            ),
    );
  }
}
