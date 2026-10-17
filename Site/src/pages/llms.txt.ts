// https://llmstxt.org: what sbu.dev is, for AI search. Built from the same content as the pages.
import type { APIRoute } from 'astro';
import { localePath } from '../i18n';
import { getAlternatives, getApps, text } from '../lib/apps';
import { DEVELOPER_URL, REPO_URL } from '../lib/pages';

export const GET: APIRoute = async ({ site }) => {
  const url = (path: string) => new URL(localePath('en', path), site).href;
  const apps = await getApps();
  const live = apps.filter((app) => app.status === 'live');
  const alternatives = (await getAlternatives(apps)).filter((alternative) => alternative.locale === 'en');
  const lines = [
    '# sbu.dev',
    '',
    '> Free native iPhone apps that each do one thing. Each one remakes a top-paid App Store utility, free: no subscription, no in-app purchases, no account, no ads, no tracking, data only on the device. Open source. Made in Italy by Matteo Giuditta. Italian and English.',
    '',
    '## Apps on the App Store',
    '',
    ...live.map((app) => {
      const listing = text(app, 'en');
      const originale = app.originale ? ` Free alternative to ${app.originale.name}.` : '';
      return `- [${listing.name}](${url(`apps/${app.slug}`)}): ${listing.subtitle}.${originale} App Store: ${app.storeUrl}`;
    }),
    '',
    ...(alternatives.length
      ? ['## Comparisons', '', ...alternatives.map(({ entry, slug }) => `- [${entry.data.title}](${url(`alternatives/${slug}`)}): ${entry.data.description}`), '']
      : []),
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
