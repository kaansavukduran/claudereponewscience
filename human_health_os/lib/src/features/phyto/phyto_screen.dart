import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../domain/phyto/phyto_table.dart';
import '../../l10n/strings.dart';
import '../genetics/genome_file_picker.dart';
import '../guide/glossary_screen.dart' show foldForSearch;

/// A plant-chemicals table from Dr. Duke's databases, loaded from a file
/// and searched on this device (G003). Kept only while the page is open.
class PhytoScreen extends StatefulWidget {
  const PhytoScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<PhytoScreen> createState() => _PhytoScreenState();
}

class _PhytoScreenState extends State<PhytoScreen> {
  static const int _shown = 200;
  PhytoTable? _table;

  /// Each row folded once at load, so a keystroke does not re-fold the
  /// whole table.
  List<String> _folded = const [];
  String? _name;
  String? _refusal;
  bool _busy = false;
  String _q = '';
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  GenomeFilePicker get _picker =>
      widget.services.genomePicker ?? const SystemGenomeFilePicker();

  Future<void> _choose() async {
    setState(() {
      _busy = true;
      _refusal = null;
    });
    try {
      final picked = await _picker.pick(title: S.of(context).phytoLoad);
      if (picked == null) return;
      final Uint8List bytes;
      try {
        bytes = await picked.read();
      } finally {
        await _picker.release();
      }
      final table = parsePhytoBytes(
        bytes,
        (b) => utf8.decode(b, allowMalformed: true),
      );
      if (mounted) {
        setState(() {
          _table = table;
          _folded = [
            for (final r in table.rows) foldForSearch(r.join('\u0001')),
          ];
          _name = picked.name;
          // A new table starts unfiltered, and the box shows that.
          _q = '';
          _search.clear();
        });
      }
    } on PhytoFormatError catch (e) {
      if (mounted) setState(() => _refusal = e.code);
    } catch (_) {
      if (mounted) setState(() => _refusal = 'READ_FAILED');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final t = _table;
    final q = foldForSearch(_q.trim());
    final rows = t == null
        ? const <List<String>>[]
        : [
            for (var i = 0; i < t.rows.length; i++)
              if (q.isEmpty || _folded[i].contains(q)) t.rows[i],
          ];
    return Scaffold(
      appBar: AppBar(title: Text(s.phytoTitle)),
      body: ListView(
        key: const ValueKey('screen-phyto'),
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.phytoHow, style: text.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const ValueKey('phyto-load'),
                onPressed: _busy ? null : _choose,
                icon: const Icon(Icons.folder_open_outlined),
                label: Text(s.phytoLoad),
              ),
              if (t != null)
                TextButton(
                  key: const ValueKey('phyto-clear'),
                  onPressed: () => setState(() {
                    _table = null;
                    _name = null;
                  }),
                  child: Text(s.phytoClear),
                ),
            ],
          ),
          if (_refusal != null) ...[
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(
                s.phytoRefusal(_refusal!),
                key: const ValueKey('phyto-refusal'),
                style: text.bodyMedium?.copyWith(color: scheme.error),
              ),
            ),
          ],
          if (t != null) ...[
            const SizedBox(height: 16),
            Text(
              s.phytoLoaded(_name ?? '', t.rows.length),
              key: const ValueKey('phyto-loaded'),
              style: text.titleSmall,
            ),
            if (t.skipped > 0)
              Text(
                s.phytoSkipped(t.skipped),
                style: text.bodySmall?.copyWith(color: scheme.outline),
              ),
            const SizedBox(height: 8),
            Text(
              s.phytoNote,
              key: const ValueKey('phyto-note'),
              style: text.bodySmall?.copyWith(color: scheme.outline),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('phyto-search'),
              controller: _search,
              decoration: InputDecoration(
                labelText: s.phytoSearch,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _q = v),
            ),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              Text(s.phytoNone, key: const ValueKey('phyto-none'))
            else
              for (final r in rows.take(_shown)) _row(s, text, scheme, t, r),
            if (rows.length > _shown) Text(s.phytoMore(_shown, rows.length)),
          ],
        ],
      ),
    );
  }

  Widget _row(
    S s,
    TextTheme text,
    ColorScheme scheme,
    PhytoTable t,
    List<String> r,
  ) {
    final terms = doseTermsIn(r.join(' '));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.first, style: text.titleSmall),
          for (var i = 1; i < r.length; i++)
            if (r[i].isNotEmpty)
              Text('${t.headers[i]}: ${r[i]}', style: text.bodyMedium),
          if (terms.isNotEmpty)
            Text(
              terms
                  .map(
                    (k) =>
                        '$k = ${s.lang == AppLang.tr ? doseTerms[k]!.$2 : doseTerms[k]!.$1}',
                  )
                  .join(' · '),
              style: text.bodySmall?.copyWith(color: scheme.outline),
            ),
        ],
      ),
    );
  }
}
