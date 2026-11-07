/// A local annotation pack and the matches it gives for a raw genome (G001).
///
/// A pack is a plain tab-separated file whose header says where the data
/// comes from (name, licence, genome build, strand). Rows state an
/// association exactly as their source states it; this code never turns it
/// into a meaning for the person: no risk, no carrier status, no copy count,
/// no "normal". A genotype is compared with the allele named by the source
/// only on the strand and build the pack declares; a variant whose strand
/// cannot be told apart (A/T, C/G) is never matched.
library;

import 'raw_genome.dart';

/// Why a pack was refused as a whole.
class PackFormatError implements Exception {
  const PackFormatError(this.code);

  /// `EMPTY` · `HEADER` (a required header line is missing) · `STRAND`
  /// (not the plus strand) · `NO_ROWS`
  final String code;

  @override
  String toString() => 'PackFormatError($code)';
}

/// One statement of a source about one variant and one allele.
class PackEntry {
  const PackEntry({
    required this.rsid,
    required this.gene,
    required this.allele,
    required this.statement,
    required this.source,
    required this.sourceId,
    required this.sourceDate,
    required this.evidence,
  });

  final String rsid;
  final String gene;

  /// The allele the source names, on the pack's strand.
  final String allele;

  /// What the source says, verbatim.
  final String statement;
  final String source;
  final String sourceId;
  final String sourceDate;

  /// The evidence or review level as the source gives it; empty when it
  /// does not.
  final String evidence;
}

class AnnotationPack {
  AnnotationPack({
    required this.name,
    required this.licence,
    required this.build,
    required this.synthetic,
    required this.entries,
    required this.invalidCount,
  });

  final String name;
  final String licence;

  /// The genome build of the positions and strand of the alleles, `37`.
  final String build;

  /// True for a pack of invented data (a demonstration); never real
  /// knowledge.
  final bool synthetic;
  final List<PackEntry> entries;
  final int invalidCount;
}

final _bases = RegExp(r'^[ACGT]$');

// Control characters and the invisible direction marks that can reorder or
// hide text (bidi embeddings and isolates, zero-width marks, BOM).
final _hiddenChars = RegExp(
  r'[\u0000-\u001F\u007F-\u009F\u061C\u200B-\u200F\u2028-\u202E\u2060-\u206F\uFEFF\u00AD\u034F\u180E\uFE00-\uFE0F\uFFF9-\uFFFC\u{E0000}-\u{E007F}]',
  unicode: true,
);

/// Longest text a pack may show for one field; longer text is cut with "…".
const int maxPackFieldChars = 400;

/// Text from a pack as it may be shown: hidden characters removed, length
/// capped. A pack is a file from anywhere, so its words are data to display
/// safely, never layout.
String cleanPackText(String s, {int max = maxPackFieldChars}) {
  final t = s.replaceAll(_hiddenChars, '').trim();
  final runes = t.runes.toList();
  if (runes.length <= max) return t;
  return '${String.fromCharCodes(runes.take(max - 1))}…';
}

