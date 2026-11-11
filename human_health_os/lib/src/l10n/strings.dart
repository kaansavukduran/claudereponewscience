/// Minimal EN/TR string table for the shell. Moves to ARB files with
/// `flutter gen-l10n` once screens carry real content (canonical data never
/// changes with locale; only labels do).
library;

import 'package:flutter/widgets.dart';

import '../domain/ports/health_repository.dart';
import '../domain/ports/storage_status.dart';
import '../domain/records/health_record.dart';
import '../app/appearance_scope.dart';
import '../domain/settings/appearance.dart';
import '../domain/units/display_units.dart';

enum AppLang { en, tr }

AppLang langOf(BuildContext context) {
  final code = Localizations.maybeLocaleOf(context)?.languageCode;
  return code == 'tr' ? AppLang.tr : AppLang.en;
}

class S {
  const S(this.lang, {this.units = UnitSystem.metric});

  final AppLang lang;

  /// Display units chosen in Settings (values are shown as typed; US units
  /// add a converted value beside them).
  final UnitSystem units;

  static S of(BuildContext context) => S(
    langOf(context),
    units: AppearanceScope.maybeOf(context)?.value.units ?? UnitSystem.metric,
  );

  /// ", about 159.6 lb" for a screen reader when US units are chosen.
  String convertedSpoken(double value, String? unit) {
    final c = convertedFor(value, unit, units);
    return c == null ? '' : ', ${_t('about', 'yaklaşık')} ${c.substring(2)}';
  }

  /// " (≈ 159.6 lb)" beside a typed value when US units are chosen.
  String converted(double value, String? unit) {
    final c = convertedFor(value, unit, units);
    return c == null ? '' : ' ($c)';
  }

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
    'Human OS is being built to keep every part of your health on one timeline. Today it records body weight, blood pressure, resting heart rate and waist circumference by hand; each entry keeps where it came from.',
    'Human OS, sağlığının her parçasını tek bir zaman çizelgesinde tutmak için geliştiriliyor. Şu an kilo, tansiyon, dinlenme nabzı ve bel çevresi elle kaydediliyor; her kayıt nereden geldiğini saklar.',
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
  // Areas outside the primary navigation: some built, some still planned
  // (each planned one says so on its own screen).
  String get plannedGroup => _t('More areas', 'Diğer alanlar');

