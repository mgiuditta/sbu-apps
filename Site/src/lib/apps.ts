import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import type { ImageMetadata } from 'astro';
import { getImage } from 'astro:assets';
import { getCollection, type CollectionEntry } from 'astro:content';
import { ui, type Locale } from '../i18n';

const icons = import.meta.glob<string>('../../../Design/icons/*.png', { query: '?url', import: 'default', eager: true });
// The engraving alone, as an alpha ink mask: the app page draws it in `ink`, so it follows the theme.
const specs: Record<string, { name?: Record<Locale, string> }> = JSON.parse(readFileSync(resolve(process.cwd(), '..', 'Design', 'icons', 'engravings.json'), 'utf8'));
const engravings = import.meta.glob<ImageMetadata>('../../../Design/icons/source/*.png', { import: 'default', eager: true });

/** The ink mask as a small WebP: the 1024px originals weigh up to 950 kB. WebP keeps the alpha the mask reads. */
async function engraving(slug: string, width: number): Promise<string | undefined> {
  const source = engravings[`../../../Design/icons/source/sbu-${slug}.png`];
  return source ? (await getImage({ src: source, width, format: 'webp' })).src : undefined;
}

const iconImages = import.meta.glob<ImageMetadata>('../../../Design/icons/*.png', { import: 'default', eager: true });

/** The app icon at 48pt for lists (2x), as WebP. The full PNG stays the download. */
export async function iconThumb(slug: string): Promise<string> {
  return (await getImage({ src: iconImages[`../../../Design/icons/sbu-${slug}.png`], width: 96, format: 'webp' })).src;
}

/** Every engraving of an app on the site, in one size with its caption, for pages that pick one (the plate). */
export async function allEngravings(width: number, locale: Locale): Promise<{ src: string; caption?: string }[]> {
  const order = new Map((await getCollection('apps')).map((app) => [app.id, app.data.order]));
  // Only apps on the site: an engraving whose app has no content file stays off the plates.
  const entries = Object.entries(engravings).filter(([path]) => order.has(path.match(/sbu-(.+)\.png$/)![1]));
  return Promise.all(entries.map(async ([path, src]) => {
    const slug = path.match(/sbu-(.+)\.png$/)![1];
    return { src: (await getImage({ src, width, format: 'webp' })).src, caption: plateCaption(slug, order.get(slug), locale) };
  }));
}

/** The plate's caption: the app's number, then the instrument's name from Design/icons/engravings.json. */
export function plateCaption(slug: string, order: number | undefined, locale: Locale): string | undefined {
  const name = specs[slug]?.name?.[locale];
  return name && (order === undefined ? name : `${ui[locale].number(order)} · ${name}`);
}

const RESEARCH = resolve(process.cwd(), '..', 'research');

/** The Originale's price in the content file must match the public listing saved by Tools/discover.py. */
/** App Store Connect provider token for campaign links: public, the same for every app. */
const PROVIDER_TOKEN = 128487151;

function checkPrice(slug: string, originale: { appStoreId: number; price?: number }) {
  const meta = resolve(RESEARCH, String(originale.appStoreId), 'meta.json');
  if (originale.price === undefined || !existsSync(meta)) return;
  const listed = JSON.parse(readFileSync(meta, 'utf8')) as { price?: number; currency?: string };
  if (listed.currency === 'EUR' && listed.price !== originale.price) {
    throw new Error(`apps/${slug}: originale.price ${originale.price} but research/${originale.appStoreId}/meta.json says ${listed.price}`);
  }
}

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
      if (app.data.originale) checkPrice(app.id, app.data.originale);
      if (app.data.status === 'live' && !app.data.published) throw new Error(`apps/${app.id}: a live app needs published`);
      return {
        slug: app.id,
        ...app.data,
        listing: listing.data,
        icon: png,
        engraving: await engraving(app.id, 800),
        /** The same engraving small, for lists. */
        mark: await engraving(app.id, 192),
        storeUrl: app.data.status === 'live' && app.data.appStoreId ? `https://apps.apple.com/app/id${app.data.appStoreId}` : undefined,
        /** The badge's link: App Analytics counts installs per page (ct), no tracking of the person (#573). */
        campaignUrl: app.data.status === 'live' && app.data.appStoreId ? `https://apps.apple.com/app/apple-store/id${app.data.appStoreId}?pt=${PROVIDER_TOKEN}&ct=site-${app.id}&mt=8` : undefined,
      };
    }),
  );
  return joined.filter((app) => app !== undefined).sort((a, b) => a.order - b.order);
}

/** Apps with a content file but no listing yet: name and one line, for the home. No page of their own. */
export async function getUpcoming() {
  const apps = await getCollection('apps');
  const listed = new Set((await getCollection('listings')).map((listing) => listing.id));
  const upcoming = await Promise.all(apps
    .filter((app) => !listed.has(app.data.app))
    .map(async (app) => {
      const png = icon(app.id);
      if (!png) throw new Error(`Missing Design/icons/sbu-${app.id}.png`);
      if (!app.data.teaser) throw new Error(`apps/${app.id}: an app without a listing needs a teaser`);
      return {
        slug: app.id,
        accent: app.data.accent,
        order: app.data.order,
        status: app.data.status,
        published: app.data.published,
        // SbuNoise -> Sbu Noise: the listing is where the real name will come from.
        name: app.data.app.replace(/^Sbu/, 'Sbu '),
        teaser: app.data.teaser,
        icon: png,
        mark: await engraving(app.id, 192),
      };
    }));
  return upcoming.sort((a, b) => a.order - b.order);
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

/** Published posts, newest first: drafts are never built. */
export async function getPosts() {
  return (await getCollection('blog', (post) => !post.data.draft)).sort((a, b) => +b.data.date - +a.data.date);
}
