/// A consumer raw DNA file (23andMe, AncestryDNA, MyHeritage, FamilyTreeDNA)
/// read into a plain list of variants (ladder G001).
///
/// Pure Dart: no Flutter, no IO, no network. The parser only says what the
/// file contains. A position that was not read (a no-call) stays a no-call:
/// it is never "normal" and never a base. Nothing is dropped silently: every
/// unreadable line is counted and the first ones are kept with their line
/// number. It interprets nothing: no risk, no meaning of a genotype.
library;

import 'dart:convert';

/// Where a file came from, as far as its layout shows.
enum GenomeSource {
  twentyThreeAndMe('23andMe'),
  ancestryDna('AncestryDNA'),

  /// The four-column CSV used by MyHeritage and FamilyTreeDNA exports
  /// (RSID, CHROMOSOME, POSITION, RESULT); the header comments tell which.
  csv('MyHeritage / FamilyTreeDNA (CSV)');

  const GenomeSource(this.label);
  final String label;
}

/// One line of the file that was read as a variant.
class Variant {
  const Variant({
    required this.rsid,
    required this.chromosome,
    required this.position,
    required this.call,
  });

  /// The marker id as written (usually `rs…`, sometimes a vendor id).
  final String rsid;

  /// `1`…`22`, `X`, `Y`, `XY` or `MT`.
  final String chromosome;
  final int position;

  /// The genotype as written, upper case (`AG`, `A`, `DD`, `II`), or null for
  /// a no-call: the position was not read. Null is not a reference genotype.
  final String? call;

  bool get isCalled => call != null;
}

/// A line that could not be read as a variant.
class InvalidLine {
  const InvalidLine(this.lineNumber, this.reason);
  final int lineNumber;

  /// `COLUMNS` · `CHROMOSOME` · `POSITION` · `ID` · `GENOTYPE` · `PARTIAL`
  /// (only one of the two alleles was read). Never the text of the line:
  /// a genotype must not travel through an error message.
  final String reason;
}

/// Why a file was refused as a whole.
class GenomeFormatError implements Exception {
  const GenomeFormatError(this.code);

  /// `EMPTY` · `UNKNOWN_FORMAT` · `NO_VARIANTS` · `MOSTLY_INVALID` ·
  /// `COMPRESSED` · `NOT_TEXT` · `TOO_LARGE` · `VCF`
  final String code;

  @override
  String toString() => 'GenomeFormatError($code)';
}

/// The result of reading a file.
class GenomeFile {
  GenomeFile({
    required this.source,
    required this.vendorHint,
    required this.build,
    required this.headerLines,
    required this.variants,
    required this.invalidCount,
    required this.invalidSample,
    required this.duplicateCount,
  });

  final GenomeSource source;

  /// A vendor name found in the header comments (`MyHeritage`, `Family
  /// Tree DNA`, `23andMe`, `AncestryDNA`), or null.
  final String? vendorHint;

  /// The genome build the header states (`37`, `38`…), or null: the file
  /// then says nothing and the app does not guess.
  final String? build;

  /// The comment lines before the data, as typed.
  final List<String> headerLines;
  final List<Variant> variants;
  final int invalidCount;

  /// The first [maxInvalidSample] unreadable lines.
  final List<InvalidLine> invalidSample;
  final int duplicateCount;

  static const int maxInvalidSample = 20;

  int get total => variants.length;
  int get noCallCount => variants.where((v) => !v.isCalled).length;
  int get calledCount => total - noCallCount;

  /// Variants per chromosome, in the order 1–22, X, Y, XY, MT.
  Map<String, int> get perChromosome {
    final counts = <String, int>{};
    for (final v in variants) {
      counts[v.chromosome] = (counts[v.chromosome] ?? 0) + 1;
    }
    return {
      for (final c in chromosomeOrder)
        if (counts.containsKey(c)) c: counts[c]!,
    };
  }
}

const List<String> chromosomeOrder = [
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10',
  '11',
  '12',
  '13',
  '14',
  '15',
  '16',
  '17',
  '18',
  '19',
  '20',
  '21',
  '22',
  'X',
  'Y',
  'XY',
  'MT',
];

final _idPattern = RegExp(r'^[A-Za-z0-9_.:\-]{2,60}$');
final _basePattern = RegExp(r'^[ACGTDI]{1,2}$');
final _buildPattern = RegExp(
  r'(?:build|assembly|grch|hg)\s*[:=]?\s*(?:grch|hg|b)?\s*(\d{2})',
  caseSensitive: false,
);

String _stripBom(String s) =>
    s.isNotEmpty && s.codeUnitAt(0) == 0xFEFF ? s.substring(1) : s;