  // Persistence heartbeat (F002): body weight
  String get weightTitle => _t('Body weight', 'Vücut ağırlığı');
  String get weightField => _t('Weight (kg)', 'Ağırlık (kg)');
  String get save => _t('Save', 'Kaydet');
  String get saved => _t('Saved', 'Kaydedildi');
  String get noWeightYet =>
      _t('No weight recorded yet.', 'Henüz kilo kaydı yok.');
  String get latest => _t('Latest', 'Son');
  String get history => _t('History', 'Geçmiş');
  String get enteredAs => _t('entered as', 'girilen');
  String inputError(String code) => switch (code) {
    'FUTURE_TIME' => _t('This date is in the future.', 'Bu tarih gelecekte.'),
    'FOOD_NUTRIENT_NOT_A_NUMBER' => _t(
      'Type each label value as a number, e.g. 12 or 12,5.',
      'Her etiket değerini sayı olarak yaz, ör. 12 ya da 12,5.',
    ),
    'NOT_A_WHOLE_NUMBER' => _t(
      'Type a whole number, e.g. 30.',
      'Tam sayı yaz, ör. 30.',
    ),
    'ACTIVITY_MINUTES_RANGE' => _t(
      'Minutes go from 1 to 1440 (a day).',
      'Dakika 1 ile 1440 (bir gün) arasında olmalı.',
    ),
    'ACTIVITY_STEPS_RANGE' => _t(
      'Steps go from 1 to 200000.',
      'Adım 1 ile 200000 arasında olmalı.',
    ),
    'FOOD_LABEL_BASIS_REQUIRED' => _t(
      'Say what the label values are per (for example per 100 g).',
      'Etiket değerlerinin neye göre olduğunu seç (ör. 100 g için).',
    ),
    'CHECKIN_EMPTY' => _t(
      'Pick at least one of energy, mood or stress.',
      'Enerji, ruh hâli ya da stresten en az birini seç.',
    ),
    'SLEEP_WAKE_NOT_AFTER_BED' => _t(
      'The waking time has to come after the going-to-bed time.',
      'Uyanma saati yatma saatinden sonra olmalı.',
    ),
    'SLEEP_TOO_LONG' => _t(
      'From bed to waking has to be less than 24 hours; add a date to the going-to-bed time if it was another day.',
      'Yatmadan uyanmaya 24 saatten az olmalı; başka bir gündeyse yatma saatine tarih ekle.',
    ),
    'NO_CHANGE' => _t('Nothing to change.', 'Değişecek bir şey yok.'),
    'TEXT_TOO_LONG' => _t(
      'This text is too long (at most 300 characters).',
      'Bu metin çok uzun (en çok 300 karakter).',
    ),
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
    'AMBIGUOUS_SEPARATOR' => _t(
      'Is that a decimal point or a thousands separator? Write thousands without a separator (150000) and decimals with one digit group, e.g. 7.5.',
      'Bu ondalık ayırıcı mı, binlik ayırıcı mı? Binlikleri ayırıcısız yaz (150000), ondalığı ör. 7,5 gibi yaz.',
    ),
    'LAB_ANALYTE_EMPTY' => _t(
      'Enter the test name as printed.',
      'Raporda yazan test adını gir.',
    ),
    'DATE_INVALID' => _t(
      'Use the date format YYYY-MM-DD, e.g. 2026-10-03.',
      'Tarihi YYYY-AA-GG biçiminde yaz, ör. 2026-10-03.',
    ),
    'TARGET_NOT_FOUND' => _t(
      'This entry no longer exists here.',
      'Bu giriş artık burada yok.',
    ),
    'TARGET_NOT_CURRENT' => _t(
      'Only the current version can be changed; reopen the timeline.',
      'Yalnız güncel sürüm değiştirilebilir; zaman çizelgesini yeniden aç.',
    ),
    'TARGET_WRONG_KIND' => _t(
      'This entry is of another kind; correct it from its own row.',
      'Bu giriş başka bir türde; kendi satırından düzelt.',
    ),
    // Measurements (F007): 0 is never stored for a value not known.
    'NOT_POSITIVE' || 'VALUE_NOT_POSITIVE' => _t(
      'Enter a number greater than 0. Nothing was saved.',
      'Sıfırdan büyük bir sayı gir. Hiçbir şey kaydedilmedi.',
    ),
    'BP_ORDER' => _t(
      'The upper number (systolic) must be larger than the lower number (diastolic). Were the two swapped?',
      'Büyük tansiyon (sistolik) küçük tansiyondan (diyastolik) büyük olmalı. İkisi yer mi değiştirdi?',
    ),
    // Time entry (F007 slice 2): what is wrong with the entry, never with
    // the person or the body.
    'OUT_OF_DEFINITION' => _t(
      'A percentage cannot be above 100. Nothing was saved.',
      'Yüzde 100\'ü geçemez. Hiçbir şey kaydedilmedi.',
    ),
    'TIME_FORMAT' => _t(
      'Write the time on a 24-hour clock as YYYY-MM-DD HH:MM or HH:MM, e.g. 2026-11-07 07:30 or 07:30.',
      'Zamanı 24 saatlik düzende YYYY-AA-GG SS:DD ya da SS:DD yaz, ör. 2026-11-07 07:30 ya da 07:30.',
    ),
    'TIME_TOO_OLD' => _t(
      'Enter a date from the year 1900 on.',
      '1900 yılından sonraki bir tarih gir.',
    ),
    'TIME_DOES_NOT_EXIST' => _t(
      'That clock time did not exist (the clock moved forward then). Type another time.',
      'Bu saat yoktu (saat o gün ileri alındı). Başka bir saat yaz.',
    ),
    'TIME_AMBIGUOUS' => _t(
      'That clock time happened twice (the clock moved back). Type the full date and time, then the offset of the hour you mean: YYYY-MM-DD HH:MM +HH:MM.',
      'Bu saat iki kez yaşandı (saat geri alındı). Tam tarih ve saati, ardından kastettiğin saatin farkını yaz: YYYY-AA-GG SS:DD +SS:DD.',
    ),
    'CONTEXT_TOO_LONG' => _t(
      'Keep the note to at most 500 characters.',
      'Notu en fazla 500 karakterle sınırla.',
    ),
    'CHECKPOINT_FAILED' => _t(
      'Not saved: this entry changes the record format, and a backup of your earlier data could not be made first. Nothing was written; check the free space and try again.',
      'Kaydedilmedi: bu giriş kayıt biçimini değiştiriyor ve önceki verilerinin yedeği önce alınamadı. Hiçbir şey yazılmadı; boş alanı kontrol edip tekrar dene.',
    ),
    // Record rules the form cannot break; shown with their code if a bug
    // ever lets one through.
    'VALUE_NOT_FINITE' ||
    'UNIT_NOT_SUPPORTED' ||
    'KIND_NEEDS_NEWER_SCHEMA' ||
    'FIELD_NEEDS_NEWER_SCHEMA' ||
    'BP_HAS_NO_QUANTITY' ||
    'DETAILS_MISMATCH' ||
    'CONTEXT_NOT_SUPPORTED' ||
    'CONTEXT_EMPTY' => _t(
      'Not saved: this entry breaks a record rule ($code). Nothing was written.',
      'Kaydedilmedi: bu giriş bir kayıt kuralını çiğniyor ($code). Hiçbir şey yazılmadı.',
    ),
    // Also after a restore that failed half-way: no promise of restored data.
    'RESTART_REQUIRED' => _t(
      'Not saved: a restore ran in this session. Restart Human OS first.',
      'Kaydedilmedi: bu oturumda bir geri yükleme çalıştı. Önce Human OS\'u yeniden başlat.',
    ),
    'VAULT_READ_ONLY' => _t(
      'Not saved: your saved data is open read-only (see the note above).',
      'Kaydedilmedi: kayıtlı verilerin salt okunur açık (yukarıdaki nota bak).',
    ),
    'VAULT_MISSING' => _t(
      'Not saved: the data file is no longer in its folder. Nothing was written; restart Human OS.',
      'Kaydedilmedi: veri dosyası artık klasöründe değil. Hiçbir şey yazılmadı; Human OS\'u yeniden başlat.',
    ),
    'VAULT_CHANGED' => _t(
      'Not saved: the data file now holds another vault (replaced by another window or program). Nothing was written; restart Human OS.',
      'Kaydedilmedi: veri dosyasında artık başka bir kasa var (başka bir pencere ya da program değiştirmiş). Hiçbir şey yazılmadı; Human OS\'u yeniden başlat.',
    ),
    'VAULT_WRITE_REFUSED' => _t(
      'Not saved: the data file could not be opened for writing (another program may be using it, or its permissions changed). Nothing was written; try again.',
      'Kaydedilmedi: veri dosyası yazmak için açılamadı (başka bir program kullanıyor olabilir ya da izinleri değişmiş olabilir). Hiçbir şey yazılmadı; tekrar dene.',
    ),
    // The write may have reached the file before the failure (e.g. a flush
    // that failed afterwards), so the text promises nothing either way.
    'SAVE_FAILED' => _t(
      'Storage failed: this entry may not be saved. Try again; if it later shows up twice, mark one copy entered in error.',
      'Depolama hata verdi: bu giriş kaydedilmemiş olabilir. Tekrar dene; daha sonra iki kez görünürse birini yanlışlıkla girildi olarak işaretle.',
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
      'This $profile browser build does not save health data: it never stores them unencrypted, and encrypted browser storage is not built yet. Entries last until the page closes.',
      'Bu $profile tarayıcı derlemesi sağlık verisi kaydetmez: onları asla şifresiz saklamaz ve şifreli tarayıcı depolaması henüz yapılmadı. Girişler sayfa kapanana kadar kalır.',
    ),
    StorageReason.sessionOnly when detail == 'LOCKED_VAULT_KEPT' => _t(
      'Your encrypted vault stays locked and untouched. This session is kept in memory only; entries last until the app closes.',
      'Şifreli kasan kilitli ve dokunulmamış olarak kalıyor. Bu oturum yalnız bellekte tutuluyor; girişler uygulama kapanana kadar kalır.',
    ),
    StorageReason.sessionOnly => _t(
      'You chose to keep this session in memory only. Nothing is saved; entries last until the app closes.',
      'Bu oturumu yalnız bellekte tutmayı seçtin. Hiçbir şey kaydedilmez; girişler uygulama kapanana kadar kalır.',
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
        when detail == 'VAULT_NEWER' ||
            detail == 'RECORD_SCHEMA_NEWER' ||
            detail == 'ENVELOPE_NEWER' =>
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
    LoadWarningKind.entryMissing => _t(
      'Entry ${w.line} is missing from the encrypted vault: it was removed from the file, or a save that failed never reached it. Nothing replaces it; any other problem found is listed here.',
      'Giriş ${w.line} şifreli kasada yok: dosyadan çıkarılmış ya da başarısız bir kayıt dosyaya hiç ulaşmamış. Yerine hiçbir şey konmadı; bulunan başka sorunlar da burada listelenir.',
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

  // Timeline (F003)
  String get showHidden => _t(
    'Show deleted and withdrawn',
    'Silinenleri ve geri çekilenleri göster',
  );
  String get versionsDisagree => _t('Versions disagree', 'Sürümler çelişiyor');
  String get versions => _t('Versions', 'Sürümler');
  String get enteredOn => _t('entered', 'girildi');
  String get cancel => _t('Cancel', 'Vazgeç');

  /// The device capability texts (written in English in the pure core) in
  /// the chosen language; an unknown text is shown as it is.
  String capText(String en) => lang == AppLang.tr ? (_capTr[en] ?? en) : en;
  static const Map<String, String> _capTr = {
    'Local health records': 'Yerel sağlık kayıtları',
    'Key protection': 'Anahtar koruması',
    'Health platform': 'Sağlık platformu',
    'Network': 'Ağ',
    'Android adapter planned (Forge F013).':
        'Android bağlantısı planlandı (Forge F013).',
    'iOS adapter planned (Forge F013).':
        'iOS bağlantısı planlandı (Forge F013).',
    'No HealthKit or Health Connect on this platform. Typing entries works now; importing from other health apps is not built.': 'Bu platformda HealthKit ya da Health Connect yok. Elle giriş şimdi çalışıyor; başka sağlık uygulamalarından aktarma henüz yapılmadı.',
    'Browser: no system key store, and encrypted browser storage is not built yet.': 'Tarayıcı: sistem anahtar deposu yok ve şifreli tarayıcı depolaması henüz yapılmadı.',
    'Your passphrase protects the encrypted vault (staging, production and portable builds). The system key store is not used yet.': 'Parolan şifreli kasayı korur (test, üretim ve taşınabilir sürümler). Sistem anahtar deposu henüz kullanılmıyor.',
    'Not required. This build makes no network calls.':
        'Gerekmiyor. Bu sürüm hiçbir ağ isteği yapmaz.',
    'Saved in an encrypted vault on this device (Argon2id + ChaCha20-Poly1305). It opens only with your passphrase or recovery key.': 'Bu cihazda şifreli bir kasada saklanır (Argon2id + ChaCha20-Poly1305). Yalnız parolan ya da kurtarma anahtarınla açılır.',
    'Saved in a file on this device. Not encrypted (development build only).': 'Bu cihazda bir dosyada saklanır. Şifreli değil (yalnız geliştirme sürümü).',
    'Saved in this browser. The browser may clear it; not encrypted yet (development build).': 'Bu tarayıcıda saklanır. Tarayıcı silebilir; henüz şifreli değil (geliştirme sürümü).',
    'Not saved in this browser build: health data are never stored unencrypted, and encrypted browser storage is not built yet.': 'Bu tarayıcı sürümünde saklanmaz: sağlık verisi asla şifresiz saklanmaz ve şifreli tarayıcı depolaması henüz yapılmadı.',
    'Not saved in this session: you chose memory only. The encrypted vault, if any, is untouched.': 'Bu oturumda saklanmaz: yalnız belleği seçtin. Varsa şifreli kasaya dokunulmadı.',
    'Not saved: the data folder setting is not an absolute path.':
        'Saklanmaz: veri klasörü ayarı tam bir yol değil.',
    'Not saved: this browser blocks local storage.':
        'Saklanmaz: bu tarayıcı yerel depolamayı engelliyor.',
    'Not saved: the saved data could not be opened and was left untouched.':
        'Saklanmaz: kayıtlı veri açılamadı ve olduğu gibi bırakıldı.',
    'Saved data is shown read-only: its format needs an upgrade, which waits for backups (Forge F005).': 'Kayıtlı veri yalnız okunur gösterilir: biçimi yükseltme bekliyor, bu da yedekleri bekliyor (Forge F005).',
    'Not saved on this platform yet: entries last only until the app closes.': 'Bu platformda henüz saklanmaz: girişler yalnız uygulama kapanana kadar kalır.',
    'Not saved right now: entries last only until the app closes.':
        'Şu an saklanmaz: girişler yalnız uygulama kapanana kadar kalır.',
  };
  String get saveCorrection => _t('Save correction', 'Düzeltmeyi kaydet');

  String recordKind(RecordKind k) => switch (k) {
    RecordKind.bodyWeight => _t('Body weight', 'Vücut ağırlığı'),
    RecordKind.labResult => _t('Lab result', 'Lab sonucu'),
    RecordKind.waistCircumference => _t('Waist circumference', 'Bel çevresi'),
    RecordKind.restingHeartRate => _t('Resting heart rate', 'Dinlenme nabzı'),
    RecordKind.bloodPressure => _t('Blood pressure', 'Tansiyon'),
    RecordKind.height => _t('Height', 'Boy'),
    RecordKind.bodyTemperature => _t('Body temperature', 'Vücut sıcaklığı'),
    RecordKind.oxygenSaturation => _t(
      'Oxygen saturation (SpO2)',
      'Oksijen satürasyonu (SpO2)',
    ),
    RecordKind.respiratoryRate => _t('Respiratory rate', 'Solunum hızı'),
    RecordKind.medicationItem => _t(
      'Medicine or supplement',
      'İlaç ya da takviye',
    ),
    RecordKind.medicationPlan => _t('Plan', 'Plan'),
    RecordKind.medicationIntake => _t('Dose', 'Doz'),
    RecordKind.sleepNight => _t('Night', 'Gece'),
    RecordKind.feelingCheckIn => _t('How I feel', 'Nasıl hissediyorum'),
    RecordKind.foodEntry => _t('Food or drink', 'Yiyecek ya da içecek'),
    RecordKind.activityEntry => _t('Activity', 'Aktivite'),
    RecordKind.conditionEntry => _t(
      'Condition or symptom',
      'Durum ya da belirti',
    ),
    RecordKind.preventiveEntry => _t('Preventive item', 'Koruyucu kayıt'),
  };

  // Preventive (F009 slice 2): vaccinations, screenings and check-ups as the
  // person names them; planned is never done; no result is kept; nothing is
  // recommended, scheduled or reminded.
  String get prevTitle => _t(
    'Vaccinations, screenings, check-ups',
    'Aşılar, taramalar, kontroller',
  );
  String get prevIntro => _t(
    'As you name them: done, planned or not sure, with who it comes from. Human OS recommends nothing, keeps no schedule and sends no reminders. A screening is kept without its result.',
    'Senin adlandırdığın gibi: yapıldı, planlandı ya da emin değilim, kimden geldiğiyle birlikte. Human OS hiçbir şey önermez, takvim tutmaz ve hatırlatma göndermez. Bir tarama sonucu olmadan kaydedilir.',
  );
  String get prevAdd => _t('Add an item', 'Kayıt ekle');
  String get prevCorrectTitle => _t('Correct this entry', 'Bu kaydı düzelt');
  String get prevNone => _t('Nothing recorded yet.', 'Henüz kayıt yok.');
  String get prevName => _t(
    'What it is, in your words (e.g. tetanus vaccine)',
    'Ne olduğu, kendi sözlerinle (ör. tetanoz aşısı)',
  );
  String get prevWhen => _t(
    'When (optional, e.g. 2024-05 or last spring)',
    'Ne zaman (isteğe bağlı, ör. 2024-05 ya da geçen bahar)',
  );
  String get prevNatureLabel => _t('It is a', 'Bu bir');
  String prevNature(PreventiveType t) => switch (t) {
    PreventiveType.vaccination => _t('vaccination', 'aşı'),
    PreventiveType.screening => _t('screening', 'tarama'),
    PreventiveType.checkup => _t('check-up', 'kontrol'),
    PreventiveType.other => _t('other', 'diğer'),
  };
  String get prevStatusLabel => _t('Status', 'Durumu');
  String prevStatus(PreventiveStatus t) => switch (t) {
    PreventiveStatus.done => _t('done', 'yapıldı'),
    PreventiveStatus.planned => _t('planned', 'planlandı'),
    PreventiveStatus.unsure => _t('not sure', 'emin değilim'),
  };
  String get prevSourceLabel => _t('It comes from', 'Kaynağı');
  String prevLine(PreventiveEntryDetails d) => [
    d.name,
    prevNature(d.nature),
    '$prevStatusLabel: ${prevStatus(d.status)}',
    condSource(d.source),
    if (d.when != null) _t('when: ${d.when}', 'zaman: ${d.when}'),
  ].join(' · ');

  // Conditions (F009 slice 1): as the person names them, with who they come
  // from; a self-report is not a confirmed diagnosis; nothing is coded.
  String get condTitle =>
      _t('Conditions and symptoms', 'Durumlar ve belirtiler');
  String get condIntro => _t(
    'In your own words, with who it comes from. Human OS confirms nothing and suggests no diagnosis; what you record is your account.',
    'Kendi sözlerinle, kimden geldiğiyle birlikte. Human OS hiçbir şeyi doğrulamaz ve tanı önermez; kaydettiğin senin anlatımındır.',
  );
  String get condAdd =>
      _t('Add a condition or symptom', 'Durum ya da belirti ekle');
  String get condCorrectTitle => _t('Correct this entry', 'Bu kaydı düzelt');
  String get condNone => _t('Nothing recorded yet.', 'Henüz kayıt yok.');
  String get condName =>
      _t('What it is, in your words', 'Ne olduğu, kendi sözlerinle');
  String get condSince => _t(
    'Since when (optional, e.g. 2019)',
    'Ne zamandan beri (isteğe bağlı, ör. 2019)',
  );
  String get condNatureLabel => _t('It is a', 'Bu bir');
  String condNature(ConditionType t) => switch (t) {
    ConditionType.condition => _t('condition', 'durum'),
    ConditionType.symptom => _t('symptom', 'belirti'),
  };
  String get condTimeLabel => _t('It is', 'Durumu');
  String condTime(ConditionTime t) => switch (t) {
    ConditionTime.current => _t('current', 'sürüyor'),
    ConditionTime.past => _t('in the past', 'geçmişte kaldı'),
    ConditionTime.unsure => _t('not sure', 'emin değilim'),
  };
  String get condSourceLabel => _t('It comes from', 'Kaynağı');
  String condSource(ConditionSource c) => switch (c) {
    ConditionSource.selfReported => _t('my own account', 'kendi anlatımım'),
    ConditionSource.toldByClinician => _t(
      'what a clinician told me',
      'bir sağlık çalışanının bana söylediği',
    ),
    ConditionSource.fromDocument => _t(
      'a document I was given',
      'bana verilen bir belge',
    ),
  };
  String condLine(ConditionEntryDetails d) => [
    d.name,
    condNature(d.nature),
    '$condTimeLabel: ${condTime(d.time)}',
    condSource(d.source),
    if (d.since != null) _t('since ${d.since}', 'başlangıç: ${d.since}'),
  ].join(' · ');

  // Activity (F007 slice 6): typed by hand; minutes and steps as whole
  // numbers; nothing estimated (no calories), nothing summed with devices.
  String get actTitle => _t('Activity', 'Aktivite');
  String get actIntro => _t(
    'Walks, workouts and steps, typed by hand. Leave minutes or steps empty if you do not know them. Nothing is estimated or added up.',
    'Yürüyüş, antrenman ve adımlar, elle yazılır. Dakikayı ya da adımı bilmiyorsan boş bırak. Hiçbir şey tahmin edilmez ya da toplanmaz.',
  );
  String get actAdd => _t('Add an activity', 'Aktivite ekle');
  String get actCorrectTitle =>
      _t('Correct this activity', 'Bu aktiviteyi düzelt');
  String get actNone => _t('Nothing recorded yet.', 'Henüz kayıt yok.');
  String get actWhat => _t(
    'What it was (e.g. walk, cycling)',
    'Ne olduğu (ör. yürüyüş, bisiklet)',
  );
  String get actMinutes => _t('Minutes (optional)', 'Dakika (isteğe bağlı)');
  String get actSteps => _t('Steps (optional)', 'Adım (isteğe bağlı)');
  String actLine(ActivityEntryDetails d) => [
    d.what,
    if (d.minutes != null) _t('${d.minutes} min', '${d.minutes} dk'),
    if (d.steps != null) _t('${d.steps} steps', '${d.steps} adım'),
  ].join(' · ');

  // Nutrition (F007 slice 5): what was eaten as typed; nutrients only as
  // copied from a label; a nutrient not given is missing, never zero.
  String get foodTitle => _t('Nutrition', 'Beslenme');
  String get foodIntro => _t(
    'What you ate or drank, in your words. Copy nutrients from a label if you like; one left empty is not known, not zero. Nothing is added up.',
    'Ne yediğin ya da içtiğin, kendi sözlerinle. İstersen besin değerlerini etiketten kopyala; boş bırakılan bilinmiyor demektir, sıfır değil. Hiçbir şey toplanmaz.',
  );
  String get foodAdd => _t('Add food or drink', 'Yiyecek ya da içecek ekle');
  String get foodCorrectTitle => _t('Correct this entry', 'Bu kaydı düzelt');
  String get foodNone => _t('Nothing recorded yet.', 'Henüz kayıt yok.');
  String get foodWhat => _t('What it was', 'Ne olduğu');
  String get foodAmount => _t(
    'How much (optional, e.g. 1 bowl, 250 g)',
    'Ne kadar (isteğe bağlı, ör. 1 kase, 250 g)',
  );
  String get foodWhen => _t('When', 'Ne zaman');
  String get foodWhenHelp => _t(
    'HH:MM, or YYYY-MM-DD HH:MM; blank = now',
    'SS:DD ya da YYYY-AA-GG SS:DD; boş = şimdi',
  );
  String get foodLabelTitle =>
      _t('From the label (optional)', 'Etiketten (isteğe bağlı)');
  String get foodLabelHelp => _t(
    'Copy each number exactly as printed, in the unit shown here; leave a field empty if the label uses another unit. These are the label\'s numbers, not what you ate.',
    'Her sayıyı yazdığı gibi, burada gösterilen birimle kopyala; etiket başka bir birim kullanıyorsa alanı boş bırak. Bunlar etiketin sayıları, yediğin miktar değil.',
  );
  String get foodPer => _t('The label values are', 'Etiket değerleri');
  String foodBasis(LabelBasis b) => switch (b) {
    LabelBasis.per100g => _t('per 100 g', '100 g için'),
    LabelBasis.per100ml => _t('per 100 ml', '100 ml için'),
    LabelBasis.perServing => _t('per serving', 'porsiyon başına'),
    LabelBasis.perPack => _t('per pack', 'paket başına'),
    LabelBasis.notStated => _t(
      'not stated on the label',
      'etikette belirtilmemiş',
    ),
  };

  /// A nutrient's field label, with its unit (read aloud too).
  String foodNutrientField(PrintedNutrient n) =>
      '${foodNutrient(n)} (${printedNutrientUnit(n)})';
  String foodNutrient(PrintedNutrient n) => switch (n) {
    PrintedNutrient.energyKcal => _t('Energy', 'Enerji'),
    PrintedNutrient.energyKj => _t('Energy', 'Enerji'),
    PrintedNutrient.protein => _t('Protein', 'Protein'),
    PrintedNutrient.carbohydrate => _t('Carbohydrate', 'Karbonhidrat'),
    PrintedNutrient.fat => _t('Fat', 'Yağ'),
    PrintedNutrient.fibre => _t('Fibre', 'Lif'),
    PrintedNutrient.salt => _t('Salt', 'Tuz'),
  };
  String foodLine(FoodEntryDetails d) {
    final label = [
      for (final n in PrintedNutrient.values)
        if (d.nutrients[n] != null)
          '${foodNutrient(n)} ${d.nutrients[n]} ${printedNutrientUnit(n)}',
    ];
    return [
      d.what,
      ?d.amount,
      if (label.isNotEmpty)
        '${_t('label', 'etiket')} ${d.per == null ? '' : '(${foodBasis(d.per!)}) '}'
            '${label.join(', ')}',
    ].join(' · ');
  }

  // How I feel (F007 slice 4): the person's own levels, never a score or a
  // diagnosis; a level not picked is not given.
  String get feelTitle => _t('How you feel', 'Nasıl hissediyorsun');
  String get medsStopConfirmTitle =>
      _t('Stop this plan?', 'Bu plan bırakılsın mı?');
  String get medsStopConfirmBody => _t(
    'The plan is kept in history as stopped. Resume brings it back.',
    'Plan geçmişte bırakıldı olarak kalır. Sürdür ile geri gelir.',
  );
  String get feelCorrectTitle => _t('Correct this check-in', 'Bu kaydı düzelt');
  String get feelIntro => _t(
    'Your own words for now. Pick any of the three; nothing is scored.',
    'Şu an için kendi seçimin. Üçünden istediğini seç; hiçbir şey puanlanmaz.',
  );
  String get feelSave => _t('Save', 'Kaydet');
  String get feelOpen => _t('Record how you feel', 'Nasıl hissettiğini kaydet');
  String get feelNone => _t('Nothing recorded yet.', 'Henüz kayıt yok.');
  String get feelEnergy => _t('Energy', 'Enerji');
  String get feelMood => _t('Mood', 'Ruh hâli');
  String get feelStress => _t('Stress', 'Stres');

  /// The person's own word for each level: one set per question, so a level
  /// never reads as a lab-style high or low.
  String feelWord(FeelingQuestion q, SelfLevel l) => switch ((q, l)) {
    (FeelingQuestion.energy, SelfLevel.low) => _t('drained', 'bitkin'),
    (FeelingQuestion.energy, SelfLevel.medium) => _t('steady', 'dengeli'),
    (FeelingQuestion.energy, SelfLevel.high) => _t('lively', 'dinç'),
    (FeelingQuestion.mood, SelfLevel.low) => _t('down', 'keyifsiz'),
    (FeelingQuestion.mood, SelfLevel.medium) => _t('even', 'idare eder'),
    (FeelingQuestion.mood, SelfLevel.high) => _t('bright', 'keyifli'),
    (FeelingQuestion.stress, SelfLevel.low) => _t('calm', 'sakin'),
    (FeelingQuestion.stress, SelfLevel.medium) => _t('tense', 'gergin'),
    (FeelingQuestion.stress, SelfLevel.high) => _t('overwhelmed', 'çok gergin'),
  };
  String feelQuestion(FeelingQuestion q) => switch (q) {
    FeelingQuestion.energy => feelEnergy,
    FeelingQuestion.mood => feelMood,
    FeelingQuestion.stress => feelStress,
  };
  String feelLine(SelfLevel? energy, SelfLevel? mood, SelfLevel? stress) => [
    if (energy != null)
      '$feelEnergy: ${feelWord(FeelingQuestion.energy, energy)}',
    if (mood != null) '$feelMood: ${feelWord(FeelingQuestion.mood, mood)}',
    if (stress != null)
      '$feelStress: ${feelWord(FeelingQuestion.stress, stress)}',
  ].join(' · ');

  // Sleep (F007 slice 3): two typed times and, if given, how waking felt.
  // Time in bed is not time asleep; nothing is scored.
  String get sleepTitle => _t('Sleep', 'Uyku');
  String get sleepIntro => _t(
    'When you went to bed and when you woke up. The time between them is time in bed, not time asleep.',
    'Ne zaman yattığın ve ne zaman uyandığın. Aradaki süre yatakta geçen süredir, uykuda geçen süre değil.',
  );
  String get sleepAdd => _t('Add a night', 'Gece ekle');
  String get sleepCorrectTitle => _t('Correct this night', 'Bu geceyi düzelt');
  String get sleepNone =>
      _t('No nights recorded yet.', 'Henüz gece kaydı yok.');
  String get sleepBed => _t('Went to bed', 'Yattım');
  String get sleepBedHelp =>
      _t('HH:MM, or YYYY-MM-DD HH:MM', 'SS:DD ya da YYYY-AA-GG SS:DD');
  String get sleepWoke => _t('Woke up', 'Uyandım');
  String get sleepWokeHelp => _t(
    'HH:MM, or YYYY-MM-DD HH:MM; blank = now',
    'SS:DD ya da YYYY-AA-GG SS:DD; boş = şimdi',
  );
  String get sleepSaveFailed => _t(
    'The night could not be saved. Nothing was written.',
    'Gece kaydedilemedi. Hiçbir şey yazılmadı.',
  );
  String get sleepFeeling => _t(
    'How you felt on waking (optional)',
    'Uyanınca nasıl hissettin (isteğe bağlı)',
  );
  String sleepFeelingLabel(WakeFeeling f) => switch (f) {
    WakeFeeling.rested => _t('Rested', 'Dinlenmiş'),
    WakeFeeling.okay => _t('So-so', 'İdare eder'),
    WakeFeeling.tired => _t('Tired', 'Yorgun'),
  };
  String sleepSpan(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return _t('$h h $m min in bed', 'yatakta $h sa $m dk');
  }

  String sleepLine(String bed, String up, Duration span, WakeFeeling? f) => [
    _t('bed $bed, up $up', 'yatış $bed, uyanış $up'),
    sleepSpan(span),
    if (f != null) sleepFeelingLabel(f),
  ].join(' · ');

  // Medicines and supplements (F008): the person's own words, never a drug
  // database, a dose rule or an interaction check. A plan is not an intake.
  String get medsTitle =>
      _t('Medicines and supplements', 'İlaçlar ve takviyeler');
  String get medsIntro => _t(
    'Write down what you use, how it is meant to be taken, and each dose you actually took or skipped. A plan never counts as a dose taken. Human OS checks nothing about a product and gives no dose advice.',
    'Kullandıklarını, nasıl kullanılacağını ve gerçekten aldığın ya da atladığın her dozu yaz. Bir plan hiçbir zaman alınmış doz sayılmaz. Human OS bir ürün hakkında hiçbir şey denetlemez ve doz önerisi vermez.',
  );
  String get medsNone => _t(
    'Nothing added yet. Add a medicine or supplement to start.',
    'Henüz bir şey eklenmedi. Başlamak için bir ilaç ya da takviye ekle.',
  );
  String get medsAdd =>
      _t('Add a medicine or supplement', 'İlaç ya da takviye ekle');
  String get medsName => _t('Name (as on the pack)', 'Adı (kutudaki gibi)');
  String get medsCategory => _t('Kind', 'Türü');
  String medsCategoryLabel(MedicationCategory c) => switch (c) {
    MedicationCategory.medicine => _t('Medicine', 'İlaç'),
    MedicationCategory.supplement => _t('Supplement', 'Takviye'),
    MedicationCategory.other => _t('Other', 'Diğer'),
  };
  String get medsIngredients =>
      _t('Active ingredients (optional)', 'Etken maddeler (isteğe bağlı)');
  String get medsStrength => _t(
    'Strength as printed (optional, e.g. 500 mg)',
    'Kutuda yazan güç (isteğe bağlı, ör. 500 mg)',
  );
  String get medsForm => _t(
    'Form (optional, e.g. tablet, drops)',
    'Şekil (isteğe bağlı, ör. tablet, damla)',
  );
  String get medsSave => _t('Save', 'Kaydet');
  String get medsPlanAdd => _t('Write the plan', 'Planı yaz');
  String get medsPlanSchedule => _t(
    'How it is meant to be taken (e.g. 1 tablet every morning)',
    'Nasıl kullanılacağı (ör. her sabah 1 tablet)',
  );
  String get medsPlanSource =>
      _t('Where the plan comes from', 'Planın kaynağı');
  String medsPlanSourceLabel(PlanSource p) => switch (p) {
    PlanSource.prescribed => _t('Prescribed', 'Reçeteyle'),
    PlanSource.ownChoice => _t('My own choice', 'Kendi seçimim'),
    PlanSource.unknown => _t('Not given', 'Belirtilmedi'),
  };
  String medsMoreDoses(int n) => _t(
    '$n earlier doses are on the Timeline',
    '$n önceki doz Zaman çizelgesinde',
  );
  String get medsNoPlan => _t('No plan written', 'Plan yazılmadı');
  String medsPlanStateLabel(PlanState p) => switch (p) {
    PlanState.active => _t('active', 'geçerli'),
    PlanState.paused => _t('paused', 'duraklatıldı'),
    PlanState.stopped => _t('stopped', 'bırakıldı'),
  };
  String medsPlanLineState(String schedule, String source, String state) => _t(
    'Plan ($state): $schedule ($source)',
    'Plan ($state): $schedule ($source)',
  );
  String get medsPause => _t('Pause the plan', 'Planı duraklat');
  String get medsStop => _t('Stop the plan', 'Planı bırak');
  String get medsResume => _t('Follow the plan again', 'Plana yeniden başla');
  String get medsDose => _t('Record a dose', 'Doz kaydet');
  String get medsDoseTaken => _t('Taken', 'Alındı');
  String get medsDoseSkipped => _t('Skipped', 'Atlandı');
  String get medsDoseAmount => _t(
    'Amount (optional, e.g. 1 tablet)',
    'Miktar (isteğe bağlı, ör. 1 tablet)',
  );
  String get medsDoseWhen => _t(
    'When (optional, YYYY-MM-DD HH:MM; empty = now)',
    'Ne zaman (isteğe bağlı, YYYY-AA-GG SS:DD; boş = şimdi)',
  );
  String medsDoseCounts(int taken, int skipped) => _t(
    'Doses you recorded: $taken taken, $skipped skipped',
    'Kaydettiğin dozlar: $taken alındı, $skipped atlandı',
  );
  String get medsNoDoses => _t(
    'No dose recorded yet. The plan alone is not counted as taken.',
    'Henüz doz kaydedilmedi. Plan tek başına alınmış sayılmaz.',
  );
  String medsDoseLine(String when, bool taken, String? amount) => _t(
    '$when · ${taken ? 'taken' : 'skipped'}${amount == null ? '' : ' · $amount'}',
    '$when · ${taken ? 'alındı' : 'atlandı'}${amount == null ? '' : ' · $amount'}',
  );

  // Measurements (F007): kept exactly as typed, never judged.
  String get measurementsTitle => _t('Measurements', 'Ölçümler');
  String get measurementKind => _t('What did you measure?', 'Neyi ölçtün?');
  String get systolicField => _t(
    'Systolic, the upper number (mmHg)',
    'Büyük tansiyon, sistolik (mmHg)',
  );
  String get diastolicField => _t(
    'Diastolic, the lower number (mmHg)',
    'Küçük tansiyon, diyastolik (mmHg)',
  );
  String measurementField(RecordKind k) => switch (k) {
    RecordKind.restingHeartRate => _t(
      'Resting heart rate (bpm)',
      'Dinlenme nabzı (atım/dk)',
    ),
    RecordKind.waistCircumference => _t(
      'Waist circumference (cm)',
      'Bel çevresi (cm)',
    ),
    RecordKind.height => _t('Height (cm)', 'Boy (cm)'),
    RecordKind.bodyTemperature => _t(
      'Body temperature (°C)',
      'Vücut sıcaklığı (°C)',
    ),
    RecordKind.oxygenSaturation => _t(
      'Oxygen saturation, SpO2 (%)',
      'Oksijen satürasyonu, SpO2 (%)',
    ),
    RecordKind.respiratoryRate => _t(
      'Respiratory rate (breaths/min)',
      'Solunum hızı (soluk/dk)',
    ),
    _ => recordKind(k),
  };

  /// A neutral one-line hint that names what is measured (null: none).
  String? measurementHint(RecordKind k) => switch (k) {
    RecordKind.height => _t(
      'A new height is a new entry, not a correction of an old one.',
      'Yeni bir boy, eskisinin düzeltmesi değil yeni bir giriştir.',
    ),
    RecordKind.bodyTemperature => _t(
      'Write where you measured (mouth, ear, armpit) in the note.',
      'Nerede ölçtüğünü (ağız, kulak, koltuk altı) nota yaz.',
    ),
    RecordKind.oxygenSaturation => _t(
      'A reading from a pulse oximeter. Blood-gas results are not stored here.',
      'Nabız oksimetresinden okunan değer. Kan gazı sonuçları burada saklanmaz.',
    ),
    _ => null,
  };

  /// Shown when a backup was made for an entry that was then not saved.
  String checkpointKept(String where) => _t(
    'Not saved. A backup of your earlier data was made first and is at $where.',
    'Kaydedilmedi. Önce önceki verilerinin yedeği alındı, şurada: $where.',
  );

  String get whenField => _t('When (optional)', 'Ne zaman (isteğe bağlı)');
  String get whenHint => _t(
    'YYYY-MM-DD HH:MM or HH:MM, your device\'s time. Empty = now.',
    'YYYY-AA-GG SS:DD ya da SS:DD, cihazının saati. Boş = şimdi.',
  );
  String measuredAtLabel(String when) => _t('measured $when', 'ölçüm $when');
  String savedAtLabel(String when) => _t('saved $when', 'kayıt $when');
  String get contextField => _t(
    'Note (optional), e.g. sitting, left arm',
    'Not (isteğe bağlı), ör. oturarak, sol kol',
  );
  String get saveMeasurement => _t('Save measurement', 'Ölçümü kaydet');
  String get measurementNotYet => _t('Not recorded yet', 'Henüz kayıt yok');
  String get addMeasurement => _t('Add a measurement', 'Ölçüm ekle');
  String get yourNotes => _t(
    'Your earlier notes (click to use)',
    'Önceki notların (kullanmak için tıkla)',
  );
  String get moreDetails => _t('More details', 'Daha fazla ayrıntı');
  String get timePresetsLabel => _t('Quick pick', 'Hızlı seçim');
  String get presetNow => _t('Now', 'Şimdi');
  String get presetHourAgo => _t('1 hour ago', '1 saat önce');
  String get presetMorning => _t('This morning 08:00', 'Bu sabah 08:00');
  String get presetYesterdayEvening => _t('Yesterday 20:00', 'Dün 20:00');
  String get numberPadShow => _t('Show number pad', 'Sayı tuşlarını göster');
  String get numberPadHide => _t('Hide number pad', 'Sayı tuşlarını gizle');
  String get numberPadDelete =>
      _t('Delete last character', 'Son karakteri sil');
  String get numberPadDecimal => _t('Decimal separator', 'Ondalık ayırıcı');
  String numberPadDigit(int d) => _t('Digit $d', '$d rakamı');
  String get numberPadFor => _t('Typing into', 'Yazılan alan');

  /// The weekday and date shown at the top of Today.
  String dateLine(DateTime d) {
    const enDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const trDays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    const enMonths = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const trMonths = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return _t(
      '${enDays[d.weekday - 1]}, ${d.day} ${enMonths[d.month - 1]}',
      '${d.day} ${trMonths[d.month - 1]} ${trDays[d.weekday - 1]}',
    );
  }

  String get measurementsNote => _t(
    'Saved exactly as typed, with its time and source. Human OS does not judge these values. An empty field is never saved as 0.',
    'Yazdığın gibi, zamanı ve kaynağıyla saklanır. Human OS bu değerleri yorumlamaz. Boş alan asla 0 olarak kaydedilmez.',
  );
  String checkpointSaved(String where) => _t(
    'Saved. Before saving this entry, a backup of your earlier data was saved at $where: older versions of Human OS cannot open the new record format.',
    'Kaydedildi. Bu girişi kaydetmeden önce önceki verilerinin yedeği şuraya kaydedildi: $where. Human OS\'un eski sürümleri yeni kayıt biçimini açamaz.',
  );
  String get contextLabel => _t('note', 'not');

  /// A unit as shown (storage keeps the canonical unit).
  String unit(String u) => switch (u) {
    'bpm' => _t('bpm', 'atım/dk'),
    'breaths/min' => _t('breaths/min', 'soluk/dk'),
    _ => u,
  };

  /// A unit as a screen reader should say it.
  String spokenUnit(String u) => switch (u) {
    'mmHg' => _t('millimetres of mercury', 'milimetre cıva'),
    'bpm' => _t('beats per minute', 'dakikada atım'),
    'cm' => _t('centimetres', 'santimetre'),
    'kg' => _t('kilograms', 'kilogram'),
    '°C' => _t('degrees Celsius', 'santigrat derece'),
    '%' => _t('percent', 'yüzde'),
    'breaths/min' => _t('breaths per minute', 'dakikada soluk'),
    _ => u,
  };
  String spokenBloodPressure(String systolic, String diastolic) => _t(
    'systolic $systolic, diastolic $diastolic',
    'sistolik $systolic, diyastolik $diastolic',
  );
  String spokenLatest(
    String kind,
    String value,
    String when,
    String source, {
    String? saved,
  }) => _t(
    '$kind: $value, measured $when${saved == null ? '' : ', saved $saved'}, $source',
    '$kind: $value, ölçüm zamanı $when${saved == null ? '' : ', kaydedilme zamanı $saved'}, $source',
  );

  // Genetics (G001): a list of what a raw DNA file contains; never a meaning.
  String get summaryTitle => _t('Summary for a visit', 'Muayene için özet');
  String get summaryTileHint => _t(
    'What you recorded, as typed, with dates: show it or save it to print',
    'Kaydettiklerin, yazdığın gibi ve tarihleriyle: göster ya da yazdırmak için kaydet',
  );
  String summaryCreated(String when) => _t(
    'Made with Human OS on $when',
    'Human OS ile $when tarihinde hazırlandı',
  );
  String get summaryLabs => _t('Lab results', 'Lab sonuçları');
  String get summaryFooterTyped => _t(
    'Values are shown exactly as the person typed them, newest first, with the time each was measured.',
    'Değerler kişinin yazdığı gibi, en yeniden başlayarak, ölçüldüğü saatle gösterilir.',
  );
  String get summaryFooterNotDiagnosis => _t(
    'Recorded by the person, not by a clinic. Human OS does not interpret or score these values.',
    'Kişinin kendisi kaydetti, bir klinik değil. Human OS bu değerleri yorumlamaz ve puanlamaz.',
  );
  String get summaryEmpty => _t('Nothing recorded yet.', 'Henüz kayıt yok.');
  String get summarySave =>
      _t('Save as a page to print', 'Yazdırmak için sayfa olarak kaydet');
  String get summarySaveNotHere => _t(
    'This build keeps data encrypted, so the summary is shown here only and is not saved as an open file.',
    'Bu derleme verileri şifreli tutar; bu yüzden özet yalnız burada gösterilir, açık bir dosya olarak kaydedilmez.',
  );
  String summaryMore(int shown, int total) => _t(
    'Showing the newest $shown of $total.',
    '$total kaydın en yeni $shown tanesi gösteriliyor.',
  );
  String trendTitle(String kind) =>
      _t('$kind over time', '$kind, zaman içinde');
  String get seeOverTime => _t('See over time', 'Zaman içinde gör');
  String trendRange(String r) => switch (r) {
    'days30' => _t('30 days', '30 gün'),
    'days90' => _t('90 days', '90 gün'),
    'year' => _t('1 year', '1 yıl'),
    _ => _t('All', 'Tümü'),
  };
  String get trendNone =>
      _t('Nothing saved in this period.', 'Bu dönemde kayıt yok.');
  String get trendLegend => _t(
    'Each dot is a saved reading. A break in the line means more than 7 days without one; nothing is drawn in between. Click the chart to see a reading.',
    'Her nokta kaydedilmiş bir ölçümdür. Çizgideki kopukluk 7 günden uzun süre ölçüm olmadığını gösterir; arası doldurulmaz. Bir ölçümü görmek için grafiğe tıkla.',
  );
  String get trendLegendBp => _t(
    'Circles: systolic. Squares: diastolic. A break in the line means more than 7 days without a reading; nothing is drawn in between. Click the chart to see a reading.',
    'Daireler: sistolik. Kareler: diyastolik. Çizgideki kopukluk 7 günden uzun süre ölçüm olmadığını gösterir; arası doldurulmaz. Bir ölçümü görmek için grafiğe tıkla.',
  );
  String trendChartSpoken(int n) => _t(
    'Chart of $n saved readings; every reading is listed after it.',
    '$n kayıtlı ölçümün grafiği; her ölçüm aşağıda listelenmiştir.',
  );
  String get trendAllPoints => _t('Every reading', 'Tüm ölçümler');
  String get phytoTitle => _t('Plant chemicals', 'Bitki kimyasalları');
  String get phytoTileHint => _t(
    'Look up a table from the USDA plant-chemicals database, offline',
    'USDA bitki maddeleri veritabanından bir tabloya internetsiz bak',
  );
  String get phytoHow => _t(
    'On phytochem.nal.usda.gov open a chemical, an activity or a plant, then choose "Download these results as: CSV". Load that file here: it is read on this device and not saved.',
    'phytochem.nal.usda.gov sitesinde bir madde, etki ya da bitki aç, sonra "Download these results as: CSV" seç. O dosyayı buraya yükle: bu cihazda okunur ve kaydedilmez.',
  );
  String get phytoLoad => _t('Load a CSV file', 'CSV dosyası yükle');
  String phytoRefusal(String code) => switch (code) {
    'EMPTY' => _t('The file is empty.', 'Dosya boş.'),
    'XLSX' => _t(
      'This is an Excel (XLSX) file. Download the CSV version instead, or save it as CSV.',
      'Bu bir Excel (XLSX) dosyası. Bunun yerine CSV sürümünü indir ya da CSV olarak kaydet.',
    ),
    'TOO_LARGE' => _t(
      'The file is larger than 50 MB.',
      'Dosya 50 MB\'tan büyük.',
    ),
    'NOT_TABLE' => _t(
      'This does not look like a table with a header row.',
      'Bu, başlık satırı olan bir tabloya benzemiyor.',
    ),
    _ => _t('The file could not be read.', 'Dosya okunamadı.'),
  };
  String phytoLoaded(String name, int n) =>
      _t('$name: $n rows', '$name: $n satır');
  String phytoSkipped(int n) => _t(
    '$n lines had a different number of columns and are not shown.',
    '$n satırın sütun sayısı farklıydı, gösterilmiyor.',
  );
  String get phytoNote => _t(
    'Every cell is shown as the database wrote it. Most doses come from animal or cell studies (the abbreviations are explained under each row) and are not doses for people. An activity in a lab test is not proof of an effect in a person. Talk to a clinician or pharmacist before taking any supplement.',
    'Her hücre veritabanının yazdığı gibi gösterilir. Dozların çoğu hayvan ya da hücre çalışmalarından gelir (kısaltmalar her satırda açıklanır) ve insan için doz değildir. Laboratuvar testinde görülen bir etkinlik, bir insanda etkinin kanıtı değildir. Herhangi bir takviye almadan önce bir hekim ya da eczacıyla konuş.',
  );
  String get phytoSearch => _t('Search any column', 'Herhangi bir sütunda ara');
  String get phytoNone => _t('No row matches.', 'Eşleşen satır yok.');
  String phytoMore(int shown, int total) => _t(
    'Showing $shown of $total rows. Search to narrow them.',
    '$total satırın $shown tanesi gösteriliyor. Daraltmak için ara.',
  );
  String get phytoClear => _t('Close this table', 'Bu tabloyu kapat');
  String get clinvarNone => _t(
    'No ClinVar entry matches the variants in your file with this filter.',
    'Bu süzgeçle, dosyandaki varyantlarla eşleşen ClinVar kaydı yok.',
  );
  String clinvarMore(int shown, int total) => _t(
    'Showing $shown of $total entries.',
    '$total kaydın $shown tanesi gösteriliyor.',
  );
  String get clinvarHowWeb => _t(
    'In this browser version, unpack variant_summary.txt.gz first and load variant_summary.txt. The desktop and phone apps read the .gz directly.',
    'Bu tarayıcı sürümünde önce variant_summary.txt.gz dosyasını aç ve variant_summary.txt dosyasını yükle. Bilgisayar ve telefon uygulamaları .gz dosyasını doğrudan okur.',
  );
  String get glossaryTitle => _t('Glossary', 'Sözlük');
  String get glossaryTileHint => _t(
    'Every measurement and term in plain words, and how to measure at home',
    'Her ölçüm ve terim sade bir dille; evde nasıl ölçülür',
  );
  String get glossarySearch => _t('Search a term', 'Bir terim ara');
  String get glossaryNone => _t('No term matches.', 'Eşleşen terim yok.');
  String get glossaryUnit => _t('Unit', 'Birim');
  String get glossaryHow => _t('How to measure at home', 'Evde nasıl ölçülür');
  String get aboutMeasurement =>
      _t('About this measurement', 'Bu ölçüm hakkında');
  String get guideTitle =>
      _t('Body and specialties', 'Vücut ve uzmanlık alanları');
  String get guideTileHint => _t(
    'What each body system does and which doctors care for it',
    'Her vücut sisteminin ne yaptığı ve hangi hekimlerin ilgilendiği',
  );
  String get guideIntro => _t(
    'Click a body system to see what it does, its main parts, which medical specialties care for it, and what you can record for it here.',
    'Bir vücut sistemine tıkla: ne yaptığını, ana parçalarını, hangi tıp uzmanlıklarının ilgilendiğini ve burada onunla ilgili ne kaydedebileceğini gör.',
  );
  String get guideParts => _t('Main parts', 'Ana parçalar');
  String get guideWhoCares => _t('Who looks after it', 'Kim ilgilenir');
  String get guideFirstStop => _t(
    'Not sure where to go? Family medicine is the usual first stop. In an emergency call 112.',
    'Nereye gideceğinden emin değil misin? Olağan ilk adres aile hekimidir. Acil durumda 112\'yi ara.',
  );
  String get guideInHumanOs =>
      _t('You can record here', 'Burada kaydedebileceklerin');
  String get guideNotAdvice => _t(
    'A general guide written for Human OS. It does not diagnose and does not replace a clinician.',
    'Human OS için yazılmış genel bir rehber. Tanı koymaz ve hekimin yerini tutmaz.',
  );
  String get guideSourcesTitle =>
      _t('Sources of the structure', 'Yapının kaynakları');
  String firstStep(int n, int of) => _t('Step $n of $of', 'Adım $n / $of');
  String get firstWelcomeTitle => _t('What Human OS does', 'Human OS ne yapar');
  String get firstWelcomeBody => _t(
    'A place for your own health numbers: weight, blood pressure, lab results and more. You type them in, and find them again with their dates. Human OS does not judge values or give medical advice.',
    'Kendi sağlık sayıların için bir yer: kilo, tansiyon, lab sonuçları ve daha fazlası. Onları sen girersin ve tarihleriyle yeniden bulursun. Human OS değerleri yargılamaz ve tıbbi tavsiye vermez.',
  );
  String get firstPrivateTitle =>
      _t('It stays on this device', 'Bu cihazda kalır');
  String get firstPrivateBody => _t(
    'Human OS works without the internet. Nothing you enter is sent anywhere. Make a backup from "Your data" on Today to keep a copy.',
    'Human OS internetsiz çalışır. Girdiğin hiçbir şey bir yere gönderilmez. Bir kopya saklamak için Bugün ekranındaki "Verilerin" bölümünden yedek al.',
  );
  String get firstLookTitle => _t('Choose how it looks', 'Görünüşünü seç');
  String get firstLookBody => _t(
    'You can change all of this later in Settings (top right).',
    'Bunların hepsini daha sonra Ayarlar\'dan (sağ üst) değiştirebilirsin.',
  );
  String get firstMoreInSettings => _t(
    'Colour, text size, units and more are in Settings.',
    'Renk, yazı boyutu, birimler ve daha fazlası Ayarlar\'da.',
  );
  String get firstNext => _t('Next', 'İleri');
  String get firstBack => _t('Back', 'Geri');
  String get firstSkip => _t('Skip', 'Atla');
  String get firstStart => _t('Start', 'Başla');
  String get firstShowAgain =>
      _t('Show the introduction again', 'Tanıtımı yeniden göster');
  String get settingsTitle => _t('Settings', 'Ayarlar');
  String get settingsAccessibility =>
      _t('Appearance and accessibility', 'Görünüm ve erişilebilirlik');
  String get settingsDeviceScope => _t(
    'These choices apply on this device, not across an account.',
    'Bu tercihler bu cihazda geçerlidir, hesabın tamamına uygulanmaz.',
  );
  String get settingsInterfaceScale => _t('Interface scale', 'Arayüz ölçeği');
  String interfacePercent(int n) => _t('$n%', '%$n');
  String get interfaceScaleNote => _t(
    '80–200%. Text, buttons, icons and spacing scale together. The slider moves in steps of 5. On a narrow screen, scroll sideways if needed. Text size below is independent.',
    '%80–%200. Yazılar, düğmeler, simgeler ve boşluklar birlikte ölçeklenir. Kaydırıcı 5 puanlık adımlarla ilerler. Dar ekranda gerekirse yana kaydır. Aşağıdaki yazı boyutu ayarı bağımsızdır.',
  );
  String get interfaceExact =>
      _t('Exact scale (80–200)', 'Kesin ölçek (80–200)');
  String get interfaceInvalid => _t(
    'Enter a whole number from 80 to 200, for example 135.',
    '80 ile 200 arasında bir tam sayı yaz, örneğin 135.',
  );
  String get interfaceApply => _t('Apply scale', 'Ölçeği uygula');
  String get interfaceReset => _t('Reset scale to 100%', 'Ölçeği %100 yap');
  String get discoveryTitle => _t('Explore Human OS', 'Human OS keşfi');
  String get discoveryEnabled =>
      _t('Show discovery progress', 'Keşif ilerlemesini göster');
  String get discoveryNote => _t(
    'Optional: counts opening these three tools once. No health values or daily streaks are scored. Turn off here or in Settings; your records and progress stay.',
    'İsteğe bağlı: bu üç aracı birer kez açmanı sayar. Sağlık değerlerine veya günlük serilere puan verilmez. Buradan ya da Ayarlar’dan kapatabilirsin; kayıtların ve ilerlemen korunur.',
  );
  String discoveryCount(int n) =>
      _t('$n / 3 tools explored', '$n / 3 araç keşfedildi');
  String discoveryStep(DiscoveryStep step) => switch (step) {
    DiscoveryStep.settings => _t('Open Settings', 'Ayarları aç'),
    DiscoveryStep.glossary => _t(
      'Open a glossary entry',
      'Bir sözlük maddesini aç',
    ),
    DiscoveryStep.howTo => _t('Open the usage guide', 'Kullanım rehberini aç'),
  };
  String get discoveryVisited => _t('Opened', 'Açıldı');
  String get discoveryHide =>
      _t('Turn off discovery progress', 'Keşif ilerlemesini kapat');
  String get settingsTileHint => _t(
    'Language (Dil), light or dark, colour, text size',
    'Dil (Language), açık ya da koyu, renk, yazı boyutu',
  );
  String get settingsLanguage => _t('Language', 'Dil');
  String get settingsTheme => _t('Appearance', 'Görünüm');
  String get settingsAccent => _t('Colour', 'Renk');
  String get settingsTextSize => _t('Text size', 'Yazı boyutu');
  String get settingsSystem => _t('Same as this device', 'Bu cihazla aynı');
  String get settingsLight => _t('Light', 'Açık');
  String get settingsDark => _t('Dark', 'Koyu');
  String get settingsLarger => _t('Larger', 'Daha büyük');
  String get settingsLargest => _t('Largest', 'En büyük');
  String accentName(AccentChoice c) => switch (c) {
    AccentChoice.teal => _t('Teal', 'Petrol yeşili'),
    AccentChoice.blue => _t('Blue', 'Mavi'),
    AccentChoice.purple => _t('Purple', 'Mor'),
    AccentChoice.green => _t('Green', 'Yeşil'),
    AccentChoice.graphite => _t('Graphite', 'Grafit'),
  };
  String get settingsSpacing => _t('Spacing', 'Aralık');
  String get settingsFont => _t('Font', 'Yazı tipi');
  String get settingsUnits => _t('Units', 'Birimler');
  String get settingsDates => _t('Date and time', 'Tarih ve saat');
  String get datesNote => _t(
    'Changes how dates and times are shown. When you type a time, the format stays YYYY-MM-DD HH:MM.',
    'Tarih ve saatlerin nasıl gösterildiğini değiştirir. Bir saat yazarken biçim YYYY-AA-GG SS:DD olarak kalır.',
  );
  String get unitsMetric => _t('kg, cm, °C', 'kg, cm, °C');
  String get unitsUs => _t('Also show lb, in, °F', 'lb, inç, °F de göster');
  String get unitsNote => _t(
    'You always type in kg, cm and °C, and that is what is saved. With US units a converted value is shown beside it, marked ≈.',
    'Her zaman kg, cm ve °C ile yazarsın ve kaydedilen budur. ABD birimleri seçiliyse yanında ≈ işaretli, dönüştürülmüş bir değer gösterilir.',
  );
  String get fontLegible => _t(
    'Easy to read (Atkinson Hyperlegible)',
    'Kolay okunur (Atkinson Hyperlegible)',
  );
  String get fontDyslexic =>
      _t('For dyslexia (OpenDyslexic)', 'Disleksi için (OpenDyslexic)');
  String get settingsReduceMotion => _t(
    'Less motion: pages open without sliding',
    'Daha az hareket: sayfalar kaymadan açılır',
  );
  String get settingsWideSpacing => _t(
    'More space between letters, words and lines',
    'Harfler, sözcükler ve satırlar arasında daha fazla boşluk',
  );
  String get settingsComfortable => _t('Comfortable', 'Rahat');
  String get settingsCompact => _t('Compact', 'Sıkışık');
  String get settingsContrast => _t('Contrast', 'Kontrast');
  String get settingsHighContrast => _t(
    'Stronger contrast (darker text and edges)',
    'Güçlü kontrast (daha koyu yazı ve kenarlar)',
  );
  String get settingsStart =>
      _t('Open the app on', 'Uygulama şu ekranla açılsın');
  String startScreenName(StartScreen x) => switch (x) {
    StartScreen.today => _t('Today', 'Bugün'),
    StartScreen.timeline => _t('Timeline', 'Zaman çizelgesi'),
    StartScreen.labs => _t('Labs', 'Lab'),
  };
  String get settingsToday => _t('Today screen', 'Bugün ekranı');
  String get settingsTiles => _t(
    'Measurement tiles: tick to show, arrows to reorder',
    'Ölçüm kutuları: göstermek için işaretle, sırayı oklarla değiştir',
  );
  String settingsMoveUp(String what) =>
      _t('Move $what up', '$what yukarı taşı');
  String settingsMoveDown(String what) =>
      _t('Move $what down', '$what aşağı taşı');
  String get settingsSections => _t('Sections', 'Bölümler');
  String todaySectionName(TodaySection x) => switch (x) {
    TodaySection.sleep => _t('Sleep', 'Uyku'),
    TodaySection.feeling => _t('How you feel', 'Nasıl hissediyorsun'),
    TodaySection.tools => _t('Tools', 'Araçlar'),
    TodaySection.yourData => _t('Your data (backups)', 'Verilerin (yedekler)'),
    TodaySection.buildFacts => _t('About this build', 'Bu derleme hakkında'),
  };
  String get settingsCheckInsFirst => _t(
    'Sleep and How you feel at the top of Today',
    'Uyku ve Nasıl hissediyorsun Bugün ekranının en üstünde',
  );
  String get settingsMeasurementsFirst =>
      _t('Measurements before the weight card', 'Ölçümler kilo kartından önce');
  String get settingsUpdatesTitle =>
      _t('Updates and about', 'Güncellemeler ve hakkında');
  String settingsInstalledVersion(String version, String revision) => _t(
    'Installed version: $version (source $revision)',
    'Yüklü sürüm: $version (kaynak $revision)',
  );
  String get settingsUpdatesHow => _t(
    'Human OS does not look for newer versions by itself; it sends nothing to the internet. Newer versions are listed on this page; open it in a browser and compare the version number:',
    'Human OS yeni sürüm olup olmadığına kendisi bakmaz; internete hiçbir şey göndermez. Yeni sürümler bu sayfada listelenir; tarayıcıda aç ve sürüm numarasını karşılaştır:',
  );
  String get settingsUpdatesKeepData => _t(
    'Before installing another version, make a backup from Your data on Today.',
    'Başka bir sürüm kurmadan önce Bugün ekranındaki Verilerin bölümünden yedek al.',
  );
  String get aionAlt => _t(
    'Aion, the Human OS character, waving',
    'Aion, Human OS karakteri, el sallıyor',
  );
  String get settingsShowAion => _t(
    'Show Aion, the Human OS character',
    'Human OS karakteri Aion\'u göster',
  );
  String get settingsPadOpen => _t(
    'Open the number pad in every measurement',
    'Her ölçümde sayı tuşları açık başlasın',
  );
  String get settingsResetToday =>
      _t('Reset Today to default', 'Bugün ekranını varsayılana döndür');
  String get allTilesHidden => _t(
    'All measurement tiles are hidden. Choose them in Settings (top right).',
    'Tüm ölçüm kutuları gizli. Ayarlar\'dan (sağ üst) seçebilirsin.',
  );
  String get settingsSaved => _t(
    'Changes apply at once and are kept on this device.',
    'Değişiklikler hemen uygulanır ve bu cihazda saklanır.',
  );
  String get settingsSessionOnly => _t(
    'Changes apply at once. This build keeps them until the app is closed.',
    'Değişiklikler hemen uygulanır. Bu derleme onları uygulama kapanana kadar tutar.',
  );
  String get settingsSaveFailed => _t(
    'The change applies now but could not be saved; it lasts until the app is closed.',
    'Değişiklik şimdi uygulandı ama kaydedilemedi; uygulama kapanana kadar geçerli.',
  );
  String get howToTitle =>
      _t('How to use Human OS', 'Human OS nasıl kullanılır');
  String get howToTileHint => _t(
    'Six short steps, all with the mouse',
    'Fareyle yapılan altı kısa adım',
  );
  List<(String, String)> get howToSteps => [
    (
      _t('Add a number', 'Bir sayı ekle'),
      _t(
        'On Today, click a tile such as Blood pressure. Type the value, or click "Show number pad" and click the digits. Click "Save measurement".',
        'Bugün ekranında Tansiyon gibi bir kutuya tıkla. Değeri yaz ya da "Sayı tuşlarını göster"e tıklayıp rakamlara tıkla. "Ölçümü kaydet"e tıkla.',
      ),
    ),
    (
      _t('Say when it was measured', 'Ne zaman ölçüldüğünü söyle'),
      _t(
        'Open "More details" and click a quick pick such as "1 hour ago", or type the time. Empty means now.',
        '"Daha fazla ayrıntı"yı aç ve "1 saat önce" gibi bir hızlı seçime tıkla ya da saati yaz. Boş bırakırsan şimdi sayılır.',
      ),
    ),
    (
      _t('Find it again', 'Yeniden bul'),
      _t(
        'Timeline lists everything you saved, with the time it was measured.',
        'Zaman çizelgesi kaydettiğin her şeyi ölçüldüğü saatle listeler.',
      ),
    ),
    (
      _t('Fix a mistake', 'Bir hatayı düzelt'),
      _t(
        'On the Timeline, open the entry and click Correct. The old value is kept as history and the new one is shown.',
        'Zaman çizelgesinde kaydı aç ve Düzelt\'e tıkla. Eski değer geçmiş olarak saklanır, yenisi gösterilir.',
      ),
    ),
    (
      _t('Add a lab result', 'Bir lab sonucu ekle'),
      _t(
        'On Labs, type the test name, value, unit and range exactly as the report prints them.',
        'Lab ekranında test adını, değeri, birimi ve aralığı raporda yazdığı gibi gir.',
      ),
    ),
    (
      _t('Keep a copy', 'Bir kopya sakla'),
      _t(
        'Under "Your data" on Today, click "Create backup". Keep the file somewhere safe.',
        'Bugün ekranındaki "Verilerin" bölümünde "Yedek oluştur"a tıkla. Dosyayı güvenli bir yerde sakla.',
      ),
    ),
  ];
  String get howToNote => _t(
    'Human OS records what you enter and shows it back. It does not judge values or give medical advice.',
    'Human OS girdiğini kaydeder ve sana geri gösterir. Değerleri yargılamaz, tıbbi tavsiye vermez.',
  );
  String get geneticsTitle => _t('Genetics', 'Genetik');
  String get geneticsToolsTitle => _t('Tools', 'Araçlar');
  String get toolsGroupApp => _t('App and visits', 'Uygulama ve muayene');
  String get toolsGroupLearn => _t('Words and the body', 'Terimler ve beden');
  String get toolsGroupFiles => _t('Read a file', 'Dosya oku');
  String get geneticsTileHint => _t(
    'Read a raw DNA file (23andMe, AncestryDNA, MyHeritage, FamilyTreeDNA) on this device',
    'Ham bir DNA dosyasını (23andMe, AncestryDNA, MyHeritage, FamilyTreeDNA) bu cihazda oku',
  );
  String get geneticsIntro => _t(
    'See which variants your raw DNA file contains. Everything stays on this device.',
    'Ham DNA dosyanın hangi varyantları içerdiğini gör. Her şey bu cihazda kalır.',
  );
  String get geneticsNoticeTitle =>
      _t('Before you load a file', 'Dosyayı yüklemeden önce');
  List<String> get geneticsNotices => [
    _t(
      'Your genome identifies you for life and cannot be changed like a password.',
      'Genomun seni ömür boyu tanımlar ve bir şifre gibi değiştirilemez.',
    ),
    _t(
      'It also says things about relatives who did not choose to share it.',
      'Paylaşmayı seçmemiş akrabaların hakkında da bilgi verir.',
    ),
    _t(
      'Human OS does not save the file. Your operating system may keep copies you cannot see: downloads, screenshots, device backups.',
      'Human OS dosyayı kaydetmez. İşletim sistemin görmediğin kopyalar tutabilir: indirilenler, ekran görüntüleri, cihaz yedekleri.',
    ),
    _t(
      'This is a list of what the file contains, not a medical result. A variant missing from a list says nothing about you. Talk to a clinician or genetic counsellor before acting on anything.',
      'Bu, dosyanın içeriğinin dökümüdür, tıbbi bir sonuç değildir. Listede olmayan bir varyant senin hakkında bir şey söylemez. Bir şeye göre davranmadan önce bir hekim ya da genetik danışmanla konuş.',
    ),
  ];
  String get geneticsChoose => _t('Choose a DNA file', 'DNA dosyası seç');
  String get geneticsSample =>
      _t('Try an invented sample file', 'Uydurma bir örnek dosya dene');
  String get geneticsReading => _t('Reading the file…', 'Dosya okunuyor…');
  String geneticsLoadedFrom(String name) =>
      _t('Read from $name', '$name dosyasından okundu');
  String get geneticsSampleLoaded => _t(
    'Invented sample file: not a real person',
    'Uydurma örnek dosya: gerçek bir kişi değil',
  );
  String get geneticsKeptOnly => _t(
    'Kept only while this page is open, or until you clear it. Not saved by Human OS.',
    'Yalnız bu sayfa açıkken ya da sen temizleyene kadar tutulur. Human OS kaydetmez.',
  );
  String get geneticsClear => _t('Clear', 'Temizle');
  String get geneticsFormat => _t('Format', 'Biçim');
  String get geneticsBuild => _t('Genome build', 'Genom sürümü');
  String get geneticsBuildNotStated =>
      _t('not stated in the file', 'dosyada belirtilmemiş');
  String get geneticsTotal =>
      _t('Variants in the file', 'Dosyadaki varyantlar');
  String get geneticsRead => _t('Called', 'Belirlenen');
  String get geneticsNotRead => _t('No call', 'Belirlenemeyen');
  String get geneticsUnreadableLines =>
      _t('Lines that could not be read', 'Okunamayan satırlar');
  String get geneticsRepeated => _t('Repeated ids', 'Tekrarlanan kimlikler');
  String get geneticsChromosomes => _t('By chromosome', 'Kromozoma göre');
  String get geneticsSearchHint => _t(
    'Search by rsID (part of it) or chromosome (1–22, X, Y, MT)',
    'rsID (bir kısmı) ya da kromozomla ara (1–22, X, Y, MT)',
  );
  String get geneticsChromosomeShort => _t('chr', 'kr');
  String get geneticsNotReadShort => _t('no call', 'belirlenemedi');
  String get geneticsPrev => _t('Previous', 'Önceki');
  String get geneticsNext => _t('Next', 'Sonraki');
  String geneticsRange(int from, int to, int total) =>
      _t('$from–$to of $total', '$from–$to / $total');
  String get geneticsNoMatches => _t(
    'No variants match. Try part of an rsID such as rs12, or a chromosome such as 7, X or MT.',
    'Eşleşen varyant yok. rsID’nin bir kısmını (rs12 gibi) ya da bir kromozomu (7, X, MT gibi) dene.',
  );
  String geneticsRefusal(String code) => switch (code) {
    'EMPTY' => _t('The file is empty.', 'Dosya boş.'),
    'UNKNOWN_FORMAT' => _t(
      'This does not look like a raw data file from 23andMe, AncestryDNA, MyHeritage or FamilyTreeDNA.',
      'Bu, 23andMe, AncestryDNA, MyHeritage ya da FamilyTreeDNA ham veri dosyasına benzemiyor.',
    ),
    'NO_VARIANTS' => _t(
      'The file has a header but no readable variants.',
      'Dosyada başlık var ama okunabilir varyant yok.',
    ),
    'MOSTLY_INVALID' => _t(
      'Most lines could not be read, so the file was not loaded.',
      'Satırların çoğu okunamadığı için dosya yüklenmedi.',
    ),
    'COMPRESSED' => _t(
      'This is a compressed file (zip or gzip). Extract it first and choose the text file inside.',
      'Bu sıkıştırılmış bir dosya (zip ya da gzip). Önce çıkar, içindeki metin dosyasını seç.',
    ),
    'NOT_TEXT' => _t(
      'This is not a plain text file.',
      'Bu düz metin bir dosya değil.',
    ),
    'TOO_LARGE' => _t(
      'The file is too large (more than 200 MB).',
      'Dosya çok büyük (200 MB üzeri).',
    ),
    'VCF' => _t(
      'VCF files are not supported yet. Choose a raw data file from a consumer service.',
      'VCF dosyaları henüz desteklenmiyor. Bir tüketici servisinden ham veri dosyası seç.',
    ),
    _ => _t('The file could not be read.', 'Dosya okunamadı.'),
  };
  String geneticsInvalidReason(String code) => switch (code) {
    'COLUMNS' => _t('wrong number of columns', 'sütun sayısı yanlış'),
    'CHROMOSOME' => _t('unknown chromosome', 'bilinmeyen kromozom'),
    'POSITION' => _t('position is not a number', 'konum bir sayı değil'),
    'ID' => _t('unreadable id', 'okunamayan kimlik'),
    'GENOTYPE' => _t('unreadable genotype', 'okunamayan genotip'),
    'PARTIAL' => _t('only one allele was read', 'yalnız bir alel okunmuş'),
    _ => code,
  };
  String geneticsInvalidLine(int line, String reason) =>
      _t('Line $line: $reason', 'Satır $line: $reason');
  String get uniprotTitle =>
      _t('Proteins from UniProt', 'UniProt\'tan proteinler');
  String get uniprotHow => _t(
    'On uniprot.org search for your genes (or "Homo sapiens" and Reviewed), choose Download, Format: TSV, with the columns Gene Names, Protein names and Function [CC], then load the file here. It is read on this device; nothing is sent.',
    'uniprot.org\'da genlerini (ya da "Homo sapiens" ve Reviewed) ara, Download\'u seç, Format: TSV; Gene Names, Protein names ve Function [CC] sütunlarıyla indir, sonra dosyayı buraya yükle. Bu cihazda okunur; hiçbir şey gönderilmez.',
  );
  String get uniprotLoad =>
      _t('Load a UniProt TSV file', 'UniProt TSV dosyası yükle');
  String uniprotCounts(int kept, int skipped) => _t(
    '$kept proteins read${skipped > 0 ? '; $skipped rows not kept' : ''}.',
    '$kept protein okundu${skipped > 0 ? '; $skipped satır tutulmadı' : ''}.',
  );
  String get uniprotNote => _t(
    'Protein names and functions are UniProt\'s words (UniProt Consortium, CC BY 4.0) about each protein, not about you. Shown first: the genes named in the dbSNP and ClinVar files loaded on this page.',
    'Protein adları ve işlevleri UniProt\'un her protein için yazdıklarıdır (UniProt Consortium, CC BY 4.0); senin hakkında değildir. Önce bu sayfada yüklenen dbSNP ve ClinVar dosyalarında geçen genler gösterilir.',
  );
  String get uniprotSearch => _t(
    'Search gene, protein or accession',
    'Gen, protein ya da erişim no. ara',
  );
  String get uniprotNone => _t('No protein matches.', 'Eşleşen protein yok.');
  String get uniprotNoGenes => _t(
    'Load a dbSNP or ClinVar file on this page to see the proteins of their genes here, or search.',
    'Genlerinin proteinlerini burada görmek için bu sayfada bir dbSNP ya da ClinVar dosyası yükle ya da ara.',
  );
  String uniprotRefusal(String code) => switch (code) {
    'SPREADSHEET' => _t(
      'This looks like a spreadsheet (XLSX). Download the TSV format instead.',
      'Bu bir tablo dosyası (XLSX) gibi görünüyor. Bunun yerine TSV biçimini indir.',
    ),
    'NOT_UNIPROT' => _t(
      'This file has no Entry and Gene Names columns, so it is not a UniProt TSV export.',
      'Bu dosyada Entry ve Gene Names sütunları yok; bir UniProt TSV dışa aktarımı değil.',
    ),
    'EMPTY' => _t('The file is empty.', 'Dosya boş.'),
    _ => _t('The file could not be read.', 'Dosya okunamadı.'),
  };
  String get clinvarTitle =>
      _t('Compare with ClinVar', 'ClinVar ile karşılaştır');
  String get clinvarHow => _t(
    'Download variant_summary.txt.gz from ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/ (about 400 MB) once, then load it here. It is read on this device, line by line, keeping only the variants in your DNA file.',
    'ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/ adresinden variant_summary.txt.gz dosyasını (yaklaşık 400 MB) bir kez indir, sonra buraya yükle. Bu cihazda satır satır okunur ve yalnız DNA dosyandaki varyantlar tutulur.',
  );
  String get clinvarLoad =>
      _t('Load the ClinVar summary file', 'ClinVar özet dosyasını yükle');
  String clinvarReading(int n) =>
      _t('Reading… $n lines so far', 'Okunuyor… şimdiye dek $n satır');
  String clinvarRefusal(String code) => switch (code) {
    'NOT_CLINVAR' => _t(
      'This does not look like ClinVar\'s variant_summary file.',
      'Bu, ClinVar\'ın variant_summary dosyasına benzemiyor.',
    ),
    'GZ_HERE' => _t(
      'This build cannot unpack .gz files. Unpack it first (to variant_summary.txt) and load that.',
      'Bu derleme .gz dosyalarını açamıyor. Önce dosyayı aç (variant_summary.txt) ve onu yükle.',
    ),
    _ => _t('The file could not be read.', 'Dosya okunamadı.'),
  };
  String clinvarCounts(int lines, int found) => _t(
    '$lines lines read; $found ClinVar entries match variants in your DNA file.',
    '$lines satır okundu; $found ClinVar kaydı DNA dosyandaki varyantlarla eşleşiyor.',
  );
  String clinvarCapped(int n) => _t(
    'More than $n entries ClinVar labels "Benign" or "Likely benign" matched; the rest of those are not kept. Every other entry is kept.',
    'ClinVar\'ın "Benign" ya da "Likely benign" etiketlediği $n kayıttan fazlası eşleşti; bunların geri kalanı tutulmadı. Diğer bütün kayıtlar tutuldu.',
  );
  String get clinvarOnlyListed => _t(
    'Only where my file lists the alternate allele',
    'Yalnız dosyamın alternatif aleli listelediği yerler',
  );
  String get clinvarNote => _t(
    'ClinVar\'s labels summarise what laboratories submitted about a variant for a condition; the review status says how it was reviewed (for example criteria provided, number of submitters, expert panel). A label describes the variant, not how many copies you carry or whether it causes anything in you; that depends on both copies, inheritance, family history and a clinical assessment. Talk to a clinician or genetic counsellor before acting on anything.',
    'ClinVar\'ın etiketleri laboratuvarların bir varyant hakkında, bir durum için bildirdiklerini özetler; gözden geçirme durumu nasıl incelendiğini söyler (örneğin ölçüt sunulmuş, bildiren sayısı, uzman paneli). Bir etiket varyantı anlatır; kaç kopya taşıdığını ya da sende bir şeye yol açıp açmadığını söylemez. Bu, iki kopyaya, kalıtıma, aile öyküsüne ve klinik değerlendirmeye bağlıdır. Bir şeye göre davranmadan önce bir hekim ya da genetik danışmanla konuş.',
  );
  String clinvarAlleles(String ref, String alt, String assembly) => _t(
    'ClinVar alleles (plus strand, $assembly): $ref > $alt',
    'ClinVar alelleri (artı şerit, $assembly): $ref > $alt',
  );
  String clinvarGenotype(String g) =>
      _t('Genotype in your file: $g', 'Dosyandaki genotip: $g');
  String clinvarLetters(String allele, int showing, int letters) => _t(
    'Letters showing $allele: $showing of $letters',
    'Dosyada $allele olan harf: $showing (toplam $letters)',
  );
  String clinvarSignificance(String v) =>
      _t('ClinVar label: $v', 'ClinVar etiketi: $v');
  String clinvarReview(String v) =>
      _t('Review status: $v', 'Gözden geçirme durumu: $v');
  String clinvarConditions(String v) => _t(
    'Conditions submitters named: $v',
    'Bildirenlerin adlandırdığı durumlar: $v',
  );
  String get dbsnpTitle =>
      _t('Compare with a dbSNP file', 'Bir dbSNP dosyasıyla karşılaştır');
  String get dbsnpHow => _t(
    'On ncbi.nlm.nih.gov/snp search a gene (for example GABRB3), then Send to > File > Format: Summary > Create File. Load that file here: it is read on this device and compared with your file by rsID.',
    'ncbi.nlm.nih.gov/snp sitesinde bir gen ara (örneğin GABRB3), sonra Send to > File > Format: Summary > Create File. O dosyayı buraya yükle: bu cihazda okunur ve dosyanla rsID üzerinden karşılaştırılır.',
  );
  String get dbsnpLoad =>
      _t('Load a dbSNP Summary file', 'dbSNP Summary dosyası yükle');
  String dbsnpRefusal(String code) => switch (code) {
    'EMPTY' => _t('The file is empty.', 'Dosya boş.'),
    'NOT_SUMMARY' => _t(
      'This does not look like a dbSNP Summary file. Choose Format: Summary when you create it.',
      'Bu bir dbSNP Summary dosyasına benzemiyor. Dosyayı oluştururken Format: Summary seç.',
    ),
    _ => _t('The file could not be read.', 'Dosya okunamadı.'),
  };
  String dbsnpCounts(int all, int inFile) => _t(
    '$all variants in the dbSNP file; $inFile of them are in your DNA file.',
    'dbSNP dosyasında $all varyant var; bunların $inFile tanesi DNA dosyanda bulunuyor.',
  );
  String get dbsnpOnlyMissense => _t(
    'Only missense (changes an amino acid)',
    'Yalnız missense (bir amino asidi değiştirir)',
  );
  String get dbsnpOnlyClinical => _t(
    'Only with a clinical label in dbSNP',
    'Yalnız dbSNP\'de klinik etiketi olanlar',
  );
  String get dbsnpNote => _t(
    'Labels are dbSNP\'s words for the variant, from its sources. They are not a statement about you: what a variant means depends on both copies, inheritance and the rest of your health. Talk to a clinician or genetic counsellor before acting on anything. Human OS does not predict an effect where dbSNP gives none.',
    'Etiketler dbSNP\'nin, kaynaklarına dayanarak varyant için kullandığı sözlerdir. Senin hakkında bir ifade değildir: bir varyantın ne anlama geldiği iki kopyaya, kalıtıma ve sağlığının geri kalanına bağlıdır. Bir şeye göre davranmadan önce bir hekim ya da genetik danışmanla konuş. dbSNP bir etki belirtmediğinde Human OS kendi tahminini yapmaz.',
  );
  String get dbsnpNone => _t(
    'None of the shown variants are in your file.',
    'Gösterilen varyantların hiçbiri dosyanda yok.',
  );
  String dbsnpMore(int shown, int total) => _t(
    'Showing $shown of $total.',
    '$total varyantın $shown tanesi gösteriliyor.',
  );
  String dbsnpCall(String call, String alts) => switch (call) {
    'listsAlternate' => _t(
      'Your file lists the alternate allele $alts',
      'Dosyan alternatif alel $alts listeliyor',
    ),
    'referenceOnly' => _t(
      'Your file lists only the reference allele',
      'Dosyan yalnız referans aleli listeliyor',
    ),
    'noCall' => _t(
      'No call at this position in your file',
      'Dosyanda bu konum için çağrı yok',
    ),
    'otherAllele' => _t(
      'Your file lists a letter the source does not name here (a strand or build difference, or another allele); nothing is compared',
      'Dosyan, kaynağın burada adlandırmadığı bir harf listeliyor (şerit ya da sürüm farkı veya başka bir alel); karşılaştırma yapılmadı',
    ),
    _ => _t(
      'Not compared (an insertion or deletion, or A/T, C/G letters whose strand cannot be told apart)',
      'Karşılaştırılmadı (bir ekleme ya da silme, ya da şeridi ayırt edilemeyen A/T, C/G harfleri)',
    ),
  };
  String dbsnpAlleles(String ref, String alts) => _t(
    'dbSNP alleles (plus strand): $ref > $alts',
    'dbSNP alelleri (artı şerit): $ref > $alts',
  );
  String dbsnpConsequence(String c) =>
      _t('dbSNP consequence: $c', 'dbSNP işlevsel sonucu: $c');
  String dbsnpClinical(String c) => _t(
    'dbSNP clinical significance (for the rsID, not one allele): $c',
    'dbSNP klinik anlamlılık (rsID için, tek bir alel için değil): $c',
  );
  String get dbsnpNoClinical => _t(
    'dbSNP gives no clinical significance',
    'dbSNP bir klinik anlamlılık belirtmiyor',
  );
  String get geneticsPackTitle =>
      _t('Statements from a source pack', 'Bir kaynak paketinden ifadeler');
  String get geneticsPackNote => _t(
    'A pack states what its source says. An association is not a cause, and a list like this is not a diagnosis. Most of the genome is not covered: no entry here means nothing.',
    'Bir paket kaynağının söylediğini aktarır. Bir ilişki bir neden değildir ve böyle bir liste tanı değildir. Genomun çoğu kapsanmıyor: burada kayıt olmaması bir şey ifade etmez.',
  );
  String get geneticsPackSynthetic => _t(
    'INVENTED demonstration pack: not real knowledge',
    'UYDURMA gösterim paketi: gerçek bilgi değil',
  );
  String get geneticsPackSource => _t('Source', 'Kaynak');
  String get geneticsPackLicence => _t('Licence', 'Lisans');
  String get geneticsPackLoad => _t('Load a pack file', 'Paket dosyası yükle');
  String get geneticsPackNone => _t(
    'No pack entry mentions a variant in this file.',
    'Hiçbir paket kaydı bu dosyadaki bir varyanttan söz etmiyor.',
  );
  String geneticsPackRefusal(String code) => switch (code) {
    'EMPTY' => _t('The pack file is empty.', 'Paket dosyası boş.'),
    'HEADER' => _t(
      'The pack must state its name, licence, build and strand in its header.',
      'Paket, başlığında adını, lisansını, sürümünü ve şeridini belirtmeli.',
    ),
    'STRAND' => _t(
      'Only packs on the plus strand are read.',
      'Yalnız artı şeridindeki paketler okunur.',
    ),
    'NO_ROWS' => _t('The pack has no entries.', 'Paketin kaydı yok.'),
    _ => _t('The pack could not be read.', 'Paket okunamadı.'),
  };
  String geneticsMatchKind(String kind, {String allele = ''}) => switch (kind) {
    'containsAllele' => _t(
      'The file lists allele $allele at this position',
      'Dosya bu konumda $allele alelini listeliyor',
    ),
    'doesNotMatch' => _t(
      'The file lists no $allele at this position. This says nothing about other positions.',
      'Dosya bu konumda $allele alelini listelemiyor. Bu, başka konumlar hakkında bir şey söylemez.',
    ),
    'notComparable' => _t(
      'The call here is an insertion or deletion, so it is not compared with allele $allele',
      'Buradaki çağrı bir ekleme ya da silme olduğundan $allele aleliyle karşılaştırılmaz',
    ),
    'notRead' => _t(
      'No call at this position in your file',
      'Dosyanda bu konum için çağrı yok',
    ),
    _ => _t(
      'Cannot be told apart by strand (A/T or C/G), so nothing is claimed',
      'Şeride göre ayırt edilemez (A/T ya da C/G), bu yüzden bir şey öne sürülmez',
    ),
  };
  String geneticsBuildNote(String note, String build) => switch (note) {
    'same' => _t('Build $build in both', 'İkisinde de sürüm $build'),
    'differs' => _t(
      'The file and the pack state different builds',
      'Dosya ve paket farklı sürümler belirtiyor',
    ),
    _ => _t('Build not stated by the file', 'Sürüm dosyada belirtilmemiş'),
  };
  String geneticsGenotypeSpoken(String? call) =>
      call == null ? _t('no call', 'belirlenemedi') : call.split('').join(', ');
  String geneticsRowSpoken(
    String rsid,
    String chr,
    int pos,
    String? call,
  ) => _t(
    '$rsid, chromosome $chr, position $pos, ${geneticsGenotypeSpoken(call)}',
    '$rsid, kromozom $chr, konum $pos, ${geneticsGenotypeSpoken(call)}',
  );

  // Labs (F004): everything is shown as the report printed it.
  String get labsNoInterpretation => _t(
    'Values, flags and ranges are shown exactly as the lab printed them. Human OS does not interpret lab results or say whether they are good or bad.',
    'Değerler, işaretler ve aralıklar laboratuvarın yazdığı gibi gösterilir. Human OS lab sonuçlarını yorumlamaz, iyi ya da kötü olduklarını söylemez.',
  );
  String get labAddTitle =>
      _t('Add a result from a report', 'Rapordan sonuç ekle');
  String get labCorrectTitle =>
      _t('Correct this result (new version)', 'Bu sonucu düzelt (yeni sürüm)');
  String get labAnalyte => _t('Test name as printed', 'Raporda yazan test adı');
  String get labAnalyteHelp => _t(
    'Copy it exactly, e.g. "HbA1c". Similar names are kept apart.',
    'Aynen yaz, ör. "HbA1c". Benzer adlar ayrı tutulur.',
  );
  String get labValue => _t('Value', 'Değer');
  String get labNotReported =>
      _t('The report gives no value', 'Raporda değer yok');
  String get labUnit => _t('Unit as printed', 'Raporda yazan birim');
  String get labUnitHelp => _t(
    'Leave empty if the report prints none; it stays "not given", never guessed.',
    'Raporda yoksa boş bırak; "verilmedi" olarak kalır, tahmin edilmez.',
  );
  String get labSampleDate => _t('Sample date', 'Numune tarihi');
  String get labSpecimen =>
      _t('Specimen (optional)', 'Numune türü (isteğe bağlı)');
  String get labLaboratory =>
      _t('Laboratory (optional)', 'Laboratuvar (isteğe bağlı)');
  String get labFlag => _t(
    'Flag printed by the lab (optional)',
    'Laboratuvarın işareti (isteğe bağlı)',
  );
  String get labFlagHelp => _t(
    'Copy any mark next to the value, e.g. H, L or *.',
    'Değerin yanındaki işareti aynen yaz, ör. H, L ya da *.',
  );
  String get labRange => _t(
    'Reference range as printed (optional)',
    'Raporda yazan referans aralığı (isteğe bağlı)',
  );
  String get labRangeHelp => _t(
    'Copy it as printed, e.g. "70 - 100". It is the lab\'s range, not a target.',
    'Yazdığı gibi aktar, ör. "70 - 100". Laboratuvarın aralığıdır, hedef değildir.',
  );
  String labPrintedFlag(String f) =>
      _t('Lab flag: $f', 'Laboratuvar işareti: $f');
  String labPrintedRange(String r) =>
      _t('Lab\'s printed range: $r', 'Laboratuvarın yazdığı aralık: $r');
  String get labNoRangePrinted => _t('No range printed', 'Aralık yazılmamış');
  String get unitNotGiven => _t('unit not given', 'birim verilmedi');

  String versionsCount(int n) => _t('$n versions', '$n sürüm');

  String entryStatus(EntryStatus st) => switch (st) {
    EntryStatus.current => _t('Current', 'Güncel'),
    EntryStatus.conflict => _t('Conflict', 'Çelişki'),
    EntryStatus.deleted => _t('Deleted', 'Silindi'),
    EntryStatus.enteredInError => _t('Entered in error', 'Yanlışlıkla girildi'),
  };

  String entryStatusExplain(EntryStatus st) => switch (st) {
    EntryStatus.current => _t(
      'The newest version counts. Older versions stay below as history.',
      'En yeni sürüm geçerli. Eski sürümler aşağıda geçmiş olarak kalır.',
    ),
    EntryStatus.conflict => _t(
      'Two versions disagree and neither replaced the other. Keep the right one and mark the other as entered in error.',
      'İki sürüm çelişiyor ve biri diğerinin yerine geçmedi. Doğru olanı tut, diğerini yanlışlıkla girildi olarak işaretle.',
    ),
    EntryStatus.deleted => _t(
      'You deleted this measurement. It no longer counts anywhere and stays only in this history; completely erasing it is not built yet.',
      'Bu ölçümü sildin. Artık hiçbir yerde sayılmıyor ve yalnız bu geçmişte duruyor; tamamen silme henüz yapılmadı.',
    ),
    EntryStatus.enteredInError => _t(
      'Marked as entered in error: it never counted as a real measurement.',
      'Yanlışlıkla girildi olarak işaretlendi: hiçbir zaman gerçek bir ölçüm sayılmaz.',
    ),
  };

  String versionRole({
    required bool isFirst,
    required bool withdrawn,
    required bool current,
  }) {
    final base = isFirst
        ? _t('Original', 'İlk kayıt')
        : _t('Correction', 'Düzeltme');
    if (withdrawn) {
      return '$base · ${_t('withdrawn (entered in error)', 'geri çekildi (yanlışlıkla girildi)')}';
    }
    return current ? '$base · ${_t('current', 'güncel')}' : base;
  }

  String amendAction(AmendReason r) => switch (r) {
    AmendReason.correction => _t('Correct', 'Düzelt'),
    AmendReason.enteredInError => _t('Entered in error', 'Yanlışlıkla girildi'),
    AmendReason.deleted => _t('Delete', 'Sil'),
  };

  String amendTitle(AmendReason r) => switch (r) {
    AmendReason.correction => _t('Correct this value', 'Bu değeri düzelt'),
    AmendReason.enteredInError => _t(
      'Mark as entered in error?',
      'Yanlışlıkla girildi olarak işaretlensin mi?',
    ),
    AmendReason.deleted => _t(
      'Delete this measurement?',
      'Bu ölçüm silinsin mi?',
    ),
  };

  /// The three ways to change a record are different on purpose.
  String amendExplain(AmendReason r) => switch (r) {
    AmendReason.correction => _t(
      'Save a better value for the same measurement. The old value stays in history.',
      'Aynı ölçüm için daha doğru değeri kaydet. Eski değer geçmişte kalır.',
    ),
    AmendReason.enteredInError => _t(
      'Use this when this entry should never have been saved (for example, a whole wrong entry). It stops counting and stays in history marked as withdrawn. If it was a correction, the previous version counts again.',
      'Bu giriş hiç kaydedilmemeliydiyse kullan (ör. tamamen yanlış bir giriş). Sayılmayı bırakır ve geçmişte geri çekildi olarak kalır. Bir düzeltmeyse önceki sürüm yeniden geçerli olur.',
    ),
    AmendReason.deleted => _t(
      'Use this to remove a measurement you no longer want counted. Every version leaves your views; it stays only in history, and a later correction cannot bring it back. Completely erasing it is not built yet.',
      'Artık sayılmasını istemediğin bir ölçümü kaldırmak için kullan. Tüm sürümleri görünümlerinden çıkar; yalnız geçmişte kalır ve sonraki bir düzeltme onu geri getiremez. Tamamen silme henüz yapılmadı.',
    ),
  };

  // Your data (F005): backups and exports.
  String get dataNotAvailable => _t(
    'Backups are made from saved data. Nothing is saved in this session, so there is nothing to back up or export.',
    'Yedekler kayıtlı verilerden yapılır. Bu oturumda hiçbir şey kaydedilmiyor; yedeklenecek ya da dışa aktarılacak bir şey yok.',
  );
  String get dataEncrypted => _t(
    'Backups are encrypted like the vault: each opens only with the passphrase or recovery key the vault had when it was made.',
    'Yedekler kasa gibi şifrelidir: her biri yalnız, yapıldığı anda kasanın sahip olduğu parola ya da kurtarma anahtarıyla açılır.',
  );
  String get exportNotForEncrypted => _t(
    'Export writes an unencrypted file, so it is not offered for the encrypted vault yet.',
    'Dışa aktarma şifresiz bir dosya yazar; bu yüzden şifreli kasa için henüz sunulmuyor.',
  );
  String get dataUnencrypted => _t(
    'Backups and exports are not encrypted yet (development build). Keep the files private.',
    'Yedekler ve dışa aktarımlar henüz şifreli değil (geliştirme derlemesi). Dosyaları gizli tut.',
  );
  String get createBackup => _t('Create backup', 'Yedek oluştur');
  String get exportJson =>
      _t('Export records (JSON)', 'Kayıtları dışa aktar (JSON)');
  String savedTo(String where) => _t('Saved: $where', 'Kaydedildi: $where');
  String get savedInApp => _t(
    'Saved inside the app on this phone. To keep it somewhere else too (Downloads, a cloud folder, a USB drive), save a copy.',
    'Bu telefonda uygulamanın içine kaydedildi. Başka bir yerde de tutmak için (İndirilenler, bir bulut klasörü, USB bellek) bir kopyasını kaydet.',
  );
  String get copyNotEncrypted => _t(
    'This file is not encrypted: anyone who can open the place you choose can read it.',
    'Bu dosya şifreli değil: seçtiğin yeri açabilen herkes okuyabilir.',
  );
  String get saveCopy => _t(
    'Save a copy where I can find it',
    'Bulabileceğim bir yere kopyasını kaydet',
  );
  String copySaved(String name) =>
      _t('Copy saved: $name', 'Kopya kaydedildi: $name');
  String get backupsTitle =>
      _t('Backups on this device', 'Bu cihazdaki yedekler');
  String get noBackups => _t('No backups yet.', 'Henüz yedek yok.');
  String get checkBackup => _t('Check', 'Kontrol et');
  String get restoreBackup => _t('Restore', 'Geri yükle');
  String get browserRestoreNotBuilt => _t(
    'In the browser a backup downloads as a file. Restoring it here is not built yet.',
    'Tarayıcıda yedek bir dosya olarak iner. Burada geri yükleme henüz yapılmadı.',
  );
  String backupChecked(int records, int profiles, String made) => _t(
    'Checked: $records records and $profiles profiles, checksum matches. Made $made.',
    'Kontrol edildi: $records kayıt ve $profiles profil, sağlama toplamı eşleşiyor. Oluşturma: $made.',
  );
  String backupCheckedEncrypted(int records, String made) => _t(
    'Checked: checksum matches; encrypted; $records records according to its description. The content itself is verified when you restore it with its passphrase or recovery key. Made $made.',
    'Kontrol edildi: sağlama toplamı eşleşiyor; şifreli; tanımına göre $records kayıt. İçeriğin kendisi, yedek parolası ya da kurtarma anahtarıyla geri yüklenirken doğrulanır. Oluşturma: $made.',
  );
  String get openBackupTitle => _t('Open this backup', 'Bu yedeği aç');
  String get openBackupExplain => _t(
    'Enter the passphrase of the vault this backup was made from, as it was then, or that vault\'s recovery key. A vault created later has other keys. The backup is opened and checked in memory before anything is written.',
    'Bu yedeğin alındığı kasanın o zamanki parolasını ya da o kasanın kurtarma anahtarını gir. Sonradan oluşturulan bir kasanın anahtarları farklıdır. Yedek, hiçbir şey yazılmadan önce bellekte açılır ve kontrol edilir.',
  );
  String dataFileFailed(String code) => _t(
    'That did not work ($code). Nothing was changed.',
    'Bu işlem yapılamadı ($code). Hiçbir şey değişmedi.',
  );
  String get useRecoveryKeyInstead => _t(
    'Use the recovery key instead',
    'Bunun yerine kurtarma anahtarını kullan',
  );
  String restoredEncrypted(int n, String? keptAt) =>
      _t(
        'Restored $n records. Close and reopen Human OS, then unlock it with the backup\'s passphrase or recovery key.',
        '$n kayıt geri yüklendi. Human OS\'u kapatıp yeniden aç, sonra yedeğin parolası ya da kurtarma anahtarıyla kilidini aç.',
      ) +
      (keptAt == null
          ? ''
          : _t(
              ' The previous vault file was kept at $keptAt.',
              ' Önceki kasa dosyası şurada saklandı: $keptAt.',
            ));
  String get restartToUse => _t(
    'A restore ran in this session: close and reopen Human OS before going on. Saving, backups and exports are paused until then.',
    'Bu oturumda bir geri yükleme çalıştı: devam etmeden önce Human OS\'u kapatıp yeniden aç. O zamana kadar kayıt, yedek ve dışa aktarma durduruldu.',
  );
  String get restoreTitle =>
      _t('Restore this backup?', 'Bu yedek geri yüklensin mi?');
  String get restoreExplain => _t(
    'The backup is checked again, written beside your data, read back and only then used. The current data file is kept, not deleted. A restore never replaces records: it is refused while this device holds any.',
    'Yedek yeniden kontrol edilir, verilerinin yanına yazılır, geri okunur ve ancak ondan sonra kullanılır. Mevcut veri dosyası saklanır, silinmez. Geri yükleme kayıtların yerine geçmez: bu cihazda kayıt varken reddedilir.',
  );
  String restored(int n, String? keptAt) =>
      _t(
        'Restored $n records. Close and reopen Human OS to use them.',
        '$n kayıt geri yüklendi. Kullanmak için Human OS\'u kapatıp yeniden aç.',
      ) +
      (keptAt == null
          ? ''
          : _t(
              ' The previous data file was kept at $keptAt.',
              ' Önceki veri dosyası şurada saklandı: $keptAt.',
            ));
  String backupError(String code, [String? detail]) => switch (code) {
    'DIGEST_MISMATCH' => _t(
      'This backup is damaged: its content does not match its checksum. Nothing was changed.',
      'Bu yedek bozuk: içeriği sağlama toplamıyla eşleşmiyor. Hiçbir şey değişmedi.',
    ),
    'BACKUP_NEWER' => _t(
      'This backup was made by a newer Human OS. Update the app to use it.',
      'Bu yedek daha yeni bir Human OS ile yapılmış. Kullanmak için uygulamayı güncelle.',
    ),
    'BACKUP_ENCRYPTED_UNSUPPORTED' => _t(
      'This backup uses an encryption this version cannot open. Nothing was changed.',
      'Bu yedek, bu sürümün açamadığı bir şifreleme kullanıyor. Hiçbir şey değişmedi.',
    ),
    'BACKUP_KEY_WRONG' => _t(
      'This passphrase or recovery key does not open the backup. Nothing was changed.',
      'Bu parola ya da kurtarma anahtarı yedeği açmıyor. Hiçbir şey değişmedi.',
    ),
    'BACKUP_KIND_MISMATCH' => _t(
      'This backup and this vault are not the same kind (encrypted or not), so it cannot be restored here. Nothing was changed.',
      'Bu yedek ile bu kasa aynı türde değil (şifreli ya da değil); bu yüzden burada geri yüklenemez. Hiçbir şey değişmedi.',
    ),
    'RESTORE_TARGET_NEWER' => _t(
      'The data on this device was written by a newer Human OS. Restoring would hide it, so it was not done.',
      'Bu cihazdaki veriler daha yeni bir Human OS ile yazılmış. Geri yükleme onları gizleyeceği için yapılmadı.',
    ),
    'RESTORE_TARGET_HAS_RECORDS' => _t(
      'This device already holds records. Restoring would replace them, so it was not done.',
      'Bu cihazda zaten kayıt var. Geri yükleme onların yerine geçeceği için yapılmadı.',
    ),
    'VAULT_INCOMPATIBLE' => _t(
      'The data in this backup cannot be read by this version (${detail ?? '?'}). Nothing was changed.',
      'Bu yedekteki veriler bu sürümle okunamıyor (${detail ?? '?'}). Hiçbir şey değişmedi.',
    ),
    'COUNT_MISMATCH' || 'VAULT_ID_MISMATCH' => _t(
      'This backup does not match its own description. Nothing was changed.',
      'Bu yedek kendi tanımıyla uyuşmuyor. Hiçbir şey değişmedi.',
    ),
    'RESTORE_NOT_SWITCHED' => _t(
      'The restore could not be finished: the data files could not be moved (another program may be using them). Nothing was changed on disk. Saving stays paused until Human OS restarts.',
      'Geri yükleme tamamlanamadı: veri dosyaları taşınamadı (başka bir program kullanıyor olabilir). Diskte hiçbir şey değişmedi. Human OS yeniden başlayana kadar kayıt durduruldu.',
    ),
    'RESTORE_SWITCH_FAILED' when detail == null || detail.isEmpty => _t(
      'The restore could not be finished: the restored copy could not be moved into place. The previous data file is back where it was. Restart Human OS before saving anything.',
      'Geri yükleme tamamlanamadı: geri yüklenen kopya yerine taşınamadı. Önceki veri dosyası eski yerinde. Bir şey kaydetmeden önce Human OS\'u yeniden başlat.',
    ),
    'RESTORE_SWITCH_FAILED' => _t(
      'The restore could not be finished: the restored copy could not be moved into place, and the previous data file is now at $detail. Nothing was deleted. Restart Human OS before saving anything.',
      'Geri yükleme tamamlanamadı: geri yüklenen kopya yerine taşınamadı; önceki veri dosyası şimdi şurada: $detail. Hiçbir şey silinmedi. Bir şey kaydetmeden önce Human OS\'u yeniden başlat.',
    ),
    'RESTORE_VERIFY_FAILED' => _t(
      'The restored copy did not read back identically. Nothing was changed.',
      'Geri yüklenen kopya aynı şekilde geri okunamadı. Hiçbir şey değişmedi.',
    ),
    _ => _t(
      'This file is not a readable Human OS backup. Nothing was changed.',
      'Bu dosya okunabilir bir Human OS yedeği değil. Hiçbir şey değişmedi.',
    ),
  };

  // The vault gate (F006): create, unlock, recover; key lost; unreadable.
  String get gateCreateTitle =>
      _t('Protect your health data', 'Sağlık verilerini koru');
  String get gateCreateBody => _t(
    'Human OS keeps your records in an encrypted vault on this device. Choose a passphrase: it is needed every time the app starts, and nobody can reset it for you.',
    'Human OS kayıtlarını bu cihazda şifreli bir kasada tutar. Bir parola seç: uygulama her açıldığında gerekir ve kimse onu senin yerine sıfırlayamaz.',
  );
  String get passphrase => _t('Passphrase', 'Parola');
  String get passphraseRepeat =>
      _t('Repeat the passphrase', 'Parolayı tekrar yaz');
  String passphraseHint(int n) => _t(
    'At least $n characters. A few unrelated words are easy to remember and hard to guess.',
    'En az $n karakter. Birbiriyle ilgisiz birkaç kelime hem kolay hatırlanır hem zor tahmin edilir.',
  );
  String passphraseTooShort(int n) =>
      _t('Use at least $n characters.', 'En az $n karakter kullan.');
  String get passphrasesDiffer =>
      _t('The two passphrases differ.', 'İki parola birbirini tutmuyor.');
  String get showPassphrase => _t('Show passphrase', 'Parolayı göster');
  String get gateContinue => _t('Continue', 'Devam');
  String get gateBack => _t('Back', 'Geri');
  String get gateMemoryOnly => _t(
    'Not now: keep this session in memory only',
    'Şimdi değil: bu oturumu yalnız bellekte tut',
  );
  String get recoveryKeyTitle => _t('Your recovery key', 'Kurtarma anahtarın');
  String get recoveryKeyBody => _t(
    'If you forget the passphrase, this key is the only other way into the vault. Write it down and keep it somewhere safe, away from this device. It is shown only now. Anyone who has it can open your vault.',
    'Parolayı unutursan kasaya girmenin tek diğer yolu bu anahtardır. Bir yere yaz ve bu cihazdan uzakta, güvenli bir yerde sakla. Yalnız şimdi gösteriliyor. Ona sahip olan herkes kasanı açabilir.',
  );
  String get recoveryKeySaved => _t(
    'I have written down the recovery key',
    'Kurtarma anahtarını bir yere yazdım',
  );
  String get createVault =>
      _t('Create the encrypted vault', 'Şifreli kasayı oluştur');
  String get derivingKey => _t(
    'Working on the key. This takes a moment.',
    'Anahtar hazırlanıyor. Bu biraz sürer.',
  );
  String get unlockTitle => _t('Unlock your vault', 'Kasanın kilidini aç');
  String get unlockBody => _t(
    'Enter the passphrase of the encrypted vault on this device.',
    'Bu cihazdaki şifreli kasanın parolasını gir.',
  );
  String get unlock => _t('Unlock', 'Kilidi aç');
  String get wrongPassphrase => _t(
    'This passphrase did not open the vault. Check it and try again, or use the recovery key.',
    'Bu parola kasayı açmadı. Kontrol edip tekrar dene ya da kurtarma anahtarını kullan.',
  );
  String get useRecoveryKey => _t(
    'Forgot the passphrase? Use the recovery key',
    'Parolayı mı unuttun? Kurtarma anahtarını kullan',
  );
  String get recoverTitle =>
      _t('Recover with the recovery key', 'Kurtarma anahtarıyla kurtar');
  String get recoverBody => _t(
    'Enter the recovery key you wrote down when the vault was created, and choose a new passphrase. The old passphrase will no longer open this vault.',
    'Kasa oluşturulurken yazdığın kurtarma anahtarını gir ve yeni bir parola seç. Eski parola artık bu kasayı açmayacak.',
  );
  String get recoveryKeyLabel => _t('Recovery key', 'Kurtarma anahtarı');
  String get newPassphrase => _t('New passphrase', 'Yeni parola');
  String get newPassphraseRepeat =>
      _t('Repeat the new passphrase', 'Yeni parolayı tekrar yaz');
  String get recoverButton =>
      _t('Open and set the new passphrase', 'Aç ve yeni parolayı kaydet');
  String get wrongRecoveryKey => _t(
    'This recovery key did not open the vault.',
    'Bu kurtarma anahtarı kasayı açmadı.',
  );
  String get recoveryKeyFormat => _t(
    'A recovery key has 32 letters and digits (A–Z and 2–7), written in groups of four.',
    'Bir kurtarma anahtarında 32 harf ve rakam (A–Z ve 2–7) vardır; dörderli gruplar hâlinde yazılır.',
  );
  String get lostBoth => _t('I have lost both', 'İkisini de kaybettim');
  String get keyLostTitle => _t(
    'Without the passphrase or the recovery key',
    'Parola ya da kurtarma anahtarı olmadan',
  );
  String get keyLostBody => _t(
    'The vault on this device is encrypted. Without its passphrase or recovery key nobody can open it: not you, not Human OS, not its developers. Human OS will not open it, reset it or delete it. A backup helps only if you know that backup\'s passphrase or recovery key.',
    'Bu cihazdaki kasa şifreli. Parolası ya da kurtarma anahtarı olmadan onu kimse açamaz: ne sen, ne Human OS, ne de geliştiricileri. Human OS onu açmaz, sıfırlamaz, silmez. Bir yedek ancak o yedeğin parolasını ya da kurtarma anahtarını biliyorsan işe yarar.',
  );
  String get backToUnlock => _t('Back to unlock', 'Kilit açmaya dön');
  String get startNewVault => _t(
    'Keep the locked vault and start a new one',
    'Kilitli kasayı sakla ve yeni bir kasa başlat',
  );
  String get startNewTitle =>
      _t('Start a new vault?', 'Yeni bir kasa başlatılsın mı?');
  String get startNewBody => _t(
    'The current vault file is kept on this device under a new name. Nothing is deleted. A new, empty vault is created next.',
    'Mevcut kasa dosyası bu cihazda yeni bir adla saklanır. Hiçbir şey silinmez. Ardından yeni, boş bir kasa oluşturulur.',
  );
  String vaultKeptAt(String path) => _t(
    'The previous vault was kept as $path.',
    'Önceki kasa şu adla saklandı: $path.',
  );
  String get unreadableTitle =>
      _t('The saved vault cannot be opened', 'Kayıtlı kasa açılamıyor');
  String unreadableBody(String code) => code == 'VAULT_READ_FAILED'
      ? _t(
          'The vault file could not be read: another program may be using it, or your user may not be allowed to read it. It was not changed. Close Human OS and try again, or keep this session in memory only.',
          'Kasa dosyası okunamadı: başka bir program onu kullanıyor olabilir ya da kullanıcının onu okuma izni olmayabilir. Dosya değiştirilmedi. Human OS\'u kapatıp tekrar dene ya da bu oturumu yalnız bellekte tut.',
        )
      : const {
          'ENVELOPE_NEWER',
          'VAULT_NEWER',
          'RECORD_SCHEMA_NEWER',
        }.contains(code)
      ? _t(
          'It was written by a newer version of Human OS. Update the app to open it. The file was not changed.',
          'Human OS\'un daha yeni bir sürümüyle yazılmış. Açmak için uygulamayı güncelle. Dosya değiştirilmedi.',
        )
      : _t(
          'The vault file is damaged or not a Human OS vault ($code). It was not changed.',
          'Kasa dosyası hasarlı ya da bir Human OS kasası değil ($code). Dosya değiştirilmedi.',
        );
  String passphraseReplacedNotOpened(String code) => _t(
    'The new passphrase is set, but the vault could not be opened ($code). Unlock it with the new passphrase.',
    'Yeni parola ayarlandı ama kasa açılamadı ($code). Yeni parolayla kilidini aç.',
  );
  String vaultCreatedNotOpened(String code) => _t(
    'The vault was created, but it could not be opened ($code). Unlock it with the passphrase you just chose.',
    'Kasa oluşturuldu ama açılamadı ($code). Az önce seçtiğin parolayla kilidini aç.',
  );
  String gateFailed(String code) => _t(
    'Something went wrong ($code). Nothing was changed.',
    'Bir şey ters gitti ($code). Hiçbir şey değiştirilmedi.',
  );

  String storageLabel(String durability, bool encrypted) {
    final enc = encrypted
        ? _t(' · encrypted', ' · şifreli')
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
