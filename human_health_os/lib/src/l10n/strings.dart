/// Minimal EN/TR string table for the shell. Moves to ARB files with
/// `flutter gen-l10n` once screens carry real content (canonical data never
/// changes with locale; only labels do).
library;

import 'package:flutter/widgets.dart';

enum AppLang { en, tr }

AppLang langOf(BuildContext context) {
  final code = Localizations.maybeLocaleOf(context)?.languageCode;
  return code == 'tr' ? AppLang.tr : AppLang.en;
}

class S {
  const S(this.lang);

  final AppLang lang;

  static S of(BuildContext context) => S(langOf(context));

  String _t(String en, String tr) => lang == AppLang.tr ? tr : en;

  String get appTitle => 'Human OS';
  String get more => _t('More', 'Daha fazla');
  String get notBuiltYet => _t('Not built yet', 'Henüz yapılmadı');
  String plannedIn(String forge) =>
      _t('Planned in $forge', '$forge içinde planlandı');
  String get noRecordsYet => _t('No records yet', 'Henüz kayıt yok');
  String get thisBuild => _t('This build', 'Bu derleme');
  String get profile => _t('Build profile', 'Derleme profili');
  String get version => _t('Version', 'Sürüm');
  String get platform => _t('Platform', 'Platform');
  String get capabilities =>
      _t('Capabilities on this device', 'Bu cihazdaki yetenekler');
  String get devBanner => _t(
    'DEVELOPMENT BUILD · test use only · not for clinical decisions',
    'GELİŞTİRME DERLEMESİ · yalnız test · klinik karar için değil',
  );
  String get stagingBanner =>
      _t('STAGING BUILD · test use only', 'STAGING DERLEMESİ · yalnız test');
  String get todayIntro => _t(
    'Human OS keeps every part of your health on one timeline: labs, vitals, sleep, food, medicines, conditions and more. Each result shows where it came from and how it was calculated.',
    'Human OS sağlığının her parçasını tek bir zaman çizelgesinde tutar: lab, vital bulgular, uyku, beslenme, ilaçlar, hastalıklar ve daha fazlası. Her sonuç nereden geldiğini ve nasıl hesaplandığını gösterir.',
  );
  String get yourData => _t('Your data', 'Verilerin');
  String get yourDataEmpty => _t(
    'Nothing is stored yet. Saving your first record (a weight, on this device) arrives in FORGE 002.',
    'Henüz hiçbir şey saklanmıyor. İlk kaydı (bu cihazda bir kilo ölçümü) kaydetmek FORGE 002 ile geliyor.',
  );
  String get available => _t('Available', 'Kullanılabilir');
  String get notImplemented => _t('Not built yet', 'Henüz yapılmadı');
  String get unsupported => _t('Not on this platform', 'Bu platformda yok');
  String get notRequired => _t('Not required', 'Gerekmiyor');
}
