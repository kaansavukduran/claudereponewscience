#!/usr/bin/env node
// Runtime smoke for the Flutter web build (v0.27 gate V3; FORGE 001, extended in 002):
// serve human_health_os/build/web locally, open it in Chromium (desktop + phone),
// enable Flutter semantics, assert Today is shown, navigate to Labs, and record
// every network request (the app must not need any external host).
// Usage: node tools/flutter_web_smoke.mjs [buildDir] [outDir]
import { createServer } from 'node:http';
import { readFile, stat, mkdir, writeFile } from 'node:fs/promises';
import { extname, join, resolve } from 'node:path';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
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
const browserVersion = browser.version();
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
  // FORGE 002 heartbeat (en runs only): save a weight, reload, read it back from browser storage.
  if (locale === 'en-US') {
    await navItem(todayLabel).click();
    await heading(todayLabel).waitFor({ timeout: 15_000 }).catch(() => {});
    const empty = page.getByText(/No weight recorded yet/).first();
    check(`${label}: empty state says no weight (not 0)`, await empty.isVisible().catch(() => false));
    const box = page.getByRole('textbox', { name: /Weight \(kg\)/ }).first();
    await box.click();
    await page.keyboard.type('78,4');
    await page.getByRole('button', { name: 'Save', exact: true }).first().click();
    const latest = page.getByText('78.4 kg').first();
    await latest.waitFor({ timeout: 15_000 }).catch(() => {});
    check(`${label}: weight saved`, await latest.isVisible().catch(() => false));
    await page.reload({ waitUntil: 'load' });
    await page.waitForSelector('flutter-view', { state: 'attached', timeout: 60_000 });
    for (let i = 0; i < 40 && (await page.locator('flt-semantics').count()) === 0; i++) {
      await page.locator('flt-semantics-placeholder').dispatchEvent('click').catch(() => {});
      await page.waitForTimeout(500);
    }
    const after = page.getByText('78.4 kg').first();
    await after.waitFor({ timeout: 15_000 }).catch(() => {});
    check(`${label}: weight survives reload (browser storage)`, await after.isVisible().catch(() => false));
    check(`${label}: storage honesty label shown`, await page.getByText(/Saved in this browser \(it may be cleared\) · not encrypted/).first().isVisible().catch(() => false));
    await page.screenshot({ path: join(out, `flutter-web-${label}-weight.png`) });
  }
  check(`${label}: no external network requests`, external.length === 0, external.slice(0, 5).join(' '));
  check(`${label}: no page errors`, errors.length === 0, errors.slice(0, 3).join(' | '));
  await page.close();
}
await browser.close();
server.close();
// Evidence metadata ties this result to one exact build (audit L3).
const sha256 = async (f) => createHash('sha256').update(await readFile(f)).digest('hex');
const gitRev = (() => { try { return execFileSync('git', ['rev-parse', 'HEAD'], { encoding: 'utf8' }).trim(); } catch { return 'unknown'; } })();
const gitDirty = (() => { try { return execFileSync('git', ['status', '--porcelain'], { encoding: 'utf8' }).trim() !== ''; } catch { return null; } })();
const meta = {
  ran_at: new Date().toISOString(),
  git_head: gitRev,
  working_tree_dirty: gitDirty,
  build: root,
  main_dart_js_sha256: await sha256(join(root, 'main.dart.js')).catch(() => 'missing'),
  browser: `chromium ${browserVersion}`,
  runs: RUNS.map(({ label, viewport, locale }) => ({ label, viewport, locale })),
};
await writeFile(join(out, 'flutter_web_smoke.json'), JSON.stringify({ ...meta, results }, null, 2));
for (const r of results) console.log(`${r.status.padEnd(5)} ${r.name}${r.detail ? `  (${r.detail})` : ''}`);
process.exit(results.every((r) => r.status === 'PASS') ? 0 : 1);
