import type { ReactNode } from 'react';
import type { Lang } from '@hhos/ui';
export { NumField } from '@hhos/ui';

export const HELP: Record<string, { en: string; tr: string }> = {
  NOT_ELIGIBLE: {
    en: 'A calculator is shown as Not eligible / Unavailable when the profile is outside its validated population or the model is not licensed/implemented. No number is invented.',
    tr: 'Profil hesaplayıcının doğrulandığı popülasyonun dışındaysa ya da model lisanslı/uygulanmış değilse "Uygun değil / Kullanılamıyor" görünür. Hiçbir sayı uydurulmaz.',
  },
  coverage: {
    en: 'Coverage = weight of available eligible inputs ÷ weight of all eligible inputs. It describes data completeness, not health risk.',
    tr: 'Kapsam = mevcut uygun girdilerin ağırlığı ÷ tüm uygun girdilerin ağırlığı. Veri bütünlüğünü anlatır, sağlık riskini değil.',
  },
  provenance: {
    en: 'Provenance records where a value came from: manual entry, wearable, lab report, imported document or derived calculation.',
    tr: 'Köken (provenance), bir değerin nereden geldiğini kaydeder: elle giriş, giyilebilir cihaz, lab raporu, içe aktarılan belge ya da türetilmiş hesap.',
  },
  scenario: {
    en: 'A scenario is a hypothetical clone. Editing it never changes the source profile; results are labelled hypothetical.',
    tr: 'Senaryo varsayımsal bir klondur. Onu değiştirmek kaynak profili asla değiştirmez; sonuçlar varsayımsal olarak etiketlenir.',
  },
  reset: {
    en: 'Reset restores synthetic demo defaults. It is not deletion of anyone’s health data; in the real app settings reset and data deletion are separate actions.',
    tr: 'Sıfırlama sentetik demo varsayılanlarını geri yükler. Kimsenin sağlık verisini silmez; gerçek uygulamada ayar sıfırlama ve veri silme ayrı işlemlerdir.',
  },
};

export function Help({ topic, lang, children }: { topic: keyof typeof HELP; lang: Lang; children?: ReactNode }) {
  return (
    <details className="callout">
      <summary style={{ cursor: 'pointer', fontWeight: 600 }}>? {children ?? (lang === 'tr' ? 'Bu ne demek?' : 'What does this mean?')}</summary>
      <p style={{ margin: '6px 0 0' }}>{HELP[topic]?.[lang]}</p>
    </details>
  );
}

export function StateCard({ title, state, tone, children, testId }: { title: string; state: string; tone?: 'ok' | 'warn' | 'risk' | 'info' | 'muted'; children?: ReactNode; testId?: string }) {
  const glyph = { ok: '✓', warn: '⚠', risk: '✗', info: 'ℹ', muted: '○' }[tone ?? 'muted'];
  const color = { ok: 'var(--success)', warn: 'var(--warning)', risk: 'var(--danger)', info: 'var(--info)', muted: 'var(--text-2)' }[tone ?? 'muted'];
  return (
    <div className="state-card" data-testid={testId}>
      <div className="hh-label">{title}</div>
      <div className="state" style={{ color }}>
        <span aria-hidden="true">{glyph} </span>
        {state}
      </div>
      {children ? <div className="hh-small hh-muted" style={{ marginTop: 4 }}>{children}</div> : null}
    </div>
  );
}
