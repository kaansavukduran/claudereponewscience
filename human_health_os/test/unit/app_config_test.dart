import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';

void main() {
  test('unknown APP_ENV never becomes production', () {
    expect(BuildProfile.parse('prod'), BuildProfile.production);
    expect(BuildProfile.parse('PRODUCTION'), BuildProfile.production);
    expect(BuildProfile.parse('staging'), BuildProfile.staging);
    expect(BuildProfile.parse(''), BuildProfile.development);
    expect(BuildProfile.parse('typo'), BuildProfile.development);
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
