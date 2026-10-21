# Lancio di Sbu: la punta di lancia (aggiornato il 17 ottobre 2026)

Sostituisce la versione del 15/10, costruita su Sbu Auth: Auth è archiviata dal 16/10 insieme a Docs, Steps e Focus (`docs/factory.md`, filtro di nicchia). Sostituisce anche la sequenza e i canali di `docs/marketing/marketing-plan.md`. Restano validi i pilastri e l'inventario delle pagine di `docs/marketing/content-strategy.md`, le metriche senza script e la regola "zero richieste di terze parti sul sito". La versione del 15/10 è nella cronologia git di questo file; i suoi asset sono in `marketing/archivio/auth/`.

La strategia in una riga: **un'app sola come punta di lancia, una storia che si capisce in una frase, una faccia, un loop ripetibile.** Le utility non diventano virali da sole. Diventano virali il numero, l'ironia e la persona: Matteo Giuditta, studente di Sicurezza Informatica a Milano, che rifà le app a pagamento e le regala, con il codice aperto.

Ordine: **Sbu Subscriptions** (punta di lancia, già pubblicata), **Sbu Find** (secondo colpo, in revisione), **Sbu Clean** quando Apple accetta la risposta al 4.3 del 14/10. La suite si lancia solo con tre app pubblicate. Roadmap in `docs/factory.md`, rischi in `docs/priorita-2026-10.md`.

Stato delle app il 17/10 (lookup dell'App Store): pubblicate solo **Sbu Subscriptions 2.0.0** (id 6780154928, uscita il 15/10) e **Sbu Scanner 2.0.0** (id 6772572337, uscita il 17/10). Find in revisione. Clean, Habits, Noise, Moon respinte il 14/10, risposta in attesa. Un invio a settimana.

**Repo pubblica dal 15/10/2026:** https://github.com/mgiuditta/sbu-apps, licenza MIT, cronologia ripulita dai dati personali. Issue e PR di lavoro restano nella privata `mgiuditta/sbu-apps-private`. Le segnalazioni di sicurezza arrivano dalla "private vulnerability reporting" di GitHub.

## a. Il numero

Fonte: elenco "Acquisti in-app" della pagina pubblica dell'App Store (apps.apple.com, IT e US), letto il **17/10/2026**; valutazioni dal lookup `itunes.apple.com/lookup` dello stesso giorno. Il lookup non elenca gli acquisti in-app: i prezzi vengono dalla pagina dello Store.

| Originale (ID) | App Sbu | Stato Sbu | Prezzo più alto in elenco, IT | US | All'anno (IT) | Valutazioni IT / US |
|---|---|---|---|---|---|---|
| Orbit (6692620188) | Subscriptions | pubblicata | Orbit Plus annuale **22,99 €**; a vita 24,99-29,99 € | annuale $19.99; a vita $24.99-$39.99 | **22,99 €** | 99 / 127 |
| QR Reader for iPhone, oggi "QR Code ϟ" (368494609) | Scanner | pubblicata | TapMedia PRO **5,99 € al mese**; PRO una tantum 2,99 € | $4.99 al mese | **71,88 €** | 46,8 mila / 1,44 milioni |
| Find Air (1507917112) | Find | pubblicata il 21/10 | Air Apps One fino a **8,99 € a settimana**; annuale 79,99 € | fino a $9.99 a settimana (21/10); annuale $69.99 | **467,48 €** | 262 / 27,3 mila |
| Cleanup (1510944943) | Clean | respinta, risposta in attesa | Cleanup Pro fino a **12,99 € a settimana**; annuale 24,99 € | fino a $11.99 a settimana | **675,48 €** | (737 mila US il 15/10) |
| **Totale** | | | | | **1.237,83 €/anno** (US $1,378.83) | |

Come si legge la tabella: il settimanale × 52 o il mensile × 12, al prezzo di listino più alto in elenco. L'elenco di Find Air mostra anche "Air Apps One - 1 Month 229,99 €": è un dato strano, non lo usiamo.

**La storia di Subscriptions non è il numero, è l'ironia.** Orbit costa poco (22,99 € l'anno) e ha 99 valutazioni in Italia: attaccarlo sul prezzo è sproporzionato e antipatico (sezione f). La frase è: **"Un'app per tenere sotto controllo gli abbonamenti non dovrebbe chiederti un abbonamento."** Il numero che conta è quello dell'utente: la cifra in alto, quanto spende davvero lui (544,34 € l'anno nei dati di esempio). Il numero dei paywall settimanali torna con Find e Clean.

