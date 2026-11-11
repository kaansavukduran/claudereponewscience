// F011-S1 (D-037): the Dart engines pass the language-neutral golden vectors
// in contracts/golden_vectors, the same files the TS reference
// (packages/domain/test/golden.test.ts) and tools/verify_contracts.py run.
// Assertions follow the TS harness: states exactly, numbers within the
// vector's declared tolerance, and a refused calculation has no value.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/engines/calc_result.dart';
import 'package:human_health_os/src/domain/engines/core_derived.dart';
import 'package:human_health_os/src/domain/engines/lab_interpretation.dart';
import 'package:human_health_os/src/domain/engines/nutrition_math.dart';

/// Relative to the package root (flutter test runs there).
const String vectorDir = '../contracts/golden_vectors';

/// Vector files the Dart engines run, with their vector counts.
const Map<String, int> covered = {
  'core_derived_vectors.json': 19,
  'lab_interpretation_vectors.json': 19,
  'nutrition_vectors.json': 5,
};

/// Vector files not yet ported to Dart (the visible F011 gap).
const Map<String, int> notCovered = {
  'medication_safety_vectors.json': 10,
  'preventive_vectors.json': 20,
};

Map<String, Object?> load(String name) =>
    jsonDecode(File('$vectorDir/$name').readAsStringSync())
        as Map<String, Object?>;

List<Map<String, Object?>> vectors(String name) => [
  for (final v in load(name)['vectors']! as List<Object?>)
    v! as Map<String, Object?>,
];

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

    test('files not yet covered in Dart (F011 gap)', () {
      // Medication safety (MED-SAFETY) and preventive (PREVENTIVE) engines
      // are still TS/Python only; see D-037.
      expect(notCovered.keys.toList(), [
        'medication_safety_vectors.json',
        'preventive_vectors.json',
      ]);
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
        expect(r1.status.code, e['status']);
        expect(r1.modelId, modelId);
        expect(r1.version, v['version']);
        expect(r1.inputs, same(inputs));
        if (e.containsKey('value')) {
          close(r1.value, e['value'], v['tolerance'], id);
          expect(r1.errorCode, isNull);
          expect(r1.missingInputs, isEmpty);
        } else {
          expect(r1.value, isNull, reason: 'missing/invalid never a number');
        }
        if (e['error_code'] != null) expect(r1.errorCode, e['error_code']);
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
        if (e['status'] != null) expect(a.status, e['status']);
        if (e['reference'] != null) expect(a.referenceState, e['reference']);
        if (e['critical'] != null) expect(a.critical.state, e['critical']);
        if (e.containsKey('external_receipt_confirmed')) {
          expect(a.critical.externalReceiptConfirmed, isFalse);
        }
        if (e['decision_matched'] != null) {
          expect([
            for (final d in a.decision)
              if (d.matched) d.ruleId,
          ], e['decision_matched']);
        }
        if (e['comparability'] != null) {
          expect(a.comparability.state, e['comparability']);
        }
        if (e.containsKey('trend_discontinuity')) {
          expect(a.comparability.trendDiscontinuity, e['trend_discontinuity']);
        }
        if (e['rcv'] != null) expect(a.rcv.state, e['rcv']);
        if (e['rcv_percent'] != null) {
          close(a.rcv.rcvPercent, e['rcv_percent'], e['tolerance'], id);
        }
        if (e['observed_percent_change'] != null) {
          close(
            a.rcv.observedPercentChange,
            e['observed_percent_change'],
            e['tolerance'],
            id,
          );
        }
        if (e['baseline'] != null) expect(a.baseline.state, e['baseline']);
        if (e['robust_z'] != null) {
          close(a.baseline.robustZ, e['robust_z'], e['tolerance'], id);
        }
        if (e['flag_origins'] != null) {
          expect([for (final f in a.flags) f.origin], e['flag_origins']);
        }
        if (e.containsKey('value')) expect(a.value, e['value']);
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
          final r = scaleFood(
            FoodSnapshot.fromJson(v['food']! as Map<String, Object?>),
            Quantity.fromJson(v['quantity']! as Map<String, Object?>),
          );
          expect(r.ok, e['ok']);
          if (e['error'] != null) expect(r.error?.code, e['error']);
          final nutrients =
              (e['nutrients'] as Map<String, Object?>?) ?? const {};
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
          final r = computeRecipe(
            RecipeVersion.fromJson(v['recipe']! as Map<String, Object?>),
          );
          expect(r.ok, e['ok']);
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
