/// Minimal EN/TR string table for the shell. Moves to ARB files with
/// `flutter gen-l10n` once screens carry real content (canonical data never
/// changes with locale; only labels do).
library;

import 'package:flutter/widgets.dart';

import '../domain/ports/health_repository.dart';
import '../domain/ports/storage_status.dart';
import '../domain/records/health_record.dart';

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
  String get savingOff => _t('Saving off', 'Kayıt kapalı');
  String get startupFailedTitle =>
      _t('Human OS could not start', 'Human OS başlatılamadı');
  String get startupFailedBody => _t(
    'Nothing was changed on disk. Close and reopen the app; if this keeps happening, keep the message below for a bug report.',
    'Diskte hiçbir şey değiştirilmedi. Uygulamayı kapatıp yeniden aç; tekrar olursa aşağıdaki mesajı hata bildirimi için sakla.',
  );
  String get plannedGroup => _t('Planned', 'Planlanan');

  // Persistence heartbeat (F002): body weight
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
    'VAULT_READ_ONLY' => _t(
      'Not saved: your saved data is open read-only (see the note above).',
      'Kaydedilmedi: kayıtlı verilerin salt okunur açık (yukarıdaki nota bak).',
    ),
    'SAVE_FAILED' => _t(
      'Not saved: storage failed. Nothing was changed; try again.',
      'Kaydedilmedi: depolama hata verdi. Hiçbir şey değişmedi; tekrar dene.',
    ),
    _ => _t('This value could not be saved.', 'Bu değer kaydedilemedi.'),
  };

  /// Why entries are or are not saved; null when there is nothing to say.
  String? storageNotice(
    StorageReason? reason, {
    String? detail,
    required String profile,
  }) => switch (reason) {
    null || StorageReason.saving => null,
    StorageReason.profilePolicy => _t(
      'This $profile build does not save unencrypted health data. Saving starts with the encrypted vault (Forge F006); entries last until the app closes.',
      'Bu $profile derlemesi şifresiz sağlık verisi kaydetmez. Kayıt, şifreli kasa ile başlar (Forge F006); girişler uygulama kapanana kadar kalır.',
    ),
    StorageReason.portablePolicy => _t(
      'Portable mode saves only to an encrypted vault, which arrives in Forge F006. Nothing is written next to the app; entries last until it closes.',
      'Taşınabilir mod yalnız şifreli kasaya kaydeder; bu Forge F006 ile gelir. Uygulamanın yanına hiçbir şey yazılmaz; girişler uygulama kapanana kadar kalır.',
    ),
    StorageReason.platformNotBuilt => _t(
      'Saving on this platform is not built yet. Entries are kept only until the app closes.',
      'Bu platformda kayıt henüz yapılmadı. Girişler yalnız uygulama kapanana kadar tutulur.',
    ),
    StorageReason.dataDirInvalid => _t(
      '${detail ?? 'The data folder setting'} must be an absolute folder path. Nothing is saved until it is fixed; entries last until the app closes.',
      '${detail ?? 'Veri klasörü ayarı'} mutlak bir klasör yolu olmalı. Düzeltilene kadar hiçbir şey kaydedilmez; girişler uygulama kapanana kadar kalır.',
    ),
    StorageReason.browserBlocked => _t(
      'This browser blocks local storage. Entries are kept only until the page closes.',
      'Bu tarayıcı yerel depolamayı engelliyor. Girişler yalnız sayfa kapanana kadar tutulur.',
    ),
    StorageReason.vaultUnreadable
        when detail == 'VAULT_NEWER' || detail == 'RECORD_SCHEMA_NEWER' =>
      _t(
        'Your saved data was written by a newer version of Human OS, so this version does not open it. Nothing was changed on disk; update the app to see it. New entries are kept in memory only.',
        'Kayıtlı verilerin Human OS\'un daha yeni bir sürümüyle yazılmış; bu sürüm onları açmaz. Diskte hiçbir şey değiştirilmedi; görmek için uygulamayı güncelle. Yeni girişler yalnız bellekte tutulur.',
      ),
    StorageReason.vaultUnreadable => _t(
      'Your saved data could not be opened (${detail ?? 'unknown error'}). Nothing was changed on disk. New entries are kept in memory only until this is fixed.',
      'Kayıtlı verilerin açılamadı (${detail ?? 'bilinmeyen hata'}). Diskte hiçbir şey değiştirilmedi. Bu düzelene kadar yeni girişler yalnız bellekte tutulur.',
    ),
    StorageReason.vaultReadOnly => _t(
      'Your saved data uses an older format. It is shown as it is, but new entries are not saved until an upgrade with a backup exists (Forge F005). The file was not changed.',
      'Kayıtlı verilerin eski bir biçimde. Olduğu gibi gösteriliyor, ama yedekli bir yükseltme gelene kadar (Forge F005) yeni girişler kaydedilmez. Dosya değiştirilmedi.',
    ),
  };

  String storageNote(StorageNote n) => switch (n.kind) {
    StorageNoteKind.movedLegacyFolder => _t(
      'Your development data moved to the new folder ${n.detail}.',
      'Geliştirme verilerin yeni klasöre taşındı: ${n.detail}.',
    ),
    StorageNoteKind.legacyFolderLeft => _t(
      'An older data folder still exists at ${n.detail}. It was left untouched; the app uses the new folder.',
      'Eski bir veri klasörü hâlâ ${n.detail} konumunda. Ona dokunulmadı; uygulama yeni klasörü kullanıyor.',
    ),
    StorageNoteKind.legacyFolderInUse => _t(
      'Your data stays in ${n.detail} because it could not be moved to the new folder name.',
      'Verilerin yeni klasör adına taşınamadığı için ${n.detail} konumunda kalıyor.',
    ),
  };

  String loadWarning(LoadWarning w) => switch (w.kind) {
    LoadWarningKind.lastEntryIncomplete => _t(
      'The last saved entry was incomplete (probably an interrupted save) and was skipped. Earlier entries are intact.',
      'Son kaydedilen giriş yarım kalmış (muhtemelen kayıt kesildi) ve atlandı. Önceki girişler sağlam.',
    ),
    LoadWarningKind.entryUnreadable => _t(
      'Saved entry ${w.line} could not be read and was skipped. The file was not changed.',
      'Kayıtlı giriş ${w.line} okunamadı ve atlandı. Dosya değiştirilmedi.',
    ),
    LoadWarningKind.entryInvalid => _t(
      'Saved entry ${w.line} breaks a record rule (${w.code}) and was skipped. The file was not changed.',
      'Kayıtlı giriş ${w.line} bir kayıt kuralını çiğniyor (${w.code}) ve atlandı. Dosya değiştirilmedi.',
    ),
  };

  /// What kind of truth a record is. Never collapsed (planned ≠ completed).
  String recordState(RecordState v) => switch (v) {
    RecordState.observed => _t('Observed', 'Gözlendi'),
    RecordState.reported => _t('Reported', 'Bildirildi'),
    RecordState.planned => _t('Planned', 'Planlandı'),
    RecordState.completed => _t('Completed', 'Tamamlandı'),
    RecordState.derived => _t('Derived', 'Türetildi'),
    RecordState.modelled => _t('Model estimate', 'Model tahmini'),
    RecordState.assumed => _t('Assumed', 'Varsayıldı'),
    RecordState.unknown => _t('State unknown', 'Durum bilinmiyor'),
  };

  String provenanceKind(ProvenanceKind v) => switch (v) {
    ProvenanceKind.manual => _t('Manual entry', 'Elle giriş'),
    ProvenanceKind.device => _t('Device', 'Cihaz'),
    ProvenanceKind.provider => _t('Care provider', 'Sağlık kurumu'),
    ProvenanceKind.document => _t('Document', 'Belge'),
    ProvenanceKind.api => _t('Connected service', 'Bağlı servis'),
    ProvenanceKind.derived => _t('Derived', 'Türetildi'),
    ProvenanceKind.modelled => _t('Model', 'Model'),
    ProvenanceKind.imported => _t('Imported', 'İçe aktarıldı'),
    ProvenanceKind.unknown => _t('Source unknown', 'Kaynak bilinmiyor'),
  };

  /// A value that does not exist is named, never shown as a number.
  String valueStatus(ValueStatus v) => switch (v) {
    ValueStatus.present => _t('Value', 'Değer'),
    ValueStatus.notReported => _t('Not reported', 'Bildirilmedi'),
    ValueStatus.notMeasured => _t('Not measured', 'Ölçülmedi'),
    ValueStatus.notApplicable => _t('Not applicable', 'Uygulanamaz'),
    ValueStatus.unknown => _t('Unknown', 'Bilinmiyor'),
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