Regole di onestà, perché su HN il primo commento le controlla:
- Sempre "fino a" e "prezzo di listino". Mai dire che tutti pagano il massimo.
- Su Orbit si dice il vero: è gratis da scaricare, Plus è un abbonamento annuale o un acquisto a vita, il gratis ha dei limiti. Niente "Orbit costa X a settimana".
- Il totale si cita solo con le app Sbu pubblicate quel giorno: oggi Orbit + QR Reader = **94,87 € l'anno**, un numero debole. "Oltre 1.200 €" solo quando Find e Clean sono pubblicate.
- Prima di ogni contenuto con un prezzo: riaprire le pagine, aggiornare data e prezzi qui. I prezzi cambiano per paese e per test A/B.

## b. La punta di lancia: Sbu Subscriptions, 14 giorni

**Il giorno 0 è l'uscita della 2.1.0, non oggi sulla 2.0.0.** Tre motivi:
1. La 2.1.0 porta gli screenshot nuovi, con didascalie per la ricerca (abbonamenti, prova gratuita, rinnovi, widget). Gli screenshot di una versione in vendita non si cambiano: la 2.0.0 resta con quelli vecchi.
2. La 2.1.0 porta la richiesta di recensione dopo la Closure e "Condividi l'app" e "Scrivi una recensione" nelle impostazioni (commit 199a8217). Un picco di download sulla 2.0.0 non lascia recensioni.
3. Show HN si fa una volta per app. Bruciarlo su una pagina che converte peggio è uno spreco.

Fino al giorno 0 (settimana "zero", sulla 2.0.0): solo coda lunga. Risposte da utente nei thread Reddit che chiedono un tracker di abbonamenti gratis, con il calcolatore `/abbonamenti` del sito e l'articolo del blog su come disdire un abbonamento su iPhone; `/alternatives/orbit` è già pubblicata. Nessun post proprio, nessun Show HN.

Lo slot di questa settimana è di Find (in revisione). La 2.1.0 va nel primo slot libero dopo. Asset in `marketing/subscriptions/`. Ogni contenuto chiude con **sbu.dev/apps/subscriptions**, mai con il solo link all'App Store.

| Giorno | Azione | Asset | Fatto quando |
|---|---|---|---|
| -3 | 2.1.0 approvata, rilascio manuale pronto; screenshot nuovi caricati; video montato | `video.md` | la 2.1.0 è "Pronta per la vendita" in attesa del rilascio |
| 0 | Rilascio della 2.1.0. Video 20 s caricato nativo su Reels, Shorts, TikTok. Post LinkedIn e X con la cifra | `video.md`, `linkedin.md` (giorno 0) | link sbu.dev in bio e nel primo commento |
| 1 | **Show HN**, martedì-giovedì 15-17 ora italiana. Titolo con l'ironia, primo commento con metodo, privacy, repo, cosa non fa. Matteo risponde a tutto per 6 ore | `showhn.md` | link al thread in `marketing/log.md` |
| 1-3 | Reddit: un thread **reale** per sub, già esistente, in cui qualcuno chiede un tracker di abbonamenti o si lamenta di un rinnovo. Risposta da utente con uno screenshot vero. Mai post-link | `reddit.md` | un commento per sub, nessuna rimozione dei mod |
| 4-7 | Mail di 8 righe a MacStories, 9to5Mac (EN), iPhoneItalia, Macitynet (IT). **Solo se** il thread HN o Reddit ha preso (front page HN, o 100+ upvote su Reddit) | `press.md` | 4 mail, una per testata, nessun follow-up prima di 5 giorni |
| 7 | Post "come l'ho fatta": ore, righe di codice, 0 €, cosa ha fatto Claude e cosa Matteo. Blog sbu.dev + LinkedIn + X | `linkedin.md` (giorno 7) | numeri veri da `git log` e `cloc` |
| 14 | Post "due settimane dopo": download, recensioni, stelle GitHub, cosa è andato storto | `linkedin.md` (giorno 14) | dati da App Store Connect e GitHub |
| se rifiutata | Post "Apple mi ha rifiutato": cosa dice la regola, cosa cambio. Il rifiuto è contenuto | `linkedin.md` (post-errore) | |

