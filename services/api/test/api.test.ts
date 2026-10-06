import { createServer, type Server } from 'node:http';
import type { AddressInfo } from 'node:net';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { computeProfileResults } from '@hhos/domain';
import { syntheticProfiles } from '@hhos/packs';
import { createApp } from '../src/app.ts';
import { migrate, openDb, type Db } from '../src/db.ts';

let server: Server;
let base = '';
let db: Db;

async function call(method: string, path: string, opts: { token?: string; body?: unknown; headers?: Record<string, string> } = {}) {
  const res = await fetch(base + path, {
    method,
    headers: { 'content-type': 'application/json', ...(opts.token ? { authorization: `Bearer ${opts.token}` } : {}), ...(opts.headers ?? {}) },
    body: opts.body === undefined ? undefined : JSON.stringify(opts.body),
  });
  const text = await res.text();
  return { status: res.status, body: text ? JSON.parse(text) : null, headers: res.headers };
}

const session = async (name: string) => (await call('POST', '/v1/auth/dev-session', { body: { display_name: name } })).body.token as string;

beforeAll(async () => {
  db = openDb(':memory:');
  server = createServer(createApp(db, { env: 'test' }));
  await new Promise<void>((r) => server.listen(0, r));
  base = `http://127.0.0.1:${(server.address() as AddressInfo).port}`;
});
afterAll(() => server.close());

describe('kernel database', () => {
  it('AT-810: foreign keys enforced; AT-814 PRESENT lab without value rejected by DB; mission COMPLETED needs a record', () => {
    expect((db.prepare('PRAGMA foreign_keys').get() as { foreign_keys: number }).foreign_keys).toBe(1);
    expect(() => db.prepare("INSERT INTO health_facts (id, profile_id, fact_type, value_state, effective_at, recorded_at, provenance, created_at) VALUES ('F1','NOPE','x','UNKNOWN','t','t','m','t')").run()).toThrow();
    db.prepare("INSERT INTO users VALUES ('U-DB','x','t')").run();
    db.prepare("INSERT INTO profiles (id, owner_user_id, name, profile_type, synthetic, modules_json, inputs_json, created_at, updated_at) VALUES ('P-DB','U-DB','x','SYNTHETIC',1,'{}','{}','t','t')").run();
    expect(() => db.prepare("INSERT INTO lab_results (id, profile_id, analyte_key, result_state, numeric_value, unit, observed_at, provenance, created_at) VALUES ('L1','P-DB','a','PRESENT',NULL,'u','t','m','t')").run()).toThrow();
    db.prepare("INSERT INTO lab_results (id, profile_id, analyte_key, result_state, numeric_value, unit, observed_at, provenance, created_at) VALUES ('L2','P-DB','a','NOT_REPORTED',NULL,'u','t','m','t')").run();
    expect(() => db.prepare("INSERT INTO missions (id, profile_id, generated_for_date, category, mission_type, title, rationale, target, source_rule_id, source_rule_version, status, created_at) VALUES ('M1','P-DB','d','c','t','t','r','x','r','1','COMPLETED','t')").run()).toThrow();
  });
  it('migrations are idempotent and checksum-guarded (append-only)', () => {
    expect(migrate(db)).toEqual([]);
    db.prepare("UPDATE schema_migrations SET checksum = 'tampered' WHERE id = '0001_kernel.sql'").run();
    expect(() => migrate(db)).toThrow(/MIGRATION_CHECKSUM_MISMATCH/);
  });
});

