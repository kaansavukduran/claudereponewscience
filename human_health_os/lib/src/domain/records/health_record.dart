/// Canonical health record envelope (docs/DATA_MODEL.md).
///
/// Pure Dart: no Flutter, IO or platform imports. Every invariant that can be
/// checked locally is enforced by [HealthRecord.validate]:
/// - a PRESENT value always has a quantity; any other value status never has one
///   (missing ≠ zero);
/// - corrections are new records that point at what they supersede;
/// - the original source representation is kept next to the normalized value.
library;

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
  bodyWeight('body.weight');

  const RecordKind(this.code);
  final String code;

  static RecordKind fromCode(String code) => RecordKind.values.firstWhere(
    (k) => k.code == code,
    orElse: () => throw FormatException('Unknown record kind "$code"'),
  );
}

class Quantity {
  const Quantity(this.value, this.unit);

  final double value;

  /// UCUM-style unit code as recorded (e.g. `kg`). Never converted silently.
  final String unit;

  Map<String, Object?> toJson() => {'value': value, 'unit': unit};

  static Quantity fromJson(Map<String, Object?> j) =>
      Quantity((j['value']! as num).toDouble(), j['unit']! as String);

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
class SchemaTooNewError implements Exception {
  const SchemaTooNewError(this.what, this.version, this.supported);

  final String what;
  final int version;
  final int supported;

  @override
  String toString() =>
      'SchemaTooNewError: $what schema $version is newer than this app ($supported)';
}

class RecordValidationError implements Exception {
  const RecordValidationError(this.code, this.message);

  /// Stable machine code (e.g. `PRESENT_REQUIRES_QUANTITY`).
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
    this.deletedAt,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 1;

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
  final DateTime? deletedAt;
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
    }
  }

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
    'deleted_at': deletedAt?.toIso8601String(),
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
      deletedAt: j['deleted_at'] == null
          ? null
          : DateTime.parse(j['deleted_at']! as String).toUtc(),
    );
  }
}

/// Resolves correction chains: returns records that are neither superseded
/// nor deleted, newest observation first. History stays in the store.
List<HealthRecord> currentRecords(Iterable<HealthRecord> all) {
  final superseded = {for (final r in all) ?r.supersedesId};
  final current =
      [
        for (final r in all)
          if (!superseded.contains(r.id) && r.deletedAt == null) r,
      ]..sort((a, b) {
        final byTime = b.observedAt.compareTo(a.observedAt);
        return byTime != 0 ? byTime : b.recordedAt.compareTo(a.recordedAt);
      });
  return current;
}
