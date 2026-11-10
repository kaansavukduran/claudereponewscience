// F008@v0.32: medicines and supplements. The product, its plan and each
// recorded dose are separate records; a plan never counts as a dose; text is
// kept as typed; corrections and deletions follow the usual history rules.
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

Matcher inputError(String code) =>
    throwsA(isA<InputError>().having((e) => e.code, 'code', code));

void main() {
  test('a plan is not a dose: no dose until one is recorded', () async {
    final (svc, me, _) = await fresh();
    final item = await svc.addMedication(
      profileId: me,
      name: '  Vitamin D3 ',
      category: MedicationCategory.supplement,
      strength: '1000 IU',
      ingredients: 'cholecalciferol',
    );
    await svc.planMedication(
      profileId: me,
      itemRootId: item.id,
      schedule: '1 capsule every morning',
      source: PlanSource.ownChoice,
    );
    var view = (await svc.medications(me)).single;
    expect(view.item.name, 'Vitamin D3');
    expect(view.item.ingredients, 'cholecalciferol');
    expect(view.plan!.schedule, '1 capsule every morning');
    expect(view.doses, isEmpty);
    expect(view.count(IntakeStatus.taken), 0);

    await svc.recordDose(
      profileId: me,
      itemRootId: item.id,
      status: IntakeStatus.taken,
      amount: '1 capsule',
      when: '2026-11-10 08:15',
    );
    await svc.recordDose(
      profileId: me,
      itemRootId: item.id,
      status: IntakeStatus.skipped,
    );
    view = (await svc.medications(me)).single;
    expect(view.count(IntakeStatus.taken), 1);
    expect(view.count(IntakeStatus.skipped), 1);
    final taken = view.doses
        .map((d) => d.details! as MedicationIntakeDetails)
        .firstWhere((d) => d.status == IntakeStatus.taken);
    expect(taken.amount, '1 capsule');
    final skipped = view.doses
        .map((d) => d.details! as MedicationIntakeDetails)
        .firstWhere((d) => d.status == IntakeStatus.skipped);
    expect(skipped.amount, isNull, reason: 'never assumed from the plan');
  });

  test('a newer plan is shown; the older one stays in the store', () async {
    final (svc, me, repo) = await fresh();
    final item = await svc.addMedication(
      profileId: me,
      name: 'Metformin',
      category: MedicationCategory.medicine,
    );
    await svc.planMedication(
      profileId: me,
      itemRootId: item.id,
      schedule: '500 mg twice a day',
      source: PlanSource.prescribed,
    );
    await svc.planMedication(
      profileId: me,
      itemRootId: item.id,
      schedule: '500 mg once a day',
      source: PlanSource.prescribed,
    );
    expect(
      (await svc.medications(me)).single.plan!.schedule,
      '500 mg once a day',
    );
    final plans = await repo.records(me, kind: RecordKind.medicationPlan);
    expect(plans, hasLength(2));
  });

  test('entry rules: name required, text kept within 300 characters, a '
      'plan or dose needs a live item', () async {
    final (svc, me, _) = await fresh();
    expect(
      () => svc.addMedication(
        profileId: me,
        name: '  ',
        category: MedicationCategory.other,
      ),
      inputError('EMPTY'),
    );
    expect(
      () => svc.addMedication(
        profileId: me,
        name: 'x' * 301,
        category: MedicationCategory.other,
      ),
      inputError('TEXT_TOO_LONG'),
    );
    expect(
      () => svc.recordDose(
        profileId: me,
        itemRootId: 'nope',
        status: IntakeStatus.taken,
      ),
      inputError('TARGET_NOT_FOUND'),
    );
    final item = await svc.addMedication(
      profileId: me,
      name: 'Iron',
      category: MedicationCategory.supplement,
    );
    expect(
      () =>
          svc.planMedication(profileId: me, itemRootId: item.id, schedule: ''),
      inputError('EMPTY'),
    );
    await svc.amend(
      profileId: me,
      targetId: item.id,
      reason: AmendReason.deleted,
    );
    expect(await svc.medications(me), isEmpty);
    expect(
      () => svc.recordDose(
        profileId: me,
        itemRootId: item.id,
        status: IntakeStatus.taken,
      ),
      inputError('TARGET_NOT_FOUND'),
    );
  });

  test('records survive a round trip at schema 6; a quantity or a wrong '
      'details type is refused', () async {
    final (svc, me, _) = await fresh();
    final item = await svc.addMedication(
      profileId: me,
      name: 'Omega-3',
      category: MedicationCategory.supplement,
      form: 'softgel',
    );
    expect(item.schemaVersion, 6);
    final back = HealthRecord.fromJson(item.toJson());
    expect(back.details, item.details);
    expect(() => back.validate(), returnsNormally);

    final withQuantity = HealthRecord.fromJson({
      ...item.toJson(),
      'quantity': {'value': 1, 'unit': 'kg'},
    });
    expect(
      withQuantity.validate,
      throwsA(
        isA<RecordValidationError>().having(
          (e) => e.code,
          'code',
          'STRUCTURED_HAS_NO_QUANTITY',
        ),
      ),
    );
    final wrongType = HealthRecord.fromJson({
      ...item.toJson(),
      'kind': 'medication.intake',
    });
    expect(wrongType.validate, throwsA(isA<RecordValidationError>()));
    final emptyName = HealthRecord.fromJson({
      ...item.toJson(),
      'details': {...(item.details!.toJson()), 'name': ' '},
    });
    expect(
      emptyName.validate,
      throwsA(
        isA<RecordValidationError>().having(
          (e) => e.code,
          'code',
          'MEDICATION_NAME_EMPTY',
        ),
      ),
    );
    final oldSchema = HealthRecord.fromJson({
      ...item.toJson(),
      'schema_version': 5,
    });
    expect(
      oldSchema.validate,
      throwsA(
        isA<RecordValidationError>().having(
          (e) => e.code,
          'code',
          'KIND_NEEDS_NEWER_SCHEMA',
        ),
      ),
    );
  });
}
