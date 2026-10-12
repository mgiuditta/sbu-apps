export const locales = ['it', 'en'] as const;
export type Locale = (typeof locales)[number];

/** Locale-neutral path ('' for home, 'apps/level') to the URL path of a locale. Italian sits at the root. */
export function localePath(locale: Locale, path: string): string {
  const prefix = locale === 'it' ? '' : `/${locale}`;
  return path ? `${prefix}/${path}` : prefix || '/';
}

export const ui = {
  it: {
    siteDescription: 'App gratuite per iPhone che fanno una cosa sola. Nessun abbonamento, nessun account, nessuna pubblicità.',
    nav: { apps: 'App', principles: 'Principi', support: 'Supporto', blog: 'Blog', privacy: 'Privacy', levelTool: 'Livella online', subscriptionCost: 'Quanto spendi in abbonamenti' },
    otherLocale: { label: 'English', lang: 'en' },
    skip: 'Vai al contenuto',
    navLabel: 'Principale',
    metaSuffix: 'Gratis, senza account e senza pubblicità. Per iPhone.',
    promisesLabel: 'Le promesse di ogni app',
    promises: ['Nessun abbonamento', 'Nessun acquisto in-app', 'Nessun account', 'Nessuna pubblicità', 'Nessun tracking', 'Dati solo sul dispositivo'],
    freeBadge: ['Nessun account', 'Nessuna pubblicità', 'Nessun acquisto in-app', 'Dati solo su questo iPhone'],
    comingSoon: 'In arrivo',
    appStore: 'Scarica dall’App Store',
    requires: 'Per iPhone con iOS 17 o successivo.',
    features: 'Cosa fa',
    faq: 'Domande',
    shotCaption: (name: string) => `Così appare in ${name}`,
    alternativeLink: (originale: string) => `Usavi ${originale}? Leggi il confronto.`,
    privacyLink: (name: string) => `Privacy di ${name}`,
    tryLevel: 'Prova la livella nel browser',
    backToApp: (name: string) => `Vai a ${name}`,
    checked: (date: string) => `Dati dell’App Store verificati il ${date}.`,
    footerNote: 'Questo sito non usa cookie né statistiche. I suoi script girano solo nel tuo browser e non inviano niente.',
    readPost: 'Leggi',
  },
  en: {
    siteDescription: 'Free iPhone apps that each do one thing. No subscription, no account, no ads.',
    nav: { apps: 'Apps', principles: 'Principles', support: 'Support', blog: 'Blog', privacy: 'Privacy', levelTool: 'Bubble level online', subscriptionCost: 'Subscription cost' },
    otherLocale: { label: 'Italiano', lang: 'it' },
    skip: 'Skip to content',
    navLabel: 'Main',
    metaSuffix: 'Free, no account, no ads. For iPhone.',
    promisesLabel: 'What every app promises',
    promises: ['No subscription', 'No in-app purchases', 'No account', 'No ads', 'No tracking', 'Data stays on your device'],
    freeBadge: ['No account', 'No ads', 'No in-app purchases', 'Data only on this iPhone'],
    comingSoon: 'Coming soon',
    appStore: 'Download on the App Store',
    requires: 'For iPhone with iOS 17 or later.',
    features: 'What it does',
    faq: 'Questions',
    shotCaption: (name: string) => `How it looks in ${name}`,
    alternativeLink: (originale: string) => `Used ${originale}? Read the comparison.`,
    privacyLink: (name: string) => `${name} privacy`,
    tryLevel: 'Try the level in your browser',
    backToApp: (name: string) => `Go to ${name}`,
    checked: (date: string) => `App Store facts checked on ${date}.`,
    footerNote: 'This site uses no cookies or analytics. Its scripts run only in your browser and send nothing.',
    readPost: 'Read',
  },
} as const;

export function formatDate(date: Date, locale: Locale): string {
  return new Intl.DateTimeFormat(locale, { dateStyle: 'long', timeZone: 'UTC' }).format(date);
}

export function capitalize(text: string): string {
  return text.charAt(0).toUpperCase() + text.slice(1);
}
