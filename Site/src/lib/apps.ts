import { getCollection, getEntry, type CollectionEntry } from 'astro:content';
import type { Locale } from '../i18n';

const icons = import.meta.glob<string>('../../../Design/icons/*.{svg,png}', { query: '?url', import: 'default', eager: true });

function icon(slug: string, ext: 'svg' | 'png'): string | undefined {
  return icons[`../../../Design/icons/sbu-${slug}.${ext}`];
}

export type App = Awaited<ReturnType<typeof getApps>>[number];

/** App content joined with its App Store listing, in display order. Apps without a filled listing are left out. */
export async function getApps() {
  const apps = await getCollection('apps');
  const joined = await Promise.all(
    apps.map(async (app) => {
      const listing = await getEntry('listings', app.data.app);
      const svg = icon(app.id, 'svg');
      if (!listing) return undefined;
      if (!svg) throw new Error(`Missing Design/icons/sbu-${app.id}.svg`);
      return {
        slug: app.id,
        ...app.data,
        listing: listing.data,
        icon: svg,
        iconPng: icon(app.id, 'png'),
        field: app.data.accent.replace(/^accent-/, 'field-'),
        storeUrl: app.data.status === 'live' && app.data.appStoreId ? `https://apps.apple.com/app/id${app.data.appStoreId}` : undefined,
      };
    }),
  );
  return joined.filter((app) => app !== undefined).sort((a, b) => a.order - b.order);
}

export function text(app: App, locale: Locale) {
  return app.listing[locale];
}

/** Alternative pages that can go live: not a draft, and their App Sbu is on the App Store. */
export async function getAlternatives(apps: App[]) {
  const live = new Map(apps.filter((app) => app.status === 'live').map((app) => [app.slug, app]));
  const showDrafts = process.env.SBU_DRAFTS === '1';
  return (await getCollection('alternatives'))
    .filter((entry) => showDrafts || (!entry.data.draft && live.has(entry.data.app)))
    .map((entry) => {
      const [locale, slug] = entry.id.split('/') as [Locale, string];
      const app = apps.find((candidate) => candidate.slug === entry.data.app);
      if (!app) throw new Error(`alternatives/${entry.id}: unknown app ${entry.data.app}`);
      return { entry, locale, slug, app };
    });
}

export type Alternative = Awaited<ReturnType<typeof getAlternatives>>[number];
export type Post = CollectionEntry<'blog'>;
