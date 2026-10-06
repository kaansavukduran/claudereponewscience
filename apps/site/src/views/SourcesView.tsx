import { DOMAIN_VERSION, HANDOFF_BASELINE } from '@hhos/domain';
import { ATTRIBUTION_MANIFEST, PACK_CATALOG } from '@hhos/packs';
import { Chip } from '@hhos/ui';
import type { ViewProps } from '../App.tsx';
import { Help } from './controls.tsx';

export function SourcesView({ s }: ViewProps) {
  const L = s.lang;
  return (
    <section aria-labelledby="src-title" style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
      <h2 id="src-title" className="section-title">{L === 'tr' ? 'Veri kaynakları ve lisanslar' : 'Data Sources & Licenses'}</h2>
      <div className="hh-card hh-scroll-x">
        <h3>{L === 'tr' ? 'Atıf manifestosu' : 'Attribution manifest'}</h3>
        <table className="hh-table" data-testid="attribution-table">
          <thead><tr><th>Name</th><th>Purpose</th><th>License / terms</th><th>Disposition</th><th>State</th><th>Notes</th></tr></thead>
          <tbody>
            {ATTRIBUTION_MANIFEST.map((a) => (
              <tr key={a.name}>
                <td>{a.name}</td><td>{a.purpose}</td><td>{a.license}</td><td className="hh-mono hh-small">{a.disposition}</td>
                <td><Chip tone={a.active ? 'ok' : 'muted'}>{a.active ? 'ACTIVE' : 'NOT ACTIVE'}</Chip></td>
                <td className="hh-small">{[a.attribution, a.endorsement_note].filter(Boolean).join(' · ')}</td>
              </tr>
            ))}
          </tbody>
        </table>
        <p className="hh-small hh-muted">{L === 'tr' ? 'Mühendislik kaydıdır, hukuki tavsiye değildir. Koşullar üretim öncesi yeniden doğrulanmalıdır.' : 'Engineering register, not legal advice. Terms must be re-verified before production release.'}</p>
      </div>
      <div className="hh-card hh-scroll-x">
        <h3>{L === 'tr' ? 'Yüklü paketler' : 'Installed packs'}</h3>
        <table className="hh-table">
          <thead><tr><th>Pack</th><th>Kind</th><th>Version</th><th>Status</th><th>Default in</th><th>Note</th></tr></thead>
          <tbody>
            {PACK_CATALOG.map((p) => (
              <tr key={p.pack_id}><td className="hh-mono">{p.pack_id}</td><td>{p.kind}</td><td className="hh-mono">{p.version}</td><td className="hh-mono hh-small">{p.status}</td><td>{p.default_in.join(', ') || '—'}</td><td className="hh-small">{p.note}</td></tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="hh-card">
        <h3>{L === 'tr' ? 'Bu laboratuvar hakkında' : 'About this lab'}</h3>
        <ul className="hh-small" style={{ margin: 0, paddingLeft: 18 }}>
          <li>Deterministic core <span className="hh-mono">@hhos/domain {DOMAIN_VERSION}</span> · handoff baseline {HANDOFF_BASELINE}. {L === 'tr' ? 'Aynı kod üretim istemcisinde ve API\'de çalışır; ortak golden vector\'larla doğrulanır.' : 'The same code runs in the production client and the API, verified by shared golden vectors.'}</li>
          <li>{L === 'tr' ? 'Üretken yapay zekâ ya da sunucu gerekmez; tüm hesaplar tarayıcıda yerelde yapılır.' : 'No generative AI and no server required; every calculation runs locally in the browser.'}</li>
          <li>{L === 'tr' ? 'Durum yalnız bu tarayıcıda saklanır (localStorage). Paylaşım URL\'si sağlık verisi taşımaz.' : 'State is stored only in this browser (localStorage). No share URL carries health data.'}</li>
        </ul>
        <Help topic="reset" lang={L}>{L === 'tr' ? 'Sıfırlama ≠ silme' : 'Reset ≠ delete'}</Help>
      </div>
    </section>
  );
}
