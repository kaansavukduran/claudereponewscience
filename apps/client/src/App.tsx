import { useCallback, useEffect, useMemo, useState } from 'react';
import type { Lang } from '@hhos/ui';
import { ApiRepository, LocalRepository, type HealthRepository, type LabRecord, type StoredProfile } from './data/repository.ts';
import { IdbStore } from './data/store.ts';
import { Onboarding } from './screens/Onboarding.tsx';
import { TodayScreen } from './screens/Today.tsx';
import { BodyScreen } from './screens/Body.tsx';
import { LabsScreen } from './screens/Labs.tsx';
import { ResultsScreen } from './screens/Results.tsx';
import { CompareScreen } from './screens/Compare.tsx';
import { SettingsScreen } from './screens/Settings.tsx';

export interface Prefs {
  onboarded: boolean;
  mode: 'LOCAL' | 'CLOUD';
  apiBase: string;
  token: string | null;
  lang: Lang;
  theme: 'auto' | 'light' | 'dark' | 'clarity';
  selfId: string | null;
}

export const DEFAULT_PREFS: Prefs = { onboarded: false, mode: 'LOCAL', apiBase: 'http://localhost:8787', token: null, lang: 'en', theme: 'auto', selfId: null };
const PREFS_KEY = 'hhos-client-prefs-v1';

function loadPrefs(): Prefs {
  try {
    const raw = localStorage.getItem(PREFS_KEY);
    return raw ? { ...DEFAULT_PREFS, ...JSON.parse(raw) } : DEFAULT_PREFS;
  } catch {
    return DEFAULT_PREFS;
  }
}

export interface AppCtx {
  prefs: Prefs;
  setPrefs: (p: Partial<Prefs>) => void;
  repo: HealthRepository;
  profiles: StoredProfile[];
  self: StoredProfile | null;
  refresh: () => Promise<void>;
  labs: LabRecord[];
  error: string | null;
  setError: (e: string | null) => void;
}

type Screen = 'today' | 'body' | 'labs' | 'results' | 'compare' | 'settings';
const SCREENS: Array<{ id: Screen; en: string; tr: string; glyph: string }> = [
  { id: 'today', en: 'Today', tr: 'Bugün', glyph: '◉' },
  { id: 'body', en: 'Body', tr: 'Beden', glyph: '◎' },
  { id: 'labs', en: 'Labs', tr: 'Lab', glyph: '⌬' },
  { id: 'results', en: 'Results', tr: 'Sonuçlar', glyph: '▲' },
  { id: 'compare', en: 'Compare', tr: 'Karşılaştır', glyph: '⇄' },
  { id: 'settings', en: 'Settings', tr: 'Ayarlar', glyph: '⚙' },
];

const localRepo = new LocalRepository(new IdbStore());

export function App() {
  const [prefs, setPrefsState] = useState<Prefs>(loadPrefs);
  const [screen, setScreen] = useState<Screen>('today');
  const [profiles, setProfiles] = useState<StoredProfile[]>([]);
  const [labs, setLabs] = useState<LabRecord[]>([]);
  const [error, setError] = useState<string | null>(null);

  const setPrefs = useCallback((p: Partial<Prefs>) => {
    setPrefsState((cur) => {
      const next = { ...cur, ...p };
      try {
        localStorage.setItem(PREFS_KEY, JSON.stringify(next));
      } catch {
        /* prefs only */
      }
      return next;
    });
  }, []);

  const repo: HealthRepository = useMemo(
    () => (prefs.mode === 'CLOUD' && prefs.token ? new ApiRepository({ baseUrl: prefs.apiBase, token: prefs.token }) : localRepo),
    [prefs.mode, prefs.apiBase, prefs.token],
  );

  const self = profiles.find((p) => p.id === prefs.selfId) ?? null;

  const refresh = useCallback(async () => {
    try {
      const ps = await repo.listProfiles();
      setProfiles(ps);
      const sid = prefs.selfId;
      setLabs(sid && ps.some((p) => p.id === sid) ? await repo.listLabs(sid) : []);
      setError(null);
    } catch (e) {
      setError((e as Error).message);
    }
  }, [repo, prefs.selfId]);

  useEffect(() => {
    if (prefs.onboarded) void refresh();
  }, [prefs.onboarded, refresh]);

  useEffect(() => {
    const root = document.documentElement;
    if (prefs.theme === 'auto') root.removeAttribute('data-theme');
    else root.setAttribute('data-theme', prefs.theme);
    root.lang = prefs.lang;
  }, [prefs.theme, prefs.lang]);

  const ctx: AppCtx = { prefs, setPrefs, repo, profiles, self, refresh, labs, error, setError };
  const L = prefs.lang;

  if (!prefs.onboarded) return <Onboarding ctx={ctx} localRepo={localRepo} />;

  const View = { today: TodayScreen, body: BodyScreen, labs: LabsScreen, results: ResultsScreen, compare: CompareScreen, settings: SettingsScreen }[screen];
  return (
    <div className="app">
      <header className="app-top">
        <strong>Human Health OS</strong>
        <span className="hh-chip" data-tone={prefs.mode === 'LOCAL' ? 'ok' : 'info'} data-testid="mode-chip">
          {prefs.mode === 'LOCAL' ? (L === 'tr' ? '⌂ Yalnız bu cihaz' : '⌂ Local only') : L === 'tr' ? '☁ Bulut hesabı' : '☁ Cloud account'}
        </span>
      </header>
      {error ? <p className="hh-banner" role="alert" data-testid="error">⚠ {error}</p> : null}
      <main className="app-main" id="main">
        <View ctx={ctx} />
      </main>
      <nav className="app-nav" aria-label="Primary">
        {SCREENS.map((s) => (
          <button key={s.id} aria-current={screen === s.id ? 'page' : undefined} onClick={() => setScreen(s.id)}>
            <span aria-hidden="true">{s.glyph}</span>
            <span>{s[L]}</span>
          </button>
        ))}
      </nav>
    </div>
  );
}
