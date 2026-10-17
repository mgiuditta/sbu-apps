export const locales = ['it', 'en'] as const;
export type Locale = (typeof locales)[number];

/** Locale-neutral path ('' for home, 'apps/habits') to the URL path of a locale. Italian sits at the root. */
export function localePath(locale: Locale, path: string): string {
  const prefix = locale === 'it' ? '' : `/${locale}`;
  return path ? `${prefix}/${path}` : prefix || '/';
}

export const ui = {
  it: {
    siteDescription: 'App gratuite per iPhone che fanno una cosa sola. Nessun abbonamento, nessun account, nessuna pubblicità.',
    nav: { apps: 'App', principles: 'Principi', support: 'Supporto', blog: 'Blog', privacy: 'Privacy', subscriptionCost: 'Quanto spendi in abbonamenti', qrCode: 'Crea un codice QR', alternatives: 'Alternative gratis', press: 'Stampa' },
    otherLocale: { label: 'English', lang: 'en' },
    skip: 'Vai al contenuto',
    navLabel: 'Principale',
    menu: 'Menu',
    close: 'Chiudi',
    metaSuffix: 'Gratis, senza account e senza pubblicità. Per iPhone.',
    promises: ['Nessun abbonamento', 'Nessun acquisto in-app', 'Nessun account', 'Nessuna pubblicità', 'Nessun tracking', 'Dati solo sul dispositivo'],
    /** The app page's "non fa" list: the six promises, said of the app. */
    doesNot: 'Cosa non fa',
    doesNotList: ['Non chiede un abbonamento', 'Non vende acquisti in-app', 'Non ti chiede un account', 'Non mostra pubblicità', 'Non ti traccia', 'Non manda i tuoi dati a sbu.dev'],
    /** The app page's cartiglio: "SBU / 01 / HABITS · sostituisce Streaks · 6,99 € una tantum → 0 €". */
    replaces: (name: string) => `sostituisce ${name}`,
    oneTime: (price: string) => `${price} una tantum`,
    withSbu: 'con Sbu',
    /** The app's fixed catalogue number, its `order`: the same on the plate, the home and its page. */
    number: (n: number) => `N° ${String(n).padStart(2, '0')}`,
    appStore: 'Scarica dall’App Store',
    requires: 'Per iPhone con iOS 17 o successivo.',
    features: 'Cosa fa',
    faq: 'Domande',
    shotCaption: (name: string) => `Così appare in ${name}`,
    alternativeLink: (originale: string) => `Usavi ${originale}? Leggi il confronto.`,
    privacyLink: (name: string) => `Privacy di ${name}`,
    backToApp: (name: string) => `Vai a ${name}`,
    checked: (date: string) => `Dati dell’App Store verificati il ${date}.`,
    footerNote: 'Questo sito non usa cookie né statistiche. I suoi script girano solo nel tuo browser e non inviano niente.',
    readPost: 'Leggi',
    feed: 'Segui il blog con il feed RSS',
    feedTitle: 'Blog di sbu.dev',
    blogDescription: 'Come nascono le app Sbu.',
    code: 'Codice su GitHub',
    codeOf: (name: string) => `Leggi il codice di ${name}`,
    footerTools: 'Strumenti gratuiti',
    footerSite: 'Sbu',
    insteadOf: 'Invece di',
    /** Where the Originale's price comes from, on the home and the app page. */
    priceSource: (date: string) => `Prezzo una tantum sull’App Store italiano, verificato il ${date}.`,
  },
  en: {
    siteDescription: 'Free iPhone apps that each do one thing. No subscription, no account, no ads.',
    nav: { apps: 'Apps', principles: 'Principles', support: 'Support', blog: 'Blog', privacy: 'Privacy', subscriptionCost: 'Subscription cost', qrCode: 'QR code maker', alternatives: 'Free alternatives', press: 'Press' },
    otherLocale: { label: 'Italiano', lang: 'it' },
    skip: 'Skip to content',
    navLabel: 'Main',
    menu: 'Menu',
    close: 'Close',
    metaSuffix: 'Free, no account, no ads. For iPhone.',
    promises: ['No subscription', 'No in-app purchases', 'No account', 'No ads', 'No tracking', 'Data stays on your device'],
    doesNot: 'What it does not do',
    doesNotList: ['Asks for no subscription', 'Sells no in-app purchases', 'Needs no account', 'Shows no ads', 'Does not track you', 'Sends none of your data to sbu.dev'],
    replaces: (name: string) => `replaces ${name}`,
    oneTime: (price: string) => `${price} one-time`,
    withSbu: 'with Sbu',
    number: (n: number) => `No. ${String(n).padStart(2, '0')}`,
    appStore: 'Download on the App Store',
    requires: 'For iPhone with iOS 17 or later.',
    features: 'What it does',
    faq: 'Questions',
    shotCaption: (name: string) => `How it looks in ${name}`,
    alternativeLink: (originale: string) => `Used ${originale}? Read the comparison.`,
    privacyLink: (name: string) => `${name} privacy`,
    backToApp: (name: string) => `Go to ${name}`,
    checked: (date: string) => `App Store facts checked on ${date}.`,
    footerNote: 'This site uses no cookies or analytics. Its scripts run only in your browser and send nothing.',
    readPost: 'Read',
    feed: 'Follow the blog with the RSS feed',
    feedTitle: 'sbu.dev blog',
    blogDescription: 'How Sbu apps are made.',
    code: 'Code on GitHub',
    codeOf: (name: string) => `Read the code of ${name}`,
    footerTools: 'Free tools',
    footerSite: 'Sbu',
    insteadOf: 'Instead of',
    priceSource: (date: string) => `One-time price on the Italian App Store, checked on ${date}.`,
  },
} as const;

const statusWords = {
  it: { planned: 'Pianificata', development: 'In sviluppo', testflight: 'In TestFlight', review: 'In revisione', live: 'Pubblicata il' },
  en: { planned: 'Planned', development: 'In development', testflight: 'On TestFlight', review: 'In review', live: 'Published on' },
} as const;

/** The app's state in words, the same everywhere on the site: "In sviluppo", "Pubblicata il 15 giugno 2026". */
export function statusLabel(app: { status: keyof (typeof statusWords)['it']; published?: Date }, locale: Locale): string {
  const word = statusWords[locale][app.status];
  return app.status === 'live' && app.published ? `${word} ${formatDate(app.published, locale)}` : word;
}

export function formatDate(date: Date, locale: Locale): string {
  return new Intl.DateTimeFormat(locale, { dateStyle: 'long', timeZone: 'UTC' }).format(date);
}

/** A price in euros as the App Store writes it in that locale: "1,99 €", "€1.99"; whole amounts without cents. */
export function formatPrice(value: number, locale: Locale): string {
  const digits = Number.isInteger(value) ? 0 : 2;
  return new Intl.NumberFormat(locale === 'it' ? 'it-IT' : 'en-IE', {
    style: 'currency',
    currency: 'EUR',
    minimumFractionDigits: digits,
    maximumFractionDigits: digits,
  }).format(value);
}

export function capitalize(text: string): string {
  return text.charAt(0).toUpperCase() + text.slice(1);
}
