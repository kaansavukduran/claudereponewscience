/// MED-SAFETY-ENGINE-1 v0.22.0 (F011, D-038).
///
/// Dart port of `packages/domain/src/medSafety.ts` (the reference oracle),
/// checked against `contracts/golden_vectors/medication_safety_vectors.json`.
/// Product is not ingredient; plan is not taken; a duplicate ingredient is
/// not a toxicity finding; no rule found is not a guarantee of safety. Every
/// finding carries `guaranteedSafe == false`. The engine never prescribes,
/// stops or changes a dose and never diagnoses; its only actions are the
/// installed rule's `REVIEW_WITH_CLINICIAN`, `SEPARATE_TIMING` or `INFORM`.
///
/// Not wired to any screen. The assessment adds `inputs` and `missingInputs`
/// to the TS shape; finding types, order, amounts and notes are the same.
library;

import 'calc_result.dart' show nonFiniteResultCode;

const String safetyEngineId = 'MED-SAFETY-ENGINE-1';
const String safetyEngineVersion = '0.22.0';

/// Rule identity of the built-in duplicate-ingredient check.
const String duplicateIngredientRuleId = 'RULE-DUPLICATE-INGREDIENT-1';
const String duplicateIngredientRuleVersion = '1';

/// The reference implementation's limitations, verbatim.
const List<String> safetyLimitations = [
  'Synthetic knowledge pack: test-only IDs, not production clinical knowledge.',
  'No rule found ≠ guaranteed safe. This engine never prescribes, stops or changes a dose.',
];

/// Mass units that convert into micrograms. IU never converts without a rule.
const Map<String, double> massToMcg = {'mcg': 1, 'mg': 1000, 'g': 1000000};

String? _str(Object? v) => v as String?;
double? _num(Object? v) => (v as num?)?.toDouble();
List<String> _strings(Object? v) => [
  for (final s in (v as List<Object?>?) ?? const []) s! as String,
];

/// JavaScript `String(n)` for the integral numbers the notes print.
String _jsNum(num n) =>
    n.isFinite && n == n.truncateToDouble() ? n.toInt().toString() : '$n';

/// Reviewed, ambiguous or unknown mapping of a label ingredient.
class IngredientAmount {
  const IngredientAmount({
    required this.ingredientId,
    required this.label,
    required this.amount,
    required this.unit,
    required this.basis,
    required this.mapping,
  });

  factory IngredientAmount.fromJson(Map<String, Object?> j) => IngredientAmount(
    ingredientId: j['ingredient_id']! as String,
    label: j['label']! as String,
    amount: _num(j['amount']),
    unit: _str(j['unit']),
    basis: j['basis']! as String,
    mapping: j['mapping']! as String,
  );

  final String ingredientId;
  final String label;

  /// Per serving; null when the label does not disclose it (never 0).
  final double? amount;
  final String? unit;

  /// Amount basis, e.g. ELEMENTAL vs COMPOUND. Different bases never sum.
  final String basis;

  /// `REVIEWED`, `AMBIGUOUS` or `UNKNOWN_COMPOSITION`.
  final String mapping;
}

class ProductConcept {
  const ProductConcept({
    required this.productId,
    required this.name,
    required this.route,
    required this.labelVersion,
    required this.ingredients,
    required this.compositionKnown,
  });

  factory ProductConcept.fromJson(Map<String, Object?> j) => ProductConcept(
    productId: j['product_id']! as String,
    name: j['name']! as String,
    route: j['route']! as String,
    labelVersion: j['label_version']! as String,
    ingredients: [
      for (final i in (j['ingredients'] as List<Object?>?) ?? const [])
        IngredientAmount.fromJson(i! as Map<String, Object?>),
    ],
    compositionKnown: j['composition_known']! as bool,
  );

  final String productId;
  final String name;
  final String route;
  final String labelVersion;
  final List<IngredientAmount> ingredients;
  final bool compositionKnown;
}

/// A planned or taken exposure. Plan ≠ taken; neither becomes the other.
class ExposureEntry {
  const ExposureEntry({
    required this.entryId,
    required this.productId,
    required this.kind,
    required this.servingsPerDay,
    required this.time,
  });

