import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../domain/settings/appearance.dart';
import '../domain/settings/date_style.dart';
import '../features/onboarding/first_run_screen.dart';
import '../data/local/encrypted_vault.dart';
import '../features/vault/vault_gate_screen.dart';
import '../navigation/app_shell.dart';
import '../presentation/theme/human_os_theme.dart';
import 'app_services.dart';
import 'appearance_scope.dart';
import 'bootstrap.dart';

/// The app. Builds that keep an encrypted vault start at the vault gate
/// ([gate]); the shell appears once the gate hands over [AppServices].
class HumanOsApp extends StatefulWidget {
  const HumanOsApp({
    super.key,
    this.services,
    this.gate,
    this.appearance,
    this.offerFirstRun = false,
    this.offerIntroBeforeNewVault = false,
  }) : assert(services != null || gate != null);

  factory HumanOsApp.start(
    AppStartup startup, {
    AppearanceController? appearance,
    bool offerFirstRun = false,
    bool offerIntroBeforeNewVault = false,
  }) => HumanOsApp(
    services: startup.services,
    gate: startup.gate,
    appearance: appearance,
    offerFirstRun: offerFirstRun && appearance != null,
    offerIntroBeforeNewVault: offerIntroBeforeNewVault,
  );

  final AppServices? services;
  final VaultGate? gate;

  /// Language, theme, accent and text size; a session-only default when
  /// null (tests).
  final AppearanceController? appearance;

  /// Shows the short introduction once (the real app; tests opt in).
  final bool offerFirstRun;

  /// Shows the introduction before the passphrase screen when no vault
  /// exists yet (a first start of an encrypted build; G-64). The choices
  /// apply for this session; nothing is written before the vault exists,
  /// and a later start finds the vault and skips the introduction.
  final bool offerIntroBeforeNewVault;

  @override
  State<HumanOsApp> createState() => _HumanOsAppState();
}

class _HumanOsAppState extends State<HumanOsApp> {
  void _finishIntro() {
    setState(() => _introDone = true);
    _appearance.update(_appearance.value.copyWith(firstRunDone: true));
  }

  AppServices? _services;
  bool _introDone = false;
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
    // Every displayed time follows the chosen style (display only).
    displayDateOrder = a.dateOrder;
    displayClock = a.clock;
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
          reduceMotion: a.reduceMotion,
        ),
        darkTheme: buildHumanOsTheme(
          Brightness.dark,
          accentChoice: a.accent,
          highContrast: a.highContrast,
          compact: a.density == Density.compact,
          fontFamily: fontFamilyFor(a.font),
          wideSpacing: a.wideSpacing,
          reduceMotion: a.reduceMotion,
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
            ? (widget.offerFirstRun && !a.firstRunDone && !_introDone
                  ? FirstRunScreen(onDone: _finishIntro)
                  : AppShell(key: ObjectKey(services), services: services))
            // Only with a store that keeps nothing: choices made here must
            // not reach the disk before the vault exists.
            : (widget.offerIntroBeforeNewVault &&
                      !_appearance.store.persistent &&
                      !_introDone &&
                      !a.firstRunDone &&
                      widget.gate!.inspection.access == VaultAccess.create
                  ? FirstRunScreen(onDone: _finishIntro)
                  : VaultGateScreen(
                      key: ObjectKey(widget.gate),
                      gate: widget.gate!,
                      onReady: (s) => setState(() => _services = s),
                    )),
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
