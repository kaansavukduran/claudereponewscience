/// Canonical health record envelope (docs/DATA_MODEL.md).
///
/// Pure Dart: no Flutter, IO or platform imports. Every invariant that can be
/// checked locally is enforced by [HealthRecord.validate]:
/// - a PRESENT value always has a quantity; any other value status never has one
///   (missing ≠ zero);
/// - corrections are new records that point at what they supersede, and say
///   why ([AmendReason]); nothing is edited in place;
/// - the original source representation is kept next to the normalized value.
library;

import '../errors.dart';
import 'lab_details.dart';
import 'timeline.dart';

export 'lab_details.dart';
export 'timeline.dart';

/// What kind of truth a record represents. Never collapse these.
enum RecordState {
  observed,
  reported,
  planned,
  completed,
  derived,
  modelled,
  assumed,
  unknown,
}

/// Whether a value exists. Anything other than [present] carries no number.
enum ValueStatus { present, notReported, notMeasured, notApplicable, unknown }

/// Where a record came from.
enum ProvenanceKind {
  manual,
  device,
  provider,
  document,
  api,
  derived,
  modelled,
  imported,
  unknown,
}

/// Record kinds implemented so far. New kinds are added per FORGE.
enum RecordKind {
  bodyWeight('body.weight'),

  /// A laboratory result as printed (F004, record schema 3).
  labResult('lab.result');

  const RecordKind(this.code);
  final String code;

  static RecordKind fromCode(String code) => RecordKind.values.firstWhere(
    (k) => k.code == code,
    orElse: () => throw FormatException('Unknown record kind "$code"'),
  );
}

/// Why a record points at an earlier one (record schema 2, ladder F003).
/// See `timeline.dart` for how each reason changes what is current.
enum AmendReason {
  /// A better value for the same observation; the earlier version stays in
  /// history.
  correction('correction'),

  /// The target should never have been saved. It stops counting (if it was
  /// a correction, the previous version counts again) and stays in history
  /// marked as withdrawn.
  enteredInError('entered_in_error'),

  /// The person removed a true record. The whole fact leaves every view and
  /// stays in history as deleted (tombstone); later versions cannot bring
  /// it back.
  deleted('deleted');

  const AmendReason(this.code);
  final String code;

  static AmendReason fromCode(String code) => AmendReason.values.firstWhere(
    (r) => r.code == code,
    orElse: () => throw FormatException('Unknown amend reason "$code"'),
  );

  /// Withdraws or deletes its target instead of carrying a health value.
  bool get isMarker => this != correction;
}

class Quantity {
  const Quantity(this.value, this.unit);

  final double value;

  /// Unit as recorded (e.g. `kg`, or a lab's printed `mg/dL`). Never
  /// converted silently. Null only for a lab result whose report printed no
  /// unit: a missing unit stays missing (F004); body weight always has one.
  final String? unit;

  Map<String, Object?> toJson() => {'value': value, 'unit': unit};

  static Quantity fromJson(Map<String, Object?> j) =>
      Quantity((j['value']! as num).toDouble(), j['unit'] as String?);

  @override
  bool operator ==(Object other) =>
      other is Quantity && other.value == value && other.unit == unit;

  @override
  int get hashCode => Object.hash(value, unit);
}

class Provenance {
  const Provenance({
    required this.kind,
    this.sourceId,
    this.sourceVersion,
    this.deviceId,
  });

  const Provenance.manual() : this(kind: ProvenanceKind.manual);

  final ProvenanceKind kind;
  final String? sourceId;
  final String? sourceVersion;
  final String? deviceId;

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    if (sourceId != null) 'source_id': sourceId,
    if (sourceVersion != null) 'source_version': sourceVersion,
    if (deviceId != null) 'device_id': deviceId,
  };

  static Provenance fromJson(Map<String, Object?> j) => Provenance(
    kind: ProvenanceKind.values.byName(j['kind']! as String),
    sourceId: j['source_id'] as String?,
    sourceVersion: j['source_version'] as String?,
    deviceId: j['device_id'] as String?,
  );
}

/// Data written by a newer app version. It is never guessed at or
/// downgraded (master §35.3); the store that holds it refuses to open.
class SchemaTooNewError implements Exception, CodedError {
  const SchemaTooNewError(this.what, this.version, this.supported);

  @override
  String get code => 'SCHEMA_TOO_NEW';

