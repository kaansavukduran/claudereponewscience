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
// CHROME_EXECUTABLE names a Chromium to use when Playwright's own browser build is not installed.
const browser = await chromium.launch(process.env.CHROME_EXECUTABLE ? { executablePath: process.env.CHROME_EXECUTABLE } : {});
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
  // U014: a fresh browser shows the short introduction first; it must be
  // skippable with one click.
  const skipIntro = async () => {
    const b = page.getByRole('button', { name: /^(Skip|Atla)$/ }).first();
    await b.waitFor({ timeout: 1_500 }).catch(() => {});
    if ((await b.count()) > 0) await b.click().catch(() => {});
    await page.waitForTimeout(300);
  };
  // R002: the browser build cannot remember that the introduction was seen
  // (G-62), so it is not offered there: Today comes first.
  await today.waitFor({ timeout: 30_000 }).catch(() => {});
  check(
    `${label}: no introduction forced in the browser`,
    (await page.getByRole('button', { name: /^(Skip|Atla)$/ }).count()) === 0,
  );
  check(`${label}: app starts and shows ${todayLabel}`, await today.isVisible().catch(() => false));
  check(`${label}: development profile banner visible`, await page.getByText(banner).first().isVisible().catch(() => false));
  if (locale === 'en-US') {
    const flutterRow = page.getByText('Flutter', { exact: true }).first();
    // Today is a lazy list: Flutter builds the row only once it scrolls
    // near it, so wheel over the list padding (left of the heading) first.
    const th = await today.boundingBox().catch(() => null);
    const tx = th ? Math.max(2, th.x - 8) : viewport.width - 6;
    for (let i = 0; i < 30 && (await flutterRow.count()) === 0; i++) {
      await page.mouse.move(tx, viewport.height / 2);
      await page.mouse.wheel(0, 400);
      await page.waitForTimeout(200);
    }
    await flutterRow.scrollIntoViewIfNeeded().catch(() => {});
    check(`${label}: build identity row (Flutter) present`, await flutterRow.isVisible().catch(() => false));
    if (expectFlutter) {
      check(`${label}: build identity shows Flutter ${expectFlutter}`, await page.getByText(expectFlutter, { exact: true }).first().isVisible().catch(() => false));
    }
    for (let i = 0; i < 10; i++) {
      await page.mouse.move(tx, viewport.height / 2);
      await page.mouse.wheel(0, -2000);
      await page.waitForTimeout(100);
    }
    await page.waitForTimeout(300);
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
    // The browser build keeps settings in memory: the introduction returns.
    await skipIntro();
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
    const intoView = async (locator, x = wheelX) => {
      for (let i = 0; i < 20; i++) {
        const b = await locator.boundingBox().catch(() => null);
        if (b && b.y >= 110 && b.y + b.height <= viewport.height - 90) return;
        const dy = b ? Math.max(-400, Math.min(400, b.y - viewport.height / 2)) : 300;
        await page.mouse.move(x, viewport.height / 2);
        await page.mouse.wheel(0, dy);
        await page.waitForTimeout(250);
      }
    };
    // Flutter web moves its hidden DOM input when focus changes; keys typed
    // before that settles are dropped, so wait and type at a human pace.
    const typeInto = async (name, text, x = wheelX) => {
      const box = page.getByRole('textbox', { name }).first();
      await intoView(box, x);
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
    const scrollTo = async (locator, x = wheelX) => {
      await locator.waitFor({ state: 'attached', timeout: 5_000 }).catch(() => {});
      for (let i = 0; i < 25 && (await locator.count()) === 0; i++) {
        await page.mouse.move(x, viewport.height / 2);
        await page.mouse.wheel(0, 300);
        await page.waitForTimeout(200);
      }
      await intoView(locator, x);
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
    // The browser build keeps settings in memory: the introduction returns.
    await skipIntro();
    await navItem(labsLabel).click().catch(() => {});
    await heading(labsLabel).waitFor({ timeout: 15_000 }).catch(() => {});
    check(`${label}: lab result survives reload`, await scrollTo(page.getByText('5,4 %').first()));
    check(`${label}: no "normal/abnormal" wording on Labs`, !(await page.getByText(/\b(abnormal|normal)\b/i).first().isVisible().catch(() => false)));
    await page.screenshot({ path: join(out, `flutter-web-${label}-labs-result.png`) });
    // F007: a blood pressure reading typed on Today is one record with two
    // numbers, shown as typed, never judged; it survives a reload and is
    // listed on the Timeline.
    const openToday = async () => {
      await navItem(todayLabel).click().catch(() => {});
      await heading(todayLabel).waitFor({ timeout: 15_000 }).catch(() => {});
      const h = await heading(todayLabel).boundingBox().catch(() => null);
      return h ? Math.max(2, h.x - 8) : wheelX;
    };
    let todayX = await openToday();
    // A tile is a button named by its spoken summary; a sheet holds one entry.
    const tile = (kind) => page.getByRole('button', { name: new RegExp(`^${kind}`) }).first();
    const spokenBp = /^Blood pressure: systolic 118, diastolic 76 millimetres of mercury, measured /;
    const spokenHeight = /^Height: 172\.5 centimetres, measured \d{4}-\d{2}-\d{2} \d{2}:\d{2}, saved /;
    const saveSheet = async () => {
      const save = page.getByRole('button', { name: 'Save measurement', exact: true }).first();
      await save.click({ timeout: 10_000 });
      await page.getByText('Saved', { exact: false }).first().waitFor({ timeout: 10_000 }).catch(() => {});
    };
    try {
      await scrollTo(tile('Blood pressure'), todayX);
      await tile('Blood pressure').click({ timeout: 10_000 });
      await page.waitForTimeout(500);
      await typeInto(/Systolic, the upper number/, '118', todayX);
      await typeInto(/Diastolic, the lower number/, '76', todayX);
      await saveSheet();
    } catch (e) {
      check(`${label}: measurement sheet usable`, false, e.message.split('\n')[0]);
      await writeFile(join(out, `flutter-web-${label}-a11y-today.json`), JSON.stringify(await page.accessibility.snapshot(), null, 1));
    }
    check(`${label}: blood pressure saved as typed (spoken summary 118/76)`, await scrollTo(tile('Blood pressure').filter({ hasText: spokenBp }), todayX));
    // Slice 2: a height typed with a time (a measurement of an earlier day).
    try {
      await scrollTo(tile('Height'), todayX);
      await tile('Height').click({ timeout: 10_000 });
      await page.waitForTimeout(500);
      await typeInto(/Height \(cm\)/, '172,5', todayX);
      await page.getByRole('button', { name: 'More details' }).first().click({ timeout: 10_000 });
      await page.waitForTimeout(500);
      await typeInto(/When \(optional\)/, '2026-10-01 08:00Z', todayX);
      await saveSheet();
    } catch (e) {
      check(`${label}: height with a time usable`, false, e.message.split('\n')[0]);
    }
    check(`${label}: height saved with its measured time and the save time`, await scrollTo(tile('Height').filter({ hasText: spokenHeight }), todayX));
    check(`${label}: no judging words on the measurements`, !(await page.getByText(/\b(hypertension|hypotension|elevated|stage \d|normal|abnormal|fever|hypoxia)\b/i).first().isVisible().catch(() => false)));
    await page.screenshot({ path: join(out, `flutter-web-${label}-measurement.png`) });
    await page.reload({ waitUntil: 'load' });
    await page.waitForSelector('flutter-view', { state: 'attached', timeout: 60_000 });
    for (let i = 0; i < 40 && (await page.locator('flt-semantics').count()) === 0; i++) {
      await page.locator('flt-semantics-placeholder').dispatchEvent('click').catch(() => {});
      await page.waitForTimeout(500);
    }
    // The browser build keeps settings in memory: the introduction returns.
    await skipIntro();
    todayX = await openToday();
    check(`${label}: blood pressure survives reload`, await scrollTo(tile('Blood pressure').filter({ hasText: spokenBp }), todayX));
    check(`${label}: height survives reload`, await scrollTo(tile('Height').filter({ hasText: spokenHeight }), todayX));
    let bpOnTimeline = true;
    try {
      await navItem(timelineLabel).click({ timeout: 10_000 });
      await heading(timelineLabel).waitFor({ timeout: 15_000 });
      await page.getByText(timelineText).first().waitFor({ timeout: 15_000 });
      bpOnTimeline = !(await heading(todayLabel).isVisible().catch(() => false));
    } catch {
      bpOnTimeline = false;
    }
    const bpRow = page.getByText('118/76 mmHg').first();
    await bpRow.waitFor({ timeout: 15_000 }).catch(() => {});
    check(`${label}: blood pressure listed on the Timeline`, bpOnTimeline && (await bpRow.isVisible().catch(() => false)));
    check(`${label}: height listed on the Timeline`, await page.getByText('172.5 cm').first().isVisible().catch(() => false));
    await page.screenshot({ path: join(out, `flutter-web-${label}-timeline-measurement.png`) });
    // G001: the Genetics page opens from Today, shows the pre-load notice, and
    // loads the invented sample (no native file dialog) with its invented pack.
    try {
      todayX = await openToday();
      const toolTile = page.getByRole('button', { name: /Genetics/ }).first();
      await scrollTo(toolTile, todayX);
      await toolTile.click({ timeout: 10_000 });
      await page.getByText('Before you load a file').first().waitFor({ timeout: 15_000 });
      check(`${label}: genetics page shows the notice before any file`, await page.getByText(/identifies you for life/).first().isVisible().catch(() => false));
      await page.getByRole('button', { name: 'Try an invented sample file' }).first().click({ timeout: 10_000 });
      await page.getByText('Invented sample file: not a real person').first().waitFor({ timeout: 15_000 });
      check(`${label}: genetics sample loaded (12 variants, none judged)`, await page.getByText(/Variants in the file: 12/).first().isVisible().catch(() => false));
      check(`${label}: genetics shows the invented pack label`, await scrollTo(page.getByText(/INVENTED demonstration pack/).first(), 6));
      check(`${label}: no judging words on the genetics page`, !(await page.getByText(/\b(risk|carrier|mutation|pathogenic|healthy)\b/i).first().isVisible().catch(() => false)));
      await page.screenshot({ path: join(out, `flutter-web-${label}-genetics.png`) });
      await page.getByRole('button', { name: /Back/ }).first().click({ timeout: 10_000 });
    } catch (e) {
      check(`${label}: genetics page usable`, false, e.message.split('\n')[0]);
    }
    await navItem(todayLabel).click().catch(() => {});
    await heading(todayLabel).waitFor({ timeout: 15_000 }).catch(() => {});
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
      check(`${label}: backup holds the blood pressure reading as typed`, bundle.payload.includes('"kind":"vital.blood_pressure"') && bundle.payload.includes('"systolic_text":"118"') && bundle.payload.includes('"diastolic_text":"76"') && bundle.manifest.record_schema_versions.includes(4), `schemas=${bundle.manifest.record_schema_versions}`);
      check(`${label}: backup holds the height as typed, with its measured time, at schema 5`, bundle.payload.includes('"kind":"body.height"') && bundle.payload.includes('"original_text":"172,5"') && bundle.payload.includes('"observed_at":"2026-10-01T08:00:00.000Z"') && bundle.manifest.record_schema_versions.includes(5), `schemas=${bundle.manifest.record_schema_versions}`);
    } catch (e) {
      check(`${label}: backup downloads with a matching checksum`, false, e.message.split('\n')[0]);
    }
  }
  // T003: the areas built since F007 (Medications, Nutrition, Activity,
  // Conditions, Preventive) and Today's Sleep and "How you feel" cards. Every run sees
  // each title and empty state; the English runs also add one activity and
  // one condition. The network and console checks below cover these steps.
  {
    const en = locale === 'en-US';
    const A = en
      ? { meds: 'Medications', medsTitle: 'Medicines and supplements', medsNone: /^Nothing added yet\. Add a medicine or supplement/, more: 'More', none: 'Nothing recorded yet.', sleep: 'Sleep', feel: 'How you feel',
          areas: [['Nutrition', 'Nutrition'], ['Activity', 'Activity'], ['Conditions', 'Conditions and symptoms'], ['Preventive', 'Vaccinations, screenings, check-ups']] }
      : { meds: 'İlaçlar', medsTitle: 'İlaçlar ve takviyeler', medsNone: /^Henüz bir şey eklenmedi\. Başlamak için/, more: 'Daha fazla', none: 'Henüz kayıt yok.', sleep: 'Uyku', feel: 'Nasıl hissediyorsun',
          areas: [['Nutrition', 'Beslenme', 'Beslenme'], ['Activity', 'Aktivite', 'Aktivite'], ['Conditions', 'Durumlar', 'Durumlar ve belirtiler'], ['Preventive', 'Koruyucu', 'Aşılar, taramalar, kontroller']].map(([, item, title]) => [item, title]) };
    // A secondary area: under "More areas" on the rail, or in the "More" sheet.
    const openArea = async (item) => {
      const onRail = page.getByRole('button', { name: item, exact: true }).first();
      if ((await onRail.count()) === 0) {
        await page.getByRole('tab', { name: A.more, exact: true }).first().click({ timeout: 10_000 });
        await page.waitForTimeout(600);
      }
      await page.getByRole('button', { name: item, exact: true }).or(page.getByText(item, { exact: true })).last().click({ timeout: 10_000 });
    };
    // Flutter merges a row's texts into one node named by aria-label (an
    // empty state is a group), so match the accessible name or the text.
    const named = (re) => page.getByLabel(re).or(page.getByText(re)).first();
    const esc = (t) => t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    try {
      await navItem(A.meds).click({ timeout: 15_000 });
      await heading(A.medsTitle).waitFor({ timeout: 15_000 }).catch(() => {});
      check(`${label}: navigates to ${A.meds}`, await heading(A.medsTitle).isVisible().catch(() => false));
      check(`${label}: ${A.meds} empty state shown`, await named(A.medsNone).isVisible().catch(() => false));
    } catch (e) {
      check(`${label}: ${A.meds} navigation item found`, false, e.message.split('\n')[0]);
    }
    for (const [item, title] of A.areas) {
      try {
        await openArea(item);
        await heading(title).waitFor({ timeout: 15_000 }).catch(() => {});
        check(`${label}: opens ${item} from the more areas`, await heading(title).isVisible().catch(() => false));
        check(`${label}: ${item} empty state says nothing recorded`, await named(new RegExp(`^${esc(A.none)}$`)).isVisible().catch(() => false));
      } catch (e) {
        check(`${label}: opens ${item} from the more areas`, false, e.message.split('\n')[0]);
      }
      if (en && item === 'Activity') {
        try {
          await page.getByRole('button', { name: 'Add an activity' }).first().click({ timeout: 10_000 });
          await page.waitForTimeout(600);
          for (const [name, value] of [[/^What it was/, 'Walk'], [/^Minutes \(optional\)/, '20']]) {
            await page.getByRole('textbox', { name }).first().click({ timeout: 10_000 });
            await page.waitForTimeout(400);
            await page.keyboard.type(value, { delay: 60 });
            await page.waitForTimeout(200);
          }
          await page.getByRole('button', { name: 'Save', exact: true }).last().click({ timeout: 10_000 });
        } catch (e) {
          check(`${label}: activity sheet usable`, false, e.message.split('\n')[0]);
        }
        const walk = named(/^Walk · 20 min(\s|$)/);
        await walk.waitFor({ timeout: 15_000 }).catch(() => {});
        check(`${label}: activity saved as "Walk · 20 min"`, await walk.isVisible().catch(() => false));
        await page.screenshot({ path: join(out, `flutter-web-${label}-activity.png`) });
      }
      if (en && item === 'Conditions') {
        try {
          await page.getByRole('button', { name: 'Add a condition or symptom' }).first().click({ timeout: 10_000 });
          await page.waitForTimeout(600);
          await page.getByRole('textbox', { name: /^What it is, in your words/ }).first().click({ timeout: 10_000 });
          await page.waitForTimeout(400);
          await page.keyboard.type('Cough', { delay: 60 });
          await page.waitForTimeout(200);
          await page.getByRole('button', { name: 'Save', exact: true }).last().click({ timeout: 10_000 });
        } catch (e) {
          check(`${label}: condition sheet usable`, false, e.message.split('\n')[0]);
        }
        // The line names it as typed and keeps "not sure" until the person chooses.
        const cough = named(/^Cough · condition · It is: not sure · my own account/);
        await cough.waitFor({ timeout: 15_000 }).catch(() => {});
        check(`${label}: condition saved as named ("Cough", not sure, self-reported)`, await cough.isVisible().catch(() => false));
        await page.screenshot({ path: join(out, `flutter-web-${label}-conditions.png`) });
      }
    }
    // Today's check-in cards (lazy list: wheel over the padding until built).
    await navItem(todayLabel).click().catch(() => {});
    await heading(todayLabel).waitFor({ timeout: 15_000 }).catch(() => {});
    const h = await heading(todayLabel).boundingBox().catch(() => null);
    const cx = h ? Math.max(2, h.x - 8) : viewport.width - 6;
    // Today keeps its scroll position from earlier steps: back to the top first.
    for (let i = 0; i < 10; i++) {
      await page.mouse.move(cx, viewport.height / 2);
      await page.mouse.wheel(0, -2000);
      await page.waitForTimeout(100);
    }
    await page.waitForTimeout(300);
    for (const card of [A.sleep, A.feel]) {
      // The card's header node carries its title first, then its body.
      const re = new RegExp(`^${esc(card)}(\\s|$)`);
      const t = page.getByRole('heading', { name: re }).or(page.getByLabel(re)).first();
      for (let i = 0; i < 40 && (await t.count()) === 0; i++) {
        await page.mouse.move(cx, viewport.height / 2);
        await page.mouse.wheel(0, 200);
        await page.waitForTimeout(300);
      }
      check(`${label}: Today shows the ${card} card`, await t.isVisible().catch(() => false));
    }
    await page.screenshot({ path: join(out, `flutter-web-${label}-checkin-cards.png`) });
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
