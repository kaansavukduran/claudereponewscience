#!/usr/bin/env node
// FORGE 001 runtime smoke for the Flutter web build (v0.27 gate V3):
// serve human_health_os/build/web locally, open it in Chromium (desktop + phone),
// enable Flutter semantics, assert Today is shown, navigate to Labs, and record
// every network request (the app must not need any external host).
// Usage: node tools/flutter_web_smoke.mjs [buildDir] [outDir]
import { createServer } from 'node:http';
import { readFile, stat, mkdir, writeFile } from 'node:fs/promises';
import { extname, join, resolve } from 'node:path';
import { chromium } from '@playwright/test';

const root = resolve(process.argv[2] ?? 'human_health_os/build/web');
const out = resolve(process.argv[3] ?? 'reports/runtime');
const TYPES = { '.html': 'text/html', '.js': 'text/javascript', '.mjs': 'text/javascript', '.json': 'application/json', '.wasm': 'application/wasm', '.png': 'image/png', '.otf': 'font/otf', '.ttf': 'font/ttf', '.css': 'text/css', '.symbols': 'application/octet-stream', '.frag': 'application/octet-stream' };

const server = createServer(async (req, res) => {
  try {
    let p = join(root, decodeURIComponent(new URL(req.url, 'http://x').pathname));
    if ((await stat(p).catch(() => null))?.isDirectory()) p = join(p, 'index.html');
    const body = await readFile(p);
    res.writeHead(200, { 'content-type': TYPES[extname(p)] ?? 'application/octet-stream' });
    res.end(body);
  } catch {
    res.writeHead(404).end();
  }
});
await new Promise((r) => server.listen(0, '127.0.0.1', r));
const base = `http://127.0.0.1:${server.address().port}/`;
await mkdir(out, { recursive: true });

const results = [];
const check = (name, ok, detail = '') => { results.push({ name, status: ok ? 'PASS' : 'FAIL', detail }); };
const browser = await chromium.launch();
// Explicit BCP-47 locales: a POSIX-locale container makes headless Chromium report
// 'en-US@posix', which Flutter web rejects at startup (see project_state/RISKS.md R-11).
const RUNS = [
  { label: 'desktop-en', viewport: { width: 1440, height: 900 }, locale: 'en-US', today: 'Today', labs: 'Labs', labsText: /Reference interval ≠ optimal target/, banner: /DEVELOPMENT BUILD/ },
  { label: 'phone-en', viewport: { width: 390, height: 844 }, locale: 'en-US', today: 'Today', labs: 'Labs', labsText: /Reference interval ≠ optimal target/, banner: /DEVELOPMENT BUILD/ },
  { label: 'phone-tr', viewport: { width: 390, height: 844 }, locale: 'tr-TR', today: 'Bugün', labs: 'Lab', labsText: /Referans aralığı ≠ optimal hedef/, banner: /GELİŞTİRME DERLEMESİ/ },
];
for (const { label, viewport, locale, today: todayLabel, labs: labsLabel, labsText, banner } of RUNS) {
  const page = await browser.newPage({ viewport, locale });
  const external = [];
  const errors = [];
  page.on('request', (r) => { const u = new URL(r.url()); if (!['127.0.0.1', 'localhost'].includes(u.hostname) && u.protocol !== 'data:' && u.protocol !== 'blob:') external.push(r.url()); });
  page.on('pageerror', (e) => errors.push(e.message));
  await page.goto(base, { waitUntil: 'load' });
  await page.waitForSelector('flutter-view', { state: 'attached', timeout: 60_000 });
  // Turn on the Flutter semantics tree so text is queryable (same path a screen reader uses).
  // The placeholder appears once the engine is ready; retry until the semantics tree exists.
  for (let i = 0; i < 40 && (await page.locator('flt-semantics').count()) === 0; i++) {
    await page.locator('flt-semantics-placeholder').dispatchEvent('click').catch(() => {});
    await page.waitForTimeout(500);
  }
  // Rail items are buttons named '<label> Tab n of m'; bottom-bar items are tabs named '<label>'.
  const navItem = (name) => page.getByRole('tab', { name, exact: true }).or(page.getByRole('button', { name: new RegExp(`^${name} `) })).first();
  const heading = (name) => page.getByRole('heading', { name, exact: true }).first();
  const today = heading(todayLabel);
  await today.waitFor({ timeout: 30_000 }).catch(() => {});
  check(`${label}: app starts and shows ${todayLabel}`, await today.isVisible().catch(() => false));
  check(`${label}: development profile banner visible`, await page.getByText(banner).first().isVisible().catch(() => false));
  await page.screenshot({ path: join(out, `flutter-web-${label}-today.png`) });
  try {
    await navItem(labsLabel).click({ timeout: 15_000 });
  } catch (e) {
    check(`${label}: ${labsLabel} navigation item found`, false, e.message.split('\n')[0]);
    await writeFile(join(out, `flutter-web-${label}-a11y.json`), JSON.stringify(await page.accessibility.snapshot(), null, 1));
  }
  const labs = heading(labsLabel);
  await labs.waitFor({ timeout: 15_000 }).catch(() => {});
  check(`${label}: Labs principle visible`, await page.getByText(labsText).first().isVisible().catch(() => false));
  await labs.waitFor({ timeout: 15_000 }).catch(() => {});
  check(`${label}: navigates to ${labsLabel}`, await labs.isVisible().catch(() => false));
  await page.screenshot({ path: join(out, `flutter-web-${label}-labs.png`) });
  check(`${label}: no external network requests`, external.length === 0, external.slice(0, 5).join(' '));
  check(`${label}: no page errors`, errors.length === 0, errors.slice(0, 3).join(' | '));
  await page.close();
}
await browser.close();
server.close();
await writeFile(join(out, 'flutter_web_smoke.json'), JSON.stringify({ build: root, results }, null, 2));
for (const r of results) console.log(`${r.status.padEnd(5)} ${r.name}${r.detail ? `  (${r.detail})` : ''}`);
process.exit(results.every((r) => r.status === 'PASS') ? 0 : 1);
