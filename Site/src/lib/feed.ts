import rss from '@astrojs/rss';
import { localePath, ui, type Locale } from '../i18n';
import { getPosts } from './apps';

/** The blog's RSS feed for one locale: published posts, newest first, absolute URLs without a trailing slash. */
export async function blogFeed(locale: Locale, site: URL) {
  const t = ui[locale];
  const posts = (await getPosts()).filter((post) => post.id.startsWith(`${locale}/`));
  return rss({
    title: t.feedTitle,
    description: t.blogDescription,
    site: new URL(localePath(locale, 'blog'), site).href,
    trailingSlash: false,
    items: posts.map((post) => ({
      title: post.data.title,
      description: post.data.description,
      pubDate: post.data.date,
      link: new URL(localePath(locale, `blog/${post.id.split('/')[1]}`), site).href,
    })),
    customData: `<language>${locale}</language>`,
  });
}
