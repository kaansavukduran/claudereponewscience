import { useEffect, useRef, useState } from 'react';
import type { Lang } from '@hhos/ui';

const STEPS: Array<{ en: [string, string]; tr: [string, string] }> = [
  { en: ['Synthetic laboratory', 'Every person, lab value and rule here is synthetic. Move sliders, toggle modules and watch results recalculate deterministically — same inputs, same outputs.'], tr: ['Sentetik laboratuvar', 'Buradaki her kişi, lab değeri ve kural sentetiktir. Kaydırıcıları oynat, modülleri aç/kapat; sonuçlar deterministik olarak yeniden hesaplanır — aynı girdi, aynı çıktı.'] },
  { en: ['Four kinds of result', 'Raw fact (what was measured) · Derived measurement (e.g. BMI) · Validated clinical model (only when licensed and eligible) · App-defined score (Protection/Burden/Function). They are never mixed.'], tr: ['Dört tür sonuç', 'Ham olgu (ölçülen) · Türetilmiş ölçüm (ör. BMİ) · Doğrulanmış klinik model (yalnız lisanslı ve uygunsa) · Uygulama skoru (Koruma/Yük/İşlev). Asla karıştırılmaz.'] },
  { en: ['Missing is not zero', 'Tick "Unknown" on any field: the app shows a missing state and lowers coverage instead of inventing a 0.'], tr: ['Eksik, sıfır değildir', 'Herhangi bir alanda "Bilinmiyor"u işaretle: uygulama 0 uydurmak yerine eksik durumunu gösterir ve kapsamı düşürür.'] },
  { en: ['Scenarios & plans', 'Clone a profile to try "what if" — the source never changes. A mission is a plan; only a logged completion counts.'], tr: ['Senaryolar ve planlar', '"Ya şöyle olsaydı" için profili klonla — kaynak asla değişmez. Görev bir plandır; yalnız kaydedilen tamamlanma sayılır.'] },
  { en: ['How calculated?', 'Every card opens its model/rule ID, version, inputs, missing inputs, coverage and limitations. Reset restores demo defaults; it never deletes real data.'], tr: ['Nasıl hesaplandı?', 'Her kart model/kural kimliğini, sürümünü, girdilerini, eksik girdilerini, kapsamını ve sınırlamalarını açar. Sıfırlama demo varsayılanlarını geri getirir; gerçek veriyi silmez.'] },
];

export function Tour({ lang, onClose }: { lang: Lang; onClose: () => void }) {
  const [i, setI] = useState(0);
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => ref.current?.focus(), [i]);
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && onClose();
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [onClose]);
  const [title, body] = STEPS[i]![lang];
  return (
    <div className="tour-backdrop">
      <div ref={ref} tabIndex={-1} className="hh-card tour" role="dialog" aria-modal="true" aria-labelledby="tour-title" data-testid="tour">
        <div className="hh-label">{i + 1} / {STEPS.length}</div>
        <h2 id="tour-title" style={{ margin: '4px 0 8px' }}>{title}</h2>
        <p>{body}</p>
        <div className="hh-row" style={{ justifyContent: 'space-between' }}>
          <button className="hh-btn" data-testid="tour-skip" onClick={onClose}>{lang === 'tr' ? 'Turu atla' : 'Skip tour'}</button>
          <div className="hh-row">
            <button className="hh-btn" disabled={i === 0} onClick={() => setI(i - 1)}>←</button>
            {i < STEPS.length - 1 ? (
              <button className="hh-btn primary" onClick={() => setI(i + 1)}>{lang === 'tr' ? 'İleri' : 'Next'} →</button>
            ) : (
              <button className="hh-btn primary" onClick={onClose}>{lang === 'tr' ? 'Başla' : 'Start'}</button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
