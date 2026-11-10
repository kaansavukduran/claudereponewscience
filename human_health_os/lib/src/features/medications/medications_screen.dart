import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../application/heartbeat_service.dart';
import '../../domain/records/health_record.dart';
import '../../l10n/strings.dart';
import '../../presentation/widgets/aion.dart';
import '../timeline/timeline_screen.dart' show fmtWhen;

/// Medicines and supplements (F008): what the person uses, how it is meant
/// to be taken, and each dose they record as taken or skipped. Kept as
/// typed. A plan is never counted as a dose; nothing is checked or advised.
class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  List<MedicationView>? _items;

  HeartbeatService get _svc => widget.services.heartbeat;
  String get _me => widget.services.self.id;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final items = await _svc.medications(_me);
    if (mounted) setState(() => _items = items);
  }

  bool _busy = false;

  /// One change at a time; a refused change (a double tap on an older view,
  /// an item gone) is said in words, and the list is read again either way.
  Future<void> _setState(String itemRootId, PlanState state) async {
    if (_busy) return;
    _busy = true;
    final s = S.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      await _svc.setPlanState(
        profileId: _me,
        itemRootId: itemRootId,
        state: state,
      );
    } on InputError catch (e) {
      messenger?.showSnackBar(
        SnackBar(
          key: const ValueKey('meds-state-error'),
          content: Text(s.inputError(e.code)),
        ),
      );
    } finally {
      _busy = false;
      await _reload();
    }
  }

  Future<void> _sheet(Widget Function(BuildContext) builder) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: builder,
    );
    if (saved == true) await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final items = _items;
    return ListView(
      key: const ValueKey('screen-medications'),
      padding: const EdgeInsets.all(16),
      children: [
        Semantics(
          header: true,
          child: Text(s.medsTitle, style: text.headlineSmall),
        ),
        const SizedBox(height: 8),
        Text(s.medsIntro, style: text.bodyMedium),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            key: const ValueKey('meds-add'),
            onPressed: () => _sheet((_) => _AddItemSheet(svc: _svc, me: _me)),
            icon: const Icon(Icons.add),
            label: Text(s.medsAdd),
          ),
        ),
        const SizedBox(height: 16),
        if (items == null)
          const Center(child: CircularProgressIndicator())
        else if (items.isEmpty)
          Row(
            children: [
              const AionFigure(height: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Text(s.medsNone, key: const ValueKey('meds-none')),
              ),
            ],
          )
        else
          for (final m in items)
            _ItemCard(
              view: m,
              onPlan: () => _sheet(
                (_) => _PlanSheet(svc: _svc, me: _me, itemRootId: m.rootId),
              ),
              onDose: () => _sheet(
                (_) => _DoseSheet(svc: _svc, me: _me, itemRootId: m.rootId),
              ),
              onState: (state) => _setState(m.rootId, state),
            ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.view,
    required this.onPlan,
    required this.onDose,
    required this.onState,
  });

  final MedicationView view;
  final VoidCallback onPlan;
  final VoidCallback onDose;
  final ValueChanged<PlanState> onState;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final item = view.item;
    final plan = view.plan;
    final facts = [
      if (item.strength != null) item.strength!,
      if (item.form != null) item.form!,
      if (item.ingredients != null) item.ingredients!,
    ].join(' · ');
    return Card(
      key: ValueKey('meds-item-${view.rootId}'),
      semanticContainer: true,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.name} · ${s.medsCategoryLabel(item.category)}',
              style: text.titleMedium,
            ),
            if (facts.isNotEmpty) Text(facts, style: text.bodyMedium),
            const SizedBox(height: 8),
            Text(
              plan == null
                  ? s.medsNoPlan
                  : s.medsPlanLineState(
                      plan.schedule,
                      s.medsPlanSourceLabel(plan.source),
                      s.medsPlanStateLabel(plan.state),
                    ),
              key: ValueKey('meds-plan-${view.rootId}'),
            ),
            const SizedBox(height: 4),
            Text(
              view.doses.isEmpty
                  ? s.medsNoDoses
                  : s.medsDoseCounts(
                      view.count(IntakeStatus.taken),
                      view.count(IntakeStatus.skipped),
                    ),
              key: ValueKey('meds-counts-${view.rootId}'),
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            for (final d in view.doses.take(5))
              Text(
                s.medsDoseLine(
                  fmtWhen(d.observedAt),
                  (d.details! as MedicationIntakeDetails).status ==
                      IntakeStatus.taken,
                  (d.details! as MedicationIntakeDetails).amount,
                ),
              ),
            if (view.doses.length > 5)
              Text(
                s.medsMoreDoses(view.doses.length - 5),
                key: ValueKey('meds-more-${view.rootId}'),
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  key: ValueKey('meds-plan-add-${view.rootId}'),
                  onPressed: onPlan,
                  child: Text(s.medsPlanAdd),
                ),
                FilledButton.tonal(
                  key: ValueKey('meds-dose-${view.rootId}'),
                  onPressed: onDose,
                  child: Text(s.medsDose),
                ),
                if (plan != null && plan.state == PlanState.active) ...[
                  TextButton(
                    key: ValueKey('meds-pause-${view.rootId}'),
                    onPressed: () => onState(PlanState.paused),
                    child: Text(s.medsPause),
                  ),
                  TextButton(
                    key: ValueKey('meds-stop-${view.rootId}'),
                    onPressed: () => onState(PlanState.stopped),
                    child: Text(s.medsStop),
                  ),
                ],
                if (plan != null && plan.state != PlanState.active)
                  TextButton(
                    key: ValueKey('meds-resume-${view.rootId}'),
                    onPressed: () => onState(PlanState.active),
                    child: Text(s.medsResume),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A form in a bottom sheet: fields, an error line and Save.
class _FormSheet extends StatelessWidget {
  const _FormSheet({
    required this.title,
    required this.children,
    required this.error,
    required this.onSave,
    required this.saveKey,
  });

  final String title;
  final List<Widget> children;
  final String? error;
  final VoidCallback onSave;
  final String saveKey;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 +
            MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 12),
            ...children,
            if (error != null) ...[
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(
                  error!,
                  key: const ValueKey('meds-error'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              key: ValueKey(saveKey),
              onPressed: onSave,
              child: Text(s.medsSave),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _field(String key, String label, TextEditingController c) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: TextField(
    key: ValueKey(key),
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  ),
);

class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet({required this.svc, required this.me});

  final HeartbeatService svc;
  final String me;

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _name = TextEditingController();
  final _ingredients = TextEditingController();
  final _strength = TextEditingController();
  final _form = TextEditingController();
  var _category = MedicationCategory.supplement;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _ingredients, _strength, _form]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final s = S.of(context);
    try {
      await widget.svc.addMedication(
        profileId: widget.me,
        name: _name.text,
        category: _category,
        ingredients: _ingredients.text,
        strength: _strength.text,
        form: _form.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on InputError catch (e) {
      setState(() => _error = s.inputError(e.code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _FormSheet(
      title: s.medsAdd,
      error: _error,
      onSave: _save,
      saveKey: 'meds-item-save',
      children: [
        _field('meds-name', s.medsName, _name),
        ExcludeSemantics(child: Text(s.medsCategory)),
        const SizedBox(height: 4),
        Semantics(
          container: true,
          label: s.medsCategory,
          child: Wrap(
            spacing: 8,
            children: [
              for (final c in MedicationCategory.values)
                ChoiceChip(
                  key: ValueKey('meds-category-${c.name}'),
                  label: Text(s.medsCategoryLabel(c)),
                  selected: c == _category,
                  onSelected: (_) => setState(() => _category = c),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _field('meds-strength', s.medsStrength, _strength),
        _field('meds-form', s.medsForm, _form),
        _field('meds-ingredients', s.medsIngredients, _ingredients),
      ],
    );
  }
}

class _PlanSheet extends StatefulWidget {
  const _PlanSheet({
    required this.svc,
    required this.me,
    required this.itemRootId,
  });

  final HeartbeatService svc;
  final String me;
  final String itemRootId;

  @override
  State<_PlanSheet> createState() => _PlanSheetState();
}

class _PlanSheetState extends State<_PlanSheet> {
  final _schedule = TextEditingController();
  var _source = PlanSource.unknown;
  String? _error;

  @override
  void dispose() {
    _schedule.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = S.of(context);
    try {
      await widget.svc.planMedication(
        profileId: widget.me,
        itemRootId: widget.itemRootId,
        schedule: _schedule.text,
        source: _source,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on InputError catch (e) {
      setState(() => _error = s.inputError(e.code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _FormSheet(
      title: s.medsPlanAdd,
      error: _error,
      onSave: _save,
      saveKey: 'meds-plan-save',
      children: [
        _field('meds-schedule', s.medsPlanSchedule, _schedule),
        ExcludeSemantics(child: Text(s.medsPlanSource)),
        const SizedBox(height: 4),
        Semantics(
          container: true,
          label: s.medsPlanSource,
          child: Wrap(
            spacing: 8,
            children: [
              for (final p in PlanSource.values)
                ChoiceChip(
                  key: ValueKey('meds-source-${p.name}'),
                  label: Text(s.medsPlanSourceLabel(p)),
                  selected: p == _source,
                  onSelected: (_) => setState(() => _source = p),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DoseSheet extends StatefulWidget {
  const _DoseSheet({
    required this.svc,
    required this.me,
    required this.itemRootId,
  });

  final HeartbeatService svc;
  final String me;
  final String itemRootId;

  @override
  State<_DoseSheet> createState() => _DoseSheetState();
}

class _DoseSheetState extends State<_DoseSheet> {
  final _amount = TextEditingController();
  final _when = TextEditingController();
  var _status = IntakeStatus.taken;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _when.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = S.of(context);
    try {
      await widget.svc.recordDose(
        profileId: widget.me,
        itemRootId: widget.itemRootId,
        status: _status,
        amount: _amount.text,
        when: _when.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on InputError catch (e) {
      setState(() => _error = s.inputError(e.code));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _FormSheet(
      title: s.medsDose,
      error: _error,
      onSave: _save,
      saveKey: 'meds-dose-save',
      children: [
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              key: const ValueKey('meds-status-taken'),
              label: Text(s.medsDoseTaken),
              selected: _status == IntakeStatus.taken,
              onSelected: (_) => setState(() => _status = IntakeStatus.taken),
            ),
            ChoiceChip(
              key: const ValueKey('meds-status-skipped'),
              label: Text(s.medsDoseSkipped),
              selected: _status == IntakeStatus.skipped,
              onSelected: (_) => setState(() => _status = IntakeStatus.skipped),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _field('meds-amount', s.medsDoseAmount, _amount),
        _field('meds-when', s.medsDoseWhen, _when),
      ],
    );
  }
}
