import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';

void main() {
  test(
    'APP_ENV fails closed: unknown never becomes production or development',
    () {
      expect(BuildProfile.parse('prod'), BuildProfile.production);
      expect(BuildProfile.parse('PRODUCTION'), BuildProfile.production);
      expect(BuildProfile.parse('staging'), BuildProfile.staging);
      expect(BuildProfile.parse('development'), BuildProfile.development);
      expect(BuildProfile.parse(' Dev '), BuildProfile.development);
      // A typo is labelled and memory-only, never the plaintext-persisting profile.
      expect(BuildProfile.parse('typo'), BuildProfile.staging);
      expect(BuildProfile.parse('prd'), BuildProfile.staging);
      // Missing: development only for debug/profile runs; a release build
      // that forgot APP_ENV is staging.
      expect(BuildProfile.parse('', release: false), BuildProfile.development);
      expect(BuildProfile.parse('', release: true), BuildProfile.staging);
    },
  );

  test('absent build identity reads "unknown", never a guessed value', () {
    expect(AppConfig.fromEnvironment().version, 'unknown');
    expect(AppConfig.fromEnvironment().sourceRevision, 'unknown');
  });

  test('memory-only storage: "off in this build" where an adapter exists, '
      '"not built yet" where none does', () {
    String status(HostPlatform p) =>
        CapabilityRegistry.forPlatform(p).capabilities
            .firstWhere((c) => c.id == 'local_storage')
            .status
            .name;
    for (final p in [
      HostPlatform.web,
      HostPlatform.linux,
      HostPlatform.windows,
      HostPlatform.macos,
    ]) {
      expect(status(p), 'offInThisBuild', reason: p.name);
    }
    expect(status(HostPlatform.android), 'notImplemented');
    expect(status(HostPlatform.ios), 'notImplemented');
  });

  test('default (no --dart-define) is development', () {
    expect(AppConfig.fromEnvironment().profile, BuildProfile.development);
  });

  test('FORGE 001 claims no implemented capability on any platform', () {
    for (final p in HostPlatform.values) {
      final reg = CapabilityRegistry.forPlatform(p);
      expect(
        reg.capabilities.where((c) => c.status == CapabilityStatus.available),
        isEmpty,
        reason: p.name,
      );
    }
  });

  test('health platform adapters only appear on their own platform', () {
    String healthLabel(HostPlatform p) =>
        CapabilityRegistry.forPlatform(p).capabilities
            .firstWhere((c) => c.id == 'health_platform')
            .label;
    expect(healthLabel(HostPlatform.android), 'Health Connect');
    expect(healthLabel(HostPlatform.ios), 'Apple Health (HealthKit)');
    for (final p in [
      HostPlatform.web,
      HostPlatform.windows,
      HostPlatform.macos,
      HostPlatform.linux,
    ]) {
      expect(healthLabel(p), 'Health platform', reason: p.name);
    }
  });
}
