# sbu.dev SEO checklist

Baseline: on 2026-10-12 `sbu.dev` did not resolve (no DNS answer), so there is nothing live to audit or redirect. This list is applied up front in `Site/`. `[x]` = done in the scaffold, `[ ]` = to do at or after launch.

## Crawl and index

- [x] Static HTML (Astro, no client JS): crawlable without rendering
- [x] `robots.txt` allows all and points to `/sitemap-index.xml`
- [x] Sitemap from `@astrojs/sitemap`, with `xhtml:link` alternates for it/en; drafts never built, so never listed
- [x] One canonical per page, self-referencing, absolute `https://sbu.dev/...`, no trailing slash (`trailingSlash: 'never'`, `build.format: 'file'`), so `https://sbu.dev/privacy` in the fastlane metadata is the canonical URL as written
- [x] Custom 404 page, not indexed
- [ ] Verify the domain in Search Console and Bing Webmaster Tools via DNS TXT (no verification script or meta tag), submit the sitemap
- [ ] Old public repo `mgiuditta/sbu.dev`: archive it so it can't publish a second copy of the domain

## International (it default, en)

- [x] Subdirectory locales: Italian at `/`, English at `/en/`; no Accept-Language or IP redirects
- [x] `<html lang="it">` / `<html lang="en">`
- [x] `hreflang` it, en and `x-default` (→ Italian) on every page, self-referencing and reciprocal; same slugs in both locales so the pair always exists
- [x] Main content translated, not only the chrome: app text comes from the it and en-US fastlane descriptions
- [ ] Decide whether to localize slugs (`/en/principles`); needs a slug map for hreflang

## On-page

- [x] Unique `<title>` (≤ 60 chars, brand last: "Sbu Level, livella e clinometro gratis · sbu.dev") and meta description (≤ 160) per page, from the App Store subtitle and Cosa sola
- [x] One `<h1>` per page, keyword first ("Alternativa gratuita a Streaks")
- [x] Descriptive URLs: `/apps/level`, `/alternatives/streaks`
- [x] Icons are SVG with `alt` text; no raster hero images
- [x] Internal links per `content-strategy.md`: home grid → apps; app ↔ alternative; footer → principi, support, privacy

## Structured data (JSON-LD, inline, no script loader)

- [x] Home: `Organization` + `WebSite` (name, url, logo, `inLanguage`)
- [x] App page: `MobileApplication` (name, operatingSystem "iOS 17+", applicationCategory, `offers` price 0 EUR, `downloadUrl` when live, `inLanguage`). No `aggregateRating`: we have none and never invent one, so Google may not show a rich result
- [x] App and alternative pages: `FAQPage` from the FAQ in front matter. Google shows FAQ rich results only for few sites since 2023, but Bing and AI answers still read it
- [x] `BreadcrumbList` on app and alternative pages
- [ ] Check each template once in the Rich Results Test after launch

## Social previews

- [x] `og:title`, `og:description`, `og:url`, `og:locale` + `og:locale:alternate`, `og:type`, `twitter:card`
- [ ] OG images (1200×630, `surface` field, app icon, Bricolage Grotesque title): generate at build with a script from `Design/icons` and `Design/fonts`. Not in the first scaffold; until then pages fall back to the app icon PNG where it exists

## Performance (Core Web Vitals)

- [x] Zero client JS, zero third-party requests (no analytics, no CDN fonts)
- [x] Two self-hosted fonts (Bricolage Grotesque variable for display, IBM Plex Mono Medium for the cartiglio, WOFF2 subsets) with `font-display: swap`; body text uses the system stack from tokens
- [x] Icon SVGs with explicit `width`/`height` (no CLS)
- [ ] Convert the font to WOFF2 subset when the site has real traffic (needs a tool not in the repo)
- [ ] PageSpeed Insights on home, one app page, one alternative page after launch: LCP < 2.5 s, CLS < 0.1, INP < 200 ms

## Security and hosting

- [x] HTTPS only (Coolify, Let's Encrypt); `Site/headers.inc` (nginx) with HSTS, `X-Content-Type-Options`, `Referrer-Policy: strict-origin-when-cross-origin`, a CSP that allows only self
- [ ] `www.sbu.dev` → `sbu.dev` 301 in Coolify (redirect setting on the resource)

## Alternative pages

- [x] Built only when `draft: false`, which you set when the App Sbu is live on the App Store
- [x] Facts only, from the public App Store listing, with the date checked; name used nominatively, no Originale logo or screenshot (ADR-0003)
- [x] Each links to its `/apps` page and back; listed in the home page app tile once published
