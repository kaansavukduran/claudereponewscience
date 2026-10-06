import { useMemo } from 'react';
import { MODULE_IDS, computeProfileResults, olsSlope, type ConditionStatus, type ProfileInputs, type SmokingStatus } from '@hhos/domain';
import { syntheticWearable } from '@hhos/packs';
import { Chip, ResultCard, fmt, tr } from '@hhos/ui';
import type { ViewProps } from '../App.tsx';
import { Help, NumField } from './controls.tsx';

type NumKey = { [K in keyof ProfileInputs]: ProfileInputs[K] extends number | null ? K : never }[keyof ProfileInputs];

const GROUPS: Array<{ en: string; tr: string; fields: Array<{ k: NumKey; en: string; tr: string; unit: string; min: number; max: number; step?: number }> }> = [
  { en: 'Body', tr: 'Beden', fields: [
    { k: 'age_years', en: 'Age', tr: 'Yaş', unit: 'y', min: 18, max: 95 },
    { k: 'height_cm', en: 'Height', tr: 'Boy', unit: 'cm', min: 140, max: 210 },
    { k: 'weight_kg', en: 'Weight', tr: 'Kilo', unit: 'kg', min: 40, max: 180, step: 0.5 },
    { k: 'waist_cm', en: 'Waist', tr: 'Bel', unit: 'cm', min: 55, max: 160 },
    { k: 'body_fat_pct', en: 'Body fat', tr: 'Vücut yağı', unit: '%', min: 5, max: 55 },
  ] },
  { en: 'Cardiovascular', tr: 'Kardiyovasküler', fields: [
    { k: 'systolic_bp', en: 'Systolic BP', tr: 'Sistolik KB', unit: 'mmHg', min: 90, max: 200 },
    { k: 'diastolic_bp', en: 'Diastolic BP', tr: 'Diyastolik KB', unit: 'mmHg', min: 50, max: 120 },
    { k: 'resting_hr', en: 'Resting HR', tr: 'Dinlenik nabız', unit: 'bpm', min: 40, max: 110 },
  ] },
  { en: 'Sleep & activity', tr: 'Uyku ve aktivite', fields: [
    { k: 'sleep_hours', en: 'Sleep', tr: 'Uyku', unit: 'h', min: 3, max: 11, step: 0.1 },
    { k: 'sleep_quality_1_10', en: 'Sleep quality', tr: 'Uyku kalitesi', unit: '1–10', min: 1, max: 10 },
    { k: 'steps_per_day', en: 'Steps', tr: 'Adım', unit: '/day', min: 0, max: 20000, step: 100 },
    { k: 'exercise_min_week', en: 'Exercise', tr: 'Egzersiz', unit: 'min/wk', min: 0, max: 600, step: 5 },
  ] },
  { en: 'Exposures', tr: 'Maruziyetler', fields: [
    { k: 'packs_per_day', en: 'Packs per day', tr: 'Günlük paket', unit: 'packs', min: 0, max: 3, step: 0.1 },
    { k: 'years_smoked', en: 'Years smoked', tr: 'Sigara yılı', unit: 'y', min: 0, max: 60 },
    { k: 'alcohol_units_week', en: 'Alcohol', tr: 'Alkol', unit: 'units/wk', min: 0, max: 50 },
    { k: 'poor_air_days_month', en: 'Poor-air days', tr: 'Kötü hava günü', unit: '/month', min: 0, max: 30 },
  ] },
  { en: 'Mind & function (self-report ≠ diagnosis)', tr: 'Zihin ve işlev (öz bildirim ≠ tanı)', fields: [
    { k: 'mood_1_10', en: 'Mood', tr: 'Ruh hâli', unit: '1–10', min: 1, max: 10 },
    { k: 'pain_0_10', en: 'Pain', tr: 'Ağrı', unit: '0–10', min: 0, max: 10 },
    { k: 'mobility_1_10', en: 'Mobility', tr: 'Hareketlilik', unit: '1–10', min: 1, max: 10 },
    { k: 'cognition_self_1_10', en: 'Cognition (self)', tr: 'Biliş (öz)', unit: '1–10', min: 1, max: 10 },
    { k: 'skin_symptom_0_10', en: 'Skin symptoms', tr: 'Cilt belirtisi', unit: '0–10', min: 0, max: 10 },
    { k: 'breathlessness_0_10', en: 'Breathlessness', tr: 'Nefes darlığı', unit: '0–10', min: 0, max: 10 },
  ] },
  { en: 'Synthetic labs (synthetic units)', tr: 'Sentetik lab (sentetik birim)', fields: [
    { k: 'synth_lipid_marker', en: 'Synthetic lipid marker', tr: 'Sentetik lipit belirteci', unit: 'syn-u', min: 60, max: 260 },
    { k: 'synth_glycemic_marker', en: 'Synthetic glycemic marker', tr: 'Sentetik glisemik belirteç', unit: 'syn-u', min: 4, max: 12, step: 0.1 },
    { k: 'synth_kidney_marker', en: 'Synthetic kidney marker', tr: 'Sentetik böbrek belirteci', unit: 'syn-u', min: 0.4, max: 3, step: 0.05 },
  ] },
  { en: 'Prevention', tr: 'Koruyucu bakım', fields: [
    { k: 'preventive_items_up_to_date', en: 'Items up to date', tr: 'Güncel kalemler', unit: 'n', min: 0, max: 10 },
    { k: 'preventive_items_total', en: 'Items applicable', tr: 'Uygulanabilir kalemler', unit: 'n', min: 0, max: 10 },
  ] },
];

