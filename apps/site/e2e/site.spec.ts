// Site Build Prompt v0.24 — TESTS 1–10 plus v0.21–v0.24 lab semantics, against the real production build.
import { expect, test, type Page } from '@playwright/test';

async function open(page: Page) {
  await page.goto('/');
  await page.evaluate(() => localStorage.clear());
  await page.reload();
  await expect(page.getByTestId('tour')).toBeVisible(); // zero-knowledge first-run tour
  await page.getByTestId('tour-skip').click();
}

const metric = (page: Page, id: string) => page.getByTestId(id).locator('.hh-metric, .hh-missing').first();

test('1 · default synthetic profile loads (AT-756)', async ({ page }) => {
  await open(page);
  await expect(page.getByText('SYNTHETIC DEMO').first()).toBeVisible();
  await expect(page.getByRole('button', { name: 'Synthetic A · basic' })).toHaveAttribute('aria-pressed', 'true');
  await expect(metric(page, 'card-bmi')).toContainText('26.4');
});

test('2 · changing weight updates BMI deterministically', async ({ page }) => {
  await open(page);
  await page.getByTestId('field-weight_kg').fill('90');
  await expect(metric(page, 'card-bmi')).toContainText('30.4'); // 90 / 1.72²
});

test('3 · scenario clone edits never mutate the source (AT-762)', async ({ page }) => {
  await open(page);
  await page.getByRole('button', { name: /Clone scenario/ }).click();
  await expect(page.getByText('HYPOTHETICAL SCENARIO').first()).toBeVisible();
  await page.getByTestId('field-weight_kg').fill('60');
  await expect(metric(page, 'card-bmi')).toContainText('20.3');
  await page.getByRole('button', { name: 'Synthetic A · basic', exact: true }).click();
  await expect(page.getByTestId('field-weight_kg')).toHaveValue('78');
  await expect(metric(page, 'card-bmi')).toContainText('26.4');
});

test('4 · reset returns the demo to declared defaults (AT-763/764)', async ({ page }) => {
  await open(page);
  await page.getByTestId('field-weight_kg').fill('120');
  await page.getByRole('button', { name: /Clone scenario/ }).click();
  await page.getByTestId('reset-demo').click();
  await expect(page.getByRole('alertdialog')).toContainText('not health-data deletion');
  await page.getByTestId('confirm-yes').click();
  await expect(page.getByRole('button', { name: /scenario/ })).toHaveCount(1); // only the "Clone scenario" action remains
  await expect(page.getByTestId('field-weight_kg')).toHaveValue('78');
});

test('5 · missing inputs never become zero', async ({ page }) => {
  await open(page);
  const waist = page.getByTestId('field-waist_cm');
  await waist.fill('');
  await expect(waist).toHaveValue('');
  await expect(page.getByTestId('card-whtr')).toContainText('Missing — not zero');
  await expect(page.getByTestId('card-whtr').locator('.hh-metric')).toHaveCount(0);
});

test('6 · ineligible/unlicensed model shows an explicit state, never a percentage (AT-760/780)', async ({ page }) => {
  await open(page);
  const card = page.getByTestId('ext-EXT-AHA-PREVENT');
  await expect(card).toContainText('Unavailable');
  await expect(card).toContainText('LICENSE_ACCEPTANCE_REQUIRED_NOT_BUNDLED');
  await expect(card.locator('.hh-metric')).toHaveCount(0);
});

test('7 · compare works with 3+ profiles and %Δ only where meaningful (AT-761)', async ({ page }) => {
  await open(page);
  await page.getByRole('button', { name: 'Compare' }).click();
  await page.getByTestId('cmp-clone').click();
  const table = page.getByTestId('compare-table');
  await expect(table.locator('thead th')).toHaveCount(1 + 5);
  await expect(table).toContainText('Δ +34 · +43.6%');
  await expect(table).toContainText('%Δ n/a');
  await expect(table.getByTestId('cell-state').first()).toBeVisible();
});

