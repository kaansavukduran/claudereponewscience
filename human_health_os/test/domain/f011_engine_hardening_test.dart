// F011-S2 (D-038, review R012): edge cases beyond the golden vectors.
// Rolling windows refuse an empty or all-missing list and a bad min_count;
// no engine reports NaN or an infinity as a result; a result keeps an
// unmodifiable copy of its inputs. Plus the safety wording of the
// medication safety and preventive engines.
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/engines/calc_result.dart';
import 'package:human_health_os/src/domain/engines/core_derived.dart';
import 'package:human_health_os/src/domain/engines/lab_interpretation.dart';
import 'package:human_health_os/src/domain/engines/medication_safety.dart';
import 'package:human_health_os/src/domain/engines/nutrition_math.dart';
import 'package:human_health_os/src/domain/engines/preventive.dart';

void main() {
  group('rolling windows (min_count, empty lists)', () {
    final fns = {'mean': rollingMean, 'median': rollingMedian};
    for (final f in fns.entries) {
      for (final bad in <Object?>[
        0,
        -1,
        1.5,
        double.nan,
        double.infinity,
        '3',
      ]) {
        test('${f.key} refuses min_count $bad', () {
          final r = f.value({
            'values': [1, 2, 3],
            'window': 3,
            'min_count': bad,
          });
          expect(r.status, CalcStatus.invalidInput);
          expect(r.errorCode, 'INVALID_MIN_COUNT');
          expect(r.value, isNull);
        });
      }

      test('${f.key} refuses an empty list (no NaN, no RangeError)', () {
        final r = f.value({'values': <Object?>[], 'window': 3});
        expect(r.status, CalcStatus.missingInput);
        expect(r.errorCode, 'INSUFFICIENT_OBSERVATIONS');
        expect(r.value, isNull);
      });

      test('${f.key} refuses an all-missing list', () {
        final r = f.value({
          'values': [null, double.nan, null],
          'window': 3,
        });
        expect(r.errorCode, 'INSUFFICIENT_OBSERVATIONS');
        expect(r.value, isNull);
      });

      test('${f.key} accepts min_count 2 and 2.0 and a null min_count', () {
        for (final mc in <Object?>[2, 2.0, null]) {
          final r = f.value({
            'values': [1, null, 3],
            'window': 3,
            'min_count': mc,
          });
          expect(r.status, CalcStatus.ok, reason: '$mc');
          expect(r.value, 2);
        }
      });
    }

    test('median of nothing is an argument error, never a value', () {
      expect(() => median(const []), throwsArgumentError);
    });
  });

  group('non-finite results are refused (NON_FINITE_RESULT)', () {
    test('BMI overflow', () {
      final r = bmi({'weight_kg': 1e308, 'height_m': 1e-200});
      expect(r.status, CalcStatus.invalidInput);
      expect(r.errorCode, nonFiniteResultCode);
      expect(r.value, isNull);
      expect(r.modelId, 'DERIVED-BMI-1');
    });

    test('rolling mean overflow', () {
      final r = rollingMean({
        'values': [1e308, 1e308],
        'window': 2,
      });
      expect(r.errorCode, nonFiniteResultCode);
      expect(r.value, isNull);
    });

    test('CalcResult.ok never carries NaN', () {
      const m = ModelRef(
        modelId: 'X',
        version: '1',
        resultClass: ResultClass.experimental,
        unit: null,
      );
      final r = CalcResult.ok(m, double.nan, const {});
      expect(r.status, CalcStatus.invalidInput);
      expect(r.value, isNull);
      expect(r.errorCode, nonFiniteResultCode);
    });

    test('nutrition scaling overflow refuses the whole map', () {
      final food = FoodSnapshot.fromJson({
        'snapshot_id': 'F',
        'name': 'synthetic',
        'source': 'SYN',
        'basis': {'amount': 100, 'unit': 'g'},
        'nutrients': {'protein_g': 1e308, 'fiber_g': null},
      });
      final r = scaleFood(
        food,
        Quantity.fromJson({'amount': 1e10, 'unit': 'g'}),
      );
      expect(r.ok, isFalse);
      expect(r.error, ScaleError.nonFiniteResult);
      expect(r.error!.code, nonFiniteResultCode);
      expect(r.nutrients, isEmpty);
    });

    test('recipe totals overflow refuses the recipe', () {
      final food = FoodSnapshot.fromJson({
        'snapshot_id': 'F',
        'name': 'synthetic',
        'source': 'SYN',
        'basis': {'amount': 100, 'unit': 'g'},
        'nutrients': {'protein_g': 1e308},
      });
      final ing = RecipeIngredient(
        food: food,
        quantity: Quantity.fromJson({'amount': 100, 'unit': 'g'}),
      );
      final r = computeRecipe(
        RecipeVersion(
          recipeId: 'R',
          version: 1,
          name: 'overflow',
          ingredients: [ing, ing],
          servingCount: 2,
          finalCookedMassG: 100,
        ),
      );
      expect(r.ok, isFalse);
      expect(r.errors.last.error, ScaleError.nonFiniteResult);
      expect(r.totals, isEmpty);
      expect(r.perServing, isNull);
      expect(r.per100gCooked, isNull);
    });

    test('lab RCV and baseline overflow', () {
      final a = interpretLabResult(
        LabInterpretationInput.fromJson({
          'result': {
            'analyte_key': 'SYN',
            'value': 1e308,
            'unit': 'u',
            'observed_at': '2026-02-01',
            'method_id': 'M',
            'specimen': 'S',
          },
          'prior': {
            'analyte_key': 'SYN',
            'value': 1e-308,
            'unit': 'u',
            'observed_at': '2026-01-01',
            'method_id': 'M',
            'specimen': 'S',
          },
          'rcv': {'cva': 1, 'cvi': 1, 'z': 1.96, 'source': 'SYN'},
          'baseline_points': [-1e-300, 0, 1e-300, 2e-300, 3e-300],
        }),
      );
      expect(a.rcv.state, nonFiniteResultCode);
      expect(a.rcv.observedPercentChange, isNull);
      expect(a.baseline.state, nonFiniteResultCode);
      expect(a.baseline.robustZ, isNull);
    });

    test('medication amounts that overflow are not combined', () {
      final r = combineAmounts(const [
        AmountPart(1e308, 'g', 'AS_LABELED'),
        AmountPart(1e308, 'g', 'AS_LABELED'),
      ]);
      expect(r.value, isNull);
      expect(r.reason, nonFiniteResultCode);
    });
  });

  group('inputs are an unmodifiable copy', () {
    test('mutating the caller map after compute changes nothing', () {
      final inputs = <String, Object?>{
        'values': <Object?>[1, 2, 3],
        'window': 3,
      };
      final r = rollingMean(inputs);
      inputs['window'] = 99;
      (inputs['values']! as List<Object?>).add(1000);
      expect(r.inputs['window'], 3);
      expect(r.inputs['values'], [1, 2, 3]);
      expect(() => r.inputs['window'] = 1, throwsUnsupportedError);
      expect(
        () => (r.inputs['values']! as List<Object?>).add(4),
        throwsUnsupportedError,
      );
    });

    test('a refusal also keeps a copy', () {
      final inputs = <String, Object?>{'weight_kg': null, 'height_m': 1.8};
      final r = bmi(inputs);
      inputs['weight_kg'] = 80;
      expect(r.inputs['weight_kg'], isNull);
    });
  });

  group('medication safety wording', () {
    const pack = SafetyPack(packId: 'P', version: '1', status: 'SYNTHETIC');
    test('no rule found is never a guarantee of safety', () {
      final a = assessSafety(
        const [],
        const [
          ExposureEntry(
            entryId: 'E',
            productId: 'NOT-IN-CATALOGUE',
            kind: 'TAKEN',
            servingsPerDay: 1,
            time: null,
          ),
        ],
        const [],
        const [],
        pack,
      );
      expect(a.findings.single.type, 'CLEAR_NO_MATCH_FOUND');
      expect(a.findings.single.guaranteedSafe, isFalse);
      expect(a.findings.single.note, contains('NOT a guarantee of safety'));
      expect(a.missingInputs, ['entries.E.product']);
      expect(
        a.limitations.join(' '),
        contains('No rule found ≠ guaranteed safe'),
      );
      expect(a.limitations.join(' '), contains('never prescribes'));
    });

    test('a timing rule without an intake time asks for context', () {
      const products = [
        ProductConcept(
          productId: 'A',
          name: 'a',
          route: 'ORAL',
          labelVersion: 'L1',
          compositionKnown: true,
          ingredients: [
            IngredientAmount(
              ingredientId: 'I1',
              label: 'i1',
              amount: 1,
              unit: 'mg',
              basis: 'AS_LABELED',
              mapping: 'REVIEWED',
            ),
          ],
        ),
        ProductConcept(
          productId: 'B',
          name: 'b',
          route: 'ORAL',
          labelVersion: 'L1',
          compositionKnown: true,
          ingredients: [
            IngredientAmount(
              ingredientId: 'I2',
              label: 'i2',
              amount: 1,
              unit: 'mg',
              basis: 'AS_LABELED',
              mapping: 'REVIEWED',
            ),
          ],
        ),
      ];
      const rule = InteractionRule(
        ruleId: 'T',
        version: '1',
        source: 'SYN',
        kind: 'TIMING_SEPARATION',
        participants: ['I1', 'I2'],
        route: null,
        minSeparationMinutes: 120,
        action: 'SEPARATE_TIMING',
        testOnly: true,
      );
      final a = assessSafety(
        products,
        const [
          ExposureEntry(
            entryId: 'E1',
            productId: 'A',
            kind: 'PLAN',
            servingsPerDay: 1,
            time: '08:00',
          ),
          ExposureEntry(
            entryId: 'E2',
            productId: 'B',
            kind: 'PLAN',
            servingsPerDay: 1,
            time: null,
          ),
        ],
        const [rule],
        const [],
        pack,
      );
      expect(a.findings.single.type, 'INSUFFICIENT_CONTEXT');
      expect(a.findings.single.combinedReason, 'MISSING_TIME');
      expect(a.findings.single.action, isNull);
      expect(a.missingInputs, ['entries.E2.time']);
    });

    test('mass units combine into the largest unit; IU never converts', () {
      final ok = combineAmounts(const [
        AmountPart(500, 'mcg', 'AS_LABELED'),
        AmountPart(1, 'mg', 'AS_LABELED'),
      ]);
      expect(ok.value, 1.5);
      expect(ok.unit, 'mg');
      final iu = combineAmounts(const [
        AmountPart(400, 'IU', 'AS_LABELED'),
        AmountPart(1, 'mg', 'AS_LABELED'),
      ]);
      expect(iu.value, isNull);
      expect(iu.reason, 'UNIT_CONVERSION_RULE_NOT_INSTALLED');
      final undisclosed = combineAmounts(const [
        AmountPart(null, 'mg', 'AS_LABELED'),
        AmountPart(1, 'mg', 'AS_LABELED'),
      ]);
      expect(undisclosed.reason, 'UNDISCLOSED_AMOUNT');
    });
  });

  group('preventive engine', () {
    const input = PreventiveInput(
      asOf: '2026-10-06',
      jurisdiction: null,
      ageYears: null,
      risks: [],
      anatomy: [],
      history: 'UNKNOWN',
      completions: [],
      contraindicated: false,
      dueSoonWindowDays: 30,
    );
    test('unknowns are reported as missing, never assumed', () {
      final a = assessService('SVC', const [], input);
      expect(a.assessmentStatus, 'NO_ACTIVE_PACK');
      expect(a.missingInputs, ['jurisdiction', 'age_years', 'history']);
      expect(a.limitations.join(' '), contains('not a diagnosis'));
      expect(a.limitations.join(' '), contains('recommends nothing'));
    });

    test('calendar arithmetic is timezone-free and leap-aware', () {
      expect(addDays('2026-03-01', 730), '2028-02-29');
      expect(daysBetween('2026-10-06', '2026-10-20'), 14);
      expect(addDays('2026-12-31T23:59:59Z', 1), '2027-01-01');
    });
  });
}
