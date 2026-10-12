# sbu.dev content strategy

Inputs: README, CONTEXT.md, the two live specs (`research/286215117`, `research/963034692`), the fastlane metadata of Sbu Level and Sbu Habits. No keyword tool data yet: every keyword below is a hypothesis to check in Search Console after launch.

## Positioning (product-marketing context, short form)

- **One-liner (it):** App per iPhone gratuite che fanno una cosa sola. **(en):** Free iPhone apps that each do one thing.
- **Shelf:** "free alternative to <Originale>" and "<task> app" (livella, abitudini), not "privacy app".
- **Business model:** none. Free, no IAP, no ads, no tracking. The site sells nothing; its job is to send people to the App Store.
- **Who:** iPhone users who search for a single utility, find a paid or subscription app at the top, and want the same thing without paying or signing up. Italian first, English second.
- **Push:** the Originale costs money up front (Clinometer 1,99 €, Streaks 6,99 €) or upsells extras; many competitors in the same niche are subscriptions. **Pull:** the six Promesse, same core job. **Anxiety:** "free means ads or data selling". **Habit:** the app they already paid for.
- **Proof we can show honestly:** the Promesse, the App Store privacy label ("Data Not Collected"), the fact that the site itself has no scripts. No testimonials, ratings, stars or download counts (they look like a paywall pitch and we have none yet).
- **Voice:** CLAUDE.md rules. Second person singular, short sentences, no emoji, no exclamation marks. Words to avoid: "premium", "pro", "unlock", "tracking invasivo", "best".

Note on wording: the first two Originali are paid up front, not subscriptions. Copy says "gratis" and "senza abbonamento" (true of the Sbu side) but never claims the Originale is a subscription unless it is.

## Pillars

| # | Pillar | Searchable / shareable | Buyer stage | Why |
|---|---|---|---|---|
| 1 | **Alternative gratuite**: one page per Originale ("Alternativa gratuita a Streaks") | Searchable | Consideration, decision | Highest intent. People search "<Originale> alternative" and "<Originale> free". One page per App Sbu, mapped 1:1 by ADR-0004. |
| 2 | **La cosa sola**: one page per App Sbu plus how-to answers around its task ("come usare l'iPhone come livella", "come non perdere la serie se salti un giorno") | Searchable | Awareness, implementation | Captures task searches that never name the Originale. FAQs come from 1-3 star reviews of the Originale (user pains in each spec). |
| 3 | **Le Promesse**: what each promise means and how to check it on any app (privacy label, IAP list) | Both | Awareness | Builds trust in "free"; linkable from Reddit and press. Lives in `/principi`. |
| 4 | **Come lavora Sbu**: build notes, how an Originale is picked from public top-paid charts, why one thing only | Shareable | None (brand) | Fuel for Hacker News, Reddit, Indie Hackers, Italian tech press. Lives in `/blog`. |

## Page inventory

Italian is the default locale at the root, English under `/en/`. Slugs are shared across locales so every page has exactly one counterpart (simple hreflang).

| Path | Purpose | Pillar | Ships |
|---|---|---|---|
| `/` | Promesse, app grid, "Sbu fa una cosa sola" | all | now |
| `/apps/<slug>` | One App Sbu: Cosa sola, features, FAQ, App Store link, Originale link | 2 | now (status `building` shows "In arrivo", no store link) |
| `/alternatives/<originale>` | "Alternativa gratuita a <Originale>": what both do, what differs, FAQ | 1 | only when the App Sbu is live (`draft: true` until then) |
| `/principi` | The six Promesse explained, plus "one thing" and "no Concorrenti" | 3 | now |
| `/support` | FAQ common to all apps, contact | 2 | now |
| `/privacy` | Privacy policy for all apps (URL already in fastlane metadata) | 3 | now |
| `/privacy/<slug>` | Per-app privacy, same policy plus app permissions | 3 | now |
| `/blog/<post>` | Pillar 4 posts | 4 | first post now |

## Topic clusters and internal links

```
/ (hub)
├── /apps/level ──────────── /alternatives/clinometer   (both link to each other)
│     how-to FAQs: livella iPhone, clinometro, calibrazione
├── /apps/habits ─────────── /alternatives/streaks
│     how-to FAQs: serie, saltare un giorno, widget abitudini
├── /principi  <── linked from every page footer and every promise chip
└── /blog      ──> links into the /apps page of the app it talks about
```

Rules: every `/apps` page links its alternative page (when published) and `/principi`; every alternative page links back to its `/apps` page and to two other live App Sbu pages; the home grid links every app. No orphan pages: the sitemap and the home grid are generated from the same collection.

## Priority topics (first 90 days)

| Topic | Keyword hypothesis (it / en) | Type | Stage |
|---|---|---|---|
| Alternativa gratuita a Streaks | alternativa streaks, streaks gratis / streaks alternative free | Comparison page | Decision |
| Alternativa gratuita a Clinometer | clinometer gratis / free clinometer app | Comparison page | Decision |
| Sbu Habits page | app abitudini senza abbonamento / habit tracker no subscription | App page + FAQ | Consideration |
| Sbu Level page | livella iPhone gratis / bubble level app free | App page + FAQ | Consideration |
| Principi | app senza tracking / apps without tracking | Explainer | Awareness |
| "Perché sbu.dev" | n/a | Blog, launch post | Brand |

Comparison pages state only facts from the public App Store listing (price, IAP, privacy label), dated, with no Originale logo or screenshot (ADR-0003). Nominative use of the name only.
