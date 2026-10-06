// Human Health OS API (/v1). Owns HTTP/auth/persistence orchestration — NOT medical formulas:
// every calculation is delegated to @hhos/domain, the same code the Site Lab and client run offline.

import { createHash, randomBytes, randomUUID } from 'node:crypto';
import type { IncomingMessage, ServerResponse } from 'node:http';
import {
  DOMAIN_VERSION,
  HANDOFF_BASELINE,
  MODULE_IDS,
  applyMissionEvent,
  applyPatch,
  cloneAsScenario,
  compareProfiles,
  computeProfileResults,
  defaultModules,
  emptyInputs,
  generateMissions,
  interpretLabResult,
  type BodyProfile,
  type CalcResult,
  type Mission,
  type MissionEvent,
  type ProfileInputs,
  type ReferenceIntervalSnapshot,
} from '@hhos/domain';
import { ATTRIBUTION_MANIFEST, DEMO_PROGRAM, PACK_CATALOG, syntheticProfiles } from '@hhos/packs';
import { type Db, tx } from './db.ts';

export interface AppConfig {
  env: 'development' | 'test' | 'staging' | 'production';
}

class ApiError extends Error {
  status: number;
  code: string;
  retryable: boolean;
  details: unknown;
  fieldErrors: Array<{ field: string; code: string }> | undefined;
  constructor(status: number, code: string, message: string, opts: { retryable?: boolean; details?: unknown; fieldErrors?: Array<{ field: string; code: string }> } = {}) {
    super(message);
    this.status = status;
    this.code = code;
    this.retryable = opts.retryable ?? false;
    this.details = opts.details ?? null;
    this.fieldErrors = opts.fieldErrors;
  }
}

interface Ctx {
  req: IncomingMessage;
  requestId: string;
  userId: string | null;
  body: unknown;
  params: Record<string, string>;
  query: URLSearchParams;
}

type Handler = (ctx: Ctx) => { status: number; body: unknown; headers?: Record<string, string> };

interface Route {
  method: string;
  pattern: RegExp;
  keys: string[];
  auth: 'PUBLIC' | 'AUTHENTICATED_OWNER' | 'DEV_ONLY';
  idempotent?: boolean;
  handler: Handler;
}

const now = () => new Date().toISOString();
const sha = (s: string) => createHash('sha256').update(s).digest('hex');

interface ProfileRow {
  id: string;
  owner_user_id: string;
  name: string;
  profile_type: BodyProfile['profile_type'];
  synthetic: number;
  source_profile_id: string | null;
  modules_json: string;
  inputs_json: string;
  revision: number;
  created_at: string;
  updated_at: string;
}

function rowToProfile(r: ProfileRow): BodyProfile & { revision: number } {
  return {
    id: r.id,
    name: r.name,
    profile_type: r.profile_type,
    synthetic: r.synthetic === 1,
    source_profile_id: r.source_profile_id,
    pinned_baseline: false,
    modules: { ...defaultModules(), ...JSON.parse(r.modules_json) },
    inputs: { ...emptyInputs(), ...JSON.parse(r.inputs_json) },
    revision: r.revision,
  };
}

const INPUT_KEYS = new Set(Object.keys(emptyInputs()));

function validateInputs(patch: unknown): Partial<ProfileInputs> {
  if (patch === undefined) return {};
  if (typeof patch !== 'object' || patch === null || Array.isArray(patch)) throw new ApiError(400, 'VALIDATION_ERROR', 'inputs must be an object');
  const errs: Array<{ field: string; code: string }> = [];
  for (const [k, v] of Object.entries(patch)) {
    if (!INPUT_KEYS.has(k)) errs.push({ field: `inputs.${k}`, code: 'UNKNOWN_FIELD' });
    else if (k === 'conditions') {
      if (!Array.isArray(v)) errs.push({ field: 'inputs.conditions', code: 'EXPECTED_ARRAY' });
    } else if (k === 'smoking_status') {
      if (!['NEVER', 'FORMER', 'CURRENT', 'UNKNOWN'].includes(v as string)) errs.push({ field: 'inputs.smoking_status', code: 'INVALID_ENUM' });
    } else if (v !== null && (typeof v !== 'number' || !Number.isFinite(v))) errs.push({ field: `inputs.${k}`, code: 'EXPECTED_NUMBER_OR_NULL' });
  }
  if (errs.length) throw new ApiError(400, 'VALIDATION_ERROR', 'Invalid profile inputs', { fieldErrors: errs });
  return patch as Partial<ProfileInputs>;
}

