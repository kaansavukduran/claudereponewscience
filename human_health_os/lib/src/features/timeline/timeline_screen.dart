import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../../navigation/destinations.dart';
import '../../presentation/widgets/status_chip.dart';

/// Timeline (ladder F003): every fact once, newest first, with its versions.
/// Corrections add versions; "entered in error" withdraws a version; delete
/// removes the whole fact from views. Nothing is rewritten.
class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<TimelineEntry> _entries = const [];
  bool _showHidden = false;
  bool _loaded = false;

  HeartbeatService get _svc => widget.services.heartbeat;
  String get _me => widget.services.self.id;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final e = await _svc.timeline(_me, includeHidden: _showHidden);
    if (mounted) {
      setState(() {
        _entries = e;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final d = destinationById(DestinationId.timeline);
    return ListView(
      key: const ValueKey('screen-timeline'),
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text(d.label(s.lang), style: text.headlineSmall),
        ),
        const SizedBox(height: 8),
        Text(d.purpose(s.lang), style: text.bodyLarge),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.rule,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(d.principle(s.lang), style: text.bodyMedium)),
          ],
        ),
        SwitchListTile(
          key: const ValueKey('timeline-show-hidden'),
          contentPadding: EdgeInsets.zero,
          title: Text(s.showHidden),
          value: _showHidden,
          onChanged: (v) {
            setState(() => _showHidden = v);
            _reload();
          },
        ),
        if (_loaded && _entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              s.noRecordsYet,
              key: const ValueKey('timeline-empty'),
              style: text.titleMedium,
            ),
          ),
        for (final e in _entries)
          _EntryTile(
            key: ValueKey('timeline-entry-${e.rootId}'),
            entry: e,
            onTap: () => _openDetail(e),
          ),
      ],
    );
  }

  Future<void> _openDetail(TimelineEntry e) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EntryDetail(entry: e, svc: _svc, profileId: _me),
    );
    if (changed == true) await _reload();
  }
}

String fmtValue(S s, HealthRecord r) {
  final q = r.quantity;
  if (r.valueStatus != ValueStatus.present || q == null) {
    return s.valueStatus(r.valueStatus);
  }
  final v = q.value == q.value.roundToDouble()
      ? q.value.toStringAsFixed(0)
      : q.value.toStringAsFixed(1);
  return '$v ${q.unit}';
}

