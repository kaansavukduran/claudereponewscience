import { useId } from 'react';
import type { Lang } from './i18n.ts';

/** Number + slider + explicit "Unknown" toggle. Unknown sets null — never 0. */
export function NumField({
  label,
  unit,
  value,
  min,
  max,
  step = 1,
  onChange,
  lang,
  testId,
}: {
  label: string;
  unit: string;
  value: number | null;
  min: number;
  max: number;
  step?: number;
  onChange: (v: number | null) => void;
  lang: Lang;
  testId?: string;
}) {
  const id = useId();
  const missing = value === null;
  const mid = Math.round(((min + max) / 2) / step) * step;
  return (
    <div className="field" data-missing={missing}>
      <label className="name" htmlFor={id}>
        {label} <span className="unit">{unit}</span>
      </label>
      <input
        id={id}
        data-testid={testId}
        className="hh-input"
        type="number"
        inputMode="decimal"
        min={min}
        max={max}
        step={step}
        value={missing ? '' : value}
        placeholder="—"
        aria-describedby={missing ? `${id}-missing` : undefined}
        onChange={(e) => {
          const raw = e.target.value;
          if (raw === '') return onChange(null);
          const n = Number(raw);
          if (Number.isFinite(n)) onChange(n);
        }}
      />
      <input
        type="range"
        aria-label={`${label} slider`}
        min={min}
        max={max}
        step={step}
        value={missing ? mid : value}
        disabled={missing}
        onChange={(e) => onChange(Number(e.target.value))}
      />
      <label className="unknown">
        <input type="checkbox" checked={missing} onChange={(e) => onChange(e.target.checked ? null : mid)} />
        <span id={`${id}-missing`}>{lang === 'tr' ? 'Bilinmiyor (eksik ≠ 0)' : 'Unknown (missing ≠ 0)'}</span>
      </label>
    </div>
  );
}