export function createApp(db: Db, config: AppConfig) {
  const routes: Route[] = [];
  const route = (method: string, path: string, auth: Route['auth'], handler: Handler, idempotent = false) => {
    const keys: string[] = [];
    const pattern = new RegExp(
      '^' + path.replace(/:([a-zA-Z]+)/g, (_m, k: string) => {
        keys.push(k);
        return '([^/]+)';
      }) + '$',
    );
    routes.push({ method, pattern, keys, auth, handler, idempotent });
  };

  /** Ownership resolved from authenticated server identity; foreign IDs → 404 (no disclosure). */
  const ownedProfile = (ctx: Ctx, id: string): ProfileRow => {
    const row = db.prepare('SELECT * FROM profiles WHERE id = ? AND deleted_at IS NULL').get(id) as ProfileRow | undefined;
    if (!row || row.owner_user_id !== ctx.userId) throw new ApiError(404, 'NOT_FOUND', 'Profile not found');
    return row;
  };

  const audit = (ctx: Ctx, action: string, resource: string) =>
    db.prepare('INSERT INTO audit_events (user_id, action, resource, request_id, at) VALUES (?, ?, ?, ?, ?)').run(ctx.userId, action, resource, ctx.requestId, now());

  const insertProfile = (owner: string, p: BodyProfile) => {
    const t = now();
    db.prepare(
      `INSERT INTO profiles (id, owner_user_id, name, profile_type, synthetic, source_profile_id, modules_json, inputs_json, revision, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)`,
    ).run(p.id, owner, p.name, p.profile_type, p.synthetic ? 1 : 0, p.source_profile_id, JSON.stringify(p.modules), JSON.stringify(p.inputs), t, t);
  };

  // ---------- PUBLIC ----------
  route('GET', '/v1/health', 'PUBLIC', () => ({ status: 200, body: { status: 'ok', domain_version: DOMAIN_VERSION, handoff_baseline: HANDOFF_BASELINE, env: config.env } }));
  route('GET', '/v1/packs', 'PUBLIC', () => ({ status: 200, body: { items: PACK_CATALOG } }));
  route('GET', '/v1/attribution', 'PUBLIC', () => ({ status: 200, body: { items: ATTRIBUTION_MANIFEST } }));

  // ---------- DEV AUTH (placeholder for a real identity provider; disabled in production) ----------
  route('POST', '/v1/auth/dev-session', 'DEV_ONLY', (ctx) => {
    const name = (ctx.body as { display_name?: string } | null)?.display_name ?? 'Developer';
    const userId = `USR-${randomUUID()}`;
    const token = randomBytes(24).toString('base64url');
    tx(db, () => {
      db.prepare('INSERT INTO users (id, display_name, created_at) VALUES (?, ?, ?)').run(userId, String(name).slice(0, 80), now());
      db.prepare('INSERT INTO sessions (token_hash, user_id, created_at) VALUES (?, ?, ?)').run(sha(token), userId, now());
    });
    return { status: 201, body: { user_id: userId, token, warning: 'DEV_SESSION_NOT_FOR_PRODUCTION' } };
  });

  // ---------- PROFILES ----------
  route('GET', '/v1/profiles', 'AUTHENTICATED_OWNER', (ctx) => {
    const rows = db.prepare('SELECT * FROM profiles WHERE owner_user_id = ? AND deleted_at IS NULL ORDER BY created_at, id').all(ctx.userId) as unknown as ProfileRow[];
    return { status: 200, body: { items: rows.map(rowToProfile), next_cursor: null, has_more: false } };
  });

  route('POST', '/v1/profiles', 'AUTHENTICATED_OWNER', (ctx) => {
    const b = (ctx.body ?? {}) as { name?: string; profile_type?: string; synthetic?: boolean; inputs?: unknown; modules?: Record<string, boolean> };
    if (!b.name || typeof b.name !== 'string') throw new ApiError(400, 'VALIDATION_ERROR', 'name is required', { fieldErrors: [{ field: 'name', code: 'REQUIRED' }] });
    const type = (b.profile_type ?? 'SELF') as BodyProfile['profile_type'];
    if (!['SELF', 'REAL_OTHER', 'SYNTHETIC'].includes(type)) throw new ApiError(400, 'VALIDATION_ERROR', 'profile_type invalid (use /scenarios to clone)');
    const modules = { ...defaultModules() };
    for (const [k, v] of Object.entries(b.modules ?? {})) if ((MODULE_IDS as readonly string[]).includes(k)) modules[k as keyof typeof modules] = !!v;
    const p: BodyProfile = {
      id: `PRF-${randomUUID()}`,
      name: b.name.slice(0, 120),
      profile_type: type,
      synthetic: !!b.synthetic,
      source_profile_id: null,
      pinned_baseline: false,
      modules,
      // A new profile can be almost blank: nothing is invented (AT-825).
      inputs: { ...emptyInputs(), ...validateInputs(b.inputs) },
    };
    insertProfile(ctx.userId as string, p);
    audit(ctx, 'PROFILE_CREATE', p.id);
    return { status: 201, body: rowToProfile(ownedProfile(ctx, p.id)) };
  }, true);

  route('GET', '/v1/profiles/:profileId', 'AUTHENTICATED_OWNER', (ctx) => ({ status: 200, body: rowToProfile(ownedProfile(ctx, ctx.params.profileId as string)) }));

  route('PATCH', '/v1/profiles/:profileId', 'AUTHENTICATED_OWNER', (ctx) => {
    const row = ownedProfile(ctx, ctx.params.profileId as string);
    const ifMatch = ctx.req.headers['if-match'];
    if (!ifMatch) throw new ApiError(428, 'VALIDATION_ERROR', 'If-Match revision header is required');
    if (Number(String(ifMatch).replace(/"/g, '')) !== row.revision)
      throw new ApiError(409, 'REVISION_CONFLICT', 'Profile changed since your base revision', { details: { current_revision: row.revision, updated_at: row.updated_at } });
    const b = (ctx.body ?? {}) as { name?: string; inputs?: unknown; modules?: Record<string, boolean> };
    const current = rowToProfile(row);
    const next = applyPatch(current, validateInputs(b.inputs));
    for (const [k, v] of Object.entries(b.modules ?? {})) if ((MODULE_IDS as readonly string[]).includes(k)) next.modules[k as keyof typeof next.modules] = !!v;
    const res = db
      .prepare('UPDATE profiles SET name = ?, inputs_json = ?, modules_json = ?, revision = revision + 1, updated_at = ? WHERE id = ? AND revision = ?')
      .run(typeof b.name === 'string' ? b.name.slice(0, 120) : row.name, JSON.stringify(next.inputs), JSON.stringify(next.modules), now(), row.id, row.revision);
    if (res.changes !== 1) throw new ApiError(409, 'REVISION_CONFLICT', 'Concurrent update');
    audit(ctx, 'PROFILE_UPDATE', row.id);
    return { status: 200, body: rowToProfile(ownedProfile(ctx, row.id)) };
  });

  route('POST', '/v1/profiles/:profileId/scenarios', 'AUTHENTICATED_OWNER', (ctx) => {
    const src = rowToProfile(ownedProfile(ctx, ctx.params.profileId as string));
    const b = (ctx.body ?? {}) as { name?: string; patch?: unknown };
    const scn = applyPatch(cloneAsScenario(src, `SCN-${randomUUID()}`, String(b.name ?? `${src.name} · scenario`).slice(0, 120)), validateInputs(b.patch));
    insertProfile(ctx.userId as string, scn);
    audit(ctx, 'SCENARIO_CREATE', scn.id);
    return { status: 201, body: rowToProfile(ownedProfile(ctx, scn.id)) };
  }, true);

  // ---------- DEMO SEED (idempotent; synthetic only, never into a real profile) ----------
  route('POST', '/v1/demo/seed', 'AUTHENTICATED_OWNER', (ctx) => {
    const created: string[] = [];
    tx(db, () => {
      for (const p of syntheticProfiles()) {
        const id = `${p.id}--${(ctx.userId as string).slice(4, 12)}`;
        const exists = db.prepare('SELECT 1 FROM profiles WHERE id = ?').get(id);
        if (!exists) {
          insertProfile(ctx.userId as string, { ...p, id });
          created.push(id);
        }
      }
    });
    return { status: 200, body: { created, label: 'SYNTHETIC DEMO DATA' } };
  });

  // ---------- LABS ----------
  route('GET', '/v1/profiles/:profileId/labs', 'AUTHENTICATED_OWNER', (ctx) => {
    const p = ownedProfile(ctx, ctx.params.profileId as string);
    const items = db.prepare('SELECT * FROM lab_results WHERE profile_id = ? AND deleted_at IS NULL ORDER BY observed_at, id').all(p.id);
    return { status: 200, body: { items, next_cursor: null, has_more: false } };
  });

  route('POST', '/v1/profiles/:profileId/labs', 'AUTHENTICATED_OWNER', (ctx) => {
    const p = ownedProfile(ctx, ctx.params.profileId as string);
    const b = (ctx.body ?? {}) as Record<string, unknown>;
    const errs: Array<{ field: string; code: string }> = [];
    const state = (b.result_state ?? (b.numeric_value === null || b.numeric_value === undefined ? 'NOT_REPORTED' : 'PRESENT')) as string;
    if (!['PRESENT', 'NOT_REPORTED', 'UNREADABLE'].includes(state)) errs.push({ field: 'result_state', code: 'INVALID_ENUM' });
    if (state === 'PRESENT' && (typeof b.numeric_value !== 'number' || !Number.isFinite(b.numeric_value))) errs.push({ field: 'numeric_value', code: 'REQUIRED_WHEN_PRESENT' });
    if (state !== 'PRESENT' && b.numeric_value !== null && b.numeric_value !== undefined) errs.push({ field: 'numeric_value', code: 'MUST_BE_NULL_WHEN_MISSING' });
    if (!b.analyte_key) errs.push({ field: 'analyte_key', code: 'REQUIRED' });
    if (!b.unit) errs.push({ field: 'unit', code: 'REQUIRED' });
    if (!b.observed_at) errs.push({ field: 'observed_at', code: 'REQUIRED' });
    if (errs.length) throw new ApiError(400, 'VALIDATION_ERROR', 'Invalid lab result', { fieldErrors: errs });
    const id = `LAB-${randomUUID()}`;
    db.prepare(
      `INSERT INTO lab_results (id, profile_id, analyte_key, result_state, numeric_value, unit, specimen, method_id, laboratory, observed_at, source_flag, ref_interval_json, provenance, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    ).run(id, p.id, String(b.analyte_key), state, state === 'PRESENT' ? (b.numeric_value as number) : null, String(b.unit), (b.specimen as string) ?? null, (b.method_id as string) ?? null, (b.laboratory as string) ?? null, String(b.observed_at), (b.source_flag as string) ?? null, b.reference_interval ? JSON.stringify(b.reference_interval) : null, String(b.provenance ?? 'MANUAL'), now());
    audit(ctx, 'LAB_CREATE', id);
    return { status: 201, body: db.prepare('SELECT * FROM lab_results WHERE id = ?').get(id) };
  }, true);

  route('GET', '/v1/profiles/:profileId/labs/:labId/interpretation', 'AUTHENTICATED_OWNER', (ctx) => {
    const p = ownedProfile(ctx, ctx.params.profileId as string);
    type LabRow = { id: string; analyte_key: string; result_state: string; numeric_value: number | null; unit: string; specimen: string | null; method_id: string | null; laboratory: string | null; observed_at: string; source_flag: string | null; ref_interval_json: string | null };
    const lab = db.prepare('SELECT * FROM lab_results WHERE id = ? AND profile_id = ? AND deleted_at IS NULL').get(ctx.params.labId as string, p.id) as LabRow | undefined;
    if (!lab) throw new ApiError(404, 'NOT_FOUND', 'Lab result not found');
    const history = db
      .prepare("SELECT * FROM lab_results WHERE profile_id = ? AND analyte_key = ? AND observed_at < ? AND deleted_at IS NULL AND result_state = 'PRESENT' ORDER BY observed_at")
      .all(p.id, lab.analyte_key, lab.observed_at) as unknown as LabRow[];
    const prior = history.at(-1) ?? null;
    const toInput = (r: LabRow) => ({ analyte_key: r.analyte_key, value: r.numeric_value, unit: r.unit, specimen: r.specimen, method_id: r.method_id, laboratory: r.laboratory, observed_at: r.observed_at, source_flag: r.source_flag });
    const ri = lab.ref_interval_json ? (JSON.parse(lab.ref_interval_json) as ReferenceIntervalSnapshot) : null;
    const assessment = interpretLabResult({
      result: toInput(lab),
      reference: ri ? [ri] : [],
      context: {},
      decision_rules: [],
      // No real critical rule pack is installed server-side → NO_ACTIVE_RULE, never an invented threshold.
      critical_rules: [],
      prior: prior ? toInput(prior) : null,
      comparability_records: [],
      // No source-approved biological-variation pack → RCV reports NO_RCV_SOURCE.
      rcv: null,
      baseline_points: history.filter((h) => h.method_id === lab.method_id && h.specimen === lab.specimen).map((h) => h.numeric_value),
    });
    return { status: 200, body: assessment };
  });

  // ---------- SCORES ----------
  route('POST', '/v1/profiles/:profileId/scores/compute', 'AUTHENTICATED_OWNER', (ctx) => {
    const row = ownedProfile(ctx, ctx.params.profileId as string);
    const profile = rowToProfile(row);
    const r = computeProfileResults(profile);
    const calcAt = now();
    const results: CalcResult[] = [r.derived.bmi, r.derived.whtr, r.derived.packYears, r.protection, r.burden, r.function, r.balance, r.coverage, ...r.external.map((e) => e.result)];
    tx(db, () => {
      for (const s of results) {
        db.prepare(
          `INSERT INTO score_results (id, profile_id, model_id, model_version, result_class, status, numeric_output, error_code, input_record_ids_json, payload_json, hypothetical, calculated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        ).run(`SCR-${randomUUID()}`, row.id, s.modelId, s.version, s.resultClass, s.status, s.status === 'OK' ? (s.value as number) : null, s.errorCode, JSON.stringify([`${row.id}@rev${row.revision}`]), JSON.stringify(s), r.hypothetical ? 1 : 0, calcAt);
      }
    });
    return { status: 200, body: { profile_revision: row.revision, calculated_at: calcAt, results: r } };
  });

  route('GET', '/v1/profiles/:profileId/scores', 'AUTHENTICATED_OWNER', (ctx) => {
    const p = ownedProfile(ctx, ctx.params.profileId as string);
    const items = (db.prepare('SELECT * FROM score_results WHERE profile_id = ? ORDER BY calculated_at DESC, model_id').all(p.id) as Array<Record<string, unknown>>).map((x) => ({ ...x, payload_json: undefined, payload: JSON.parse(x.payload_json as string) }));
    return { status: 200, body: { items, next_cursor: null, has_more: false } };
  });

  // ---------- MISSIONS ----------
  const missionRow = (m: Mission) => ({ ...m });
  route('POST', '/v1/profiles/:profileId/missions/generate', 'AUTHENTICATED_OWNER', (ctx) => {
    const p = ownedProfile(ctx, ctx.params.profileId as string);
    const date = String((ctx.body as { date?: string } | null)?.date ?? '');
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date)) throw new ApiError(400, 'VALIDATION_ERROR', 'date must be YYYY-MM-DD');
    const existing = db.prepare('SELECT * FROM missions WHERE profile_id = ? AND generated_for_date = ? ORDER BY id').all(p.id, date);
    // Historical missions keep the rule version originally used (AT-432): never regenerated in place.
    if (existing.length) return { status: 200, body: { items: existing, generated: false } };
    const ms = generateMissions({ profile_id: p.id, date, program: DEMO_PROGRAM, sessions: [], safety_flags: [], last_mood_checkin_date: null, next_lesson_id: 'EDU-001', preventive_review_needed: false });
    tx(db, () => {
      for (const m of ms)
        db.prepare(
          `INSERT INTO missions (id, profile_id, generated_for_date, category, mission_type, title, rationale, target, source_rule_id, source_rule_version, status, completion_record_ids_json, xp, created_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        ).run(m.id, p.id, date, m.category, m.mission_type, m.title, m.rationale, m.target, m.source_rule_id, m.source_rule_version, m.status, JSON.stringify(m.completion_record_ids), m.xp, now());
    });
    return { status: 201, body: { items: db.prepare('SELECT * FROM missions WHERE profile_id = ? AND generated_for_date = ? ORDER BY id').all(p.id, date), generated: true } };
  });

  route('POST', '/v1/profiles/:profileId/missions/:missionId/events', 'AUTHENTICATED_OWNER', (ctx) => {
    const p = ownedProfile(ctx, ctx.params.profileId as string);
    const row = db.prepare('SELECT * FROM missions WHERE id = ? AND profile_id = ?').get(ctx.params.missionId as string, p.id) as Record<string, unknown> | undefined;
    if (!row) throw new ApiError(404, 'NOT_FOUND', 'Mission not found');
    const ev = ctx.body as MissionEvent;
    if (!ev || !['NOTIFICATION_DELIVERED', 'NOTIFICATION_OPENED', 'STARTED', 'COMPLETED', 'SKIPPED'].includes(ev.kind)) throw new ApiError(400, 'VALIDATION_ERROR', 'invalid event kind');
    if (ev.kind === 'COMPLETED' && !ev.completion_record_id) throw new ApiError(400, 'VALIDATION_ERROR', 'COMPLETED requires completion_record_id', { fieldErrors: [{ field: 'completion_record_id', code: 'REQUIRED' }] });
    const m: Mission = { ...(row as unknown as Mission), completion_record_ids: JSON.parse(row.completion_record_ids_json as string) };
    const next = applyMissionEvent(m, ev);
    db.prepare('UPDATE missions SET status = ?, completion_record_ids_json = ? WHERE id = ?').run(next.status, JSON.stringify(next.completion_record_ids), m.id);
    return { status: 200, body: missionRow(next) };
  });

  // ---------- COMPARE ----------
  route('POST', '/v1/compare', 'AUTHENTICATED_OWNER', (ctx) => {
    const b = (ctx.body ?? {}) as { profile_ids?: string[]; baseline_id?: string };
    if (!Array.isArray(b.profile_ids) || b.profile_ids.length < 1) throw new ApiError(400, 'VALIDATION_ERROR', 'profile_ids required');
    const profiles = b.profile_ids.map((id) => rowToProfile(ownedProfile(ctx, id)));
    const rows = compareProfiles(profiles, b.baseline_id ?? profiles[0]?.id ?? null);
    return { status: 200, body: { baseline_id: b.baseline_id ?? profiles[0]?.id, rows: rows.map((r) => ({ metric: { id: r.metric.id, label: r.metric.label, unit: r.metric.unit, result_class: r.metric.resultClass }, cells: r.cells })) } };
  });

  // ---------- DISPATCH ----------
  async function readBody(req: IncomingMessage): Promise<unknown> {
    if (req.method === 'GET' || req.method === 'HEAD') return null;
    const chunks: Buffer[] = [];
    let size = 0;
    for await (const c of req) {
      size += (c as Buffer).length;
      if (size > 1_000_000) throw new ApiError(413, 'VALIDATION_ERROR', 'Body too large');
      chunks.push(c as Buffer);
    }
    if (!chunks.length) return null;
    try {
      return JSON.parse(Buffer.concat(chunks).toString('utf8'));
    } catch {
      throw new ApiError(400, 'VALIDATION_ERROR', 'Malformed JSON');
    }
  }

  function authenticate(req: IncomingMessage): string | null {
    const h = req.headers.authorization;
    if (!h?.startsWith('Bearer ')) return null;
    const row = db.prepare('SELECT user_id FROM sessions WHERE token_hash = ? AND revoked_at IS NULL').get(sha(h.slice(7))) as { user_id: string } | undefined;
    return row?.user_id ?? null;
  }

  return async function handle(req: IncomingMessage, res: ServerResponse) {
    const requestId = `req_${randomUUID()}`;
    const send = (status: number, body: unknown, headers: Record<string, string> = {}) => {
      res.writeHead(status, { 'content-type': 'application/json; charset=utf-8', 'x-request-id': requestId, 'access-control-allow-origin': '*', 'access-control-allow-headers': 'authorization, content-type, idempotency-key, if-match', 'access-control-allow-methods': 'GET, POST, PATCH, OPTIONS', 'access-control-expose-headers': 'x-request-id, etag', ...headers });
      res.end(status === 204 ? undefined : JSON.stringify(body));
    };
    try {
      if (req.method === 'OPTIONS') return send(204, null);
      const url = new URL(req.url ?? '/', 'http://local');
      const candidates = routes.filter((r) => r.pattern.test(url.pathname));
      if (!candidates.length) throw new ApiError(404, 'NOT_FOUND', 'Route not found');
      const r = candidates.find((c) => c.method === req.method);
      if (!r) throw new ApiError(405, 'VALIDATION_ERROR', 'Method not allowed');
      const m = url.pathname.match(r.pattern) as RegExpMatchArray;
      const params = Object.fromEntries(r.keys.map((k, i) => [k, decodeURIComponent(m[i + 1] as string)]));
      const ctx: Ctx = { req, requestId, userId: null, body: await readBody(req), params, query: url.searchParams };
      if (r.auth === 'DEV_ONLY' && config.env === 'production') throw new ApiError(404, 'NOT_FOUND', 'Route not found');
      if (r.auth === 'AUTHENTICATED_OWNER') {
        ctx.userId = authenticate(req);
        if (!ctx.userId) throw new ApiError(401, 'AUTH_REQUIRED', 'Authentication required');
      }
      if (r.idempotent) {
        const key = req.headers['idempotency-key'];
        if (!key || typeof key !== 'string') throw new ApiError(400, 'VALIDATION_ERROR', 'Idempotency-Key header required', { fieldErrors: [{ field: 'Idempotency-Key', code: 'REQUIRED' }] });
        const fp = sha(`${req.method} ${url.pathname} ${JSON.stringify(ctx.body)}`);
        const prev = db.prepare('SELECT * FROM idempotency_receipts WHERE user_id = ? AND idem_key = ?').get(ctx.userId, key) as { request_fingerprint: string; response_status: number; response_json: string } | undefined;
        if (prev) {
          if (prev.request_fingerprint !== fp) throw new ApiError(422, 'IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_REQUEST', 'Idempotency-Key reused with a different request');
          return send(prev.response_status, JSON.parse(prev.response_json), { 'idempotent-replay': 'true' });
        }
        const out = r.handler(ctx);
        db.prepare('INSERT INTO idempotency_receipts (user_id, idem_key, request_fingerprint, response_status, response_json, created_at) VALUES (?, ?, ?, ?, ?, ?)').run(ctx.userId, key, fp, out.status, JSON.stringify(out.body), now());
        return send(out.status, out.body, out.headers);
      }
      const out = r.handler(ctx);
      const etag = (out.body as { revision?: number } | null)?.revision;
      return send(out.status, out.body, { ...(etag ? { etag: `"${etag}"` } : {}), ...out.headers });
    } catch (e) {
      const err = e instanceof ApiError ? e : new ApiError(500, 'INTERNAL_ERROR', 'Internal error', { retryable: true });
      if (!(e instanceof ApiError)) console.error(requestId, e);
      return send(err.status, { error: { code: err.code, message: err.message, request_id: requestId, retryable: err.retryable, details: err.details, ...(err.fieldErrors ? { field_errors: err.fieldErrors } : {}) } });
    }
  };
}
