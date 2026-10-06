import { useState } from 'react';
import { DOMAIN_VERSION, HANDOFF_BASELINE } from '@hhos/domain';
import { ATTRIBUTION_MANIFEST, PACK_CATALOG } from '@hhos/packs';
import { Chip, tr } from '@hhos/ui';
import { DEFAULT_PREFS, type AppCtx, type Prefs } from '../App.tsx';

export function SettingsScreen({ ctx }: { ctx: AppCtx }) {
  const L = ctx.prefs.lang;
  const [confirmText, setConfirmText] = useState('');
  const [msg, setMsg] = useState<string | null>(null);

  // FR-45/AT-210: settings reset touches display preferences only; health records stay.
  const resetSettings = () => {
    ctx.setPrefs({ lang: DEFAULT_PREFS.lang, theme: DEFAULT_PREFS.theme });
    setMsg(`${L === 'tr' ? 'Ayarlar sıfırlandı. Sağlık kayıtları değişmedi' : 'Settings reset. Health records unchanged'}: ${ctx.profiles.length} profiles, ${ctx.labs.length} labs.`);
  };

  const exportJson = () => {
    const bundle = { format: 'HHOS-PORTABLE-EXPORT-PREVIEW', domain_version: DOMAIN_VERSION, handoff: HANDOFF_BASELINE, exported_at: new Date().toISOString(), mode: ctx.prefs.mode, packs: PACK_CATALOG.map((p) => ({ pack_id: p.pack_id, version: p.version })), profiles: ctx.profiles, labs: ctx.labs };
    const url = URL.createObjectURL(new Blob([JSON.stringify(bundle, null, 2)], { type: 'application/json' }));
    const a = document.createElement('a');
    a.href = url;
    a.download = `hhos-export-${new Date().toISOString().slice(0, 10)}.json`;
    a.click();
    URL.revokeObjectURL(url);
  };

  const deleteAll = async () => {
    try {
      await ctx.repo.deleteAllHealthData();
      ctx.setPrefs({ onboarded: false, selfId: null, token: null });
    } catch (e) {
      setMsg((e as Error).message);
    }
  };

  return (
    <section style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <div className="hh-card form-grid">
        <label>Language<select className="hh-input" value={L} onChange={(e) => ctx.setPrefs({ lang: e.target.value as 'en' | 'tr' })}><option value="en">English</option><option value="tr">Türkçe</option></select></label>
        <label>{tr(L, 'theme')}<select className="hh-input" value={ctx.prefs.theme} onChange={(e) => ctx.setPrefs({ theme: e.target.value as Prefs['theme'] })}><option value="auto">{tr(L, 'themeAuto')}</option><option value="light">{tr(L, 'themeLight')}</option><option value="dark">{tr(L, 'themeDark')}</option><option value="clarity">{tr(L, 'themeClarity')}</option></select></label>
        <div>
          <div className="hh-label">{L === 'tr' ? 'Depolama' : 'Storage'}</div>
          <p className="hh-small" style={{ margin: 0 }}>{ctx.prefs.mode === 'LOCAL' ? (L === 'tr' ? 'Yalnız bu cihaz (IndexedDB). Hiçbir şey sunucuya gitmez.' : 'Local only (IndexedDB). Nothing leaves this device.') : `${L === 'tr' ? 'Bulut' : 'Cloud'}: ${ctx.prefs.apiBase}`}</p>
        </div>
      </div>
      <div className="hh-card">
        <h3>{L === 'tr' ? 'Sıfırla ≠ sil' : 'Reset ≠ delete'}</h3>
        <div className="hh-row">
          <button className="hh-btn" data-testid="reset-settings" onClick={resetSettings}>↺ {L === 'tr' ? 'Ayarları varsayılana döndür' : 'Reset settings to defaults'}</button>
          <button className="hh-btn" onClick={exportJson}>⇩ {L === 'tr' ? 'Dışa aktar (JSON)' : 'Export (JSON)'}</button>
        </div>
        {msg ? <p className="hh-small" role="status" data-testid="settings-msg">{msg}</p> : null}
        <fieldset className="group" style={{ marginTop: 12, borderColor: 'var(--danger)' }}>
          <legend style={{ color: 'var(--danger)' }}>{L === 'tr' ? 'Tüm sağlık verisini sil' : 'Delete all health data'}</legend>
          <p className="hh-small">{L === 'tr' ? 'Geri alınamaz. Onaylamak için DELETE yaz.' : 'Irreversible. Type DELETE to confirm.'}</p>
          <div className="hh-row">
            <input className="hh-input" style={{ maxWidth: 160 }} aria-label="Type DELETE to confirm" value={confirmText} onChange={(e) => setConfirmText(e.target.value)} />
            <button className="hh-btn danger" disabled={confirmText !== 'DELETE'} onClick={deleteAll}>{L === 'tr' ? 'Kalıcı olarak sil' : 'Delete permanently'}</button>
          </div>
        </fieldset>
      </div>
      <div className="hh-card hh-scroll-x">
        <h3>{L === 'tr' ? 'Veri kaynakları ve lisanslar' : 'Data Sources & Licenses'}</h3>
        <table className="hh-table">
          <tbody>
            {ATTRIBUTION_MANIFEST.map((a) => (
              <tr key={a.name}><td>{a.name}</td><td className="hh-small">{a.license}</td><td><Chip tone={a.active ? 'ok' : 'muted'}>{a.active ? 'ACTIVE' : 'NOT ACTIVE'}</Chip></td></tr>
            ))}
          </tbody>
        </table>
        <p className="hh-small hh-muted">@hhos/domain {DOMAIN_VERSION} · handoff {HANDOFF_BASELINE}</p>
      </div>
    </section>
  );
}
