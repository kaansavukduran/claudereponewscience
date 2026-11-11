/// Destinations. Primary navigation is Today, Timeline, Labs (v0.32 kernel)
/// and Medications (F008). The other areas from v0.27 doc 209 are reachable
/// as a secondary "More areas" group (conflict C-8): Nutrition and Activity
/// are built (F007); each still unbuilt area names the Forge that builds it,
/// so it says so instead of faking content.
library;

import 'package:flutter/material.dart';

import '../l10n/strings.dart';

enum DestinationId {
  today,
  timeline,
  labs,
  medications,
  nutrition,
  activity,
  conditions,
  preventive,
  compare,
  learn,
}

class Destination {
  const Destination({
    required this.id,
    required this.en,
    required this.tr,
    required this.icon,
    required this.selectedIcon,
    required this.purposeEn,
    required this.purposeTr,
    required this.plannedForge,
    required this.principleEn,
    required this.principleTr,
    this.emptyStateEn,
    this.emptyStateTr,
  });

  final DestinationId id;
  final String en;
  final String tr;
  final IconData icon;
  final IconData selectedIcon;
  final String purposeEn;
  final String purposeTr;

  /// Ladder Forge(s) that deliver the area's stated purpose (D-011, D-013);
  /// null only when that purpose is fully built.
  final String? plannedForge;

  /// One invariant this area must respect, shown so the empty state still teaches.
  final String principleEn;
  final String principleTr;

  /// What the unbuilt view truthfully says instead of "No records yet" when
  /// records of its kind can already exist elsewhere (e.g. Timeline, while
  /// Today saves weights). Null = "No records yet" is true for this area.
  final String? emptyStateEn;
  final String? emptyStateTr;

  bool get isPrimary => kPrimaryDestinations.contains(id);

  String label(AppLang lang) => lang == AppLang.tr ? tr : en;
  String purpose(AppLang lang) => lang == AppLang.tr ? purposeTr : purposeEn;
  String principle(AppLang lang) =>
      lang == AppLang.tr ? principleTr : principleEn;
  String? emptyState(AppLang lang) =>
      lang == AppLang.tr ? emptyStateTr : emptyStateEn;
}

/// The F001 primary destinations (v0.32 kernel): the only first-level items
/// in both the compact bar and the rail.
const List<DestinationId> kPrimaryDestinations = [
  DestinationId.today,
  DestinationId.timeline,
  DestinationId.labs,
  // Built in F008.
  DestinationId.medications,
];

