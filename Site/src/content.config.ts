import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';
import { loadListings } from './lib/listings';

const localized = <T extends z.ZodTypeAny>(schema: T) => z.object({ it: schema, en: schema });
const faq = z.array(z.object({ q: z.string(), a: z.string() }));

const listingText = z.object({
  name: z.string(),
  subtitle: z.string(),
  intro: z.array(z.string()),
  features: z.array(z.string()),
  oneThing: z.string(),
  keywords: z.array(z.string()),
});

/** App Store text, read from Apps/<App>/fastlane/metadata. Never repeated in apps/*.md. */
const listings = defineCollection({
  loader: async () => loadListings(),
  schema: z.object({ it: listingText, en: listingText }),
});

/** What the listing doesn't say: accent, store id, Originale, status, FAQ. File name = slug. */
const apps = defineCollection({
  loader: glob({ pattern: '*.md', base: './src/content/apps' }),
  schema: z.object({
    app: z.string().regex(/^Sbu[A-Z][A-Za-z]+$/),
    accent: z.string().regex(/^accent-[a-z]+$/),
    order: z.number(),
    status: z.enum(['building', 'live']),
    appStoreId: z.number().nullable(),
    /** schema.org applicationCategory, e.g. UtilitiesApplication. */
    category: z.string(),
    originale: z.object({ name: z.string(), appStoreId: z.number() }).optional(),
    figure: localized(z.object({ value: z.string(), label: z.string() })).optional(),
    permissions: localized(z.array(z.string())).default({ it: [], en: [] }),
    faq: localized(faq).default({ it: [], en: [] }),
    /** One line for an app with no listing yet: the home's "In arrivo" scene. Ignored once the listing exists. */
    teaser: localized(z.string()).optional(),
  }),
});

/** One page per Originale and locale: <locale>/<originale>.md. Built only when not a draft and the app is live. */
const alternatives = defineCollection({
  loader: glob({ pattern: '*/*.md', base: './src/content/alternatives' }),
  schema: z.object({
    app: z.string(),
    title: z.string(),
    description: z.string(),
    draft: z.boolean().default(true),
    /** Date the Originale facts were checked on its public App Store page. */
    checked: z.coerce.date(),
    facts: z.array(z.object({ label: z.string(), originale: z.string(), sbu: z.string() })),
    faq: faq.default([]),
  }),
});

const blog = defineCollection({
  loader: glob({ pattern: '*/*.md', base: './src/content/blog' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    date: z.coerce.date(),
    draft: z.boolean().default(false),
  }),
});

export const collections = { listings, apps, alternatives, blog };