  final String what;
  final int version;
  final int supported;

  @override
  String toString() =>
      'SchemaTooNewError: $what schema $version is newer than this app ($supported)';
}

class RecordValidationError implements Exception, CodedError {
  const RecordValidationError(this.code, this.message);

  /// Stable machine code (e.g. `PRESENT_REQUIRES_QUANTITY`).
  @override
  final String code;
  final String message;

  @override
  String toString() => 'RecordValidationError($code): $message';
}

class HealthRecord {
  const HealthRecord({
    required this.id,
    required this.profileId,
    required this.kind,
    required this.state,
    required this.valueStatus,
    required this.quantity,
    required this.originalText,
    required this.provenance,
    required this.observedAt,
    required this.recordedAt,
    this.supersedesId,
    this.amendReason,
    this.deletedAt,
    this.lab,
    this.schemaVersion = currentSchemaVersion,
  });

  /// Record schema history (master §35.1). Each version reads every older
  /// one without rewriting it:
  /// - 1 (FORGE 002): the envelope; `supersedes_id` alone means correction.
  /// - 2 (F003): adds `amend_reason` (correction, entered in error, deleted).
  ///   A schema 1 record has no reason; one with `supersedes_id` is read as
  ///   a correction.
  /// - 3 (F004): adds the `lab.result` kind with `lab` details and allows a
  ///   lab value without a unit. Older records read unchanged.
  static const int currentSchemaVersion = 3;

  final String id;
  final String profileId;
  final RecordKind kind;
  final RecordState state;
  final ValueStatus valueStatus;
  final Quantity? quantity;

  /// The value exactly as the user or source wrote it (e.g. "78,4").
  final String? originalText;
  final Provenance provenance;

  /// When it happened (UTC).
  final DateTime observedAt;

  /// When it was entered (UTC).
  final DateTime recordedAt;
  final String? supersedesId;

  /// Why [supersedesId] is set (schema 2). Null on schema 1 records.
  final AmendReason? amendReason;
  final DateTime? deletedAt;

  /// The printed lab details of a [RecordKind.labResult] (schema 3).
  final LabDetails? lab;

  /// [observedAt] is a calendar day (UTC midnight of that day), not an
  /// instant: lab sample dates. Shown without a time-zone shift.
  bool get observedDateOnly => kind == RecordKind.labResult;
  final int schemaVersion;

  /// Throws [RecordValidationError] when an invariant is violated.
  void validate() {
    if (id.isEmpty || profileId.isEmpty) {
      throw const RecordValidationError(
        'MISSING_ID',
        'id and profileId are required',
      );
    }
    if (valueStatus == ValueStatus.present && quantity == null) {
      throw const RecordValidationError(
        'PRESENT_REQUIRES_QUANTITY',
        'A present value needs a quantity',
      );
    }
    if (valueStatus != ValueStatus.present && quantity != null) {
      throw const RecordValidationError(
        'MISSING_HAS_NO_QUANTITY',
        'A missing value cannot carry a number (missing ≠ zero)',
      );
    }
    if (!observedAt.isUtc || !recordedAt.isUtc) {
      throw const RecordValidationError(
        'NON_UTC_TIME',
        'Timestamps are stored in UTC',
      );
    }
    if (supersedesId != null && supersedesId == id) {
      throw const RecordValidationError(
        'SELF_SUPERSEDE',
        'A record cannot supersede itself',
      );
    }
    final reason = amendReason;
    if (reason != null && supersedesId == null) {
      throw const RecordValidationError(
        'AMEND_NEEDS_TARGET',
        'An amendment must name the record it amends',
      );
    }
    if (schemaVersion >= 2 && supersedesId != null && reason == null) {
      throw const RecordValidationError(
        'AMEND_REASON_REQUIRED',
        'Say why a record supersedes another (schema 2)',
      );
    }
    if (reason != null && reason.isMarker) {
      if (valueStatus != ValueStatus.notApplicable || quantity != null) {
        throw const RecordValidationError(
          'MARKER_HAS_NO_VALUE',
          'Withdrawing or deleting a record carries no health value',
        );
      }
    }
    if (schemaVersion >= 2 &&
        (deletedAt != null) != (reason == AmendReason.deleted)) {
      throw const RecordValidationError(
        'DELETE_TIME_MISMATCH',
        'Only a deletion carries a deletion time, and it always does',
      );
    }
    if (reason != null && reason.isMarker) {
      if (lab != null) {
        throw const RecordValidationError(
          'MARKER_HAS_NO_VALUE',
          'Withdrawing or deleting a record carries no lab details',
        );
      }
      return;
    }
    final q = quantity;
    if (q != null && q.unit == null && kind != RecordKind.labResult) {
      throw const RecordValidationError(
        'UNIT_REQUIRED',
        'Only a lab result may lack a unit',
      );
    }
    if ((lab != null) != (kind == RecordKind.labResult)) {
      throw const RecordValidationError(
        'LAB_DETAILS_MISMATCH',
        'Lab details belong to lab results, and every lab result has them',
      );
    }
    switch (kind) {
      case RecordKind.bodyWeight:
        final q = quantity;
        if (q == null) break;
        if (q.unit != 'kg') {
          throw RecordValidationError(
            'UNIT_NOT_SUPPORTED',
            'body.weight is stored in kg; "${q.unit}" needs an explicit conversion rule',
          );
        }
        if (!q.value.isFinite || q.value <= 0 || q.value > 700) {
          throw const RecordValidationError(
            'OUT_OF_PLAUSIBLE_RANGE',
            'Body weight must be between 0 and 700 kg',
          );
        }
      case RecordKind.labResult:
        // No plausibility range: the app holds no clinical thresholds. Only
        // a finite number and the printed name are required.
        final v = quantity?.value;
        if (v != null && !v.isFinite) {
          throw const RecordValidationError(
            'VALUE_NOT_FINITE',
            'A lab value must be a finite number',
          );
        }
        if (lab!.analyteLabel.trim().isEmpty) {
          throw const RecordValidationError(
            'LAB_ANALYTE_REQUIRED',
            'A lab result needs the test name as printed',
          );
        }
    }
  }

