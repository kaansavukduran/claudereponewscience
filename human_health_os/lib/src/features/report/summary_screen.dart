import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../data/backup/data_files.dart';
import '../../l10n/strings.dart';
import '../today/save_copy.dart';
import 'doctor_summary.dart';

/// The summary for a visit (U009): shown on screen in every build; saved as
/// a printable page only where open files are allowed (not in encrypted
/// builds, same rule as the JSON export).
class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  DoctorSummary? _summary;
  String? _message;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final s = S.of(context);
    final summary = await DoctorSummary.collect(widget.services, s);
    if (mounted) setState(() => _summary = summary);
  }

  Copyable? _copyable;

  Future<void> _saveCopy(S s) async {
    final file = _copyable;
    final copy = saveCopyFor(widget.services);
    if (file == null || copy == null) return;
    try {
      final ok = await copy.save(
        fileName: file.name,
        text: file.text,
        mimeType: file.mime,
        title: s.saveCopy,
      );
      if (ok && mounted) setState(() => _message = s.copySaved(file.name));
    } catch (_) {
      if (mounted) setState(() => _message = s.inputError('SAVE_FAILED'));
    }
  }

  Future<void> _save(S s) async {
    final files = widget.services.dataFiles;
    final summary = _summary;
    if (files == null || summary == null) return;
    setState(() => _busy = true);
    try {
      final now = DateTime.now().toUtc();
      final name = 'human-os-summary-${fileStamp(now)}.html';
      final html = summary.toHtml(s.lang.name);
      final where = await files.save(DataFileKind.export, name, html);
      final phone = saveCopyFor(widget.services) != null;
      if (mounted) {
        setState(() {
          _copyable = phone
              ? (name: name, text: html, mime: 'text/html')
              : null;
          _message = phone ? s.savedInApp : s.savedTo(where);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _message = s.inputError('SAVE_FAILED'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final summary = _summary;
    final canSave =
        widget.services.dataFiles != null && !widget.services.storage.encrypted;
    return Scaffold(
      appBar: AppBar(title: Text(s.summaryTitle)),
      body: summary == null
          ? const SizedBox.shrink()
          : ListView(
              key: const ValueKey('screen-summary'),
              padding: const EdgeInsets.all(16),
              children: [
                Text(summary.createdAt, style: text.bodySmall),
                const SizedBox(height: 12),
                if (canSave)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonalIcon(
                      key: const ValueKey('summary-save'),
                      onPressed: _busy || summary.sections.isEmpty
                          ? null
                          : () => _save(s),
                      icon: const Icon(Icons.print_outlined),
                      label: Text(s.summarySave),
                    ),
                  )
                else if (widget.services.storage.encrypted)
                  Text(
                    s.summarySaveNotHere,
                    key: const ValueKey('summary-not-saved'),
                    style: text.bodySmall?.copyWith(color: scheme.outline),
                  ),
                if (_message != null) ...[
                  const SizedBox(height: 8),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _message!,
                      key: const ValueKey('summary-message'),
                    ),
                  ),
                  if (_copyable != null) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const ValueKey('summary-save-copy'),
                      onPressed: _busy ? null : () => _saveCopy(s),
                      icon: const Icon(Icons.save_alt),
                      label: Text(s.saveCopy),
                    ),
                  ],
                ],
                const SizedBox(height: 12),
                if (summary.sections.isEmpty)
                  Text(s.summaryEmpty, key: const ValueKey('summary-empty')),
                for (final sec in summary.sections) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    header: true,
                    child: Text(sec.title, style: text.titleMedium),
                  ),
                  if (sec.partNote.isNotEmpty)
                    Text(
                      sec.partNote,
                      style: text.bodySmall?.copyWith(color: scheme.outline),
                    ),
                  for (final r in sec.rows)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: scheme.outlineVariant),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.value, style: text.bodyLarge),
                          Text(
                            [r.when, if (r.note.isNotEmpty) r.note].join(' · '),
                            style: text.bodySmall?.copyWith(
                              color: scheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 16),
                for (final f in summary.footer)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      f,
                      style: text.bodySmall?.copyWith(color: scheme.outline),
                    ),
                  ),
              ],
            ),
    );
  }
}
