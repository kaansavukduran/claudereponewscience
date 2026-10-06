import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 30_000,
  reporter: [['list'], ['json', { outputFile: '../../reports/tests/client-e2e.json' }]],
  use: { baseURL: 'http://127.0.0.1:4175' },
  webServer: [
    { command: 'pnpm build && pnpm preview', url: 'http://127.0.0.1:4175', reuseExistingServer: false, timeout: 60_000 },
    { command: 'HHOS_ENV=test HHOS_DB_PATH=:memory: HHOS_API_PORT=8788 node --disable-warning=ExperimentalWarning ../../services/api/src/server.ts', url: 'http://127.0.0.1:8788/v1/health', reuseExistingServer: false, timeout: 30_000 },
  ],
  projects: [
    { name: 'mobile', use: { ...devices['Pixel 7'] } },
    { name: 'desktop', use: { ...devices['Desktop Chrome'], viewport: { width: 1280, height: 860 } } },
  ],
});
