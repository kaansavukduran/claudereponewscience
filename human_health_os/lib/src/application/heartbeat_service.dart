/// Record use cases: a local SELF profile, canonical body-weight observations
/// (F002) and their timeline with corrections, withdrawals and deletions
/// (F003), all through the [HealthRepository] port.
library;

import '../core/ids.dart';
import '../domain/ports/health_repository.dart';
import '../domain/profile/profile.dart';
import '../domain/records/health_record.dart';

class InputError implements Exception {
  const InputError(this.code);

  /// Stable code; the UI maps it to localized text.
  /// `EMPTY` · `NOT_A_NUMBER` · `OUT_OF_RANGE` · `FUTURE_TIME` ·
  /// `TARGET_NOT_FOUND` · `TARGET_NOT_CURRENT`
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

  double _weightKg(String input) {
    final value = parseDecimal(input);
    if (value <= 0 || value > 700) throw const InputError('OUT_OF_RANGE');
    return value;
  }

  /// Records a manually entered body weight in kg as an OBSERVED fact.
  Future<HealthRecord> recordWeightKg({
    required String profileId,
    required String input,
    DateTime? observedAt,
  }) async {
    final value = _weightKg(input);
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

  /// Current weights (heads of live entries), newest first.
  Future<List<HealthRecord>> currentWeights(String profileId) async =>
      currentRecords(
        await repository.records(profileId, kind: RecordKind.bodyWeight),
      );

  /// Body-weight timeline entries, newest first (ladder F003).
  Future<List<TimelineEntry>> weightTimeline(String profileId) async =>
      buildTimeline(
        await repository.records(profileId, kind: RecordKind.bodyWeight),
      );

  /// Every fact of the profile on one timeline. [includeHidden] adds deleted
  /// and withdrawn entries (history view).
  Future<List<TimelineEntry>> timeline(
    String profileId, {
    bool includeHidden = false,
  }) async => buildTimeline(
    await repository.records(profileId),
    includeHidden: includeHidden,
  );

  /// The live version [targetId] of a live entry, or an [InputError]. Only
  /// the current version can be amended: amending an older one would fork
  /// the history (conflicts come from sync or import, never from here).
  Future<HealthRecord> _currentTarget(String profileId, String targetId) async {
    final all = await repository.records(profileId);
    if (!all.any((r) => r.id == targetId)) {
      throw const InputError('TARGET_NOT_FOUND');
    }
    for (final e in buildTimeline(all)) {
      for (final h in e.heads) {
        if (h.id == targetId) return h;
      }
    }
    throw const InputError('TARGET_NOT_CURRENT');
  }

  /// Saves a better value for the same observation. The old version stays
  /// in history; the new one is a manual, OBSERVED entry.
  Future<HealthRecord> correctWeightKg({
    required String profileId,
    required String targetId,
    required String input,
  }) async {
    final value = _weightKg(input);
    final target = await _currentTarget(profileId, targetId);
    final record = HealthRecord(
      id: _ids.newId(),
      profileId: profileId,
      kind: target.kind,
      state: RecordState.observed,
      valueStatus: ValueStatus.present,
      quantity: Quantity(value, 'kg'),
      originalText: input.trim(),
      provenance: const Provenance.manual(),
      observedAt: target.observedAt,
      recordedAt: clock.nowUtc(),
      supersedesId: target.id,
      amendReason: AmendReason.correction,
    );
    await repository.appendRecord(record);
    return record;
  }

  /// Withdraws [targetId] as entered in error, or deletes its whole fact
  /// ([AmendReason.deleted]). Appends a marker; nothing is rewritten.
  Future<HealthRecord> amend({
    required String profileId,
    required String targetId,
    required AmendReason reason,
  }) async {
    if (!reason.isMarker) throw ArgumentError.value(reason, 'reason');
    final target = await _currentTarget(profileId, targetId);
    final now = clock.nowUtc();
    final marker = HealthRecord(
      id: _ids.newId(),
      profileId: profileId,
      kind: target.kind,
      state: RecordState.reported,
      valueStatus: ValueStatus.notApplicable,
      quantity: null,
      originalText: null,
      provenance: const Provenance.manual(),
      observedAt: target.observedAt,
      recordedAt: now,
      supersedesId: target.id,
      amendReason: reason,
      deletedAt: reason == AmendReason.deleted ? now : null,
    );
    await repository.appendRecord(marker);
    return marker;
  }
}
