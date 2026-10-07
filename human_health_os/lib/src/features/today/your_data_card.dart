import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../application/export.dart';
import '../../data/backup/backup_bundle.dart';
import '../../data/backup/data_files.dart';
import '../../data/crypto/recovery_key.dart' show RecoveryKeyFormatError;
import '../../data/local/vault_envelope.dart' show KeyKind;
import '../../l10n/strings.dart';
import '../../presentation/widgets/status_chip.dart';
import '../timeline/timeline_screen.dart' show fmtWhen;

/// Your data (ladder F005, F006): create a backup, export the records, check
/// a saved backup and restore one through the staged restore gate. An
/// encrypted vault's backups stay encrypted; restoring one needs the
/// backup's own passphrase or recovery key, and export (plaintext) is not
/// offered for it.
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

  /// Kept in AppServices, not here: leaving and returning to Today must not
  /// re-enable writes after a restore (review finding).
  bool get _restored => _s.restartRequired?.value ?? false;

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
    } on RecoveryKeyFormatError {
      _message = s.recoveryKeyFormat;
      _messageIsError = true;
    } catch (_) {
      _message = s.inputError('SAVE_FAILED');
      _messageIsError = true;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String> _backup(S s) async {
    final now = DateTime.now().toUtc();
    final bundle = await _s.makeBackup!(now);
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
    return staged.encrypted
        ? s.backupCheckedEncrypted(m.recordCount, fmtWhen(m.createdAt))
        : s.backupChecked(m.recordCount, m.profileCount, fmtWhen(m.createdAt));
  }

  /// Asks for the passphrase (or recovery key) an encrypted backup was made
  /// with. Null when cancelled.
  Future<(String, KeyKind)?> _askBackupKey(S s) =>
      showDialog<(String, KeyKind)>(
        context: context,
        builder: (c) {
          final field = TextEditingController();
          var recovery = false;
          return StatefulBuilder(
            builder: (c, setDialog) => AlertDialog(
              title: Text(s.openBackupTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.openBackupExplain),
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey('backup-secret'),
                    controller: field,
                    obscureText: !recovery,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: recovery ? s.recoveryKeyLabel : s.passphrase,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  CheckboxListTile(
                    key: const ValueKey('backup-use-recovery'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: recovery,
                    onChanged: (v) => setDialog(() => recovery = v ?? false),
                    title: Text(s.useRecoveryKeyInstead),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(c).pop(),
                  child: Text(s.cancel),
                ),
                FilledButton(
                  key: const ValueKey('confirm-open-backup'),
                  onPressed: () => Navigator.of(c).pop((
                    field.text,
                    recovery ? KeyKind.recovery : KeyKind.passphrase,
                  )),
                  child: Text(s.restoreBackup),
                ),
              ],
            ),
          );
        },
      );

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
    StagedRestore? staged;
    (String, KeyKind)? key;
    try {
      staged = stageRestore(await _files!.read(f));
    } on BackupError {
      staged = null; // _run below reports it
    }
    if (staged != null && staged.needsKey) {
      if (!mounted) return;
      key = await _askBackupKey(s);
      if (key == null) return;
    }
    await _run((s) async {
      var st = staged ?? stageRestore(await _files!.read(f));
      if (key != null) {
        st = await unlockStagedRestore(
          st,
          key.$1,
          kind: key.$2,
          derive: _s.deriveKey,
        );
      }
      final out = await _files!.restore(st, now: DateTime.now().toUtc());
      // This session's memory belongs to the replaced file: no more writes.
      _s.lockStorage?.call('RESTART_REQUIRED');
      _s.restartRequired?.value = true;
      return st.encrypted
          ? s.restoredEncrypted(out.records, out.keptPrevious)
          : s.restored(out.records, out.keptPrevious);
    }, s);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final files = _files;
    final canWrite = files != null && _s.makeBackup != null && !_restored;
    final encrypted = _s.storage.encrypted;
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
              encrypted
                  ? StatusChip(label: s.dataEncrypted, tone: StatusTone.ok)
                  : StatusChip(label: s.dataUnencrypted, tone: StatusTone.warn),
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
                  if (!encrypted)
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
              if (encrypted) ...[
                const SizedBox(height: 8),
                Text(
                  s.exportNotForEncrypted,
                  key: const ValueKey('export-not-for-encrypted'),
                  style: text.bodySmall,
                ),
              ],
              if (_restored && _message == null) ...[
                const SizedBox(height: 8),
                Text(
                  s.restartToUse,
                  key: const ValueKey('restart-to-use'),
                  style: text.bodySmall,
                ),
              ],
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