describe('API', () => {
  let alice = '';
  let bob = '';
  let profileId = '';

  it('health is public and reports shared domain version', async () => {
    const r = await call('GET', '/v1/health');
    expect(r.status).toBe(200);
    expect(r.body.domain_version).toBe('0.25.0');
  });

  it('private endpoints require auth with stable error envelope', async () => {
    const r = await call('GET', '/v1/profiles');
    expect(r.status).toBe(401);
    expect(r.body.error.code).toBe('AUTH_REQUIRED');
    expect(r.body.error.request_id).toMatch(/^req_/);
  });

  it('creates a profile idempotently; key reuse with a different body is rejected', async () => {
    alice = await session('Alice');
    bob = await session('Bob');
    const body = { name: 'Alice self', profile_type: 'SELF', inputs: { weight_kg: 70, height_cm: 175 } };
    const a = await call('POST', '/v1/profiles', { token: alice, body, headers: { 'idempotency-key': 'k1' } });
    expect(a.status).toBe(201);
    profileId = a.body.id;
    expect(a.body.inputs.waist_cm).toBeNull(); // nothing invented
    const replay = await call('POST', '/v1/profiles', { token: alice, body, headers: { 'idempotency-key': 'k1' } });
    expect(replay.body.id).toBe(profileId);
    expect(replay.headers.get('idempotent-replay')).toBe('true');
    const reuse = await call('POST', '/v1/profiles', { token: alice, body: { ...body, name: 'other' }, headers: { 'idempotency-key': 'k1' } });
    expect(reuse.body.error.code).toBe('IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_REQUEST');
    const noKey = await call('POST', '/v1/profiles', { token: alice, body });
    expect(noKey.status).toBe(400);
  });

  it('rejects invalid inputs instead of coercing them', async () => {
    const r = await call('POST', '/v1/profiles', { token: alice, body: { name: 'x', inputs: { weight_kg: '70' } }, headers: { 'idempotency-key': 'k-bad' } });
    expect(r.status).toBe(400);
    expect(r.body.error.field_errors[0]).toEqual({ field: 'inputs.weight_kg', code: 'EXPECTED_NUMBER_OR_NULL' });
  });

  it('cross-user guessed IDs disclose nothing (404)', async () => {
    for (const path of [`/v1/profiles/${profileId}`, `/v1/profiles/${profileId}/labs`, `/v1/profiles/${profileId}/scores`]) {
      const r = await call('GET', path, { token: bob });
      expect(r.status).toBe(404);
    }
    const patch = await call('PATCH', `/v1/profiles/${profileId}`, { token: bob, body: { inputs: { weight_kg: 1 } }, headers: { 'if-match': '1' } });
    expect(patch.status).toBe(404);
    const cmp = await call('POST', '/v1/compare', { token: bob, body: { profile_ids: [profileId] } });
    expect(cmp.status).toBe(404);
  });

  it('PATCH requires If-Match and rejects stale revisions (no silent last-write-wins)', async () => {
    const ok = await call('PATCH', `/v1/profiles/${profileId}`, { token: alice, body: { inputs: { weight_kg: 72 } }, headers: { 'if-match': '1' } });
    expect(ok.status).toBe(200);
    expect(ok.body.revision).toBe(2);
    const stale = await call('PATCH', `/v1/profiles/${profileId}`, { token: alice, body: { inputs: { weight_kg: 99 } }, headers: { 'if-match': '1' } });
    expect(stale.status).toBe(409);
    expect(stale.body.error.code).toBe('REVISION_CONFLICT');
  });

  it('scenario clone does not mutate the source; server results equal client/site results', async () => {
    const s = await call('POST', `/v1/profiles/${profileId}/scenarios`, { token: alice, body: { name: 'A -10kg', patch: { weight_kg: 62 } }, headers: { 'idempotency-key': 'scn1' } });
    expect(s.status).toBe(201);
    expect(s.body.source_profile_id).toBe(profileId);
    const src = await call('GET', `/v1/profiles/${profileId}`, { token: alice });
    expect(src.body.inputs.weight_kg).toBe(72);
    const comp = await call('POST', `/v1/profiles/${s.body.id}/scores/compute`, { token: alice });
    expect(comp.body.results.hypothetical).toBe(true);
    const { revision: _r, ...scenario } = s.body;
    expect(comp.body.results).toEqual(computeProfileResults(scenario)); // one engine, identical output
    const prevent = comp.body.results.external.find((e: { modelId: string }) => e.modelId === 'EXT-AHA-PREVENT');
    expect(prevent.result.value).toBeNull();
  });

  it('labs: PRESENT needs a value, NOT_REPORTED stays null; interpretation runs the shared v0.24 engine', async () => {
    const bad = await call('POST', `/v1/profiles/${profileId}/labs`, { token: alice, body: { analyte_key: 'SYN-X', result_state: 'PRESENT', unit: 'syn-u', observed_at: '2026-01-01' }, headers: { 'idempotency-key': 'lab-bad' } });
    expect(bad.status).toBe(400);
    const missing = await call('POST', `/v1/profiles/${profileId}/labs`, { token: alice, body: { analyte_key: 'SYN-X', unit: 'syn-u', observed_at: '2026-01-01' }, headers: { 'idempotency-key': 'lab-0' } });
    expect(missing.body.result_state).toBe('NOT_REPORTED');
    expect(missing.body.numeric_value).toBeNull();
    const ri = { interval_id: 'RI-SYN-1', low: 4, high: 10, unit: 'syn-u', specimen: 'serum', method_id: 'M1', source: 'SYNTHETIC-LAB-A', version: '1', required_context: [] };
    for (const [i, v] of [9, 9.2, 8.8, 9.1, 8.9].entries())
      await call('POST', `/v1/profiles/${profileId}/labs`, { token: alice, body: { analyte_key: 'SYN-X', numeric_value: v, unit: 'syn-u', specimen: 'serum', method_id: 'M1', observed_at: `2026-0${i + 2}-01`, reference_interval: ri }, headers: { 'idempotency-key': `lab-${i + 1}` } });
    const cur = await call('POST', `/v1/profiles/${profileId}/labs`, { token: alice, body: { analyte_key: 'SYN-X', numeric_value: 7, unit: 'syn-u', specimen: 'serum', method_id: 'M1', observed_at: '2026-09-01', reference_interval: ri, source_flag: 'N' }, headers: { 'idempotency-key': 'lab-cur' } });
    const a = await call('GET', `/v1/profiles/${profileId}/labs/${cur.body.id}/interpretation`, { token: alice });
    expect(a.body.reference.state).toBe('WITHIN_REFERENCE');
    expect(a.body.critical.state).toBe('NO_ACTIVE_RULE');
    expect(a.body.comparability.state).toBe('DIRECTLY_COMPARABLE');
    expect(a.body.rcv.state).toBe('NO_RCV_SOURCE');
    expect(a.body.baseline.state).toBe('UNUSUAL_FOR_PERSON');
    expect(a.body.flags[0]).toEqual({ origin: 'SOURCE_REPORTED', label: 'N' });
  });

  it('missions: generated once per date; notification never completes; COMPLETED needs a record', async () => {
    const g = await call('POST', `/v1/profiles/${profileId}/missions/generate`, { token: alice, body: { date: '2026-10-06' } });
    expect(g.status).toBe(201);
    const again = await call('POST', `/v1/profiles/${profileId}/missions/generate`, { token: alice, body: { date: '2026-10-06' } });
    expect(again.body.generated).toBe(false);
    expect(again.body.items.map((m: { id: string }) => m.id)).toEqual(g.body.items.map((m: { id: string }) => m.id));
    const mid = g.body.items[1].id;
    const opened = await call('POST', `/v1/profiles/${profileId}/missions/${mid}/events`, { token: alice, body: { kind: 'NOTIFICATION_OPENED' } });
    expect(opened.body.status).toBe('PLANNED');
    const noRec = await call('POST', `/v1/profiles/${profileId}/missions/${mid}/events`, { token: alice, body: { kind: 'COMPLETED' } });
    expect(noRec.status).toBe(400);
    const done = await call('POST', `/v1/profiles/${profileId}/missions/${mid}/events`, { token: alice, body: { kind: 'COMPLETED', completion_record_id: 'WK-1' } });
    expect(done.body.status).toBe('COMPLETED');
  });

  it('AT-819: demo seed is idempotent and synthetic; compare works with 3+ profiles', async () => {
    const s1 = await call('POST', '/v1/demo/seed', { token: alice });
    expect(s1.body.created).toHaveLength(syntheticProfiles().length);
    const s2 = await call('POST', '/v1/demo/seed', { token: alice });
    expect(s2.body.created).toHaveLength(0);
    const list = await call('GET', '/v1/profiles', { token: alice });
    const ids = list.body.items.filter((p: { synthetic: boolean }) => p.synthetic).map((p: { id: string }) => p.id);
    const cmp = await call('POST', '/v1/compare', { token: alice, body: { profile_ids: ids, baseline_id: ids[0] } });
    expect(cmp.status).toBe(200);
    expect(cmp.body.rows[0].cells).toHaveLength(4);
  });

  it('dev-session route is not exposed in production', async () => {
    const prodSrv = createServer(createApp(openDb(':memory:'), { env: 'production' }));
    await new Promise<void>((r) => prodSrv.listen(0, r));
    const res = await fetch(`http://127.0.0.1:${(prodSrv.address() as AddressInfo).port}/v1/auth/dev-session`, { method: 'POST' });
    expect(res.status).toBe(404);
    prodSrv.close();
  });
});
