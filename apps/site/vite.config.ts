import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// Static, relative-path build: deployable to any static host or published as a Site artifact.
export default defineConfig({
  base: './',
  plugins: [react()],
  server: { port: 5173, fs: { allow: ['../..'] } },
  build: { outDir: 'dist', sourcemap: false, target: 'es2022' },
});
