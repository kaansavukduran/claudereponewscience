import 'package:flutter/material.dart';

import '../../domain/guide/body_guide.dart' show Bilingual;
import '../../domain/guide/glossary.dart';
import '../../l10n/strings.dart';

String _pick(S s, Bilingual b) => s.lang == AppLang.tr ? b.$2 : b.$1;

/// Every term and measurement in plain words (U003), searchable.
class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final q = _q.trim().toLowerCase();
    final shown = [
      for (final e in glossary)
        if (q.isEmpty ||
            e.term.$1.toLowerCase().contains(q) ||
            e.term.$2.toLowerCase().contains(q))
          e,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(s.glossaryTitle)),
      body: ListView(
        key: const ValueKey('screen-glossary'),
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const ValueKey('glossary-search'),
            decoration: InputDecoration(
              labelText: s.glossarySearch,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
          const SizedBox(height: 8),
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(s.glossaryNone, key: const ValueKey('glossary-none')),
            ),
          for (final e in shown)
            ListTile(
              key: ValueKey('glossary-${e.id}'),
              contentPadding: EdgeInsets.zero,
              title: Text(_pick(s, e.term), style: text.titleSmall),
              subtitle: Text(
                _pick(s, e.what),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GlossaryEntryScreen(entry: e),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            _pick(s, glossaryAuthorship),
            style: text.bodySmall?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}

class GlossaryEntryScreen extends StatelessWidget {
  const GlossaryEntryScreen({super.key, required this.entry});

  final GlossaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final unit = entry.unit;
    final source = entry.source;
    return Scaffold(
      appBar: AppBar(title: Text(_pick(s, entry.term))),
      body: ListView(
        key: ValueKey('screen-glossary-${entry.id}'),
        padding: const EdgeInsets.all(16),
        children: [
          Text(_pick(s, entry.what), style: text.bodyLarge),
          if (unit != null) ...[
            const SizedBox(height: 16),
            Text(s.glossaryUnit, style: text.titleSmall),
            Text(_pick(s, unit), key: const ValueKey('glossary-unit')),
          ],
          if (entry.howToMeasure.isNotEmpty) ...[
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(s.glossaryHow, style: text.titleMedium),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < entry.howToMeasure.length; i++)
              Padding(
                key: ValueKey('glossary-step-${i + 1}'),
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${i + 1}',
                        style: text.titleSmall?.copyWith(color: scheme.primary),
                      ),
                    ),
                    Expanded(child: Text(_pick(s, entry.howToMeasure[i]))),
                  ],
                ),
              ),
          ],
          if (source != null) ...[
            const SizedBox(height: 12),
            Text(
              _pick(s, source),
              style: text.bodySmall?.copyWith(color: scheme.outline),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            _pick(s, glossaryAuthorship),
            style: text.bodySmall?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}
