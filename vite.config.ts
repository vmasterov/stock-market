/// <reference types="vitest/config" />

import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { playwright } from '@vitest/browser-playwright';
import tsconfigPath from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [react(), tsconfigPath()],
  server: {
    port: 3000,
  },
  test: {
    browser: {
      provider: playwright(),
      enabled: true,
      instances: [{ browser: 'chromium' }],
    },
  },
});
