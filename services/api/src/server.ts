// Entry point: `pnpm --filter @hhos/api dev` (Node ≥22.18 runs TypeScript via type stripping).
import { createServer } from 'node:http';
import { mkdirSync } from 'node:fs';
import { dirname } from 'node:path';
import { createApp } from './app.ts';
import { openDb } from './db.ts';

const env = (process.env.HHOS_ENV ?? 'development') as 'development' | 'test' | 'staging' | 'production';
const dbPath = process.env.HHOS_DB_PATH ?? './data/hhos-dev.sqlite';
if (dbPath !== ':memory:') mkdirSync(dirname(dbPath), { recursive: true });
const port = Number(process.env.HHOS_API_PORT ?? 8787);
const server = createServer(createApp(openDb(dbPath), { env }));
server.listen(port, () => console.log(`HHOS API ${env} listening on http://localhost:${port}/v1/health (db: ${dbPath})`));
