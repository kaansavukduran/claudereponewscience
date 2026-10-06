// HealthRepository — one domain-level interface, two implementations:
//   LocalRepository  (local-only profile, offline, IndexedDB/Memory store)
//   ApiRepository    (cloud account against services/api /v1 with idempotency + If-Match)
// UI never talks to storage or HTTP directly, and never implements formulas (those live in @hhos/domain).

import {
  applyPatch,
  cloneAsScenario,
  defaultModules,
  emptyInputs,
  type BodyProfile,
  type ProfileInputs,
  type ProfileType,
  type ReferenceIntervalSnapshot,
} from '@hhos/domain';
import { syntheticProfiles } from '@hhos/packs';
import type { DocumentStore } from './store.ts';

export interface StoredProfile extends BodyProfile {
  revision: number;
}

export interface LabRecord {
  id: string;
  profile_id: string;
  analyte_key: string;
  result_state: 'PRESENT' | 'NOT_REPORTED' | 'UNREADABLE';
  numeric_value: number | null;
  unit: string;
  specimen: string | null;
  method_id: string | null;
  observed_at: string;
  source_flag: string | null;
  reference_interval: ReferenceIntervalSnapshot | null;
  provenance: string;
}

export type NewLab = Omit<LabRecord, 'id' | 'profile_id' | 'result_state'> & { result_state?: LabRecord['result_state'] };

export class RepoError extends Error {
  code: string;
  /** Whether the canonical write may already have committed (error catalog semantics). */
  saved: 'NO' | 'YES' | 'UNKNOWN';
  constructor(code: string, message: string, saved: 'NO' | 'YES' | 'UNKNOWN' = 'NO') {
    super(message);
    this.code = code;
    this.saved = saved;
  }
}

export interface HealthRepository {
  readonly mode: 'LOCAL' | 'CLOUD';
  listProfiles(): Promise<StoredProfile[]>;
  createProfile(name: string, type: Exclude<ProfileType, 'SCENARIO'>, inputs?: Partial<ProfileInputs>): Promise<StoredProfile>;
  updateProfile(p: StoredProfile, patch: { inputs?: Partial<ProfileInputs>; name?: string; modules?: Partial<BodyProfile['modules']> }): Promise<StoredProfile>;
  cloneScenario(p: StoredProfile, name: string, patch?: Partial<ProfileInputs>): Promise<StoredProfile>;
  seedSyntheticDemo(): Promise<number>;
  listLabs(profileId: string): Promise<LabRecord[]>;
  addLab(profileId: string, lab: NewLab): Promise<LabRecord>;
  deleteAllHealthData(): Promise<void>;
}

export function validateLab(lab: NewLab): LabRecord['result_state'] {
  const state = lab.result_state ?? (lab.numeric_value === null ? 'NOT_REPORTED' : 'PRESENT');
  if (state === 'PRESENT' && (lab.numeric_value === null || !Number.isFinite(lab.numeric_value))) throw new RepoError('VALIDATION_ERROR', 'A PRESENT result needs a numeric value');
  if (state !== 'PRESENT' && lab.numeric_value !== null) throw new RepoError('VALIDATION_ERROR', 'A missing result cannot carry a number');
  if (!lab.analyte_key || !lab.unit || !lab.observed_at) throw new RepoError('VALIDATION_ERROR', 'analyte, unit and date are required');
  return state;
}

const uid = (p: string) => `${p}-${crypto.randomUUID()}`;

export class LocalRepository implements HealthRepository {
  readonly mode = 'LOCAL' as const;
  private store: DocumentStore;
  constructor(store: DocumentStore) {
    this.store = store;
  }

  async listProfiles() {
    return (await this.store.all<StoredProfile>('profiles')).sort((a, b) => a.id.localeCompare(b.id));
  }
  async createProfile(name: string, type: Exclude<ProfileType, 'SCENARIO'>, inputs: Partial<ProfileInputs> = {}) {
    // A minimal profile can be almost blank; nothing is invented (AT-825).
    const p: StoredProfile = { id: uid('PRF'), name, profile_type: type, synthetic: type === 'SYNTHETIC', source_profile_id: null, pinned_baseline: false, modules: defaultModules(), inputs: { ...emptyInputs(), ...inputs }, revision: 1 };
    await this.store.put('profiles', p);
    return p;
  }
  async updateProfile(p: StoredProfile, patch: { inputs?: Partial<ProfileInputs>; name?: string; modules?: Partial<BodyProfile['modules']> }) {
    const current = await this.store.get<StoredProfile>('profiles', p.id);
    if (!current) throw new RepoError('NOT_FOUND', 'Profile not found');
    if (current.revision !== p.revision) throw new RepoError('REVISION_CONFLICT', 'Profile changed since it was loaded');
    const next = applyPatch(current, patch.inputs ?? {}) as StoredProfile;
    next.name = patch.name ?? current.name;
    next.modules = { ...current.modules, ...patch.modules };
    next.revision = current.revision + 1;
    await this.store.put('profiles', next);
    return next;
  }
  async cloneScenario(p: StoredProfile, name: string, patch: Partial<ProfileInputs> = {}) {
    const s = { ...applyPatch(cloneAsScenario(p, uid('SCN'), name), patch), revision: 1 };
    await this.store.put('profiles', s);
    return s;
  }
  async seedSyntheticDemo() {
    const existing = new Set((await this.store.all<StoredProfile>('profiles')).map((p) => p.id));
    const fresh = syntheticProfiles().filter((p) => !existing.has(p.id)).map((p) => ({ ...p, revision: 1 }));
    await this.store.putMany('profiles', fresh);
    return fresh.length;
  }
  async listLabs(profileId: string) {
    return (await this.store.all<LabRecord>('labs')).filter((l) => l.profile_id === profileId).sort((a, b) => a.observed_at.localeCompare(b.observed_at) || a.id.localeCompare(b.id));
  }
  async addLab(profileId: string, lab: NewLab) {
    const state = validateLab(lab);
    if (!(await this.store.get('profiles', profileId))) throw new RepoError('NOT_FOUND', 'Profile not found');
    const rec: LabRecord = { ...lab, id: uid('LAB'), profile_id: profileId, result_state: state };
    await this.store.put('labs', rec);
    return rec;
  }
  async deleteAllHealthData() {
    for (const c of ['profiles', 'labs', 'missions'] as const) await this.store.clear(c);
  }
}

