/// Runtime capability registry.
///
/// Reports what *this* runtime really offers. An integration is never shown as
/// working because another platform supports it, and nothing is claimed before
/// its adapter exists.
library;

import 'package:flutter/foundation.dart';

import '../domain/ports/health_repository.dart';

enum HostPlatform { android, ios, web, windows, macos, linux, other }

enum CapabilityStatus {
  /// Adapter implemented and usable on this runtime.
  available,

  /// The platform could support it, but the adapter is not built yet.
  notImplemented,

  /// The platform itself cannot provide it (e.g. HealthKit in a browser).
  unsupportedOnPlatform,

  /// Deliberately not used by this build (e.g. network for the offline core).
  notRequired,

  /// The adapter exists on this platform, but this build keeps it off:
  /// its profile or portable mode forbids unencrypted saving, or the saved
  /// data could not be opened. The weight card names the reason.
  offInThisBuild,
}

class Capability {
  const Capability({
    required this.id,
    required this.label,
    required this.status,
    required this.detail,
  });

  final String id;
  final String label;
  final CapabilityStatus status;
  final String detail;
}

HostPlatform detectHostPlatform() {
  if (kIsWeb) return HostPlatform.web;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return HostPlatform.android;
    case TargetPlatform.iOS:
      return HostPlatform.ios;
    case TargetPlatform.windows:
      return HostPlatform.windows;
    case TargetPlatform.macOS:
      return HostPlatform.macos;
    case TargetPlatform.linux:
      return HostPlatform.linux;
    case TargetPlatform.fuchsia:
      return HostPlatform.other;
  }
}

class CapabilityRegistry {
  const CapabilityRegistry({
    required this.platform,
    required this.capabilities,
  });

  /// Only real adapters are reported as `available`. [storage] describes the
  /// repository actually opened at startup (null before it exists).
  factory CapabilityRegistry.forPlatform(
    HostPlatform platform, {
    StorageDescription? storage,
  }) {
    final healthPlatform = switch (platform) {
      HostPlatform.android => const Capability(
        id: 'health_platform',
        label: 'Health Connect',
        status: CapabilityStatus.notImplemented,
        detail: 'Android adapter planned (Forge F013).',
      ),
      HostPlatform.ios => const Capability(
        id: 'health_platform',
        label: 'Apple Health (HealthKit)',
        status: CapabilityStatus.notImplemented,
        detail: 'iOS adapter planned (Forge F013).',
      ),
      _ => const Capability(
        id: 'health_platform',
        label: 'Health platform',
        status: CapabilityStatus.unsupportedOnPlatform,
        detail: 'No HealthKit or Health Connect on this platform. Manual entry works now; file import is planned (Forge F005).',
      ),
    };
    final keyStore = switch (platform) {
      HostPlatform.web => const Capability(
        id: 'key_store',
        label: 'Key protection',
        status: CapabilityStatus.notImplemented,
        detail: 'Browser: no OS keychain. WebCrypto + passphrase planned (Forge F006).',
      ),
      _ => const Capability(
        id: 'key_store',
        label: 'Key protection',
        status: CapabilityStatus.notImplemented,
        detail: 'Encrypted vault with passphrase + platform key store planned (Forge F006).',
      ),
    };
    final storageCap = switch (storage?.durability) {
      StorageDurability.localFile => const Capability(
        id: 'local_storage',
        label: 'Local health records',
        status: CapabilityStatus.available,
        detail: 'Saved in a file on this device. Not encrypted yet (development build); encryption arrives in Forge F006.',
      ),
      StorageDurability.browserStorage => const Capability(
        id: 'local_storage',
        label: 'Local health records',
        status: CapabilityStatus.available,
        detail: 'Saved in this browser. The browser may clear it; not encrypted yet (development build).',
      ),
      StorageDurability.memoryOnly || null => switch (platform) {
        HostPlatform.android ||
        HostPlatform.ios ||
        HostPlatform.other => const Capability(
          id: 'local_storage',
          label: 'Local health records',
          status: CapabilityStatus.notImplemented,
          detail: 'Not saved on this platform yet: entries last only until the app closes.',
        ),
        _ => const Capability(
          id: 'local_storage',
          label: 'Local health records',
          status: CapabilityStatus.offInThisBuild,
          detail: 'Not saved in this build: entries last only until the app closes. The weight card says why.',
        ),
      },
    };
    return CapabilityRegistry(
      platform: platform,
      capabilities: [
        storageCap,
        keyStore,
        healthPlatform,
        const Capability(
          id: 'network',
          label: 'Network',
          status: CapabilityStatus.notRequired,
          detail: 'Not required. This build makes no network calls.',
        ),
      ],
    );
  }

  final HostPlatform platform;
  final List<Capability> capabilities;
}