String fmtWhen(DateTime utc) {
  final l = utc.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}';
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({super.key, required this.entry, required this.onTap});

  final TimelineEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final r = entry.shown;
    final value = entry.status == EntryStatus.conflict
        ? s.versionsDisagree
        : fmtValue(s, r);
    return Card(
      semanticContainer: false,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(s.recordKind(r.kind), style: text.titleSmall),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: text.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${fmtWhen(r.observedAt)} · ${s.recordState(r.state)} · '
                '${s.provenanceKind(r.provenance.kind)}',
                style: text.bodySmall,
              ),
              if (entry.corrected || !entry.isLive) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (entry.corrected)
                      StatusChip(
                        label: s.versionsCount(entry.versions.length),
                        tone: StatusTone.info,
                      ),
                    if (entry.status != EntryStatus.current)
                      StatusChip(
                        label: s.entryStatus(entry.status),
                        tone: entry.status == EntryStatus.conflict
                            ? StatusTone.warn
                            : StatusTone.muted,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One fact: every version with why it exists, and the three different ways
/// to change it (correct, entered in error, delete).
class _EntryDetail extends StatefulWidget {
  const _EntryDetail({
    required this.entry,
    required this.svc,
    required this.profileId,
  });

  final TimelineEntry entry;
  final HeartbeatService svc;
  final String profileId;

  @override
  State<_EntryDetail> createState() => _EntryDetailState();
}

class _EntryDetailState extends State<_EntryDetail> {
  final _controller = TextEditingController();
  String? _correcting;
  String? _errorCode;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _errorCode = null;
    });
    try {
      await action();
      if (mounted) Navigator.of(context).pop(true);
    } on InputError catch (e) {
      setState(() => _errorCode = e.code);
    } on RecordValidationError catch (e) {
      setState(() => _errorCode = e.code);
    } catch (_) {
      setState(() => _errorCode = 'SAVE_FAILED');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmAmend(HealthRecord head, AmendReason reason) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(s.amendTitle(reason)),
        content: Text(s.amendExplain(reason)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            key: ValueKey('confirm-${reason.code}'),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(s.amendAction(reason)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _run(
      () => widget.svc.amend(
        profileId: widget.profileId,
        targetId: head.id,
        reason: reason,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final e = widget.entry;
    final headIds = {for (final h in e.heads) h.id};
    return SafeArea(
      child: SingleChildScrollView(
        key: const ValueKey('timeline-detail'),
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.recordKind(e.shown.kind), style: text.titleLarge),
            const SizedBox(height: 4),
            Text(s.entryStatusExplain(e.status), style: text.bodyMedium),
            const SizedBox(height: 12),
            Text(s.versions, style: text.titleSmall),
            for (final v in e.versions.reversed)
              ListTile(
                key: ValueKey('version-${v.id}'),
                contentPadding: EdgeInsets.zero,
                title: Text(fmtValue(s, v)),
                subtitle: Text(
                  [
                    s.versionRole(
                      isFirst: v.supersedesId == null,
                      withdrawn: e.withdrawn.contains(v.id),
                      current: headIds.contains(v.id) && e.isLive,
                    ),
                    '${s.enteredOn} ${fmtWhen(v.recordedAt)}',
                    s.provenanceKind(v.provenance.kind),
                    if (v.originalText != null) '"${v.originalText}"',
                  ].join(' · '),
                ),
              ),
            if (e.deletion != null)
              Text(
                '${s.entryStatus(EntryStatus.deleted)} · '
                '${fmtWhen(e.deletion!.deletedAt ?? e.deletion!.recordedAt)}',
                key: const ValueKey('timeline-deleted-at'),
                style: text.bodySmall,
              ),
            if (e.isLive) ...[
              const Divider(height: 24),
              for (final head in e.heads) ...[
                if (e.heads.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(fmtValue(s, head), style: text.titleSmall),
                  ),
                if (_correcting == head.id) ...[
                  TextField(
                    key: const ValueKey('correct-input'),
                    controller: _controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: s.weightField,
                      helperText: s.amendExplain(AmendReason.correction),
                      helperMaxLines: 3,
                      border: const OutlineInputBorder(),
                      errorText: _errorCode == null
                          ? null
                          : s.inputError(_errorCode!),
                      errorMaxLines: 3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    key: const ValueKey('correct-save'),
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => widget.svc.correctWeightKg(
                              profileId: widget.profileId,
                              targetId: head.id,
                              input: _controller.text,
                            ),
                          ),
                    child: Text(s.saveCorrection),
                  ),
                ] else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        key: ValueKey('action-correct-${head.id}'),
                        onPressed: _busy || head.kind != RecordKind.bodyWeight
                            ? null
                            : () => setState(() {
                                _correcting = head.id;
                                _errorCode = null;
                              }),
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(s.amendAction(AmendReason.correction)),
                      ),
                      OutlinedButton.icon(
                        key: ValueKey('action-error-${head.id}'),
                        onPressed: _busy
                            ? null
                            : () => _confirmAmend(
                                head,
                                AmendReason.enteredInError,
                              ),
                        icon: const Icon(Icons.block_outlined),
                        label: Text(s.amendAction(AmendReason.enteredInError)),
                      ),
                      OutlinedButton.icon(
                        key: ValueKey('action-delete-${head.id}'),
                        onPressed: _busy
                            ? null
                            : () => _confirmAmend(head, AmendReason.deleted),
                        icon: const Icon(Icons.delete_outline),
                        label: Text(s.amendAction(AmendReason.deleted)),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
              ],
              if (_errorCode != null && _correcting == null)
                Text(
                  s.inputError(_errorCode!),
                  style: text.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
