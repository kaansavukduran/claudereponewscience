/// HealthRepository implemented on top of the vault log, parameterised by a
/// tiny byte sink so the same logic serves memory, files and browser storage.
library;

import '../../core/ids.dart';
import '../../domain/ports/health_repository.dart';
import '../../domain/profile/profile.dart';
import '../../domain/records/health_record.dart';
import 'vault_log.dart';

/// Where the log text lives.
abstract interface class LogSink {
  /// Whole log text, or null when no vault exists yet.
  Future<String?> read();

  /// Creates a new log with exactly [text] (the header line).
  Future<void> create(String text);

  /// Appends one line durably.
  Future<void> appendLine(String line);
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
  VaultState? _state;
  bool _readOnly = false;

  @override
  bool get writable => _state != null && !_readOnly;

  void _checkWritable() {
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
    encrypted: false,
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
      );
      await sink.create(header.encode());
      _state = VaultState(header);
      _readOnly = false;
      return const LoadReport(warnings: []);
    }
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
    await sink.appendLine(line);
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
    await sink.appendLine(encodeOp('record.append', record.toJson()));
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
class MemoryLogSink implements LogSink {
  /// Exposed for tests that simulate restarts or crashes.
  String? text;

  @override
  Future<String?> read() async => text;

  @override
  Future<void> create(String header) async => text = '$header\n';

  @override
  Future<void> appendLine(String line) async => text = '${text ?? ''}$line\n';
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
