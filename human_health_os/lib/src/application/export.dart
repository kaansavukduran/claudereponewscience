/// Deterministic export of the canonical records (ladder F005).
///
/// A readable JSON file of one profile's records with their full history:
/// every version, withdrawal and deletion as stored, plus the timeline
/// projection that says what is current. The same records and [exportedAt]
/// always give the same bytes (stable order, fixed key order). Missing
/// values stay null; nothing is converted or interpreted.
library;

import 'dart:convert';

import '../domain/profile/profile.dart';
import '../domain/records/health_record.dart';

const String exportFormat = 'hhos-export';
const int exportFormatVersion = 1;

int _stable(HealthRecord a, HealthRecord b) {
  final o = a.observedAt.compareTo(b.observedAt);
  if (o != 0) return o;
  final r = a.recordedAt.compareTo(b.recordedAt);
  return r != 0 ? r : a.id.compareTo(b.id);
}

String exportRecordsJson({
  required Profile profile,
  required Iterable<HealthRecord> records,
  required DateTime exportedAt,
  required String appVersion,
}) {
  final all = [
    for (final r in records)
      if (r.profileId == profile.id) r,
  ]..sort(_stable);
  final timeline = buildTimeline(all, includeHidden: true)
    ..sort((a, b) => a.rootId.compareTo(b.rootId));
  final doc = {
    'format': exportFormat,
    'format_version': exportFormatVersion,
    'exported_at': exportedAt.toUtc().toIso8601String(),
    'app_version': appVersion,
    'encryption': 'none',
    'notice':
        'Not encrypted. Contains health records exactly as stored; '
        'no interpretation.',
    'profile': {'id': profile.id, 'type': profile.type.name},
    'record_count': all.length,
    'records': [for (final r in all) r.toJson()],
    'timeline': [
      for (final e in timeline)
        {
          'root_id': e.rootId,
          'kind': e.shown.kind.code,
          'status': e.status.name,
          'current_ids': [for (final h in e.heads) h.id],
          'version_ids': [for (final v in e.versions) v.id],
          'withdrawn_ids': e.withdrawn.toList()..sort(),
          'deletion_id': e.deletion?.id,
        },
    ],
  };
  return '${const JsonEncoder.withIndent('  ').convert(doc)}\n';
}