/// Reads a pack. Required header lines: `#name:`, `#licence:`, `#build:`,
/// `#strand: plus`. Optional `#synthetic: yes`.
AnnotationPack parsePack(String text) {
  if (text.trim().isEmpty) throw const PackFormatError('EMPTY');
  final header = <String, String>{};
  final entries = <PackEntry>[];
  var invalid = 0;
  var sawColumns = false;
  for (final raw in text.split('\n')) {
    final line = raw.replaceAll('\r', '');
    final t = line.trim();
    if (t.isEmpty) continue;
    if (t.startsWith('#')) {
      final i = t.indexOf(':');
      if (i > 0) {
        header[t.substring(1, i).trim().toLowerCase()] = cleanPackText(
          t.substring(i + 1),
          max: 120,
        );
      }
      continue;
    }
    if (!sawColumns) {
      sawColumns = true; // the column header line
      if (!t.toLowerCase().startsWith('rsid')) {
        throw const PackFormatError('HEADER');
      }
      continue;
    }
    final f = line.split('\t').map(cleanPackText).toList();
    if (f.length != 8 ||
        f[0].isEmpty ||
        !_bases.hasMatch(f[2].toUpperCase()) ||
        f[3].isEmpty ||
        f[4].isEmpty) {
      invalid++;
      continue;
    }
    entries.add(
      PackEntry(
        rsid: f[0],
        gene: f[1],
        allele: f[2].toUpperCase(),
        statement: f[3],
        source: f[4],
        sourceId: f[5],
        sourceDate: f[6],
        evidence: f[7],
      ),
    );
  }
  for (final k in ['name', 'licence', 'build', 'strand']) {
    if ((header[k] ?? '').isEmpty) throw const PackFormatError('HEADER');
  }
  if (header['strand']!.toLowerCase() != 'plus') {
    throw const PackFormatError('STRAND');
  }
  if (entries.isEmpty) throw const PackFormatError('NO_ROWS');
  return AnnotationPack(
    name: header['name']!,
    licence: header['licence']!,
    // A known build is kept as 36/37/38 so that GRCh37, hg19 and 37 compare
    // equal; any other text is kept as typed and never equals a file's build.
    build:
        normalizeBuild(header['build']!, wholeText: true) ?? header['build']!,
    synthetic: (header['synthetic'] ?? '').toLowerCase() == 'yes',
    entries: entries,
    invalidCount: invalid,
  );
}

/// How a person's genotype relates to the allele a source names.
enum MatchKind {
  /// The genotype contains the allele the source names.
  containsAllele,

  /// The genotype does not contain it: the entry does not match.
  doesNotMatch,

  /// The position was not read in the file.
  notRead,

  /// A/T or C/G: the strand cannot be told apart, so nothing is claimed.
  strandUndecidable,

  /// The call is an insertion or deletion (I, D): not comparable to a base.
  notComparable,
}

class PackMatch {
  const PackMatch({
    required this.entry,
    required this.variant,
    required this.kind,
    required this.buildNote,
  });

  final PackEntry entry;
  final Variant variant;
  final MatchKind kind;

  /// `same` (file and pack state the same build), `fileNotStated` or
  /// `differs`.
  final String buildNote;
}

bool _palindromic(String a, String b) =>
    (a == 'A' && b == 'T') ||
    (a == 'T' && b == 'A') ||
    (a == 'C' && b == 'G') ||
    (a == 'G' && b == 'C');

/// Entries of [pack] that name a variant present in [genome], in the order
/// of the pack. A variant that is absent from the file, or an entry for a
/// variant the file does not have, is not mentioned. Every variant with the
/// same id is reported (a duplicate is not silently picked).
List<PackMatch> matchPack(GenomeFile genome, AnnotationPack pack) {
  final byId = <String, List<Variant>>{};
  for (final v in genome.variants) {
    byId.putIfAbsent(v.rsid.toLowerCase(), () => []).add(v);
  }
  final buildNote = genome.build == null
      ? 'fileNotStated'
      : (genome.build == pack.build ? 'same' : 'differs');
  final out = <PackMatch>[];
  for (final e in pack.entries) {
    final vs = byId[e.rsid.toLowerCase()];
    if (vs == null) continue;
    for (final v in vs) {
      final MatchKind kind;
      final call = v.call;
      if (call == null) {
        kind = MatchKind.notRead;
      } else if (call.contains('D') || call.contains('I')) {
        kind = MatchKind.notComparable;
      } else if (_undecidable(call, e.allele)) {
        kind = MatchKind.strandUndecidable;
      } else {
        kind = call.contains(e.allele)
            ? MatchKind.containsAllele
            : MatchKind.doesNotMatch;
      }
      out.add(
        PackMatch(entry: e, variant: v, kind: kind, buildNote: buildNote),
      );
    }
  }
  return out;
}

/// The entry's allele and the genotype's letters are the two bases of one
/// A/T or C/G pair only: a file on the other strand would read the same.
bool _undecidable(String call, String allele) {
  final pair = {...call.split(''), allele};
  return pair.length == 2 && _palindromic(pair.first, pair.last);
}
