// SQLite persistence kernel. Foreign keys ON; ordered, append-only, checksummed migrations.

import { createHash } from 'node:crypto';
import { readdirSync, readFileSync } from 'node:fs';
import { DatabaseSync } from 'node:sqlite';
import { fileURLToPath } from 'node:url';

const MIGRATIONS_DIR = fileURLToPath(new URL('../migrations/', import.meta.url));

export type Db = DatabaseSync;

export function openDb(path = ':memory:'): Db {
  const db = new DatabaseSync(path);
  db.exec('PRAGMA foreign_keys = ON; PRAGMA journal_mode = WAL;');
  migrate(db);
  return db;
}

export function migrate(db: Db): string[] {
  db.exec(`CREATE TABLE IF NOT EXISTS schema_migrations (
    id TEXT PRIMARY KEY, checksum TEXT NOT NULL, applied_at TEXT NOT NULL)`);
  const applied = new Map(
    (db.prepare('SELECT id, checksum FROM schema_migrations').all() as Array<{ id: string; checksum: string }>).map((r) => [r.id, r.checksum]),
  );
  const files = readdirSync(MIGRATIONS_DIR).filter((f) => f.endsWith('.sql')).sort();
  const ran: string[] = [];
  for (const f of files) {
    const sql = readFileSync(MIGRATIONS_DIR + f, 'utf8');
    const sum = createHash('sha256').update(sql).digest('hex');
    if (applied.has(f)) {
      if (applied.get(f) !== sum) throw new Error(`MIGRATION_CHECKSUM_MISMATCH ${f}: released migrations are append-only`);
      continue;
    }
    db.exec('BEGIN');
    try {
      db.exec(sql);
      db.prepare('INSERT INTO schema_migrations (id, checksum, applied_at) VALUES (?, ?, ?)').run(f, sum, new Date().toISOString());
      db.exec('COMMIT');
      ran.push(f);
    } catch (e) {
      db.exec('ROLLBACK');
      throw e;
    }
  }
  return ran;
}

export function tx<T>(db: Db, fn: () => T): T {
  db.exec('BEGIN');
  try {
    const r = fn();
    db.exec('COMMIT');
    return r;
  } catch (e) {
    db.exec('ROLLBACK');
    throw e;
  }
}
