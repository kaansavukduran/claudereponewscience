/// Timeline projection and correction lineage (ladder F003).
///
/// Pure Dart. The store keeps every record; this projection decides what is
/// current without rewriting anything:
/// - a **correction** supersedes an earlier version; the earlier version
///   stays in the entry's history;
/// - **entered in error** voids its target: the target and the target's own
///   supersession have no effect (a mistaken correction lets the previous
///   version return), and the target stays visible as withdrawn history;
/// - **deleted** tombstones the whole fact (every version of the entry); a
///   later correction cannot resurrect it (no resurrection);
/// - two live corrections of the same version are a **conflict**: both are
///   shown and flagged, never resolved by timestamp (v0.24 FR-166).
library;

import 'health_record.dart';

enum EntryStatus {
  /// One current version.
  current,

  /// More than one live version competes; the person must choose.
  conflict,

  /// Removed by the person (tombstone). Hidden from current views.
  deleted,

  /// Every version was withdrawn as entered in error.
  enteredInError,
}

/// One fact on the timeline with its full version history.
class TimelineEntry {
  const TimelineEntry({
    required this.rootId,
    required this.status,
    required this.heads,
    required this.versions,
    required this.withdrawn,
    this.deletion,
  });

  /// The first version's id: stable identity of the fact.
  final String rootId;
  final EntryStatus status;

  /// The live versions without a live successor: one when current, two or
  /// more in a conflict; for a deleted entry, the versions it had.
  final List<HealthRecord> heads;

  /// Every version of the fact (markers excluded), oldest recorded first.
  final List<HealthRecord> versions;

  /// Versions withdrawn as entered in error.
  final Set<String> withdrawn;

  /// The deletion marker, when [status] is [EntryStatus.deleted].
  final HealthRecord? deletion;

  /// The version shown in lists: the newest head, or the newest version when
  /// nothing is live.
  HealthRecord get shown => heads.isNotEmpty ? heads.first : versions.last;

  /// Corrections exist (more than one version).
  bool get corrected => versions.length > 1;

  bool get isLive =>
      status == EntryStatus.current || status == EntryStatus.conflict;
}

/// Records that withdraw or delete another record (not health facts).
bool isAmendMarker(HealthRecord r) => r.amendReason?.isMarker ?? false;

/// The moment used to order records: an instant as stored, or for a
/// calendar day the start of that day in the device's time zone, so a lab
/// dated D sorts after every instant shown on an earlier local day (review
/// finding: UTC midnight misordered evening entries west of UTC).
DateTime orderingInstant(HealthRecord r) {
  if (!r.observedDateOnly) return r.observedAt;
  final d = r.observedAt;
  return DateTime(d.year, d.month, d.day).toUtc();
}

int _newestFirst(HealthRecord a, HealthRecord b) {
  final t = orderingInstant(b).compareTo(orderingInstant(a));
  if (t != 0) return t;
  final r = b.recordedAt.compareTo(a.recordedAt);
  return r != 0 ? r : a.id.compareTo(b.id);
}

/// Builds the timeline: one entry per fact, newest observation first; ties
/// are broken by entry time, then by id, so the order is deterministic.
/// [includeHidden] adds deleted and fully withdrawn entries (history view).
List<TimelineEntry> buildTimeline(
  Iterable<HealthRecord> records, {
  bool includeHidden = false,
}) {
  final byId = {for (final r in records) r.id: r};
  final voided = <String>{
    for (final r in byId.values)
      if (r.amendReason == AmendReason.enteredInError) ?r.supersedesId,
  };
  final deletions = <String, HealthRecord>{
    for (final r in byId.values)
      if (r.amendReason == AmendReason.deleted && r.supersedesId != null)
        r.supersedesId!: r,
  };
  // Live correction edges: target -> its live successors.
  final successors = <String, List<HealthRecord>>{};
  for (final r in byId.values) {
    final target = r.supersedesId;
    if (target == null || isAmendMarker(r) || voided.contains(r.id)) continue;
    if (!byId.containsKey(target)) continue;
    successors.putIfAbsent(target, () => []).add(r);
  }
  String rootOf(HealthRecord r) {
    var cur = r;
    final seen = <String>{};
    while (true) {
      final up = cur.supersedesId;
      final parent = up == null ? null : byId[up];
      if (parent == null || !seen.add(cur.id)) {
        return cur.id;
      }
      cur = parent;
    }
  }

  final groups = <String, List<HealthRecord>>{};
  for (final r in byId.values) {
    if (isAmendMarker(r)) continue;
    groups.putIfAbsent(rootOf(r), () => []).add(r);
  }
  final entries = <TimelineEntry>[];
  for (final MapEntry(key: root, value: versions) in groups.entries) {
    // Oldest first in lineage order: a version always comes after the one
    // it corrects, even when both carry the same entry time.
    final inGroup = {for (final v in versions) v.id};
    final depth = <String, int>{};
    int depthOf(HealthRecord v) => depth[v.id] ??= () {
      var d = 0;
      var cur = v;
      final seen = <String>{cur.id};
      while (cur.supersedesId != null &&
          inGroup.contains(cur.supersedesId) &&
          seen.add(cur.supersedesId!)) {
        cur = byId[cur.supersedesId]!;
        d++;
      }
      return d;
    }();
    versions.sort((a, b) {
      final d = depthOf(a).compareTo(depthOf(b));
      if (d != 0) return d;
      final t = a.recordedAt.compareTo(b.recordedAt);
      return t != 0 ? t : a.id.compareTo(b.id);
    });
    final withdrawn = {
      for (final v in versions)
        if (voided.contains(v.id)) v.id,
    };
    final live = [
      for (final v in versions)
        if (!withdrawn.contains(v.id) && v.deletedAt == null) v,
    ];
    final heads = [
      for (final v in live)
        if ((successors[v.id] ?? const []).isEmpty) v,
    ]..sort(_newestFirst);
    HealthRecord? deletion;
    for (final v in versions) {
      deletion ??= deletions[v.id];
    }
    // Schema 1 could mark a version itself deleted; that tombstones the fact.
    final legacyDeleted = versions.any((v) => v.deletedAt != null);
    final EntryStatus status;
    if (deletion != null || legacyDeleted) {
      status = EntryStatus.deleted;
    } else if (live.isEmpty) {
      status = EntryStatus.enteredInError;
    } else if (heads.length > 1) {
      status = EntryStatus.conflict;
    } else {
      status = EntryStatus.current;
    }
    final entry = TimelineEntry(
      rootId: root,
      status: status,
      heads: heads,
      versions: versions,
      withdrawn: withdrawn,
      deletion: deletion,
    );
    if (entry.isLive || includeHidden) entries.add(entry);
  }
  entries.sort((a, b) {
    final c = _newestFirst(a.shown, b.shown);
    return c != 0 ? c : a.rootId.compareTo(b.rootId);
  });
  return entries;
}
