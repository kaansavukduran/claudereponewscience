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
    FeelingCheckInDetails.typeTag => FeelingCheckInDetails.fromJson(j),
    FoodEntryDetails.typeTag => FoodEntryDetails.fromJson(j),
    ActivityEntryDetails.typeTag => ActivityEntryDetails.fromJson(j),
    ConditionEntryDetails.typeTag => ConditionEntryDetails.fromJson(j),
    PreventiveEntryDetails.typeTag => PreventiveEntryDetails.fromJson(j),
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

/// A level the person picks for themselves. Not a measurement, not a score
/// and not a diagnosis: the same word means what the person meant.
enum SelfLevel { low, medium, high }

/// The three questions of a check-in.
enum FeelingQuestion { energy, mood, stress }

/// How the person says they feel now (F007 slice 4, record schema 8):
/// energy, mood and stress, each optional, at least one given. A level not
/// given is not given, never "medium".
class FeelingCheckInDetails extends RecordDetails {
  const FeelingCheckInDetails({this.energy, this.mood, this.stress});

  static const String typeTag = 'feeling_check_in';

  final SelfLevel? energy;
  final SelfLevel? mood;
  final SelfLevel? stress;

  @override
  String get type => typeTag;

  String? problem() =>
      energy == null && mood == null && stress == null ? 'CHECKIN_EMPTY' : null;

  @override
  Map<String, Object?> toJson() => {
    'type': typeTag,
    'energy': energy?.name,
    'mood': mood?.name,
    'stress': stress?.name,
  };

  static SelfLevel? _level(Object? v) => switch (v) {
    null => null,
    final String n =>
      SelfLevel.values.asNameMap()[n] ??
          (throw FormatException('Unknown level "$n"')),
    final x => throw FormatException('Unknown level "$x"'),
  };

  static FeelingCheckInDetails fromJson(Map<String, Object?> j) =>
      FeelingCheckInDetails(
        energy: _level(j['energy']),
        mood: _level(j['mood']),
        stress: _level(j['stress']),
      );

  @override
  bool operator ==(Object other) =>
      other is FeelingCheckInDetails &&
      other.energy == energy &&
      other.mood == mood &&
      other.stress == stress;

  @override
  int get hashCode => Object.hash(energy, mood, stress);
}

/// The nutrients a label usually prints, each kept as printed.
/// Energy is kept in the unit the label prints it in (kcal or kJ, never
/// converted); the others in grams.
enum PrintedNutrient {
  energyKcal,
  energyKj,
  protein,
  carbohydrate,
  fat,
  fibre,
  salt,
}

/// The only unit kept for each printed nutrient.
String printedNutrientUnit(PrintedNutrient n) => switch (n) {
  PrintedNutrient.energyKcal => 'kcal',
  PrintedNutrient.energyKj => 'kJ',
  _ => 'g',
};

/// What the label's numbers are per. A label value is not the amount eaten:
/// "per 100 g" stays per 100 g, whatever the person ate.
enum LabelBasis { per100g, per100ml, perServing, perPack, notStated }

/// Something eaten or drunk, as the person types it (F007 slice 5, record
/// schema 9): what it was, how much, and any nutrient values the person
/// copies from a label, each kept as typed. A nutrient not given is missing,
/// never zero; the app holds no food database and computes nothing.
class FoodEntryDetails extends RecordDetails {
  const FoodEntryDetails({
    required this.what,
    this.amount,
    this.nutrients = const {},
    this.per,
  });

  static const String typeTag = 'food_entry';

  /// What it was, as typed (e.g. "lentil soup").
  final String what;

  /// How much, as typed (e.g. "1 bowl", "250 g"); null = not given.
  final String? amount;

  /// Values as typed (e.g. "12,5", with "," or "." as the decimal mark),
  /// only for the nutrients given; per [per], never per the amount eaten.
  final Map<PrintedNutrient, String> nutrients;

  /// What the label values are per; required when any is given.
  final LabelBasis? per;

  @override
  String get type => typeTag;

  String? problem() {
    final t =
        MedicationDetails.text(what, 'FOOD_WHAT', required: true) ??
        MedicationDetails.text(amount, 'FOOD_AMOUNT');
    if (t != null) return t;
    for (final v in nutrients.values) {
      if (parsePrintedNumber(v) == null) return 'FOOD_NUTRIENT_NOT_A_NUMBER';
    }
    if (nutrients.isNotEmpty && per == null) return 'FOOD_LABEL_BASIS_REQUIRED';
    return null;
  }

