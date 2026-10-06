import type { CapacitorConfig } from '@capacitor/cli';

// Native Android/iOS shells wrap the same web build (dist/). Health data on native must move to a
// SQLite-backed DocumentStore + platform keystore before release (see docs/RELEASE_STATUS.md).
const config: CapacitorConfig = {
  appId: 'org.humanhealthos.app',
  appName: 'Human Health OS',
  webDir: 'dist',
  android: { allowMixedContent: false },
};

export default config;
