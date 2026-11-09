// Real Flutter Navigator/input/semantics smoke for U022. Uses only local files.
import { createServer } from 'node:http';
import { readFile, stat, mkdir, writeFile } from 'node:fs/promises';
import { join, extname, resolve } from 'node:path';
import { chromium } from '@playwright/test';
const root = resolve(process.argv[2] ?? 'human_health_os/build/web');
const out = resolve(process.argv[3] ?? 'reports/runtime/u022');
const types = { '.js': 'text/javascript', '.mjs': 'text/javascript', '.wasm': 'application/wasm', '.html': 'text/html', '.json': 'application/json', '.otf': 'font/otf', '.ttf': 'font/ttf' };
const server = createServer(async (req, res) => {
  try {
    let p = join(root, decodeURIComponent(new URL(req.url, 'http://local').pathname));
    if ((await stat(p)).isDirectory()) p = join(p, 'index.html');
    res.writeHead(200, { 'content-type': types[extname(p)] ?? 'application/octet-stream' });
    res.end(await readFile(p));
  } catch { res.writeHead(404).end(); }
});
await new Promise(r => server.listen(0, '127.0.0.1', r));
await mkdir(out, { recursive: true });
const browser = await chromium.launch(process.env.CHROME_EXECUTABLE ? { executablePath: process.env.CHROME_EXECUTABLE } : {});
const checks = [];
function check(name, ok, detail = '') { checks.push({ name, ok, detail }); console.log(`${ok ? 'PASS' : 'FAIL'} ${name} ${detail}`); }
try {
  for (const locale of ['en-US', 'tr-TR', 'de-DE']) {
    const tr = locale !== 'en-US';
    const page = await browser.newPage({ viewport: { width: 390, height: 900 }, locale });
    page.setDefaultTimeout(5000);
    const errors = [], external = [];
    page.on('pageerror', e => errors.push(e.message));
    page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
    page.on('request', r => { if (!['127.0.0.1', 'localhost'].includes(new URL(r.url()).hostname) && !/^(data|blob):/.test(r.url())) external.push(r.url()); });
    await page.goto(`http://127.0.0.1:${server.address().port}`);
    for (let i = 0; i < 80 && await page.locator('flt-semantics').count() === 0; i++) {
      await page.locator('flt-semantics-placeholder').dispatchEvent('click').catch(() => {});
      await page.waitForTimeout(250);
    }
    check(`${locale}: first language`, await page.getByRole('heading', { name: tr ? 'Bugün' : 'Today', exact: true }).first().isVisible());
    await page.getByRole('button', { name: tr ? 'Ayarlar' : 'Settings', exact: true }).first().click();
    const heading = page.getByRole('heading', { name: tr ? 'Ayarlar' : 'Settings', exact: true }).first();
    await heading.waitFor();
    await page.waitForTimeout(400);
    check(`${locale}: session persistence explained`, await page.getByText(tr ? /uygulama kapanana kadar/ : /until the app is closed/).first().isVisible());
    const reveal = async locator => {
      for (let i = 0; i < 35; i++) {
        const b = await locator.count() ? await locator.boundingBox().catch(() => null) : null;
        if (b && b.y >= 130 && b.y + b.height <= 870) return;
        await page.mouse.move(5, 450);
        await page.mouse.wheel(0, b ? Math.max(-350, Math.min(350, b.y - 350)) : 300);
        await page.waitForTimeout(100);
      }
      throw new Error('Control could not be revealed: ' + locator);
    };
    const click = async locator => {
      await reveal(locator);
      const b = await locator.boundingBox();
      await page.mouse.click(Math.min(370, b.x + b.width / 2), b.y + b.height / 2);
      await page.waitForTimeout(350);
    };
    const input = page.getByRole('textbox', { name: tr ? /Kesin ölçek/ : /Exact scale/ }).first();
    await reveal(input);
    const baseInputHeight = (await input.boundingBox()).height;
    await page.screenshot({ path: join(out, `before-input-${locale}.png`) });
    const inputBox = await input.boundingBox();
    await page.mouse.click(inputBox.x + 30, inputBox.y + inputBox.height / 2);
    await page.waitForTimeout(250);
    await page.keyboard.press('ControlOrMeta+A');
    await page.keyboard.type('135', { delay: 70 });
    await page.keyboard.press('Enter');
    await page.waitForTimeout(400);
    check(`${locale}: exact 135 applied and route preserved`, await heading.isVisible() && Math.abs((await input.boundingBox()).height / baseInputHeight - 1.35) < 0.05);
    const reset = page.getByRole('button', { name: tr ? 'Ölçeği %100 yap' : 'Reset scale to 100%', exact: true }).first();
    await reveal(reset);
    await page.screenshot({ path: join(out, `settings-${locale}-135.png`) });
    await click(reset);
    await page.waitForTimeout(300);
    const largest = page.getByRole('checkbox', { name: tr ? '%200' : '200%', exact: true }).first();
    await reveal(largest);
    await click(largest);
    await page.waitForTimeout(400);
    await reveal(reset);
    await page.screenshot({ path: join(out, `settings-${locale}-200.png`) });
    await reveal(input);
    check(`${locale}: 200 remains selected on narrow screen`, Math.abs((await input.boundingBox()).height / baseInputHeight - 2) < 0.05);
    await click(reset);
    await page.waitForTimeout(300);
    await reveal(input);
    await page.screenshot({path:join(out,`after-reset-${locale}.png`)});
    check(`${locale}: scale reset usable at 200`, Math.abs((await input.boundingBox()).height / baseInputHeight - 1) < 0.05);
    // Keep independent text/font/contrast controls exercised on the actual app.
    const font = page.getByRole('checkbox', { name: /OpenDyslexic/ }).first();
    await reveal(font);
    await click(font);
    const contrast = page.getByRole('switch', { name: tr ? /Güçlü kontrast/ : /Stronger contrast/ }).first();
    await reveal(contrast);
    await click(contrast);
    await page.screenshot({ path: join(out, `settings-${locale}-font-contrast.png`) });
    check(`${locale}: font and contrast controls usable`, await contrast.getAttribute('aria-checked') === 'true');
    check(`${locale}: no page or console errors`, errors.length === 0, errors.join(' | '));
    check(`${locale}: no external requests`, external.length === 0, external.join(' | '));
    await page.close();
  }
} catch (e) { check('appearance workflow completed', false, e.stack); }
finally { await browser.close(); server.close(); }
await writeFile(join(out, 'appearance_smoke.json'), JSON.stringify({ checks }, null, 2));
process.exitCode = checks.every(c => c.ok) ? 0 : 1;
