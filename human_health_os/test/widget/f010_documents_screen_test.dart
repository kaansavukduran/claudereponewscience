// F010 slice 1: the Documents screen. A reference is not the document; the
// app never reads, opens, uploads or stores it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/features/timeline/timeline_screen.dart'
    show fmtValue;
import 'package:human_health_os/src/l10n/strings.dart';
import 'package:human_health_os/src/navigation/destinations.dart';

import 'f001_contract_test.dart' show boot;
import 'f004_labs_test.dart' show interpretive;
import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  testWidgets('add a document reference; the sheet starts at other; a '
      'correction starts from the shown version and keeps one entry', (
    tester,
  ) async {
    await launchWith(tester);
    await tester.tap(find.byKey(const ValueKey('rail-planned-documents')));
    await settle(tester);
    expect(find.byKey(const ValueKey('screen-documents')), findsOneWidget);
    expect(find.byKey(const ValueKey('doc-none')), findsOneWidget);
    await tapKey(tester, 'doc-add');
    ChoiceChip chip(String key) =>
        tester.widget<ChoiceChip>(find.byKey(ValueKey(key)));
    // Nothing is chosen for the person.
    for (final t in DocumentType.values) {
      expect(
        chip('doc-nature-${t.name}').selected,
        t == DocumentType.other,
        reason: t.name,
      );
    }
    await tapKey(tester, 'doc-save');
    expect(find.text(S(AppLang.en).inputError('EMPTY')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('doc-title')),
      'Blood test report',
    );
    await tapKey(tester, 'doc-nature-labReport');
    await tester.enterText(find.byKey(const ValueKey('doc-date')), '2025-03');
    await tester.enterText(
      find.byKey(const ValueKey('doc-issuer')),
      'City Clinic',
    );
    await tester.enterText(
      find.byKey(const ValueKey('doc-where')),
      'paper folder at home',
    );
    await tapKey(tester, 'doc-save');
    await settle(tester);
    const line =
        'Blood test report · lab report · dated: 2025-03 · '
        'from: City Clinic · kept: paper folder at home';
    expect(find.text(line), findsOneWidget);
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('doc-correct-'),
      ),
    );
    await settle(tester);
    expect(chip('doc-nature-labReport').selected, isTrue);
    await tester.enterText(find.byKey(const ValueKey('doc-where')), 'email');
    await tapKey(tester, 'doc-save');
    await settle(tester);
    expect(find.text(line), findsNothing);
    expect(
      find.text(
        'Blood test report · lab report · dated: 2025-03 · '
        'from: City Clinic · kept: email',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('doc-entry-'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('cancel writes nothing; blank optional fields are left out of '
      'the line', (tester) async {
    await launchWith(tester);
    await tester.tap(find.byKey(const ValueKey('rail-planned-documents')));
    await settle(tester);
    await tapKey(tester, 'doc-add');
    await tester.enterText(find.byKey(const ValueKey('doc-title')), 'x');
    await tapKey(tester, 'doc-cancel');
    await settle(tester);
    expect(find.byKey(const ValueKey('doc-none')), findsOneWidget);
    await tapKey(tester, 'doc-add');
    await tester.enterText(
      find.byKey(const ValueKey('doc-title')),
      'Vaccination card',
    );
    await tapKey(tester, 'doc-save');
    await settle(tester);
    expect(find.text('Vaccination card · other'), findsOneWidget);
  });

  test('the Turkish line and words read naturally', () {
    const d = DocumentReferenceDetails(
      title: 'Kan tahlili',
      nature: DocumentType.labReport,
      date: '2025-03',
      issuer: 'Şehir Kliniği',
      whereKept: 'evdeki dosyada',
    );
    final tr = S(AppLang.tr);
    expect(
      tr.docLine(d),
      'Kan tahlili · tahlil raporu · tarihi: 2025-03 · veren: Şehir Kliniği · '
      'saklandığı yer: evdeki dosyada',
    );
    expect(tr.docTitle, 'Belgeler');
    expect(tr.docNature(DocumentType.letter), 'doktor yazısı');
    expect(tr.docNature(DocumentType.prescription), 'reçete');
    expect(tr.docNature(DocumentType.imaging), 'görüntüleme');
    expect(tr.docNature(DocumentType.vaccinationCard), 'aşı kartı');
    expect(tr.docNature(DocumentType.other), 'diğer');
    expect(tr.docWhere, startsWith('Nerede saklıyorsun'));
    expect(S(AppLang.en).docIntro, contains('never reads'));
    expect(tr.docIntro, contains('asla okumaz'));
    final dest = destinationById(DestinationId.documents);
    expect(dest.plannedForge, isNull);
    expect(dest.isPrimary, isFalse);
    expect(dest.principleEn, contains('does not read it'));
  });

  test('the words judge and interpret nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      final dest = destinationById(DestinationId.documents);
      for (final w in [
        s.docTitle,
        s.docIntro,
        s.docNone,
        s.docAdd,
        s.docTitleField,
        s.docDate,
        s.docIssuer,
        s.docWhere,
        s.docNatureLabel,
        s.recordKind(RecordKind.documentReference),
        dest.purpose(lang),
        dest.principle(lang),
        for (final t in DocumentType.values) s.docNature(t),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
      }
    }
  });

  test('R014: the Timeline line keeps every field as typed', () {
    final r = HealthRecord(
      id: 'x',
      profileId: 'p',
      kind: RecordKind.documentReference,
      state: RecordState.reported,
      valueStatus: ValueStatus.present,
      quantity: null,
      originalText: null,
      provenance: const Provenance.manual(),
      observedAt: DateTime.utc(2026, 11, 12, 9),
      recordedAt: DateTime.utc(2026, 11, 12, 9),
      details: const DocumentReferenceDetails(
        title: 'Discharge summary',
        nature: DocumentType.letter,
        date: '2025-03',
        issuer: 'City clinic',
        whereKept: 'https://example.org/folder',
      ),
      schemaVersion: 13,
    );
    expect(
      fmtValue(S(AppLang.en), r),
      'Discharge summary · letter from a doctor · dated: 2025-03 · '
      'from: City clinic · kept: https://example.org/folder',
    );
  });

  testWidgets('R014: 320 dp wide, Turkish, text ×2: the Documents screen and '
      'its sheet lay out without overflow', (tester) async {
    await boot(
      tester,
      size: const Size(320, 640),
      textScale: 2.0,
      locale: const Locale('tr'),
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('nav-bar')),
        matching: find.text('Diğer'),
      ),
    );
    await tester.pumpAndSettle();
    final item = find.descendant(
      of: find.byKey(const ValueKey('more-sheet')),
      matching: find.text('Belgeler'),
    );
    await tester.scrollUntilVisible(
      item,
      100,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('more-sheet')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(item);
    await tester.pumpAndSettle();
    await tester.tap(find.ancestor(of: item, matching: find.byType(ListTile)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('screen-documents')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('doc-add')),
      100,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('screen-documents')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const ValueKey('doc-add')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('doc-save')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
