// Behavioural UI contracts shared by Site Lab and production client (doc 87 / v0.19):
// MetricValue never renders missing as 0; ResultCard always shows its result class;
// HowCalculated exposes model/rule ID, version, inputs, missing inputs, coverage and limitations.

import type { ReactNode } from 'react';
import type { CalcResult, Confidence } from '@hhos/domain';
import { RESULT_CLASS_LABEL, tr, type Lang } from './i18n.ts';

export type Tone = 'ok' | 'warn' | 'risk' | 'info' | 'muted' | 'synthetic' | 'protection' | 'burden' | 'function';

const GLYPH: Record<Tone, string> = { ok: '✓', warn: '⚠', risk: '✗', info: 'ℹ', muted: '○', synthetic: '◆', protection: '▲', burden: '▼', function: '◇' };

export function Chip({ tone, children, title }: { tone: Tone; children: ReactNode; title?: string }) {
  return (
    <span className="hh-chip" data-tone={tone} title={title}>
      <span aria-hidden="true">{GLYPH[tone]}</span>
      {children}
    </span>
  );
}

export function fmt(x: number | null | undefined, digits = 1): string {
  if (x === null || x === undefined || !Number.isFinite(x)) return '—';
  return x.toLocaleString('en-US', { maximumFractionDigits: digits, minimumFractionDigits: 0 });
}

export function statusLabel(lang: Lang, r: Pick<CalcResult, 'status' | 'errorCode'>): string {
  switch (r.status) {
    case 'MISSING_INPUT':
      return r.errorCode === 'INSUFFICIENT_COVERAGE' ? tr(lang, 'insufficient') : tr(lang, 'missingValue');
    case 'NOT_ELIGIBLE':
      return tr(lang, 'notEligible');
    case 'UNAVAILABLE':
      return tr(lang, 'unavailable');
    case 'INVALID_INPUT':
      return tr(lang, 'invalid');
    default:
      return '';
  }
}

/** Renders a value or an explicit non-numeric state. Never 0 for missing. */
export function MetricValue({ result, lang, digits = 1, scale = 1, unit }: { result: CalcResult; lang: Lang; digits?: number; scale?: number; unit?: string }) {
  if (result.status !== 'OK' || result.value === null) {
    return (
      <span className="hh-missing" data-state={result.status}>
        {statusLabel(lang, result)}
        {result.errorCode ? <span className="hh-mono hh-small"> · {result.errorCode}</span> : null}
      </span>
    );
  }
  return (
    <span className="hh-metric" aria-label={`${fmt(result.value * scale, digits)} ${unit ?? result.unit ?? ''}`}>
      {fmt(result.value * scale, digits)}
      <small>{unit ?? result.unit ?? ''}</small>
    </span>
  );
}

export function HowCalculated({ result, lang, extra }: { result: CalcResult & { coverage?: number | null; confidence?: Confidence }; lang: Lang; extra?: ReactNode }) {
  const inputs = Object.entries(result.inputs ?? {});
  return (
    <details className="hh-how">
      <summary>{tr(lang, 'howCalculated')}</summary>
      <dl className="hh-kv">
        <dt>{tr(lang, 'resultClass')}</dt>
        <dd>{RESULT_CLASS_LABEL[result.resultClass]?.[lang] ?? result.resultClass}</dd>
        <dt>{tr(lang, 'model')}</dt>
        <dd className="hh-mono">{result.modelId}</dd>
        <dt>{tr(lang, 'version')}</dt>
        <dd className="hh-mono">{result.version}</dd>
        <dt>{tr(lang, 'inputs')}</dt>
        <dd className="hh-mono">{inputs.length ? inputs.map(([k, v]) => `${k}=${v === null ? 'null' : typeof v === 'object' ? JSON.stringify(v) : String(typeof v === 'number' ? Math.round(v * 1000) / 1000 : v)}`).join(' · ') : tr(lang, 'none')}</dd>
        <dt>{tr(lang, 'missingInputs')}</dt>
        <dd className="hh-mono">{result.missingInputs.length ? result.missingInputs.join(', ') : tr(lang, 'none')}</dd>
        {result.coverage !== undefined ? (
          <>
            <dt>{tr(lang, 'coverage')}</dt>
            <dd>{result.coverage === null ? '—' : `${fmt(result.coverage * 100, 0)}%`} · {result.confidence}</dd>
          </>
        ) : null}
        <dt>{tr(lang, 'limitations')}</dt>
        <dd>
          {result.limitations.length ? (
            <ul style={{ margin: 0, paddingLeft: 16 }}>
              {result.limitations.map((l) => (
                <li key={l}>{l}</li>
              ))}
            </ul>
          ) : (
            tr(lang, 'none')
          )}
        </dd>
      </dl>
      {extra}
    </details>
  );
}

export function Bar({ value, channel, label }: { value: number | null; channel: string; label: string }) {
  if (value === null) return <div className="hh-bar" role="img" aria-label={`${label}: no value`} />;
  const pct = Math.max(0, Math.min(100, value));
  return (
    <div className="hh-bar" data-channel={channel} role="img" aria-label={`${label}: ${fmt(pct, 0)} of 100`}>
      <span style={{ width: `${pct}%` }} />
    </div>
  );
}

const CHANNEL_TONE: Record<string, Tone> = { PROTECTION: 'protection', BURDEN: 'burden', FUNCTION: 'function', COVERAGE: 'info' };