  factory ExposureEntry.fromJson(Map<String, Object?> j) => ExposureEntry(
    entryId: j['entry_id']! as String,
    productId: j['product_id']! as String,
    kind: j['kind']! as String,
    servingsPerDay: (j['servings_per_day']! as num).toDouble(),
    time: _str(j['time']),
  );

  final String entryId;
  final String productId;

  /// `PLAN` or `TAKEN`.
  final String kind;
  final double servingsPerDay;

  /// HH:MM local time of intake (TAKEN) or scheduled time (PLAN).
  final String? time;
}

class InteractionRule {
  const InteractionRule({
    required this.ruleId,
    required this.version,
    required this.source,
    required this.kind,
    required this.participants,
    required this.route,
    required this.action,
    required this.testOnly,
    this.minSeparationMinutes,
    this.condition,
  });

  factory InteractionRule.fromJson(Map<String, Object?> j) => InteractionRule(
    ruleId: j['rule_id']! as String,
    version: j['version']! as String,
    source: j['source']! as String,
    kind: j['kind']! as String,
    participants: _strings(j['participants']),
    route: _str(j['route']),
    minSeparationMinutes: j['min_separation_minutes'] as num?,
    condition: _str(j['condition']),
    action: j['action']! as String,
    testOnly: j['test_only']! as bool,
  );

  final String ruleId;
  final String version;
  final String source;

  /// `PAIR`, `TIMING_SEPARATION` or `CONDITION`.
  final String kind;
  final List<String> participants;
  final String? route;
  final num? minSeparationMinutes;
  final String? condition;

  /// `REVIEW_WITH_CLINICIAN`, `SEPARATE_TIMING` or `INFORM`.
  final String action;
  final bool testOnly;
}

/// The installed knowledge pack's identity.
class SafetyPack {
  const SafetyPack({
    required this.packId,
    required this.version,
    required this.status,
  });

  factory SafetyPack.fromJson(Map<String, Object?> j) => SafetyPack(
    packId: j['pack_id']! as String,
    version: j['version']! as String,
    status: j['status']! as String,
  );

  final String packId;
  final String version;
  final String status;
}

class CombinedAmount {
  const CombinedAmount(this.value, this.unit);
  final double value;
  final String unit;
}

/// Result of [combineAmounts]: a value and unit, or a reason and no value.
class CombineResult {
  const CombineResult(this.value, this.unit, this.reason);
  final double? value;
  final String? unit;
  final String? reason;
}

class AmountPart {
  const AmountPart(this.amount, this.unit, this.basis);
  final double? amount;
  final String? unit;
  final String basis;
}

/// Sums only an identical basis and convertible mass units (AT-986/987).
/// An undisclosed amount, a basis mismatch, a unit without an installed
/// conversion or a non-finite sum (NON_FINITE_RESULT, a Dart addition)
/// gives no value and a reason (missing ≠ zero).
CombineResult combineAmounts(List<AmountPart> parts) {
  if (parts.any((p) => p.amount == null || p.unit == null)) {
    return const CombineResult(null, null, 'UNDISCLOSED_AMOUNT');
  }
  if ({for (final p in parts) p.basis}.length > 1) {
    return const CombineResult(null, null, 'BASIS_MISMATCH');
  }
  // Insertion-ordered, as a JS Set.
  final units = <String>{for (final p in parts) p.unit!};
  if (units.length == 1) {
    var sum = 0.0;
    for (final p in parts) {
      sum += p.amount!;
    }
    if (!sum.isFinite) {
      return const CombineResult(null, null, nonFiniteResultCode);
    }
    return CombineResult(sum, units.first, null);
  }
  if (units.every(massToMcg.containsKey)) {
    var mcg = 0.0;
    for (final p in parts) {
      mcg += p.amount! * massToMcg[p.unit!]!;
    }
    // Stable sort, largest unit first (as Array.prototype.sort).
    final sorted = units.toList();
    _stableSort(sorted, (a, b) => massToMcg[b]!.compareTo(massToMcg[a]!));
    final largest = sorted.first;
    final value = mcg / massToMcg[largest]!;
    if (!value.isFinite) {
      return const CombineResult(null, null, nonFiniteResultCode);
    }
    return CombineResult(value, largest, null);
  }
  return const CombineResult(null, null, 'UNIT_CONVERSION_RULE_NOT_INSTALLED');
}

