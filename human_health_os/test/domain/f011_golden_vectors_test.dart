// F011-S1/S2 (D-037, D-038): the Dart engines pass all 73 language-neutral
// golden vectors in contracts/golden_vectors, the same files the TS
// reference (packages/domain/test/golden.test.ts) runs. Assertions follow
// the TS harness: states exactly, numbers within the vector's declared
// tolerance, and a refused calculation has no value. Every key of every
// `expected` object must be one this test asserts (checkExpectedKeys); an
// unknown key fails instead of being skipped.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/engines/calc_result.dart';
import 'package:human_health_os/src/domain/engines/core_derived.dart';
import 'package:human_health_os/src/domain/engines/lab_interpretation.dart';
import 'package:human_health_os/src/domain/engines/medication_safety.dart';
import 'package:human_health_os/src/domain/engines/nutrition_math.dart';
import 'package:human_health_os/src/domain/engines/preventive.dart';

/// Relative to the package root (flutter test runs there).
const String vectorDir = '../contracts/golden_vectors';

/// Vector files the Dart engines run, with their vector counts.
const Map<String, int> covered = {
  'core_derived_vectors.json': 19,
  'lab_interpretation_vectors.json': 19,
  'medication_safety_vectors.json': 10,
  'nutrition_vectors.json': 5,
  'preventive_vectors.json': 20,
};

/// Vector files not yet ported to Dart (empty since F011-S2). A new file
/// must be added to [covered] or listed here, or the guard test fails.
const Map<String, int> notCovered = {};

Map<String, Object?> load(String name) =>
    jsonDecode(File('$vectorDir/$name').readAsStringSync())
        as Map<String, Object?>;

List<Map<String, Object?>> vectors(String name) => [
  for (final v in load(name)['vectors']! as List<Object?>)
    v! as Map<String, Object?>,
];

/// Fails when [expected] has a key this test does not assert.
void checkExpectedKeys(
  Map<String, Object?> expected,
  Set<String> handled,
  String id,
) {
  expect(
    expected.keys.toSet().difference(handled),
    isEmpty,
    reason: '$id: expected keys this test does not assert',
  );
}

void close(double? got, Object? expected, Object? tolerance, String what) {
  expect(got, isNotNull, reason: '$what has no value');
  final e = (expected! as num).toDouble();
  final tol = (tolerance! as num).toDouble();
  expect(
    (got! - e).abs() <= tol,
    isTrue,
    reason: '$what: got $got, expected $e within $tol',
  );
}

