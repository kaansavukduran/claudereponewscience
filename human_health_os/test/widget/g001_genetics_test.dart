// G001: the Genetics screen. A fake chooser stands in for the native dialog.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/genetics/raw_genome.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/features/genetics/genome_file_picker.dart';
import 'package:human_health_os/src/l10n/strings.dart';

const dev = AppConfig(
  profile: BuildProfile.development,
  version: 't',
  sourceRevision: 't',
);

/// Hands out the files it is given, one per pick, and counts releases.
class FakePicker implements GenomeFilePicker {
  FakePicker(this.files);
  final List<(String, List<int>)?> files;
  int picks = 0;
  int releases = 0;

  @override
  Future<PickedGenomeFile?> pick({required String title}) async {
    final f = files[picks++ % files.length];
    if (f == null) return null;
    return PickedGenomeFile(
      name: f.$1,
      read: () async => Uint8List.fromList(f.$2),
    );
  }

  @override
  Future<void> release() async => releases++;
}

GenomeFile parseSync(Uint8List b) => parseRawGenomeBytes(b);

String variantsFile(int n) {
  final b = StringBuffer('# rsid\tchromosome\tposition\tgenotype\n');
  for (var i = 0; i < n; i++) {
    b.writeln(
      'rs${100000 + i}\t${(i % 22) + 1}\t${i + 1}\t${i % 7 == 0 ? '--' : 'AG'}',
    );
  }
  return b.toString();
}

Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 30)),
  );
  await tester.pumpAndSettle();
}

