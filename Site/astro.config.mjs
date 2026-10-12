import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  site: 'https://sbu.dev',
  // https://sbu.dev/privacy is already in every app's fastlane metadata: no trailing slash.
  trailingSlash: 'never',
  build: { format: 'file' },
  i18n: {
    defaultLocale: 'it',
    locales: ['it', 'en'],
    routing: { prefixDefaultLocale: false },
  },
  integrations: [
    sitemap({
      i18n: { defaultLocale: 'it', locales: { it: 'it', en: 'en' } },
      filter: (page) => !page.endsWith('/404'),
    }),
  ],
  vite: {
    plugins: [tailwindcss()],
    // Icons, logo and font are read straight from ../Design, app text from ../Apps.
    server: { fs: { allow: ['..'] } },
    // Real files, never data: URIs, so icons and the mark have stable absolute URLs for JSON-LD and og:image.
    build: { assetsInlineLimit: 0 },
  },
});
