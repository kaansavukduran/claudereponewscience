// F007 slice 5: food as typed. Nutrients only as copied from a label; one not
// given is missing, never zero; nothing is added up; no food database.
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

Future<(HeartbeatService, String, LogRepository)> fresh() async {
  final repo = LogRepository(
    sink: MemoryLogSink(),
    durability: StorageDurability.localFile,
    location: 'test',
  );
  await repo.open();
  final svc = HeartbeatService(repo);
  final me = (await svc.ensureSelfProfile()).id;
  return (svc, me, repo);
}

Matcher inputError(String code, [String? field]) => throwsA(
  isA<InputError>()
      .having((e) => e.code, 'code', code)
      .having((e) => field == null || e.field == field, 'field', isTrue),
);

void main() {
  test('kept as typed; blank nutrients are left out, not zero', () async {
    final (svc, me, _) = await fresh();
    final r = await svc.recordFood(
      profileId: me,
      what: '  Lentil soup ',
      amount: '1 bowl',
      nutrients: {
        PrintedNutrient.energyKcal: '210',
        PrintedNutrient.protein: '12,5',
        PrintedNutrient.fat: '  ',
        PrintedNutrient.salt: '0',
      },
      per: LabelBasis.perServing,
    );
    final d = r.details! as FoodEntryDetails;
    expect(d.what, 'Lentil soup');
    expect(d.amount, '1 bowl');
    expect(d.nutrients, {
      PrintedNutrient.energyKcal: '210',
      PrintedNutrient.protein: '12,5',
      PrintedNutrient.salt: '0', // a printed zero is kept as zero
    });
    expect(d.per, LabelBasis.perServing);
    expect(d.nutrients.containsKey(PrintedNutrient.fat), isFalse);
    expect(r.quantity, isNull);
    expect(r.schemaVersion, 9);
    expect((await svc.foods(me)).single.id, r.id);
  });

  test('refused entries name their field and write nothing', () async {
    final (svc, me, repo) = await fresh();
    expect(
      () => svc.recordFood(profileId: me, what: ' '),
      inputError('EMPTY', 'what'),
    );
    expect(
      () => svc.recordFood(
        profileId: me,
        what: 'Bread',
        nutrients: {PrintedNutrient.salt: 'a little'},
        per: LabelBasis.per100g,
      ),
      inputError('FOOD_NUTRIENT_NOT_A_NUMBER', 'nutrient-salt'),
    );
    expect(
      () => svc.recordFood(
        profileId: me,
        what: 'Bread',
        nutrients: {PrintedNutrient.protein: '-3'},
        per: LabelBasis.per100g,
      ),
      inputError('FOOD_NUTRIENT_NOT_A_NUMBER', 'nutrient-protein'),
    );
    expect(
      () => svc.recordFood(
        profileId: me,
        what: 'Bread',
        nutrients: {PrintedNutrient.protein: '8'},
      ),
      inputError('FOOD_LABEL_BASIS_REQUIRED', 'per'),
    );
    expect(
      () => svc.recordFood(profileId: me, what: 'Bread', amount: 'y' * 301),
      inputError('TEXT_TOO_LONG', 'amount'),
    );
    expect(
      () => svc.recordFood(profileId: me, what: 'x' * 301),
      inputError('TEXT_TOO_LONG', 'what'),
    );
    expect(
      () =>
          svc.recordFood(profileId: me, what: 'Tea', when: '2999-01-01 08:00'),
      inputError('FUTURE_TIME', 'when'),
    );
    expect(await repo.records(me, kind: RecordKind.foodEntry), isEmpty);
  });

  test('round trip at schema 9; a stored value that is not a number or an '
      'unknown nutrient is refused', () async {
    final (svc, me, _) = await fresh();
    final r = await svc.recordFood(
      profileId: me,
      what: 'Oats',
      nutrients: {PrintedNutrient.fibre: '10'},
      per: LabelBasis.per100g,
    );
    final back = HealthRecord.fromJson(r.toJson());
    expect(back.details, r.details);
    expect(back.validate, returnsNormally);
    final bad = HealthRecord.fromJson({
      ...r.toJson(),
      'details': {
        'type': 'food_entry',
        'what': 'Oats',
        'nutrients': {'fibre': 'ten'},
        'per': 'per100g',
      },
    });
    expect(
      bad.validate,
      throwsA(
        isA<RecordValidationError>().having(
          (e) => e.code,
          'code',
          'FOOD_NUTRIENT_NOT_A_NUMBER',
        ),
      ),
    );
    expect(
      () => HealthRecord.fromJson({
        ...r.toJson(),
        'details': {
          'type': 'food_entry',
          'what': 'Oats',
          'nutrients': {'sugar': '3'},
        },
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('printed numbers: digits with one decimal mark only', () {
    expect(parsePrintedNumber('12'), 12);
    expect(parsePrintedNumber(' 12,5 '), 12.5);
    expect(parsePrintedNumber('0.4'), 0.4);
    expect(parsePrintedNumber('9999999,1234'), 9999999.1234);
    for (final bad in [
      '',
      '-1',
      '1,2,3',
      '1e3',
      '12 g',
      '.5',
      '12345678',
      '1,12345',
    ]) {
      expect(parsePrintedNumber(bad), isNull, reason: bad);
    }
  });

  test('a stored label value without its basis is refused', () {
    const d = FoodEntryDetails(
      what: 'Oats',
      nutrients: {PrintedNutrient.fibre: '10'},
    );
    expect(d.problem(), 'FOOD_LABEL_BASIS_REQUIRED');
    expect(const FoodEntryDetails(what: 'Tea').problem(), isNull);
  });

  test('units: energy in kcal or kJ as printed, never converted; the rest '
      'in grams', () {
    expect(
      {for (final n in PrintedNutrient.values) n.name: printedNutrientUnit(n)},
      {
        'energyKcal': 'kcal',
        'energyKj': 'kJ',
        'protein': 'g',
        'carbohydrate': 'g',
        'fat': 'g',
        'fibre': 'g',
        'salt': 'g',
      },
    );
  });

  test('an entry is corrected as a new version; the earlier one stays; only '
      'the shown entry of this kind', () async {
    final (svc, me, repo) = await fresh();
    final first = await svc.recordFood(profileId: me, what: 'Lentil soup');
    final fixed = await svc.recordFood(
      profileId: me,
      what: 'Lentil soup',
      amount: '2 bowls',
      correcting: first.id,
    );
    expect(fixed.supersedesId, first.id);
    expect(fixed.amendReason, AmendReason.correction);
    expect((await svc.foods(me)).single.id, fixed.id);
    expect(await repo.records(me, kind: RecordKind.foodEntry), hasLength(2));
    expect(
      () => svc.recordFood(profileId: me, what: 'x', correcting: first.id),
      inputError('TARGET_NOT_CURRENT'),
    );
    final w = await svc.recordWeightKg(profileId: me, input: '70');
    expect(
      () => svc.recordFood(profileId: me, what: 'x', correcting: w.id),
      inputError('TARGET_WRONG_KIND'),
    );
  });
}