Obiettivo del lancio di Subscriptions: **1.000 download in 14 giorni, 20 recensioni, 50 stelle GitHub.** Più basso di quello di Auth: Orbit ha un pubblico piccolo e la storia è l'ironia, non l'indignazione. Se il thread HN entra in front page: 3-5 mila download.

## c. Il loop ripetibile (Find, Clean)

Lo stesso schema in checklist. Copiare `marketing/subscriptions/` in `marketing/<slug>/` e riscrivere.

- [ ] Numero verificato oggi sulla pagina dello Store ("fino a", settimanale × 52), scritto in questo file, sezione a
- [ ] Hook scelto (sotto) e 10 varianti in `hooks.md`
- [ ] Screenshot del paywall dell'originale, solo per social e video, con "X è un marchio del rispettivo proprietario; Sbu non è affiliata."
- [ ] Giorno 0: release, `/apps/<slug>`, `/privacy/<slug>`, video 20 s su Reels, Shorts, TikTok, post LinkedIn e X
- [ ] Giorno 1: Show HN con il numero nel titolo (un solo Show HN per app, mai due nella stessa settimana)
- [ ] Giorno 1-3: un thread Reddit reale per sub, risposta da utente con screenshot
- [ ] Giorno 2: `/alternatives/<originale>` (Find Air e Cleanup sono già scritte e si pubblicano con l'app)
- [ ] Giorno 4-7: stampa solo se un thread ha preso
- [ ] Giorno 7: "come l'ho fatta"; giorno 14: "due settimane dopo"
- [ ] Ogni contenuto registrato in `marketing/log.md`

| App | Hook | Sub Reddit | Asset |
|---|---|---|---|
| Find | Hai perso le cuffie. Find Air ti chiede fino a 8,99 € a settimana per dirti "più caldo". Sbu Find te lo dice gratis. | r/airpods, r/iphone, r/apple | `marketing/find/` (pronti, prezzi del 17/10) |
| Clean | Cleanup ti fa scegliere le foto per mezz'ora e poi chiede fino a 12,99 € a settimana per eliminarle. Sbu Clean le elimina gratis. | r/iphone, r/ios, r/DataHoarder, r/declutter | `marketing/clean/` (pronti, numeri del 15/10 confermati il 17/10) |

Nota Find: Sbu Find non dice i metri, nessuna app può farlo con il Bluetooth. L'hook parla di "più caldo, più freddo", non di "trovale in un secondo". Per gli auricolari spenti o nella custodia serve Dov'è: si dice prima che lo chiedano.

## d. Lancio della suite (solo con Subscriptions, Find e Clean pubblicate)

- **Product Hunt, una volta sola.** Tagline: "Free native replacements for paid App Store utilities". Martedì, 00:01 PT. Primo commento: il numero, la persona, la repo.
- **PR a `awesome-ios` e `open-source-ios-apps`** (dkhamsing/open-source-ios-apps): una voce per app pubblicata, con link alla repo e all'App Store come chiedono le loro regole. Questa si può fare da subito per Subscriptions e Scanner, sono pubblicate.
- **Post-numero "N app, X €/anno, 0 €"**: solo con le app del post pubblicate. Con Subscriptions, Scanner, Find e Clean il totale di oggi è 1.237,83 € l'anno (sezione a). Si ricalcola il giorno del post, mai arrotondato per eccesso.
- Stampa della suite (MacStories, 9to5Mac, iPhoneItalia, Macitynet): solo con un thread che ha preso alle spalle.

## e. Canali e ruoli

| Canale | Scopo | Cadenza | Formato |
|---|---|---|---|
| Video breve (Reels, Shorts, TikTok) | **download** | uno per lancio, più un taglio diverso a giorno 7 | stesso file verticale 1080×1920, 20 s, sottotitoli IT/EN, niente voce, caricato **nativo** su ciascuna piattaforma (mai link a YouTube). Generato dallo screen recording del simulatore, montaggio secondo `marketing/<slug>/video.md` |
| Hacker News (Show HN) | **picchi** | uno per app, mai due nella stessa settimana | titolo con la storia, primo commento col metodo, risposte per 6 ore |
| Reddit | **picchi** e coda lunga | 1-3 giorni per lancio, poi risposte quando qualcuno chiede | commento da utente in thread esistenti, screenshot vero, mai post-link |
| LinkedIn, X | **persona e credibilità**, follower | giorni 0, 7, 14 di ogni lancio | testo corto, una immagine, link sbu.dev nel primo commento |
| sbu.dev | **casa e SEO** | a ogni lancio | `/apps/<slug>`, `/privacy/<slug>`, `/alternatives/<originale>`, blog, feed RSS |
| App Store (dentro l'app) | **recensioni e passaparola** | sempre, dalla 2.1.0 | richiesta di recensione dopo la Closure, "Condividi l'app", "Parte di sbu.dev" |
| Stampa | **amplificazione** | solo dopo un thread che ha preso | mail di 8 righe con il link al thread |

## f. Cosa non fare

- Lanciare la suite (Product Hunt, stampa della suite) prima di tre app pubblicate.
- Fare lo Show HN di Subscriptions sulla 2.0.0.
- Attaccare Orbit sul prezzo: costa 22,99 € l'anno ed è fatta da uno sviluppatore piccolo. Si parla della categoria e dell'ironia, non di Orbit.
- Contenuti generici tipo "le migliori app per iPhone".
- Linkare l'App Store al posto di sbu.dev.
- Attaccare app una tantum a prezzo equo (Streaks, AnkiMobile, Noir, Wipr, Clinometer).
- Comprare follower, upvote o pubblicità. Budget: 0 €.
- Mettere icone o screenshot dei concorrenti sul sito (solo testo, uso nominativo).
- Dire "zero rete" per Subscriptions: con Sincronizza con iCloud o una lista condivisa usa il tuo iCloud. Si dice "nessun server di sbu.dev, nessun account". Per Clean: scarica da iCloud l'originale quando lo chiedi tu.
- Più di un Show HN a settimana, o lo stesso commento copiato in più sub.

## g. Metriche per contenuto

Ogni post o thread va in `marketing/log.md`: data, canale, link, download nei 3 giorni successivi (App Store Connect, Analisi > Sorgenti), visite a `/apps/<slug>` (log di nginx sul server Coolify: sbu.dev non è dietro Cloudflare e il sito non ha script), stelle GitHub (`gh api repos/mgiuditta/sbu-apps --jq .stargazers_count`, 1 il 17/10).

Obiettivi del lancio di Subscriptions: **1.000 download, 20 recensioni e 50 stelle in 14 giorni**; front page HN: 3-5 mila download. Se nessun canale supera i 150 download in 3 giorni, il problema è l'hook: si riscrive da `hooks.md` prima di Find.

Restano le metriche di prima: download a settimana (stella polare), impressioni e clic su `/apps/*` e `/alternatives/*` in Search Console, "web referrer" sbu.dev in App Store Connect, zero richieste di terze parti sul sito.
