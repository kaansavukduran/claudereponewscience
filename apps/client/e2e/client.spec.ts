// Production client (web target) end-to-end: local-only IndexedDB flow and cloud flow against the real API.
import { expect, test } from '@playwright/test';

test('local-only onboarding → body → results (shared engine) → reset ≠ delete', async ({ page }) => {
  await page.goto('/');
  await page.getByTestId('mode-local').check();
  await page.getByTestId('onboard-next').click();
  await page.getByTestId('profile-name').fill('Me');
  await page.getByTestId('onboard-finish').click();
  await expect(page.getByTestId('mode-chip')).toContainText('Local only');

  await page.getByRole('button', { name: 'Body' }).click();
  await page.getByTestId('body-weight_kg').fill('80');
  await page.getByTestId('body-height_cm').fill('180');
  await expect(page.getByTestId('save-state')).toContainText('saved');

  await page.getByRole('button', { name: 'Results' }).click();
  await expect(page.getByTestId('c-bmi')).toContainText('24.7');
  await expect(page.getByTestId('c-protection')).toContainText('Insufficient data'); // sparse inputs → no fake score

  await page.reload(); // IndexedDB persistence
  await page.getByRole('button', { name: 'Results' }).click();
  await expect(page.getByTestId('c-bmi')).toContainText('24.7');

  await page.getByRole('button', { name: 'Settings' }).click();
  await page.getByTestId('reset-settings').click();
  await expect(page.getByTestId('settings-msg')).toContainText('Health records unchanged: 1 profiles');
});

test('labs: NOT_REPORTED is stored as missing; reference/critical channels stay separate', async ({ page }) => {
  await page.goto('/');
  await page.getByTestId('onboard-next').click();
  await page.getByTestId('onboard-finish').click();
  await page.getByRole('button', { name: 'Labs' }).click();
  await page.getByTestId('lab-analyte').fill('SYN-X');
  await page.getByTestId('lab-unit').fill('syn-u');
  await page.getByTestId('lab-nr').check();
  await page.getByTestId('lab-date').fill('2026-05-01');
  await page.getByTestId('lab-save').click();
  await page.getByTestId('lab-analyte').fill('SYN-X');
  await page.getByTestId('lab-value').fill('12');
  await page.getByTestId('lab-reflow').fill('4');
  await page.getByTestId('lab-refhigh').fill('10');
  await page.getByTestId('lab-date').fill('2026-06-01');
  await page.getByTestId('lab-save').click();
  const group = page.getByTestId('lab-group-SYN-X');
  await expect(group).toContainText('NOT_REPORTED');
  await expect(group).toContainText('ABOVE_REFERENCE');
  await expect(group).toContainText('NO_ACTIVE_RULE');
});

test('cloud account: onboarding against the API, compare with synthetic profiles + scenario', async ({ page }) => {
  await page.goto('/');
  await page.getByTestId('mode-cloud').check();
  await page.getByTestId('api-url').fill('http://127.0.0.1:8788');
  await page.getByTestId('onboard-next').click();
  await page.getByTestId('profile-name').fill('Cloud me');
  await page.getByTestId('onboard-finish').click();
  await expect(page.getByTestId('mode-chip')).toContainText('Cloud account');
  await page.getByRole('button', { name: 'Body' }).click();
  await page.getByTestId('body-weight_kg').fill('90');
  await page.getByTestId('body-height_cm').fill('175');
  await expect(page.getByTestId('save-state')).toContainText('saved');
  await page.getByRole('button', { name: 'Compare' }).click();
  await page.getByTestId('seed-synthetic').click();
  await page.getByTestId('clone-self').click();
  const table = page.getByTestId('client-compare');
  await expect(table.locator('thead th')).toHaveCount(1 + 6);
  await expect(table).toContainText('SCENARIO');
  await expect(table).toContainText('UNAVAILABLE');
});

test('today: a mission is a plan until a completion is logged', async ({ page }) => {
  await page.goto('/');
  await page.getByTestId('onboard-next').click();
  await page.getByTestId('onboard-finish').click();
  const m = page.getByTestId('today-WALK');
  await expect(m).toContainText('PLANNED');
  await m.getByTestId('today-complete').click();
  await expect(m).toContainText('COMPLETED');
});