/// Splits one CSV line into fields, removing surrounding quotes.
List<String> _csvFields(String line) {
  final out = <String>[];
  final b = StringBuffer();
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      if (quoted && i + 1 < line.length && line[i + 1] == '"') {
        b.write('"');
        i++;
      } else {
        quoted = !quoted;
      }
    } else if (c == ',' && !quoted) {
      out.add(b.toString().trim());
      b.clear();
    } else {
      b.write(c);
    }
  }
  out.add(b.toString().trim());
  return out;
}

String? _normalizeChromosome(String raw, {required bool numericSexCodes}) {
  final c = raw.trim().toUpperCase().replaceFirst('CHR', '');
  if (c == 'M' || c == 'MT') return 'MT';
  if (c == 'X' || c == 'Y' || c == 'XY') return c;
  final n = int.tryParse(c);
  if (n == null) return null;
  if (n >= 1 && n <= 22) return '$n';
  if (numericSexCodes) {
    // AncestryDNA: 23 = X, 24 = Y, 25 = pseudo-autosomal, 26 = mitochondrial.
    return switch (n) {
      23 => 'X',
      24 => 'Y',
      25 => 'XY',
      26 => 'MT',
      _ => null,
    };
  }
  return null;
}

bool _isNoCall(String g) =>
    g.isEmpty || g == '-' || g == '--' || g == '0' || g == '00';

/// Reads [text]. Throws [GenomeFormatError] when the whole file is refused.
GenomeFile parseRawGenome(String text) {
  final body = _stripBom(text);
  if (body.trim().isEmpty) throw const GenomeFormatError('EMPTY');
  final lines = body.split('\n');
  final header = <String>[];
  GenomeSource? source;
  var dataStart = -1;
  // The first non-comment line decides the layout.
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].replaceAll('\r', '');
    final t = line.trim();
    if (t.isEmpty) continue;
    if (t.startsWith('#')) {
      header.add(line);
      continue;
    }
    final lower = t.toLowerCase().replaceAll('"', '');
    if (lower.startsWith('rsid') && lower.contains('allele1')) {
      source = GenomeSource.ancestryDna;
      dataStart = i + 1; // the column header line is not data
    } else if (lower.startsWith('rsid') && lower.contains(',')) {
      source = GenomeSource.csv;
      dataStart = i + 1;
    } else if (lower.startsWith('rsid') && lower.contains('genotype')) {
      source = GenomeSource.twentyThreeAndMe;
      dataStart = i + 1;
    } else if (t.contains('\t') && line.trimLeft().split('\t').length == 4) {
      source = GenomeSource.twentyThreeAndMe;
      dataStart = i;
    } else if (t.contains('\t') && line.trimLeft().split('\t').length == 5) {
      source = GenomeSource.ancestryDna;
      dataStart = i;
    } else if (t.contains(',') && _csvFields(t).length == 4) {
      source = GenomeSource.csv;
      dataStart = i;
    }
    break;
  }
  // 23andMe puts its column header in a comment: "# rsid chromosome ...".
  if (source == null) {
    for (final h in header) {
      final l = h.toLowerCase();
      if (l.contains('rsid') && l.contains('genotype')) {
        source = GenomeSource.twentyThreeAndMe;
      }
    }
    if (source != null) {
      for (var i = 0; i < lines.length; i++) {
        final t = lines[i].trim();
        if (t.isNotEmpty && !t.startsWith('#')) {
          dataStart = i;
          break;
        }
      }
    }
  }
  if (source == null || dataStart < 0) {
    throw const GenomeFormatError('UNKNOWN_FORMAT');
  }
  // A 23andMe file whose header is a comment keeps its layout; make sure
  // comments after the first data line are not treated as data.
  final variants = <Variant>[];
  final seen = <String>{};
  var duplicates = 0;
  var invalid = 0;
  final sample = <InvalidLine>[];
  void bad(int lineNumber, String reason) {
    invalid++;
    if (sample.length < GenomeFile.maxInvalidSample) {
      sample.add(InvalidLine(lineNumber, reason));
    }
  }

  for (var i = dataStart; i < lines.length; i++) {
    final raw = lines[i].replaceAll('\r', '');
    final t = raw.trim();
    if (t.isEmpty || t.startsWith('#')) continue;
    final lineNumber = i + 1;
    final List<String> f;
    final bool ancestry = source == GenomeSource.ancestryDna;
    if (source == GenomeSource.csv) {
      f = _csvFields(t);
    } else {
      // Not trimmed first: an empty last field is a no-call, not a missing
      // column.
      f = raw.trimLeft().split('\t').map((e) => e.trim()).toList();
    }
    final expected = ancestry ? 5 : 4;
    if (f.length != expected) {
      bad(lineNumber, 'COLUMNS');
      continue;
    }
    final id = f[0];
    if (!_idPattern.hasMatch(id)) {
      bad(lineNumber, 'ID');
      continue;
    }
    final chromosome = _normalizeChromosome(f[1], numericSexCodes: ancestry);
    if (chromosome == null) {
      bad(lineNumber, 'CHROMOSOME');
      continue;
    }
    final position = int.tryParse(f[2]);
    if (position == null || position < 0) {
      bad(lineNumber, 'POSITION');
      continue;
    }
    String? call;
    if (ancestry) {
      final a = f[3].toUpperCase();
      final b = f[4].toUpperCase();
      if (_isNoCall(a) && _isNoCall(b)) {
        call = null;
      } else if (_isNoCall(a) != _isNoCall(b)) {
        // One allele read, the other not: not a call this app can state.
        bad(lineNumber, 'PARTIAL');
        continue;
      } else if (RegExp(r'^[ACGTDI]$').hasMatch(a) &&
          RegExp(r'^[ACGTDI]$').hasMatch(b)) {
        call = '$a$b';
      } else {
        bad(lineNumber, 'GENOTYPE');
        continue;
      }
    } else {
      final g = f[3].toUpperCase();
      if (_isNoCall(g)) {
        call = null;
      } else if (_basePattern.hasMatch(g)) {
        call = g;
      } else {
        bad(lineNumber, 'GENOTYPE');
        continue;
      }
    }
    if (!seen.add(id)) duplicates++;
    variants.add(
      Variant(rsid: id, chromosome: chromosome, position: position, call: call),
    );
  }
  if (variants.isEmpty) throw const GenomeFormatError('NO_VARIANTS');
  // A file that is mostly unreadable was not in the layout it seemed to be:
  // refuse it instead of loading a few lines and hiding the rest.
  if (invalid * 5 > variants.length + invalid) {
    throw const GenomeFormatError('MOSTLY_INVALID');
  }
  final headerText = header.join('\n');
  String? hint;
  final lowerHeader = headerText.toLowerCase();
  if (lowerHeader.contains('myheritage')) {
    hint = 'MyHeritage';
  } else if (lowerHeader.contains('family tree') ||
      lowerHeader.contains('familytree') ||
      lowerHeader.contains('ftdna')) {
    hint = 'FamilyTreeDNA';
  } else if (lowerHeader.contains('23andme')) {
    hint = '23andMe';
  } else if (lowerHeader.contains('ancestry')) {
    hint = 'AncestryDNA';
  }
  final m = _buildPattern.firstMatch(headerText);
  return GenomeFile(
    source: source,
    vendorHint: hint,
    build: m?[1],
    headerLines: header,
    variants: variants,
    invalidCount: invalid,
    invalidSample: sample,
    duplicateCount: duplicates,
  );
}