  @override
  Map<String, Object?> toJson() => {
    'type': typeTag,
    'what': what,
    'amount': amount,
    'nutrients': {for (final e in nutrients.entries) e.key.name: e.value},
    'per': per?.name,
  };

  static FoodEntryDetails fromJson(Map<String, Object?> j) {
    final raw = (j['nutrients'] as Map?)?.cast<String, Object?>() ?? const {};
    final names = PrintedNutrient.values.asNameMap();
    return FoodEntryDetails(
      what: j['what']! as String,
      amount: j['amount'] as String?,
      per: switch (j['per']) {
        null => null,
        final String p =>
          LabelBasis.values.asNameMap()[p] ??
              (throw FormatException('Unknown label basis "$p"')),
        final p => throw FormatException('Unknown label basis "$p"'),
      },
      nutrients: {
        for (final e in raw.entries)
          (names[e.key] ??
                  (throw FormatException('Unknown nutrient "${e.key}"'))):
              e.value! as String,
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FoodEntryDetails &&
      other.what == what &&
      other.amount == amount &&
      other.per == per &&
      other.nutrients.length == nutrients.length &&
      nutrients.entries.every((e) => other.nutrients[e.key] == e.value);

  @override
  int get hashCode => Object.hash(
    what,
    amount,
    per,
    Object.hashAllUnordered([
      for (final e in nutrients.entries) Object.hash(e.key, e.value),
    ]),
  );
}

/// A non-negative number as typed on a label: up to 7 digits, with one "."
/// or "," as the decimal mark and up to 4 decimals; null when it is not one.
double? parsePrintedNumber(String text) {
  final t = text.trim();
  if (!RegExp(r'^\d{1,7}([.,]\d{1,4})?$').hasMatch(t)) return null;
  return double.parse(t.replaceAll(',', '.'));
}

/// Longest single activity kept, in minutes (a day).
const int maxActivityMinutes = 1440;

/// Most steps kept for one entry.
const int maxActivitySteps = 200000;

/// One activity as the person types it (F007 slice 6, record schema 10):
/// what it was, and optionally how many minutes and how many steps, as
/// whole numbers. Typed by hand, so nothing is de-duplicated or summed with
/// a device; a value not given is missing, never zero; no calories are
/// estimated.
class ActivityEntryDetails extends RecordDetails {
  const ActivityEntryDetails({required this.what, this.minutes, this.steps});

  static const String typeTag = 'activity_entry';

  /// What it was, as typed (e.g. "walk", "squats").
  final String what;
  final int? minutes;
  final int? steps;

  @override
  String get type => typeTag;

  String? problem() =>
      MedicationDetails.text(what, 'ACTIVITY_WHAT', required: true) ??
      (minutes != null && (minutes! < 1 || minutes! > maxActivityMinutes)
          ? 'ACTIVITY_MINUTES_RANGE'
          : steps != null && (steps! < 1 || steps! > maxActivitySteps)
          ? 'ACTIVITY_STEPS_RANGE'
          : null);

  @override
  Map<String, Object?> toJson() => {
    'type': typeTag,
    'what': what,
    'minutes': minutes,
    'steps': steps,
  };

  /// A whole number as stored (an integral 20.0 from another writer reads
  /// as 20); anything else is a format error, not a crash.
  static int? _whole(Object? v) => switch (v) {
    null => null,
    final int i => i,
    final num n when n == n.truncate() => n.toInt(),
    final x => throw FormatException('Not a whole number: "$x"'),
  };

  static ActivityEntryDetails fromJson(Map<String, Object?> j) =>
      ActivityEntryDetails(
        what: switch (j['what']) {
          final String w => w,
          final x => throw FormatException('Activity without text: "$x"'),
        },
        minutes: _whole(j['minutes']),
        steps: _whole(j['steps']),
      );

  @override
  bool operator ==(Object other) =>
      other is ActivityEntryDetails &&
      other.what == what &&
      other.minutes == minutes &&
      other.steps == steps;

  @override
  int get hashCode => Object.hash(what, minutes, steps);
}

/// Whether the person records a condition or a symptom.
enum ConditionType { condition, symptom }

/// Whether it is current, in the past, or the person is not sure.
enum ConditionTime { current, past, unsure }

/// Who the person says it comes from. The app never confirms anything: a
/// self-report is not a diagnosis, and "told by a clinician" is what the
/// person says they were told, not a clinical record.
enum ConditionSource { selfReported, toldByClinician, fromDocument }

/// A condition or a symptom as the person names it (F009 slice 1, record
/// schema 11): the name as typed, whether it is current, past or unsure,
/// who it comes from, and since when as typed. No coding, no inference.
class ConditionEntryDetails extends RecordDetails {
  const ConditionEntryDetails({
    required this.name,
    required this.nature,
    required this.time,
    required this.source,
    this.since,
  });

  static const String typeTag = 'condition_entry';

  final String name;
  final ConditionType nature;
  final ConditionTime time;
  final ConditionSource source;

  /// Since when, as typed (e.g. "2019", "childhood"); null = not given.
  final String? since;

  @override
  String get type => typeTag;

  String? problem() =>
      MedicationDetails.text(name, 'CONDITION_NAME', required: true) ??
      MedicationDetails.text(since, 'CONDITION_SINCE');

  @override
  Map<String, Object?> toJson() => {
    'type': typeTag,
    'name': name,
    'nature': nature.name,
    'time': time.name,
    'source': source.name,
    'since': since,
  };

  static T _pick<T extends Enum>(List<T> values, Object? v, String what) =>
      switch (v) {
        final String n when values.asNameMap().containsKey(n) =>
          values.asNameMap()[n]!,
        final x => throw FormatException('Unknown $what "$x"'),
      };

  static ConditionEntryDetails fromJson(Map<String, Object?> j) =>
      ConditionEntryDetails(
        name: switch (j['name']) {
          final String n => n,
          final x => throw FormatException('Condition without a name: "$x"'),
        },
        nature: _pick(ConditionType.values, j['nature'], 'condition nature'),
        time: _pick(ConditionTime.values, j['time'], 'condition time'),
        source: _pick(ConditionSource.values, j['source'], 'condition source'),
        since: switch (j['since']) {
          null => null,
          final String s => s,
          final x => throw FormatException('Bad condition since "$x"'),
        },
      );

  @override
  bool operator ==(Object other) =>
      other is ConditionEntryDetails &&
      other.name == name &&
      other.nature == nature &&
      other.time == time &&
      other.source == source &&
      other.since == since;

  @override
  int get hashCode => Object.hash(name, nature, time, source, since);
}

/// What kind of preventive item the person records.
enum PreventiveType { vaccination, screening, checkup, other }

/// Whether the person says it was done, is planned, or is not sure. Planned
/// is never done; a missing state is not chosen for them.
enum PreventiveStatus { done, planned, unsure }

/// A preventive item as the person names it (F009 slice 2, record schema
/// 12): a vaccination, a screening, a check-up or something else, whether it
/// was done, is planned or the person is not sure, who it comes from, and
/// when as typed. No result or interpretation is stored (screening is not
/// diagnosis); the app recommends nothing, keeps no schedule, sets no due
/// dates and sends no reminders.
class PreventiveEntryDetails extends RecordDetails {
  const PreventiveEntryDetails({
    required this.name,
    required this.nature,
    required this.status,
    required this.source,
    this.when,
  });

  static const String typeTag = 'preventive_entry';

  final String name;
  final PreventiveType nature;
  final PreventiveStatus status;
  final ConditionSource source;

  /// When, as typed (e.g. "2024-05", "last spring"); null = not given,
  /// which is missing, never "never".
  final String? when;

  @override
  String get type => typeTag;

  String? problem() =>
      MedicationDetails.text(name, 'PREVENTIVE_NAME', required: true) ??
      MedicationDetails.text(when, 'PREVENTIVE_WHEN');

  @override
  Map<String, Object?> toJson() => {
    'type': typeTag,
    'name': name,
    'nature': nature.name,
    'status': status.name,
    'source': source.name,
    'when': when,
  };

  static T _pick<T extends Enum>(List<T> values, Object? v, String what) =>
      switch (v) {
        final String n when values.asNameMap().containsKey(n) =>
          values.asNameMap()[n]!,
        final x => throw FormatException('Unknown $what "$x"'),
      };

  static PreventiveEntryDetails fromJson(
    Map<String, Object?> j,
  ) => PreventiveEntryDetails(
    name: switch (j['name']) {
      final String n => n,
      final x => throw FormatException('Preventive item without a name: "$x"'),
    },
    nature: _pick(PreventiveType.values, j['nature'], 'preventive nature'),
    status: _pick(PreventiveStatus.values, j['status'], 'preventive status'),
    source: _pick(ConditionSource.values, j['source'], 'preventive source'),
    when: switch (j['when']) {
      null => null,
      final String s => s,
      final x => throw FormatException('Bad preventive when "$x"'),
    },
  );

  @override
  bool operator ==(Object other) =>
      other is PreventiveEntryDetails &&
      other.name == name &&
      other.nature == nature &&
      other.status == status &&
      other.source == source &&
      other.when == when;

  @override
  int get hashCode => Object.hash(name, nature, status, source, when);
}
