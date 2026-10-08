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
    'FUTURE_TIME' => _t('This date is in the future.', 'Bu tarih gelecekte.'),
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
  String get saveCorrection => _t('Save correction', 'Düzeltmeyi kaydet');

  String recordKind(RecordKind k) => switch (k) {
    RecordKind.bodyWeight => _t('Body weight', 'Vücut ağırlığı'),
    RecordKind.labResult => _t('Lab result', 'Lab sonucu'),
  };

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
