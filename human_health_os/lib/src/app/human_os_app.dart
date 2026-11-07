import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../domain/settings/appearance.dart';
import '../features/vault/vault_gate_screen.dart';
import '../navigation/app_shell.dart';
import '../presentation/theme/human_os_theme.dart';
import 'app_services.dart';
import 'appearance_scope.dart';
import 'bootstrap.dart';

/// The app. Builds that keep an encrypted vault start at the vault gate
/// ([gate]); the shell appears once the gate hands over [AppServices].
class HumanOsApp extends StatefulWidget {
  const HumanOsApp({super.key, this.services, this.gate, this.appearance})
    : assert(services != null || gate != null);

  factory HumanOsApp.start(
    AppStartup startup, {
    AppearanceController? appearance,
  }) => HumanOsApp(
    services: startup.services,
    gate: startup.gate,
    appearance: appearance,
  );

  final AppServices? services;
  final VaultGate? gate;

  /// Language, theme, accent and text size; a session-only default when
  /// null (tests).
  final AppearanceController? appearance;

  @override
  State<HumanOsApp> createState() => _HumanOsAppState();
}

class _HumanOsAppState extends State<HumanOsApp> {
  AppServices? _services;
  late AppearanceController _appearance =
      widget.appearance ?? AppearanceController(MemoryAppearanceStore());

  @override
  void initState() {
    super.initState();
    _services = widget.services;
    _appearance.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _appearance.removeListener(_changed);
    super.dispose();
  }

  @override
  void didUpdateWidget(HumanOsApp old) {
    super.didUpdateWidget(old);
    // A new app instance (a test's "relaunch") starts from its own inputs.
    if (widget.services != old.services || widget.gate != old.gate) {
      _services = widget.services;
    }
    if (widget.appearance != null && widget.appearance != _appearance) {
      _appearance.removeListener(_changed);
      _appearance = widget.appearance!..addListener(_changed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = _services;
    final a = _appearance.value;
    return AppearanceScope(
      controller: _appearance,
      child: MaterialApp(
        title: 'Human OS',
        debugShowCheckedModeBanner: false,
        theme: buildHumanOsTheme(
          Brightness.light,
          accentChoice: a.accent,
          highContrast: a.highContrast,
          compact: a.density == Density.compact,
          fontFamily: fontFamilyFor(a.font),
          wideSpacing: a.wideSpacing,
        ),
        darkTheme: buildHumanOsTheme(
          Brightness.dark,
          accentChoice: a.accent,
          highContrast: a.highContrast,
          compact: a.density == Density.compact,
          fontFamily: fontFamilyFor(a.font),
          wideSpacing: a.wideSpacing,
        ),
        themeMode: switch (a.theme) {
          ThemeChoice.system => ThemeMode.system,
          ThemeChoice.light => ThemeMode.light,
          ThemeChoice.dark => ThemeMode.dark,
        },
        locale: switch (a.language) {
          LanguageChoice.system => null,
          LanguageChoice.tr => const Locale('tr'),
          LanguageChoice.en => const Locale('en'),
        },
        supportedLocales: const [Locale('en'), Locale('tr')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        // The chosen text size multiplies what the system asks for.
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          final factor = a.textFactor;
          if (factor == 1.0) return child!;
          return MediaQuery(
            data: mq.copyWith(textScaler: _Scaled(mq.textScaler, factor)),
            child: child!,
          );
        },
        home: services != null
            ? AppShell(key: ObjectKey(services), services: services)
            : VaultGateScreen(
                key: ObjectKey(widget.gate),
                gate: widget.gate!,
                onReady: (s) => setState(() => _services = s),
              ),
      ),
    );
  }
}

/// The bundled family for a font choice; null keeps the device font.
String? fontFamilyFor(FontChoice f) => switch (f) {
  FontChoice.system => null,
  FontChoice.legible => 'AtkinsonHyperlegibleNext',
  FontChoice.dyslexic => 'OpenDyslexic',
};

class _Scaled extends TextScaler {
  const _Scaled(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => base.textScaleFactor * factor;

  @override
  bool operator ==(Object other) =>
      other is _Scaled && other.base == base && other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
