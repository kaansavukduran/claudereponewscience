import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../../presentation/widgets/aion.dart';
import '../../presentation/widgets/sheet_parts.dart';

/// Documents (F010 slice 1): references to the documents the person keeps,
/// each field as typed: a title, what kind of document it is, its own date,
/// who issued it and where it is kept. A reference is not the document: the
/// app never reads, opens, uploads or stores it, and extracts nothing.
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<HealthRecord>? _entries;

  HeartbeatService get _svc => widget.services.heartbeat;
  String get _me => widget.services.self.id;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final entries = await _svc.documents(_me);
    if (mounted) setState(() => _entries = entries);
  }

  Future<void> _open({HealthRecord? correcting}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) =>
          _DocumentSheet(svc: _svc, me: _me, correcting: correcting),
    );
    if (saved == true) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final entries = _entries;
    return ListView(
      key: const ValueKey('screen-documents'),
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text(s.docTitle, style: text.headlineSmall),
        ),
        const SizedBox(height: 8),
        Text(s.docIntro, style: text.bodyMedium),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const ValueKey('doc-add'),
            onPressed: _open,
            icon: const Icon(Icons.add),
            label: Text(s.docAdd),
          ),
        ),
        const SizedBox(height: 16),
        if (entries == null)
          const Center(child: CircularProgressIndicator())
        else if (entries.isEmpty)
          Row(
            children: [
              const AionFigure(height: 64),
              const SizedBox(width: 12),
              Expanded(child: Text(s.docNone, key: const ValueKey('doc-none'))),
            ],
          )
        else
          for (final r in entries)
            Card(
              key: ValueKey('doc-entry-${r.id}'),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(s.docLine(r.details! as DocumentReferenceDetails)),
                // Under the text, so a narrow window never squeezes it.
                subtitle: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: ValueKey('doc-correct-${r.id}'),
                    onPressed: () => _open(correcting: r),
                    child: Text(s.amendAction(AmendReason.correction)),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _DocumentSheet extends StatefulWidget {
  const _DocumentSheet({required this.svc, required this.me, this.correcting});

  final HeartbeatService svc;
  final String me;

  /// The shown version being corrected; null for a new entry.
  final HealthRecord? correcting;

  @override
  State<_DocumentSheet> createState() => _DocumentSheetState();
}

class _DocumentSheetState extends State<_DocumentSheet> {
  final _title = TextEditingController();
  final _date = TextEditingController();
  final _issuer = TextEditingController();
  final _where = TextEditingController();
  final _focus = FieldFocus();
  // Nothing is chosen for the person: the kind starts at "other".
  var _nature = DocumentType.other;
  String? _error;
  String? _errorField;
  bool _busy = false;

  static const _textFields = {'title', 'date', 'issuer', 'whereKept'};

  @override
  void initState() {
    super.initState();
    final d = widget.correcting?.details;
    if (d is DocumentReferenceDetails) {
      _title.text = d.title;
      _date.text = d.date ?? '';
      _issuer.text = d.issuer ?? '';
      _where.text = d.whereKept ?? '';
      _nature = d.nature;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _date.dispose();
    _issuer.dispose();
    _where.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final s = S.of(context);
    setState(() => _busy = true);
    var saved = false;
    try {
      await widget.svc.recordDocument(
        profileId: widget.me,
        title: _title.text,
        nature: _nature,
        date: _date.text,
        issuer: _issuer.text,
        whereKept: _where.text,
        correcting: widget.correcting?.id,
      );
      saved = true;
    } on InputError catch (e) {
      _error = s.inputError(e.code);
      _errorField = e.field;
    } on Object {
      // A storage failure is said in words; nothing was written.
      _error = s.saveFailed;
      _errorField = null;
    } finally {
      if (mounted) {
        if (saved) {
          Navigator.of(context).pop(true);
        } else {
          setState(() => _busy = false);
          _focus.focusAfterFrame(this, _errorField);
        }
      }
    }
  }

  Widget _field(String key, String label, TextEditingController c, String f) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          key: ValueKey(key),
          controller: c,
          focusNode: _focus[f],
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            if (_error != null) setState(() => _error = _errorField = null);
          },
          decoration: InputDecoration(
            labelText: label,
            errorText: _errorField == f ? _error : null,
            errorMaxLines: 4,
            border: const OutlineInputBorder(),
          ),
        ),
      );

  Widget _natureChoice(S s) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Semantics(
      container: true,
      label: s.docNatureLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(child: Text(s.docNatureLabel)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final v in DocumentType.values)
                ChoiceChip(
                  key: ValueKey('doc-nature-${v.name}'),
                  label: Text(s.docNature(v)),
                  selected: v == _nature,
                  onSelected: (_) => setState(() => _nature = v),
                ),
            ],
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SheetFrame(
      fields: [
        Semantics(
          header: true,
          child: Text(
            widget.correcting == null ? s.docAdd : s.docCorrectTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        _field('doc-title', s.docTitleField, _title, 'title'),
        _natureChoice(s),
        _field('doc-date', s.docDate, _date, 'date'),
        _field('doc-issuer', s.docIssuer, _issuer, 'issuer'),
        _field('doc-where', s.docWhere, _where, 'whereKept'),
        if (_error != null && !_textFields.contains(_errorField))
          Semantics(
            liveRegion: true,
            child: Text(
              _error!,
              key: const ValueKey('doc-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
      actions: [
        FilledButton(
          key: const ValueKey('doc-save'),
          onPressed: _busy ? null : _save,
          child: Text(s.save),
        ),
        TextButton(
          key: const ValueKey('doc-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(s.cancel),
        ),
      ],
    );
  }
}
