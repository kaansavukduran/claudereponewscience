/// Destinations. Primary navigation is exactly Today, Timeline and Labs
/// (v0.32 kernel). The other seven areas from v0.27 doc 209 already exist as
/// tested, honest placeholders and stay reachable as a secondary "Planned"
/// group (conflict C-8). Each names the Forge that builds it, so an unbuilt
/// area says so instead of faking content.
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
    plannedForge: 'Forge F003',
    principleEn: 'A correction adds a new version; the old one stays visible in history.',
    principleTr:
        'Düzeltme yeni bir sürüm ekler; eskisi geçmişte görünür kalır.',
    emptyStateEn: 'This view does not list records yet. Your 10 most recent entries are shown on Today, with how they are stored.',
    emptyStateTr: 'Bu görünüm henüz kayıt listelemiyor. Son 10 girişin, nasıl saklandıklarıyla birlikte Bugün ekranında görünür.',
  ),
  Destination(
    id: DestinationId.labs,
    en: 'Labs',
    tr: 'Lab',
    icon: Icons.science_outlined,
    selectedIcon: Icons.science,
    purposeEn: 'Lab results with units, method, specimen and the report’s own reference interval.',
    purposeTr: 'Birim, yöntem, numune ve raporun kendi referans aralığıyla lab sonuçları.',
    plannedForge: 'Forge F004',
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
    plannedForge: 'Forge F008',
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
        'Foods, meals and recipes with an immutable nutrient snapshot per log.',
    purposeTr: 'Her kayıt için değişmez besin anlık görüntüsüyle yiyecekler, öğünler ve tarifler.',
    plannedForge: 'Forge F007',
    principleEn: 'A nutrient the label does not report is missing, not zero.',
    principleTr: 'Etikette yazmayan bir besin öğesi eksiktir, sıfır değil.',
  ),
  Destination(
    id: DestinationId.activity,
    en: 'Activity',
    tr: 'Aktivite',
    icon: Icons.directions_run_outlined,
    selectedIcon: Icons.directions_run,
    purposeEn:
        'Steps, workouts and sleep from manual entry or (later) wearables.',
    purposeTr: 'Elle girişten ya da (ileride) giyilebilir cihazlardan adım, antrenman ve uyku.',
    plannedForge: 'Forge F007',
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
    purposeEn: 'Conditions, symptoms and treatments with who reported or confirmed them.',
    purposeTr: 'Durumlar, belirtiler ve tedaviler; kimin bildirdiği ya da doğruladığıyla.',
    plannedForge: 'Forge F009',
    principleEn: 'Self-reported is not a confirmed diagnosis.',
    principleTr: 'Öz bildirim, doğrulanmış tanı değildir.',
  ),
  Destination(
    id: DestinationId.preventive,
    en: 'Preventive',
    tr: 'Koruyucu',
    icon: Icons.shield_outlined,
    selectedIcon: Icons.shield,
    purposeEn: 'Vaccines and screenings from a guideline pack you choose for your country.',
    purposeTr: 'Ülken için seçtiğin kılavuz paketine göre aşılar ve taramalar.',
    plannedForge: 'Forge F009',
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
