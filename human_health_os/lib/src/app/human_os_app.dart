import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../navigation/app_shell.dart';
import '../presentation/theme/human_os_theme.dart';
import 'app_services.dart';

class HumanOsApp extends StatelessWidget {
  const HumanOsApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Human OS',
      debugShowCheckedModeBanner: false,
      theme: buildHumanOsTheme(Brightness.light),
      darkTheme: buildHumanOsTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: AppShell(services: services),
    );
  }
}
