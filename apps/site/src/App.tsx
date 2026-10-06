import { useEffect, useReducer, useState } from 'react';
import { Chip, tr } from '@hhos/ui';
import { clearStorage, loadState, reducer, saveState, type Action, type SiteState, type TabId, type Theme } from './state.ts';
import { ProfileLab } from './views/ProfileLab.tsx';
import { CompareLab } from './views/CompareLab.tsx';
import { LabInterpretationLab } from './views/LabInterpretationLab.tsx';
import { PreventiveLab } from './views/PreventiveLab.tsx';
import { SafetyLab } from './views/SafetyLab.tsx';
import { NutritionLab } from './views/NutritionLab.tsx';
import { MissionsLab } from './views/MissionsLab.tsx';
import { TimelineLab } from './views/TimelineLab.tsx';
import { LearnLab } from './views/LearnLab.tsx';
import { SourcesView } from './views/SourcesView.tsx';
import { Tour } from './views/Tour.tsx';

// Theme set by an embedding host (e.g. a published-artifact viewer) is restored when the lab theme is "auto".
const HOST_THEME = typeof document === 'undefined' ? null : document.documentElement.getAttribute('data-theme');

export interface ViewProps {
  s: SiteState;
  d: (a: Action) => void;
}

const TABS: Array<{ id: TabId; en: string; tr: string; glyph: string }> = [
  { id: 'lab', en: 'Profile & results', tr: 'Profil ve sonuçlar', glyph: '◎' },
  { id: 'compare', en: 'Compare', tr: 'Karşılaştır', glyph: '⇄' },
  { id: 'labs', en: 'Lab interpretation', tr: 'Lab yorumlama', glyph: '⌬' },
  { id: 'prevent', en: 'Preventive care', tr: 'Koruyucu bakım', glyph: '⛨' },
  { id: 'safety', en: 'Meds & supplements', tr: 'İlaç ve takviye', glyph: '⚕' },
  { id: 'nutrition', en: 'Nutrition math', tr: 'Beslenme hesabı', glyph: '◫' },
  { id: 'missions', en: 'Daily missions', tr: 'Günlük görevler', glyph: '✓' },
  { id: 'timeline', en: 'Timeline & wearables', tr: 'Zaman çizelgesi', glyph: '≋' },
  { id: 'learn', en: 'Learn', tr: 'Öğren', glyph: '✎' },
  { id: 'sources', en: 'Sources & licenses', tr: 'Kaynaklar ve lisanslar', glyph: '§' },
];

export function App() {
  const [s, d] = useReducer(reducer, undefined, loadState);
  const [confirm, setConfirm] = useState<null | 'reset' | 'clear'>(null);

  useEffect(() => saveState(s), [s]);
  useEffect(() => {
    const root = document.documentElement;
    if (s.theme === 'auto') {
      if (HOST_THEME) root.setAttribute('data-theme', HOST_THEME);
      else root.removeAttribute('data-theme');
    }
    else root.setAttribute('data-theme', s.theme);
    root.lang = s.lang;
  }, [s.theme, s.lang]);

  const L = s.lang;
  const View = { lab: ProfileLab, compare: CompareLab, labs: LabInterpretationLab, prevent: PreventiveLab, safety: SafetyLab, nutrition: NutritionLab, missions: MissionsLab, timeline: TimelineLab, learn: LearnLab, sources: SourcesView }[s.tab];

  return (
    <div className="shell">
      <a className="skip" href="#main">Skip to content</a>
      <header className="topbar">
        <div className="brand">
          <span className="logo" aria-hidden="true">⟁</span>
          <div>
            <div className="brand-title">{tr(L, 'appSite')}</div>
            <div className="hh-small hh-muted">Longevity ↔ Shortevity · deterministic core v0.25 · handoff v0.24</div>
          </div>
        </div>
        <div className="hh-row toolbar">
          <Chip tone="synthetic">{tr(L, 'synthetic')}</Chip>
          <label className="sr-only" htmlFor="lang">Language</label>
          <select id="lang" className="hh-input compact" value={L} onChange={(e) => d({ type: 'set', patch: { lang: e.target.value as 'en' | 'tr' } })}>
            <option value="en">EN</option>
            <option value="tr">TR</option>
          </select>
          <label className="sr-only" htmlFor="theme">{tr(L, 'theme')}</label>
          <select id="theme" className="hh-input compact" value={s.theme} onChange={(e) => d({ type: 'set', patch: { theme: e.target.value as Theme } })}>
            <option value="auto">{tr(L, 'themeAuto')}</option>
            <option value="light">{tr(L, 'themeLight')}</option>
            <option value="dark">{tr(L, 'themeDark')}</option>
            <option value="clarity">{tr(L, 'themeClarity')}</option>
          </select>
          <button className="hh-btn" onClick={() => d({ type: 'set', patch: { tourDone: false } })}>{tr(L, 'tour')}</button>
          <button className="hh-btn" data-testid="reset-demo" onClick={() => setConfirm('reset')}>↺ {tr(L, 'resetDemo')}</button>
          <button className="hh-btn danger" onClick={() => setConfirm('clear')}>{tr(L, 'clearLocal')}</button>
        </div>
      </header>

      {confirm ? (
        <div className="confirm hh-card" role="alertdialog" aria-labelledby="confirm-title">
          <strong id="confirm-title">{confirm === 'reset' ? tr(L, 'resetDemo') : tr(L, 'clearLocal')}</strong>
          <p className="hh-small">
            {confirm === 'reset'
              ? L === 'tr'
                ? 'Sentetik profiller, demo ayarları ve paket seçimi varsayılana döner. Bu bir sağlık verisi silme işlemi değildir; burada gerçek veri yok.'
                : 'Synthetic profiles, demo settings and pack selection return to defaults. This is not health-data deletion; there is no real data here.'
              : L === 'tr'
                ? 'Bu tarayıcıdaki kayıtlı demo durumunu (dil ve tema dahil) siler.'
                : 'Removes the saved demo state from this browser (including language and theme).'}
          </p>
          <div className="hh-row">
            <button
              className={`hh-btn ${confirm === 'clear' ? 'danger' : 'primary'}`}
              data-testid="confirm-yes"
              autoFocus
              onClick={() => {
                if (confirm === 'clear') clearStorage();
                d({ type: confirm === 'reset' ? 'resetDemo' : 'clearLocal' });
                setConfirm(null);
              }}
            >
              {L === 'tr' ? 'Onayla' : 'Confirm'}
            </button>
            <button className="hh-btn" onClick={() => setConfirm(null)}>{L === 'tr' ? 'Vazgeç' : 'Cancel'}</button>
          </div>
        </div>
      ) : null}

      <nav className="tabs" aria-label="Lab sections">
        {TABS.map((t) => (
          <button key={t.id} className="tab" aria-current={s.tab === t.id ? 'page' : undefined} onClick={() => d({ type: 'set', patch: { tab: t.id } })}>
            <span aria-hidden="true" className="tab-glyph">{t.glyph}</span>
            {t[L]}
          </button>
        ))}
      </nav>

      <main id="main" className="main" tabIndex={-1}>
        <p className="hh-banner" role="note">◆ {tr(L, 'syntheticBanner')}</p>
        <View s={s} d={d} />
      </main>

      {!s.tourDone ? <Tour lang={L} onClose={() => d({ type: 'set', patch: { tourDone: true } })} /> : null}
    </div>
  );
}
