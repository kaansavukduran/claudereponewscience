import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../data/local/gzip_stream.dart';
import '../../domain/genetics/annotation_pack.dart';
import '../../domain/genetics/clinvar.dart';
import '../../domain/genetics/dbsnp_summary.dart';
import '../../domain/genetics/raw_genome.dart';
import '../../domain/genetics/sample_data.dart';
import '../../l10n/strings.dart';
import 'genome_file_picker.dart';

GenomeFile _parseBytes(Uint8List bytes) => parseRawGenomeBytes(bytes);

/// What a raw DNA file contains (ladder G001): a searchable list of
/// variants, never a meaning. The file is read on this device, kept only
/// while this page is open and never written, logged or sent.
class GeneticsScreen extends StatefulWidget {
  const GeneticsScreen({super.key, required this.services, this.parse});

  final AppServices services;

  /// Replaces the reader (tests, so that no isolate is needed).
  final GenomeFile Function(Uint8List bytes)? parse;

  @override
  State<GeneticsScreen> createState() => _GeneticsScreenState();
}

class _GeneticsScreenState extends State<GeneticsScreen> {
  static const int _pageSize = 50;

  GenomeFile? _file;
  String? _name;
  bool _isSample = false;
  AnnotationPack? _pack;
  List<PackMatch> _matches = const [];
  bool _busy = false;
  String? _refusal;
  String? _packRefusal;
  String _query = '';
  int _page = 0;
  final _search = TextEditingController();

  GenomeFilePicker get _picker =>
      widget.services.genomePicker ?? const SystemGenomeFilePicker();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _use(GenomeFile file, String name, {required bool sample}) {
    final pack = sample ? parsePack(samplePackText) : null;
    setState(() {
      _file = file;
      _name = name;
      _isSample = sample;
      _pack = pack;
      _matches = pack == null ? const [] : matchPack(file, pack);
      _refusal = null;
      _packRefusal = null;
      _query = '';
      _search.clear();
      _page = 0;
    });
  }

