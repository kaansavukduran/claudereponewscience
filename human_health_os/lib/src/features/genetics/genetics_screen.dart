import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../domain/genetics/annotation_pack.dart';
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
      final bytes = await picked.read();
      await _picker.release();
      final parse = widget.parse;
      final file = parse != null
          ? parse(bytes)
          : await compute(_parseBytes, bytes);
      if (mounted) _use(file, picked.name, sample: false);
    } on GenomeFormatError catch (e) {
      // The file already loaded, if any, stays as it was.
      if (mounted) setState(() => _refusal = e.code);
    } catch (_) {
      if (mounted) setState(() => _refusal = 'READ_FAILED');
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
      final bytes = await picked.read();
      await _picker.release();
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
    _query = '';
    _search.clear();
    _page = 0;
  });

  List<Variant> _filtered(GenomeFile f) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return f.variants;
    return [
      for (final v in f.variants)
        if (v.rsid.toLowerCase().contains(q) || v.chromosome.toLowerCase() == q)
          v,
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
                Text(s.geneticsReading),
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
      Text(
        s.geneticsColumns,
        style: text.labelMedium?.copyWith(color: scheme.outline),
      ),
      const SizedBox(height: 4),
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
    ];
  }

  Widget _variantRow(S s, TextTheme text, ColorScheme scheme, Variant v) {
    final call = v.call;
    return Semantics(
      label:
          '${v.rsid}, chromosome ${v.chromosome}, position ${v.position}, '
          '${s.geneticsGenotypeSpoken(call)}',
      excludeSemantics: true,
      child: Container(
        key: ValueKey('variant-${v.rsid}-${v.position}'),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(v.rsid)),
            Expanded(flex: 1, child: Text(v.chromosome)),
            Expanded(flex: 2, child: Text('${v.position}')),
            Expanded(
              flex: 2,
              child: Text(
                call ?? s.geneticsNotReadShort,
                textAlign: TextAlign.end,
                style: call == null
                    ? text.bodyMedium?.copyWith(color: scheme.outline)
                    : text.titleSmall?.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
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
          Text(s.geneticsMatchKind(m.kind.name)),
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
