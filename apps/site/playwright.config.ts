import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 30_000,
  reporter: [['list'], ['json', { outputFile: '../../reports/tests/site-e2e.json' }]],
  use: { baseURL: 'http://127.0.0.1:4174', trace: 'off' },
  webServer: { command: 'pnpm build && pnpm preview', url: 'http://127.0.0.1:4174', reuseExistingServer: false, timeout: 60_000 },
  projects: [
    { name: 'desktop', use: { ...devices['Desktop Chrome'], viewport: { width: 1440, height: 900 } } },
    { name: 'mobile', use: { ...devices['Pixel 7'] } },
  ],
});
