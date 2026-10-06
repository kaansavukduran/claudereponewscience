// Local persistence for the production client.
// Web: IndexedDB (transactional, structured) — not key-value preferences.
// Native (Capacitor): replace IdbStore with a SQLite-backed store implementing the same interface
// (blocked in this environment: no Android SDK / Xcode; see docs/RELEASE_STATUS.md).

export type Collection = 'profiles' | 'labs' | 'missions' | 'meta';

export interface DocumentStore {
  all<T>(c: Collection): Promise<T[]>;
  get<T>(c: Collection, id: string): Promise<T | undefined>;
  put<T extends { id: string }>(c: Collection, doc: T): Promise<void>;
  /** Writes all docs atomically (single transaction). */
  putMany<T extends { id: string }>(c: Collection, docs: T[]): Promise<void>;
  clear(c: Collection): Promise<void>;
}

export class MemoryStore implements DocumentStore {
  private data = new Map<Collection, Map<string, unknown>>();
  private col(c: Collection) {
    let m = this.data.get(c);
    if (!m) this.data.set(c, (m = new Map()));
    return m;
  }
  async all<T>(c: Collection) {
    return [...this.col(c).values()].map((v) => structuredClone(v)) as T[];
  }
  async get<T>(c: Collection, id: string) {
    const v = this.col(c).get(id);
    return v === undefined ? undefined : (structuredClone(v) as T);
  }
  async put<T extends { id: string }>(c: Collection, doc: T) {
    this.col(c).set(doc.id, structuredClone(doc));
  }
  async putMany<T extends { id: string }>(c: Collection, docs: T[]) {
    for (const d of docs) this.col(c).set(d.id, structuredClone(d));
  }
  async clear(c: Collection) {
    this.col(c).clear();
  }
}

const DB_NAME = 'hhos-client';
const DB_VERSION = 1;
const COLLECTIONS: Collection[] = ['profiles', 'labs', 'missions', 'meta'];

export class IdbStore implements DocumentStore {
  private dbp: Promise<IDBDatabase>;
  constructor(name = DB_NAME) {
    this.dbp = new Promise((resolve, reject) => {
      const req = indexedDB.open(name, DB_VERSION);
      // Versioned schema upgrade (migration 1).
      req.onupgradeneeded = () => {
        for (const c of COLLECTIONS) if (!req.result.objectStoreNames.contains(c)) req.result.createObjectStore(c, { keyPath: 'id' });
      };
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
  }
  private async run<T>(c: Collection, mode: IDBTransactionMode, fn: (s: IDBObjectStore) => IDBRequest | void): Promise<T> {
    const db = await this.dbp;
    return new Promise<T>((resolve, reject) => {
      const tx = db.transaction(c, mode);
      const req = fn(tx.objectStore(c));
      tx.oncomplete = () => resolve((req ? req.result : undefined) as T);
      tx.onerror = () => reject(tx.error);
      tx.onabort = () => reject(tx.error);
    });
  }
  all<T>(c: Collection) {
    return this.run<T[]>(c, 'readonly', (s) => s.getAll());
  }
  get<T>(c: Collection, id: string) {
    return this.run<T | undefined>(c, 'readonly', (s) => s.get(id));
  }
  async put<T extends { id: string }>(c: Collection, doc: T) {
    await this.run(c, 'readwrite', (s) => s.put(doc));
  }
  async putMany<T extends { id: string }>(c: Collection, docs: T[]) {
    await this.run(c, 'readwrite', (s) => {
      for (const d of docs) s.put(d);
    });
  }
  async clear(c: Collection) {
    await this.run(c, 'readwrite', (s) => s.clear());
  }
}
