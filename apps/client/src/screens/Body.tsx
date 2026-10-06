import { useEffect, useRef, useState } from 'react';
import type { ProfileInputs, SmokingStatus } from '@hhos/domain';
import { NumField } from '@hhos/ui';
import type { AppCtx } from '../App.tsx';

type NumKey = { [K in keyof ProfileInputs]: ProfileInputs[K] extends number | null ? K : never }[keyof ProfileInputs];
const FIELDS: Array<{ k: NumKey; en: string; tr: string; unit: string; min: number; max: number; step?: number }> = [
  { k: 'age_years', en: 'Age', tr: 'Yaş', unit: 'y', min: 18, max: 100 },
  { k: 'height_cm', en: 'Height', tr: 'Boy', unit: 'cm', min: 120, max: 220 },
  { k: 'weight_kg', en: 'Weight', tr: 'Kilo', unit: 'kg', min: 30, max: 250, step: 0.1 },
  { k: 'waist_cm', en: 'Waist', tr: 'Bel', unit: 'cm', min: 50, max: 180 },
  { k: 'systolic_bp', en: 'Systolic BP', tr: 'Sistolik KB', unit: 'mmHg', min: 80, max: 220 },
  { k: 'diastolic_bp', en: 'Diastolic BP', tr: 'Diyastolik KB', unit: 'mmHg', min: 40, max: 140 },
  { k: 'resting_hr', en: 'Resting HR', tr: 'Dinlenik nabız', unit: 'bpm', min: 30, max: 130 },
  { k: 'sleep_hours', en: 'Sleep', tr: 'Uyku', unit: 'h', min: 0, max: 14, step: 0.1 },
  { k: 'steps_per_day', en: 'Steps', tr: 'Adım', unit: '/day', min: 0, max: 40000, step: 100 },
  { k: 'exercise_min_week', en: 'Exercise', tr: 'Egzersiz', unit: 'min/wk', min: 0, max: 1200, step: 5 },
  { k: 'alcohol_units_week', en: 'Alcohol', tr: 'Alkol', unit: 'units/wk', min: 0, max: 80 },
  { k: 'packs_per_day', en: 'Packs per day', tr: 'Günlük paket', unit: 'packs', min: 0, max: 4, step: 0.1 },
  { k: 'years_smoked', en: 'Years smoked', tr: 'Sigara yılı', unit: 'y', min: 0, max: 80 },
  { k: 'mood_1_10', en: 'Mood (self-rating)', tr: 'Ruh hâli (öz)', unit: '1–10', min: 1, max: 10 },
  { k: 'pain_0_10', en: 'Pain', tr: 'Ağrı', unit: '0–10', min: 0, max: 10 },
  { k: 'mobility_1_10', en: 'Mobility', tr: 'Hareketlilik', unit: '1–10', min: 1, max: 10 },
];

/** Edits are debounced into one revisioned write; stale writes surface REVISION_CONFLICT instead of overwriting. */
export function BodyScreen({ ctx }: { ctx: AppCtx }) {
  const L = ctx.prefs.lang;
  const self = ctx.self;
  const [draft, setDraft] = useState<Partial<ProfileInputs>>({});
  const [saved, setSaved] = useState<'idle' | 'saving' | 'saved'>('idle');
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(() => setDraft({}), [self?.id]);
  if (!self) return <p>{L === 'tr' ? 'Profil bulunamadı.' : 'No profile found.'}</p>;
  const value = (k: keyof ProfileInputs) => (k in draft ? draft[k] : self.inputs[k]);

  const change = (patch: Partial<ProfileInputs>) => {
    const next = { ...draft, ...patch };
    setDraft(next);
    setSaved('saving');
    if (timer.current) clearTimeout(timer.current);
    timer.current = setTimeout(async () => {
      try {
        await ctx.repo.updateProfile(self, { inputs: next });
        setDraft({});
        await ctx.refresh();
        setSaved('saved');
      } catch (e) {
        ctx.setError(`${(e as Error).message} — ${L === 'tr' ? 'kaydedilmedi; yenileyip tekrar dene' : 'not saved; refresh and retry'}`);
        setSaved('idle');
      }
    }, 350);
  };

  return (
    <section aria-labelledby="body-title" className="hh-card">
      <div className="hh-row" style={{ justifyContent: 'space-between' }}>
        <h2 id="body-title" style={{ margin: 0 }}>{L === 'tr' ? 'Beden ve yaşam' : 'Body & lifestyle'}</h2>
        <span className="hh-small hh-muted" data-testid="save-state" aria-live="polite">{saved === 'saving' ? (L === 'tr' ? 'kaydediliyor…' : 'saving…') : saved === 'saved' ? (L === 'tr' ? '✓ kaydedildi' : '✓ saved') : `rev ${self.revision}`}</span>
      </div>
      <p className="hh-small hh-muted">{L === 'tr' ? 'Kaynak: elle giriş. Bilinmeyen alanlar boş kalır (eksik ≠ 0).' : 'Source: manual entry. Unknown fields stay empty (missing ≠ 0).'}</p>
      <fieldset className="group">
        <legend>{L === 'tr' ? 'Sigara durumu' : 'Smoking status'}</legend>
        <select className="hh-input" aria-label="Smoking status" value={value('smoking_status') as string} onChange={(e) => change({ smoking_status: e.target.value as SmokingStatus })}>
          {['UNKNOWN', 'NEVER', 'FORMER', 'CURRENT'].map((v) => <option key={v}>{v}</option>)}
        </select>
      </fieldset>
      {FIELDS.map((f) => (
        <NumField key={f.k} testId={`body-${f.k}`} label={f[L]} unit={f.unit} min={f.min} max={f.max} step={f.step} value={value(f.k) as number | null} lang={L} onChange={(v) => change({ [f.k]: v } as Partial<ProfileInputs>)} />
      ))}
    </section>
  );
}
