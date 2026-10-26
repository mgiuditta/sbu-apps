import { localePath, type Locale } from '../i18n';

/** The one Organization and its founder, declared on the home and referenced by @id everywhere else. */
export const ORG = { '@type': 'Organization', '@id': 'https://sbu.dev/#org', name: 'sbu.dev' };
export const FOUNDER = { '@type': 'Person', '@id': 'https://sbu.dev/#founder', name: 'Matteo Giuditta' };

export function breadcrumbs(site: URL, locale: Locale, items: [name: string, path: string][]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map(([name, path], index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name,
      item: new URL(localePath(locale, path), site).href,
    })),
  };
}

export function faqPage(faq: { q: string; a: string }[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faq.map(({ q, a }) => ({ '@type': 'Question', name: q, acceptedAnswer: { '@type': 'Answer', text: a } })),
  };
}