export interface ApiConfig {
  baseUrl: string;
  token: string;
  fetchImpl?: typeof fetch;
}

export class ApiRepository implements HealthRepository {
  readonly mode = 'CLOUD' as const;
  private cfg: ApiConfig;
  constructor(cfg: ApiConfig) {
    this.cfg = cfg;
  }

  static async devSession(baseUrl: string, displayName: string, fetchImpl: typeof fetch = fetch): Promise<string> {
    const r = await fetchImpl(`${baseUrl}/v1/auth/dev-session`, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ display_name: displayName }) });
    if (!r.ok) throw new RepoError('AUTH_REQUIRED', 'Could not open a development session');
    return ((await r.json()) as { token: string }).token;
  }

  private async req<T>(method: string, path: string, body?: unknown, headers: Record<string, string> = {}): Promise<T> {
    const f = this.cfg.fetchImpl ?? fetch;
    let res: Response;
    try {
      res = await f(`${this.cfg.baseUrl}${path}`, { method, headers: { 'content-type': 'application/json', authorization: `Bearer ${this.cfg.token}`, ...headers }, body: body === undefined ? undefined : JSON.stringify(body) });
    } catch {
      // Network failure after send: delivery is unknown; idempotency keys make the retry safe.
      throw new RepoError('SERVICE_UNAVAILABLE', 'Network error', method === 'GET' ? 'NO' : 'UNKNOWN');
    }
    const json = (await res.json().catch(() => null)) as { error?: { code: string; message: string } } | null;
    if (!res.ok) throw new RepoError(json?.error?.code ?? 'INTERNAL_ERROR', json?.error?.message ?? res.statusText);
    return json as T;
  }

  async listProfiles() {
    return (await this.req<{ items: StoredProfile[] }>('GET', '/v1/profiles')).items;
  }
  createProfile(name: string, type: Exclude<ProfileType, 'SCENARIO'>, inputs: Partial<ProfileInputs> = {}) {
    return this.req<StoredProfile>('POST', '/v1/profiles', { name, profile_type: type, synthetic: type === 'SYNTHETIC', inputs }, { 'idempotency-key': crypto.randomUUID() });
  }
  updateProfile(p: StoredProfile, patch: { inputs?: Partial<ProfileInputs>; name?: string; modules?: Partial<BodyProfile['modules']> }) {
    return this.req<StoredProfile>('PATCH', `/v1/profiles/${encodeURIComponent(p.id)}`, patch, { 'if-match': `"${p.revision}"` });
  }
  cloneScenario(p: StoredProfile, name: string, patch: Partial<ProfileInputs> = {}) {
    return this.req<StoredProfile>('POST', `/v1/profiles/${encodeURIComponent(p.id)}/scenarios`, { name, patch }, { 'idempotency-key': crypto.randomUUID() });
  }
  async seedSyntheticDemo() {
    return (await this.req<{ created: string[] }>('POST', '/v1/demo/seed')).created.length;
  }
  async listLabs(profileId: string) {
    const items = (await this.req<{ items: Array<Omit<LabRecord, 'reference_interval'> & { ref_interval_json: string | null }> }>('GET', `/v1/profiles/${encodeURIComponent(profileId)}/labs`)).items;
    return items.map(({ ref_interval_json, ...l }) => ({ ...l, reference_interval: ref_interval_json ? (JSON.parse(ref_interval_json) as ReferenceIntervalSnapshot) : null }));
  }
  async addLab(profileId: string, lab: NewLab) {
    validateLab(lab);
    const { reference_interval, ...rest } = lab;
    const row = await this.req<Omit<LabRecord, 'reference_interval'> & { ref_interval_json: string | null }>('POST', `/v1/profiles/${encodeURIComponent(profileId)}/labs`, { ...rest, reference_interval }, { 'idempotency-key': crypto.randomUUID() });
    const { ref_interval_json, ...l } = row;
    return { ...l, reference_interval: ref_interval_json ? JSON.parse(ref_interval_json) : null } as LabRecord;
  }
  async deleteAllHealthData() {
    throw new RepoError('NOT_IMPLEMENTED', 'Cloud account deletion workflow is not implemented in this build');
  }
}
