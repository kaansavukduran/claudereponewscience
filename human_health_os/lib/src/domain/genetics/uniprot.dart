/// Reads a UniProt TSV export (uniprot.org → search → Download → Format:
/// TSV) offline (G007, G-69). UniProt is produced by the UniProt Consortium
/// and shared under CC BY 4.0; its words are shown as written, with the
/// source named. A protein's function is UniProt's description of the
/// protein, never a statement about the person.
library;

import 'annotation_pack.dart' show cleanPackText;

class UniProtEntry {
  const UniProtEntry({
    required this.accession,
    this.entryName = '',
    this.reviewed = '',
    this.proteinNames = '',
    this.genes = const [],
    this.organism = '',
    this.function = '',
  });

  /// "P38398" and its entry name "BRCA1_HUMAN".
  final String accession;
  final String entryName;

  /// UniProt's own word: "reviewed" (Swiss-Prot) or "unreviewed" (TrEMBL).
  final String reviewed;
  final String proteinNames;

  /// Gene names as UniProt lists them (primary first, then synonyms).
  final List<String> genes;
  final String organism;

  /// The "Function [CC]" text, as written (often starting "FUNCTION:").
  final String function;
}

class UniProtFormatError implements Exception {
  const UniProtFormatError(this.code);

  /// NOT_UNIPROT, SPREADSHEET, EMPTY.
  final String code;

  @override
  String toString() => 'UniProtFormatError($code)';
}

/// At most this many entries are kept (the reviewed human proteome is about
/// 20,400); more are counted, not kept.
const int maxUniProtEntries = 50000;

class UniProtFile {
  const UniProtFile(this.entries, {this.skipped = 0, this.capped = 0});

  final List<UniProtEntry> entries;

  /// Rows without an accession.
  final int skipped;

  /// Rows past [maxUniProtEntries].
  final int capped;

  /// Entries by gene name, upper case.
  Map<String, List<UniProtEntry>> byGene() {
    final out = <String, List<UniProtEntry>>{};
    for (final e in entries) {
      for (final g in e.genes) {
        (out[g.toUpperCase()] ??= []).add(e);
      }
    }
    return out;
  }
}

UniProtFile parseUniProtTsv(String text) {
  if (text.startsWith('PK')) throw const UniProtFormatError('SPREADSHEET');
  final t = text.startsWith('﻿') ? text.substring(1) : text;
  final lines = t.split('\n');
  final header = lines.isEmpty ? '' : _strip(lines.first);
  if (header.trim().isEmpty) throw const UniProtFormatError('EMPTY');
  final names = header.split('\t').map((h) => h.trim()).toList();
  int? col(List<String> options) {
    for (final o in options) {
      final i = names.indexOf(o);
      if (i >= 0) return i;
    }
    return null;
  }

  final entry = col(['Entry']);
  final genes = col(['Gene Names', 'Gene Names (primary)']);
  if (entry == null || genes == null) {
    throw const UniProtFormatError('NOT_UNIPROT');
  }
  final entryName = col(['Entry Name']);
  final reviewed = col(['Reviewed']);
  final protein = col(['Protein names']);
  final organism = col(['Organism']);
  final function = col(['Function [CC]']);
  final out = <UniProtEntry>[];
  var skipped = 0;
  var capped = 0;
  for (final raw in lines.skip(1)) {
    final line = _strip(raw);
    if (line.trim().isEmpty) continue;
    final f = line.split('\t');
    String at(int? i, {int max = 400}) =>
        i == null || i >= f.length ? '' : cleanPackText(f[i], max: max);
    final accession = at(entry, max: 20);
    if (accession.isEmpty) {
      skipped++;
      continue;
    }
    if (out.length >= maxUniProtEntries) {
      capped++;
      continue;
    }
    out.add(
      UniProtEntry(
        accession: accession,
        entryName: at(entryName, max: 40),
        reviewed: at(reviewed, max: 20),
        proteinNames: at(protein),
        genes: [
          for (final g in at(genes).split(RegExp(r'[\s;]+')))
            if (g.isNotEmpty) g,
        ],
        organism: at(organism, max: 120),
        function: at(function, max: 2000),
      ),
    );
  }
  return UniProtFile(out, skipped: skipped, capped: capped);
}

String _strip(String l) => l.endsWith('\r') ? l.substring(0, l.length - 1) : l;
