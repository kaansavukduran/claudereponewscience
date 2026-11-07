// U003@v0.32: every measurement Human OS records has a plain explanation
// with its unit and home steps; no entry gives a target or a judgement.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/guide/glossary.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/features/today/measurements_card.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show launch, tapKey, settle;
import 'u002_guide_test.dart' show diagnosing, reveal;

/// A target, a "normal" range or advice to aim for something.
final RegExp targets = RegExp(
  r'(?<!\p{L})(target|goal|ideal|optimal|should be|aim for|normal|healthy|'
  r'hedef|ideal|optimal|olmalı|normal|sağlıklı)(?!\p{L})',
  caseSensitive: false,
  unicode: true,
);

const definesRange = {'reference_interval', 'flag'};

void main() {
  test('every measurement on Today and the weight have an entry with a unit '
      'and home steps', () {
    for (final k in [...MeasurementsCard.kinds, RecordKind.bodyWeight]) {
      final e = glossaryForKind(k.code);
      expect(e, isNotNull, reason: k.code);
      expect(e!.unit, isNotNull, reason: k.code);
      expect(e.howToMeasure, isNotEmpty, reason: k.code);
    }
  });

  test('ids are unique and every kind link is a real record kind', () {
    expect({for (final e in glossary) e.id}.length, glossary.length);
    final codes = {for (final k in RecordKind.values) k.code};
    for (final e in glossary) {
      if (e.kind != null) expect(codes, contains(e.kind), reason: e.id);
    }
  });

  test('no entry gives a target, diagnoses or judges, in EN and TR', () {
    for (final e in glossary) {
      for (final t in [
        e.term.$1,
        e.term.$2,
        e.what.$1,
        e.what.$2,
        for (final h in e.howToMeasure) ...[h.$1, h.$2],
      ]) {
        expect(targets.hasMatch(t), isFalse, reason: t);
        expect(diagnosing.hasMatch(t), isFalse, reason: t);
        expect(interpretive.hasMatch(t), isFalse, reason: t);
        // The two lab terms define "above" and "outside" a printed range;
        // they say what the lab's words mean, not how a value is.
        if (!definesRange.contains(e.id)) {
          expect(judged.hasMatch(t), isFalse, reason: t);
        }
      }
    }
  });

  testWidgets('"About this measurement" in a sheet opens its entry; the '
      'glossary is searchable from Today', (tester) async {
    await launch(tester);
    await tapKey(tester, 'measure-tile-vital.blood_pressure');
    await tapKey(tester, 'measure-about');
    expect(
      find.byKey(const ValueKey('screen-glossary-blood_pressure')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('glossary-step-4')), findsOneWidget);
    await tester.tap(find.byTooltip('Back').first);
    await settle(tester);
    await tapKey(tester, 'measure-cancel');
    await reveal(tester, 'screen-today', 'tool-glossary');
    await tapKey(tester, 'tool-glossary');
    await tester.enterText(
      find.byKey(const ValueKey('glossary-search')),
      'satür',
    );
    await settle(tester);
    expect(find.byKey(const ValueKey('glossary-spo2')), findsOneWidget);
    expect(find.byKey(const ValueKey('glossary-height')), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('glossary-search')),
      'zzz',
    );
    await settle(tester);
    expect(find.byKey(const ValueKey('glossary-none')), findsOneWidget);
  });

  testWidgets('every entry opens in Turkish at 320 dp and 2x text', (
    tester,
  ) async {
    await launch(
      tester,
      locale: const Locale('tr'),
      size: const Size(320, 1400),
      textScale: 2.0,
    );
    await reveal(tester, 'screen-today', 'tool-glossary');
    await tapKey(tester, 'tool-glossary');
    for (final e in glossary) {
      await reveal(tester, 'screen-glossary', 'glossary-${e.id}');
      await tapKey(tester, 'glossary-${e.id}');
      expect(find.byKey(ValueKey('screen-glossary-${e.id}')), findsOneWidget);
      expect(tester.takeException(), isNull, reason: e.id);
      await tester.tap(find.byTooltip('Geri').first);
      await settle(tester);
    }
  });
}
