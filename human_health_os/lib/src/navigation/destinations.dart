/// The ten first-level destinations (v0.27 doc 209). Each one names the
/// FORGE that builds it, so an unbuilt area says so instead of faking content.
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
  });

  final DestinationId id;
  final String en;
  final String tr;
  final IconData icon;
  final IconData selectedIcon;
  final String purposeEn;
  final String purposeTr;

  /// FORGE that delivers the area's stated purpose; null only when that
  /// purpose is fully built.
  final String? plannedForge;

  /// One invariant this area must respect, shown so the empty state still teaches.
  final String principleEn;
  final String principleTr;

  String label(AppLang lang) => lang == AppLang.tr ? tr : en;
  String purpose(AppLang lang) => lang == AppLang.tr ? purposeTr : purposeEn;
  String principle(AppLang lang) =>
      lang == AppLang.tr ? principleTr : principleEn;
}

const List<Destination> destinations = [
  Destination(
    id: DestinationId.today,
    en: 'Today',
    tr: 'Bugün',
    icon: Icons.wb_sunny_outlined,
    selectedIcon: Icons.wb_sunny,
    purposeEn: 'Your day at a glance: check-ins, missions and what changed.',
    purposeTr: 'Günün bir bakışta: kontroller, görevler ve neyin değiştiği.',
    plannedForge: 'FORGE 020',
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
    plannedForge: 'FORGE 006',
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
    purposeEn: 'Lab results with units, method, specimen and the report’s own reference interval.',
    purposeTr: 'Birim, yöntem, numune ve raporun kendi referans aralığıyla lab sonuçları.',
    plannedForge: 'FORGE 008',
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
    plannedForge: 'FORGE 013',
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
    plannedForge: 'FORGE 012',
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
    plannedForge: 'FORGE 011',
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
    plannedForge: 'FORGE 014',
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
    plannedForge: 'FORGE 016',
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
    plannedForge: 'FORGE 018',
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
    plannedForge: 'FORGE 021',
    principleEn: 'Reading a lesson is not the same as a health improvement.',
    principleTr: 'Bir dersi okumak sağlıkta iyileşme ile aynı şey değildir.',
  ),
];

Destination destinationById(DestinationId id) =>
    destinations.firstWhere((d) => d.id == id);
