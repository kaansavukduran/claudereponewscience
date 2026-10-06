// EDU-HEALTH-LITERACY-FOUNDATION-1 — offline, non-diagnostic, bilingual (EN/TR).
// Viewed ≠ understood; quiz completion ≠ health improvement; learning XP ≠ health score.

export type Lang = 'en' | 'tr';
export type Text = Record<Lang, string>;

export interface Mcq {
  q: Text;
  options: Text[];
  correct: number;
  why: Text;
}

export interface Lesson {
  id: string;
  title: Text;
  body: Text;
  example: Text;
  quiz: [Mcq, Mcq];
  transfer: { q: Text; a: Text };
}

export const EDUCATION_PACK = { packId: 'EDU-HEALTH-LITERACY-FOUNDATION-1', version: '1.0.0', status: 'BUNDLE_DEFAULT' } as const;

const t = (en: string, tr: string): Text => ({ en, tr });
const yesNo = [t('Yes', 'Evet'), t('No', 'Hayır')];

export const LESSONS: Lesson[] = [
  {
    id: 'EDU-001',
    title: t('Measurement, fact and interpretation', 'Ölçüm, olgu ve yorum'),
    body: t('A measured value, its source, its unit and what it might mean are four different things. The app stores them separately so an interpretation can change without rewriting what was measured.', 'Ölçülen değer, kaynağı, birimi ve ne anlama gelebileceği dört ayrı şeydir. Uygulama bunları ayrı saklar; böylece yorum değişse bile ölçülen değer yeniden yazılmaz.'),
    example: t('"Weight 78 kg, entered manually on 2 Oct" is a fact. "BMI 26.4" is a derived result. Any judgement about it is interpretation.', '"Kilo 78 kg, 2 Ekim\'de elle girildi" bir olgudur. "BMİ 26,4" türetilmiş sonuçtur. Onun hakkındaki her hüküm yorumdur.'),
    quiz: [
      { q: t('Which part is the interpretation?', 'Hangisi yorumdur?'), options: [t('78 kg', '78 kg'), t('Entered manually', 'Elle girildi'), t('"This is concerning"', '"Bu endişe verici"')], correct: 2, why: t('Value and source are facts; a judgement is interpretation.', 'Değer ve kaynak olgudur; hüküm yorumdur.') },
      { q: t('Should a new interpretation rewrite the stored value?', 'Yeni bir yorum kayıtlı değeri değiştirmeli mi?'), options: yesNo, correct: 1, why: t('Facts stay; interpretations are versioned separately.', 'Olgu kalır; yorumlar ayrı sürümlenir.') },
    ],
    transfer: { q: t('A wearable says "stress high". Fact or interpretation?', 'Saat "stres yüksek" diyor. Olgu mu yorum mu?'), a: t('An interpretation (a device algorithm), built on sensor facts.', 'Yorum (cihaz algoritması); sensör olgularına dayanır.') },
  },
  {
    id: 'EDU-002',
    title: t('Missing does not mean zero', 'Eksik, sıfır demek değildir'),
    body: t('Missing, not measured, not applicable and zero are four different states. Turning a missing value into 0 silently changes every average, total and score.', 'Eksik, ölçülmedi, uygulanamaz ve sıfır dört ayrı durumdur. Eksik bir değeri sessizce 0 yapmak her ortalamayı, toplamı ve skoru değiştirir.'),
    example: t('A food label without vitamin B12 does not mean the food has 0 µg; it means the label did not report it.', 'B12 yazmayan bir etiket besinde 0 µg olduğu anlamına gelmez; etiket bunu bildirmemiştir.'),
    quiz: [
      { q: t('A result is absent from a lab report. What should the app store?', 'Bir sonuç lab raporunda yok. Uygulama ne saklamalı?'), options: [t('0', '0'), t('NOT_REPORTED (missing state)', 'NOT_REPORTED (eksik durumu)'), t('The last known value', 'Bilinen son değer')], correct: 1, why: t('Zero is a measurement; absence is a state.', 'Sıfır bir ölçümdür; yokluk bir durumdur.') },
      { q: t('Steps are missing for 2 of 7 days. Average over…', '7 günün 2\'sinde adım eksik. Ortalama…'), options: [t('7 days with zeros', 'sıfırlarla 7 gün'), t('5 known days, coverage shown', 'bilinen 5 gün, kapsam gösterilerek')], correct: 1, why: t('Known values only, with explicit coverage.', 'Yalnız bilinen değerler, kapsam açıkça gösterilir.') },
    ],
    transfer: { q: t('Your sleep tracker was off one night. What should the weekly chart show for that night?', 'Uyku takipçin bir gece kapalıydı. Haftalık grafik o gece için ne göstermeli?'), a: t('A gap/“no data” marker, not a 0-hour bar.', '0 saatlik çubuk değil, boşluk/"veri yok" işareti.') },
  },
  {
    id: 'EDU-003',
    title: t('Source and provenance', 'Kaynak ve köken (provenance)'),
    body: t('Manual entry, a wearable, a laboratory report, an imported document and a derived calculation have different reliability and context. Provenance tells you where a value came from.', 'Elle giriş, giyilebilir cihaz, laboratuvar raporu, içe aktarılmış belge ve türetilmiş hesap farklı güvenilirlik ve bağlama sahiptir. Köken bilgisi değerin nereden geldiğini söyler.'),
    example: t('Resting HR 54 from a watch and 54 from a clinic ECG are the same number with different provenance.', 'Saatten gelen dinlenik nabız 54 ile klinik EKG\'den gelen 54 aynı sayıdır ama kökenleri farklıdır.'),
    quiz: [
      { q: t('Is BMI a measured fact?', 'BMİ ölçülmüş bir olgu mu?'), options: yesNo, correct: 1, why: t('It is derived from weight and height.', 'Kilo ve boydan türetilir.') },
      { q: t('Two sources report steps for the same hour. Should the app add them?', 'Aynı saat için iki kaynak adım bildiriyor. Uygulama toplamalı mı?'), options: yesNo, correct: 1, why: t('Overlapping sources are deduplicated by policy, never blindly summed.', 'Çakışan kaynaklar politika ile tekilleştirilir, körce toplanmaz.') },
    ],
    transfer: { q: t('A PDF parser reads "LDL 130". Is that already a health record?', 'PDF okuyucu "LDL 130" buldu. Bu artık sağlık kaydı mı?'), a: t('No — it is a staged candidate until you review and commit it.', 'Hayır — sen inceleyip onaylayana kadar aday kayıttır.') },
  },
  {
    id: 'EDU-004',
    title: t('Units matter', 'Birimler önemlidir'),
    body: t('mg/dL and mmol/L, kg and lb, cm and in cannot be swapped freely. Some conversions need analyte-specific factors; some (mL → g) need density.', 'mg/dL ile mmol/L, kg ile lb, cm ile inç serbestçe değiştirilemez. Bazı dönüşümler analite özgü katsayı, bazıları (mL → g) yoğunluk ister.'),
    example: t('250 mL of a drink is not 250 g unless density is known.', '250 mL içecek, yoğunluk bilinmeden 250 g değildir.'),
    quiz: [
      { q: t('Can the app convert mL to g without density?', 'Uygulama yoğunluk olmadan mL\'yi g\'ye çevirebilir mi?'), options: yesNo, correct: 1, why: t('Blocked until an explicit density/measure exists.', 'Açık yoğunluk/ölçü olana kadar engellenir.') },
      { q: t('Waist in inches, height in cm. Compute waist/height directly?', 'Bel inç, boy cm. Doğrudan bel/boy oranı?'), options: yesNo, correct: 1, why: t('Same-unit inputs are required.', 'Aynı birimde girdiler gerekir.') },
    ],
    transfer: { q: t('500 mcg + 1 mg of the same ingredient on the same basis?', 'Aynı bazda aynı bileşenden 500 mcg + 1 mg?'), a: t('1.5 mg — mass units of identical basis convert safely.', '1,5 mg — aynı bazdaki kütle birimleri güvenle çevrilir.') },
  },
  {
    id: 'EDU-005',
    title: t('Reference interval vs personal baseline', 'Referans aralığı ve kişisel bazal'),
    body: t('A lab reference interval describes a reference population for a specific method. Your personal baseline is your own history. A value can be inside the interval yet unusual for you — or outside and stable for you.', 'Lab referans aralığı belirli bir yöntem için bir referans popülasyonu tanımlar. Kişisel bazal senin geçmişindir. Bir değer aralık içinde ama sana göre olağandışı, ya da aralık dışında ama sana göre sabit olabilir.'),
    example: t('Synthetic analyte: history ≈ 9, today 7, interval 4–10 → within reference, but an unusual personal change.', 'Sentetik analit: geçmiş ≈ 9, bugün 7, aralık 4–10 → referans içinde, ama kişisel olarak olağandışı değişim.'),
    quiz: [
      { q: t('Is a reference interval an optimal target?', 'Referans aralığı optimal hedef midir?'), options: yesNo, correct: 1, why: t('Reference interval ≠ optimal target ≠ decision limit.', 'Referans aralığı ≠ optimal hedef ≠ karar sınırı.') },
      { q: t('Outside the reference interval means critical?', 'Referans dışı demek kritik mi?'), options: yesNo, correct: 1, why: t('Critical results need a separate source-defined rule.', 'Kritik sonuç ayrı, kaynak tanımlı bir kural gerektirir.') },
    ],
    transfer: { q: t('The lab changed method between two tests. Draw one smooth trend line?', 'İki test arasında lab yöntem değiştirdi. Tek düzgün trend çizgisi çizilir mi?'), a: t('No — mark a method discontinuity unless comparability is reviewed.', 'Hayır — karşılaştırılabilirlik incelenmedikçe yöntem kopukluğu işaretlenir.') },
  },
  {
    id: 'EDU-006',
    title: t('Population baseline vs personal prediction', 'Popülasyon bazalı ve kişisel tahmin'),
    body: t('Life expectancy and HALE describe populations by place and year. They are not a promise about one person.', 'Yaşam beklentisi ve HALE yer ve yıla göre popülasyonları tanımlar. Tek bir kişi hakkında vaat değildir.'),
    example: t('"Remaining life expectancy at 40 in country X, 2021" is a population statistic with a source and year.', '"X ülkesinde 2021\'de 40 yaşında kalan yaşam beklentisi" kaynaklı ve yıllı bir popülasyon istatistiğidir.'),
    quiz: [
      { q: t('Can a population table give your personal age at death?', 'Popülasyon tablosu senin kişisel ölüm yaşını verebilir mi?'), options: yesNo, correct: 1, why: t('It is a baseline, not a personal prediction.', 'Bazaldır, kişisel tahmin değil.') },
      { q: t('What must a population baseline always show?', 'Popülasyon bazalı her zaman neyi göstermeli?'), options: [t('Source, geography and year', 'Kaynak, coğrafya ve yıl'), t('A colour', 'Bir renk')], correct: 0, why: t('Metadata makes it interpretable.', 'Meta veri onu yorumlanabilir kılar.') },
    ],
    transfer: { q: t('Why does this demo show no "expected age"?', 'Bu demo neden "beklenen yaş" göstermiyor?'), a: t('No population pack or validated survival model is active, so nothing is manufactured.', 'Aktif popülasyon paketi ya da doğrulanmış sağkalım modeli yok; hiçbir şey uydurulmaz.') },
  },
  {
    id: 'EDU-007',
    title: t('Risk probability', 'Risk olasılığı'),
    body: t('A risk estimate has an endpoint (what event), a horizon (how many years) and an eligible population. Without all three, a percentage is meaningless.', 'Risk tahmininin bir sonlanımı (hangi olay), ufku (kaç yıl) ve uygun popülasyonu vardır. Üçü olmadan yüzde anlamsızdır.'),
    example: t('"10-year cardiovascular event risk, ages 30–79, model version X" is well-defined.', '"10 yıllık kardiyovasküler olay riski, 30–79 yaş, model sürümü X" iyi tanımlıdır.'),
    quiz: [
      { q: t('A calculator is NOT_ELIGIBLE for a profile. Show an estimated % anyway?', 'Hesaplayıcı profil için NOT_ELIGIBLE. Yine de tahmini % gösterilsin mi?'), options: yesNo, correct: 1, why: t('Ineligible means no number.', 'Uygun değilse sayı yok.') },
      { q: t('Which is part of a risk definition?', 'Hangisi risk tanımının parçasıdır?'), options: [t('Horizon', 'Ufuk'), t('App colour theme', 'Uygulama renk teması')], correct: 0, why: t('Endpoint + horizon + population.', 'Sonlanım + ufuk + popülasyon.') },
    ],
    transfer: { q: t('Two models give 8% and 12%. Average them?', 'İki model %8 ve %12 veriyor. Ortalaması alınır mı?'), a: t('No — different models/endpoints stay separate outputs.', 'Hayır — farklı model/sonlanımlar ayrı çıktılar olarak kalır.') },
  },
  {
    id: 'EDU-008',
    title: t('Validated clinical result vs app score', 'Doğrulanmış klinik sonuç ve uygulama skoru'),
    body: t('Protection, Burden and Function 0–100 are app-defined summaries with visible weights. They are not probabilities, diagnoses or years of life.', 'Koruma, Yük ve İşlev 0–100 görünür ağırlıklı, uygulamanın tanımladığı özetlerdir. Olasılık, tanı ya da yaşam yılı değildir.'),
    example: t('Burden 70 does not mean 70% mortality or 7 years lost.', 'Yük 70; %70 ölüm ya da 7 yıl kayıp demek değildir.'),
    quiz: [
      { q: t('Can Burden be converted into years lost?', 'Yük skoru kayıp yıla çevrilebilir mi?'), options: yesNo, correct: 1, why: t('Only an applicable validated survival model could do that.', 'Bunu yalnız uygun, doğrulanmış bir sağkalım modeli yapabilir.') },
      { q: t('Balance = Protection − Burden. Show Balance alone?', 'Denge = Koruma − Yük. Denge tek başına gösterilir mi?'), options: yesNo, correct: 1, why: t('Both source channels stay visible.', 'İki kaynak kanal görünür kalır.') },
    ],
    transfer: { q: t('A skin cream improves skin symptoms. Add +2 life years?', 'Bir krem cilt belirtilerini iyileştiriyor. +2 yaşam yılı eklenir mi?'), a: t('No — domain change ≠ lifespan change.', 'Hayır — alan değişimi ≠ yaşam süresi değişimi.') },
  },
  {
    id: 'EDU-009',
    title: t('Correlation vs causation', 'Korelasyon ve nedensellik'),
    body: t('Two things moving together, or one following another, does not prove one caused the other. Confounders, chance and reverse causation are common.', 'İki şeyin birlikte değişmesi ya da birinin diğerini izlemesi, birinin diğerine neden olduğunu kanıtlamaz. Karıştırıcılar, şans ve ters nedensellik yaygındır.'),
    example: t('Better sleep on workout days might be due to weekends, not the workouts.', 'Antrenman günlerinde daha iyi uyku hafta sonundan kaynaklanıyor olabilir.'),
    quiz: [
      { q: t('Your mood improved after starting a supplement. Proven cause?', 'Takviyeye başladıktan sonra ruh halin düzeldi. Neden kanıtlandı mı?'), options: yesNo, correct: 1, why: t('Temporal order alone is not causation.', 'Yalnız zaman sırası nedensellik değildir.') },
      { q: t('Which helps test causation?', 'Nedenselliği test etmeye hangisi yardım eder?'), options: [t('Randomised comparison', 'Randomize karşılaştırma'), t('A single anecdote', 'Tek bir anekdot')], correct: 0, why: t('Controlled comparisons reduce confounding.', 'Kontrollü karşılaştırma karıştırıcıları azaltır.') },
    ],
    transfer: { q: t('How would an N-of-1 experiment reduce bias?', 'N-of-1 deneyi yanlılığı nasıl azaltır?'), a: t('Planned baseline/intervention/washout periods with pre-declared outcomes.', 'Önceden belirlenmiş sonuçlarla planlı bazal/müdahale/arınma dönemleri.') },
  },
  {
    id: 'EDU-010',
    title: t('Plan vs completed behaviour', 'Plan ve tamamlanan davranış'),
    body: t('A scheduled workout, reminder or medication plan is not proof that it happened. Only a completion event counts.', 'Planlanmış antrenman, hatırlatıcı ya da ilaç planı gerçekleştiğinin kanıtı değildir. Yalnız tamamlanma olayı sayılır.'),
    example: t('"Bench Press 3 × 10 @ 30 kg" is a plan until the completed sets are logged.', '"Bench Press 3 × 10 @ 30 kg" tamamlanan setler girilene kadar plandır.'),
    quiz: [
      { q: t('A reminder notification was opened. Mission complete?', 'Hatırlatma bildirimi açıldı. Görev tamam mı?'), options: yesNo, correct: 1, why: t('Opening ≠ doing.', 'Açmak ≠ yapmak.') },
      { q: t('Do planned sets count toward volume load?', 'Planlanan setler hacim yüküne sayılır mı?'), options: yesNo, correct: 1, why: t('Only completed sets.', 'Yalnız tamamlanan setler.') },
    ],
    transfer: { q: t('You missed yesterday\'s optional walk. Double it today?', 'Dünkü isteğe bağlı yürüyüşü kaçırdın. Bugün iki katı mı?'), a: t('No — missed optional tasks are not stacked.', 'Hayır — kaçırılan isteğe bağlı görevler yığılmaz.') },
  },
  {
    id: 'EDU-011',
    title: t('Scenario vs observed body', 'Senaryo ve gözlenen beden'),
    body: t('A scenario clone is a hypothetical calculation. Changing it never rewrites the source profile or its history.', 'Senaryo klonu varsayımsal bir hesaptır. Onu değiştirmek kaynak profili ya da geçmişini asla yeniden yazmaz.'),
    example: t('Scenario "−20 kg" recalculates BMI, but no weight record is created.', '"−20 kg" senaryosu BMİ\'yi yeniden hesaplar ama kilo kaydı oluşmaz.'),
    quiz: [
      { q: t('Is a scenario result an observed fact?', 'Senaryo sonucu gözlenmiş olgu mu?'), options: yesNo, correct: 1, why: t('It is labelled hypothetical.', 'Varsayımsal olarak etiketlenir.') },
      { q: t('Does lowering a biomarker in a scenario prove a treatment works?', 'Senaryoda bir biyobelirteci düşürmek tedavinin işe yaradığını kanıtlar mı?'), options: yesNo, correct: 1, why: t('Math recalculation ≠ evidence-supported effect.', 'Matematiksel yeniden hesap ≠ kanıta dayalı etki.') },
    ],
    transfer: { q: t('What should "Reset scenario" do?', '"Senaryoyu sıfırla" ne yapmalı?'), a: t('Copy the source inputs back into the scenario; never touch the source.', 'Kaynak girdileri senaryoya geri kopyalamalı; kaynağa dokunmamalı.') },
  },
  {
    id: 'EDU-012',
    title: t('Healthspan vs lifespan', 'Sağlıklı yaşam süresi ve yaşam süresi'),
    body: t('Lifespan is how long; healthspan is how long with preserved function and quality of life. They are related but distinct.', 'Yaşam süresi ne kadar uzun; sağlıklı yaşam süresi işlev ve yaşam kalitesi korunarak ne kadar uzun yaşandığıdır. İlişkili ama farklıdır.'),
    example: t('Mobility and pain are healthspan data even when they do not change mortality estimates.', 'Hareketlilik ve ağrı, ölüm tahminini değiştirmese bile sağlıklı yaşam verisidir.'),
    quiz: [
      { q: t('Is the Function channel a lifespan estimate?', 'İşlev kanalı yaşam süresi tahmini mi?'), options: yesNo, correct: 1, why: t('It tracks capacity, not years.', 'Kapasiteyi izler, yılı değil.') },
      { q: t('Can healthspan improve without lifespan data changing?', 'Yaşam süresi verisi değişmeden sağlıklı yaşam iyileşebilir mi?'), options: yesNo, correct: 0, why: t('Yes — function and quality of life are their own outcomes.', 'Evet — işlev ve yaşam kalitesi ayrı sonuçlardır.') },
    ],
    transfer: { q: t('Which channel would rehab after an injury show first?', 'Sakatlık sonrası rehabilitasyon önce hangi kanalda görünür?'), a: t('Function / Capacity.', 'İşlev / Kapasite.') },
  },
  {
    id: 'EDU-013',
    title: t('Data coverage and confidence', 'Veri kapsamı ve güven'),
    body: t('A precise-looking number can still be weak if inputs are few, old or low quality. Coverage shows how much of the needed data exists; confidence summarises it.', 'Kesin görünen bir sayı, girdiler az, eski ya da düşük kaliteliyse yine zayıf olabilir. Kapsam gereken verinin ne kadarının mevcut olduğunu gösterir; güven bunu özetler.'),
    example: t('Protection 74 with 30% coverage is less informative than 68 with 90% coverage.', '%30 kapsamlı Koruma 74, %90 kapsamlı 68\'den daha az bilgilendiricidir.'),
    quiz: [
      { q: t('Is coverage a health risk?', 'Kapsam bir sağlık riski mi?'), options: yesNo, correct: 1, why: t('It describes data, not health.', 'Veriyi tanımlar, sağlığı değil.') },
      { q: t('Coverage too low — what does the app show?', 'Kapsam çok düşük — uygulama ne gösterir?'), options: [t('A score anyway', 'Yine de skor'), t('INSUFFICIENT_DATA', 'INSUFFICIENT_DATA')], correct: 1, why: t('No score is shown below the minimum coverage.', 'Asgari kapsamın altında skor gösterilmez.') },
    ],
    transfer: { q: t('How can you raise confidence without changing your health?', 'Sağlığını değiştirmeden güveni nasıl artırırsın?'), a: t('By adding missing, recent, good-quality measurements.', 'Eksik, güncel ve kaliteli ölçümler ekleyerek.') },
  },
  {
    id: 'EDU-014',
    title: t('Wearable data', 'Giyilebilir cihaz verisi'),
    body: t('Sensor samples, daily aggregates and clinical measurements have different contexts. Two devices can disagree; overlapping data needs a deduplication policy.', 'Sensör örnekleri, günlük özetler ve klinik ölçümler farklı bağlamlara sahiptir. İki cihaz uyuşmayabilir; çakışan veri tekilleştirme politikası ister.'),
    example: t('A watch\'s sleep estimate is not a sleep-lab study.', 'Saatin uyku tahmini bir uyku laboratuvarı çalışması değildir.'),
    quiz: [
      { q: t('An empty Health Connect query means "no data"?', 'Boş Health Connect sorgusu "veri yok" demek mi?'), options: yesNo, correct: 1, why: t('It may mean no permission; never infer.', 'İzin yok demek olabilir; çıkarım yapılmaz.') },
      { q: t('Phone and watch both count steps. Sum them?', 'Telefon ve saat adım sayıyor. Toplanır mı?'), options: yesNo, correct: 1, why: t('Overlap policy, not blind sums.', 'Çakışma politikası, körce toplama değil.') },
    ],
    transfer: { q: t('If permission is denied, what should still work?', 'İzin reddedilirse ne çalışmaya devam etmeli?'), a: t('Manual entry, without fake imported data.', 'Sahte içe aktarım olmadan elle giriş.') },
  },
  {
    id: 'EDU-015',
    title: t('Why corrections preserve history', 'Düzeltmeler neden geçmişi korur'),
    body: t('Correcting a wrong record creates a new version and keeps the old one auditable. Derived results are recalculated; unrelated history is not rewritten.', 'Yanlış kaydı düzeltmek yeni sürüm oluşturur ve eskisini denetlenebilir tutar. Türetilmiş sonuçlar yeniden hesaplanır; ilgisiz geçmiş yeniden yazılmaz.'),
    example: t('Weight 87 → corrected to 78: BMI history shows the correction instead of silently changing.', 'Kilo 87 → 78 olarak düzeltildi: BMİ geçmişi sessizce değişmek yerine düzeltmeyi gösterir.'),
    quiz: [
      { q: t('Does "Reset settings" delete health records?', '"Ayarları sıfırla" sağlık kayıtlarını siler mi?'), options: yesNo, correct: 1, why: t('Reset ≠ delete.', 'Sıfırlama ≠ silme.') },
      { q: t('After a correction, should old results vanish without trace?', 'Düzeltmeden sonra eski sonuçlar iz bırakmadan kaybolmalı mı?'), options: yesNo, correct: 1, why: t('History stays auditable.', 'Geçmiş denetlenebilir kalır.') },
    ],
    transfer: { q: t('A deleted record syncs from an old device. Restore it?', 'Silinmiş bir kayıt eski cihazdan senkronlanıyor. Geri yüklensin mi?'), a: t('No — tombstones prevent resurrection.', 'Hayır — tombstone kayıtları dirilmeyi engeller.') },
  },
];

/** Answer key guard (AT-796): the missing≠zero lesson never accepts "0". */
export function gradeMcq(lessonId: string, qIndex: 0 | 1, choice: number): boolean {
  const l = LESSONS.find((x) => x.id === lessonId);
  return !!l && l.quiz[qIndex].correct === choice;
}
