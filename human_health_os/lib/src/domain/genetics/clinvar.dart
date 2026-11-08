/// Reads ClinVar's tab-delimited summary (variant_summary.txt[.gz] from
/// ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/) as a stream of lines,
/// keeping only the variants whose rsID is in the person's raw DNA file
/// (G004). ClinVar is produced by NCBI (a US government work). Its
/// clinical significance and review status are shown as ClinVar's words:
/// they describe submissions about a variant, not the person (D-024).
library;

import 'annotation_pack.dart' show cleanPackText;

class ClinVarRecord {
  const ClinVarRecord({
    required this.rsid,
    required this.variationId,
    this.gene = '',
    this.significance = '',
    this.reviewStatus = '',
    this.conditions = '',
    this.assembly = '',
    this.type = '',
    this.name = '',
    this.reference,
    this.alternate,
    this.chromosome = '',
    this.position = '',
  });

  final String rsid;
  final String variationId;
  final String gene;

  /// ClinVar's aggregate label, verbatim ("Pathogenic", "Benign", ...).
  final String significance;

  /// ClinVar's review status, verbatim ("criteria provided, single
  /// submitter", ...).
  final String reviewStatus;

  /// The conditions submitters named (PhenotypeList), verbatim.
  final String conditions;
  final String assembly;
  final String type;
  final String name;

  /// VCF-style alleles on the forward strand, when ClinVar gives them.
  final String? reference;
  final String? alternate;
  final String chromosome;
  final String position;
}

class ClinVarFormatError implements Exception {
  const ClinVarFormatError(this.code);

  /// `NOT_CLINVAR` (no ClinVar header line)
  final String code;

  @override
  String toString() => 'ClinVarFormatError($code)';
}

class ClinVarResult {
  const ClinVarResult({
    required this.records,
    required this.linesRead,
    required this.capped,
  });

  final List<ClinVarRecord> records;
  final int linesRead;

  /// More matches than [maxClinVarMatches] were found; the rest are not kept.
  final bool capped;
}

/// The most entries labelled only benign or likely benign that are kept;
/// every other entry is always kept.
const int maxClinVarMatches = 20000;

bool _benignOnly(String sig) {
  final parts = sig
      .toLowerCase()
      .split(RegExp(r'[/;,]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  return parts.isNotEmpty &&
      parts.every((s) => s == 'benign' || s == 'likely benign');
}

/// The RS# field of a tab-separated [line] without splitting the whole
/// line (most of ClinVar's millions of rows are not wanted).
String _field(String line, int index) {
  var start = 0;
  for (var i = 0; i < index; i++) {
    start = line.indexOf('\t', start);
    if (start < 0) return '';
    start++;
  }
  final end = line.indexOf('\t', start);
  return end < 0 ? line.substring(start) : line.substring(start, end);
}

/// Longest line read; a longer one is skipped (a file with no line breaks
/// is not a ClinVar file).
const int maxClinVarLine = 100000;

/// Streams [lines] once. [wanted] holds lower-case rsIDs ("rs123"). For a
/// variant listed for both GRCh37 and GRCh38, the GRCh37 row is kept
/// (consumer raw data files use build 37).
Future<ClinVarResult> readClinVar(
  Stream<String> lines,
  Set<String> wanted, {
  void Function(int linesRead)? progress,
}) async {
  Map<String, int>? col;
  final byKey = <String, ClinVarRecord>{};
  var read = 0;
  var capped = false;
  var benignKept = 0;
  int? rsColumn;
  await for (final raw in lines) {
    read++;
    if (progress != null && read % 100000 == 0) progress(read);
    final line = raw.endsWith('\r') ? raw.substring(0, raw.length - 1) : raw;
    if (col == null) {
      if (line.startsWith('#AlleleID') || line.startsWith('AlleleID')) {
        final names = line.replaceFirst('#', '').split('\t');
        col = {for (var i = 0; i < names.length; i++) names[i].trim(): i};
        if (!col.containsKey('RS# (dbSNP)')) {
          throw const ClinVarFormatError('NOT_CLINVAR');
        }
        rsColumn = col['RS# (dbSNP)'];
      } else if (read > 5) {
        throw const ClinVarFormatError('NOT_CLINVAR');
      }
      continue;
    }
    if (line.length > maxClinVarLine) continue;
    final rsQuick = _field(line, rsColumn!).trim();
    if (rsQuick.isEmpty || rsQuick == '-1' || !wanted.contains('rs$rsQuick')) {
      continue;
    }
    final f = line.split('\t');
    String at(String name) {
      final i = col![name];
      return i == null || i >= f.length ? '' : f[i];
    }

    final rsNumber = at('RS# (dbSNP)').trim();
    if (rsNumber.isEmpty || rsNumber == '-1') continue;
    final rsid = 'rs$rsNumber';
    if (!wanted.contains(rsid)) continue;
    final variation = at('VariationID').trim();
    final assembly = at('Assembly').trim();
    final key = '$rsid|$variation';
    final existing = byKey[key];
    if (existing != null && existing.assembly == 'GRCh37') continue;
    final benign = _benignOnly(at('ClinicalSignificance'));
    // The cap only drops entries labelled benign or likely benign.
    if (existing == null && benign && benignKept >= maxClinVarMatches) {
      capped = true;
      continue;
    }
    if (existing == null && benign) benignKept++;
    String? allele(String name) {
      final v = at(name).trim().toUpperCase();
      return v.isEmpty || v == 'NA' || v == '-' ? null : v;
    }

    byKey[key] = ClinVarRecord(
      rsid: rsid,
      variationId: variation,
      gene: cleanPackText(at('GeneSymbol'), max: 80),
      significance: cleanPackText(at('ClinicalSignificance'), max: 160),
      reviewStatus: cleanPackText(at('ReviewStatus'), max: 160),
      conditions: cleanPackText(at('PhenotypeList')),
      assembly: assembly,
      type: cleanPackText(at('Type'), max: 80),
      name: cleanPackText(at('Name')),
      reference: allele('ReferenceAlleleVCF'),
      alternate: allele('AlternateAlleleVCF'),
      chromosome: at('Chromosome').trim(),
      position: at('PositionVCF').trim(),
    );
  }
  if (col == null) throw const ClinVarFormatError('NOT_CLINVAR');
  return ClinVarResult(
    records: byKey.values.toList(),
    linesRead: read,
    capped: capped,
  );
}
