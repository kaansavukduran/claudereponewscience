import { defineConfig } from 'vitest/config';

// Unit tests only; Playwright specs under e2e/ run via `pnpm e2e`.
export default defineConfig({ test: { include: ['test/**/*.test.ts'] } });