void _stableSort<T>(List<T> list, int Function(T, T) cmp) {
  for (var i = 1; i < list.length; i++) {
    final x = list[i];
    var j = i - 1;
    while (j >= 0 && cmp(list[j], x) > 0) {
      list[j + 1] = list[j];
      j--;
    }
    list[j + 1] = x;
  }
}

/// JavaScript `Number(s)` for the pieces of an HH:MM time: whitespace is
/// trimmed and an empty string is 0; anything unparsable is NaN (null here).
double? _jsNumber(String s) {
  final t = s.trim();
  if (t.isEmpty) return 0;
  return num.tryParse(t)?.toDouble();
}

/// Minutes after midnight of an `HH:MM` time; null when absent or unreadable.
double? timeToMinutes(String? t) {
  if (t == null || t.isEmpty) return null;
  final parts = t.split(':');
  final h = _jsNumber(parts[0]);
  final m = parts.length > 1 ? _jsNumber(parts[1]) : null;
  if (h == null || m == null || !h.isFinite || !m.isFinite) return null;
  return h * 60 + m;
}

class SafetyFinding {
  const SafetyFinding({
    required this.type,
    required this.ingredientId,
    required this.products,
    required this.ruleId,
    required this.ruleVersion,
    required this.action,
    required this.combinedAmount,
    required this.combinedReason,
    required this.exposureBasis,
    required this.note,
  });

  /// One of EXACT_DUPLICATE_ACTIVE_INGREDIENT, SAME_ACTIVE_DIFFERENT_PRODUCT,
  /// POSSIBLE_NAME_DUPLICATE, UNKNOWN_INGREDIENT, INSUFFICIENT_CONTEXT,
  /// SYNTHETIC_PAIR_INTERACTION, TIMING_SEPARATION, CONDITION_CONTEXT,
  /// CLEAR_NO_MATCH_FOUND.
  final String type;
  final String? ingredientId;
  final List<String> products;
  final String? ruleId;
  final String? ruleVersion;
  final String? action;

  /// Combined daily amount when bases and units are compatible; otherwise
  /// null with [combinedReason].
  final CombinedAmount? combinedAmount;
  final String? combinedReason;

  /// `PLANNED`, `TAKEN` or `MIXED`.
  final String exposureBasis;

  /// Always false: no finding (and no absence of findings) means safe.
  bool get guaranteedSafe => false;
  final String note;
}

class SafetyInputs {
  const SafetyInputs({
    required this.products,
    required this.entries,
    required this.rules,
    required this.conditions,
    required this.pack,
  });

  final List<ProductConcept> products;
  final List<ExposureEntry> entries;
  final List<InteractionRule> rules;
  final List<String> conditions;
  final SafetyPack pack;
}

class SafetyAssessment {
  const SafetyAssessment({
    required this.pack,
    required this.findings,
    required this.inputs,
    required this.missingInputs,
  });

  String get engineId => safetyEngineId;
  String get engineVersion => safetyEngineVersion;
  final SafetyPack pack;
  final List<SafetyFinding> findings;

  /// Inputs, as given.
  final SafetyInputs inputs;

  /// What kept a check from running: `entries.<id>.product` (product not in
  /// the catalogue, so the entry is not assessed), `products.<id>.composition`
  /// (composition unknown), `entries.<id>.time` (a timing rule needed it).
  /// Additive to the TS shape; it never changes the findings.
  final List<String> missingInputs;
  List<String> get limitations => safetyLimitations;
}

class _Use {
  const _Use(this.entry, this.ing);
  final ExposureEntry entry;
  final IngredientAmount ing;
}

List<String> _unique(Iterable<String> xs) => {...xs}.toList();

String _basisOf(Iterable<ExposureEntry> es) {
  final k = {for (final e in es) e.kind};
  return k.length > 1
      ? 'MIXED'
      : k.contains('TAKEN')
      ? 'TAKEN'
      : 'PLANNED';
}

