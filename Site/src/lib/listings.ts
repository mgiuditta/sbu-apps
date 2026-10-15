// Reads each app's App Store listing from Apps/<App>/fastlane/metadata, the one source of app text.
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

const APPS = resolve(process.cwd(), '..', 'Apps');
const FOLDERS = { it: 'it', en: 'en-US' } as const;
const PROMISES = {
  it: 'Nessun abbonamento.\nNessun acquisto in-app.\nNessun account.\nNessuna pubblicità.\nNessun tracking.\nDati solo sul dispositivo.',
  en: 'No subscription.\nNo in-app purchases.\nNo account.\nNo ads.\nNo tracking.\nData stays on your device.',
};
const ONE_THING = { it: /^Sbu fa una cosa sola: (.+?)\.?$/, en: /^Sbu does one thing: (?:it )?(.+?)\.?$/ };

export interface ListingText {
  name: string;
  subtitle: string;
  intro: string[];
  features: string[];
  /** The Cosa sola, lowercase and without the subject: "ti dice se una cosa è dritta". */
  oneThing: string;
  keywords: string[];
}

function read(dir: string, file: string): string {
  return readFileSync(join(dir, `${file}.txt`), 'utf8').trim();
}

function text(app: string, locale: keyof typeof FOLDERS): ListingText {
  const dir = join(APPS, app, 'fastlane', 'metadata', FOLDERS[locale]);
  const blocks = read(dir, 'description').split(/\n\s*\n/);
  // The promise block opens the description or, since the 1.1 listings, closes it; one line per promise or one line.
  const flat = (s: string) => s.replace(/\s+/g, ' ').trim();
  const at = [0, blocks.length - 1].find((i) => flat(blocks[i]) === flat(PROMISES[locale]));
  if (at === undefined) {
    throw new Error(`${app} ${locale}: the description must start or end with the fixed promise block`);
  }
  blocks.splice(at, 1);
  const last = blocks.pop() ?? '';
  const oneThing = last.match(ONE_THING[locale])?.[1];
  if (!oneThing) throw new Error(`${app} ${locale}: the description must end with the Sbu one-thing line`);
  return {
    name: read(dir, 'name'),
    subtitle: read(dir, 'subtitle'),
    intro: blocks.filter((block) => !block.startsWith('- ')),
    features: blocks.flatMap((block) => block.split('\n')).filter((line) => line.startsWith('- ')).map((line) => line.slice(2)),
    oneThing,
    keywords: read(dir, 'keywords').split(','),
  };
}

/** One entry per app whose listing is filled in; apps still holding new_app.sh placeholders are skipped. */
export function loadListings() {
  return readdirSync(APPS)
    .filter((app) => existsSync(join(APPS, app, 'fastlane', 'metadata')))
    .filter((app) => {
      const dir = join(APPS, app, 'fastlane', 'metadata');
      return !Object.values(FOLDERS).some((folder) =>
        readdirSync(join(dir, folder)).some((file) => readFileSync(join(dir, folder, file), 'utf8').includes('__')),
      );
    })
    .map((app) => ({ id: app, it: text(app, 'it'), en: text(app, 'en') }));
}