  /// Written in the shape of [schemaVersion], so an old record keeps its
  /// exact bytes when it is compared or exported again.
  Map<String, Object?> toJson() => {
    'schema_version': schemaVersion,
    'id': id,
    'profile_id': profileId,
    'kind': kind.code,
    'state': state.name,
    'value_status': valueStatus.name,
    'quantity': quantity?.toJson(),
    'original_text': originalText,
    'provenance': provenance.toJson(),
    'observed_at': observedAt.toIso8601String(),
    'recorded_at': recordedAt.toIso8601String(),
    'supersedes_id': supersedesId,
    if (schemaVersion >= 2) 'amend_reason': amendReason?.code,
    'deleted_at': deletedAt?.toIso8601String(),
    if (schemaVersion >= 3) 'lab': lab?.toJson(),
  };

  static HealthRecord fromJson(Map<String, Object?> j) {
    final version = (j['schema_version'] as num?)?.toInt() ?? 1;
    if (version > currentSchemaVersion) {
      throw SchemaTooNewError('record', version, currentSchemaVersion);
    }
    final q = j['quantity'];
    return HealthRecord(
      schemaVersion: version,
      id: j['id']! as String,
      profileId: j['profile_id']! as String,
      kind: RecordKind.fromCode(j['kind']! as String),
      state: RecordState.values.byName(j['state']! as String),
      valueStatus: ValueStatus.values.byName(j['value_status']! as String),
      quantity: q == null
          ? null
          : Quantity.fromJson((q as Map).cast<String, Object?>()),
      originalText: j['original_text'] as String?,
      provenance: Provenance.fromJson(
        (j['provenance']! as Map).cast<String, Object?>(),
      ),
      observedAt: DateTime.parse(j['observed_at']! as String).toUtc(),
      recordedAt: DateTime.parse(j['recorded_at']! as String).toUtc(),
      supersedesId: j['supersedes_id'] as String?,
      amendReason: j['amend_reason'] == null
          ? null
          : AmendReason.fromCode(j['amend_reason']! as String),
      deletedAt: j['deleted_at'] == null
          ? null
          : DateTime.parse(j['deleted_at']! as String).toUtc(),
      lab: j['lab'] == null
          ? null
          : LabDetails.fromJson((j['lab']! as Map).cast<String, Object?>()),
    );
  }
}

/// The current versions (newest observation first): the heads of every live
/// timeline entry. In a conflict both competing versions are returned.
/// History stays in the store (see `timeline.dart`).
List<HealthRecord> currentRecords(Iterable<HealthRecord> all) => [
  for (final e in buildTimeline(all)) ...e.heads,
];
