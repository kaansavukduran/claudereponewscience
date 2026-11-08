/// Reads a table exported from Dr. Duke's Phytochemical and Ethnobotanical
/// Databases (phytochem.nal.usda.gov → Download these results as CSV),
/// offline (G003). The database is a US government work (USDA ARS). Every
/// cell is shown as the source wrote it; doses carry the species and route
/// the source gives and are never turned into a dose for a person.
library;

import '../genetics/annotation_pack.dart' show cleanPackText;

class PhytoTable {
  const PhytoTable({
    required this.headers,
    required this.rows,
    required this.skipped,
  });

  final List<String> headers;
  final List<List<String>> rows;

  /// Lines that did not have the header's number of columns.
  final int skipped;

  int? column(String containing) {
    for (var i = 0; i < headers.length; i++) {
      if (headers[i].toLowerCase().contains(containing)) return i;
    }
    return null;
  }
}

class PhytoFormatError implements Exception {
  const PhytoFormatError(this.code);

  /// `EMPTY` · `XLSX` · `NOT_TABLE` · `TOO_LARGE`
  final String code;

  @override
  String toString() => 'PhytoFormatError($code)';
}

const int maxPhytoBytes = 50 * 1024 * 1024;

/// CSV fields of one record; quoted fields may hold commas, doubled quotes
/// and line breaks.
List<List<String>> _records(String text) {
  final out = <List<String>>[];
  var row = <String>[];
  final b = StringBuffer();
  var quoted = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (c == '"') {
      // RFC 4180: a quote opens a quoted field only at its start; inside an
      // unquoted field it is an ordinary character (5" rod).
      if (quoted && i + 1 < text.length && text[i + 1] == '"') {
        b.write('"');
        i++;
      } else if (quoted) {
        quoted = false;
      } else if (b.isEmpty) {
        quoted = true;
      } else {
        b.write(c);
      }
    } else if (c == ',' && !quoted) {
      row.add(b.toString());
      b.clear();
    } else if ((c == '\n' || c == '\r') && !quoted) {
      if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(b.toString());
      b.clear();
      if (row.any((f) => f.trim().isNotEmpty)) out.add(row);
      row = <String>[];
    } else {
      b.write(c);
    }
  }
  row.add(b.toString());
  if (row.any((f) => f.trim().isNotEmpty)) out.add(row);
  return out;
}

PhytoTable parsePhytoBytes(List<int> bytes, String Function(List<int>) decode) {
  if (bytes.isEmpty) throw const PhytoFormatError('EMPTY');
  if (bytes.length > maxPhytoBytes) throw const PhytoFormatError('TOO_LARGE');
  if (bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B) {
    // A ZIP container: an .xlsx workbook. Save it as CSV instead.
    throw const PhytoFormatError('XLSX');
  }
  return parsePhytoCsv(decode(bytes));
}

PhytoTable parsePhytoCsv(String text) {
  final body = text.isNotEmpty && text.codeUnitAt(0) == 0xFEFF
      ? text.substring(1)
      : text;
  if (body.trim().isEmpty) throw const PhytoFormatError('EMPTY');
  final recs = _records(body);
  if (recs.length < 2 || recs.first.length < 2) {
    throw const PhytoFormatError('NOT_TABLE');
  }
  final headers = [for (final h in recs.first) cleanPackText(h, max: 80)];
  final rows = <List<String>>[];
  var skipped = 0;
  for (final r0 in recs.skip(1)) {
    // A short row keeps its cells and leaves the rest empty (missing is
    // not dropped); a longer row cannot be placed and is counted.
    if (r0.length > headers.length) {
      skipped++;
      continue;
    }
    final r = [...r0, for (var i = r0.length; i < headers.length; i++) ''];
    // A line break inside a quoted cell reads as a space, so two words
    // never run together when control characters are removed.
    rows.add([
      for (final f in r)
        cleanPackText(f.replaceAll(RegExp(r'\s*\r?\n\s*'), ' ')),
    ]);
  }
  if (rows.isEmpty) throw const PhytoFormatError('NOT_TABLE');
  return PhytoTable(headers: headers, rows: rows, skipped: skipped);
}

/// Abbreviations the database uses in doses, explained in plain words so a
/// reader can see which results come from animals or cells.
const Map<String, (String, String)> doseTerms = {
  'orl': ('by mouth', 'ağızdan'),
  'ipr': ('injected into the belly cavity', 'karın boşluğuna enjeksiyon'),
  'ivn': ('injected into a vein', 'damara enjeksiyon'),
  'scu': ('injected under the skin', 'deri altına enjeksiyon'),
  'mus': ('in mice', 'farelerde'),
  'rat': ('in rats', 'sıçanlarda'),
  'IC50': (
    'concentration that halves an activity in a lab test',
    'laboratuvar testinde bir etkinliği yarıya indiren derişim',
  ),
  'LD50': (
    'dose that killed half of the test animals',
    'deney hayvanlarının yarısını öldüren doz',
  ),
  'LDlo': (
    'lowest dose reported to have killed a test animal',
    'bir deney hayvanını öldürdüğü bildirilen en düşük doz',
  ),
  'TDlo': (
    'lowest dose with a toxic effect reported',
    'toksik etki bildirilen en düşük doz',
  ),
  'TDLo': (
    'lowest dose with a toxic effect reported',
    'toksik etki bildirilen en düşük doz',
  ),
  'LDLo': (
    'lowest dose reported to have killed a test animal',
    'bir deney hayvanını öldürdüğü bildirilen en düşük doz',
  ),
  'man': ('in men (human data)', 'erkeklerde (insan verisi)'),
  'wmn': ('in women (human data)', 'kadınlarda (insan verisi)'),
  'hmn': ('in humans', 'insanlarda'),
  'dog': ('in dogs', 'köpeklerde'),
  'rbt': ('in rabbits', 'tavşanlarda'),
  'gpg': ('in guinea pigs', 'kobaylarda'),
  'mky': ('in monkeys', 'maymunlarda'),
  'ims': ('injected into a muscle', 'kasa enjeksiyon'),
  'skn': ('on the skin', 'deri üzerine'),
  'ihl': ('breathed in', 'solunarak'),
  'par': ('not by mouth (parenteral)', 'ağız dışı yoldan (parenteral)'),
  'unr': ('route not reported', 'yol bildirilmemiş'),
  'ADI': (
    'acceptable daily intake set by a regulator',
    'düzenleyicinin belirlediği kabul edilebilir günlük alım',
  ),
  'ppm': (
    'parts per million (a concentration)',
    'milyonda bir pay (bir derişim)',
  ),
  'uM': (
    'micromoles per litre (lab concentration)',
    'litrede mikromol (laboratuvar derişimi)',
  ),
};

/// The dose terms that appear in [text], in the order of [doseTerms].
List<String> doseTermsIn(String text) => [
  for (final k in doseTerms.keys)
    if (RegExp('(?<![A-Za-z])${RegExp.escape(k)}(?![A-Za-z])').hasMatch(text))
      k,
];
