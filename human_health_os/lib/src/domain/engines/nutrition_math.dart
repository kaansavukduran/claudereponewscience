/// NUTRITION-MATH-1 v0.20.0: portion scaling and recipe sums (F011, D-037).
///
/// Dart port of `packages/domain/src/nutrition.ts` (the reference oracle),
/// checked against `contracts/golden_vectors/nutrition_vectors.json`. A
/// nutrient the source did not report stays missing, never 0; volume is
/// turned into mass only with an explicit density or household measure; a
/// cooking yield is never assumed. Each result carries the engine ID and
/// version, its inputs, what was missing and its limitations (additions to
/// the TS shape; the numbers are the same).
///
/// Not wired to the app's `nutrition.food_entry` records (D-033): those keep
/// label values as typed and are never scaled. This engine serves food
/// snapshots with a declared basis (F012).
library;

import 'calc_result.dart';

const String nutritionEngineId = 'NUTRITION-MATH-1';
const String nutritionEngineVersion = '0.20.0';

/// Limitations every nutrition result carries.
const List<String> nutritionLimitations = [
  'A nutrient the source did not report stays missing, never 0.',
  'Volume becomes mass only with an explicit density or household measure.',
  'Totals are sums of known contributions; coverage shows what is missing.',
  'A cooking yield is never assumed; per-100 g cooked needs a measured mass.',
];

/// The amount a food snapshot's nutrient values refer to (e.g. 100 g).
class Basis {
  const Basis({required this.amount, required this.unit});

  factory Basis.fromJson(Map<String, Object?> j) => Basis(
    amount: (j['amount']! as num).toDouble(),
    unit: j['unit']! as String,
  );

  final double amount;

  /// g, mL, serving or piece.
  final String unit;

  Map<String, Object?> toJson() => {'amount': amount, 'unit': unit};
}

/// An immutable food snapshot: nutrient values per [basis]. A null nutrient
/// is MISSING (the provider did not report it).
class FoodSnapshot {
  const FoodSnapshot({
    required this.snapshotId,
    required this.name,
    required this.basis,
    required this.nutrients,
    required this.source,
    this.densityGPerMl,
    this.measuresG,
  });

  factory FoodSnapshot.fromJson(Map<String, Object?> j) {
    final nutrients = j['nutrients']! as Map<String, Object?>;
    final measures = j['measures_g'] as Map<String, Object?>?;
    return FoodSnapshot(
      snapshotId: j['snapshot_id']! as String,
      name: j['name']! as String,
      basis: Basis.fromJson(j['basis']! as Map<String, Object?>),
      nutrients: {
        for (final e in nutrients.entries) e.key: presentOrNull(e.value),
      },
      source: j['source']! as String,
      densityGPerMl: presentOrNull(j['density_g_per_ml']),
      measuresG: measures == null
          ? null
          : {
              for (final e in measures.entries)
                e.key: (e.value! as num).toDouble(),
            },
    );
  }

  final String snapshotId;
  final String name;
  final Basis basis;
  final Map<String, double?> nutrients;
  final String source;

  /// Explicit density for mL ↔ g conversion (g per mL); null = unknown.
  final double? densityGPerMl;

  /// Household measures in grams, e.g. {slice: 30}.
  final Map<String, double>? measuresG;

  Map<String, Object?> toJson() => {
    'snapshot_id': snapshotId,
    'name': name,
    'basis': basis.toJson(),
    'nutrients': nutrients,
    'source': source,
    'density_g_per_ml': densityGPerMl,
    'measures_g': measuresG,
  };
}

/// A consumed quantity: an amount (null = not given) and its unit.
class Quantity {
  const Quantity({required this.amount, required this.unit});

  factory Quantity.fromJson(Map<String, Object?> j) =>
      Quantity(amount: presentOrNull(j['amount']), unit: j['unit']! as String);

  final double? amount;
  final String unit;

  Map<String, Object?> toJson() => {'amount': amount, 'unit': unit};
}

/// Why a quantity could not be scaled.
enum ScaleError {
  volumeToMassBlocked('VOLUME_TO_MASS_BLOCKED'),
  unknownMeasure('UNKNOWN_MEASURE'),
  invalidQuantity('INVALID_QUANTITY'),
  basisIncompatible('BASIS_INCOMPATIBLE'),

  /// The arithmetic gave NaN or an infinity (e.g. an overflow); no value is
  /// reported (same code as `nonFiniteResultCode`).
  nonFiniteResult(nonFiniteResultCode);

  const ScaleError(this.code);
  final String code;
}

/// factor = consumed / basis, or the reason there is none.
typedef ScaleFactor = ({double? factor, ScaleError? error, String? conversion});

/// JavaScript-style number text (`1` not `1.0`), for conversion notes.
String _jsNum(double x) =>
    x == x.truncateToDouble() && x.abs() < 1e21 ? x.toInt().toString() : '$x';

