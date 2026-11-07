// F007 slice 2: when a measurement was taken and when it was saved, as the
// tiles, rows and sheets show it.
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/features/measurements/measurement_format.dart';
import 'package:human_health_os/src/features/today/measurements_card.dart';
import 'package:human_health_os/src/l10n/strings.dart';

HealthRecord at(DateTime observed, DateTime recorded) => HealthRecord(
  id: 'm',
  profileId: 'p',
  kind: RecordKind.height,
  state: RecordState.observed,
  valueStatus: ValueStatus.present,
  quantity: const Quantity(172, 'cm'),
  originalText: '172',
  provenance: const Provenance.manual(),
  observedAt: observed,
  recordedAt: recorded,
  schemaVersion: 5,
);

String fmt(DateTime t) => 'T${t.toIso8601String()}';

void main() {
  final t = DateTime.utc(2026, 11, 7, 12);
  group('saved time shown only when it differs by more than a minute', () {
    test('threshold and direction', () {
      String? saved(Duration d) => savedWhenDifferent(at(t, t.add(d)), fmt);
      expect(saved(Duration.zero), isNull);
      expect(saved(const Duration(seconds: 59)), isNull);
      expect(
        saved(const Duration(seconds: 60)),
        isNull,
        reason: 'strictly more',
      );
      expect(saved(const Duration(seconds: 61)), isNotNull);
      expect(saved(const Duration(days: 2)), isNotNull);
      // Measured later than saved (a time up to 5 minutes ahead).
      expect(saved(const Duration(seconds: -59)), isNull);
      expect(saved(const Duration(minutes: -4)), isNotNull);
    });

    test('the caption names the measured time first, the save time second', () {
      final r = at(DateTime.utc(2026, 10, 1, 8), t);
      final s = S(AppLang.en);
      expect(
        whenCaption(s, r, fmt),
        'T2026-10-01T08:00:00.000Z · Manual entry · '
        'saved T2026-11-07T12:00:00.000Z',
      );
      expect(
        whenCaption(s, at(t, t), fmt),
        'T2026-11-07T12:00:00.000Z · Manual entry',
      );
    });
  });

  test('the tiles come in a fixed order, seven of them', () {
    expect(MeasurementsCard.kinds, [
      RecordKind.bloodPressure,
      RecordKind.restingHeartRate,
      RecordKind.bodyTemperature,
      RecordKind.oxygenSaturation,
      RecordKind.respiratoryRate,
      RecordKind.waistCircumference,
      RecordKind.height,
    ]);
  });

  test('spoken labels say measured and saved, and the unit in words', () {
    final en = S(AppLang.en)
        .spokenLatest('Height', '172 cm', 'A', 'B', saved: 'C');
    expect(en, 'Height: 172 cm, measured A, saved C, B');
    final tr = S(AppLang.tr)
        .spokenLatest('Boy', '172 cm', 'A', 'B', saved: 'C');
    expect(tr, 'Boy: 172 cm, ölçüm zamanı A, kaydedilme zamanı C, B');
    expect(S(AppLang.en).spokenUnit('°C'), 'degrees Celsius');
    expect(S(AppLang.tr).spokenUnit('°C'), 'santigrat derece');
    expect(S(AppLang.en).spokenUnit('%'), 'percent');
  });
}
