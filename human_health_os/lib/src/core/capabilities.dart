/// Runtime capability registry.
///
/// Reports what *this* runtime really offers. An integration is never shown as
/// working because another platform supports it, and nothing is claimed before
/// its adapter exists.
library;

import 'package:flutter/foundation.dart';

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

  /// FORGE 001: no adapter exists yet, so nothing is `available`.
  factory CapabilityRegistry.forPlatform(HostPlatform platform) {
    final healthPlatform = switch (platform) {
      HostPlatform.android => const Capability(
        id: 'health_platform',
        label: 'Health Connect',
        status: CapabilityStatus.notImplemented,
        detail: 'Android adapter planned (FORGE 023).',
      ),
      HostPlatform.ios => const Capability(
        id: 'health_platform',
        label: 'Apple Health (HealthKit)',
        status: CapabilityStatus.notImplemented,
        detail: 'iOS adapter planned (FORGE 024).',
      ),
      _ => const Capability(
        id: 'health_platform',
        label: 'Health platform',
        status: CapabilityStatus.unsupportedOnPlatform,
        detail: 'No HealthKit or Health Connect on this platform. Manual entry and file import are the paths.',
      ),
    };
    final keyStore = switch (platform) {
      HostPlatform.web => const Capability(
        id: 'key_store',
        label: 'Key protection',
        status: CapabilityStatus.notImplemented,
        detail: 'Browser: no OS keychain. WebCrypto + passphrase planned (FORGE 004).',
      ),
      _ => const Capability(
        id: 'key_store',
        label: 'Key protection',
        status: CapabilityStatus.notImplemented,
        detail: 'Encrypted vault with passphrase + platform key store planned (FORGE 004).',
      ),
    };
    final storage = switch (platform) {
      HostPlatform.web => const Capability(
        id: 'local_storage',
        label: 'Local health records',
        status: CapabilityStatus.notImplemented,
        detail: 'Browser storage can be evicted; export will be the durable path. Planned FORGE 002.',
      ),
      _ => const Capability(
        id: 'local_storage',
        label: 'Local health records',
        status: CapabilityStatus.notImplemented,
        detail: 'Local vault planned (FORGE 002, encrypted in FORGE 004).',
      ),
    };
    return CapabilityRegistry(
      platform: platform,
      capabilities: [
        storage,
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
