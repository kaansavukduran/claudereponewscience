/// FORGE 002 use cases: a local SELF profile and canonical body-weight
/// observations through the [HealthRepository] port.
library;

import '../core/ids.dart';
import '../domain/ports/health_repository.dart';
import '../domain/profile/profile.dart';
import '../domain/records/health_record.dart';

class InputError implements Exception {
  const InputError(this.code);

  /// Stable code; the UI maps it to localized text.
  /// `EMPTY` · `NOT_A_NUMBER` · `OUT_OF_RANGE` · `FUTURE_TIME`
  final String code;

  @override
  String toString() => 'InputError($code)';
}

/// Parses user text such as `78.4`, `78,4` or ` 78 `. Blank input is an error,
/// never zero (missing ≠ zero).
double parseDecimal(String raw) {
  final t = raw.trim().replaceAll(' ', '');
  if (t.isEmpty) throw const InputError('EMPTY');
  if (!RegExp(r'^\d+([.,]\d+)?$').hasMatch(t)) {
    throw const InputError('NOT_A_NUMBER');
  }
  return double.parse(t.replaceAll(',', '.'));
}

class HeartbeatService {
  HeartbeatService(
    this.repository, {
    this.clock = const SystemClock(),
    IdGenerator? ids,
  }) : _ids = ids ?? UuidV4Generator();

  final HealthRepository repository;
  final Clock clock;
  final IdGenerator _ids;

  /// Returns the existing SELF profile, or creates one the first time.
  /// The id lives inside the vault, so the same profile survives restarts
  /// and moving a portable folder.
  Future<Profile> ensureSelfProfile() async {
    final existing = (await repository.profiles()).where(
      (p) => p.type == ProfileType.self,
    );
    if (existing.isNotEmpty) return existing.first;
    final p = Profile(
      id: _ids.newId(),
      type: ProfileType.self,
      createdAt: clock.nowUtc(),
    );
    await repository.putProfile(p);
    return p;
  }

  /// Records a manually entered body weight in kg as an OBSERVED fact.
  Future<HealthRecord> recordWeightKg({
    required String profileId,
    required String input,
    DateTime? observedAt,
  }) async {
    final value = parseDecimal(input);
    if (value <= 0 || value > 700) throw const InputError('OUT_OF_RANGE');
    final now = clock.nowUtc();
    final when = (observedAt ?? now).toUtc();
    if (when.isAfter(now.add(const Duration(minutes: 5)))) {
      throw const InputError('FUTURE_TIME');
    }
    final record = HealthRecord(
      id: _ids.newId(),
      profileId: profileId,
      kind: RecordKind.bodyWeight,
      state: RecordState.observed,
      valueStatus: ValueStatus.present,
      quantity: Quantity(value, 'kg'),
      originalText: input.trim(),
      provenance: const Provenance.manual(),
      observedAt: when,
      recordedAt: now,
    );
    await repository.appendRecord(record);
    return record;
  }

  /// Current (not superseded, not deleted) weights, newest first.
  Future<List<HealthRecord>> currentWeights(String profileId) async =>
      currentRecords(
        await repository.records(profileId, kind: RecordKind.bodyWeight),
      );
}
