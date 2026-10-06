import { useState } from 'react';
import type { AppCtx } from '../App.tsx';
import { ApiRepository, type LocalRepository } from '../data/repository.ts';

/** Zero-knowledge first run (ONBOARDING_FLOW): storage choice → minimal profile → core loop. */
export function Onboarding({ ctx, localRepo }: { ctx: AppCtx; localRepo: LocalRepository }) {
  const L = ctx.prefs.lang;
  const [step, setStep] = useState<1 | 2>(1);
  const [mode, setMode] = useState<'LOCAL' | 'CLOUD'>('LOCAL');
  const [api, setApi] = useState(ctx.prefs.apiBase);
  const [name, setName] = useState('');
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const finish = async () => {
    setBusy(true);
    setErr(null);
    try {
      let token: string | null = null;
      let repo = localRepo as unknown as ApiRepository | LocalRepository;
      if (mode === 'CLOUD') {
        token = await ApiRepository.devSession(api, name || 'Me');
        repo = new ApiRepository({ baseUrl: api, token });
      }
      const p = await repo.createProfile(name || (L === 'tr' ? 'Ben' : 'Me'), 'SELF');
      ctx.setPrefs({ onboarded: true, mode, apiBase: api, token, selfId: p.id });
    } catch (e) {
      setErr((e as Error).message);
    } finally {
      setBusy(false);
    }
  };

  return (
    <main className="onboard">
      <div className="hh-card" style={{ maxWidth: 560, width: '100%' }}>
        <div className="hh-row" style={{ justifyContent: 'space-between' }}>
          <span className="hh-label">{step} / 2</span>
          <select className="hh-input" style={{ width: 'auto' }} aria-label="Language" value={L} onChange={(e) => ctx.setPrefs({ lang: e.target.value as 'en' | 'tr' })}>
            <option value="en">EN</option>
            <option value="tr">TR</option>
          </select>
        </div>
        {step === 1 ? (
          <>
            <h1 style={{ fontSize: 'var(--fs-display)', margin: '8px 0' }}>{L === 'tr' ? 'Verilerin nerede dursun?' : 'Where should your data live?'}</h1>
            <fieldset className="group">
              <legend>{L === 'tr' ? 'Depolama' : 'Storage'}</legend>
              <label className="choice">
                <input type="radio" name="mode" data-testid="mode-local" checked={mode === 'LOCAL'} onChange={() => setMode('LOCAL')} />
                <span>
                  <strong>{L === 'tr' ? 'Yalnız bu cihaz' : 'Local only'}</strong>
                  <br />
                  <span className="hh-small hh-muted">{L === 'tr' ? 'Veriler sen dışa aktarmadıkça bu cihazda kalır. Tam özellikli; demo modu değildir.' : 'Data stays on this device unless you export it. Fully featured — not a demo mode.'}</span>
                </span>
              </label>
              <label className="choice">
                <input type="radio" name="mode" data-testid="mode-cloud" checked={mode === 'CLOUD'} onChange={() => setMode('CLOUD')} />
                <span>
                  <strong>{L === 'tr' ? 'Bulut hesabı' : 'Cloud account'}</strong>
                  <br />
                  <span className="hh-small hh-muted">{L === 'tr' ? 'Desteklenen cihazlar arası eşitleme için. Bu yapı geliştirme oturumu kullanır.' : 'For supported cross-device sync. This build uses a development session.'}</span>
                </span>
              </label>
              {mode === 'CLOUD' ? (
                <label className="hh-small" style={{ display: 'block', marginTop: 8 }}>
                  API URL
                  <input className="hh-input" data-testid="api-url" value={api} onChange={(e) => setApi(e.target.value)} />
                </label>
              ) : null}
            </fieldset>
            <button className="hh-btn primary" data-testid="onboard-next" onClick={() => setStep(2)}>{L === 'tr' ? 'İleri' : 'Next'} →</button>
          </>
        ) : (
          <>
            <h1 style={{ fontSize: 'var(--fs-display)', margin: '8px 0' }}>{L === 'tr' ? 'Profilini oluştur' : 'Create your profile'}</h1>
            <p className="hh-muted">{L === 'tr' ? 'Profil neredeyse boş olabilir. Tanı ya da ilaç sorulmaz; hiçbir şey uydurulmaz.' : 'Your profile can be almost blank. No diagnosis or medication is required, and nothing is invented.'}</p>
            <label className="hh-small">
              {L === 'tr' ? 'Ad (isteğe bağlı)' : 'Name (optional)'}
              <input className="hh-input" data-testid="profile-name" value={name} onChange={(e) => setName(e.target.value)} />
            </label>
            <div className="callout" style={{ margin: '12px 0' }}>
              {L === 'tr'
                ? 'Temel döngü: Gir / içe aktar → zaman çizelgesi → hesaplar → sonuçlar → karşılaştır / uygula / öğren. Ham olgu, türetilmiş ölçüm, doğrulanmış risk ve uygulama skoru dört ayrı şeydir.'
                : 'Core loop: enter / import → timeline → calculations → results → compare / act / learn. A raw fact, a derived measurement, a validated risk and an app score are four different things.'}
            </div>
            {err ? <p className="hh-banner" role="alert">⚠ {err}</p> : null}
            <div className="hh-row">
              <button className="hh-btn" onClick={() => setStep(1)}>←</button>
              <button className="hh-btn primary" data-testid="onboard-finish" disabled={busy} onClick={finish}>{L === 'tr' ? 'Başla' : 'Start'}</button>
            </div>
          </>
        )}
      </div>
    </main>
  );
}
