import 'package:flutter/material.dart';

import 'src/app/human_os_app.dart';
import 'src/config/app_config.dart';
import 'src/core/capabilities.dart';

void main() {
  final config = AppConfig.fromEnvironment();
  final registry = CapabilityRegistry.forPlatform(detectHostPlatform());
  runApp(HumanOsApp(config: config, registry: registry));
}
