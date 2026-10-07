/// Shown when startup itself fails, so the user sees what happened instead
/// of a blank window (audit UX-8). It touches no storage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/redact.dart';
import '../l10n/strings.dart';

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Human OS',
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Builder(
        builder: (context) {
          final s = S.of(context);
          final text = Theme.of(context).textTheme;
          return Scaffold(
            body: SafeArea(
              child: ListView(
                key: const ValueKey('startup-error'),
                padding: const EdgeInsets.all(24),
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      s.startupFailedTitle,
                      style: text.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(s.startupFailedBody, style: text.bodyLarge),
                  const SizedBox(height: 12),
                  // Type and code only: a message may quote data (§37).
                  SelectableText(describeError(error), style: text.bodySmall),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
