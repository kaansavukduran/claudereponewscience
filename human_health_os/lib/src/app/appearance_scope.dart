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

  /// Switches to the preferences sealed in a just-opened vault (U018): saved
  /// choices are applied; with none saved yet, the choices of this session
  /// (for example from the introduction) are saved; a file that cannot be
  /// read is left as it is (until a choice is changed) and this session's
  /// choices stay on screen.
  Future<void> adopt(SealedAppearanceStore next) async {
    store = next;
    final saved = await next.load();
    switch (next.state) {
      case SealedPreferencesState.readable:
        value = saved.copyWith(firstRunDone: true);
      case SealedPreferencesState.none:
        try {
          await next.save(value);
          saveFailed = false;
        } catch (_) {
          saveFailed = true;
        }
      case SealedPreferencesState.unusable || SealedPreferencesState.unknown:
        break;
    }
    notifyListeners();
  }

  Future<void> update(AppearanceSettings next) async {
    if (next == value) return;
    value = next;
    try {
      await store.save(next);
      saveFailed = false;
    } catch (_) {
      saveFailed = true;
    }
    notifyListeners();
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
