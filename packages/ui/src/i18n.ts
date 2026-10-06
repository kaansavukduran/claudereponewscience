// Shared UI strings (EN/TR). Canonical data never changes with locale; only labels do.

export type Lang = 'en' | 'tr';

const STRINGS = {
  appSite: { en: 'Human Health OS · Interactive Lab', tr: 'Human Health OS · İnteraktif Laboratuvar' },
  appClient: { en: 'Human Health OS', tr: 'Human Health OS' },
  synthetic: { en: 'SYNTHETIC DEMO', tr: 'SENTETİK DEMO' },
  syntheticBanner: { en: 'All people, labs and rules here are synthetic. Nothing is a real person or a clinical recommendation.', tr: 'Buradaki tüm kişiler, lab değerleri ve kurallar sentetiktir. Hiçbiri gerçek bir kişi ya da klinik öneri değildir.' },
  resetDemo: { en: 'Reset demo to defaults', tr: 'Demoyu varsayılana döndür' },
  clearLocal: { en: 'Clear local demo data', tr: 'Yerel demo verisini temizle' },
  tour: { en: 'Tour', tr: 'Tur' },
  theme: { en: 'Theme', tr: 'Tema' },
  themeAuto: { en: 'Auto', tr: 'Otomatik' },
  themeLight: { en: 'Light', tr: 'Açık' },
  themeDark: { en: 'Dark', tr: 'Koyu' },
  themeClarity: { en: 'High clarity', tr: 'Yüksek netlik' },
  howCalculated: { en: 'How calculated?', tr: 'Nasıl hesaplandı?' },
  resultClass: { en: 'Result class', tr: 'Sonuç sınıfı' },
  model: { en: 'Model / rule', tr: 'Model / kural' },
  version: { en: 'Version', tr: 'Sürüm' },
  inputs: { en: 'Inputs', tr: 'Girdiler' },
  missingInputs: { en: 'Missing inputs', tr: 'Eksik girdiler' },
  coverage: { en: 'Coverage', tr: 'Kapsam' },
  confidence: { en: 'Confidence', tr: 'Güven' },
  limitations: { en: 'Limitations', tr: 'Sınırlamalar' },
  none: { en: 'none', tr: 'yok' },
  unknown: { en: 'Unknown', tr: 'Bilinmiyor' },
  missingValue: { en: 'Missing — not zero', tr: 'Eksik — sıfır değil' },
  notEligible: { en: 'Not eligible', tr: 'Uygun değil' },
  unavailable: { en: 'Unavailable', tr: 'Kullanılamıyor' },
  invalid: { en: 'Cannot calculate', tr: 'Hesaplanamaz' },
  insufficient: { en: 'Insufficient data', tr: 'Yetersiz veri' },
  hypothetical: { en: 'HYPOTHETICAL SCENARIO', tr: 'VARSAYIMSAL SENARYO' },
  appDefined: { en: 'App-defined score · not clinical risk', tr: 'Uygulama skoru · klinik risk değil' },
  protection: { en: 'Protection / Resilience', tr: 'Koruma / Dayanıklılık' },
  burden: { en: 'Risk / Burden', tr: 'Risk / Yük' },
  function: { en: 'Function / Capacity', tr: 'İşlev / Kapasite' },
  trajectory: { en: 'Trajectory', tr: 'Gidişat' },
  coverageConfidence: { en: 'Coverage / Confidence', tr: 'Kapsam / Güven' },
  balance: { en: 'Balance index', tr: 'Denge indeksi' },
  derived: { en: 'Derived measurements', tr: 'Türetilmiş ölçümler' },
  validated: { en: 'Validated & reference models', tr: 'Doğrulanmış ve referans modeller' },
  lifespanState: { en: 'Lifespan projection state', tr: 'Yaşam süresi projeksiyon durumu' },
} as const;

export type StringKey = keyof typeof STRINGS;

export function tr(lang: Lang, key: StringKey): string {
  return STRINGS[key][lang];
}

export const RESULT_CLASS_LABEL: Record<string, Record<Lang, string>> = {
  POPULATION_BASELINE: { en: 'Population baseline', tr: 'Popülasyon bazalı' },
  VALIDATED_RISK: { en: 'Validated clinical model', tr: 'Doğrulanmış klinik model' },
  APP_COMPOSITE: { en: 'App-defined score', tr: 'Uygulama skoru' },
  COVERAGE: { en: 'Data coverage', tr: 'Veri kapsamı' },
  ADHERENCE: { en: 'Adherence', tr: 'Uyum' },
  DERIVED_MEASUREMENT: { en: 'Derived measurement', tr: 'Türetilmiş ölçüm' },
  EXPERIMENTAL: { en: 'Research only', tr: 'Yalnız araştırma' },
  OBSERVED_INPUT: { en: 'Observed input', tr: 'Gözlenen girdi' },
};
