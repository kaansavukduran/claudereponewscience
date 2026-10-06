import { LESSONS } from '@hhos/packs';
import { Chip } from '@hhos/ui';
import type { ViewProps } from '../App.tsx';

export function LearnLab({ s, d }: ViewProps) {
  const L = s.lang;
  const idx = Math.min(s.learn.lessonIdx, LESSONS.length - 1);
  const lesson = LESSONS[idx]!;
  const answered = Object.keys(s.learn.answers).length;
  const correct = Object.entries(s.learn.answers).filter(([k, v]) => {
    const [id, q] = k.split('#');
    return LESSONS.find((l) => l.id === id)?.quiz[Number(q) as 0 | 1].correct === v;
  }).length;

  return (
    <section aria-labelledby="le-title" className="split">
      <div className="hh-card editor">
        <h2 id="le-title" className="section-title">{L === 'tr' ? 'Öğren' : 'Learn'}</h2>
        <p className="hh-small hh-muted">EDU-HEALTH-LITERACY-FOUNDATION-1 · {L === 'tr' ? 'çevrimdışı' : 'offline'}</p>
        <ol style={{ margin: 0, paddingLeft: 20 }}>
          {LESSONS.map((l, i) => (
            <li key={l.id}>
              <button className="tab" aria-current={i === idx ? 'page' : undefined} onClick={() => d({ type: 'learn', patch: { lessonIdx: i } })}>{l.title[L]}</button>
            </li>
          ))}
        </ol>
        <div className="hh-row" style={{ marginTop: 8 }}>
          <Chip tone="info">{L === 'tr' ? 'Yanıtlanan' : 'Answered'} {answered}/{LESSONS.length * 2}</Chip>
          <Chip tone="ok">{L === 'tr' ? 'Doğru' : 'Correct'} {correct}</Chip>
        </div>
        <p className="hh-small hh-muted">{L === 'tr' ? 'Okumak ≠ anlamak. Quiz ≠ sağlık iyileşmesi. Öğrenme XP ≠ sağlık skoru.' : 'Viewed ≠ understood. Quiz ≠ health improvement. Learning XP ≠ health score.'}</p>
      </div>
      <article className="hh-card" style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        <div className="hh-label">{lesson.id}</div>
        <h3 style={{ fontSize: 'var(--fs-title)' }}>{lesson.title[L]}</h3>
        <p style={{ margin: 0 }}>{lesson.body[L]}</p>
        <p className="callout" style={{ margin: 0 }}>{L === 'tr' ? 'Örnek' : 'Example'}: {lesson.example[L]}</p>
        {lesson.quiz.map((q, qi) => {
          const key = `${lesson.id}#${qi}`;
          const chosen = s.learn.answers[key];
          return (
            <div key={key} className="mcq" role="group" aria-labelledby={`${key}-q`}>
              <strong id={`${key}-q`}>{qi + 1}. {q.q[L]}</strong>
              {q.options.map((o, oi) => (
                <button
                  key={oi}
                  className="hh-btn"
                  data-testid={`mcq-${lesson.id}-${qi}-${oi}`}
                  data-result={chosen === undefined ? undefined : oi === q.correct ? 'right' : oi === chosen ? 'wrong' : undefined}
                  aria-pressed={chosen === oi}
                  onClick={() => d({ type: 'learn', patch: { answers: { ...s.learn.answers, [key]: oi } } })}
                >
                  {o[L]}
                  {chosen !== undefined && oi === q.correct ? ' ✓' : chosen === oi ? ' ✗' : ''}
                </button>
              ))}
              {chosen !== undefined ? <p className="hh-small" aria-live="polite">{q.why[L]}</p> : null}
            </div>
          );
        })}
        <details>
          <summary style={{ cursor: 'pointer', fontWeight: 600 }}>{L === 'tr' ? 'Transfer sorusu' : 'Transfer question'}: {lesson.transfer.q[L]}</summary>
          <p>{lesson.transfer.a[L]}</p>
        </details>
        <div className="hh-row">
          <button className="hh-btn" disabled={idx === 0} onClick={() => d({ type: 'learn', patch: { lessonIdx: idx - 1 } })}>← {L === 'tr' ? 'Önceki' : 'Previous'}</button>
          <button className="hh-btn primary" disabled={idx === LESSONS.length - 1} onClick={() => d({ type: 'learn', patch: { lessonIdx: idx + 1 } })}>{L === 'tr' ? 'Sonraki' : 'Next'} →</button>
        </div>
      </article>
    </section>
  );
}