  Future<void> _choose() async {
    setState(() {
      _busy = true;
      _refusal = null;
    });
    try {
      final picked = await _picker.pick(title: S.of(context).geneticsChoose);
      if (picked == null) return;
      final Uint8List bytes;
      try {
        bytes = await picked.read();
      } finally {
        await _picker.release();
      }
      final parse = widget.parse;
      final file = parse != null
          ? parse(bytes)
          : await compute(_parseBytes, bytes);
      if (mounted) {
        _use(file, cleanPackText(picked.name, max: 120), sample: false);
      }
    } on GenomeFormatError catch (e) {
      // The file already loaded, if any, stays as it was.
      if (mounted) setState(() => _refusal = e.code);
    } catch (_) {
      if (mounted) setState(() => _refusal = 'READ_FAILED');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<DbSnpVariant> _dbsnp = const [];
  String? _dbsnpRefusal;
  bool _onlyMissense = false;
  bool _onlyClinical = false;

  ClinVarResult? _clinvar;
  String? _clinvarRefusal;
  int _clinvarProgress = 0;
  String? _clinvarLabel;

  Future<void> _chooseClinVar() async {
    final file = _file;
    if (file == null) return;
    setState(() {
      _busy = true;
      _clinvarRefusal = null;
      _clinvarProgress = 0;
    });
    try {
      final picked = await _picker.pick(title: S.of(context).clinvarLoad);
      if (picked == null) return;
      try {
        Stream<List<int>> bytes =
            picked.openRead?.call() ?? Stream.fromFuture(picked.read());
        if (picked.name.toLowerCase().endsWith('.gz')) {
          if (!canGunzip) throw const ClinVarFormatError('GZ_HERE');
          bytes = gunzipStream(bytes);
        }
        final lines = bytes
            .transform(const Utf8Decoder(allowMalformed: true))
            .transform(const LineSplitter());
        final wanted = {for (final v in file.variants) v.rsid.toLowerCase()};
        final result = await readClinVar(
          lines,
          wanted,
          progress: (n) {
            if (mounted) setState(() => _clinvarProgress = n);
          },
        );
        if (mounted) {
          setState(() {
            _clinvar = result;
            _clinvarLabel = null;
          });
        }
      } finally {
        await _picker.release();
      }
    } on ClinVarFormatError catch (e) {
      if (mounted) setState(() => _clinvarRefusal = e.code);
    } catch (_) {
      if (mounted) setState(() => _clinvarRefusal = 'READ_FAILED');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _chooseDbSnp() async {
    setState(() {
      _busy = true;
      _dbsnpRefusal = null;
    });
    try {
      final picked = await _picker.pick(title: S.of(context).dbsnpLoad);
      if (picked == null) return;
      final Uint8List bytes;
      try {
        bytes = await picked.read();
      } finally {
        await _picker.release();
      }
      final variants = parseDbSnpSummary(
        utf8.decode(bytes, allowMalformed: true),
      );
      if (mounted) setState(() => _dbsnp = variants);
    } on DbSnpFormatError catch (e) {
      if (mounted) setState(() => _dbsnpRefusal = e.code);
    } catch (_) {
      if (mounted) setState(() => _dbsnpRefusal = 'READ_FAILED');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _choosePack() async {
    setState(() {
      _busy = true;
      _packRefusal = null;
    });
    try {
      final picked = await _picker.pick(title: S.of(context).geneticsPackLoad);
      if (picked == null) return;
      final Uint8List bytes;
      try {
        bytes = await picked.read();
      } finally {
        await _picker.release();
      }
      final pack = parsePack(utf8.decode(bytes, allowMalformed: true));
      final file = _file;
      if (mounted && file != null) {
        setState(() {
          _pack = pack;
          _matches = matchPack(file, pack);
        });
      }
    } on PackFormatError catch (e) {
      if (mounted) setState(() => _packRefusal = e.code);
    } catch (_) {
      if (mounted) setState(() => _packRefusal = 'READ_FAILED');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _clear() => setState(() {
    _file = null;
    _name = null;
    _isSample = false;
    _pack = null;
    _matches = const [];
    _refusal = null;
    _packRefusal = null;
    _dbsnp = const [];
    _dbsnpRefusal = null;
    _clinvar = null;
    _clinvarRefusal = null;
    _query = '';
    _search.clear();
    _page = 0;
  });

  List<Variant> _filtered(GenomeFile f) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return f.variants;
    // "chr7", "chromosome 7" and "7" all mean chromosome 7.
    final chr = q
        .replaceFirst(RegExp(r'^(chromosome|chr)\s*'), '')
        .toUpperCase();
    return [
      for (final v in f.variants)
        if (v.rsid.toLowerCase().contains(q) || v.chromosome == chr) v,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final file = _file;
    return Scaffold(
      appBar: AppBar(title: Text(s.geneticsTitle)),
      body: ListView(
        key: const ValueKey('screen-genetics'),
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.geneticsIntro, style: text.bodyLarge),
          const SizedBox(height: 16),
          if (file == null) _notice(s, text, scheme),
          if (file == null) const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const ValueKey('genetics-choose'),
                onPressed: _busy ? null : _choose,
                icon: const Icon(Icons.folder_open_outlined),
                label: Text(s.geneticsChoose),
              ),
              OutlinedButton(
                key: const ValueKey('genetics-sample'),
                onPressed: _busy
                    ? null
                    : () => _use(
                        parseRawGenome(sampleGenomeText),
                        'sample',
                        sample: true,
                      ),
                child: Text(s.geneticsSample),
              ),
              if (file != null)
                TextButton(
                  key: const ValueKey('genetics-clear'),
                  onPressed: _busy ? null : _clear,
                  child: Text(s.geneticsClear),
                ),
            ],
          ),
          if (_busy) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Semantics(liveRegion: true, child: Text(s.geneticsReading)),
              ],
            ),
          ],
          if (_refusal != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Text(
                s.geneticsRefusal(_refusal!),
                key: const ValueKey('genetics-refusal'),
                style: text.bodyMedium?.copyWith(color: scheme.error),
              ),
            ),
          ],
          if (file != null) ..._loaded(s, text, scheme, file),
        ],
      ),
    );
  }

  Widget _notice(S s, TextTheme text, ColorScheme scheme) => Container(
    key: const ValueKey('genetics-notice'),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: scheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(s.geneticsNoticeTitle, style: text.titleMedium),
        ),
        const SizedBox(height: 8),
        for (final line in s.geneticsNotices)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(line, style: text.bodyMedium)),
              ],
            ),
          ),
      ],
    ),
  );

  List<Widget> _loaded(S s, TextTheme text, ColorScheme scheme, GenomeFile f) {
    final rows = _filtered(f);
    final pages = (rows.length / _pageSize).ceil().clamp(1, 1 << 30);
    final page = _page.clamp(0, pages - 1);
    final from = rows.isEmpty ? 0 : page * _pageSize + 1;
    final to = (page * _pageSize + _pageSize).clamp(0, rows.length);
    String kv(String k, String v) => '$k: $v';
    return [
      const SizedBox(height: 20),
      Text(
        _isSample ? s.geneticsSampleLoaded : s.geneticsLoadedFrom(_name ?? ''),
        key: const ValueKey('genetics-loaded-from'),
        style: text.titleMedium,
      ),
      const SizedBox(height: 4),
      Text(
        s.geneticsKeptOnly,
        key: const ValueKey('genetics-kept-only'),
        style: text.bodySmall?.copyWith(color: scheme.outline),
      ),
      const SizedBox(height: 12),
      Column(
        key: const ValueKey('genetics-summary'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kv(s.geneticsFormat, f.vendorHint ?? f.source.label)),
          Text(kv(s.geneticsBuild, f.build ?? s.geneticsBuildNotStated)),
          Text(kv(s.geneticsTotal, '${f.total}')),
          Text(kv(s.geneticsRead, '${f.calledCount}')),
          Text(kv(s.geneticsNotRead, '${f.noCallCount}')),
          if (f.invalidCount > 0)
            Text(kv(s.geneticsUnreadableLines, '${f.invalidCount}')),
          if (f.duplicateCount > 0)
            Text(kv(s.geneticsRepeated, '${f.duplicateCount}')),
        ],
      ),
      if (f.invalidSample.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(
          [
            for (final i in f.invalidSample.take(5))
              s.geneticsInvalidLine(
                i.lineNumber,
                s.geneticsInvalidReason(i.reason),
              ),
          ].join('\n'),
          key: const ValueKey('genetics-invalid-lines'),
          style: text.bodySmall?.copyWith(color: scheme.outline),
        ),
      ],
      const SizedBox(height: 12),
      Text(s.geneticsChromosomes, style: text.titleSmall),
      const SizedBox(height: 4),
      Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          for (final e in f.perChromosome.entries)
            Text('${e.key}: ${e.value}', style: text.bodySmall),
        ],
      ),
      const SizedBox(height: 20),
      TextField(
        key: const ValueKey('genetics-search'),
        controller: _search,
        // Typed ids stay out of the keyboard's learned words.
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        decoration: InputDecoration(
          labelText: s.geneticsSearchHint,
          prefixIcon: const Icon(Icons.search),
        ),
        onChanged: (v) => setState(() {
          _query = v;
          _page = 0;
        }),
      ),
      const SizedBox(height: 8),
      if (rows.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            s.geneticsNoMatches,
            key: const ValueKey('genetics-no-matches'),
          ),
        )
      else
        for (final v in rows.skip(page * _pageSize).take(_pageSize))
          _variantRow(s, text, scheme, v),
      const SizedBox(height: 8),
      // A Wrap, not a Row: at large text the two buttons and the range do
      // not fit side by side on a phone.
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        children: [
          TextButton(
            key: const ValueKey('genetics-prev'),
            onPressed: page > 0 ? () => setState(() => _page = page - 1) : null,
            child: Text(s.geneticsPrev),
          ),
          Text(
            s.geneticsRange(from, to, rows.length),
            key: const ValueKey('genetics-range'),
            textAlign: TextAlign.center,
          ),
          TextButton(
            key: const ValueKey('genetics-next'),
            onPressed: page < pages - 1
                ? () => setState(() => _page = page + 1)
                : null,
            child: Text(s.geneticsNext),
          ),
        ],
      ),
      const SizedBox(height: 24),
      ..._packSection(s, text, scheme),
      const SizedBox(height: 24),
      ..._dbsnpSection(s, text, scheme, f),
      const SizedBox(height: 24),
      ..._clinvarSection(s, text, scheme, f),
    ];
  }

  Widget _variantRow(S s, TextTheme text, ColorScheme scheme, Variant v) {
    final call = v.call;
    final genotype = Text(
      call ?? s.geneticsNotReadShort,
      textAlign: TextAlign.end,
      style: call == null
          ? text.bodyMedium?.copyWith(color: scheme.outline)
          : text.titleSmall?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
    );
    return Semantics(
      label: s.geneticsRowSpoken(v.rsid, v.chromosome, v.position, call),
      excludeSemantics: true,
      child: Container(
        key: ValueKey('variant-${v.rsid}-${v.position}'),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
        ),
        // Two lines, not four cramped columns: the rsID and the genotype on
        // the first, the place in the genome on the second. It holds at 320 dp
        // and at large text, and reads the same on a wide window.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(v.rsid)),
                const SizedBox(width: 12),
                Flexible(child: genotype),
              ],
            ),
            Text(
              '${s.geneticsChromosomeShort} ${v.chromosome} · ${v.position}',
              style: text.bodySmall?.copyWith(
                color: scheme.outline,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _packSection(S s, TextTheme text, ColorScheme scheme) {
    final pack = _pack;
    return [
      Semantics(
        header: true,
        child: Text(s.geneticsPackTitle, style: text.titleMedium),
      ),
      const SizedBox(height: 4),
      Text(
        s.geneticsPackNote,
        key: const ValueKey('genetics-pack-note'),
        style: text.bodySmall?.copyWith(color: scheme.outline),
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        key: const ValueKey('genetics-pack-load'),
        onPressed: _busy ? null : _choosePack,
        child: Text(s.geneticsPackLoad),
      ),
      if (_packRefusal != null) ...[
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Text(
            s.geneticsPackRefusal(_packRefusal!),
            key: const ValueKey('genetics-pack-refusal'),
            style: text.bodyMedium?.copyWith(color: scheme.error),
          ),
        ),
      ],
      if (pack != null) ...[
        const SizedBox(height: 12),
        Text(pack.name, style: text.titleSmall),
        if (pack.synthetic)
          Text(
            s.geneticsPackSynthetic,
            key: const ValueKey('genetics-pack-synthetic'),
            style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        Text(
          '${s.geneticsPackLicence}: ${pack.licence}',
          style: text.bodySmall?.copyWith(color: scheme.outline),
        ),
        const SizedBox(height: 8),
        if (_matches.isEmpty)
          Text(s.geneticsPackNone, key: const ValueKey('genetics-pack-none'))
        else
          for (final m in _matches) _matchCard(s, text, scheme, m, pack),
      ],
    ];
  }

  List<Widget> _dbsnpSection(
    S s,
    TextTheme text,
    ColorScheme scheme,
    GenomeFile f,
  ) {
    final byId = <String, Variant>{
      for (final v in f.variants) v.rsid.toLowerCase(): v,
    };
    final matches = [
      for (final d in _dbsnp)
        if (byId.containsKey(d.rsid))
          if ((!_onlyMissense || d.isMissense) &&
              (!_onlyClinical || d.hasClinical))
            compareWithDbSnp(d, byId[d.rsid]!.call),
    ];
    final inFile = _dbsnp.where((d) => byId.containsKey(d.rsid)).length;
    return [
      Semantics(
        header: true,
        child: Text(s.dbsnpTitle, style: text.titleMedium),
      ),
      const SizedBox(height: 4),
      Text(
        s.dbsnpHow,
        key: const ValueKey('dbsnp-how'),
        style: text.bodySmall?.copyWith(color: scheme.outline),
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        key: const ValueKey('dbsnp-load'),
        onPressed: _busy ? null : _chooseDbSnp,
        child: Text(s.dbsnpLoad),
      ),
      if (_dbsnpRefusal != null) ...[
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Text(
            s.dbsnpRefusal(_dbsnpRefusal!),
            key: const ValueKey('dbsnp-refusal'),
            style: text.bodyMedium?.copyWith(color: scheme.error),
          ),
        ),
      ],
      if (_dbsnp.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(
          s.dbsnpCounts(_dbsnp.length, inFile),
          key: const ValueKey('dbsnp-counts'),
          style: text.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              key: const ValueKey('dbsnp-only-missense'),
              label: Text(s.dbsnpOnlyMissense),
              selected: _onlyMissense,
              onSelected: (v) => setState(() => _onlyMissense = v),
            ),
            FilterChip(
              key: const ValueKey('dbsnp-only-clinical'),
              label: Text(s.dbsnpOnlyClinical),
              selected: _onlyClinical,
              onSelected: (v) => setState(() => _onlyClinical = v),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          s.dbsnpNote,
          key: const ValueKey('dbsnp-note'),
          style: text.bodySmall?.copyWith(color: scheme.outline),
        ),
        const SizedBox(height: 8),
        if (matches.isEmpty)
          Text(s.dbsnpNone, key: const ValueKey('dbsnp-none'))
        else
          for (final m in matches.take(200)) _dbsnpCard(s, text, scheme, m),
        if (matches.length > 200) Text(s.dbsnpMore(200, matches.length)),
      ],
    ];
  }

  List<Widget> _clinvarSection(
    S s,
    TextTheme text,
    ColorScheme scheme,
    GenomeFile f,
  ) {
    final result = _clinvar;
    final byId = <String, Variant>{
      for (final v in f.variants) v.rsid.toLowerCase(): v,
    };
    final labels = <String>{
      for (final r in result?.records ?? const <ClinVarRecord>[])
        if (r.significance.isNotEmpty) r.significance,
    }.toList()..sort();
    final shown = [
      for (final r in result?.records ?? const <ClinVarRecord>[])
        if (_clinvarLabel == null || r.significance == _clinvarLabel) r,
    ];
    return [
      Semantics(
        header: true,
        child: Text(s.clinvarTitle, style: text.titleMedium),
      ),
      const SizedBox(height: 4),
      Text(
        s.clinvarHow,
        key: const ValueKey('clinvar-how'),
        style: text.bodySmall?.copyWith(color: scheme.outline),
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        key: const ValueKey('clinvar-load'),
        onPressed: _busy ? null : _chooseClinVar,
        child: Text(s.clinvarLoad),
      ),
      if (_busy && _clinvarProgress > 0)
        Semantics(
          liveRegion: true,
          child: Text(s.clinvarReading(_clinvarProgress)),
        ),
      if (_clinvarRefusal != null) ...[
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Text(
            s.clinvarRefusal(_clinvarRefusal!),
            key: const ValueKey('clinvar-refusal'),
            style: text.bodyMedium?.copyWith(color: scheme.error),
          ),
        ),
      ],
      if (result != null) ...[
        const SizedBox(height: 12),
        Text(
          s.clinvarCounts(result.linesRead, result.records.length),
          key: const ValueKey('clinvar-counts'),
          style: text.titleSmall,
        ),
        if (result.capped) Text(s.clinvarCapped(maxClinVarMatches)),
        const SizedBox(height: 8),
        Text(
          s.clinvarNote,
          key: const ValueKey('clinvar-note'),
          style: text.bodySmall?.copyWith(color: scheme.outline),
        ),
        const SizedBox(height: 8),
        if (labels.length > 1)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                key: const ValueKey('clinvar-label-all'),
                label: Text(s.trendRange('all')),
                selected: _clinvarLabel == null,
                onSelected: (_) => setState(() => _clinvarLabel = null),
              ),
              for (final l in labels.take(12))
                ChoiceChip(
                  key: ValueKey('clinvar-label-$l'),
                  label: Text(l),
                  selected: _clinvarLabel == l,
                  onSelected: (_) => setState(() => _clinvarLabel = l),
                ),
            ],
          ),
        const SizedBox(height: 8),
        if (shown.isEmpty)
          Text(s.dbsnpNone, key: const ValueKey('clinvar-none'))
        else
          for (final r in shown.take(200))
            _clinvarCard(s, text, scheme, r, byId[r.rsid]?.call),
        if (shown.length > 200) Text(s.dbsnpMore(200, shown.length)),
      ],
    ];
  }

  Widget _clinvarCard(
    S s,
    TextTheme text,
    ColorScheme scheme,
    ClinVarRecord r,
    String? genotype,
  ) {
    final comparison = r.reference == null || r.alternate == null
        ? null
        : compareWithDbSnp(
            DbSnpVariant(
              rsid: r.rsid,
              reference: r.reference,
              alternates: [r.alternate!],
            ),
            genotype,
          );
    return Container(
      key: ValueKey('clinvar-${r.rsid}-${r.variationId}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [r.rsid, if (r.gene.isNotEmpty) r.gene].join(' · '),
            style: text.titleSmall,
          ),
          Text(
            genotype ?? s.geneticsNotReadShort,
            style: text.titleMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (comparison != null)
            Text(
              s.dbsnpCall(
                comparison.call.name,
                comparison.alternatesListed.join(', '),
              ),
            ),
          if (r.reference != null && r.alternate != null)
            Text(
              s.clinvarAlleles(r.reference!, r.alternate!),
              style: text.bodySmall,
            ),
          Text(
            s.clinvarSignificance(
              r.significance.isEmpty ? '—' : r.significance,
            ),
            key: ValueKey('clinvar-sig-${r.rsid}-${r.variationId}'),
            style: text.bodySmall,
          ),
          if (r.reviewStatus.isNotEmpty)
            Text(s.clinvarReview(r.reviewStatus), style: text.bodySmall),
          if (r.conditions.isNotEmpty)
            Text(
              s.clinvarConditions(r.conditions),
              style: text.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          Text(
            [
              if (r.chromosome.isNotEmpty) '${r.chromosome}:${r.position}',
              r.assembly,
              'VCV ${r.variationId}',
            ].where((x) => x.isNotEmpty).join(' · '),
            style: text.bodySmall?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _dbsnpCard(S s, TextTheme text, ColorScheme scheme, DbSnpMatch m) {
    final v = m.variant;
    return Container(
      key: ValueKey('dbsnp-${v.rsid}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text([v.rsid, ...v.genes].join(' · '), style: text.titleSmall),
          Text(
            m.genotype ?? s.geneticsNotReadShort,
            style: text.titleMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(s.dbsnpCall(m.call.name, m.alternatesListed.join(', '))),
          if (v.reference != null)
            Text(
              s.dbsnpAlleles(v.reference!, v.alternates.join(', ')),
              style: text.bodySmall,
            ),
          if (v.consequences.isNotEmpty)
            Text(
              s.dbsnpConsequence(v.consequences.join(', ')),
              style: text.bodySmall,
            ),
          Text(
            v.clinical.isEmpty
                ? s.dbsnpNoClinical
                : s.dbsnpClinical(v.clinical.join(', ')),
            key: ValueKey('dbsnp-clinical-${v.rsid}'),
            style: text.bodySmall,
          ),
          if (v.positions.isNotEmpty)
            Text(
              v.positions.join(' · '),
              style: text.bodySmall?.copyWith(color: scheme.outline),
            ),
        ],
      ),
    );
  }

  Widget _matchCard(
    S s,
    TextTheme text,
    ColorScheme scheme,
    PackMatch m,
    AnnotationPack pack,
  ) {
    final e = m.entry;
    return Container(
      key: ValueKey('match-${e.rsid}-${m.variant.position}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${e.rsid} · ${e.gene}', style: text.titleSmall),
          Text(
            m.variant.call ?? s.geneticsNotReadShort,
            style: text.titleMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(s.geneticsMatchKind(m.kind.name, allele: e.allele)),
          const SizedBox(height: 4),
          Text('“${e.statement}”', style: text.bodyMedium),
          const SizedBox(height: 4),
          Text(
            [
              '${s.geneticsPackSource}: ${e.source}',
              e.sourceId,
              e.sourceDate,
              if (e.evidence.isNotEmpty) e.evidence,
            ].join(' · '),
            style: text.bodySmall?.copyWith(color: scheme.outline),
          ),
          Text(
            s.geneticsBuildNote(m.buildNote, pack.build),
            style: text.bodySmall?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}