Future<FakePicker> open(
  WidgetTester tester,
  FakePicker picker, {
  Size size = const Size(1280, 3000),
  double textScale = 1.0,
  Locale? locale,
  bool stayOnToday = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  if (locale != null) {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }
  final s = await tester.runAsync(() async {
    final repo = LogRepository(
      sink: MemoryLogSink(),
      durability: StorageDurability.localFile,
      location: 'test',
    );
    final report = await repo.open();
    return servicesFor(
      dev,
      HostPlatform.linux,
      repo,
      report: report,
      genomePicker: picker,
    );
  });
  await tester.pumpWidget(HumanOsApp(services: s!));
  await settle(tester);
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('tool-genetics')),
    300,
    scrollable: find
        .descendant(
          of: find.byKey(const ValueKey('screen-today')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.ensureVisible(find.byKey(const ValueKey('tool-genetics')));
  await tester.pumpAndSettle();
  // Lift it clear of the bottom bar before tapping.
  await tester.drag(
    find.byKey(const ValueKey('screen-today')),
    const Offset(0, -150),
  );
  await tester.pumpAndSettle();
  if (stayOnToday) return picker;
  await tester.tap(find.byKey(const ValueKey('tool-genetics')));
  await settle(tester);
  return picker;
}

/// Scrolls the lazy page until the [finder] is built and on screen.
Future<void> reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('screen-genetics')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  if (f.evaluate().isEmpty) {
    // The page is a lazy list: go to the top, then scroll until the control
    // is built.
    await tester.drag(
      find.byKey(const ValueKey('screen-genetics')),
      const Offset(0, 100000),
    );
    await tester.pumpAndSettle();
    if (f.evaluate().isNotEmpty) {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await settle(tester);
      return;
    }
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('screen-genetics')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  expect(f, findsOneWidget, reason: 'the control $key is on screen');
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await settle(tester);
}

void main() {
  testWidgets('the screen opens from Today with the mouse, says what it does '
      'and what to know before a file is loaded', (tester) async {
    await open(tester, FakePicker([null]));
    expect(find.byKey(const ValueKey('screen-genetics')), findsOneWidget);
    expect(find.byKey(const ValueKey('genetics-notice')), findsOneWidget);
    expect(find.textContaining('identifies you for life'), findsOneWidget);
    expect(find.textContaining('relatives'), findsOneWidget);
    expect(find.textContaining('does not save the file'), findsOneWidget);
    expect(find.textContaining('not a medical result'), findsOneWidget);
    expect(find.byKey(const ValueKey('genetics-choose')), findsOneWidget);
    expect(find.byKey(const ValueKey('genetics-sample')), findsOneWidget);
    expect(find.byKey(const ValueKey('genetics-clear')), findsNothing);
  });

  testWidgets('choosing a file shows its summary and variants; the chooser '
      'is released after the read; cancelling changes nothing', (tester) async {
    final picker = FakePicker([
      ('my-dna.txt', utf8.encode(variantsFile(120))),
      null,
    ]);
    await open(tester, picker);
    await tap(tester, 'genetics-choose');
    expect(picker.releases, 1, reason: 'no cached copy is left behind');
    expect(find.text('Read from my-dna.txt'), findsOneWidget);
    expect(find.textContaining('Variants in the file: 120'), findsOneWidget);
    expect(find.textContaining('No call: 18'), findsOneWidget);
    expect(
      find.textContaining('Genome build: not stated in the file'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('genetics-notice')), findsNothing);
    expect(find.textContaining('Not saved by Human OS'), findsOneWidget);
    expect(find.byKey(const ValueKey('variant-rs100001-2')), findsOneWidget);
    expect(find.text('no call'), findsWidgets);
    await tap(tester, 'genetics-choose'); // cancelled
    expect(find.text('Read from my-dna.txt'), findsOneWidget);
  });

  testWidgets('search, paging and Clear', (tester) async {
    await open(tester, FakePicker([('f.txt', utf8.encode(variantsFile(120)))]));
    await tap(tester, 'genetics-choose');
    await reveal(tester, find.text('1–50 of 120'));
    expect(find.text('1–50 of 120'), findsOneWidget);
    await tap(tester, 'genetics-next');
    await reveal(tester, find.text('51–100 of 120'));
    expect(find.text('51–100 of 120'), findsOneWidget);
    await tap(tester, 'genetics-next');
    await reveal(tester, find.text('101–120 of 120'));
    expect(find.text('101–120 of 120'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.byKey(const ValueKey('genetics-next')))
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.byKey(const ValueKey('genetics-search')),
      'rs100005',
    );
    await settle(tester);
    await reveal(tester, find.text('1–1 of 1'));
    expect(find.text('1–1 of 1'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('genetics-search')), '3');
    await settle(tester);
    expect(find.textContaining('of '), findsWidgets);
    await tester.enterText(
      find.byKey(const ValueKey('genetics-search')),
      'zzz',
    );
    await settle(tester);
    expect(find.byKey(const ValueKey('genetics-no-matches')), findsOneWidget);
    await tap(tester, 'genetics-clear');
    expect(find.byKey(const ValueKey('genetics-summary')), findsNothing);
    expect(find.byKey(const ValueKey('genetics-notice')), findsOneWidget);
    expect(find.byKey(const ValueKey('genetics-clear')), findsNothing);
  });

  testWidgets('a refused file says why, and keeps the file that was loaded', (
    tester,
  ) async {
    await open(
      tester,
      FakePicker([
        ('good.txt', utf8.encode(variantsFile(10))),
        ('notes.txt', utf8.encode('hello this is not dna')),
        ('x.zip', [0x50, 0x4B, 3, 4, 0]),
        ('a.vcf', utf8.encode('##fileformat=VCFv4.2\n#CHROM')),
      ]),
    );
    await tap(tester, 'genetics-choose');
    expect(find.text('Read from good.txt'), findsOneWidget);
    await tap(tester, 'genetics-choose');
    expect(
      find.textContaining('does not look like a raw data file'),
      findsOneWidget,
    );
    expect(find.text('Read from good.txt'), findsOneWidget, reason: 'kept');
    await tap(tester, 'genetics-choose');
    expect(find.textContaining('compressed file'), findsOneWidget);
    await tap(tester, 'genetics-choose');
    expect(find.textContaining('VCF files are not supported'), findsOneWidget);
    expect(find.text('Read from good.txt'), findsOneWidget);
  });

  testWidgets('the invented sample comes with an invented pack: statements '
      'verbatim with their source, strand and build notes, nothing judged', (
    tester,
  ) async {
    await open(tester, FakePicker([null]));
    await tap(tester, 'genetics-sample');
    expect(
      find.text('Invented sample file: not a real person'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('genetics-pack-synthetic')),
      findsOneWidget,
    );
    expect(find.textContaining('INVENTED demonstration pack'), findsOneWidget);
    expect(find.textContaining('not a diagnosis'), findsOneWidget);
    expect(find.textContaining('Licence:'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('match-rs9000001-100001')),
      findsOneWidget,
    );
    expect(find.textContaining('The file lists allele'), findsNWidgets(2));
    expect(find.textContaining('The file lists no '), findsWidgets);
    expect(
      find.textContaining('says nothing about other positions'),
      findsWidgets,
    );
    expect(find.textContaining('No call at this position'), findsOneWidget);
    expect(
      find.textContaining('Cannot be told apart by strand'),
      findsOneWidget,
    );
    expect(find.textContaining('Build 37 in both'), findsWidgets);
    expect(
      find.textContaining('rs9000099'),
      findsNothing,
      reason: 'an entry for a variant the file lacks is not mentioned',
    );
  });

  testWidgets('a pack file is read with its header; a bad one is refused', (
    tester,
  ) async {
    const pack =
        '#name: Mine\n#licence: mine\n#build: 37\n#strand: plus\n'
        'rsid\tgene\tallele\tstatement\tsource\tsource_id\tsource_date\tevidence\n'
        'rs9000001\tG1\tA\tsays something\tSrc\tID\t2026\t\n';
    final picker = FakePicker([
      ('pack.tsv', utf8.encode(pack)),
      ('bad.tsv', utf8.encode('#name: x\nrsid\tgene\n')),
    ]);
    await open(tester, picker);
    await tap(tester, 'genetics-sample');
    await tap(tester, 'genetics-pack-load');
    expect(find.text('Mine'), findsOneWidget);
    expect(find.textContaining('“says something”'), findsOneWidget);
    expect(find.byKey(const ValueKey('genetics-pack-synthetic')), findsNothing);
    await tap(tester, 'genetics-pack-load');
    expect(
      find.textContaining('must state its name, licence, build and strand'),
      findsOneWidget,
    );
    expect(find.text('Mine'), findsOneWidget, reason: 'the pack stays');
  });

  testWidgets('nothing the screen does writes to the console: no id, '
      'genotype or file name reaches debugPrint', (tester) async {
    final printed = <String>[];
    final original = debugPrint;
    debugPrint = (String? m, {int? wrapWidth}) => printed.add(m ?? '');
    try {
      await open(
        tester,
        FakePicker([('secret-name.txt', utf8.encode(variantsFile(30)))]),
      );
      await tap(tester, 'genetics-choose');
      await tester.enterText(
        find.byKey(const ValueKey('genetics-search')),
        'rs100',
      );
      await settle(tester);
      await tap(tester, 'genetics-sample');
      await tap(tester, 'genetics-clear');
    } finally {
      debugPrint = original; // the binding checks this before tear-downs
    }
    final all = printed.join('\n');
    for (final needle in ['rs100', 'rs9000', 'secret-name', 'AG']) {
      expect(all, isNot(contains(needle)), reason: needle);
    }
  });

  testWidgets('320 dp wide at 2x text, EN and TR: no overflow', (tester) async {
    for (final locale in [const Locale('en'), const Locale('tr')]) {
      await tester.pumpWidget(const SizedBox());
      await open(
        tester,
        FakePicker([('f.txt', utf8.encode(variantsFile(60)))]),
        size: const Size(320, 3000),
        textScale: 2.0,
        locale: locale,
      );
      await tap(tester, 'genetics-sample');
      await tap(tester, 'genetics-choose');
      expect(tester.takeException(), isNull, reason: '$locale');
    }
  });

  test('every string of the screen judges nothing, in both languages', () {
    final judging = RegExp(
      r'(?<!\p{L})(risk\p{L}*|carrier\p{L}*|mutation\p{L}*|pathogenic|benign|'
      r'normal|abnormal|wild-type|protective|harmful|positive|negative|healthy|'
      r'at risk|predispos\p{L}*|riskli|taşıyıcı|mutasyon\p{L}*|normal|anormal|'
      r'sağlıklı|koruyucu|zararlı|pozitif|negatif)(?!\p{L})',
      caseSensitive: false,
      unicode: true,
    );
    for (final lang in AppLang.values) {
      final s = S(lang);
      final texts = [
        s.geneticsTitle,
        s.geneticsToolsTitle,
        s.geneticsTileHint,
        s.geneticsIntro,
        s.geneticsNoticeTitle,
        ...s.geneticsNotices,
        s.geneticsNoMatches,
        s.geneticsSearchHint,
        s.geneticsPackLoad,
        s.geneticsPackLicence,
        s.geneticsPackSource,
        s.geneticsLoadedFrom('f.txt'),
        s.geneticsSampleLoaded,
        s.geneticsReading,
        s.geneticsChromosomes,
        s.geneticsNotReadShort,
        s.geneticsNotRead,
        s.geneticsRead,
        s.geneticsRowSpoken('rs1', '1', 5, 'AG'),
        s.geneticsInvalidLine(3, s.geneticsInvalidReason('PARTIAL')),
        s.geneticsUnreadableLines,
        s.geneticsChoose,
        s.geneticsSample,
        s.geneticsKeptOnly,
        s.geneticsPackTitle,
        s.geneticsPackNote,
        s.geneticsPackSynthetic,
        s.geneticsPackNone,
        for (final c in [
          'EMPTY',
          'UNKNOWN_FORMAT',
          'NO_VARIANTS',
          'MOSTLY_INVALID',
          'COMPRESSED',
          'NOT_TEXT',
          'TOO_LARGE',
          'VCF',
          'X',
        ])
          s.geneticsRefusal(c),
        for (final c in ['EMPTY', 'HEADER', 'STRAND', 'NO_ROWS', 'X'])
          s.geneticsPackRefusal(c),
        for (final k in [
          'containsAllele',
          'doesNotMatch',
          'notRead',
          'strandUndecidable',
          'notComparable',
        ])
          s.geneticsMatchKind(k),
        for (final n in ['same', 'differs', 'fileNotStated'])
          s.geneticsBuildNote(n, '37'),
        for (final r in [
          'COLUMNS',
          'CHROMOSOME',
          'POSITION',
          'ID',
          'GENOTYPE',
          'PARTIAL',
        ])
          s.geneticsInvalidReason(r),
      ];
      for (final t in texts) {
        expect(judging.firstMatch(t)?.group(0), isNull, reason: '$lang "$t"');
      }
    }
  });

  testWidgets('"chr" and "chromosome" prefixes search a chromosome; the empty '
      'state says what works', (tester) async {
    await open(tester, FakePicker([null]));
    await tap(tester, 'genetics-sample');
    for (final q in ['chrX', 'CHR X', 'chromosome x', 'X']) {
      await tester.enterText(find.byKey(const ValueKey('genetics-search')), q);
      await settle(tester);
      await reveal(tester, find.byKey(const ValueKey('genetics-range')));
      expect(find.text('1–1 of 1'), findsOneWidget, reason: q);
    }
    await tester.enterText(
      find.byKey(const ValueKey('genetics-search')),
      'chr99',
    );
    await settle(tester);
    await reveal(tester, find.byKey(const ValueKey('genetics-no-matches')));
    expect(find.textContaining('part of an rsID'), findsOneWidget);
  });

  testWidgets('a match card names the allele the entry states', (tester) async {
    await open(tester, FakePicker([null]));
    await tap(tester, 'genetics-sample');
    final card = find.byKey(const ValueKey('match-rs9000001-100001'));
    await reveal(tester, card);
    expect(
      find.descendant(
        of: card,
        matching: find.text('The file lists allele G at this position'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a variant row is spoken in the app language, not English', (
    tester,
  ) async {
    await open(tester, FakePicker([null]), locale: const Locale('tr'));
    await tap(tester, 'genetics-sample');
    final row = find.byKey(const ValueKey('variant-rs9000001-100001'));
    await reveal(tester, row);
    final handle = tester.ensureSemantics();
    expect(
      find.bySemanticsLabel('rs9000001, kromozom 1, konum 100001, A, G'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('the Genetics tile on Today is a button for assistive '
      'technology, named by its title', (tester) async {
    final handle = tester.ensureSemantics();
    await open(tester, FakePicker([null]), stayOnToday: true);
    final node = tester.getSemantics(
      find.descendant(
        of: find.byKey(const ValueKey('tool-genetics')),
        matching: find.byType(InkWell),
      ),
    );
    expect(node.flagsCollection.isButton, isTrue);
    expect(node.label, contains('Genetics'));
    handle.dispose();
  });
}
