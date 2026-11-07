/// Reads a dbSNP "Summary" text file (ncbi.nlm.nih.gov/snp → Send to → File →
/// Format: Summary) offline (G002). dbSNP is produced by NCBI (a US
/// government work); its fields are shown as dbSNP states them, with the
/// source named. Human OS adds no prediction of its own: a "clinical
/// significance" is dbSNP's label for a variant, not a statement about the
/// person who carries it.
library;

import 'annotation_pack.dart' show cleanPackText;

class DbSnpVariant {
  const DbSnpVariant({
    required this.rsid,
    this.variantType,
    this.reference,
    this.alternates = const [],
    this.positions = const [],
    this.genes = const [],
    this.consequences = const [],
    this.clinical = const [],
    this.validated,
  });

  final String rsid;
  final String? variantType;

  /// The reference allele and the alternate alleles as dbSNP lists them
  /// ("G>A,C,T" gives G and [A, C, T]), on the forward strand.
  final String? reference;
  final List<String> alternates;

  /// "15:26773789 (GRCh38)" style positions, as typed.
  final List<String> positions;
  final List<String> genes;

  /// Sequence Ontology terms (missense_variant, intron_variant…).
  final List<String> consequences;

  /// dbSNP's clinical significance labels, verbatim.
  final List<String> clinical;
  final String? validated;

  /// True when dbSNP lists the variant as changing an amino acid.
  bool get isMissense =>
      consequences.any((c) => c.toLowerCase().contains('missense'));

  bool get hasClinical => clinical.any(
    (c) => c.isNotEmpty && !c.toLowerCase().contains('not provided'),
  );
}

class DbSnpFormatError implements Exception {
  const DbSnpFormatError(this.code);

  /// `EMPTY` · `NOT_SUMMARY`
  final String code;

  @override
  String toString() => 'DbSnpFormatError($code)';
}

final _entryStart = RegExp(r'^\s*\d+\.\s+(rs\d+)\b', caseSensitive: false);
final _keyValue = RegExp(r'^\s*([A-Za-z][A-Za-z /()_-]{1,40}):\s*(.*)$');
final _base = RegExp(r'^[ACGT]+$');

List<String> _list(String v) => [
  for (final p in v.split(','))
    if (cleanPackText(p, max: 120).isNotEmpty) cleanPackText(p, max: 120),
];

/// Every entry of the file. Unknown keys are ignored; a line without a key
/// continues the previous key (dbSNP prints a second position on its own
/// line).
List<DbSnpVariant> parseDbSnpSummary(String text) {
  if (text.trim().isEmpty) throw const DbSnpFormatError('EMPTY');
  final out = <DbSnpVariant>[];
  String? rsid;
  var fields = <String, List<String>>{};
  String? lastKey;

  void finish() {
    final id = rsid;
    if (id == null) return;
    String? first(String k) {
      final v = fields[k];
      return v == null || v.isEmpty ? null : v.first;
    }

    String? reference;
    var alternates = <String>[];
    final alleles = first('alleles');
    if (alleles != null) {
      final cleaned = alleles.replaceAll(RegExp(r'\[.*?\]'), '').trim();
      final parts = cleaned.split('>');
      if (parts.length == 2) {
        final ref = parts[0].trim().toUpperCase();
        reference = ref.isEmpty ? null : ref;
        alternates = [
          for (final a in parts[1].split(','))
            if (a.trim().isNotEmpty) a.trim().toUpperCase(),
        ];
      }
    }
    out.add(
      DbSnpVariant(
        rsid: id.toLowerCase(),
        variantType: first('variant type'),
        reference: reference,
        alternates: alternates,
        positions: [
          for (final p in fields['chromosome'] ?? const <String>[])
            ...p.split(RegExp(r'\s{2,}')).where((x) => x.trim().isNotEmpty),
        ],
        genes: [
          for (final g in _list(first('gene') ?? ''))
            g.replaceAll(RegExp(r'\s*\(.*?\)'), '').trim(),
        ].where((g) => g.isNotEmpty).toList(),
        consequences: _list((fields['functional consequence'] ?? []).join(',')),
        clinical: _list((fields['clinical significance'] ?? []).join(',')),
        validated: first('validated'),
      ),
    );
  }

  for (final raw in text.split(RegExp(r'\r?\n'))) {
    final line = raw.trimRight();
    final start = _entryStart.firstMatch(line);
    if (start != null) {
      finish();
      rsid = start[1];
      fields = {};
      lastKey = null;
      continue;
    }
    if (rsid == null || line.trim().isEmpty) continue;
    final kv = _keyValue.firstMatch(line);
    if (kv != null) {
      lastKey = kv[1]!.trim().toLowerCase();
      fields.putIfAbsent(lastKey, () => []).add(cleanPackText(kv[2]!));
    } else if (lastKey != null) {
      fields[lastKey]!.add(cleanPackText(line.trim()));
    }
  }
  finish();
  if (out.isEmpty) throw const DbSnpFormatError('NOT_SUMMARY');
  return out;
}

/// How a person's genotype relates to dbSNP's alleles at one variant.
enum DbSnpCall {
  /// The genotype lists one or more of dbSNP's alternate alleles.
  listsAlternate,

  /// The genotype lists only the reference allele.
  referenceOnly,

  /// The file has no call here.
  noCall,

  /// The alleles cannot be compared (an indel, a multi-base allele, or A/T
  /// and C/G pairs whose strand cannot be told apart).
  notComparable,
}

class DbSnpMatch {
  const DbSnpMatch({
    required this.variant,
    required this.genotype,
    required this.call,
    required this.alternatesListed,
  });

  final DbSnpVariant variant;
  final String? genotype;
  final DbSnpCall call;

  /// Which of dbSNP's alternate alleles the genotype lists.
  final List<String> alternatesListed;
}

/// Compares a genotype (plus strand, as consumer files report it) with
/// dbSNP's alleles (forward strand). Nothing is inferred beyond which
/// letters appear.
DbSnpMatch compareWithDbSnp(DbSnpVariant v, String? genotype) {
  if (genotype == null) {
    return DbSnpMatch(
      variant: v,
      genotype: null,
      call: DbSnpCall.noCall,
      alternatesListed: const [],
    );
  }
  final ref = v.reference;
  final single = [
    ?ref,
    ...v.alternates,
  ].every((a) => a.length == 1 && _base.hasMatch(a));
  final g = genotype.toUpperCase();
  if (ref == null || !single || !_base.hasMatch(g)) {
    return DbSnpMatch(
      variant: v,
      genotype: genotype,
      call: DbSnpCall.notComparable,
      alternatesListed: const [],
    );
  }
  // A/T or C/G only: the other strand reads the same letters swapped.
  final letters = {ref, ...v.alternates};
  if (letters.length == 2 &&
      (letters.containsAll({'A', 'T'}) || letters.containsAll({'C', 'G'}))) {
    return DbSnpMatch(
      variant: v,
      genotype: genotype,
      call: DbSnpCall.notComparable,
      alternatesListed: const [],
    );
  }
  final listed = [
    for (final a in v.alternates)
      if (g.contains(a)) a,
  ];
  return DbSnpMatch(
    variant: v,
    genotype: genotype,
    call: listed.isNotEmpty
        ? DbSnpCall.listsAlternate
        : DbSnpCall.referenceOnly,
    alternatesListed: listed,
  );
}
