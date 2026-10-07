import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../application/export.dart';
import '../../data/backup/backup_bundle.dart';
import '../../data/backup/data_files.dart';
import '../../l10n/strings.dart';
import '../../presentation/widgets/status_chip.dart';

/// Your data (ladder F005): create a backup, export the records, check a
/// saved backup and restore one through the staged restore gate.
class YourDataCard extends StatefulWidget {
  const YourDataCard({super.key, required this.services});

  final AppServices services;

  @override
  State<YourDataCard> createState() => _YourDataCardState();
}

class _YourDataCardState extends State<YourDataCard> {
  List<SavedFile> _backups = const [];
  String? _message;
  bool _messageIsError = false;
  bool _busy = false;
  bool _restored = false;

  AppServices get _s => widget.services;
  DataFiles? get _files => _s.dataFiles;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final f = _files;
    if (f == null || !f.canRestore) return;
    final list = await f.backups();
    if (mounted) setState(() => _backups = list);
  }

  Future<void> _run(Future<String> Function(S s) action, S s) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final msg = await action(s);
      _message = msg;
      _messageIsError = false;
      await _reload();
    } on BackupError catch (e) {
      _message = s.backupError(e.code, e.message);
      _messageIsError = true;
    } catch (_) {
      _message = s.inputError('SAVE_FAILED');
      _messageIsError = true;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String> _backup(S s) async {
    final text = await _s.readVaultText!();
    final now = DateTime.now().toUtc();
    final bundle = createBackupBundle(
      vaultLogText: text ?? '',
      appVersion: _s.config.version,
      sourceRevision: _s.config.sourceRevision,
      createdAt: now,
    );
    final where = await _files!.save(
      DataFileKind.backup,
      backupFileName(_s.storage.vaultId, now),
      bundle,
    );
    return s.savedTo(where);
  }

  Future<String> _export(S s) async {
    final now = DateTime.now().toUtc();
    final json = exportRecordsJson(
      profile: _s.self,
      records: await _s.heartbeat.repository.records(_s.self.id),
      exportedAt: now,
      appVersion: _s.config.version,
    );
    final where = await _files!.save(
      DataFileKind.export,
      exportFileName(now),
      json,
    );
    return s.savedTo(where);
  }

  Future<String> _check(SavedFile f, S s) async {
    final staged = stageRestore(await _files!.read(f));
    final m = staged.manifest;
    return s.backupChecked(
      m.recordCount,
      m.profileCount,
      m.createdAt.toIso8601String().substring(0, 16).replaceFirst('T', ' '),
    );
  }

  Future<void> _restore(SavedFile f, S s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(s.restoreTitle),
        content: Text(s.restoreExplain),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            key: const ValueKey('confirm-restore'),
            onPressed: () => Navigator.of(c).pop(true),
            child: Text(s.restoreBackup),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _run((s) async {
      final staged = stageRestore(await _files!.read(f));
      final out = await _files!.restore(staged, now: DateTime.now().toUtc());
      // This session's memory belongs to the replaced file: no more writes.
      _s.lockStorage?.call('RESTART_REQUIRED');
      _restored = true;
      return s.restored(out.records);
    }, s);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final files = _files;
    final canWrite = files != null && _s.readVaultText != null && !_restored;
    return Card(
      semanticContainer: false,
      key: const ValueKey('your-data-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(s.yourData, style: text.titleMedium),
            ),
            const SizedBox(height: 8),
            if (files == null)
              Text(
                s.dataNotAvailable,
                key: const ValueKey('data-not-available'),
                style: text.bodyMedium,
              )
            else ...[
              StatusChip(label: s.dataUnencrypted, tone: StatusTone.warn),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    key: const ValueKey('create-backup'),
                    onPressed: _busy || !canWrite
                        ? null
                        : () => _run(_backup, s),
                    icon: const Icon(Icons.backup_outlined),
                    label: Text(s.createBackup),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('export-json'),
                    onPressed: _busy || !canWrite
                        ? null
                        : () => _run(_export, s),
                    icon: const Icon(Icons.file_download_outlined),
                    label: Text(s.exportJson),
                  ),
                ],
              ),
              if (_message != null) ...[
                const SizedBox(height: 8),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _message!,
                    key: const ValueKey('data-message'),
                    style: text.bodySmall?.copyWith(
                      color: _messageIsError
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (!files.canRestore)
                Text(s.browserRestoreNotBuilt, style: text.bodySmall)
              else ...[
                Text(s.backupsTitle, style: text.titleSmall),
                if (_backups.isEmpty)
                  Text(
                    s.noBackups,
                    key: const ValueKey('no-backups'),
                    style: text.bodySmall,
                  ),
                for (final b in _backups)
                  Padding(
                    key: ValueKey('backup-${b.name}'),
                    padding: const EdgeInsets.only(top: 6),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(b.name, style: text.bodySmall),
                        TextButton(
                          key: ValueKey('check-${b.name}'),
                          onPressed: _busy
                              ? null
                              : () => _run((s) => _check(b, s), s),
                          child: Text(s.checkBackup),
                        ),
                        TextButton(
                          key: ValueKey('restore-${b.name}'),
                          onPressed: _busy || _restored
                              ? null
                              : () => _restore(b, s),
                          child: Text(s.restoreBackup),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