/// Converts the consumed quantity into the food's basis unit.
ScaleFactor scaleFactor(FoodSnapshot food, Quantity q) {
  final amount = q.amount;
  if (amount == null || amount < 0) {
    return (factor: null, error: ScaleError.invalidQuantity, conversion: null);
  }
  final b = food.basis;
  final d = food.densityGPerMl;
  if (q.unit == b.unit) {
    return (factor: amount / b.amount, error: null, conversion: null);
  }
  if (b.unit == 'g' && q.unit == 'mL') {
    if (d == null) {
      return (
        factor: null,
        error: ScaleError.volumeToMassBlocked,
        conversion: null,
      );
    }
    return (
      factor: (amount * d) / b.amount,
      error: null,
      conversion: 'density ${_jsNum(d)} g/mL',
    );
  }
  if (b.unit == 'mL' && q.unit == 'g') {
    if (d == null) {
      return (
        factor: null,
        error: ScaleError.volumeToMassBlocked,
        conversion: null,
      );
    }
    return (
      factor: amount / d / b.amount,
      error: null,
      conversion: 'density ${_jsNum(d)} g/mL',
    );
  }
  final measures = food.measuresG;
  if (b.unit == 'g' && measures != null && measures.containsKey(q.unit)) {
    final g = measures[q.unit]!;
    return (
      factor: (amount * g) / b.amount,
      error: null,
      conversion: 'measure ${q.unit} = ${_jsNum(g)} g',
    );
  }
  if (b.unit == 'g') {
    return (factor: null, error: ScaleError.unknownMeasure, conversion: null);
  }
  return (factor: null, error: ScaleError.basisIncompatible, conversion: null);
}

/// A food scaled to the consumed quantity.
class ScaledNutrients {
  const ScaledNutrients({
    required this.ok,
    required this.error,
    required this.nutrients,
    required this.factor,
    required this.conversion,
    required this.food,
    required this.quantity,
    required this.missingInputs,
  });

  final bool ok;
  final ScaleError? error;

  /// Scaled values; null where the source did not report the nutrient.
  /// Empty when scaling was refused.
  final Map<String, double?> nutrients;
  final double? factor;
  final String? conversion;

  /// Inputs, as given.
  final FoodSnapshot food;
  final Quantity quantity;

  /// `nutrients.<key>` for each unreported nutrient, `density_g_per_ml`
  /// when a volume could not become a mass, `quantity.amount` when the
  /// amount was not given.
  final List<String> missingInputs;

  String get engineId => nutritionEngineId;
  String get engineVersion => nutritionEngineVersion;
  List<String> get limitations => nutritionLimitations;
}

ScaledNutrients scaleFood(FoodSnapshot food, Quantity q) {
  final s = scaleFactor(food, q);
  final factor = s.factor;
  if (factor == null) {
    return ScaledNutrients(
      ok: false,
      error: s.error,
      nutrients: const {},
      factor: null,
      conversion: null,
      food: food,
      quantity: q,
      missingInputs: List.unmodifiable([
        if (s.error == ScaleError.volumeToMassBlocked) 'density_g_per_ml',
        if (q.amount == null) 'quantity.amount',
      ]),
    );
  }
  final scaled = {
    for (final e in food.nutrients.entries)
      e.key: e.value == null ? null : e.value! * factor,
  };
  if (!factor.isFinite || scaled.values.any((v) => v != null && !v.isFinite)) {
    return ScaledNutrients(
      ok: false,
      error: ScaleError.nonFiniteResult,
      nutrients: const {},
      factor: null,
      conversion: null,
      food: food,
      quantity: q,
      missingInputs: const [],
    );
  }
  return ScaledNutrients(
    ok: true,
    error: null,
    nutrients: Map.unmodifiable(scaled),
    factor: factor,
    conversion: s.conversion,
    food: food,
    quantity: q,
    missingInputs: List.unmodifiable([
      for (final e in food.nutrients.entries)
        if (e.value == null) 'nutrients.${e.key}',
    ]),
  );
}

/// A total over several items for one nutrient.
class NutrientTotal {
  const NutrientTotal({
    required this.known,
    required this.knownSources,
    required this.missingSources,
    required this.coverage,
    required this.complete,
  });

  /// Sum of known contributions only; null if none is known.
  final double? known;
  final int knownSources;
  final int missingSources;

  /// Fraction of items that reported this nutrient.
  final double coverage;
  final bool complete;
}

/// Known total and missing-source count per nutrient. Keys default to the
/// sorted union of all items' keys.
Map<String, NutrientTotal> sumNutrients(
  List<Map<String, double?>> items, [
  List<String>? keys,
]) {
  final all = keys ?? ({for (final i in items) ...i.keys}.toList()..sort());
  final out = <String, NutrientTotal>{};
  for (final k in all) {
    var known = 0.0;
    var ks = 0;
    var ms = 0;
    for (final it in items) {
      final v = it[k];
      if (v != null && v.isFinite) {
        known += v;
        ks++;
      } else {
        ms++;
      }
    }
    out[k] = NutrientTotal(
      known: ks > 0 ? known : null,
      knownSources: ks,
      missingSources: ms,
      coverage: items.isNotEmpty ? ks / items.length : 0,
      complete: ms == 0 && ks > 0,
    );
  }
  return out;
}

