import { getCollection, type CollectionEntry } from 'astro:content';
import type { Locale } from '../i18n';

const icons = import.meta.glob<string>('../../../Design/icons/*.png', { query: '?url', import: 'default', eager: true });

function icon(slug: string): string | undefined {
  return icons[`../../../Design/icons/sbu-${slug}.png`];
}

export type App = Awaited<ReturnType<typeof getApps>>[number];

/** App content joined with its App Store listing, in display order. Apps without a filled listing are left out. */
export async function getApps() {
  const apps = await getCollection('apps');
  // Looked up in the collection, not with getEntry: apps still being built have no listing, by design.
  const listings = new Map((await getCollection('listings')).map((listing) => [listing.id, listing]));
  const joined = await Promise.all(
    apps.map(async (app) => {
      const listing = listings.get(app.data.app);
      const png = icon(app.id);
      if (!listing) return undefined;
      if (!png) throw new Error(`Missing Design/icons/sbu-${app.id}.png`);
      return {
        slug: app.id,
        ...app.data,
        listing: listing.data,
        icon: png,
        storeUrl: app.data.status === 'live' && app.data.appStoreId ? `https://apps.apple.com/app/id${app.data.appStoreId}` : undefined,
      };
    }),
  );
  return joined.filter((app) => app !== undefined).sort((a, b) => a.order - b.order);
}

/** Apps with a content file but no listing yet: name and one line, for the home. No page of their own. */
export async function getUpcoming() {
  const apps = await getCollection('apps');
  const listed = new Set((await getCollection('listings')).map((listing) => listing.id));
  return apps
    .filter((app) => !listed.has(app.data.app))
    .map((app) => {
      const png = icon(app.id);
      if (!png) throw new Error(`Missing Design/icons/sbu-${app.id}.png`);
      if (!app.data.teaser) throw new Error(`apps/${app.id}: an app without a listing needs a teaser`);
      return {
        slug: app.id,
        accent: app.data.accent,
        order: app.data.order,
        // SbuNoise -> Sbu Noise: the listing is where the real name will come from.
        name: app.data.app.replace(/^Sbu/, 'Sbu '),
        teaser: app.data.teaser,
        icon: png,
      };
    })
    .sort((a, b) => a.order - b.order);
}

export type UpcomingApp = Awaited<ReturnType<typeof getUpcoming>>[number];

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
