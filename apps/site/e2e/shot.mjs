// Ad-hoc screenshot helper: node e2e/shot.mjs <outdir>
import { chromium } from '@playwright/test';
const out = process.argv[2] ?? '.';
const b = await chromium.launch();
for (const [name, vp] of [['desktop', { width: 1440, height: 900 }], ['mobile', { width: 390, height: 844 }]]) {
  const p = await b.newPage({ viewport: vp, colorScheme: name === 'desktop' ? 'dark' : 'light' });
  await p.goto('http://127.0.0.1:4174/');
  await p.getByTestId('tour-skip').click();
  await p.screenshot({ path: `${out}/${name}-lab.png`, fullPage: false });
  for (const tab of ['Compare', 'Lab interpretation', 'Preventive care', 'Daily missions']) {
    await p.getByRole('button', { name: tab }).click();
    await p.screenshot({ path: `${out}/${name}-${tab.split(' ')[0].toLowerCase()}.png`, fullPage: false });
  }
  await p.close();
}
await b.close();