/// Runs the installed pack's rules over the active exposures, in the
/// reference order: composition and mapping checks per entry, duplicate
/// ingredients (sorted by ingredient ID), then each rule in pack order.
/// With no finding at all it reports CLEAR_NO_MATCH_FOUND, which is not a
/// guarantee of safety.
SafetyAssessment assessSafety(
  List<ProductConcept> products,
  List<ExposureEntry> entries,
  List<InteractionRule> rules,
  List<String> conditions,
  SafetyPack pack,
) {
  final inputs = SafetyInputs(
    products: products,
    entries: entries,
    rules: rules,
    conditions: conditions,
    pack: pack,
  );
  final byId = {for (final p in products) p.productId: p};
  final active = entries.where((e) => byId.containsKey(e.productId)).toList();
  final missing = <String>[
    for (final e in entries)
      if (!byId.containsKey(e.productId)) 'entries.${e.entryId}.product',
  ];
  final findings = <SafetyFinding>[];

  for (final e in active) {
    final p = byId[e.productId]!;
    if (!p.compositionKnown) {
      final key = 'products.${p.productId}.composition';
      if (!missing.contains(key)) missing.add(key);
      findings.add(
        SafetyFinding(
          type: 'INSUFFICIENT_CONTEXT',
          ingredientId: null,
          products: [p.productId],
          ruleId: null,
          ruleVersion: null,
          action: null,
          combinedAmount: null,
          combinedReason: 'UNKNOWN_COMPOSITION',
          exposureBasis: _basisOf([e]),
          note: 'Composition unknown; ingredient-level checks cannot run.',
        ),
      );
    }
    for (final ing in p.ingredients.where((i) => i.mapping == 'AMBIGUOUS')) {
      findings.add(
        SafetyFinding(
          type: 'UNKNOWN_INGREDIENT',
          ingredientId: ing.ingredientId,
          products: [p.productId],
          ruleId: null,
          ruleVersion: null,
          action: null,
          combinedAmount: null,
          combinedReason: null,
          exposureBasis: _basisOf([e]),
          note:
              '"${ing.label}" mapping is ambiguous; it cannot trigger exact hard rules.',
        ),
      );
    }
  }

  // Duplicate ingredient detection over reviewed identities only.
  final reviewed = <String, List<_Use>>{};
  for (final e in active) {
    final p = byId[e.productId]!;
    for (final ing in p.ingredients.where((i) => i.mapping == 'REVIEWED')) {
      (reviewed[ing.ingredientId] ??= []).add(_Use(e, ing));
    }
  }
  final ids = reviewed.keys.toList()..sort();
  for (final ingId in ids) {
    final list = reviewed[ingId]!;
    if (list.length < 2) continue;
    final prods = _unique(list.map((l) => l.entry.productId));
    final combined = combineAmounts([
      for (final l in list)
        AmountPart(
          l.ing.amount == null ? null : l.ing.amount! * l.entry.servingsPerDay,
          l.ing.unit,
          l.ing.basis,
        ),
    ]);
    findings.add(
      SafetyFinding(
        type: prods.length > 1
            ? 'SAME_ACTIVE_DIFFERENT_PRODUCT'
            : 'EXACT_DUPLICATE_ACTIVE_INGREDIENT',
        ingredientId: ingId,
        products: prods,
        ruleId: duplicateIngredientRuleId,
        ruleVersion: duplicateIngredientRuleVersion,
        action: 'INFORM',
        combinedAmount: combined.value == null
            ? null
            : CombinedAmount(combined.value!, combined.unit!),
        combinedReason: combined.reason,
        exposureBasis: _basisOf(list.map((l) => l.entry)),
        note: 'Same normalized ingredient in more than one entry. This is not a toxicity or overdose finding.',
      ),
    );
  }

  List<_Use> uses(String id) => [...?reviewed[id]];
  for (final rule in rules) {
    if (rule.kind == 'PAIR') {
      final parts = rule.participants.map(uses).toList();
      if (parts.any((p) => p.isEmpty)) continue;
      final routeOk =
          rule.route == null ||
          parts.every(
            (p) => p.any((x) => byId[x.entry.productId]!.route == rule.route),
          );
      if (!routeOk) continue;
      final flat = parts.expand((p) => p).toList();
      findings.add(
        SafetyFinding(
          type: 'SYNTHETIC_PAIR_INTERACTION',
          ingredientId: rule.participants.join('+'),
          products: _unique(flat.map((x) => x.entry.productId)),
          ruleId: rule.ruleId,
          ruleVersion: rule.version,
          action: rule.action,
          combinedAmount: null,
          combinedReason: null,
          exposureBasis: _basisOf(flat.map((x) => x.entry)),
          note:
              'Synthetic pair rule from ${rule.source}. Evidence ≠ diagnosis.',
        ),
      );
    } else if (rule.kind == 'TIMING_SEPARATION') {
      final a = uses(rule.participants.isNotEmpty ? rule.participants[0] : '');
      final b = uses(rule.participants.length > 1 ? rule.participants[1] : '');
      if (a.isEmpty || b.isEmpty) continue;
      for (final x in a) {
        for (final y in b) {
          final tx = timeToMinutes(x.entry.time);
          final ty = timeToMinutes(y.entry.time);
          if (tx == null || ty == null) {
            for (final u in [if (tx == null) x, if (ty == null) y]) {
              final key = 'entries.${u.entry.entryId}.time';
              if (!missing.contains(key)) missing.add(key);
            }
            findings.add(
              SafetyFinding(
                type: 'INSUFFICIENT_CONTEXT',
                ingredientId: rule.participants.join('+'),
                products: [x.entry.productId, y.entry.productId],
                ruleId: rule.ruleId,
                ruleVersion: rule.version,
                action: null,
                combinedAmount: null,
                combinedReason: 'MISSING_TIME',
                exposureBasis: _basisOf([x.entry, y.entry]),
                note: 'Timing rule needs intake times.',
              ),
            );
          } else if ((tx - ty).abs() < (rule.minSeparationMinutes ?? 0)) {
            findings.add(
              SafetyFinding(
                type: 'TIMING_SEPARATION',
                ingredientId: rule.participants.join('+'),
                products: [x.entry.productId, y.entry.productId],
                ruleId: rule.ruleId,
                ruleVersion: rule.version,
                action: rule.action,
                combinedAmount: null,
                combinedReason: null,
                exposureBasis: _basisOf([x.entry, y.entry]),
                note:
                    'Synthetic rule asks for ≥${_jsNum(rule.minSeparationMinutes!)} min separation; observed ${_jsNum((tx - ty).abs())} min.',
              ),
            );
          }
        }
      }
    } else if (rule.kind == 'CONDITION') {
      final first = rule.participants.isNotEmpty ? rule.participants[0] : '';
      final p = uses(first);
      final cond = rule.condition;
      if (p.isNotEmpty &&
          cond != null &&
          cond.isNotEmpty &&
          conditions.contains(cond)) {
        findings.add(
          SafetyFinding(
            type: 'CONDITION_CONTEXT',
            ingredientId: first,
            products: _unique(p.map((x) => x.entry.productId)),
            ruleId: rule.ruleId,
            ruleVersion: rule.version,
            action: rule.action,
            combinedAmount: null,
            combinedReason: null,
            exposureBasis: _basisOf(p.map((x) => x.entry)),
            note: 'Synthetic condition-context rule ($cond).',
          ),
        );
      }
    }
  }

  if (findings.isEmpty) {
    findings.add(
      SafetyFinding(
        type: 'CLEAR_NO_MATCH_FOUND',
        ingredientId: null,
        products: [for (final e in active) e.productId],
        ruleId: null,
        ruleVersion: null,
        action: null,
        combinedAmount: null,
        combinedReason: null,
        exposureBasis: _basisOf(active),
        note: 'No applicable rule found in the installed pack. This is NOT a guarantee of safety.',
      ),
    );
  }

  return SafetyAssessment(
    pack: pack,
    findings: List.unmodifiable(findings),
    inputs: inputs,
    missingInputs: List.unmodifiable(missing),
  );
}
