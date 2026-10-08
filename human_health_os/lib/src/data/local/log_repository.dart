/// HealthRepository implemented on top of the vault log, parameterised by a
/// tiny byte sink so the same logic serves memory, files and browser storage.
library;

import '../../core/ids.dart';
import '../../domain/ports/health_repository.dart';
import '../../domain/profile/profile.dart';
import '../../domain/records/health_record.dart';
import 'vault_log.dart';

/// The `encryption` value of a log header kept inside the encrypted envelope
/// (vault_envelope.dart).
const String encryptionEnvelopeV1 = 'hhos-vault-enc-v1';

/// Where the log text lives.
abstract interface class LogSink {
  /// Whole log text, or null when no vault exists yet.
  Future<String?> read();

  /// Creates the log with exactly [text] plus a final newline, replacing
  /// anything stored, in one atomic step where the medium allows it.
  Future<void> create(String text);

  /// Appends one line durably.
  Future<void> appendLine(String line);
}

/// A [LogSink] that can replace its first line and keep every byte after
/// it exactly as stored (also bytes that do not decode as text).
abstract interface class FirstLineReplaceable {
  /// Atomically replaces line 1 with [line].
  Future<void> replaceFirstLine(String line);
}

class LogRepository implements HealthRepository {
  LogRepository({
    required this.sink,
    required this.durability,
    required this.location,
    this.clock = const SystemClock(),
    IdGenerator? ids,
    this.migrations = vaultMigrations,
    this.targetVersion = vaultFormatVersion,
    this.encrypted = false,
  }) : _ids = ids ?? UuidV4Generator();

  final LogSink sink;
  final StorageDurability durability;
  final String location;
  final Clock clock;
  final IdGenerator _ids;

  /// The migration graph and the format this repository writes. Tests pass a
  /// synthetic graph; the app uses the production one.
  final List<VaultMigration> migrations;
  final int targetVersion;

  /// True when [sink] seals what it stores (the encrypted vault). Set by
  /// whoever wires the sink, never read from the stored header.
  final bool encrypted;
  VaultState? _state;
  bool _readOnly = false;
  String? _lockedCode;

  /// True when the stored text may end in an unfinished line (a torn last
  /// write found at open, or a write that failed in this session). The next
  /// write first ends that line, so the fragment stays a separate, skipped
  /// line and never swallows the new entry.
  bool _tailOpen = false;

  Future<void> _append(String line) async {
    if (_tailOpen) {
      await sink.appendLine('');
      _tailOpen = false;
    }
    try {
      await sink.appendLine(line);
    } catch (_) {
      _tailOpen = true;
      rethrow;
    }
  }

  @override
  bool get writable => _state != null && !_readOnly && _lockedCode == null;

  /// Refuses every later write with [code] (e.g. after the vault file was
  /// replaced by a restore: this session's memory no longer matches it).
  void lock(String code) => _lockedCode = code;

  void _checkWritable() {
    final locked = _lockedCode;
    if (locked != null) throw StorageWriteRefused(locked);
    if (_readOnly) throw const StorageWriteRefused('VAULT_READ_ONLY');
  }

  VaultState get _s {
    final s = _state;
    if (s == null) throw StateError('Repository not opened');
    return s;
  }

  @override
  StorageDescription get description => StorageDescription(
    durability: durability,
    encrypted: encrypted,
    location: location,
    vaultId: _state?.header.vaultId ?? '',
  );

  @override
  Future<LoadReport> open() async {
    final text = await sink.read();
    if (text == null || text.trim().isEmpty) {
      final header = VaultHeader(
        vaultId: _ids.newId(),
        createdAt: clock.nowUtc(),
        formatVersion: targetVersion,
        encryption: encrypted ? encryptionEnvelopeV1 : encryptionNoneDevOnly,
      );
      await sink.create(header.encode());
      _state = VaultState(header);
      _readOnly = false;
      _tailOpen = false;
      return const LoadReport(warnings: []);
    }
    _tailOpen = !text.endsWith('\n');
    _state = parseVaultLog(
      text,
      migrations: migrations,
      targetVersion: targetVersion,
      now: clock.nowUtc,
    );
    // A vault read through a migration is not appended to in the old format;
    // it stays read-only until an upgrade with a checkpoint exists (D-014).
    _readOnly = _s.migrations.isNotEmpty;
    return LoadReport(
      warnings: List.unmodifiable(_s.warnings),
      migrations: List.unmodifiable(_s.migrations),
      readOnly: _readOnly,
    );
  }

  @override
  Future<List<Profile>> profiles() async => _s.profiles.values.toList();

  @override
  Future<void> putProfile(Profile profile) async {
    _checkWritable();
    final line = encodeOp('profile.put', profile.toJson());
    await _append(line);
    _s.apply('profile.put', profile.toJson());
  }

  @override
  Future<void> appendRecord(HealthRecord record) async {
    _checkWritable();
    // Every rule is checked before the write, so the file never receives a
    // line that replay would skip.
    _s.check(record);
    final existing = _s.records[record.id];
    if (existing != null) {
      // Idempotent retry of the same write is fine; a different payload is not.
      _s.apply('record.append', record.toJson());
      return;
    }
    // Write first, then update memory: memory never shows unsaved data.
    await _append(encodeOp('record.append', record.toJson()));
    _s.apply('record.append', record.toJson());
  }

  @override
  Future<List<HealthRecord>> records(
    String profileId, {
    RecordKind? kind,
  }) async => [
    for (final id in _s.order)
      if (_s.records[id]!.profileId == profileId &&
          (kind == null || _s.records[id]!.kind == kind))
        _s.records[id]!,
  ];
}

/// Memory-only sink (tests and platforms without a persistent adapter yet).
class MemoryLogSink implements LogSink, FirstLineReplaceable {
  /// Exposed for tests that simulate restarts or crashes.
  String? text;

  @override
  Future<String?> read() async => text;

  @override
  Future<void> create(String header) async => text = '$header\n';

  @override
  Future<void> appendLine(String line) async => text = '${text ?? ''}$line\n';

  @override
  Future<void> replaceFirstLine(String line) async {
    final t = text ?? '';
    final cut = t.indexOf('\n');
    text = cut < 0 ? '$line\n' : '$line${t.substring(cut)}';
  }
}

LogRepository inMemoryRepository({
  Clock clock = const SystemClock(),
  IdGenerator? ids,
}) => LogRepository(
  sink: MemoryLogSink(),
  durability: StorageDurability.memoryOnly,
  location: 'memory (not saved)',
  clock: clock,
  ids: ids,
);
