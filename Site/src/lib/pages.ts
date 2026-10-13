import type { Locale } from '../i18n';

interface Section {
  heading?: string;
  paragraphs?: string[];
  list?: string[];
}

interface TextPage {
  title: string;
  description: string;
  sections: Section[];
  faq?: { q: string; a: string }[];
}

/** Support address, not decided yet: the contact paragraph appears only once it is set. */
export const SUPPORT_EMAIL: string | undefined = 'matteogiuditta@gmail.com';

const principles: Record<Locale, TextPage> = {
  it: {
    title: 'Principi',
    description: 'Le sei promesse di ogni app Sbu, e perché ogni app fa una cosa sola.',
    sections: [
      {
        paragraphs: ['Ogni app Sbu rispetta sei promesse. Se un’app ne viola una, non esce.'],
        list: ['Nessun abbonamento.', 'Nessun acquisto in-app.', 'Nessun account.', 'Nessuna pubblicità.', 'Nessun tracking.', 'Dati solo sul dispositivo.'],
      },
      {
        heading: 'Una cosa sola',
        paragraphs: [
          'Ogni app fa un solo lavoro, e lo fa per intero. Se un’app sembra aver bisogno di una seconda funzione grande, è il segnale che sta facendo troppo.',
        ],
      },
      {
        heading: 'Come lo verifichi',
        paragraphs: [
          'Nella scheda App Store di ogni app Sbu, la sezione Privacy dell’app riporta i dati raccolti, e non ci sono acquisti in-app. Le app non si collegano a nessun server: funzionano anche in modalità aereo.',
        ],
      },
      {
        heading: 'Come nasce un’app',
        paragraphs: [
          'Sbu sceglie un lavoro semplice che l’iPhone sa già fare, come misurare una pendenza o contare i giorni di fila, e ci costruisce un’app gratuita. Il codice e la grafica sono scritti da zero.',
        ],
      },
    ],
  },
  en: {
    title: 'Principles',
    description: 'The six promises every Sbu app keeps, and why each app does one thing.',
    sections: [
      {
        paragraphs: ['Every Sbu app keeps six promises. If an app breaks one, it does not ship.'],
        list: ['No subscription.', 'No in-app purchases.', 'No account.', 'No ads.', 'No tracking.', 'Data stays on your device.'],
      },
      {
        heading: 'One thing',
        paragraphs: [
          'Each app does one job, and does all of it. If an app seems to need a second big feature, it is doing too much.',
        ],
      },
      {
        heading: 'How to check',
        paragraphs: [
          'On the App Store page of every Sbu app, the App Privacy section lists the data collected, and there are no in-app purchases. The apps connect to no server: they work in airplane mode too.',
        ],
      },
      {
        heading: 'How an app is made',
        paragraphs: [
          'Sbu picks a simple job your iPhone can already do, like measuring a slope or counting days in a row, and builds a free app for it. The code and the design are written from scratch.',
        ],
      },
    ],
  },
};

const support: Record<Locale, TextPage> = {
  it: {
    title: 'Supporto',
    description: 'Risposte alle domande comuni sulle app Sbu.',
    sections: SUPPORT_EMAIL ? [{ paragraphs: [`Per un problema o un’idea, scrivi a ${SUPPORT_EMAIL}.`] }] : [],
    faq: [
      { q: 'Le app sono davvero gratis?', a: 'Sì. Niente abbonamento, niente acquisti in-app, niente pubblicità.' },
      { q: 'Serve un account?', a: 'No. Apri l’app e la usi.' },
      { q: 'Dove sono i miei dati?', a: 'Solo sul tuo iPhone, nel backup che fai già. Se elimini l’app, i dati vengono eliminati con lei.' },
      { q: 'Su quali iPhone funzionano?', a: 'Su iPhone con iOS 17 o successivo.' },
    ],
  },
  en: {
    title: 'Support',
    description: 'Answers to common questions about Sbu apps.',
    sections: SUPPORT_EMAIL ? [{ paragraphs: [`For a problem or an idea, write to ${SUPPORT_EMAIL}.`] }] : [],
    faq: [
      { q: 'Are the apps really free?', a: 'Yes. No subscription, no in-app purchases, no ads.' },
      { q: 'Do I need an account?', a: 'No. Open the app and use it.' },
      { q: 'Where is my data?', a: 'Only on your iPhone, in the backup you already make. If you delete the app, its data goes with it.' },
      { q: 'Which iPhones do they run on?', a: 'iPhone with iOS 17 or later.' },
    ],
  },
};

/**
 * @param connections For one app that may reach the user's own iCloud or devices: the end of the
 * first sentence, in place of "and it connects to no server.".
 */
function privacy(locale: Locale, app?: string, permissions: string[] = [], connections?: string): TextPage {
  const it = locale === 'it';
  const subject = app ?? (it ? 'Le app Sbu' : 'Sbu apps');
  const servers = connections ?? (it ? 'e non si collegano a nessun server.' : 'and they connect to no server.');
  const sections: Section[] = [
    {
      paragraphs: it
        ? [
            `${subject} non raccolgono e non inviano dati personali. Non hanno account, statistiche, pubblicità o strumenti di tracciamento, ${servers}`,
            'Quello che inserisci resta sul tuo iPhone e nei backup che fai tu, su iCloud o sul computer.',
          ]
        : [
            `${subject} collect and send no personal data. There are no accounts, analytics, ads or tracking tools, ${servers}`,
            'What you enter stays on your iPhone and in the backups you make, on iCloud or on your computer.',
          ],
    },
  ];
  if (permissions.length) {
    sections.push({ heading: it ? 'Permessi' : 'Permissions', list: permissions });
  }
  sections.push({
    heading: it ? 'Questo sito' : 'This site',
    paragraphs: [
      it
        ? 'sbu.dev non usa cookie né statistiche. I suoi script aprono il menu sul telefono e fanno i calcoli degli strumenti, come la livella: girano nel tuo browser e non inviano niente. Il server che lo ospita riceve il tuo indirizzo IP per consegnarti le pagine, come ogni server web.'
        : 'sbu.dev uses no cookies or analytics. Its scripts open the menu on your phone and run the tools, like the level: they run in your browser and send nothing. The server that hosts it receives your IP address to deliver the pages, like any web server.',
    ],
  });
  if (app) {
    // Singular subject for one app.
    sections[0].paragraphs = sections[0].paragraphs!.map((p) =>
      it ? p.replace('non raccolgono e non inviano', 'non raccoglie e non invia').replace('Non hanno', 'Non ha').replace('non si collegano', 'non si collega')
         : p.replace('collect and send', 'collects and sends').replace('There are no', 'It has no').replace('and they connect', 'and it connects'),
    );
  }
  return {
    title: app ? `${it ? 'Privacy di' : 'Privacy:'} ${app}` : 'Privacy',
    description: connections
      ? it ? `${subject}: nessun dato raccolto, niente passa da sbu.dev.` : `${subject}: no data collected, nothing goes through sbu.dev.`
      : it ? `${subject}: nessun dato raccolto, tutto resta sul tuo iPhone.` : `${subject}: no data collected, everything stays on your iPhone.`,
    sections,
  };
}

export const pages = {
  principles: (locale: Locale) => principles[locale],
  support: (locale: Locale) => support[locale],
  privacy: (locale: Locale) => privacy(locale),
  appPrivacy: (locale: Locale, app?: string, permissions: string[] = [], connections?: string) => privacy(locale, app, permissions, connections),
};
