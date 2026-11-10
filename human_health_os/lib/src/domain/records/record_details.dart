/// Structured values of measurement kinds (ladder F007, record schema 4).
///
/// Pure Dart. A kind whose value is more than one number keeps it here,
/// tagged with its type, instead of in a single quantity: a blood pressure
/// reading is one record with two numbers, never two records and never one
/// number shown as "the" reading. Every number keeps the text it was typed
/// as. Nothing here is an interpretation: no category, stage or range.
library;

/// The kind-tagged structured value of a record (`details` in JSON). Later
/// structured kinds add a subtype and a `type` value, not a new JSON key.
abstract class RecordDetails {
  const RecordDetails();

  /// Stable tag written as `type`.
  String get type;

  Map<String, Object?> toJson();

  /// Throws [FormatException] for a type this app does not know (written by
  /// a newer app; such a record also carries a newer schema version).
  static RecordDetails fromJson(Map<String, Object?> j) => switch (j['type']) {
    BloodPressureDetails.typeTag => BloodPressureDetails.fromJson(j),
    MedicationItemDetails.typeTag => MedicationItemDetails.fromJson(j),
    MedicationPlanDetails.typeTag => MedicationPlanDetails.fromJson(j),
    MedicationIntakeDetails.typeTag => MedicationIntakeDetails.fromJson(j),
    SleepNightDetails.typeTag => SleepNightDetails.fromJson(j),
    final t => throw FormatException('Unknown details type "$t"'),
  };
}

/// One blood pressure reading: systolic (the upper number) and diastolic
/// (the lower number) in the same unit, each with the text it was typed as.
class BloodPressureDetails extends RecordDetails {
  const BloodPressureDetails({
    required this.systolic,
    required this.diastolic,
    this.unit = 'mmHg',
    this.systolicText,
    this.diastolicText,
  });

  static const String typeTag = 'blood_pressure';

  final double systolic;
  final double diastolic;

  /// As recorded; only mmHg is stored (no conversion rule exists).
  final String unit;

  /// The numbers exactly as typed (e.g. "118"); null when not typed by a
  /// person.
  final String? systolicText;
  final String? diastolicText;

  @override
  String get type => typeTag;

  @override
  Map<String, Object?> toJson() => {
    'type': typeTag,
    'systolic': systolic,
    'diastolic': diastolic,
    'unit': unit,
    'systolic_text': systolicText,
    'diastolic_text': diastolicText,
  };

