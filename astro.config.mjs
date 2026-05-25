import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://rodls.me',
  compressHTML: true,
  build: {
    inlineStylesheets: 'auto',
  },
});