void main() {
  group('golden vector files', () {
    test('every file is either covered or listed as not covered', () {
      final files =
          Directory(vectorDir)
              .listSync()
              .whereType<File>()
              .map((f) => f.uri.pathSegments.last)
              .where((n) => n.endsWith('.json'))
              .toList()
            ..sort();
      expect(files, isNotEmpty, reason: 'vector directory not found');
      expect(
        covered.keys.toSet().intersection(notCovered.keys.toSet()),
        isEmpty,
      );
      expect(
        files,
        ({...covered.keys, ...notCovered.keys}.toList()..sort()),
        reason: 'a new vector file must be ported or listed as not covered',
      );
    });

    test('vector counts match (73 in all)', () {
      final all = {...covered, ...notCovered};
      for (final e in all.entries) {
        expect(vectors(e.key), hasLength(e.value), reason: e.key);
      }
      expect(all.values.fold<int>(0, (a, b) => a + b), 73);
    });

    test('no vector file is left uncovered in Dart (F011 gap closed)', () {
      expect(notCovered, isEmpty);
      expect(covered.values.fold<int>(0, (a, b) => a + b), 73);
    });
  });

  group('core_derived_vectors (MP-CORE-DERIVED-1)', () {
    final cat = load('core_derived_vectors.json');
    test('pack identity', () {
      expect(cat['pack'], coreDerivedPackId);
      expect(cat['pack_version'], coreDerivedPackVersion);
    });
    for (final v in vectors('core_derived_vectors.json')) {
      final id = v['vector_id']! as String;
      final modelId = v['model_id']! as String;
      test('$id $modelId', () {
        final fn = coreDerivedFunctions[modelId];
        expect(fn, isNotNull, reason: 'no implementation for $modelId');
        final inputs = v['inputs']! as Map<String, Object?>;
        final r1 = fn!(inputs);
        final r2 = fn(jsonDecode(jsonEncode(inputs)) as Map<String, Object?>);
        // Deterministic repeatability.
        expect(
          [r2.status, r2.value, r2.errorCode, r2.missingInputs],
          [r1.status, r1.value, r1.errorCode, r1.missingInputs],
        );
        final e = v['expected']! as Map<String, Object?>;
        checkExpectedKeys(e, {'status', 'value', 'error_code'}, id);
        expect(r1.status.code, e['status']);
        expect(r1.modelId, modelId);
        expect(r1.version, v['version']);
        // An unmodifiable copy of the inputs, not the caller's map.
        expect(r1.inputs, equals(inputs));
        expect(r1.inputs, isNot(same(inputs)));
        if (e.containsKey('value')) {
          close(r1.value, e['value'], v['tolerance'], id);
          expect(r1.errorCode, isNull);
          expect(r1.missingInputs, isEmpty);
        } else {
          expect(r1.value, isNull, reason: 'missing/invalid never a number');
        }
        if (e.containsKey('error_code')) {
          expect(r1.errorCode, e['error_code']);
        }
        if (r1.status == CalcStatus.missingInput) {
          expect(r1.missingInputs, isNotEmpty);
        }
      });
    }
  });

  group('lab_interpretation_vectors (LAB-INTERPRETATION-ENGINE-1)', () {
    final cat = load('lab_interpretation_vectors.json');
    test('engine identity', () {
      expect(cat['engine'], labEngineId);
      expect(cat['engine_version'], labEngineVersion);
    });
    for (final v in vectors('lab_interpretation_vectors.json')) {
      final id = v['vector_id']! as String;
      test('$id ${v['note']}', () {
        final input = LabInterpretationInput.fromJson(
          v['input']! as Map<String, Object?>,
        );
        final a = interpretLabResult(input);
        final e = v['expected']! as Map<String, Object?>;
        checkExpectedKeys(e, {
          'status',
          'reference',
          'critical',
          'external_receipt_confirmed',
          'decision_matched',
          'comparability',
          'trend_discontinuity',
          'rcv',
          'rcv_percent',
          'observed_percent_change',
          'baseline',
          'robust_z',
          'flag_origins',
          'value',
          // Parameterises near(); not a result field.
          'tolerance',
        }, id);
        void exact(String key, Object? got) {
          if (e.containsKey(key)) expect(got, e[key], reason: '$id.$key');
        }

        void near(String key, double? got) {
          if (e.containsKey(key)) close(got, e[key], e['tolerance'], id);
        }

        exact('status', a.status);
        exact('reference', a.referenceState);
        exact('critical', a.critical.state);
        exact(
          'external_receipt_confirmed',
          a.critical.externalReceiptConfirmed,
        );
        exact('decision_matched', [
          for (final d in a.decision)
            if (d.matched) d.ruleId,
        ]);
        exact('comparability', a.comparability.state);
        exact('trend_discontinuity', a.comparability.trendDiscontinuity);
        exact('rcv', a.rcv.state);
        near('rcv_percent', a.rcv.rcvPercent);
        near('observed_percent_change', a.rcv.observedPercentChange);
        exact('baseline', a.baseline.state);
        near('robust_z', a.baseline.robustZ);
        exact('flag_origins', [for (final f in a.flags) f.origin]);
        exact('value', a.value);
        expect(a.engineId, labEngineId);
        expect(a.engineVersion, labEngineVersion);
        expect(a.limitations, isNotEmpty);
        expect(a.inputs, same(input));
        if (a.value == null) expect(a.missingInputs, contains('result.value'));
      });
    }
  });

  group('nutrition_vectors (NUTRITION-MATH-1)', () {
    final cat = load('nutrition_vectors.json');
    test('engine identity', () {
      expect(cat['engine'], nutritionEngineId);
      expect(cat['engine_version'], nutritionEngineVersion);
    });
    for (final v in vectors('nutrition_vectors.json')) {
      final id = v['vector_id']! as String;
      final e = v['expected']! as Map<String, Object?>;
      test('$id ${v['note']}', () {
        if (v['kind'] == 'scale') {
          checkExpectedKeys(e, {'ok', 'error', 'nutrients'}, id);
          final food = FoodSnapshot.fromJson(
            v['food']! as Map<String, Object?>,
          );
          final r = scaleFood(
            food,
            Quantity.fromJson(v['quantity']! as Map<String, Object?>),
          );
          expect(r.ok, e['ok']);
          if (e.containsKey('error')) {
            expect(r.error?.code, e['error']);
          } else {
            expect(r.error, isNull);
          }
          // Result nutrients cannot be matched against `expected` alone:
          // the vector format lists a subset (GV-NUT-004 lists protein_g
          // only). So the result holds exactly the food's own nutrients
          // (nothing invented), every expected one is present, and the
          // values listed match.
          final nutrients =
              (e['nutrients'] as Map<String, Object?>?) ?? const {};
          if (r.ok) {
            expect(r.nutrients.keys.toSet(), food.nutrients.keys.toSet());
          } else {
            expect(r.nutrients, isEmpty);
            expect(nutrients, isEmpty);
          }
          expect(
            r.nutrients.keys.toSet().containsAll(nutrients.keys),
            isTrue,
            reason: '$id: expected nutrients missing from the result',
          );
          for (final n in nutrients.entries) {
            if (n.value == null) {
              expect(r.nutrients.containsKey(n.key), isTrue);
              expect(r.nutrients[n.key], isNull, reason: 'missing ≠ zero');
              expect(r.missingInputs, contains('nutrients.${n.key}'));
            } else {
              close(r.nutrients[n.key], n.value, 1e-9, '$id.${n.key}');
            }
          }
          expect(r.engineId, nutritionEngineId);
          expect(r.limitations, isNotEmpty);
        } else if (v['kind'] == 'recipe') {
          checkExpectedKeys(e, {
            'ok',
            'totals_known',
            'missing_sources',
            'per_serving',
            'per_100g_cooked',
          }, id);
          final recipe = RecipeVersion.fromJson(
            v['recipe']! as Map<String, Object?>,
          );
          final r = computeRecipe(recipe);
          expect(r.ok, e['ok']);
          // Totals cover exactly the union of the ingredients' nutrients.
          expect(r.totals.keys.toSet(), {
            for (final i in recipe.ingredients) ...i.food.nutrients.keys,
          });
          final totals =
              (e['totals_known'] as Map<String, Object?>?) ?? const {};
          for (final t in totals.entries) {
            close(r.totals[t.key]?.known, t.value, 1e-9, '$id.${t.key}');
          }
          final miss =
              (e['missing_sources'] as Map<String, Object?>?) ?? const {};
          for (final m in miss.entries) {
            expect(r.totals[m.key]?.missingSources, m.value);
          }
          void per(String key, Map<String, double?>? got) {
            if (!e.containsKey(key)) return;
            if (e[key] == null) {
              expect(got, isNull, reason: '$id.$key');
              return;
            }
            for (final p in (e[key]! as Map<String, Object?>).entries) {
              close(got?[p.key], p.value, 1e-9, '$id.$key.${p.key}');
            }
          }

          per('per_serving', r.perServing);
          per('per_100g_cooked', r.per100gCooked);
          expect(r.engineId, nutritionEngineId);
        } else {
          fail('unknown vector kind ${v['kind']}');
        }
      });
    }
  });

  group('medication_safety_vectors (MED-SAFETY-ENGINE-1)', () {
    final cat = load('medication_safety_vectors.json');
    final products = [
      for (final p in cat['products']! as List<Object?>)
        ProductConcept.fromJson(p! as Map<String, Object?>),
    ];
    final rules = [
      for (final r in cat['rules']! as List<Object?>)
        InteractionRule.fromJson(r! as Map<String, Object?>),
    ];
    final pack = SafetyPack.fromJson(cat['pack']! as Map<String, Object?>);
    for (final v in vectors('medication_safety_vectors.json')) {
      final id = v['vector_id']! as String;
      test('$id ${v['note']}', () {
        final entries = [
          for (final x in v['entries']! as List<Object?>)
            ExposureEntry.fromJson(x! as Map<String, Object?>),
        ];
        final conditions = [
          for (final c in v['conditions']! as List<Object?>) c! as String,
        ];
        final a = assessSafety(products, entries, rules, conditions, pack);
        final e = v['expected']! as Map<String, Object?>;
        checkExpectedKeys(e, {
          'types',
          'guaranteed_safe',
          'combined',
          'combined_reason',
          'exposure_basis',
        }, id);
        expect([for (final f in a.findings) f.type], e['types']);
        // No interaction found ≠ safe: never true, whatever the vector says.
        for (final f in a.findings) {
          expect(f.guaranteedSafe, isFalse);
        }
        if (e.containsKey('guaranteed_safe')) {
          expect(e['guaranteed_safe'], isFalse);
        }
        SafetyFinding find(String ing) => a.findings.firstWhere(
          (x) => x.ingredientId == ing,
          orElse: () => fail('$id: no finding for $ing'),
        );
        final combined = (e['combined'] as Map<String, Object?>?) ?? const {};
        for (final c in combined.entries) {
          final f = find(c.key);
          if (c.value == null) {
            expect(f.combinedAmount, isNull);
          } else {
            final want = c.value! as Map<String, Object?>;
            close(f.combinedAmount?.value, want['value'], 1e-12, id);
            expect(f.combinedAmount?.unit, want['unit']);
          }
        }
        final reasons =
            (e['combined_reason'] as Map<String, Object?>?) ?? const {};
        for (final c in reasons.entries) {
          expect(find(c.key).combinedReason, c.value);
        }
        if (e.containsKey('exposure_basis')) {
          expect(a.findings.first.exposureBasis, e['exposure_basis']);
        }
        expect(a.engineId, safetyEngineId);
        expect(a.engineVersion, safetyEngineVersion);
        expect(a.pack.packId, 'SYNTHETIC-SAFETY-PACK-1');
        expect(a.limitations, safetyLimitations);
        expect(a.inputs.entries, same(entries));
      });
    }
  });

  group('preventive_vectors (PREVENTIVE-ENGINE-1)', () {
    final cat = load('preventive_vectors.json');
    List<PreventiveRule> parse(Object? rules) => [
      for (final r in rules! as List<Object?>)
        PreventiveRule.fromJson(r! as Map<String, Object?>),
    ];
    final packRules = parse(cat['rules']);
    for (final v in vectors('preventive_vectors.json')) {
      final id = v['vector_id']! as String;
      test('$id ${v['service_id']}', () {
        final input = PreventiveInput.fromJson(
          v['input']! as Map<String, Object?>,
        );
        final rules = v['rules'] == null ? packRules : parse(v['rules']);
        final a = assessService(v['service_id']! as String, rules, input);
        final got = <String, Object?>{
          'assessment_status': a.assessmentStatus,
          'due_state': a.dueState,
          'eligibility_state': a.eligibilityState,
          'next_due_date': a.nextDueDate,
          'recommendation_mode': a.recommendationMode,
        };
        final e = v['expected']! as Map<String, Object?>;
        checkExpectedKeys(e, got.keys.toSet(), id);
        for (final k in e.keys) {
          expect(got[k], e[k], reason: '$id.$k');
        }
        expect(a.engineId, preventiveEngineId);
        expect(a.engineVersion, preventiveEngineVersion);
        expect(a.limitations, isNotEmpty);
        expect(a.inputs, same(input));
        expect(a.explanation, isNotEmpty);
      });
    }
  });

  group('engine invariants beyond the vectors', () {
    test('missing is never zero and a refusal carries its model', () {
      final r = bmi({'weight_kg': null, 'height_m': null});
      expect(r.value, isNull);
      expect(r.missingInputs, ['weight_kg', 'height_m']);
      expect(r.modelId, 'DERIVED-BMI-1');
      expect(r.version, '1');
      expect(r.resultClass, ResultClass.derivedMeasurement);
      expect(r.limitations, isNotEmpty);
    });

    test('rolling window refuses a non-integer window', () {
      final r = rollingMean({
        'values': [1, 2],
        'window': 1.5,
      });
      expect(r.errorCode, 'INVALID_WINDOW');
      expect(r.value, isNull);
    });

    test('OLS refuses zero time variance', () {
      final r = olsSlope({
        'points': [
          {'t': 1, 'v': 1},
          {'t': 1, 'v': 2},
        ],
      });
      expect(r.errorCode, 'ZERO_TIME_VARIANCE');
    });

    test('a recipe without serving count or cooked mass divides nothing', () {
      final r = computeRecipe(
        const RecipeVersion(
          recipeId: 'R',
          version: 1,
          name: 'n',
          ingredients: [],
          servingCount: null,
          finalCookedMassG: null,
        ),
      );
      expect(r.perServing, isNull);
      expect(r.per100gCooked, isNull);
      expect(r.missingInputs, ['serving_count', 'final_cooked_mass_g']);
    });
  });
}