const List<Destination> destinations = [
  Destination(
    id: DestinationId.today,
    en: 'Today',
    tr: 'Bugün',
    icon: Icons.wb_sunny_outlined,
    selectedIcon: Icons.wb_sunny,
    purposeEn: 'Your day at a glance: check-ins, missions and what changed.',
    purposeTr: 'Günün bir bakışta: kontroller, görevler ve neyin değiştiği.',
    plannedForge: 'Forge F007 · F011',
    principleEn: 'A mission is a plan. Only a logged completion counts.',
    principleTr: 'Görev bir plandır. Yalnız kaydedilen tamamlanma sayılır.',
  ),
  Destination(
    id: DestinationId.timeline,
    en: 'Timeline',
    tr: 'Zaman çizelgesi',
    icon: Icons.timeline_outlined,
    selectedIcon: Icons.timeline,
    purposeEn: 'Every record on one timeline, with its source and corrections.',
    purposeTr: 'Her kayıt, kaynağı ve düzeltmeleriyle tek zaman çizelgesinde.',
    // Built in F003 for every record kind that exists (body weight); Labs
    // results join it in F004.
    plannedForge: null,
    principleEn: 'A correction adds a new version; the old one stays visible in history.',
    principleTr:
        'Düzeltme yeni bir sürüm ekler; eskisi geçmişte görünür kalır.',
  ),
  Destination(
    id: DestinationId.labs,
    en: 'Labs',
    tr: 'Lab',
    icon: Icons.science_outlined,
    selectedIcon: Icons.science,
    purposeEn: 'Lab results as the report printed them: value, unit, specimen, the lab’s flag and its own reference range.',
    purposeTr: 'Lab sonuçları raporda yazdığı gibi: değer, birim, numune, laboratuvarın işareti ve kendi referans aralığı.',
    // Built in F004 (manual entry as printed). Interpretation is not part of
    // this purpose; it is planned with the deterministic engines (F011).
    plannedForge: null,
    principleEn: 'Reference interval ≠ optimal target ≠ decision limit. Out of range ≠ critical.',
    principleTr: 'Referans aralığı ≠ optimal hedef ≠ karar sınırı. Aralık dışı ≠ kritik.',
  ),
  Destination(
    id: DestinationId.medications,
    en: 'Medications',
    tr: 'İlaçlar',
    icon: Icons.medication_outlined,
    selectedIcon: Icons.medication,
    purposeEn: 'Medicines and supplements: products, ingredients, plans and actual intake.',
    purposeTr:
        'İlaç ve takviyeler: ürünler, etken maddeler, planlar ve gerçek alım.',
    // Built in F008: products, plans and recorded doses kept apart.
    plannedForge: null,
    principleEn: 'A prescription or reminder is not an intake. "No interaction found" is not "safe".',
    principleTr: 'Reçete ya da hatırlatma alım değildir. "Etkileşim bulunamadı", "güvenli" demek değildir.',
  ),
  Destination(
    id: DestinationId.nutrition,
    en: 'Nutrition',
    tr: 'Beslenme',
    icon: Icons.restaurant_outlined,
    selectedIcon: Icons.restaurant,
    purposeEn:
        'What you ate or drank, with nutrients only as copied from a label.',
    purposeTr: 'Ne yediğin ya da içtiğin; besin değerleri yalnız etiketten kopyalandığı gibi.',
    // Built in F007 slice 5: entries as typed; no food database, no totals.
    plannedForge: null,
    principleEn: 'A nutrient the label does not report is missing, not zero.',
    principleTr: 'Etikette yazmayan bir besin öğesi eksiktir, sıfır değil.',
  ),
  Destination(
    id: DestinationId.activity,
    en: 'Activity',
    tr: 'Aktivite',
    icon: Icons.directions_run_outlined,
    selectedIcon: Icons.directions_run,
    purposeEn: 'Walks, workouts and steps typed by hand; sleep is on Today; wearables later.',
    purposeTr: 'Elle yazılan yürüyüş, antrenman ve adımlar; uyku Bugün ekranında; giyilebilir cihazlar ileride.',
    // Built in F007 slice 6 (typed by hand). Device data comes with F013.
    plannedForge: null,
    principleEn:
        'Two devices counting the same hour are de-duplicated, never summed.',
    principleTr: 'Aynı saati sayan iki cihaz tekilleştirilir, asla toplanmaz.',
  ),
  Destination(
    id: DestinationId.conditions,
    en: 'Conditions',
    tr: 'Durumlar',
    icon: Icons.healing_outlined,
    selectedIcon: Icons.healing,
    purposeEn:
        'Conditions and symptoms in your words, with who they come from.',
    purposeTr:
        'Durumlar ve belirtiler kendi sözlerinle, kimden geldiğiyle birlikte.',
    // Built in F009 slice 1; treatments and care pathways come later.
    plannedForge: null,
    principleEn: 'Self-reported is not a confirmed diagnosis.',
    principleTr: 'Öz bildirim, doğrulanmış tanı değildir.',
  ),
  Destination(
    id: DestinationId.preventive,
    en: 'Preventive',
    tr: 'Koruyucu',
    icon: Icons.shield_outlined,
    selectedIcon: Icons.shield,
    purposeEn: 'Vaccinations, screenings and check-ups in your words: done, planned or not sure. Nothing is recommended or scheduled.',
    purposeTr: 'Aşılar, taramalar ve kontroller kendi sözlerinle: yapıldı, planlandı ya da emin değilim. Hiçbir şey önerilmez ya da takvime konmaz.',
    // Built in F009 slice 2 (as named, no guideline pack, no schedule).
    plannedForge: null,
    principleEn:
        'Unknown history is not "never done". Screening is not diagnosis.',
    principleTr:
        'Bilinmeyen geçmiş "hiç yapılmadı" değildir. Tarama tanı değildir.',
  ),
  Destination(
    id: DestinationId.compare,
    en: 'Compare',
    tr: 'Karşılaştır',
    icon: Icons.compare_arrows_outlined,
    selectedIcon: Icons.compare_arrows,
    purposeEn:
        'Compare yourself with scenarios ("what if") or synthetic profiles.',
    purposeTr: 'Kendini senaryolarla ("ya şöyle olsaydı") ya da sentetik profillerle karşılaştır.',
    plannedForge: 'Forge F011',
    principleEn: 'A scenario never changes your real records.',
    principleTr: 'Senaryo gerçek kayıtlarını asla değiştirmez.',
  ),
  Destination(
    id: DestinationId.learn,
    en: 'Learn',
    tr: 'Öğren',
    icon: Icons.school_outlined,
    selectedIcon: Icons.school,
    purposeEn: 'Short lessons: missing vs zero, reference ranges, risk vs score, healthspan.',
    purposeTr: 'Kısa dersler: eksik ve sıfır, referans aralıkları, risk ve skor, sağlıklı yaşam süresi.',
    plannedForge: 'Forge F011',
    principleEn: 'Reading a lesson is not the same as a health improvement.',
    principleTr: 'Bir dersi okumak sağlıkta iyileşme ile aynı şey değildir.',
  ),
];

Destination destinationById(DestinationId id) =>
    destinations.firstWhere((d) => d.id == id);

/// Destinations outside primary navigation, in their canonical order.
final List<Destination> plannedDestinations = [
  for (final d in destinations)
    if (!d.isPrimary) d,
];
