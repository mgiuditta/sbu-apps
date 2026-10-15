# Lancio di Sbu: la punta di lancia (15 ottobre 2026)

Sostituisce la sequenza e i canali di `docs/marketing/marketing-plan.md`. Restano validi i pilastri e l'inventario delle pagine di `docs/marketing/content-strategy.md`, le metriche senza script e la regola "zero richieste di terze parti sul sito".

La strategia in una riga: **un'app sola come punta di lancia, un numero scandaloso, una faccia, un loop settimanale ripetibile.** Le utility non diventano virali da sole. Diventano virali il numero (il paywall settimanale × 52) e la persona: Matteo Giuditta, studente di Sicurezza Informatica a Milano, che rifà le app a pagamento e le regala, con il codice aperto.

Ordine: Sbu Auth (punta di lancia), Sbu Clean (il "Sweep" del brief, secondo colpo), poi Steps e Docs (lo "Scan" del brief) con il loop. La suite si lancia solo dopo Auth e Clean pubblicate. Roadmap in `docs/factory.md`, rischi in `docs/priorita-2026-10.md`.

**Repo pubblica dal 15/10/2026:** https://github.com/mgiuditta/sbu-apps, licenza MIT, cronologia ripulita dai dati personali. Issue e PR di lavoro restano nella privata `mgiuditta/sbu-apps-private`. Le segnalazioni di sicurezza arrivano dalla "private vulnerability reporting" di GitHub.

## a. Il numero

Il dato da ripetere in ogni contenuto. Fonte: elenco "Acquisti in-app" della pagina pubblica dell'App Store (apps.apple.com, IT e US), letto il **15/10/2026**. L'API `itunes.apple.com/lookup` ha risposto per tutti gli ID ma non elenca gli acquisti in-app: i prezzi vengono dalla pagina dello Store, i numeri di valutazioni dal lookup.

| App (ID) | Cosa fa | Settimanale IT | Settimanale US | × 52 (IT) | Anche in elenco | Valutazioni US |
|---|---|---|---|---|---|---|
| Cleanup (1510944943) | pulizia foto | 5,95-**12,99 €** | $5.95-$11.99 | **675,48 €** | 1 anno 24,99 € | 737 mila |
| Authenticator ℠ App (6754900760) | codici 2FA | 6,99-**9,99 €** | $5.99-$14.90 | **519,48 €** | nessun annuale | 5,9 mila |
| Swipewipe (1583884012) | pulizia foto | fino a **9,99 €** | $3.99-$9.99 | **519,48 €** | 1 anno $29.99 | 97,5 mila |
| Heartica (6742904990) | battito cardiaco | 6,99-10,99 € (**7,99 €** il più comune) | $6.99-$9.99 | **415,48 €** | 1 anno 59,99 €, a vita 89,99 € | 16,7 mila |
| **Totale** | | | | **2.129,92 €/anno** | | |

La frase: **"Fino a oltre 2.000 € l'anno per quattro funzioni che iOS fa quasi gratis. Sbu: 0 €."**

Regole di onestà, perché su HN il primo commento le controlla:
- Sempre "fino a" e "prezzo di listino". Mai dire che tutti pagano il massimo.
- Se qualcuno cita il piano annuale (Cleanup 24,99 €, Swipewipe 29,99 $), si risponde con i fatti: esiste, è nascosto dietro la prova settimanale, e le recensioni 1-3★ parlano di addebiti settimanali (Cleanup: 42 su 69 sul paywall).
- Heartica non ha un'App Sbu corrispondente. Va bene come esempio del fenomeno, non nel post "4 app, 0 €" (vedi d).
- Prima di ogni contenuto con il numero: riaprire le quattro pagine, aggiornare data e prezzi qui. I prezzi cambiano per paese e per test A/B.

## b. La punta di lancia: Sbu Auth, 14 giorni

Asset pronti in `marketing/auth/`. Ogni contenuto chiude con **sbu.dev/apps/auth**, mai con il solo link all'App Store.

