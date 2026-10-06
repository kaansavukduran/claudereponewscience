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
  String get sourceRevision => _t('Source revision', 'Kaynak revizyonu');
  String get flutterVersion => _t('Flutter', 'Flutter');
  String get dartVersion => _t('Dart', 'Dart');
  String get recordSchema => _t('Record schema', 'Kayıt şeması');
  String get capabilities =>
      _t('Capabilities on this device', 'Bu cihazdaki yetenekler');
  // The clinical disclaimer comes first so a narrow or large-text banner
  // that ellipsizes never cuts it.
  String get devBanner => _t(
    'Not for clinical decisions · DEVELOPMENT BUILD · test use only',
    'Klinik karar için değil · GELİŞTİRME DERLEMESİ · yalnız test',
  );
  String get stagingBanner => _t(
    'Not for clinical decisions · STAGING BUILD · test use only',
    'Klinik karar için değil · STAGING DERLEMESİ · yalnız test',
  );
  String get todayIntro => _t(
    'Human OS is being built to keep every part of your health on one timeline. Today it records body weight by hand; each entry keeps where it came from.',
    'Human OS, sağlığının her parçasını tek bir zaman çizelgesinde tutmak için geliştiriliyor. Şu an kilo elle kaydediliyor; her kayıt nereden geldiğini saklar.',
  );
  String get checkInsAndMissions => _t(
    'Check-ins and daily missions: not built yet.',
    'Kontroller ve günlük görevler: henüz yapılmadı.',
  );
  String get yourData => _t('Your data', 'Verilerin');
  String get available => _t('Available', 'Kullanılabilir');
  String get notImplemented => _t('Not built yet', 'Henüz yapılmadı');
  String get unsupported => _t('Not on this platform', 'Bu platformda yok');
  String get notRequired => _t('Not required', 'Gerekmiyor');
  String get offInThisBuild => _t('Off in this build', 'Bu derlemede kapalı');
  String get plannedGroup => _t('Planned', 'Planlanan');

  // FORGE 002 — weight heartbeat
  String get weightTitle => _t('Body weight', 'Vücut ağırlığı');
  String get weightField => _t('Weight (kg)', 'Ağırlık (kg)');
  String get save => _t('Save', 'Kaydet');
  String get saved => _t('Saved', 'Kaydedildi');
  String get noWeightYet => _t(
    'No weight recorded yet. An empty field is never stored as 0.',
    'Henüz kilo kaydı yok. Boş alan asla 0 olarak saklanmaz.',
  );
  String get latest => _t('Latest', 'Son');
  String get history => _t('History', 'Geçmiş');
  String get manualEntry => _t('Manual entry', 'Elle giriş');
  String get observed => _t('Observed', 'Gözlendi');
  String get enteredAs => _t('entered as', 'girilen');
  String inputError(String code) => switch (code) {
    'EMPTY' => _t(
      'Enter a value. Empty is not saved as 0.',
      'Bir değer gir. Boş değer 0 olarak kaydedilmez.',
    ),
    'NOT_A_NUMBER' => _t(
      'Use digits, e.g. 78.4 or 78,4.',
      'Rakam kullan, ör. 78.4 ya da 78,4.',
    ),
    'OUT_OF_RANGE' => _t(
      'Weight must be between 0 and 700 kg.',
      'Ağırlık 0 ile 700 kg arasında olmalı.',
    ),
    _ => _t('This value could not be saved.', 'Bu değer kaydedilemedi.'),
  };
  String storageLabel(String durability, bool encrypted) {
    final enc = encrypted
        ? ''
        : _t(' · not encrypted (development)', ' · şifresiz (geliştirme)');
    return switch (durability) {
      'localFile' => _t('Saved on this device', 'Bu cihazda saklanıyor') + enc,
      'browserStorage' =>
        _t(
              'Saved in this browser (it may be cleared)',
              'Bu tarayıcıda saklanıyor (silinebilir)',
            ) +
            enc,
      _ => _t(
        'Not saved: kept only until the app closes',
        'Kaydedilmiyor: yalnız uygulama kapanana kadar',
      ),
    };
  }
}
