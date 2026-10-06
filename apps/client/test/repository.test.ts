// Client data layer: local-only and cloud repositories satisfy the same contract,
// and the cloud path is exercised against the real services/api app (client ↔ API connection).

import { createServer, type Server } from 'node:http';
import type { AddressInfo } from 'node:net';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { computeProfileResults } from '@hhos/domain';
import { createApp } from '../../../services/api/src/app.ts';
import { openDb } from '../../../services/api/src/db.ts';
import { ApiRepository, LocalRepository, RepoError, type HealthRepository } from '../src/data/repository.ts';
import { MemoryStore } from '../src/data/store.ts';
import { assessLab } from '../src/screens/Labs.tsx';

let server: Server;
let base = '';

beforeAll(async () => {
  server = createServer(createApp(openDb(':memory:'), { env: 'test' }));
  await new Promise<void>((r) => server.listen(0, r));
  base = `http://127.0.0.1:${(server.address() as AddressInfo).port}`;
});
afterAll(() => server.close());

const RI = { interval_id: 'RI-1', low: 4, high: 10, unit: 'syn-u', specimen: 'serum', method_id: 'M1', source: 'REPORT', version: '1', required_context: [] };

async function contract(repo: HealthRepository) {
  const me = await repo.createProfile('Me', 'SELF');
  expect(me.inputs.weight_kg).toBeNull(); // nothing invented
  const updated = await repo.updateProfile(me, { inputs: { weight_kg: 80, height_cm: 180 } });
  expect(updated.revision).toBe(me.revision + 1);
  await expect(repo.updateProfile(me, { inputs: { weight_kg: 1 } })).rejects.toMatchObject({ code: 'REVISION_CONFLICT' });

  const scn = await repo.cloneScenario(updated, 'Me −10', { weight_kg: 70 });
  expect(scn.profile_type).toBe('SCENARIO');
  const list = await repo.listProfiles();
  expect(list.find((p) => p.id === me.id)!.inputs.weight_kg).toBe(80); // source untouched

  await expect(repo.addLab(me.id, { analyte_key: 'X', numeric_value: null, result_state: 'PRESENT', unit: 'syn-u', specimen: 'serum', method_id: 'M1', observed_at: '2026-01-01', source_flag: null, reference_interval: null, provenance: 'MANUAL' })).rejects.toBeInstanceOf(RepoError);
  const nr = await repo.addLab(me.id, { analyte_key: 'X', numeric_value: null, unit: 'syn-u', specimen: 'serum', method_id: 'M1', observed_at: '2026-01-01', source_flag: null, reference_interval: RI, provenance: 'MANUAL' });
  expect(nr.result_state).toBe('NOT_REPORTED');
  expect(nr.numeric_value).toBeNull();
  for (const [i, v] of [9, 9.2, 8.8, 9.1, 8.9].entries())
    await repo.addLab(me.id, { analyte_key: 'X', numeric_value: v, unit: 'syn-u', specimen: 'serum', method_id: 'M1', observed_at: `2026-0${i + 2}-01`, source_flag: null, reference_interval: RI, provenance: 'MANUAL' });
  await repo.addLab(me.id, { analyte_key: 'X', numeric_value: 7, unit: 'syn-u', specimen: 'serum', method_id: 'M1', observed_at: '2026-09-01', source_flag: 'N', reference_interval: RI, provenance: 'MANUAL' });
  const labs = await repo.listLabs(me.id);
  expect(labs).toHaveLength(7);
  const a = assessLab(labs.at(-1)!, labs);
  expect([a.reference.state, a.critical.state, a.baseline.state]).toEqual(['WITHIN_REFERENCE', 'NO_ACTIVE_RULE', 'UNUSUAL_FOR_PERSON']);

  expect(await repo.seedSyntheticDemo()).toBe(4);
  expect(await repo.seedSyntheticDemo()).toBe(0); // idempotent (AT-819)
  return { me: (await repo.listProfiles()).find((p) => p.id === me.id)! };
}

describe('LocalRepository (local-only profile)', () => {
  it('satisfies the repository contract offline', async () => {
    await contract(new LocalRepository(new MemoryStore()));
  });
  it('delete-all is separate and explicit', async () => {
    const r = new LocalRepository(new MemoryStore());
    await r.createProfile('Me', 'SELF');
    await r.deleteAllHealthData();
    expect(await r.listProfiles()).toHaveLength(0);
  });
});

describe('ApiRepository (cloud account) against services/api', () => {
  it('satisfies the same contract over HTTP', async () => {
    const token = await ApiRepository.devSession(base, 'Client test');
    await contract(new ApiRepository({ baseUrl: base, token }));
  });

  it('server-computed results equal on-device results for the same profile (parity)', async () => {
    const token = await ApiRepository.devSession(base, 'Parity');
    const repo = new ApiRepository({ baseUrl: base, token });
    const p = await repo.createProfile('P', 'SELF', { weight_kg: 81, height_cm: 177, systolic_bp: 131, steps_per_day: 6400, sleep_hours: 7.1, smoking_status: 'NEVER' });
    const server = await (await fetch(`${base}/v1/profiles/${p.id}/scores/compute`, { method: 'POST', headers: { authorization: `Bearer ${token}` } })).json();
    const { revision: _r, ...profile } = p;
    expect(server.results).toEqual(computeProfileResults(profile));
  });

  it('network failure reports unknown delivery state for writes (retry is safe via idempotency)', async () => {
    const repo = new ApiRepository({ baseUrl: 'http://127.0.0.1:1', token: 'x' });
    await expect(repo.createProfile('x', 'SELF')).rejects.toMatchObject({ code: 'SERVICE_UNAVAILABLE', saved: 'UNKNOWN' });
  });
});