test('8 · layout has no horizontal page scroll', async ({ page }) => {
  await open(page);
  for (const tab of ['Profile & results', 'Compare', 'Lab interpretation', 'Preventive care', 'Meds & supplements', 'Nutrition math', 'Daily missions', 'Timeline & wearables', 'Learn', 'Sources & licenses']) {
    await page.getByRole('button', { name: tab }).click();
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
    expect(overflow, tab).toBeLessThanOrEqual(1);
  }
});

test('9 · primary controls are keyboard operable', async ({ page, isMobile }) => {
  test.skip(!!isMobile, 'keyboard flow verified on desktop');
  await open(page);
  await page.getByRole('button', { name: 'Compare' }).focus();
  await page.keyboard.press('Enter');
  await expect(page.getByRole('heading', { name: /Compare Lab/ })).toBeVisible();
  const weight = page.getByRole('button', { name: 'Profile & results' });
  await weight.focus();
  await page.keyboard.press('Enter');
  await page.getByTestId('field-weight_kg').focus();
  await page.keyboard.press('Control+A');
  await page.keyboard.type('100');
  await expect(metric(page, 'card-bmi')).toContainText('33.8');
});

test('10 · deterministic repeatability across reloads', async ({ page }) => {
  await open(page);
  const read = async () => Promise.all(['card-protection', 'card-burden', 'card-function', 'card-coverage', 'card-bmi'].map((id) => metric(page, id).innerText()));
  const a = await read();
  await page.reload();
  const b = await read();
  expect(b).toEqual(a);
});

test('lab interpretation: outside ≠ critical, method change marks discontinuity (v0.24)', async ({ page }) => {
  await open(page);
  await page.getByRole('button', { name: 'Lab interpretation' }).click();
  await page.getByTestId('preset-outside-not-critical').click();
  await expect(page.getByTestId('li-reference')).toContainText('ABOVE_REFERENCE');
  await expect(page.getByTestId('li-critical')).toContainText('NO_MATCH');
  await page.getByTestId('preset-method-change').click();
  await expect(page.getByTestId('li-method-state')).toContainText('UNKNOWN_COMPARABILITY');
  await expect(page.getByTestId('li-rcv')).toContainText('BLOCKED_BY_COMPARABILITY');
  await page.getByTestId('preset-within-unusual').click();
  await expect(page.getByTestId('li-reference')).toContainText('WITHIN_REFERENCE');
  await expect(page.getByTestId('li-baseline')).toContainText('UNUSUAL_FOR_PERSON');
});

test('missions: notification opened ≠ completed; safety flag blocks training', async ({ page }) => {
  await open(page);
  await page.getByRole('button', { name: 'Daily missions' }).click();
  const bench = page.getByTestId('mission-RESISTANCE_PRESCRIPTION').first();
  await expect(bench).toContainText('Bench Press — 3 × 10 @ 32.5 kg');
  await bench.getByTestId('ms-notify').click();
  await expect(bench).toContainText('PLANNED');
  await bench.getByTestId('ms-complete').click();
  await expect(bench).toContainText('COMPLETED');
  await page.getByTestId('ms-safety').check();
  await expect(page.getByTestId('mission-RESISTANCE_PRESCRIPTION').first()).toContainText('BLOCKED');
});

test('preventive: unknown history is not "never done"; data sources page lists attribution', async ({ page }) => {
  await open(page);
  await page.getByRole('button', { name: 'Preventive care' }).click();
  await expect(page.getByTestId('pv-SVC-SYN-SCREENING-BETA')).toContainText('DUE_SOON');
  await page.getByTestId('pv-history').selectOption('UNKNOWN');
  await expect(page.getByTestId('pv-SVC-SYN-SCREENING-BETA')).toContainText('UNKNOWN_HISTORY');
  await page.getByRole('button', { name: 'Sources & licenses' }).click();
  await expect(page.getByTestId('attribution-table')).toContainText('USDA FoodData Central');
});
