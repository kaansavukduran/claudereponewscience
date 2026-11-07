// U002@v0.32: a clickable guide to the body's systems and the specialties
// that care for them. It explains, never diagnoses, and its links to Human
// OS measurements point at kinds that exist.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/guide/body_guide.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show launch, tapKey, settle;

/// Words a guide must not use about a person: it names no disease and gives
/// no instruction to treat.
final RegExp diagnosing = RegExp(
  r'(?<!\p{L})(you have|you may have|diagnos\p{L}*|symptom\p{L}*|disease|'
  r'disorder|treat(ment)?|cure|risk|teşhis|tanı|belirti\p{L}*|hastalığın|'
  r'tedavi\p{L}*|risk\p{L}*)(?!\p{L})',
  caseSensitive: false,
  unicode: true,
);

/// Scrolls the lazy list [list] until [key] is built.
Future<void> reveal(WidgetTester tester, String list, String key) async {
  final f = find.byKey(ValueKey(key));
  if (f.evaluate().isNotEmpty) return;
  await tester.scrollUntilVisible(
    f,
    300,
    scrollable: find
        .descendant(
          of: find.byKey(ValueKey(list)),
          matching: find.byType(Scrollable),
        )
        .first,
  );
}

void main() {
  group('the guide data', () {
    test(
      'every system names a specialty that exists and at least one part',
      () {
        final ids = {for (final s in specialties) s.id};
        expect(ids.length, specialties.length, reason: 'ids are unique');
        expect({for (final b in bodySystems) b.id}.length, bodySystems.length);
        for (final b in bodySystems) {
          expect(b.parts, isNotEmpty, reason: b.id);
          expect(b.specialties, isNotEmpty, reason: b.id);
          for (final id in b.specialties) {
            expect(ids, contains(id), reason: '${b.id} → $id');
          }
        }
      },
    );

    test('every linked measurement is a record kind Human OS has', () {
      final codes = {for (final k in RecordKind.values) k.code};
      for (final b in bodySystems) {
        for (final m in b.measurements) {
          expect(codes, contains(m), reason: '${b.id} → $m');
        }
      }
    });

    test('no text diagnoses, judges or advises treatment, in EN and TR', () {
      final texts = <String>[
        for (final b in bodySystems) ...[
          b.name.$1,
          b.name.$2,
          b.what.$1,
          b.what.$2,
          for (final p in b.parts) ...[p.$1, p.$2],
        ],
        for (final s in specialties) ...[s.name.$1, s.name.$2],
        for (final lang in AppLang.values) ...[
          S(lang).guideTitle,
          S(lang).guideTileHint,
          S(lang).guideIntro,
          S(lang).guideFirstStop,
        ],
      ];
      // The disclaimer says the guide does not diagnose; it is checked for
      // judging words only.
      for (final lang in AppLang.values) {
        expect(judged.hasMatch(S(lang).guideNotAdvice), isFalse);
      }
      for (final t in texts) {
        expect(diagnosing.hasMatch(t), isFalse, reason: t);
        expect(interpretive.hasMatch(t), isFalse, reason: t);
        expect(judged.hasMatch(t), isFalse, reason: t);
      }
    });
  });

  testWidgets('Today → guide → Heart: parts, specialties, what can be '
      'recorded, and where to go first', (tester) async {
    await launch(tester);
    await tapKey(tester, 'tool-guide');
    expect(find.byKey(const ValueKey('screen-guide')), findsOneWidget);
    await tapKey(tester, 'guide-system-heart');
    expect(find.byKey(const ValueKey('screen-guide-heart')), findsOneWidget);
    expect(find.text('Cardiology'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('guide-specialty-cardiology')),
      findsOneWidget,
    );
    expect(find.textContaining('Blood pressure'), findsWidgets);
    expect(find.textContaining('112'), findsOneWidget);
    expect(find.byKey(const ValueKey('guide-not-advice')), findsOneWidget);
  });

  testWidgets('every system opens, in Turkish, at 320 dp and 2x text', (
    tester,
  ) async {
    await launch(
      tester,
      locale: const Locale('tr'),
      size: const Size(320, 1400),
      textScale: 2.0,
    );
    await reveal(tester, 'screen-today', 'tool-guide');
    await tapKey(tester, 'tool-guide');
    for (final b in bodySystems) {
      await reveal(tester, 'screen-guide', 'guide-system-${b.id}');
      await tapKey(tester, 'guide-system-${b.id}');
      expect(find.byKey(ValueKey('screen-guide-${b.id}')), findsOneWidget);
      expect(find.text(b.name.$2), findsWidgets);
      expect(tester.takeException(), isNull, reason: b.id);
      await tester.tap(find.byTooltip('Geri').first);
      await settle(tester);
    }
  });
}