export function ResultCard({
  title,
  result,
  lang,
  channel,
  scale = 1,
  unit,
  digits = 1,
  bar,
  children,
  testId,
}: {
  title: string;
  result: CalcResult & { coverage?: number | null; confidence?: Confidence };
  lang: Lang;
  channel?: string;
  scale?: number;
  unit?: string;
  digits?: number;
  bar?: boolean;
  children?: ReactNode;
  testId?: string;
}) {
  return (
    <article className="hh-card hh-result" data-channel={channel} data-class={result.resultClass} data-testid={testId} aria-live="polite">
      <div className="hh-row" style={{ justifyContent: 'space-between' }}>
        <h3 style={{ margin: 0 }}>{title}</h3>
        <Chip tone={channel ? (CHANNEL_TONE[channel] ?? 'muted') : 'muted'}>{RESULT_CLASS_LABEL[result.resultClass]?.[lang] ?? result.resultClass}</Chip>
      </div>
      <MetricValue result={result} lang={lang} scale={scale} unit={unit} digits={digits} />
      {bar ? <Bar value={result.status === 'OK' ? (result.value as number) * scale : null} channel={channel ?? ''} label={title} /> : null}
      {result.coverage !== undefined ? (
        <div className="hh-row hh-small hh-muted">
          <span>
            {tr(lang, 'coverage')}: {result.coverage === null ? '—' : `${fmt(result.coverage * 100, 0)}%`}
          </span>
          <Chip tone={result.confidence === 'HIGH' ? 'ok' : result.confidence === 'MODERATE' ? 'info' : 'warn'}>
            {tr(lang, 'confidence')}: {result.confidence}
          </Chip>
        </div>
      ) : null}
      {children}
      <HowCalculated result={result} lang={lang} />
    </article>
  );
}

/** Accessible line/point chart with gaps for missing values and dashed method-discontinuity markers. */
export function TrendChart({
  points,
  unit,
  title,
  band,
  height = 160,
}: {
  points: Array<{ x: string; y: number | null; discontinuity?: boolean; label?: string }>;
  unit: string;
  title: string;
  band?: { low: number | null; high: number | null } | null;
  height?: number;
}) {
  const w = 560;
  const pad = { l: 40, r: 12, t: 12, b: 28 };
  const ys = points.map((p) => p.y).filter((y): y is number => y !== null);
  if (!ys.length) return <p className="hh-missing">{title}: no numeric values yet (missing ≠ 0)</p>;
  const lo = Math.min(...ys, band?.low ?? Infinity) * 0.9;
  const hi = Math.max(...ys, band?.high ?? -Infinity) * 1.08;
  const X = (i: number) => pad.l + (i * (w - pad.l - pad.r)) / Math.max(1, points.length - 1);
  const Y = (v: number) => pad.t + (1 - (v - lo) / (hi - lo || 1)) * (height - pad.t - pad.b);
  const segs: string[] = [];
  let cur = '';
  points.forEach((p, i) => {
    if (p.y === null || p.discontinuity) {
      if (cur) segs.push(cur);
      cur = p.y === null ? '' : `M${X(i)},${Y(p.y)}`;
      return;
    }
    cur += `${cur ? 'L' : 'M'}${X(i)},${Y(p.y)}`;
  });
  if (cur) segs.push(cur);
  return (
    <figure style={{ margin: 0 }}>
      <svg viewBox={`0 0 ${w} ${height}`} width="100%" role="img" aria-label={`${title} (${unit}). See data table below.`} style={{ display: 'block', maxHeight: height + 40 }}>
        {[lo, (lo + hi) / 2, hi].map((t) => (
          <g key={t}>
            <line x1={pad.l} x2={w - pad.r} y1={Y(t)} y2={Y(t)} stroke="var(--border)" />
            <text x={pad.l - 6} y={Y(t) + 4} textAnchor="end" fontSize="10" fill="var(--text-3)">{fmt(t, 1)}</text>
          </g>
        ))}
        {segs.map((d) => (
          <path key={d} d={d} fill="none" stroke="var(--accent)" strokeWidth="2" />
        ))}
        {points.map((p, i) =>
          p.discontinuity ? (
            <g key={`d${i}`}>
              <line x1={X(i) - (X(1) - X(0)) / 2} x2={X(i) - (X(1) - X(0)) / 2} y1={pad.t} y2={height - pad.b} stroke="var(--warning)" strokeDasharray="4 3" />
              <text x={X(i) - (X(1) - X(0)) / 2 + 3} y={pad.t + 10} fontSize="10" fill="var(--warning)">method ≠</text>
            </g>
          ) : null,
        )}
        {points.map((p, i) =>
          p.y === null ? (
            <text key={i} x={X(i)} y={height - pad.b - 4} textAnchor="middle" fontSize="10" fill="var(--text-3)">n/r</text>
          ) : (
            <circle key={i} cx={X(i)} cy={Y(p.y)} r="4" fill="var(--surface-1)" stroke="var(--accent)" strokeWidth="2" />
          ),
        )}
        {points.map((p, i) => (
          <text key={`x${i}`} x={X(i)} y={height - 8} textAnchor="middle" fontSize="10" fill="var(--text-3)">{p.x.slice(2)}</text>
        ))}
      </svg>
    </figure>
  );
}
