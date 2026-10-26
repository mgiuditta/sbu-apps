// https://llmstxt.org: what sbu.dev is, for AI search. Built from the same content as the pages.
import type { APIRoute } from 'astro';
import { localePath, statusLabel } from '../i18n';
import { getAlternatives, getApps, getPosts, text } from '../lib/apps';
import { DEVELOPER_URL, REPO_URL } from '../lib/pages';

export const GET: APIRoute = async ({ site }) => {
  const url = (path: string) => new URL(localePath('en', path), site).href;
  const apps = await getApps();
  const live = apps.filter((app) => app.status === 'live');
  const coming = apps.filter((app) => app.status !== 'live');
  const posts = (await getPosts()).filter((post) => post.id.startsWith('en/'));
  const line = (app: (typeof apps)[number]) => {
    const listing = text(app, 'en');
    const kind = app.category === 'GameApplication' ? ' Game.' : '';
    const originale = app.originale ? ` Free alternative to ${app.originale.name.replace(/\.$/, '')}.` : '';
    return `- [${listing.name}](${url(`apps/${app.slug}`)}): ${listing.subtitle}.${kind}${originale}`;
  };
  const alternatives = (await getAlternatives(apps)).filter((alternative) => alternative.locale === 'en');
  const lines = [
    '# sbu.dev',
    '',
    '> Free native iPhone apps that each do one thing. Each one remakes a top-paid App Store utility, free: no subscription, no in-app purchases, no account, no ads, no tracking, data only on the device. Open source. Made in Italy by Matteo Giuditta. Italian and English.',
    '',
    '## Apps on the App Store',
    '',
    ...live.map((app) => `${line(app)} App Store: ${app.storeUrl}`),
    '',
    ...(coming.length ? ['## Coming soon', '', ...coming.map((app) => `${line(app)} ${statusLabel(app, 'en')}.`), ''] : []),
    '## Games and software',
    '',
    `- [Games](${url('games')}): the most played iPhone games, remade with no ads and no in-app purchases`,
    `- [Software](${url('software')}): software companies pay for, remade open source and self-hosted`,
    '',
    '## Free tools in the browser',
    '',
    `- [Subscription cost](${url('abbonamenti')}): add up what your subscriptions cost in a year`,
    `- [QR code maker](${url('qr-code')}): a QR code for a link, text or Wi-Fi, free and never expiring`,
    '',
    ...(alternatives.length
      ? ['## Comparisons', '', ...alternatives.map(({ entry, slug }) => `- [${entry.data.title}](${url(`alternatives/${slug}`)}): ${entry.data.description}`), '']
      : []),
    ...(posts.length ? ['## Blog', '', ...posts.map((post) => `- [${post.data.title}](${url(`blog/${post.id.split('/')[1]}`)}): ${post.data.description}`), ''] : []),
    '## About',
    '',
    `- [Principles](${url('principi')}): the six promises every app keeps`,
    `- [Press](${url('stampa')}): facts and text free to use`,
    `- [Source code](${REPO_URL})`,
    `- [All apps on the App Store](${DEVELOPER_URL})`,
    '',
  ];
  return new Response(lines.join('\n'), { headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
};