  static BloodPressureDetails fromJson(Map<String, Object?> j) =>
      BloodPressureDetails(
        systolic: (j['systolic']! as num).toDouble(),
        diastolic: (j['diastolic']! as num).toDouble(),
        unit: j['unit']! as String,
        systolicText: j['systolic_text'] as String?,
        diastolicText: j['diastolic_text'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is BloodPressureDetails &&
      other.systolic == systolic &&
      other.diastolic == diastolic &&
      other.unit == unit &&
      other.systolicText == systolicText &&
      other.diastolicText == diastolicText;

  @override
  int get hashCode =>
      Object.hash(systolic, diastolic, unit, systolicText, diastolicText);
}

/// Longest text kept in a medication field, in characters.
const int maxMedicationText = 300;

/// What a medicine or supplement is (F008, record schema 6). Every field is
/// the person's own text, kept as typed: the app holds no drug database, no
/// dose rules and no interaction checks, and says nothing about a product.
abstract class MedicationDetails extends RecordDetails {
  const MedicationDetails();

  /// The first broken rule as a stable code (e.g. `MEDICATION_NAME_EMPTY`),
  /// or null. The record's validation turns it into an error.
  String? problem();

  static String? text(String? v, String code, {bool required = false}) {
    if (v == null) return required ? '${code}_REQUIRED' : null;
    if (v.trim().isEmpty) return '${code}_EMPTY';
    if (v.runes.length > maxMedicationText) return '${code}_TOO_LONG';
    return null;
  }
}

/// Whether a product is a medicine, a supplement or something else, as the
/// person sorts it. Not a regulatory status.
enum MedicationCategory { medicine, supplement, other }

class MedicationItemDetails extends MedicationDetails {
  const MedicationItemDetails({
    required this.name,
    required this.category,
    this.ingredients,
    this.strength,
    this.form,
  });

  static const String typeTag = 'medication_item';

  /// The product name as typed (brand or generic).
  final String name;
  final MedicationCategory category;

  /// Active ingredients as typed (e.g. "cholecalciferol"); the product is
  /// not its ingredients, so this is kept apart and never derived.
  final String? ingredients;

  /// Strength as printed on the pack (e.g. "1000 IU", "500 mg").
  final String? strength;

  /// Form as typed (tablet, capsule, drops...).
  final String? form;

  @override
  String get type => typeTag;

  @override
  String? problem() =>
      MedicationDetails.text(name, 'MEDICATION_NAME', required: true) ??
      MedicationDetails.text(ingredients, 'MEDICATION_INGREDIENTS') ??
      MedicationDetails.text(strength, 'MEDICATION_STRENGTH') ??
      MedicationDetails.text(form, 'MEDICATION_FORM');

  @override
  Map<String, Object?> toJson() => {
    'type': typeTag,
    'name': name,
    'category': category.name,
    'ingredients': ingredients,
    'strength': strength,
    'form': form,
  };

  static MedicationItemDetails fromJson(Map<String, Object?> j) =>
      MedicationItemDetails(
        name: j['name']! as String,
        category: MedicationCategory.values.byName(j['category']! as String),
        ingredients: j['ingredients'] as String?,
        strength: j['strength'] as String?,
        form: j['form'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is MedicationItemDetails &&
      other.name == name &&
      other.category == category &&
      other.ingredients == ingredients &&
      other.strength == strength &&
      other.form == form;

  @override
  int get hashCode => Object.hash(name, category, ingredients, strength, form);
}

/// Who the plan comes from, as the person says. "Prescribed" is not "taken".
enum PlanSource { prescribed, ownChoice, unknown }

/// Whether a plan is followed, paused or stopped, as the person records it.
/// A paused or stopped plan is a new plan record; the earlier one stays.
enum PlanState { active, paused, stopped }

class MedicationPlanDetails extends MedicationDetails {
  const MedicationPlanDetails({
    required this.itemRootId,
    required this.schedule,
    this.source = PlanSource.unknown,
    this.state = PlanState.active,
  });

  static const String typeTag = 'medication_plan';

  /// The first version id of the medicine or supplement this plan is for.
  final String itemRootId;

  /// The plan in the words it was given (e.g. "1 tablet every morning").
  /// Not parsed into times: a plan is never turned into doses.
  final String schedule;
  final PlanSource source;

  /// Active unless the person paused or stopped it (F008 slice 2).
  final PlanState state;

  @override
  String get type => typeTag;

  @override
  String? problem() => itemRootId.isEmpty
      ? 'MEDICATION_ITEM_REQUIRED'
      : MedicationDetails.text(schedule, 'MEDICATION_SCHEDULE', required: true);

  @override
  Map<String, Object?> toJson() => {
    'type': typeTag,
    'item_root_id': itemRootId,
    'schedule': schedule,
    'source': source.name,
    'state': state.name,
  };

  static MedicationPlanDetails fromJson(Map<String, Object?> j) =>
      MedicationPlanDetails(
        itemRootId: j['item_root_id']! as String,
        schedule: j['schedule']! as String,
        source: PlanSource.values.byName(j['source']! as String),
        // Plans written before slice 2 carry no state: they were active.
        state: j['state'] == null
            ? PlanState.active
            : PlanState.values.byName(j['state']! as String),
      );

  @override
  bool operator ==(Object other) =>
      other is MedicationPlanDetails &&
      other.itemRootId == itemRootId &&
      other.schedule == schedule &&
      other.source == source &&
      other.state == state;

  @override
  int get hashCode => Object.hash(itemRootId, schedule, source, state);
}

/// What happened to one dose, as the person records it.
enum IntakeStatus { taken, skipped }

class MedicationIntakeDetails extends MedicationDetails {
  const MedicationIntakeDetails({
    required this.itemRootId,
    required this.status,
    this.amount,
  });

  static const String typeTag = 'medication_intake';

  /// The first version id of the medicine or supplement.
  final String itemRootId;
  final IntakeStatus status;

  /// The amount as typed (e.g. "1 tablet", "2 drops"); null = not given,
  /// never assumed from the plan.
  final String? amount;

  @override
  String get type => typeTag;

  @override
  String? problem() => itemRootId.isEmpty
      ? 'MEDICATION_ITEM_REQUIRED'
      : MedicationDetails.text(amount, 'MEDICATION_AMOUNT');

  @override
  Map<String, Object?> toJson() => {
    'type': typeTag,
    'item_root_id': itemRootId,
    'status': status.name,
    'amount': amount,
  };

  static MedicationIntakeDetails fromJson(Map<String, Object?> j) =>
      MedicationIntakeDetails(
        itemRootId: j['item_root_id']! as String,
        status: IntakeStatus.values.byName(j['status']! as String),
        amount: j['amount'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is MedicationIntakeDetails &&
      other.itemRootId == itemRootId &&
      other.status == status &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(itemRootId, status, amount);
}

/// How the person felt on waking, in their own words. Not a sleep score and
/// not a measure of sleep.
enum WakeFeeling { rested, okay, tired }

/// A night is shorter than this, from going to bed to waking up (the same
/// clock time twice is a slip, not a day in bed).
const Duration maxNightSpan = Duration(hours: 24);

/// One night as the person types it (F007 slice 3, record schema 7): when
/// they went to bed and when they woke up, and optionally how they felt.
/// The time between the two is time in bed, never time asleep: nothing here
/// knows when sleep began or how often it broke.
class SleepNightDetails extends RecordDetails {
  const SleepNightDetails({
    required this.wentToBed,
    required this.wokeUp,
    this.feeling,
  });

  static const String typeTag = 'sleep_night';

  /// UTC instants.
  final DateTime wentToBed;
  final DateTime wokeUp;

  /// Null = not said; never assumed.
  final WakeFeeling? feeling;

  /// Rule `sleep.time_in_bed` v1: waking time minus going-to-bed time.
  Duration get timeInBed => wokeUp.difference(wentToBed);

  @override
  String get type => typeTag;

  /// The first broken rule as a stable code, or null.
  String? problem() => !wokeUp.isAfter(wentToBed)
      ? 'SLEEP_WAKE_NOT_AFTER_BED'
      : timeInBed >= maxNightSpan
      ? 'SLEEP_TOO_LONG'
      : null;

  @override
  Map<String, Object?> toJson() => {
    'type': typeTag,
    'went_to_bed': wentToBed.toUtc().toIso8601String(),
    'woke_up': wokeUp.toUtc().toIso8601String(),
    'feeling': feeling?.name,
  };

  static SleepNightDetails fromJson(Map<String, Object?> j) =>
      SleepNightDetails(
        wentToBed: DateTime.parse(j['went_to_bed']! as String).toUtc(),
        wokeUp: DateTime.parse(j['woke_up']! as String).toUtc(),
        feeling: switch (j['feeling']) {
          null => null,
          final String f => WakeFeeling.values.byName(f),
          final f => throw FormatException('Unknown feeling "$f"'),
        },
      );

  @override
  bool operator ==(Object other) =>
      other is SleepNightDetails &&
      other.wentToBed == wentToBed &&
      other.wokeUp == wokeUp &&
      other.feeling == feeling;

  @override
  int get hashCode => Object.hash(wentToBed, wokeUp, feeling);
}
