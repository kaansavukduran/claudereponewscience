#!/usr/bin/env node
// Runtime smoke for the Flutter web build (v0.27 gate V3; FORGE 001, extended in 002):
// serve human_health_os/build/web locally, open it in Chromium (desktop + phone),
// enable Flutter semantics, assert Today is shown, navigate to Labs, and record
// every network request (the app must not need any external host).
// Usage: node tools/flutter_web_smoke.mjs [buildDir] [outDir]
// Env: EXPECT_FLUTTER_VERSION=<x.y.z> also checks the in-app build identity
// (v0.31 F001 AC-7); unset = the identity row is only required to exist.
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
  { label: 'desktop-en', viewport: { width: 1440, height: 900 }, locale: 'en-US', today: 'Today', timeline: 'Timeline', timelineText: /A correction adds a new version/, labs: 'Labs', labsText: /Reference interval ≠ optimal target/, banner: /DEVELOPMENT BUILD/ },
  { label: 'phone-en', viewport: { width: 390, height: 844 }, locale: 'en-US', today: 'Today', timeline: 'Timeline', timelineText: /A correction adds a new version/, labs: 'Labs', labsText: /Reference interval ≠ optimal target/, banner: /DEVELOPMENT BUILD/ },
  { label: 'phone-tr', viewport: { width: 390, height: 844 }, locale: 'tr-TR', today: 'Bugün', timeline: 'Zaman çizelgesi', timelineText: /Düzeltme yeni bir sürüm ekler/, labs: 'Lab', labsText: /Referans aralığı ≠ optimal hedef/, banner: /GELİŞTİRME DERLEMESİ/ },
];
const expectFlutter = process.env.EXPECT_FLUTTER_VERSION;
for (const { label, viewport, locale, today: todayLabel, timeline: timelineLabel, timelineText, labs: labsLabel, labsText, banner } of RUNS) {
  const page = await browser.newPage({ viewport, locale });
  const external = [];
  const errors = [];
  page.on('request', (r) => { const u = new URL(r.url()); if (!['127.0.0.1', 'localhost'].includes(u.hostname) && u.protocol !== 'data:' && u.protocol !== 'blob:') external.push(r.url()); });
  page.on('pageerror', (e) => errors.push(e.message));
  // v0.32 runtime smoke step 4: no fatal console/runtime error. Every console
  // 'error' entry fails the run (no allowlist); failed or >= 400 responses too.
  const consoleErrors = [];
  const failedRequests = [];
  page.on('console', (m) => { if (m.type() === 'error') consoleErrors.push(m.text()); });
  page.on('requestfailed', (r) => failedRequests.push(`${r.url()} (${r.failure()?.errorText ?? 'failed'})`));
  page.on('response', (r) => { if (r.status() >= 400) failedRequests.push(`${r.url()} (HTTP ${r.status()})`); });
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
  if (locale === 'en-US') {
    const flutterRow = page.getByText('Flutter', { exact: true }).first();
    await flutterRow.scrollIntoViewIfNeeded().catch(() => {});
    check(`${label}: build identity row (Flutter) present`, await flutterRow.isVisible().catch(() => false));
    if (expectFlutter) {
      check(`${label}: build identity shows Flutter ${expectFlutter}`, await page.getByText(expectFlutter, { exact: true }).first().isVisible().catch(() => false));
    }
  }
  await page.screenshot({ path: join(out, `flutter-web-${label}-today.png`) });
  // v0.31 F001: Today → Timeline → Labs.
  try {
    await navItem(timelineLabel).click({ timeout: 15_000 });
  } catch (e) {
    check(`${label}: ${timelineLabel} navigation item found`, false, e.message.split('\n')[0]);
  }
  const timeline = heading(timelineLabel);
  await timeline.waitFor({ timeout: 15_000 }).catch(() => {});
  check(`${label}: navigates to ${timelineLabel}`, await timeline.isVisible().catch(() => false));
  check(`${label}: Timeline principle visible`, await page.getByText(timelineText).first().isVisible().catch(() => false));
  await page.screenshot({ path: join(out, `flutter-web-${label}-timeline.png`) });
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
    // F003: the saved weight is on the Timeline after the reload.
    // The Timeline must really be open: Today shows the same value, so a
    // failed click must fail the check (review finding).
    let onTimelineScreen = true;
    try {
      await navItem(timelineLabel).click({ timeout: 10_000 });
      await heading(timelineLabel).waitFor({ timeout: 15_000 });
      await page.getByText(timelineText).first().waitFor({ timeout: 15_000 });
      onTimelineScreen = !(await heading(todayLabel).isVisible().catch(() => false));
    } catch {
      onTimelineScreen = false;
    }
    const onTimeline = page.getByText('78.4 kg').first();
    await onTimeline.waitFor({ timeout: 15_000 }).catch(() => {});
    check(`${label}: saved weight listed on the Timeline`, onTimelineScreen && (await onTimeline.isVisible().catch(() => false)));
    check(`${label}: Timeline does not say "No records yet"`, !(await page.getByText('No records yet').first().isVisible().catch(() => false)));
    await page.screenshot({ path: join(out, `flutter-web-${label}-timeline-records.png`) });
    // F004: a lab result typed as printed survives a reload, with its flag
    // labelled as the lab's and no interpretation added.
    await navItem(labsLabel).click().catch(() => {});
    await heading(labsLabel).waitFor({ timeout: 15_000 }).catch(() => {});
    // Flutter hit-tests clicks by screen position, so an off-screen field
    // must be scrolled into view by Flutter itself (wheel over the list
    // padding; semantics <input>s swallow wheel events) before a click.
    // Wheel just left of the Labs heading: inside the list's padding on any
    // layout (rail or bottom bar), never over a text field.
    const head = await heading(labsLabel).boundingBox().catch(() => null);
    const wheelX = head ? Math.max(2, head.x - 8) : viewport.width - 6;
    const intoView = async (locator) => {
      for (let i = 0; i < 20; i++) {
        const b = await locator.boundingBox().catch(() => null);
        if (b && b.y >= 110 && b.y + b.height <= viewport.height - 90) return;
        const dy = b ? Math.max(-400, Math.min(400, b.y - viewport.height / 2)) : 300;
        await page.mouse.move(wheelX, viewport.height / 2);
        await page.mouse.wheel(0, dy);
        await page.waitForTimeout(250);
      }
    };
    // Flutter web moves its hidden DOM input when focus changes; keys typed
    // before that settles are dropped, so wait and type at a human pace.
    const typeInto = async (name, text) => {
      const box = page.getByRole('textbox', { name }).first();
      await intoView(box);
      await box.click({ timeout: 10_000 });
      await page.waitForTimeout(400);
      await page.keyboard.type(text, { delay: 60 });
      await page.waitForTimeout(200);
    };
    try {
      await typeInto(/Test name as printed/, 'HbA1c');
      await typeInto(/^Value/, '5,4');
      await typeInto(/Unit as printed/, '%');
      await typeInto(/Flag printed by the lab/, 'H');
      await typeInto(/Reference range as printed/, '4.0 - 6.0');
      const save = page.getByRole('button', { name: 'Save', exact: true }).first();
      await intoView(save);
      await save.click({ timeout: 10_000 });
    } catch (e) {
      check(`${label}: lab form usable`, false, e.message.split('\n')[0]);
    }
    // On screen, not just present in the semantics tree.
    const scrollTo = async (locator) => {
      await locator.waitFor({ state: 'attached', timeout: 5_000 }).catch(() => {});
      for (let i = 0; i < 25 && (await locator.count()) === 0; i++) {
        await page.mouse.move(wheelX, viewport.height / 2);
        await page.mouse.wheel(0, 300);
        await page.waitForTimeout(200);
      }
      await intoView(locator);
      const b = await locator.boundingBox().catch(() => null);
      return !!b && b.y >= 0 && b.y + b.height <= viewport.height;
    };
    check(`${label}: lab result listed as printed`, await scrollTo(page.getByText('5,4 %').first()));
    check(`${label}: lab flag labelled as the lab's`, await scrollTo(page.getByText('Lab flag: H').first()));
    await page.reload({ waitUntil: 'load' });
    await page.waitForSelector('flutter-view', { state: 'attached', timeout: 60_000 });
    for (let i = 0; i < 40 && (await page.locator('flt-semantics').count()) === 0; i++) {
      await page.locator('flt-semantics-placeholder').dispatchEvent('click').catch(() => {});
      await page.waitForTimeout(500);
    }
    await navItem(labsLabel).click().catch(() => {});
    await heading(labsLabel).waitFor({ timeout: 15_000 }).catch(() => {});
    check(`${label}: lab result survives reload`, await scrollTo(page.getByText('5,4 %').first()));
    check(`${label}: no "normal/abnormal" wording on Labs`, !(await page.getByText(/\b(abnormal|normal)\b/i).first().isVisible().catch(() => false)));
    await page.screenshot({ path: join(out, `flutter-web-${label}-labs-result.png`) });
    // F005: a backup downloads as a file (a local Blob, no network) whose
    // manifest checksum matches its payload.
    await navItem(todayLabel).click().catch(() => {});
    await heading(todayLabel).waitFor({ timeout: 15_000 }).catch(() => {});
    const todayHead = await heading(todayLabel).boundingBox().catch(() => null);
    const todayWheelX = todayHead ? Math.max(2, todayHead.x - 8) : wheelX;
    const backupButton = page.getByRole('button', { name: 'Create backup' }).first();
    for (let i = 0; i < 25 && (await backupButton.count()) === 0; i++) {
      await page.mouse.move(todayWheelX, viewport.height / 2);
      await page.mouse.wheel(0, 300);
      await page.waitForTimeout(200);
    }
    for (let i = 0; i < 20; i++) {
      const b = await backupButton.boundingBox().catch(() => null);
      if (b && b.y >= 110 && b.y + b.height <= viewport.height - 90) break;
      await page.mouse.move(todayWheelX, viewport.height / 2);
      await page.mouse.wheel(0, b ? Math.max(-400, Math.min(400, b.y - viewport.height / 2)) : 300);
      await page.waitForTimeout(250);
    }
    try {
      const [download] = await Promise.all([
        page.waitForEvent('download', { timeout: 15_000 }),
        backupButton.click({ timeout: 10_000 }),
      ]);
      const saved = join(out, `flutter-web-${label}-backup.json`);
      await download.saveAs(saved);
      const bundle = JSON.parse(await readFile(saved, 'utf8'));
      const digest = createHash('sha256').update(bundle.payload, 'utf8').digest('hex');
      check(`${label}: backup downloads with a matching checksum`, bundle.manifest.payload_sha256 === digest && bundle.manifest.format === 'hhos-backup', `${download.suggestedFilename()}`);
      check(`${label}: backup holds the saved weight and lab result`, bundle.manifest.record_count >= 2 && bundle.payload.includes('"analyte_label":"HbA1c"'), `records=${bundle.manifest.record_count}`);
      check(`${label}: backup says it is not encrypted`, bundle.manifest.encryption === 'none-dev-only');
    } catch (e) {
      check(`${label}: backup downloads with a matching checksum`, false, e.message.split('\n')[0]);
    }
  }
  check(`${label}: no external network requests`, external.length === 0, external.slice(0, 5).join(' '));
  check(`${label}: no page errors`, errors.length === 0, errors.slice(0, 3).join(' | '));
  check(`${label}: no console errors`, consoleErrors.length === 0, consoleErrors.slice(0, 3).join(' | '));
  check(`${label}: no failed requests`, failedRequests.length === 0, failedRequests.slice(0, 3).join(' | '));
  await page.close();
}
await browser.close();
server.close();
// Evidence metadata ties this result to one exact build (audit L3).
const sha256 = async (f) => createHash('sha256').update(await readFile(f)).digest('hex');
const gitRev = (() => { try { return execFileSync('git', ['rev-parse', 'HEAD'], { encoding: 'utf8' }).trim(); } catch { return 'unknown'; } })();
// Same rule as tools/evidence/run_gate.py: evidence outputs do not make the source dirty.
const gitDirty = (() => { try { return execFileSync('git', ['status', '--porcelain', '--', '.', ':!reports', ':!evidence'], { encoding: 'utf8' }).trim() !== ''; } catch { return null; } })();
const meta = {
  ran_at: new Date().toISOString(),
  git_head: gitRev,
  working_tree_dirty: gitDirty,
  build: root,
  main_dart_js_sha256: await sha256(join(root, 'main.dart.js')).catch(() => 'missing'),
  browser: `chromium ${browserVersion}`,
  runs: RUNS.map(({ label, viewport, locale }) => ({ label, viewport, locale })),
};
const report = JSON.stringify({ ...meta, results }, null, 2);
await writeFile(join(out, 'flutter_web_smoke.json'), report);
// Per-revision copy, so a later run never overwrites the evidence of this one.
await writeFile(join(out, `flutter_web_smoke_${gitRev.slice(0, 12)}.json`), report);
for (const r of results) console.log(`${r.status.padEnd(5)} ${r.name}${r.detail ? `  (${r.detail})` : ''}`);
process.exit(results.every((r) => r.status === 'PASS') ? 0 : 1);