const MODULE_LABEL: Record<string, { en: string; tr: string }> = {
  cardiovascular: { en: 'Cardiovascular', tr: 'Kardiyovasküler' }, oncology: { en: 'Oncology', tr: 'Onkoloji' }, metabolic: { en: 'Metabolic/Endocrine', tr: 'Metabolik/Endokrin' },
  renal: { en: 'Renal', tr: 'Böbrek' }, respiratory: { en: 'Respiratory', tr: 'Solunum' }, neurology: { en: 'Neurology/Cognition', tr: 'Nöroloji/Biliş' },
  dermatology: { en: 'Dermatology', tr: 'Dermatoloji' }, musculoskeletal: { en: 'Musculoskeletal/Function', tr: 'Kas-iskelet/İşlev' }, prevention: { en: 'Prevention', tr: 'Koruyucu' }, environment: { en: 'Environment/Exposome', tr: 'Çevre/Ekspozom' },
};

export function ProfileLab({ s, d }: ViewProps) {
  const L = s.lang;
  const p = s.profiles.find((x) => x.id === s.activeId) ?? s.profiles[0]!;
  const r = useMemo(() => computeProfileResults(p), [p]);
  const wear = useMemo(() => syntheticWearable(), []);
  const trend = useMemo(() => olsSlope({ points: wear.map((w, i) => ({ t: i, v: w.steps })), min_n: 7 }), [wear]);
  const set = (patch: Partial<ProfileInputs>) => d({ type: 'patchInputs', id: p.id, patch });
  const src = p.source_profile_id ? s.profiles.find((x) => x.id === p.source_profile_id) : null;

  return (
    <section aria-labelledby="lab-title" className="split">
      <div className="hh-card editor">
        <h2 id="lab-title" className="section-title">{L === 'tr' ? 'Profil oluşturucu' : 'Profile builder'}</h2>
        <div className="profile-pills" role="group" aria-label="Profiles" style={{ marginTop: 8 }}>
          {s.profiles.map((x) => (
            <button key={x.id} className="pill" aria-pressed={x.id === p.id} onClick={() => d({ type: 'selectProfile', id: x.id })}>
              {x.profile_type === 'SCENARIO' ? '⑂ ' : ''}{x.name}
            </button>
          ))}
        </div>
        <div className="hh-row" style={{ margin: '8px 0' }}>
          <Chip tone="synthetic">{p.profile_type}</Chip>
          {p.profile_type === 'SCENARIO' ? <Chip tone="warn">{tr(L, 'hypothetical')}</Chip> : null}
          <button className="hh-btn" onClick={() => d({ type: 'cloneScenario', id: p.id })}>⑂ {L === 'tr' ? 'Senaryo klonla' : 'Clone scenario'}</button>
          <button className="hh-btn" onClick={() => d({ type: 'addBlank' })}>＋ {L === 'tr' ? 'Boş sentetik profil' : 'Blank synthetic profile'}</button>
        </div>
        {src ? <p className="hh-small hh-muted">{L === 'tr' ? 'Kaynak' : 'Source'}: {src.name} — {L === 'tr' ? 'değişmez' : 'never mutated'}</p> : null}

        <fieldset className="group">
          <legend>{L === 'tr' ? 'Sigara durumu' : 'Smoking status'}</legend>
          <select className="hh-input" aria-label="Smoking status" value={p.inputs.smoking_status} onChange={(e) => set({ smoking_status: e.target.value as SmokingStatus })}>
            {['UNKNOWN', 'NEVER', 'FORMER', 'CURRENT'].map((v) => <option key={v} value={v}>{v}</option>)}
          </select>
        </fieldset>

        {GROUPS.map((g) => (
          <fieldset key={g.en} className="group">
            <legend>{g[L]}</legend>
            {g.fields.map((f) => (
              <NumField key={f.k} testId={`field-${f.k}`} label={f[L]} unit={f.unit} min={f.min} max={f.max} step={f.step} value={p.inputs[f.k] as number | null} lang={L} onChange={(v) => set({ [f.k]: v } as Partial<ProfileInputs>)} />
            ))}
          </fieldset>
        ))}

        <fieldset className="group">
          <legend>{L === 'tr' ? 'Durumlar (sentetik)' : 'Conditions (synthetic)'}</legend>
          {p.inputs.conditions.length === 0 ? <p className="hh-small hh-muted">{L === 'tr' ? 'Kayıt yok — tanı uydurulmaz.' : 'None recorded — no diagnosis is invented.'}</p> : null}
          {p.inputs.conditions.map((c) => (
            <div key={c.id} className="hh-row" style={{ marginTop: 6 }}>
              <span className="hh-small" style={{ flex: 1 }}>{c.label}</span>
              <select className="hh-input compact" aria-label={`${c.label} status`} value={c.status} onChange={(e) => set({ conditions: p.inputs.conditions.map((x) => (x.id === c.id ? { ...x, status: e.target.value as ConditionStatus } : x)) })}>
                {['CONFIRMED', 'SUSPECTED', 'HISTORY', 'SELF_REPORTED'].map((v) => <option key={v}>{v}</option>)}
              </select>
              <button className="hh-btn" aria-label={`Remove ${c.label}`} onClick={() => set({ conditions: p.inputs.conditions.filter((x) => x.id !== c.id) })}>✕</button>
            </div>
          ))}
          <button className="hh-btn" style={{ marginTop: 8 }} onClick={() => set({ conditions: [...p.inputs.conditions, { id: `COND-${s.seq}-${p.inputs.conditions.length}`, label: `Synthetic condition ${p.inputs.conditions.length + 1}`, status: 'SUSPECTED', module: null }] })}>
            ＋ {L === 'tr' ? 'Sentetik durum ekle' : 'Add synthetic condition'}
          </button>
          <p className="hh-small hh-muted">{L === 'tr' ? 'Yük skoruna yalnız CONFIRMED sayılır; SUSPECTED/öz bildirim tanı değildir.' : 'Only CONFIRMED counts toward Burden; SUSPECTED/self-report is not a diagnosis.'}</p>
        </fieldset>

        <fieldset className="group">
          <legend>{L === 'tr' ? 'İleri sağlık modülleri' : 'Advanced health modules'}</legend>
          <div className="controls">
            {MODULE_IDS.map((m) => (
              <label key={m} className="check">
                <input type="checkbox" checked={p.modules[m]} onChange={() => d({ type: 'toggleModule', id: p.id, module: m })} />
                {MODULE_LABEL[m]?.[L]}
              </label>
            ))}
          </div>
          <p className="hh-small hh-muted">{L === 'tr' ? 'Modülü kapatmak karmaşıklığı gizler; veriyi silmez.' : 'Turning a module off hides complexity; it does not delete data.'}</p>
        </fieldset>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 16, minWidth: 0 }}>
        <div className="hh-row" style={{ justifyContent: 'space-between' }}>
          <h2 className="section-title">Longevity ↔ Shortevity</h2>
          {r.hypothetical ? <Chip tone="warn">{tr(L, 'hypothetical')}</Chip> : null}
        </div>
        <p className="hh-small hh-muted" style={{ margin: 0 }}>
          {L === 'tr'
            ? 'Beş ayrı kanal. Hiçbiri ölüm olasılığı, tanı ya da "kaç yıl yaşarsın" değildir.'
            : 'Five separate channels. None is a mortality probability, diagnosis or "years you will live".'}
        </p>
        <div className="channels">
          <ResultCard testId="card-protection" title={tr(L, 'protection')} result={r.protection} lang={L} channel="PROTECTION" bar digits={0} unit="/100" />
          <ResultCard testId="card-burden" title={tr(L, 'burden')} result={r.burden} lang={L} channel="BURDEN" bar digits={0} unit="/100" />
          <ResultCard testId="card-function" title={tr(L, 'function')} result={r.function} lang={L} channel="FUNCTION" bar digits={0} unit="/100" />
          <ResultCard testId="card-coverage" title={tr(L, 'coverageConfidence')} result={r.coverage} lang={L} channel="COVERAGE" scale={100} unit="%" digits={0} bar>
            <Help topic="coverage" lang={L} />
          </ResultCard>
        </div>
        <div className="channels">
          <ResultCard title={tr(L, 'balance')} result={r.balance} lang={L} digits={0} unit="">
            <p className="hh-small hh-muted" style={{ margin: 0 }}>
              {tr(L, 'protection')}: {fmt(r.balance.protection, 0)} · {tr(L, 'burden')}: {fmt(r.balance.burden, 0)}
            </p>
          </ResultCard>
          <ResultCard title={`${tr(L, 'trajectory')} · ${L === 'tr' ? 'sentetik adım serisi' : 'synthetic step series'}`} result={trend} lang={L} digits={1} unit="steps/day per day">
            <p className="hh-small hh-muted" style={{ margin: 0 }}>{L === 'tr' ? 'OLS eğimi, 28 günlük sentetik giyilebilir veri; boşluklar hariç. Tahmin değil.' : 'OLS slope over 28 days of synthetic wearable data, gaps excluded. Not a forecast.'}</p>
          </ResultCard>
        </div>

        <h3 className="section-title" style={{ fontSize: 'var(--fs-heading)' }}>{tr(L, 'derived')}</h3>
        <div className="channels">
          <ResultCard testId="card-bmi" title="BMI" result={r.derived.bmi} lang={L} digits={1} />
          <ResultCard testId="card-whtr" title={L === 'tr' ? 'Bel/boy oranı' : 'Waist/height ratio'} result={r.derived.whtr} lang={L} digits={3} unit="ratio" />
          <ResultCard title={L === 'tr' ? 'Paket-yıl' : 'Pack-years'} result={r.derived.packYears} lang={L} digits={1} />
        </div>

        <h3 className="section-title" style={{ fontSize: 'var(--fs-heading)' }}>{tr(L, 'validated')}</h3>
        <div className="channels">
          {r.external.map((e) => (
            <ResultCard key={e.modelId} testId={`ext-${e.modelId}`} title={e.title} result={e.result} lang={L}>
              <p className="hh-small hh-muted" style={{ margin: 0 }}>{e.explanation}</p>
            </ResultCard>
          ))}
          <article className="hh-card hh-result" data-class="POPULATION_BASELINE">
            <h3 style={{ margin: 0 }}>{tr(L, 'lifespanState')}</h3>
            <span className="hh-missing">{r.lifespanProjection}</span>
            <p className="hh-small hh-muted" style={{ margin: 0 }}>
              {L === 'tr'
                ? 'Aktif popülasyon paketi ya da doğrulanmış sağkalım modeli yok; kişisel yaş uydurulmaz. Alan skoru değişimi ≠ yaşam süresi değişimi.'
                : 'No population pack or validated survival model is active, so no personal age is manufactured. Domain score change ≠ lifespan change.'}
            </p>
          </article>
        </div>
        <Help topic="NOT_ELIGIBLE" lang={L}>{L === 'tr' ? 'Neden sayı yok?' : 'Why no number?'}</Help>
      </div>
    </section>
  );
}
