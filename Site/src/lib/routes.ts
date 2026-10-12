import { getCollection } from 'astro:content';
import { locales, localePath, type Locale } from '../i18n';
import { getAlternatives, getApps, type Alternative, type App, type Post } from './apps';

type View =
  | { view: 'home' | 'principles' | 'support' | 'privacy' }
  | { view: 'app' | 'appPrivacy'; app: App }
  | { view: 'alternative'; alternative: Alternative }
  | { view: 'blog'; posts: Post[] }
  | { view: 'post'; post: Post };

export type Route = View & {
  /** Locale-neutral path, the same in every locale: '' or 'apps/level'. */
  path: string;
  locale: Locale;
  apps: App[];
  alternatives: Alternative[];
  /** Locales that have this page, for hreflang and the language switch. */
  alternates: Locale[];
};

/** Every page of the site, built from content. Same slug in every locale. */
export async function routes(): Promise<Route[]> {
  const apps = await getApps();
  const alternatives = await getAlternatives(apps);
  const posts = (await getCollection('blog', (post) => !post.data.draft)).sort((a, b) => +b.data.date - +a.data.date);

  const pages: (View & { path: string; locale: Locale })[] = [];
  for (const locale of locales) {
    const own = (post: Post) => post.id.startsWith(`${locale}/`);
    pages.push(
      { view: 'home', path: '', locale },
      { view: 'principles', path: 'principi', locale },
      { view: 'support', path: 'support', locale },
      { view: 'privacy', path: 'privacy', locale },
      ...apps.map((app) => ({ view: 'app' as const, app, path: `apps/${app.slug}`, locale })),
      ...apps.map((app) => ({ view: 'appPrivacy' as const, app, path: `privacy/${app.slug}`, locale })),
      { view: 'blog', posts: posts.filter(own), path: 'blog', locale },
      ...posts.filter(own).map((post) => ({ view: 'post' as const, post, path: `blog/${post.id.split('/')[1]}`, locale })),
    );
  }
  pages.push(
    ...alternatives.map((alternative) => ({
      view: 'alternative' as const,
      alternative,
      path: `alternatives/${alternative.slug}`,
      locale: alternative.locale,
    })),
  );

  return pages.map((page) => ({
    ...page,
    apps,
    alternatives,
    alternates: locales.filter((locale) => pages.some((other) => other.path === page.path && other.locale === locale)),
  }));
}

export function urlParam(route: Pick<Route, 'locale' | 'path'>): string | undefined {
  return localePath(route.locale, route.path).slice(1) || undefined;
}