class RecipeIngredient {
  const RecipeIngredient({required this.food, required this.quantity});

  factory RecipeIngredient.fromJson(Map<String, Object?> j) => RecipeIngredient(
    food: FoodSnapshot.fromJson(j['food']! as Map<String, Object?>),
    quantity: Quantity.fromJson(j['quantity']! as Map<String, Object?>),
  );

  final FoodSnapshot food;
  final Quantity quantity;
}

/// One version of a recipe. Editing makes a new version.
class RecipeVersion {
  const RecipeVersion({
    required this.recipeId,
    required this.version,
    required this.name,
    required this.ingredients,
    required this.servingCount,
    required this.finalCookedMassG,
  });

  factory RecipeVersion.fromJson(Map<String, Object?> j) => RecipeVersion(
    recipeId: j['recipe_id']! as String,
    version: (j['version']! as num).toInt(),
    name: j['name']! as String,
    ingredients: [
      for (final i in j['ingredients']! as List<Object?>)
        RecipeIngredient.fromJson(i! as Map<String, Object?>),
    ],
    servingCount: presentOrNull(j['serving_count']),
    finalCookedMassG: presentOrNull(j['final_cooked_mass_g']),
  );

  final String recipeId;
  final int version;
  final String name;
  final List<RecipeIngredient> ingredients;

  /// null = not given.
  final double? servingCount;

  /// Measured final cooked mass in grams; null = not measured.
  final double? finalCookedMassG;
}

class RecipeResult {
  const RecipeResult({
    required this.ok,
    required this.errors,
    required this.totals,
    required this.perServing,
    required this.per100gCooked,
    required this.recipe,
    required this.missingInputs,
  });

  final bool ok;
  final List<({String ingredient, ScaleError error})> errors;
  final Map<String, NutrientTotal> totals;

  /// null when the serving count is missing or not positive.
  final Map<String, double?>? perServing;

  /// null when the final cooked mass was not measured.
  final Map<String, double?>? per100gCooked;

  /// Input, as given.
  final RecipeVersion recipe;

  /// `serving_count` / `final_cooked_mass_g` when missing, plus
  /// `nutrients.<key>` for each nutrient with a missing source.
  final List<String> missingInputs;

  String get engineId => nutritionEngineId;
  String get engineVersion => nutritionEngineVersion;
  List<String> get limitations => nutritionLimitations;
}

RecipeResult computeRecipe(RecipeVersion recipe) {
  final scaled = [
    for (final ing in recipe.ingredients)
      (ing: ing, s: scaleFood(ing.food, ing.quantity)),
  ];
  final errors = [
    for (final x in scaled)
      if (!x.s.ok) (ingredient: x.ing.food.name, error: x.s.error!),
  ];
  final totals = sumNutrients([
    for (final x in scaled)
      if (x.s.ok) x.s.nutrients,
  ]);
  Map<String, double?>? div(double? d) => d == null || d <= 0
      ? null
      : Map.unmodifiable({
          for (final e in totals.entries)
            e.key: e.value.known == null ? null : e.value.known! / d,
        });
  final mass = recipe.finalCookedMassG;
  final perServing = div(recipe.servingCount);
  // Cooking yield is never assumed: per-100 g cooked needs a measured mass.
  final per100g = mass != null && mass != 0 ? div(mass / 100) : null;
  bool bad(double? v) => v != null && !v.isFinite;
  if (totals.values.any((t) => bad(t.known)) ||
      (perServing?.values.any(bad) ?? false) ||
      (per100g?.values.any(bad) ?? false)) {
    // An overflowing sum or division is refused as a whole, never shown.
    return RecipeResult(
      ok: false,
      errors: List.unmodifiable([
        ...errors,
        (ingredient: recipe.name, error: ScaleError.nonFiniteResult),
      ]),
      totals: const {},
      perServing: null,
      per100gCooked: null,
      recipe: recipe,
      missingInputs: const [],
    );
  }
  return RecipeResult(
    ok: errors.isEmpty,
    errors: List.unmodifiable(errors),
    totals: Map.unmodifiable(totals),
    perServing: perServing,
    per100gCooked: per100g,
    recipe: recipe,
    missingInputs: List.unmodifiable([
      if (recipe.servingCount == null) 'serving_count',
      if (mass == null) 'final_cooked_mass_g',
      for (final e in totals.entries)
        if (e.value.missingSources > 0) 'nutrients.${e.key}',
    ]),
  );
}
