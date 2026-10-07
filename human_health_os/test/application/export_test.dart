// F005@v0.32 deterministic export of the canonical records (master §39).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/export.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/profile/profile.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

void main() {
  final state = parseVaultLog(
    File('test/fixtures/vault/v1_f004_schema3.hhoslog.jsonl')
        .readAsStringSync(),
  );
  final self = state.profiles.values.single;
  final at = DateTime.utc(2026, 10, 7, 12);

  String export(Iterable<HealthRecord> records, {Profile? profile}) =>
      exportRecordsJson(
        profile: profile ?? self,
        records: records,
        exportedAt: at,
        appVersion: '0.1.0+1',
      );

  test('the same records give the same bytes, whatever their order', () {
    final a = export(state.records.values);
    expect(export(state.records.values.toList().reversed), a);
    expect(export([...state.records.values]..shuffle()), a);
  });

  test('every stored version is exported as stored; the timeline says '
      'what is current', () {
    final d = jsonDecode(export(state.records.values)) as Map<String, Object?>;
    expect(d['format'], 'hhos-export');
    expect(d['encryption'], 'none');
    expect(d['exported_at'], '2026-10-07T12:00:00.000Z');
    final records = (d['records']! as List).cast<Map<String, Object?>>();
    expect(records.length, state.records.length);
    for (final r in records) {
      expect(r, state.records[r['id']]!.toJson(), reason: 'unchanged');
    }
    final ferritin = records.singleWhere(
      (r) => (r['lab'] as Map?)?['analyte_label'] == 'Ferritin',
    );
    expect(
      (ferritin['quantity']! as Map)['unit'],
      isNull,
      reason: 'missing stays missing',
    );
    final timeline = (d['timeline']! as List).cast<Map<String, Object?>>();
    final hba1c = timeline.singleWhere(
      (e) => e['root_id'] == '00000000-0000-4000-8000-0000000000d4',
    );
    expect(hba1c['current_ids'], ['00000000-0000-4000-8000-0000000000d5']);
    expect(hba1c['version_ids'], [
      '00000000-0000-4000-8000-0000000000d4',
      '00000000-0000-4000-8000-0000000000d5',
    ]);
  });

  test('only the chosen profile is exported', () {
    final other = Profile(
      id: 'someone-else',
      type: ProfileType.realOther,
      createdAt: DateTime.utc(2026),
    );
    final d = jsonDecode(export(state.records.values, profile: other)) as Map;
    expect(d['records'], isEmpty);
    expect(d['record_count'], 0);
  });
}