| Giorno | Azione | Asset | Fatto quando |
|---|---|---|---|
| -3 | Repo pubblica; `/apps/auth` e `/privacy/auth` pronte in build (vedi `docs/site-todo.md`); video montato | `video.md` | la build del sito passa con lo stato `live` |
| 0 | Release. Pagina `/apps/auth` live, `/privacy/auth`. Video 20 s caricato nativo su Reels, Shorts, TikTok. Post LinkedIn e X con lo screenshot del paywall e la riga sul marchio | `video.md`, `linkedin.md` (giorno 0) | link sbu.dev in bio e nel primo commento |
| 1 | **Show HN**, martedì-giovedì 15-17 ora italiana. Titolo con il numero, primo commento con metodo (dati pubblici, niente binari), privacy, repo, cosa non fa. Matteo risponde a tutto per 6 ore | `showhn.md` | link al thread in `marketing/log.md` |
| 1-3 | Reddit: un thread **reale** per sub, già esistente, in cui qualcuno chiede un'app 2FA o si lamenta di un abbonamento. Risposta da utente con uno screenshot vero. Mai post-link. Sub: r/privacy, r/iosapps, r/iphone, r/2fa, r/opensource (qui un post proprio solo se la regola lo permette) | `reddit.md` | un commento per sub, nessuna rimozione dei mod |
| 2 | `/alternatives/authenticator-app` pubblicata (solo fatti dello Store, datati, nessuna icona o screenshot dell'originale) | `docs/site-todo.md` | in sitemap |
| 4-7 | Mail di 8 righe a MacStories, 9to5Mac (EN), iPhoneItalia, Macitynet (IT). **Solo se** il thread HN o Reddit ha preso (front page HN, o 100+ upvote su Reddit): il link al thread va nella mail | `press.md` | 4 mail, una per testata, nessun follow-up prima di 5 giorni |
| 7 | Post "come l'ho fatta": ore, righe di codice, 0 €, cosa ha fatto Claude e cosa Matteo. Blog sbu.dev + LinkedIn + X | `linkedin.md` (giorno 7) | numeri veri da `git log` e `cloc` |
| 14 | Post-numero "una settimana dopo": download, stelle GitHub, cosa è andato storto | `linkedin.md` (giorno 14) | dati da App Store Connect e GitHub |
| se rifiutata | Post "Apple mi ha rifiutato": cosa dice la regola, cosa cambio. Il rifiuto è contenuto | `linkedin.md` (post-errore) | |

Obiettivo del lancio di Auth: **2.000 download in 14 giorni e 100 stelle GitHub**. Se il thread HN entra in front page: 5-10 mila download.

## c. Il loop ripetibile (Clean, Steps, Docs)

Lo stesso schema in checklist. Copiare la cartella `marketing/auth/` in `marketing/<slug>/` e riscrivere.

- [ ] Numero verificato oggi sulla pagina dello Store (settimanale × 52, "fino a"), scritto in `docs/lancio-sbu.md` sezione a
- [ ] Hook scelto (sotto) e 10 varianti in `hooks.md`
- [ ] Screenshot del paywall dell'originale, solo per social e video, con "X è un marchio del rispettivo proprietario; Sbu non è affiliata."
- [ ] Giorno 0: release, `/apps/<slug>`, `/privacy/<slug>`, video 20 s su Reels, Shorts, TikTok, post LinkedIn e X
- [ ] Giorno 1: Show HN con il numero nel titolo (un solo Show HN per app, mai due nella stessa settimana)
- [ ] Giorno 1-3: un thread Reddit reale per sub, risposta da utente con screenshot
- [ ] Giorno 2: `/alternatives/<originale>`
- [ ] Giorno 4-7: stampa solo se un thread ha preso
- [ ] Giorno 7: "come l'ho fatta"; giorno 14: "una settimana dopo"
- [ ] Ogni contenuto registrato in `marketing/log.md`

| App | Hook | Sub Reddit | Asset |
|---|---|---|---|
| Clean | Cleanup ti fa scegliere le foto per mezz'ora e poi chiede fino a 12,99 € a settimana per eliminarle. Sbu Clean le elimina gratis. | r/iphone, r/ios, r/DataHoarder, r/declutter | `marketing/clean/` (pronti) |
| Steps | Stompers smette di contare i tuoi passi alle 21 se non paghi 5,99 € a settimana. Sbu Steps conta tutta la giornata, gratis. | r/walking, r/AppleWatch, r/fitness | da scrivere |
| Docs | Scansionare un foglio non dovrebbe costare 50 $ l'anno e una filigrana. | r/productivity, r/GoodNotes, r/paperless | da scrivere |

Nota Steps: in Stompers il contapassi è gratis; il paywall è sulla giornata intera e sullo storico. L'hook dice esattamente questo, non "il contapassi costa".

## d. Lancio della suite (solo dopo Auth e Clean pubblicate)

- **Product Hunt, una volta sola.** Tagline: "Free native replacements for the App Store's top paid utilities". Martedì, 00:01 PT. Primo commento: il numero, la persona, la repo.
- **PR a `awesome-ios` e `open-source-ios-apps`** (dkhamsing/open-source-ios-apps): una voce per app pubblicata, con link alla repo e all'App Store come chiedono le loro regole.
- **Post-numero "4 app, 2.000 €/anno, 0 €"**: solo quando le quattro app nel post sono pubblicate. Con Auth, Clean, Steps e Docs le quattro sono Authenticator (519 €), Cleanup (675 €), Stompers (311 €) e CamScanner+ (50 $): totale circa 1.550 €. Per dire "2.000 €" serve Swipewipe al posto di CamScanner (Clean sostituisce entrambe) oppure un'App Sbu per il battito cardiaco. Il numero si ricalcola il giorno del post, mai arrotondato per eccesso.
- Stampa della suite (MacStories, 9to5Mac, iPhoneItalia, Macitynet): solo con un thread che ha preso alle spalle.

## e. Canali e ruoli

| Canale | Scopo | Cadenza | Formato |
|---|---|---|---|
| Video breve (Reels, Shorts, TikTok) | **download** | uno per lancio, più un taglio diverso a giorno 7 | stesso file verticale 1080×1920, 20 s, sottotitoli IT/EN, niente voce, caricato **nativo** su ciascuna piattaforma (mai link a YouTube). Generato dallo screen recording del simulatore: cornice con `fastlane frameit` o render con `ImageRenderer`, montaggio secondo `marketing/<slug>/video.md` |
| Hacker News (Show HN) | **picchi** | uno per app, mai due nella stessa settimana | titolo col numero, primo commento col metodo, risposte per 6 ore |
| Reddit | **picchi** e coda lunga | 1-3 giorni per lancio, poi risposte quando qualcuno chiede | commento da utente in thread esistenti, screenshot vero, mai post-link |
| LinkedIn, X | **persona e credibilità**, follower | giorni 0, 7, 14 di ogni lancio | testo corto, una immagine, link sbu.dev nel primo commento |
| sbu.dev | **casa e SEO** | a ogni lancio | `/apps/<slug>`, `/privacy/<slug>`, `/alternatives/<originale>`, blog |
| Stampa | **amplificazione** | solo dopo un thread che ha preso | mail di 8 righe con il link al thread |

## f. Cosa non fare

- Lanciare la suite (Product Hunt, liste awesome, stampa della suite) prima che Auth e Clean siano pubblicate.
- Contenuti generici tipo "le migliori app per iPhone".
- Linkare l'App Store al posto di sbu.dev.
- Attaccare app una tantum a prezzo equo (Streaks, AnkiMobile, Noir, Wipr, Clinometer).
- Comprare follower, upvote o pubblicità. Budget: 0 €.
- Mettere icone o screenshot dei concorrenti sul sito (solo testo, uso nominativo).
- Dire "zero rete" per Clean (scarica da iCloud l'originale quando lo chiedi tu: si dice "nessun server, nessun account").
- Più di un Show HN a settimana, o lo stesso commento copiato in più sub.

## g. Metriche per contenuto

Ogni post o thread va in `marketing/log.md`: data, canale, link, download nei 3 giorni successivi (App Store Connect, Analisi > Sorgenti), visite a `/apps/<slug>` (log di nginx sul server Coolify: sbu.dev non è dietro Cloudflare e il sito non ha script), stelle GitHub (`gh api repos/mgiuditta/sbu-apps --jq .stargazers_count`).

Obiettivi del lancio di Auth: **2.000 download e 100 stelle in 14 giorni**; front page HN: 5-10 mila download.

Restano le metriche di prima: download a settimana (stella polare), impressioni e clic su `/apps/*` e `/alternatives/*` in Search Console, "web referrer" sbu.dev in App Store Connect, zero richieste di terze parti sul sito.