/// Biggest file read (bytes). A real raw file is 15-30 MB.
const int maxRawGenomeBytes = 200 * 1024 * 1024;

/// Reads a file from its bytes. The extension is not trusted: archives,
/// UTF-16 text, VCF and oversized files are refused with a code before any
/// parsing, and text is decoded as UTF-8 (malformed bytes become U+FFFD and
/// then fail as unreadable lines, never as a different genotype).
GenomeFile parseRawGenomeBytes(List<int> bytes) {
  if (bytes.isEmpty) throw const GenomeFormatError('EMPTY');
  if (bytes.length > maxRawGenomeBytes) {
    throw const GenomeFormatError('TOO_LARGE');
  }
  if (bytes.length >= 2) {
    final a = bytes[0];
    final b = bytes[1];
    if ((a == 0x1F && b == 0x8B) || // gzip
        (a == 0x50 && b == 0x4B) || // zip
        (a == 0x42 && b == 0x5A) || // bzip2
        (a == 0x37 && b == 0x7A)) {
      throw const GenomeFormatError('COMPRESSED');
    }
    if ((a == 0xFF && b == 0xFE) || (a == 0xFE && b == 0xFF)) {
      throw const GenomeFormatError('NOT_TEXT'); // UTF-16
    }
  }
  final head = String.fromCharCodes(bytes.take(64).where((c) => c < 128));
  if (head.toLowerCase().startsWith('##fileformat=vcf')) {
    throw const GenomeFormatError('VCF');
  }
  // NUL bytes in the first kilobyte: not text.
  if (bytes.take(1024).any((c) => c == 0)) {
    throw const GenomeFormatError('NOT_TEXT');
  }
  return parseRawGenome(utf8.decode(bytes, allowMalformed: true));
}
