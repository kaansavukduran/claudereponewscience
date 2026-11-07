import 'package:flutter/widgets.dart';

import '../domain/settings/appearance.dart';

/// The person's appearance choices, changed on the Settings page and saved
/// through [store]. A failed save keeps the change for this session.
class AppearanceController extends ValueNotifier<AppearanceSettings> {
  AppearanceController(
    this.store, [
    super.initial = const AppearanceSettings(),
  ]);

  final AppearanceStore store;

  /// True when the last save failed (shown on the Settings page).
  bool saveFailed = false;

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
