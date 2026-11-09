import 'package:flutter/widgets.dart';

import '../data/local/sealed_preferences.dart';
import '../domain/settings/appearance.dart';

/// The person's appearance choices, changed on the Settings page and saved
/// through [store]. A failed save keeps the change for this session.
class AppearanceController extends ValueNotifier<AppearanceSettings> {
  AppearanceController(
    this.store, [
    super.initial = const AppearanceSettings(),
  ]);

  AppearanceStore store;

  /// True when the last save failed (shown on the Settings page).
  bool saveFailed = false;

  Future<void> visit(DiscoveryStep step) => update(value.visit(step));

  /// Switches to the preferences sealed in a just-opened vault (U018): saved
  /// choices are applied; with none saved yet, the choices of this session
  /// (for example from the introduction) are saved; a file that cannot be
  /// read is left as it is (until a choice is changed) and this session's
  /// choices stay on screen.
  ///
  /// A choice changed while the file was being read wins over the file
  /// (R005).
  Future<void> adopt(SealedAppearanceStore next) async {
    store = next;
    final before = value;
    final saved = await next.load();
    final changedMeanwhile = value != before;
    switch (next.state) {
      case SealedPreferencesState.readable when !changedMeanwhile:
        value = saved.copyWith(firstRunDone: true);
      case SealedPreferencesState.none:
      case SealedPreferencesState.readable:
        await _save(value);
      case SealedPreferencesState.unusable || SealedPreferencesState.unknown:
        break;
    }
    notifyListeners();
  }

  Future<void> update(AppearanceSettings next) async {
    if (next == value) return;
    value = next;
    await _save(next);
    notifyListeners();
  }

  /// Saves run one after another, so two quick changes never write the same
  /// file at once; the last change is the one kept (R005).
  Future<void> _saving = Future<void>.value();

  Future<void> _save(AppearanceSettings settings) {
    final target = store;
    final run = _saving.then((_) async {
      try {
        await target.save(settings);
        saveFailed = false;
      } catch (_) {
        saveFailed = true;
      }
    });
    _saving = run;
    return run;
  }
}

class AppearanceScope extends InheritedNotifier<AppearanceController> {
  const AppearanceScope({
    super.key,
    required AppearanceController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppearanceController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppearanceScope>()?.notifier;
}
