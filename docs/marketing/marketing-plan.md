# sbu.dev marketing plan (lean, zero budget)

Solo developer, 0 € spend, no analytics on the site, no email list. The only conversion is a tap on the App Store link. Measurement uses what needs no script: Google Search Console, Bing Webmaster Tools, and App Store Connect (downloads, product page views, web referrers, all aggregated by Apple).

## Bets

1. **One launch moment per App Sbu.** Every new app is a reason to post, update the site and publish its alternative page. Cadence follows the build cadence, not a calendar.
2. **Alternative pages + AlternativeTo listings** capture people already looking to leave a paid app.
3. **The Promesse are the story.** "Free, and the site has zero scripts too" is the hook for Reddit, Hacker News and Italian tech press.

## Ideas kept (from the marketing-ideas library)

| Stage | Idea (#) | How it applies |
|---|---|---|
| Acquisition | Easy keyword ranking (1), Programmatic SEO (4, small scale) | One alternative page and one app page per App Sbu, generated from content files |
| Acquisition | Comparison pages (11), Marketing jiu-jitsu (12) | "Alternativa gratuita a <Originale>", facts only |
| Acquisition | Product Hunt (78), alternatives directories (82) | AlternativeTo entry per App Sbu as alternative to its Originale; Product Hunt for the suite, not per app |
| Acquisition | Reddit research + participation (37, 38), comment marketing (44) | r/apple, r/iphone, r/apps and Italian tech subreddits; answer "free alternative to X" threads, no link spam |
| Acquisition | Press coverage (74), YouTube reviews (126) | Pitch Italian Apple blogs and YouTubers once three apps are live; a suite is a better story than one app |
| Acquisition | App Store Optimization (124) | Already in fastlane metadata; site and listing share the same text (single source) |
| Acquisition | Open source as marketing (123) | If the repo goes public (open question) |
| Activation | Customer language (139) | FAQs and copy reuse wording from 1-3 star reviews of the Originale |
| Retention | Powered-by (87) | "Parte di sbu.dev" footer in every app links to the site: each app cross-sells the suite |
| Retention | Changelogs (108), Support as marketing (135) | Release notes on the app page; answer every support mail |
| Referral | Content repurposing (5) | One blog post per launch, cut into a Reddit post and a short thread |

## Ideas dropped and why

- All paid ads (23-34), retargeting (33), pixel sharing (60): need budget and tracking.
- Email capture, newsletters, onboarding and win-back email (45-53): an email list is personal data and an account in disguise. RSS for the blog instead.
- Affiliates, referral rewards, giveaways, lifetime deals, early-access pricing, in-app upsells, price localization (62, 79-86, 91, 132, 137): nothing to sell or reward.
- Engagement pods, Cameo, OOH, stunts, events and webinars (43, 65-72, 118-120): no fit for a solo free-app suite.

## 90 days

| Weeks | Moves | Done when |
|---|---|---|
| 1-2 | Site live on Cloudflare Pages; Search Console + Bing verified (DNS record, no script); old sbu.dev repo archived | `sitemap-index.xml` submitted, `/privacy` resolves for App Review |
| 3-4 | Sbu Level and Sbu Habits live on the App Store: add `appStoreId`, flip status to `live`, publish both alternative pages; AlternativeTo entries | Two alternative pages indexed |
| 5-8 | Launch post "Perché sbu.dev" on the blog, Reddit and Show HN; reply to threads asking for free alternatives | First non-brand queries in Search Console |
| 9-12 | Third App Sbu: same launch loop; first press and YouTube pitches with three apps | Three app pages and three alternative pages live |

## Measures

- **North star:** App Store downloads per week (App Store Connect).
- **Leading:** Search Console impressions and clicks on `/alternatives/*` and `/apps/*`; App Store Connect "web referrer" for sbu.dev.
- **Guardrail:** zero third-party requests on the site (checked by the build output, no `<script src>` from other origins).
