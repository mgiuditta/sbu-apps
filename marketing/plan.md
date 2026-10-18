<!-- Piano marketing di sbu.dev, copia pubblica. La fonte di lavoro resta fuori dal repo; i dettagli di Sbu Commerce restano privati finché il progetto non è annunciato. -->

# sbu.dev — Piano marketing 12 mesi

v3.2 · 18 ottobre 2026, sera (allineata a `docs/stato.md`: coda dello Store, voci fatte, decisioni chiuse; tre rami: App, Giochi, Software) · Matteo Giuditta + Claude

## 1. Executive summary

**sbu.dev rifà gratis il software che oggi si paga, in tre rami.** **App**: le app iPhone più vendute, rifatte gratis, una a settimana. **Giochi**: i giochi più giocati, rifatti senza pubblicità, uno al mese. **Software**: il software che le aziende pagano centinaia di migliaia di euro l'anno, rifatto open source; il primo progetto è **Sbu Commerce**, un backend e-commerce B2B open source e self-hosted. Stesse regole per tutti: niente abbonamenti, niente pubblicità, niente tracking, i dati restano a chi li possiede.

Oggi (18/10, verificato su App Store Connect): 2 app live (Subscriptions 2.0, Scanner 2.0), Find 1.0 in revisione, 4 app respinte il 14/10 (4.3) in attesa della risposta di Apple, 3 pronte su ASC e mai inviate (Chats, Fuel, Inventory), 7 scritte e mai su ASC, Squares (primo gioco) su main. Software: ADR-0016 e pagine `/software` online, il repo `sbu-commerce` non esiste ancora. E nessuno conosce ancora sbu.dev: zero lanci usciti, 1 recensione, 1 stella GitHub, zero backlink. Punteggio di partenza 51/85.

**Il collo di bottiglia non è il marketing, è lo Store**: la risposta di Apple al 4.3 (finché tace, un invio a settimana), il test insieme sul tuo iPhone e TestFlight che non installa. La base marketing è pronta: ogni lancio parte il giorno in cui Apple approva.

### Tre scommesse (una per ramo, più un tetto comune)
1. **App: rispondere a ricerche che esistono già.** Una pagina "alternativa gratis a <app a pagamento>" per ogni app, IT e EN; Matteo in video ("Questa app costa 40 € l'anno. L'ho rifatta gratis."); SbuKit che chiede recensioni e fa condividere. Lancio della collezione (Show HN + Product Hunt) a metà dicembre.
2. **Giochi: "senza pubblicità" come unica promessa.** Sbu Squares a dicembre, poi un gioco al mese; ASO su "no ads", video di gameplay, partita del giorno da condividere. È la porta d'ingresso a sbu.dev per il pubblico più grande.
3. **Software (Sbu Commerce): il commerce enterprise, open source.** Un backend B2B che le aziende installano sui propri server, al posto di licenze da centinaia di migliaia di euro l'anno. Pubblico piccolo ma che spende molto, ed è il mestiere di Matteo: credibilità che le app non danno.
- **Il tetto comune**: un solo brand (sbu.dev), un solo volto (Matteo), un solo manifesto ("il software che si paga, rifatto gratis") e un sito con tre rami: `/apps`, `/games`, `/software`.

### 90 giorni (19 ott – 10 gen)
- **App**, sett. 1–12: la base è fatta (Search Console, Smart Banner, review request in SbuKit, 6 pagine alternativa, strumenti, RSS). Ora: lancio di Find il giorno dell'approvazione, un Show HN per app, il primo video, poi Show HN e Product Hunt della collezione a metà dicembre (§9).
- **Giochi**: prova completa di Squares, screenshot, TestFlight, invio a inizio dicembre; `/games` online all'approvazione.
- **Software / Sbu Commerce**: ADR-0016 e `/software/commerce` già fatti; restano repo `sbu-commerce`, primo spike (catalogo, prodotto, carrello), primo articolo tecnico. Niente lancio pubblico prima di una demo che gira.

### Obiettivo a 12 mesi
- **App**: 30 pagine alternativa indicizzate, 500+ recensioni, download raddoppiati ogni trimestre.
- **Giochi**: 10 giochi, Squares nei primi 3 per "block puzzle no ads", 1.000+ recensioni.
- **Software / Sbu Commerce**: una versione 1.0 (catalogo, ricerca, carrello, checkout, account B2B), 1.000+ stelle GitHub, 3 aziende che la provano in staging, 1 migrazione pubblica raccontata.
- **sbu.dev**: primo su Google per il proprio nome, 10 articoli di stampa, 1 talk.
Costo: **0 €** fino a un primo segnale; poi al massimo 100–300 €/mese su Apple Search Ads, solo se ripaga. Il ramo Software non spende in ads: il suo canale è la community.


---

## 2. Strategic frame

### Architettura del brand (v3)
Un brand, tre rami. Il manifesto è uno: **"Il software che si paga, rifatto gratis."** EN: *"Software you pay for, remade free."*
| Ramo | Indirizzo | Prodotto | Frase | Pubblico | Forma |
|---|---|---|---|---|---|
| **App** | `sbu.dev/apps` | Sbu Subscriptions, Scanner, Find… | "Le app più vendute dell'App Store, rifatte gratis. Una a settimana." | A, B (consumatori), C (dev) | App iOS native, dati sul dispositivo |
| **Giochi** | `sbu.dev/games` | Sbu Squares, poi Tiles, Sudoku… | "I giochi più giocati, rifatti senza pubblicità. Uno al mese." | D (giocatori) | App iOS native, offline |
| **Software** | `sbu.dev/software` | Sbu Commerce (primo progetto, `sbu.dev/software/commerce`) | "Il commerce enterprise, open source." | E (aziende con piattaforme e-commerce enterprise a licenza, integratori) | Open source MIT, self-hosted (Docker), nessun server di sbu.dev |

Le regole che valgono ovunque: niente abbonamenti, niente pubblicità, niente tracking, i dati restano a chi li possiede (sul dispositivo per app e giochi, sui server del cliente per Software). Le regole che cambiano per ramo: le app non usano la rete; i progetti Software sono software server per definizione, ma sbu.dev non lo ospita e non riceve nulla (ADR-0016).


### Category claim
**"Le app più vendute dell'App Store, rifatte gratis. Una a settimana."**
EN: *"The top-paid iPhone apps, remade free. One a week."*

 **Giochi (v2):** *"I giochi più giocati, rifatti senza pubblicità. Uno al mese."* EN: *"The most-played games, remade without ads. One a month."*

Non "app gratis" (categoria affollata, piena di freemium che mentono) ma il **remake gratuito di un'app a pagamento precisa**. Questa frase è insieme posizionamento, storia per la stampa e strategia SEO: ogni app risponde a una ricerca che esiste già, "alternativa gratis a <app a pagamento>".

### Tre pubblici, un messaggio
| Pubblico | Cosa cerca | Dove sta | Cosa gli diamo |
|---|---|---|---|
| **A. Stanchi degli abbonamenti** (IT + US) | "alternativa gratis a Orbit", "app abbonamenti senza abbonamento" | Google, App Store search, Reddit | Pagina alternativa + app |
| **B. Privacy e indie fan** | app senza tracking, open source | r/apple, r/iphone, HN, Mastodon, MacStories | Principi, codice, sei promesse |
| **C. Dev e build-in-public** | come si fa una app a settimana da soli con Claude | X, HN, r/iOSProgramming, LinkedIn, YouTube | Matteo: il processo, i numeri, i rifiuti Apple |

| **D. Stanchi della pubblicità nei giochi** (IT + US, v2) | "block puzzle senza pubblicità", "sudoku no ads", "giochi offline senza pubblicità" | App Store search, TikTok, Facebook, YouTube Shorts, r/iosgaming, genitori | Gioco nativo senza interruzioni, offline |

| **E. Aziende con e-commerce enterprise a licenza** (v3) | alternative open source al proprio e-commerce enterprise | LinkedIn, community tecniche, integratori | Sbu Commerce |

A e B scaricano le app. C rende famoso Matteo e il repo, e porta link (autorità SEO) che fanno salire le pagine per A. D è il pubblico più grande di tutti: i giochi puzzle gratis hanno valutazioni a milioni, contro le migliaia delle utility. È anche il più lontano dal mondo dev, quindi i giochi sono la porta d'ingresso a sbu.dev per chi non leggerà mai HN: da un gioco si arriva alle app, non il contrario.

### Logica del modello
Nessun ricavo, per scelta. La "moneta" è attenzione: download, link, menzioni, stelle. Quindi niente CAC/LTV; si misurano **ricerche del brand, backlink, download, stelle GitHub** (§13).
Conseguenza: ogni euro speso deve comprare qualcosa che resta (contenuto, link, video), non traffico che finisce quando finisce il budget.

E è il pubblico più piccolo e il più ricco: poche migliaia di aziende nel mondo. Non scarica: **prova, valuta, migra**, in mesi.

### Vincoli non negoziabili
1. **Marchi dei concorrenti mai nei metadati App Store** (guideline 2.3.7, e dopo il 4.3 del 14/10 sarebbe benzina). Sul sito sì, in forma fattuale e comparativa ("Sbu Subscriptions fa quello che fa Orbit, gratis"), mai loghi, screenshot o UI loro.
2. **Mai "copia" o "clone"**: si dice "rifatta", "alternativa", "versione gratuita di questo lavoro". Protegge da 4.3 e da diffide.
3. **Brand: sempre "sbu.dev"**, mai "sbu" da solo nei testi pubblici: "sbu" è di Stony Brook University e altri, non lo vinci. "sbu.dev" e "Sbu <Nome>" sono vincibili subito.
4. **Voce** (già scritta in CLAUDE.md, vale anche fuori dall'app): seconda persona, frasi brevi, niente emoji, niente punti esclamativi, niente "PRO", niente gradienti, niente aria da paywall. Le sei promesse sempre in fondo, mai in apertura.
5. **Onestà sull'AI**: se Matteo racconta che le app sono fatte con Claude, lo dice per primo e con i numeri (test, rifiuti, ore). Scoperto da altri diventa "AI slop"; raccontato da lui diventa la storia.

6. **Giochi (v2)**: mai il nome di un altro gioco (né "Blast", né "doku" preso da Meowdoku) nel nome, nell'icona o nei metadati App Store. La meccanica si riprende, il look no: niente blocchi colorati e gemme, solo il Quaderno (`ink` su `paper`, griglia da 24 pt, il punto fermo come l'unica cella colorata). Sul sito, pagina alternativa fattuale come per le app.
7. **Niente dark pattern (v2)**: niente vite, energia, timer per tornare, notifiche "ti manca", streak punitive, monete. Un gioco sbu.dev si chiude quando vuoi tu. È la promessa "senza pubblicità" portata fino in fondo, ed è anche la differenza che regge davanti al 4.3: lo stesso genere, senza il motore dei soldi.

8. **Sbu Commerce (v3)**: interoperabilità solo da documentazione pubblica e codice open source; mai materiale o marchi di altri nel nome (ADR-0016).
9. **Sbu Commerce, onestà sul perimetro**: una tabella pubblica e sempre vera di cosa copre e cosa no.

### Decisione aperta (§13)
Raccontare o no l'angolo "una persona + Claude fa un'app a settimana". È l'hook più forte per HN/X/stampa tech; è anche il più rischioso con Apple (4.3) e con il pubblico A. Raccomandazione: sì, ma su canali dev (pubblico C), non nelle pagine app.
**v2:** i giochi hanno bisogno di un'ADR: "Sbu fa una cosa sola" vale per gioco (una meccanica per gioco), e la regola "una figura per schermata" diventa il punteggio.


---

## 3. Current state

*v1.2 (piano v3.2): fatti allineati a `docs/stato.md` il 18/10 sera. v1.1, punteggi rifatti il 18/10/2026 dai materiali: repo, sito live, lookup App Store IT/US, GitHub. Search Console e Bing attivi dal 17/10, ancora senza dati utili. La v1 del 17/10 (41/85) è in `materials/03-v1.md`.*

### Team
| Persona | Ruolo | Superficie marketing |
|---|---|---|
| Matteo | Founder, sviluppatore, unico umano | Tutto: app, sito, metadati App Store, invii, rapporti con Apple |
| Claude (+ skill) | Esecuzione | Codice, testi, metadati, screenshot, sito, ricerca |

Matteo è π-shaped su **prodotto + design system** e T-shaped sulla distribuzione. Non serve un'assunzione: manca il tempo dedicato. Il piano assume **5–10 ore a settimana** di marketing con la faccia di Matteo, più Claude per produrre. Le azioni pubbliche su siti esterni (PR, post, invii) le fa Matteo.

### Budget
- Speso oggi: 0 €/mese. Strumenti: Apple Developer 99 €/anno, hosting sito (già pagato).
- Il piano resta a **0 €** fino al primo segnale organico (§10). GitHub Sponsors: non per ora (decisione del 18/10, #589). Newsletter: no, solo RSS (#588).
- CAC, ARR, LTV: **non applicabili**, le app sono gratis per scelta. Le metriche sono attenzione e download (§13).
- Fase: fine del pre-lancio. La base è pronta, il primo lancio (Find) aspetta l'approvazione di Apple.

### Cosa è già fatto (e va riconosciuto)
- **Design system Quaderno** v5: le app si riconoscono come famiglia.
- **Sito bilingue** con SEO tecnico completo: sitemap, hreflang, canonical, JSON-LD, `sameAs`, `llms.txt`, Smart App Banner, RSS per lingua, PageSpeed mobile ≥ 99 su ogni pagina.
- **Home**: frase-categoria ("rifà da zero un'app a pagamento"), "Dov'è la fregatura?", le app che si scaricano per prime (ordine per stato dal 18/10, il numero di catalogo resta).
- **Pagine alternativa**: 6 scritte IT/EN (Orbit, QR Reader, Find Air, Cleanup, My Moon Phase Pro, Streaks) e hub `/alternatives`; online quelle delle app live, le altre escono con l'app.
- **Strumenti e contenuti**: generatore QR `/qr-code`, calcolatore abbonamenti, guida "Come disdire un abbonamento su iPhone", articoli IT (3) e EN (2).
- **Stampa**: pagina Stampa con testi liberi e ritratto.
- **Profili**: Instagram @sbudevapp, Bluesky @sbu.dev, bio IT/EN; link campagna App Store (`pt=128487151`, `ct=` per sorgente).
- **Repo pubblico** con README, 9 topic, MIT.
- **Liste**: AlternativeTo inviato (in moderazione), PR a open-source-ios-apps aperto (#2442, Subscriptions e Scanner).
- **2 app live**: Subscriptions 2.0 (id6780154928), Scanner 2.0 (id6772572337).
- **Lancio di Find pronto**: checklist, Show HN (deciso: uno per app, Find per prima, #590), Reddit, LinkedIn/X, stampa, video.
- **Richiesta di recensione in SbuKit**: fatta, arriva con la prossima versione di ogni app.

### In corso
- Find 1.0 in revisione dal 17/10, rilascio automatico all'approvazione (= giorno 0).
- Subscriptions 2.1.0 su App Store Connect, nessuna build agganciata (la 7 va selezionata), submit dal 24/10 dopo il test insieme: porta screenshot nuovi e richiesta di recensione.
- Habits, Clean, Noise, Moon 1.0 **respinte il 14/10** (4.3 / 4.2.6), in attesa della risposta di Apple; follow-up su Habits il 21/10 se Apple tace.
- Chats, Fuel, Inventory 1.0 pronte su ASC, mai inviate: mancano App Privacy, test insieme, uno slot.
- Level e Speed 1.1 da ripresentare dopo test sul device e screenshot, mai nella stessa settimana.
- Ritmo: 1 invio a settimana finché Apple non risponde al 4.3.

### Bloccato o mancante
1. **Zero lanci usciti**: tutto è pronto, aspetta Apple.
2. **Recensioni: 1 in tutto** (Scanner IT, 5★; Subscriptions 0). Si sblocca solo con la 2.1 e le versioni successive, più richieste personali a chi ha usato le app davvero.
3. **Autorità zero**: 1 stella GitHub, nessun backlink, nessuna menzione.
4. **Nessun dato di traffico** ancora: GSC appena attivo, registro `marketing/log.md` vuoto.
5. **Video** del lancio da girare su iPhone vero (se manca al giorno 0, esce al giorno 7).
6. **Il percorso verso lo Store**: TestFlight non installa sul tuo iPhone dal 16/10 (caso aperto con Developer Support; ripiego: build Release via cavo) e il test insieme manca a quasi tutte le app pronte. Ogni lancio del piano dipende da qui.

### Punteggi (17 voci, 0–5)
| # | Voce | 17/10 | 18/10 | Perché |
|---|---|---|---|---|
| 1 | Posizionamento | 4 | 5 | Frase-categoria in home, coerente su sito, store, repo. |
| 2 | Ricerca clienti | 3 | 3 | Recensioni 1–3★ dei concorrenti via `spec.py`; nessuna voce dei propri utenti. |
| 3 | Homepage | 4 | 4 | "Dov'è la fregatura?" e ordine per stato; manca la prova sociale. |
| 4 | Pagine prodotto | 3 | 3 | Strutturate, FAQ e schema; sottili. |
| 5 | Pagine di conversione | 3 | 4 | Smart App Banner, QR per il download, codici campagna. |
| 6 | Confronto concorrenti | 1 | 3 | 6 pagine scritte e hub; online solo quelle delle app live. |
| 7 | Contenuti | 1 | 2 | 5 articoli, guida, generatore QR, calcolatore, RSS. |
| 8 | Onboarding | 4 | 4 | `SbuEmpty`, niente permessi anticipati. |
| 9 | Email | 0 | 1 | Per scelta nessuna lista; RSS al suo posto. |
| 10 | Materiale stampa | 3 | 4 | Pagina Stampa, ritratto, testi liberi. |
| 11 | Messaggi | 4 | 4 | Voce forte e coerente. |
| 12 | Prezzo | 5 | 5 | 0 €, nessun acquisto in-app. |
| 13 | CRO | 1 | 2 | GSC/Bing e codici campagna attivi; nessun dato ancora. |
| 14 | Lanci | 0 | 1 | Materiale di Find pronto, PR e AlternativeTo inviati; nessun lancio uscito. |
| 15 | Ads | 0 | 0 | Nessuna; giusto per ora. |
| 16 | SEO | 2 | 3 | Tecnica 5/5, pagine alternativa; autorità 0/5. |
| 17 | Internazionalizzazione | 3 | 3 | IT + EN ovunque. |
| | **Totale** | **41** | **51 / 85** | |

**Forma: "base finita, distribuzione ancora a zero".** Sito, SEO tecnico, pagine alternativa, profili e stampa sono pronti. Restano a zero lanci, recensioni e autorità, e nessuna delle tre migliora con altro lavoro sul sito: si sbloccano con l'approvazione di Find (Show HN, Reddit) e con la prossima versione delle app (richiesta di recensione). Il collo di bottiglia oggi è Apple, non il marketing: il lavoro utile nell'attesa è il video di Find e le richieste personali di recensione.

### Giochi (v2, aggiornato in v3.2)
Fatto il 18/10: **ADR-0015** (Giochi Sbu), glossario dei giochi, accento `accent-squares`, **Sbu Squares** su main (un'unica partita senza fine come l'originale, algoritmi di distribuzione e punteggio dell'originale, record nel cartiglio), installato sul tuo iPhone; vetrina `sbu.dev/games` online. Mancano: prova completa, screenshot Store, record ASC, TestFlight; invio previsto a inizio dicembre. Nessuna esperienza di ASO sui giochi.
Cosa si riusa:
- **Il Quaderno è già un tabellone.** La griglia da 24 pt, `ink` su `paper`, il punto fermo come cella piena: un gioco su griglia non ha bisogno di un nuovo design system, solo di un'ADR.
- **SbuKit**: shell, `SbuFigure` (il punteggio), `SbuMotion`/`SbuHaptic` (`tick` su ogni pezzo, `closure` su una riga), `.sbuClosure` (fine partita), widget, review request, "Condividi".
- **Il sito Astro** ospita la vetrina `/games` (niente versione web dei giochi, decisione 18/10).
- **I profili social** presi in §9 #2 servono anche per i video di gameplay.
Mancano: un motore di gioco (non serve: SwiftUI `Canvas` + `TimelineView` bastano per una griglia 8×8), una persona che faccia playtest (Matteo + 3 amici), la verifica `originality-check` per un genere saturo.
Punteggio: invariato (51/85) finché Squares non esce. I giochi aprono la voce 14 (Lanci) e 4 (ASO) su un pubblico nuovo, ma per ora non c'è niente da misurare.

### Software / Sbu Commerce
I dettagli del progetto restano nella copia privata del piano finché il progetto non è annunciato.

---

## 4. Acquisition

### Oggi
Nessun canale attivo. Il poco traffico che arriva viene dalla ricerca dentro l'App Store (2 app live, quasi zero recensioni) e da chi conosce già Matteo. Non c'è un numero perché Search Console non è attivo (§3).

### Tesi
Una persona con 5–10 ore a settimana non vince facendo tutto. Vince con **un'uscita a settimana**, l'app approvata, che diventa sempre gli stessi cinque pezzi:
1. una pagina "alternativa gratis a X" sul sito (SEO, resta per anni);
2. un video corto di Matteo (social, picco);
3. un post scritto mentre si lavora (dev, link);
4. un invio ad AlternativeTo e alle directory (backlink);
5. una riga alla stampa quando la notizia regge.

Claude produce le bozze, Matteo ci mette la faccia e preme invio. Le mosse seguenti dettagliano ogni pezzo.

---

### Mossa 1 — SEO: le pagine "alternativa gratis a …"
**La leva più grande.** Chi cerca "Orbit alternativa gratis", "Streaks free alternative", "Find Air alternative", "Medisafe senza abbonamento" ha già il problema e sta per scaricare. Sono query a coda lunga con poca concorrenza vera: rispondono soprattutto listicle generici e AlternativeTo.

Una pagina per app, IT e EN, sul modello di `alternatives/streaks`:
- **Titolo**: `Alternativa gratis a <X> per iPhone · Sbu <Nome>` / `Free <X> alternative for iPhone, no subscription`.
- **Contenuto vero** (800–1.200 parole, non una doorway page): cosa costa X (prezzo pubblico dall'App Store), tabella di confronto fattuale funzione per funzione, **cosa Sbu non fa** (onestà = fiducia = E-E-A-T), come importare i dati se possibile, FAQ (schema `FAQPage`).
- Mai loghi, screenshot o UI del concorrente. Solo nome, prezzo e funzioni pubbliche.
- In sitemap appena l'app è live.

Mappa iniziale (app live o in review):
| App | Alternativa a | Query IT | Query EN |
|---|---|---|---|
| Subscriptions | Orbit | app abbonamenti gratis, gestire abbonamenti iPhone | free subscription tracker iPhone, Orbit alternative |
| Scanner | QR Reader | lettore QR senza pubblicità | QR scanner no ads iPhone |
| Habits | Streaks | app abitudini gratis | Streaks alternative free |
| Find | Find Air | trovare AirPods persi | find lost AirPods app free |
| Clean | Cleanup | liberare spazio iPhone gratis | free photo cleaner iPhone no subscription |
| Moon | My Moon Phase Pro | fasi lunari app | moon phase app free |
| Noise | White Noise | rumore bianco app gratis | white noise app no subscription |

Poi Fuel (Fuelly), Inventory (Sortly), Speed, Meds (Medisafe), Tidy (Tody), Remote, Shrink, Grid, Chats, al ritmo delle approvazioni.

**Pagine di categoria** (una ogni due settimane): "Le app iPhone che ti fanno pagare un abbonamento per niente", "Quanto spendi in abbonamenti" (esiste: rinforzarla). Funzionano da hub che rimandano alle pagine alternativa.

**Strumenti:** skill `competitors`, `programmatic-seo` (solo per il template, ogni pagina scritta a mano), `schema`, `seo-audit`. GSC per vedere quali query arrivano già.

### Mossa 2 — Brand: far esistere "sbu.dev"
"sbu" non si vince. "sbu.dev" e "Sbu Subscriptions" si vincono in settimane, se Google capisce chi sei:
- **Search Console + Bing Webmaster** (verifica DNS), sitemap inviata, richiesta di indicizzazione per home e app live.
- `Organization` JSON-LD con `sameAs`: GitHub, pagina sviluppatore App Store, X, LinkedIn, Mastodon, YouTube. `founder` → `Person` Matteo con i suoi profili.
- `MobileApplication` con `author`, `aggregateRating` solo quando ci sono recensioni vere.
- **`llms.txt`** e una pagina "Cos'è sbu.dev" chiara, perché ChatGPT/Perplexity/AI Overviews la citino (skill `ai-seo`). Chi chiede "app gratis senza abbonamento per iPhone" a un'AI deve trovare sbu.dev.
- Stesso nome ovunque: `sbudevapp` come handle (Instagram @sbudevapp preso, Bluesky @sbu.dev; X, TikTok, YouTube, LinkedIn da prendere con lo stesso nome).

### Mossa 3 — ASO
- Sottotitoli già buoni. Nei metadati provare **"gratis" / "senza abbonamento" / "free, no subscription"** (consentito, sono fatti) nel sottotitolo o nelle keyword, dove ci stanno.
- Keyword: niente marchi altrui (§2), via le parole già nel nome (Apple le indicizza già).
- **Recensioni** (`requestReview` dopo la Chiusura, §5): da 1 a 50 per app è il salto di ranking più grande che puoi fare gratis.
- Pagina sviluppatore: tutte le app sotto lo stesso nome. Ogni app nuova porta traffico alle altre ("Altre app di sbu.dev").
- Skill: `aso`, `app-store-aso`, `asc-aso-audit`, `asc-metadata-sync`.

### Mossa 4 — Founder-led: Matteo in video e per iscritto
La storia è già scritta: **"Questa app costa 40 € l'anno. L'ho rifatta gratis. Settimana 7."** È un format: si ripete per ogni app, fa vedere il prodotto in 30 secondi e non ha bisogno di montaggio.

| Canale | Formato | Ritmo | Pubblico |
|---|---|---|---|
| TikTok + Reels + Shorts | 30–45 s: prezzo dell'originale → la tua app che fa la stessa cosa → "gratis, niente account, link in bio" | 1 a settimana (l'app della settimana) + 1 extra | A |
| X | Mentre lavori: numeri, screenshot, rifiuti Apple, il codice | 3–5 a settimana, brevi | C |
| LinkedIn (IT) | Un post lungo a settimana: la storia, cosa hai imparato | 1 a settimana | C, stampa IT |
| Blog sbu.dev | Un articolo ogni 2 settimane: "Come Apple mi ha rifiutato 6 app in un giorno", "Una app a settimana: il sistema", "Quanto costano davvero gli abbonamenti iPhone" | 2 al mese | A, B, C + SEO |

Regole: voce di sbu.dev anche qui (niente emoji, niente "!"), i prezzi dei concorrenti sempre veri e con data, mai deridere chi fa app a pagamento ("anche loro devono vivere; io ho scelto un'altra strada").
Skill: `social`, `content-strategy`, `video`, `copywriting`, `humanizer`.

### Mossa 5 — Community e directory (backlink)
- **AlternativeTo**: ogni app elencata come alternativa al suo originale. Ranka su Google per "X alternative" ed è un backlink. Mezz'ora per app.
- **awesome-lists**: `dkhamsing/open-source-ios-apps` (molto seguita) con una PR per app; `awesome-swiftui`. Backlink forti e pubblico dev.
- **Reddit**, con le regole di ogni sub: r/SideProject, r/iOSProgramming (codice e design system), r/apple e r/iphone solo nei thread dedicati alle app/self-promo, r/ItalyInformatica. Mai lo stesso post in più sub.
- **Hacker News "Show HN"**: una volta sola, per il repo, quando ci sono 8–10 app live. Titolo: "Show HN: I'm remaking top-paid iPhone apps as free, open-source apps, one a week". È il colpo più grosso per stelle e link: va preparato (§9 settimana 9–12).
- **Product Hunt**: un lancio della collezione (non app per app), stesso periodo di HN o subito dopo.
- **Indie Hackers**, **Mastodon** (#iosdev, pubblico privacy).

### Mossa 6 — Stampa
L'aggancio c'è: "un italiano rifà gratis le app più vendute dell'App Store" in Italia; "free, open-source, no-tracking remakes of top-paid apps" negli USA.
- **IT**: iSpazio, iPhoneItalia, Macitynet, HDblog, Tom's Hardware IT, Wired Italia, Il Post (rubrica tech), Corriere Innovazione, podcast come Daily Cogito o Gitbar (dev).
- **US/EN**: 9to5Mac, MacStories, TidBITS, The Verge (Installer), Lifehacker ("free alternative" è il loro genere), iOS Dev Weekly, TLDR.
- Una mail breve, personale, con link alla pagina Stampa. Mai comunicati stampa di massa. Solo quando c'è un fatto: lancio della collezione, 10 app live, Show HN andato bene, primo traguardo di download.
- Pagina Stampa da completare: foto di Matteo, screenshot alta risoluzione scaricabili, storia in 3 paragrafi, contatto diretto.
- Skill: `launch`, `cold-email`.

### Mossa 7 — Strumenti gratuiti sul sito (engineering as marketing)
Il calcolatore "Quanto spendi in abbonamenti" è il prototipo. Strumenti web gratuiti, che girano tutti nel browser senza server, ciascuno collegato alla sua app:
- **Generatore QR** (→ Scanner): "genera QR code gratis" è una delle query più cercate del genere.
- **Calcolatore consumi** (→ Fuel), **fasi lunari di oggi** (→ Moon), **rumore bianco nel browser** (→ Noise).
Ognuno porta traffico di ricerca costante e un "per iPhone c'è l'app".
Skill: `free-tools`.

### Mossa 8 — A pagamento (con un cancello)
Solo **Apple Search Ads**, solo dopo che un'app ha più di 20 recensioni e una pagina alternativa che converte. Test: 100–150 € per un mese, solo sulle keyword di categoria (mai sui marchi altrui), su Subscriptions. Se il costo per installazione resta sotto 1 € e chi installa apre l'app più volte, si continua; se no si chiude. Meta, TikTok e Google Ads: **no**, perché a 0 € di ricavo non si ripagano e non lasciano niente.
Skill: `asc-apple-ads`, `ads`.

### Cosa non facciamo
- Influencer a pagamento: troppo cari, e il pubblico A non ha bisogno di essere convinto, ha bisogno di trovarti.
- Un lancio Product Hunt per ogni app: diluisce. Uno, per la collezione.
- Comunicati stampa via servizi di distribuzione: spam.
- Puntare a "sbu": impossibile, e inutile.

### 90 giorni (dettaglio in §9)
- **Sett. 1–2**: GSC/Bing, `sameAs`, `llms.txt`, handle `sbu.dev`, AlternativeTo per le 2 app live, pagina alternativa Orbit.
- **Sett. 3–4**: primo video + primo post per ogni app approvata; pagine alternativa per le app in review appena escono; PR alle awesome-lists.
- **Sett. 5–8**: ritmo pieno (5 pezzi per uscita); generatore QR; 2 articoli; prima mail stampa IT.
- **Sett. 9–12**: Show HN + Product Hunt collezione; stampa US; valutazione del test Apple Search Ads.

### Giochi (v2)
**Tesi:** sui giochi il canale principale non è Google ma **la ricerca dell'App Store e i video di gameplay**. Chi gioca a un block puzzle non legge HN; guarda TikTok e scrive "block puzzle" nella ricerca. Il messaggio è uno solo: *senza pubblicità*.

**Mossa G1 — ASO per i giochi.** Nome **Sbu Squares** ("quadretti", §13 decisione G2). Sottotitolo IT "Block puzzle senza pubblicità", EN "Block puzzle, no ads, offline". Keyword: block puzzle, blocchi, griglia, offline, senza pubblicità, no ads, rompicapo, logica. Mai "Blast", mai il nome di un altro gioco (vincolo 6). Primo screenshot: la griglia a metà partita con "Nessuna pubblicità. Mai." Secondo: "Niente vite, niente monete, niente attese." Le frasi vengono dalle recensioni a 1 stella dei leader del genere ("troppa pubblicità", "uno spot ogni partita"): la prima riga della descrizione risponde a quelle, "Il block puzzle senza pubblicità, anche in aereo." Skill: `app-store-aso`, `asc-shots-pipeline`.

**Mossa G2 — `sbu.dev/games` come vetrina (aggiornata 18/10).** Niente versione web dei giochi: Matteo vuole i giochi solo come app native, fatti bene. La pagina `/games` elenca i giochi con video, screenshot e link App Store, più la pagina alternativa fattuale per ogni gioco ("Un block puzzle come Block Blast, senza pubblicità"), mai loghi o UI altrui. I link "battimi su questa partita" (§7 G2) atterrano qui e aprono l'app se è installata.

**Mossa G3 — Video di gameplay (#42).** Il format delle app adattato: "Questo gioco ha 2,7 milioni di recensioni e una pubblicità ogni due partite. L'ho rifatto senza." Poi 20 secondi di partita a matita, con il suono delle righe che si cancellano. Variante affiancata: 3 partite dell'originale con il contatore degli spot, 3 partite di Squares, zero. È il format più naturale per TikTok/Reels/Shorts, più delle utility: si guarda anche senza audio. Uno all'uscita, poi uno a settimana per 4 settimane (partite del giorno difficili, record).

**Mossa G4 — Community giochi (#38).** r/iosgaming (post del developer, regole del sub), r/AppHookup (le app gratis senza IAP sono benvenute), r/puzzles per la partita del giorno, forum TouchArcade. Un post per gioco, scritto da Matteo, con "niente pubblicità, niente acquisti, codice aperto".

**Mossa G5 — Stampa giochi.** TouchArcade, Pocket Gamer, 148Apps (EN); Multiplayer.it, Everyeye (IT). Angolo: "un block puzzle senza pubblicità né acquisti, open source, da uno sviluppatore italiano". Bozze di Claude, invio di Matteo, come §4 M6.

**Mossa G6 — Marketing jiu-jitsu sulla pubblicità (#12).** Google Alert su "Block Blast ads", "mobile game ads", "pubblicità giochi". Quando un gioco famoso finisce sotto critica (più pubblicità, raccolta dati, video virali come quello di @ayoships su Block Blast, oltre 10.000 commenti), video e post escono lo stesso giorno: fattuali, mai contro gli sviluppatori. Il nostro argomento è verificabile: codice aperto, la partita del giorno nasce da un seed pubblico.

**Cosa non facciamo sui giochi:** pubblicità a pagamento su Meta/TikTok (il genere vive di UA a pagamento, noi no), influencer pagati, ASA sul marchio di un altro gioco, classifiche online che richiedono un account.

### Software / Sbu Commerce
I dettagli del progetto restano nella copia privata del piano finché il progetto non è annunciato.

---

## 5. Activation

Per sbu.dev "attivarsi" vuol dire: **chi arriva scarica l'app, la apre, vede la cifra e arriva alla prima Chiusura.** Non ci sono iscrizioni né paywall: il percorso è corto, e ogni passaggio che perde gente si vede.

```
Ricerca / video / post → pagina sbu.dev → App Store → installa → primo avvio (SbuEmpty) → prima cifra → prima Chiusura
```

### Oggi
- **Sito → App Store**: badge ufficiale IT/EN. Manca lo **Smart App Banner** (`apple-itunes-app`): su iPhone, chi apre una pagina app di sbu.dev non vede il banner nativo "Apri / Scarica". Su desktop nessun QR.
- **App Store**: screenshot generati con fastlane e Quaderno, coerenti. Nessuna Custom Product Page. Quasi zero recensioni (§3), e senza recensioni la conversione della pagina prodotto crolla.
- **In app**: primo avvio pulito (`SbuEmpty`, nessun permesso anticipato), buono. Nessuna richiesta di recensione, nessun "condividi", nessun "altre app".
- **Misure**: nessuna. Le app non possono avere analytics (regola di prodotto). Resta **App Analytics di App Store Connect**: anonima, di Apple, opt-in da parte dell'utente, già disponibile senza scrivere codice.

### Mossa 1 — Smart App Banner e QR (sito)
- `<meta name="apple-itunes-app" content="app-id=<id>">` su ogni pagina app e alternativa, quando `appStoreId` esiste. Una riga in `AppPage.astro`.
- Su desktop, accanto al badge, un QR della pagina App Store (generato al build, SVG statico, in `ink` su `paper`).
- Link App Store con **`ct=` campaign token** (`?pt=<provider>&ct=alt-orbit`, `ct=tiktok`, `ct=hn`): App Analytics mostra le installazioni per sorgente **senza tracking nell'app**. È l'unico modo pulito per sapere quale canale funziona.

### Mossa 2 — Pagina App Store che converte
- **Primo screenshot = la promessa**: la cifra grande e, sotto, "Gratis. Niente abbonamento, niente account." Chi arriva da "alternativa a Orbit" deve capirlo in un secondo. Le sei promesse restano in fondo alla descrizione (regola 4.3 del 14/10); lo screenshot è un'altra cosa.
- **Custom Product Pages** (gratuite, fino a 35 per app): una per la sorgente principale (es. "chi viene dai video", "chi viene da 'alternativa a'"), con screenshot in ordine diverso. Link dalle pagine alternativa e dai video.
- **Product Page Optimization** (A/B nativo di Apple) sul primo screenshot, quando arrivano almeno qualche centinaio di visite a settimana.
- Skill: `aso`, `asc-shots-pipeline`, `asc-screenshot-resize`, `cro`.

### Mossa 3 — Richiesta di recensione dopo la Chiusura (SbuKit)
Il momento giusto c'è già nel design system: **la Chiusura** (`.sbuClosure`) è il "fatto" della giornata. È lì che l'utente è contento.
- `SbuReviewRequest` in SbuKit: dopo la **terza Chiusura**, in giorni diversi e mai al primo avvio, chiama `requestReview` (SwiftUI `@Environment(\.requestReview)`). Apple mostra la richiesta al massimo 3 volte l'anno e decide lei se mostrarla: nessuno spam possibile.
- Mai una schermata custom "Ti piace l'app?" (vietata dalle linee guida se filtra le recensioni, e brutta).
- In Impostazioni: riga "Scrivi una recensione" → `https://apps.apple.com/app/id<id>?action=write-review`.
- Una modifica a SbuKit = tutte le app. **Il cambiamento con più impatto di tutto il piano rispetto allo sforzo.**
- Skill: `swiftui-pro`, `ios-accessibility`. Test Swift Testing sulla regola "3 Chiusure in 3 giorni diversi".

### Mossa 4 — "Condividi l'app" e "Altre app di sbu.dev" (SbuKit, Impostazioni)
Nel foglio Impostazioni dello shell, una sezione nuova sopra Privacy:
- **Condividi Sbu <Nome>** → `ShareLink` con il link della pagina sbu.dev dell'app (non dell'App Store: così passa per la pagina con le promesse e il banner).
- **Altre app di sbu.dev** → una lista semplice (`List`, nome + una riga + `SbuRowMark`), letta da un JSON incluso nell'app a ogni versione, senza rete. Tocchi una riga e si apre la pagina App Store con `SKOverlay`/`StoreKit`, o Safari su sbu.dev.

Non è pubblicità (sono tue, sono gratis, sono in Impostazioni e non nella schermata principale), ma va detto nella riga privacy: "nessuna rete, la lista è nell'app". Verifica con `appstore-review` prima del primo invio che la contiene.

### Mossa 5 — Prima cifra in meno di 30 secondi
Già quasi vero. Da controllare app per app con un test UI di flusso: dal primo avvio alla prima cifra in non più di 3 tocchi. Dove non è così (es. Subscriptions: aggiungere il primo abbonamento), un **esempio precompilato** che si cancella con un tocco, o un'importazione CSV in evidenza. È la stessa cosa che fa una buona pagina alternativa: "importa da Orbit" vale più di dieci funzioni.

### Mossa 6 — Le pagine alternativa sono pagine di attivazione
Per chi arriva da Google la pagina alternativa è l'onboarding: deve rispondere a "posso portarmi dietro i miei dati?", "cosa perdo?", "è davvero gratis, dov'è la fregatura?". La sezione "Dov'è la fregatura" (risposta: non c'è, il codice è pubblico, ecco perché lo faccio) va su ogni pagina alternativa e sulla home.

### Cosa non facciamo
- Analytics nelle app, neanche "anonime": rompe una promessa. Solo App Analytics di Apple e `ct=`.
- Onboarding a carosello, permessi al primo avvio: già esclusi dal design system.
- Popup "valutaci" custom.

### Decisione aperta (§13)
Analytics sul **sito**: oggi niente. Opzioni: solo GSC (zero cookie, zero script), oppure un contatore cookieless self-hosted (Plausible/Umami sul tuo server) per sapere quali pagine portano ai badge. Raccomandazione: **solo GSC + `ct=` per 90 giorni**, poi si decide.

### Giochi (v2)
- **Si gioca al primo tocco.** All'apertura c'è già la griglia con i primi tre pezzi: niente tutorial a schermate, niente permessi, niente ATT, niente login. La prima riga completata in meno di 30 secondi (stesso obiettivo di §5 M5). Il primo avvio è l'unico in cui una riga di testo spiega il gesto ("Trascina un pezzo sulla griglia").
- **La pagina App Store promette una cosa sola**: "Nessuna pubblicità. Mai." È la frase che il pubblico D cerca e quella che i concorrenti non possono scrivere.
- **Dal sito all'app**: Smart App Banner su `sbu.dev/games/squares` con `ct=games-squares`.
- **Da un gioco alle app**: in Impostazioni, "Altre app di sbu.dev" (§5 M4) mostra prima gli altri giochi, poi le app. Mai durante la partita.

### Software / Sbu Commerce
I dettagli del progetto restano nella copia privata del piano finché il progetto non è annunciato.

---

## 6. Retention

Due retention diverse:
1. **L'app resta sull'iPhone e viene usata.** Questo spinge il ranking App Store (Apple pesa uso e disinstallazioni) e produce recensioni.
2. **Chi ha scoperto sbu.dev segue il progetto.** Questo rende famoso il brand e Matteo, e ogni nuova app parte da un pubblico invece che da zero.

Niente account e niente email nelle app: la retention si fa con il prodotto e con canali che l'utente sceglie da sé.

### Oggi
- **Bene**: widget in 9 app (Clean, Find, Habits + watch, Libretto, Meds, Noise, Remote, Subscriptions, Tidy). App Shortcuts in Noise, Remote, Scanner, Subscriptions. Notifiche solo funzionali. iCloud opzionale. Design familiare tra le app.
- **Fatto dal 17/10**: RSS del blog per lingua, Instagram e Bluesky nel footer e in `sameAs`.
- **Manca**: nessuna risposta alle recensioni. Note di versione non usate come racconto. Nessuna misura della retention.

### Mossa 1 — Il widget è la retention
Un widget sulla Home equivale a un'app che non viene cancellata. Ogni app che ha una cifra da mostrare deve avere il suo `SbuWidgetFigure`, e la pagina App Store deve **farlo vedere**: uno screenshot dedicato "Mettilo sulla Home".
Le app senza widget (Scanner, Speed, Moon, Fuel, Inventory, Grid, Shrink, Chats) vanno valutate una per una: Moon e Fuel ne hanno bisogno, le altre forse no.
Skill: `widgets`.

### Mossa 2 — Siri, Comandi Rapidi, Spotlight
App Intents ovunque abbia senso: "Quanto spendo in abbonamenti?", "Segna l'abitudine". Più superfici di sistema raggiunge un'app, meno viene dimenticata. È anche una **storia da raccontare** (stampa tech e Apple stessa notano le app che usano bene le API nuove).
Skill: `app-intents`.

### Mossa 3 — Aggiornamenti come racconto
- Un aggiornamento vero ogni 4–6 settimane per le app live: l'app compare in "Aggiornamenti", e Apple premia le app mantenute.
- **Note di versione** nella voce sbu.dev: una frase per novità, seconda persona. "Ora puoi importare da CSV." Niente "bug fix e miglioramenti". Skill: `app-store-changelog`, `asc-whats-new-writer`.
- Ogni aggiornamento importante = un post (§4 Mossa 4).

### Mossa 4 — Rispondere a ogni recensione
App Store Connect permette di rispondere. Ogni recensione riceve una risposta di Matteo entro 48 ore, in prima persona, nella lingua della recensione. Le critiche diventano issue (privato) e, quando risolte, "Fatto nella 2.1, grazie". Chi legge le recensioni prima di scaricare vede che dietro c'è una persona: è il vantaggio che le app a pagamento grandi non hanno.
Strumento: `asc` CLI o fastlane per leggere le recensioni ogni lunedì; Claude scrive le bozze.

### Mossa 5 — Seguire sbu.dev (sito)
- **RSS** del blog, `/rss.xml` e `/en/rss.xml`: fatto. Prossimo: un feed "nuove app".
- **Newsletter: no** (decisione del 18/10, #588). L'RSS ne prende il posto; nessuna email raccolta, da nessuna parte.
- Footer e pagina Stampa: Instagram, Bluesky, GitHub, RSS già presenti; gli altri profili quando esistono.

### Mossa 6 — Misurare senza tracciare
App Analytics di App Store Connect (dati di chi ha accettato di condividerli con gli sviluppatori): **sessioni per utente attivo, retention a 1/7/28 giorni, disinstallazioni**. Revisione mensile, una riga per app in §13. Se un'app perde più del 90% degli utenti entro il giorno 7, il problema è il prodotto, non il marketing: si torna alla spec.
Skill: `asc-analytics-reports`.

### Cosa non facciamo
- Notifiche "ci manchi" o promemoria inventati per riportare gente nell'app: rompono la fiducia e il design system.
- Badge, streak finte, gamification fuori dalle app che lo fanno per mestiere (Habits).
- Email raccolte nell'app.

### Giochi (v2)
Un gioco sbu.dev si chiude quando vuoi tu (vincolo 7). La retention deve venire da un motivo onesto per tornare, non da una notifica.
- **Mossa G1 — La partita del giorno (#111).** Una partita a seed fisso, uguale per tutti, una al giorno, alla Wordle. È il motivo per tornare domani senza vite né timer, e il pezzo da condividere (§7). Si calcola sul dispositivo dalla data: nessun server.
- **Mossa G2 — Il record è la figura.** `SbuFigure` mostra il punteggio; il record personale sta in `inkMuted`. La fine partita è la Chiusura ("Chiusa" + punto fermo) solo quando batti il record, mai a ogni partita.
- **Mossa G3 — Widget.** `SbuWidgetFigure` con il record o "Partita del giorno: da giocare". È l'unico promemoria, e lo sceglie l'utente.
- **Mossa G4 — La partita resta dove l'hai lasciata.** Stato salvato a ogni mossa: chiudere l'app non costa niente.
- **Recensioni**: richiesta dopo il terzo record battuto, in giorni diversi (stessa regola di `SbuReviewRequest`).
**Cosa non facciamo:** notifiche push, streak che si perdono, Game Center al lancio (§13 decisione G3), monete o sblocchi.

### Software / Sbu Commerce
I dettagli del progetto restano nella copia privata del piano finché il progetto non è annunciato.

---

## 7. Referral

Niente programmi di affiliazione o premi: non c'è niente da regalare e non ci deve essere. Il passaparola di sbu.dev nasce da tre cose: **una cifra che vale la pena mostrare**, **una lista condivisa che ha bisogno dell'app**, **un progetto aperto a cui si può partecipare**.

### Oggi
- Condivisione di contenuti in alcune app (Scanner condivide codici, Habits/Fuel/Grid esportano, Meds condivide un report).
- Liste condivise via iCloud in Subscriptions (ADR-0009): chi riceve una lista ha bisogno dell'app. È già un piccolo loop virale.
- Nessuna immagine condivisibile della cifra. Nessun "condividi l'app" (si aggiunge in §5 Mossa 4). Repo senza Discussions né guida per contribuire.

### Mossa 1 — La cifra da condividere (idea #87, "powered by")
Ogni app ha **una cifra** (`SbuFigure`): "544,34 € all'anno", "42 giorni di fila", "3,2 GB liberati". È esattamente il tipo di numero che la gente posta.
- In SbuKit: `SbuFigureCard`, un'immagine 1080×1350 renderizzata con `ImageRenderer`: la cifra su carta quadrettata, la parola, il punto fermo nel colore dell'app, in basso piccolo `Sbu <Nome> · sbu.dev`. Si apre dal `ShareLink` accanto alla cifra, solo quando l'utente lo tocca.
- Mai dati personali oltre la cifra stessa; l'utente vede l'immagine prima di condividerla.
- Le app candidate: Subscriptions ("Spendo X € l'anno in abbonamenti"), Habits (giorni di fila), Clean (spazio liberato), Chats (è già un "wrapped"), Fuel (consumo medio).
- È il passaparola più forte per il pubblico A: arriva su Instagram Stories e WhatsApp, dove nessun annuncio arriva.
- Regola di design: è un `.set` per immagine, rispetta Quaderno, nessun colore in più.
Skill: `swiftui-pro`, `referrals`.

### Mossa 2 — Liste condivise come porta d'ingresso
In Subscriptions chi riceve una lista vede l'invito di Apple; se non ha l'app, finisce sull'App Store. Due ritocchi:
- Il testo dell'invito spiega in una riga cos'è l'app e che è gratis.
- La pagina sbu.dev dell'app ha una sezione "Ti hanno condiviso una lista?".
Valutare la stessa condivisione per Inventory, Tidy (casa condivisa, una lista di faccende) e Habits (abitudini di coppia), solo dove serve davvero all'utente.

### Mossa 3 — Il progetto aperto
Per il pubblico C il passaparola è **partecipare**.
- **GitHub Discussions** sul repo pubblico (gli issue restano chiusi, ma una sezione "Idee" e "Mostra" costa zero): "Quale app a pagamento dovrei rifare dopo?". Il voto pubblico è contenuto, e chi vota torna a vedere l'app uscire.
- **Traduzioni**: `Localizable.xcstrings` si presta. Una guida `CONTRIBUTING.md` per aggiungere una lingua. Ogni nuova lingua è nuovo pubblico (§17 della rubrica), e chi traduce la condivide nel suo paese.
- **README** con screenshot, link alle app, le sei promesse, "Come è fatta" (la fabbrica, il design system). È la pagina che i dev condividono.
- Topic GitHub: `ios`, `swiftui`, `open-source-app`, `privacy`, `no-tracking`, `free-alternative`.

### Mossa 4 — La storia che si racconta da sola
"Conosci quello che rifà gratis le app a pagamento?" è una frase che passa di bocca in bocca solo se è **semplice e verificabile**. Per questo:
- Un contatore pubblico in home: "17 app, 0 € spesi da chi le usa, X € risparmiati" (stima dichiarata: prezzo annuo dell'originale × download, senza dati personali; si può fare solo con i download aggregati di App Store Connect, aggiornati a mano ogni mese).
- Una pagina `/principi` già esistente: tenerla corta, citabile.

### Cosa non facciamo
- Codici invito, premi, "invita 3 amici": niente da dare, e sembrerebbe un paywall al contrario.
- Watermark su contenuti dell'utente (codici QR generati, PDF, foto): mai. Il marchio va solo sull'immagine della cifra, che è dell'app.
- Ambassador/affiliate: non applicabile.

### Giochi (v2)
- **Mossa G1 — Il risultato da condividere (#93, #87).** Dopo la partita del giorno, "Condividi" produce un testo, non un'immagine: una piccola griglia di ■ e □, il punteggio e `sbu.dev/games`. Funziona in WhatsApp e nei messaggi, è il meccanismo che ha reso Wordle virale, e non richiede account né server.
- **Mossa G2 — "Battimi su questa partita".** Il link porta il seed della partita (`sbu.dev/games/squares?p=…`): con l'app installata la apre sulla stessa partita (universal link, nessuna chiamata di rete), altrimenti mostra la pagina con il link App Store. Sfida tra amici senza classifica online.
- **Mossa G3 — I giochi portano alle app.** Il pubblico D è il più grande; "Altre app di sbu.dev" in Impostazioni è il ponte (§5).

### Software / Sbu Commerce
I dettagli del progetto restano nella copia privata del piano finché il progetto non è annunciato.

---

## 8. Revenue

Le app sono gratis per scelta e le sei promesse non si toccano: **nessun acquisto in-app, nemmeno una "mancia"**. Questa sezione quindi non parla di prezzi delle app: parla di come il progetto copre i costi e di come la notorietà diventa valore per Matteo, senza che nessuna app cambi.

### Costi oggi
| Voce | Costo |
|---|---|
| Apple Developer Program | 99 €/anno |
| Hosting sbu.dev | già pagato (server proprio) |
| Claude / API (sviluppo, spec, testi) | abbonamento esistente di Matteo |
| Gemini (incisioni delle icone) | a consumo, basso |
| Opzionale piano: Apple Search Ads test | 100–150 € una tantum (§4 Mossa 8) |

Il progetto costa meno di 20 €/mese. **Non ha bisogno di ricavi per esistere**, e questo è parte della storia: va detto (pagina Principi, "Dov'è la fregatura?").

### Cosa è possibile senza rompere promesse
1. **GitHub Sponsors: non per ora** (decisione del 18/10, #589). Nessun link "Sostieni" sul sito né nelle app. Non si ripropone finché Matteo non lo chiede.
2. **La notorietà di Matteo** è il ricavo vero, indiretto:
   - lavoro e consulenze iOS/SwiftUI (il repo è un portfolio pubblico eccezionale);
   - talk a conferenze (Pragma Conf, Swift Heroes in Italia; iOSDevUK, NSSpain) e podcast;
   - più avanti: un corso o una guida "Come faccio un'app a settimana" (pubblico C), venduta sul sito, mai collegata alle app.
3. **Sponsor del contenuto, non delle app**: un canale YouTube con pubblico sufficiente può avere uno sponsor dichiarato. Solo strumenti per sviluppatori coerenti con i principi. Non prima di 12 mesi.

### Cosa non facciamo
- Mancia via acquisto in-app, "versione Pro", sblocchi: escluso dalle promesse.
- Pubblicità nelle app o sul sito.
- Vendere o "aggregare" dati: non esistono.
- Affiliazioni con le app originali o con servizi negli abbonamenti tracciati.

### Decisione chiusa
GitHub Sponsors: no, per ora (#589, 18/10).

### Giochi (v2)
Invariata: **zero ricavi**, anche sui giochi. Niente pubblicità, niente acquisti, niente "rimuovi le pubblicità" a 0,99 $ come fanno i concorrenti ad-free. Nessun canale di donazione (#589). Il costo in più è solo il tempo di Matteo (§10).

### Software / Sbu Commerce
I dettagli del progetto restano nella copia privata del piano finché il progetto non è annunciato.

---

## 9. 90-day roadmap

Dal **19 ottobre 2026 al 10 gennaio 2027**. Owner: **M** = Matteo, **C** = Claude (bozze, codice, testi; Matteo rivede e pubblica). Tag: Acq, Act, Ret, Ref, Rev.
Tempo di Matteo: **5–10 h/settimana** di marketing, oltre allo sviluppo. Il codice SbuKit resta in locale finché Matteo non lo rivede (nessun push senza review).

### Il ritmo fisso (da settimana 3, ogni settimana)
| Giorno | Cosa | Owner | Tag |
|---|---|---|---|
| Lunedì | Recensioni App Store: leggere, bozze di risposta, rispondere | C → M | Ret |
| Uscita app (quando Apple approva) | Pagina alternativa IT/EN online, AlternativeTo, PR awesome-list | C → M | Acq |
| Stesso giorno | Video 30–45 s (TikTok, Reels, Shorts) | M (C scrive la traccia) | Acq |
| Stesso giorno | Post X + LinkedIn | C → M | Acq |
| Venerdì | 15 minuti di GSC: query nuove, pagine che salgono | M | Acq |

---

### Settimane 1–2 · Sbloccare (19 ott – 1 nov)
| # | Cosa | Owner | Tag | Fatto quando |
|---|---|---|---|---|
| 1 | Google Search Console + Bing Webmaster via DNS, sitemap inviata, indicizzazione richiesta per home + 2 app live | M | Acq | **Fatto 17/10** (#558); indicizzazione delle pagine nuove aperta (#575) |
| 2 | Handle `sbudevapp` su X, TikTok, Instagram, YouTube, LinkedIn page (bio in `marketing/social/bio.md`) | M | Acq | **In parte**: Instagram @sbudevapp, Bluesky @sbu.dev; gli altri da prendere |
| 3 | `Organization` + `Person` JSON-LD con `sameAs`, `llms.txt`, link social nel footer | C | Acq | **Fatto 17/10** |
| 4 | Smart App Banner + `ct=` su ogni link App Store | C | Act | **Fatto 17/10** (`pt=128487151`) |
| 5 | `SbuReviewRequest` (3 Chiusure, giorni diversi) + "Scrivi una recensione" + "Condividi" in Impostazioni (SbuKit, locale, test) | C → M review | Act/Ref | **Fatto, su main**; arriva agli utenti con la prossima versione di ogni app |
| 6 | Pagina alternativa **Orbit** (Subscriptions) e **QR Reader** (Scanner), IT/EN | C → M | Acq | **Fatto**; scritte anche Find Air, Cleanup, My Moon Phase Pro, Streaks |
| 7 | AlternativeTo per Subscriptions e Scanner | M | Acq | **Inviato**, in moderazione |
| 8 | README del repo con screenshot e link; topic GitHub | C → M | Ref | **Fatto** (9 topic) |
| 9 | Pagina Stampa: foto, storia in 3 paragrafi, screenshot HD, contatto | C + M (foto) | Acq | **Fatto** (ritratto, #574) |
| 9b | **Lancio di Find** il giorno dell'approvazione: checklist `marketing/find/lancio.md`; Show HN il giorno 1 (uno per app, #590), Reddit, LinkedIn/X, stampa, PR di follow-up a open-source-ios-apps | M (C prepara) | Acq | Giorno 0–7 chiusi |
| 9c | Il 21/10, se Apple tace: follow-up 4.3 su Habits nello stesso thread | M | — | Inviato o deciso di no |

### Settimane 3–4 · Fondamenta (2 – 15 nov)
| # | Cosa | Owner | Tag |
|---|---|---|---|
| 10 | Primo video: quello di Find (`marketing/find/video.md`), poi "Orbit costa X € l'anno. L'ho rifatta gratis.". Test del format | M | Acq |
| 11 | Primo articolo blog: "Apple mi ha rifiutato 6 app in un giorno" (bozza IT già scritta, `draft: true`; EN da fare; uscita dopo la risposta di Apple) + post LinkedIn + X thread | C → M | Acq |
| 12 | Pagine alternativa già scritte (Find Air, Cleanup, My Moon Phase Pro, Streaks) online **appena l'app è approvata**; da scrivere per Noise | C | Acq |
| 13 | PR a `dkhamsing/open-source-ios-apps`: **aperto** (#2442, Subscriptions e Scanner); Find e le successive in un PR di follow-up | C → M | Acq |
| 14 | Subscriptions 2.1 (review request, screenshot nuovi) inviato dal 24/10 dopo il test insieme; è un aggiornamento, non occupa lo slot | M | Act |
| 15 | App Store: primo screenshot "Gratis. Niente abbonamento, niente account." sulle app live | C | Act |

### Settimane 5–8 · Velocità (16 nov – 13 dic)
| # | Cosa | Owner | Tag |
|---|---|---|---|
| 16 | Ritmo fisso pieno: ogni app approvata = 5 pezzi | M + C | Acq |
| 17 | **Generatore QR** gratuito su sbu.dev (client-side) → Scanner: **fatto** (`/qr-code`, `ct=tool-qr`) | C → M | Acq |
| 18 | `SbuFigureCard` (immagine della cifra da condividere) in Subscriptions e Habits: **fatto, su main** (#579) | C → M review | Ref |
| 19 | Secondo articolo: "Una app a settimana: il sistema" (pubblico dev) | C → M | Acq |
| 20 | Calcolatore abbonamenti e hub `/alternatives` **fatti**; resta l'hub "App iPhone gratis senza abbonamento" | C | Acq |
| 21 | Prima mail stampa IT (iSpazio, iPhoneItalia, Macitynet, HDblog, Wired): 5 mail personali | C bozze → M invia | Acq |
| 22 | GitHub Discussions aperte: "Quale app rifaccio dopo?" | M | Ref |
| 24 | Preparazione Show HN e Product Hunt: titolo, primo commento, galleria, hunter | C → M | Acq |

### Settimane 9–12 · Accumulo (14 dic – 10 gen)
| # | Cosa | Owner | Tag |
|---|---|---|---|
| 25 | **Show HN della collezione** martedì 15 dic, ore 15–16 italiane. Solo se ≥ 8 app live; altrimenti martedì 12 gen. Si somma agli Show HN per app (#590), mai nella stessa settimana di un altro | M | Acq |
| 26 | **Product Hunt** della collezione il giorno dopo HN (o la settimana dopo) | M | Acq |
| 27 | Mail stampa EN (9to5Mac, MacStories, Lifehacker, iOS Dev Weekly) con i numeri di HN | C → M | Acq |
| 29 | Articolo di fine anno: "2026: X app gratis, Y download, Z € risparmiati" (idea year-wrap) | C → M | Acq/Ref |
| 30 | Revisione 90 giorni: metriche §13, cosa tenere, cosa chiudere; decidere il test Apple Search Ads | M + C | — |

Settimane 10–11 cadono a Natale: niente lanci, solo ritmo fisso e articolo di fine anno.

### Cosa deve essere vero il 10 gennaio
- GSC: sbu.dev e ogni "Sbu <Nome>" al primo posto per la ricerca del proprio nome.
- Almeno 8 pagine alternativa indicizzate, almeno 3 in prima pagina per la loro query.
- Almeno 20 recensioni sulle app live più vecchie.
- Show HN fatto, Product Hunt fatto, almeno 2 articoli di stampa.
- 12 video pubblicati, un format che si sa se funziona o no.

### Giochi (v2) — un gioco al mese, in aggiunta alle app
| # | Cosa | Settimane | Owner | Tag | Fatto quando |
|---|---|---|---|---|---|
| G1 | **ADR giochi**: "una meccanica per gioco", punteggio come `SbuFigure`, niente dark pattern, cella `.set` (§2 vincoli 6–7) | 3 (2–8 nov) | C → M | — | **Fatto 18/10** (ADR-0015) |
| G2 | **Squares su main** (una partita senza fine come l'originale, record nel cartiglio), installato sul tuo iPhone; playtest con 3 persone | 3–5 | C → M | Act | **Gioco fatto**; playtest con altre persone da fare |
| G3 | Prova completa, screenshot Store, record ASC, TestFlight | 1–7 | C → M review | — | Test verdi, prova sul dispositivo con Matteo |
| G4 | `originality-check` + `release-review` + `appstore-review`, metadati e screenshot (§4 G1) | 7 | C → M | Acq | Punteggio di originalità ok |
| G5 | **Invio ad Apple** (in aggiunta al submit settimanale delle app) | 8 (circa 10 dic) | M | — | In review |
| G6 | All'approvazione: `sbu.dev/games` (vetrina) + pagina alternativa, video gameplay, r/iosgaming + r/AppHookup, mail TouchArcade/Pocket Gamer | 9–10 | C → M | Acq | Online |
| G7 | Secondo gioco: scelta (§10) e prototipo iOS | 11–12 | C → M | — | Prototipo giocabile su TestFlight interno |

Natale (sett. 10–11) è il periodo più giocato dell'anno: se l'approvazione arriva prima del 20 dic, il video di gameplay esce comunque.

### Software / Sbu Commerce
I dettagli del progetto restano nella copia privata del piano finché il progetto non è annunciato.

---

## 10. 12-month outlook

Ottobre 2026 → ottobre 2027. Non ci sono round di finanziamento: i "cancelli" che aprono capacità nuove sono **segnali** (un canale che funziona) e **tempo di Matteo**, non soldi raccolti.

### La forma della crescita
Non una curva a bastone da hockey. Per un progetto così è una scala:
- **lineare** tra un gradino e l'altro: +1 app a settimana, +1 pagina alternativa, +1 video. Il traffico SEO cresce lento e costante;
- **a gradini**: Show HN, un articolo su 9to5Mac, un video che esplode, WWDC. Ogni gradino porta un picco; la parte lineare decide quanto di quel picco resta.

Le curve a S da mettere una sopra l'altra, iniziando la seconda prima che la prima si fermi:
1. **Canale**: SEO alternativa (Q1–Q2) → video founder (Q1–Q3) → stampa e conferenze (Q2–Q4).
2. **Prodotto**: le app nuove ogni settimana, poi gli aggiornamenti di quelle forti.
3. **Mercato**: IT + EN → spagnolo, tedesco, francese, portoghese (BR) con contributori (Q3–Q4).

### Trimestri
| Trimestre | Tema | Traguardi | Cancello per il trimestre dopo |
|---|---|---|---|
| **Q1** · ott–gen | Esistere | §9: brand indicizzato (GSC attivo dal 17/10), Find e le app in coda sullo Store, 8+ pagine alternativa, review request in tutte le app, Show HN + PH, 2 articoli stampa | GSC mostra impressioni in crescita settimana su settimana |
| **Q2** · gen–apr | Accumulare | 15+ app live, 15+ pagine alternativa, 3 strumenti web gratuiti, 1 talk accettato (Pragma Conf / Swift Heroes CFP), test Apple Search Ads (100–150 €) se il cancello §4 è aperto | Almeno una pagina alternativa porta installazioni misurabili (`ct=`) |
| **Q3** · apr–lug | WWDC | Adottare in 2 settimane le API nuove di iOS 27 nelle app con più utenti → articolo + video "pronte il giorno uno"; candidatura Apple Design Award / "App of the Day" tramite il modulo Apple per gli sviluppatori; prime 2 lingue nuove dai contributori | Un video o un articolo oltre 50.000 visualizzazioni, o 1.000 stelle GitHub |
| **Q4** · lug–ott | Un anno | "Un anno, 40 app" (articolo, video, stampa IT+EN); talk in conferenza; seconda ondata stampa internazionale; decisione su YouTube lungo (racconto mensile) | Piano v2 |

### Quando spendere (se "dipende" diventa sì)
| Segnale | Cosa si sblocca | Costo indicativo |
|---|---|---|
| Un'app con 20+ recensioni e una pagina alternativa che converte | Test Apple Search Ads su keyword di categoria | 100–150 € una tantum |
| Il test ASA sotto 1 € per installazione con uso ripetuto | ASA continuo sulle 3 app migliori | 100–300 €/mese |
| Video che funzionano ma montaggio che ruba ore | Un montatore freelance per i corti | 15–30 € a video |
| Traffico stampa in arrivo da paesi senza lingua | Traduzione professionale delle pagine top in 1 lingua | 200–400 € una tantum |
| Talk accettato | Viaggio conferenza | variabile |

Mai: agenzie, retainer, ads su Meta/Google/TikTok (§4).

### Numeri: ipotesi, da correggere con i dati
Non c'è ancora una base (GSC attivo dal 17/10, senza dati utili). Ipotesi di lavoro, da sostituire a fine Q1:
- clic organici sul sito: da ~0 a 2.000–5.000/mese a fine anno, quasi tutti dalle pagine alternativa;
- stelle GitHub: 500–2.000 dopo Show HN se va in prima pagina, altrimenti 100–300;
- download: dipendono più da ASO e recensioni che da tutto il resto. Il primo obiettivo misurabile è **raddoppiare trimestre su trimestre** i download totali da App Store Connect.

### Giochi (v2)
Un gioco al mese da dicembre: **10 giochi a ottobre 2027**. Ordine proposto, dai più giocati e più adatti alla griglia Quaderno (dati §research, 18/10):
| Ordine | Nome (significato): genere | Riferimento in classifica (valutazioni US) | Perché |
|---|---|---|---|
| 1 | **Sbu Squares** ("quadretti"): block puzzle | Block Blast 2,76 M | Il più grande, griglia pura |
| 2 | **Sbu Tiles** ("tessere"): mahjong solitario | Vita Mahjong 1,78 M | Pubblico senior, il più colpito dalle pubblicità |
| 3 | **Sbu Sudoku**: sudoku | Sudoku.com 1,86 M | Ad-free solo a pagamento oggi |
| 4 | **Sbu Arrows** ("frecce"): frecce da far uscire | Arrows 498 k, Amaze GO! 236 k | Minimalista, si fa in inchiostro |
| 5 | **Sbu Sort** ("ordina"): ordinare per segno | Magic Sort 689 k | Rifatto con forme, non colori |
| 6 | **Sbu Solitaire** ("solitario"): solitario a carte | Disney Solitaire (top 15 US) | Classico, nessuna IP |
| 7 | **Sbu Words** ("parole"): parole IT/EN | Word Tiles | Lingua come vantaggio italiano |
| 8–10 | Dalle classifiche del momento | `discover.py` sui top free | Meowdoku (maggio 2026, già #1) mostra che un genere nuovo sale in settimane |

**Cancelli:** se Squares fa più download delle app entro 60 giorni, i giochi passano a 2 al mese e le app restano a 1 a settimana solo finché c'è tempo; se un gioco riceve un 4.3, ci si ferma, si fa appello e si rivede l'ADR prima del gioco successivo. Q1 1 gioco, Q2 4, Q3 7, Q4 10.

### Software / Sbu Commerce
I dettagli del progetto restano nella copia privata del piano finché il progetto non è annunciato.

---

## 11. Marketing operations stack

Una persona + Claude + skill + qualche integrazione fanno il lavoro di un piccolo team. Questa è la mappa di **chi esegue cosa**. Regola: Claude scrive bozze e codice; Matteo rivede, ci mette la faccia, preme invio. Niente parte senza di lui.

### Per fase AARRR
| Fase | Mossa | Skill | Strumenti / integrazioni |
|---|---|---|---|
| **Acq** · SEO | Pagine alternativa, hub, schema, audit | `competitors`, `programmatic-seo` (template), `schema`, `seo-audit`, `site-architecture`, `copywriting` | Astro (`Site/`), Google Search Console, Bing Webmaster, Rich Results Test, PageSpeed Insights |
| **Acq** · AI search | `llms.txt`, pagina "Cos'è sbu.dev", citabilità | `ai-seo` | ChatGPT / Perplexity per verificare cosa rispondono |
| **Acq** · ASO | Keyword, sottotitoli, screenshot, Custom Product Pages | `aso`, `app-store-aso`, `asc-aso-audit`, `asc-metadata-sync`, `asc-localize-metadata`, `asc-shots-pipeline`, `asc-screenshot-resize` | fastlane, `asc` CLI, App Store Connect |
| **Acq** · founder | Video, post X/LinkedIn, articoli | `social`, `content-strategy`, `video`, `copywriting`, `humanizer`, `copy-editing` | Telefono di Matteo, CapCut/Final Cut; `nano-banana` per immagini di copertina; `Tools/make_og.py` per le anteprime |
| **Acq** · ricerca trend | Cosa si dice degli abbonamenti, di Orbit, di Streaks; thread Reddit dove rispondere | `last30days`, `customer-research` | Reddit, X, HN (via last30days) |
| **Acq** · community | AlternativeTo, awesome-lists, Reddit, Show HN, Product Hunt | `community-marketing`, `launch`, `directory-submissions` | `gh` (PR alle awesome-lists), browser |
| **Acq** · stampa | Mail personali, pagina Stampa | `launch`, `cold-email` | Gmail MCP (**bozze** con `create_draft`, Matteo invia) |
| **Acq** · strumenti web | Generatore QR, calcolatori | `free-tools`, `frontend-design` | Astro, JS client-side |
| **Acq** · paid (con cancello) | Apple Search Ads test | `asc-apple-ads`, `ads` | Apple Search Ads Basic/Advanced |
| **Act** | Smart Banner, `ct=`, primo screenshot, CPP, prima cifra in 3 tocchi | `cro`, `onboarding`, `swiftui-pro`, `ios-accessibility` | App Analytics (ASC), XCUITest di flusso |
| **Act** | `SbuReviewRequest`, Condividi, Altre app | `swiftui-pro`, `swift-testing-pro`, `appstore-review` | Xcode, SbuKit, simulatore (`ios-simulator-skill`) |
| **Ret** | Risposte alle recensioni | `writing-for-interfaces` (tono), `humanizer` | `asc` CLI (lettura recensioni), App Store Connect |
| **Ret** | Note di versione | `app-store-changelog`, `asc-whats-new-writer` | fastlane `release` |
| **Ret** | Widget, App Intents | `widgets`, `app-intents` | Xcode |
| **Ret** | RSS (fatto; niente newsletter, #588) | — | `@astrojs/rss` |
| **Ret** | Retention 1/7/28, disinstallazioni | `asc-analytics-reports` | App Store Connect Analytics |
| **Ref** | `SbuFigureCard`, liste condivise | `referrals`, `swiftui-pro` | `ImageRenderer`, CloudKit sharing (ADR-0009) |
| **Ref** | README, Discussions, CONTRIBUTING | `documentation` | `gh` |
| **Trasversale** | Calendario del ritmo fisso | `schedule` / `loop` (promemoria) | Google Calendar MCP (eventi ricorrenti: lunedì recensioni, venerdì GSC) |
| **Trasversale** | Controllo marchi altrui e 4.3 prima di ogni invio | `originality-check`, `release-review`, `appstore-review` | — |
| **Trasversale** | Voce sbu.dev in ogni testo pubblico | `humanizer`, `antislop-copywriting` | CLAUDE.md (regole di voce) |

### Cosa manca e si aggiunge solo se serve
| Lacuna | Quando | Soluzione |
|---|---|---|
| Nessun accesso di Claude ai dati GSC | Da settimana 3 | Export CSV settimanale nella cartella `materials/` del piano, oppure un MCP per Search Console se Matteo lo vuole collegare |
| Nessun dato di parole chiave (volumi) | Settimana 1–2 | Gratis: Google Keyword Planner + suggerimenti App Store; a pagamento (non ora): Ahrefs / AppFigures |
| Montaggio video | Se supera 1 h a video | Freelance (§10) |
| Notion non autenticato | Solo se Matteo vuole il piano lì | Notion MCP (`authenticate`) |

### Capacità per livello di investimento
| Livello | Cosa si può fare |
|---|---|
| **0 €/mese (ora)** | Tutto §9: SEO, ASO, video, community, stampa, codice SbuKit |
| **~100–150 € una tantum** | Test Apple Search Ads |
| **~100–300 €/mese** | ASA continuo + montatore video |
| **Oltre** | Non previsto in questo piano |

### Giochi (v2)
| Fase | Mossa | Skill | Strumenti |
|---|---|---|---|
| Prima dell'invio | Originalità in un genere saturo | `originality-check`, `appstore-review`, `release-review` | `Tools/discover.py` (classifiche top free: aggiungere l'URL RSS per genere 6014/7012) |
| Acq | ASO giochi, screenshot | `app-store-aso`, `aso`, `asc-shots-pipeline` | ASC |
| Acq | Vetrina `/games` | `frontend-design` | Astro |
| Acq | Video gameplay | `video`, `social` | Registrazione schermo del simulatore |
| Act/Ret | Partita del giorno, widget | `swiftui-pro`, `widgets`, `swift-testing-pro` | SbuKit |
| Ref | Testo da condividere | `writing-for-interfaces` | `ShareLink` |

### Software / Sbu Commerce
I dettagli del progetto restano nella copia privata del piano finché il progetto non è annunciato.

---

## 12. Tactical idea bank

Le 139 idee di `marketing-ideas`, ognuna con fase AARRR e stato per sbu.dev.
**Legenda**: **Ora** = nei 90 giorni (§9) · **Q2** = gen–apr · **Q3+** = da apr · **Q4+** = da lug · **Skip** = non la facciamo, con il motivo.

Totale: Ora 33 · Q2 20 · Q3+ 10 · Q4+ 3 · Skip 73.

Il gran numero di Skip è voluto: niente ads tranne ASA, niente email in app, niente regali o affiliazioni. Le promesse escludono metà del manuale classico, e questo è un vantaggio di messaggio.

| # | Idea | Fase | Stato | Per sbu.dev |
|---|---|---|---|---|
| 1 | Easy Keyword Ranking | Acq | Ora | Query "alternativa gratis a X": coda lunga, poca concorrenza (§4 M1) |
| 2 | SEO Audit | Acq | Ora | Audit fatto in INIT; ripetere a gen |
| 3 | Glossary Marketing | Acq | Skip | Nessun gergo da spiegare |
| 4 | Programmatic SEO | Acq | Q2 | Solo il template delle pagine alternativa; testi scritti a mano |
| 5 | Content Repurposing | Acq | Ora | Ogni uscita = 5 pezzi (§4) |
| 6 | Proprietary Data Content | Acq | Q2 | Prezzi degli abbonamenti iPhone nel tempo, da discover.py (dati pubblici) |
| 7 | Internal Linking | Acq | Ora | Hub categoria → pagine alternativa → pagine app |
| 8 | Content Refreshing | Acq | Q2 | Prezzi dei concorrenti aggiornati ogni trimestre, con data |
| 9 | Knowledge Base SEO | Acq | Q3+ | Pagina Supporto con domande per app |
| 10 | Parasite SEO | Acq | Ora | LinkedIn articles, dev.to, Medium per i post dev, con link |
| 11 | Competitor Comparison Pages | Acq | Ora | La leva principale (§4 M1) |
| 12 | Marketing Jiu-Jitsu | Acq | Ora | Quando un'app famosa alza il prezzo: post + video il giorno stesso |
| 13 | Competitive Ad Research | Acq | Skip | Nessuna campagna da preparare |
| 14 | Side Projects | Acq | Q2 | Strumenti web (§4 M7) |
| 15 | Engineering as Marketing | Acq | Ora | Generatore QR (§9 #17) |
| 16 | Importers as Marketing | Act | Q2 | "Importa da Orbit/Streaks" via CSV dove l'originale esporta |
| 17 | Quiz Marketing | Acq | Skip | Fuori voce |
| 18 | Calculator Marketing | Acq | Ora | Calcolatore abbonamenti esiste; consumi in Q2 |
| 19 | Chrome Extensions | Acq | Skip | Il progetto è iPhone |
| 20 | Microsites | Acq | Skip | Tutto su sbu.dev: concentra l'autorità |
| 21 | Scanners | Acq | Skip | Non pertinente |
| 22 | Public APIs | Acq | Skip | Nessun server, per scelta |
| 23 | Podcast Advertising | Acq | Skip | Nessun ricavo che lo ripaghi |
| 24 | Pre-targeting Ads | Acq | Skip | — |
| 25 | Facebook Ads | Acq | Skip | §4: no Meta |
| 26 | Instagram Ads | Acq | Skip | §4: no Meta |
| 27 | Twitter Ads | Acq | Skip | — |
| 28 | LinkedIn Ads | Acq | Skip | — |
| 29 | Reddit Ads | Acq | Skip | — |
| 30 | Quora Ads | Acq | Skip | — |
| 31 | Google Ads | Acq | Skip | §4: solo Apple Search Ads |
| 32 | YouTube Ads | Acq | Skip | — |
| 33 | Cross-Platform Retargeting | Acq | Skip | Richiede tracking: rompe le promesse |
| 34 | Click-to-Messenger Ads | Acq | Skip | — |
| 35 | Community Marketing | Ref | Q2 | GitHub Discussions, non un Discord da moderare |
| 36 | Quora Marketing | Acq | Skip | Pubblico poco presente |
| 37 | Reddit Keyword Research | Acq | Ora | last30days su abbonamenti, Orbit, Streaks: parole vere per le pagine |
| 38 | Reddit Marketing | Acq | Ora | Secondo le regole dei sub (§4 M5) |
| 39 | LinkedIn Audience | Acq | Ora | Un post lungo a settimana in italiano |
| 40 | Instagram Audience | Acq | Ora | Reels dello stesso video |
| 41 | X Audience | Acq | Ora | Build in public 3–5 a settimana |
| 42 | Short Form Video | Acq | Ora | Il format "costa X, l'ho rifatta gratis" |
| 43 | Engagement Pods | Acq | Skip | Finto |
| 44 | Comment Marketing | Acq | Ora | Risposte utili nei thread "app gratis senza abbonamento" |
| 45 | Mistake Email Marketing | Ret | Skip | Nessuna lista email in app |
| 46 | Reactivation Emails | Ret | Skip | Nessuna email |
| 47 | Founder Welcome Email | Ret | Skip | Niente newsletter (#588) |
| 48 | Dynamic Email Capture | Acq | Skip | Popup: fuori voce |
| 49 | Monthly Newsletters | Ret | Skip | Niente newsletter, solo RSS (#588) |
| 50 | Inbox Placement | Ret | Skip | Nessuna email inviata (#588) |
| 51 | Onboarding Emails | Act | Skip | Nessun account |
| 52 | Win-back Emails | Ret | Skip | Nessun account |
| 53 | Trial Reactivation | Rev | Skip | Nessun trial |
| 54 | Affiliate Discovery | Ref | Skip | Nessun programma affiliati |
| 55 | Influencer Whitelisting | Acq | Skip | — |
| 56 | Reseller Programs | Rev | Skip | — |
| 57 | Expert Networks | Ref | Skip | — |
| 58 | Newsletter Swaps | Acq | Skip | Niente newsletter (#588) |
| 59 | Article Quotes | Acq | Q2 | Rispondere a giornalisti su abbonamenti/privacy app |
| 60 | Pixel Sharing | Acq | Skip | Tracking |
| 61 | Shared Slack Channels | Ref | Skip | — |
| 62 | Affiliate Program | Ref | Skip | Niente da pagare |
| 63 | Integration Marketing | Acq | Q3+ | Apple come "partner": Shortcuts gallery, App of the Day |
| 64 | Community Sponsorship | Acq | Skip | Budget |
| 65 | Live Webinars | Acq | Skip | Formato sbagliato |
| 66 | Virtual Summits | Acq | Skip | — |
| 67 | Roadshows | Acq | Skip | — |
| 68 | Local Meetups | Acq | Q2 | CocoaHeads / meetup Swift in Italia: un talk breve |
| 69 | Meetup Sponsorship | Acq | Skip | Budget |
| 70 | Conference Speaking | Acq | Q2 | Pragma Conf, Swift Heroes (§10) |
| 71 | Conferences | Acq | Skip | — |
| 72 | Conference Sponsorship | Acq | Skip | — |
| 73 | Media Acquisitions | Acq | Skip | — |
| 74 | Press Coverage | Acq | Ora | §4 M6, mail personali |
| 75 | Fundraising PR | Acq | Skip | Nessun round |
| 76 | Documentaries | Acq | Q4+ | Forse "un anno, 40 app" in video lungo |
| 77 | Black Friday Promotions | Acq | Ora | Contro-campagna: "Black Friday tutto l'anno: 0 €" (27 nov) |
| 78 | Product Hunt Launch | Acq | Ora | Una volta, la collezione (§9 #26) |
| 79 | Early-Access Referrals | Ref | Skip | Nessuna lista d'attesa |
| 80 | New Year Promotions | Acq | Ora | "Gennaio: cancella gli abbonamenti" con il calcolatore |
| 81 | Early Access Pricing | Rev | Skip | 0 € sempre |
| 82 | Product Hunt Alternatives | Acq | Ora | AlternativeTo per ogni app; BetaList no |
| 83 | Twitter Giveaways | Acq | Skip | Niente da regalare |
| 84 | Giveaways | Acq | Skip | — |
| 85 | Vacation Giveaways | Acq | Skip | — |
| 86 | Lifetime Deals | Rev | Skip | Già gratis per sempre |
| 87 | Powered By Marketing | Ref | Ora | `SbuFigureCard` con "sbu.dev" (§7 M1) |
| 88 | Free Migrations | Act | Q2 | Con #16 |
| 89 | Contract Buyouts | Rev | Skip | — |
| 90 | One-Click Registration | Act | Skip | Nessuna registrazione |
| 91 | In-App Upsells | Rev | Skip | Nessun acquisto in-app |
| 92 | Newsletter Referrals | Ref | Skip | — |
| 93 | Viral Loops | Ref | Ora | Liste condivise (§7 M2) |
| 94 | Offboarding Flows | Ret | Skip | Nessun abbonamento da cancellare |
| 95 | Concierge Setup | Act | Skip | — |
| 96 | Onboarding Optimization | Act | Ora | Prima cifra in 3 tocchi (§5 M5) |
| 97 | Playlists as Marketing | Acq | Q3+ | Forse per Noise: playlist "lavoro concentrato" |
| 98 | Template Marketing | Acq | Q3+ | CSV di esempio per Inventory/Subscriptions |
| 99 | Graphic Novel Marketing | Acq | Skip | — |
| 100 | Promo Videos | Acq | Q2 | Un video di 60 s della collezione per PH e home |
| 101 | Industry Interviews | Acq | Q3+ | Intervistare chi fa app a pagamento: rispetto, non contrapposizione |
| 102 | Social Screenshots | Ref | Ora | Stesso componente di #87 |
| 103 | Online Courses | Rev | Q4+ | "Un'app a settimana" (§8) |
| 104 | Book Marketing | Acq | Skip | — |
| 105 | Annual Reports | Acq | Q4+ | "Quanto costano le app iPhone nel 2027" |
| 106 | End of Year Wraps | Ref | Ora | Articolo di fine anno (§9 #29); Chats è già un wrapped |
| 107 | Podcasts | Acq | Skip | Tempo |
| 108 | Changelogs | Ret | Ora | Note di versione + pagina "Novità" sul sito |
| 109 | Public Demos | Acq | Q2 | Live coding di un'app su YouTube/X |
| 110 | Awards as Marketing | Acq | Q3+ | Candidature Apple Design Award, non crearne |
| 111 | Challenges as Marketing | Acq | Q2 | "30 giorni senza abbonamenti inutili" con Subscriptions |
| 112 | Reality TV Marketing | Acq | Skip | — |
| 113 | Controversy as Marketing | Acq | Skip | Mai contro altri sviluppatori (§4 M4) |
| 114 | Moneyball Marketing | Acq | Ora | ASO + recensioni: canale sottovalutato |
| 115 | Curation as Marketing | Acq | Q2 | "App iPhone oneste" anche di altri: link e buona volontà |
| 116 | Grants as Marketing | Acq | Skip | — |
| 117 | Product Competitions | Acq | Skip | — |
| 118 | Cameo Marketing | Acq | Skip | — |
| 119 | OOH Advertising | Acq | Skip | — |
| 120 | Marketing Stunts | Acq | Q3+ | "Una app in 24 ore in diretta" a WWDC |
| 121 | Guerrilla Marketing | Acq | Skip | — |
| 122 | Humor Marketing | Acq | Skip | Voce sobria |
| 123 | Open Source as Marketing | Acq | Ora | Repo pubblico, README, Show HN |
| 124 | App Store Optimization | Acq | Ora | §4 M3 |
| 125 | App Marketplaces | Acq | Skip | Solo App Store |
| 126 | YouTube Reviews | Acq | Q2 | Inviare app a canali iOS IT (es. "iPhone tips") |
| 127 | YouTube Channel | Acq | Q3+ | Shorts subito; formato lungo in Q3 |
| 128 | Source Platforms | Acq | Skip | G2/Capterra: B2B |
| 129 | Review Sites | Ret | Ora | Recensioni App Store e risposte |
| 130 | Live Audio | Acq | Skip | — |
| 131 | International Expansion | Acq | Q3+ | Lingue dai contributori |
| 132 | Price Localization | Rev | Skip | 0 € ovunque |
| 133 | Investor Marketing | Rev | Skip | — |
| 134 | Certifications | Acq | Skip | — |
| 135 | Support as Marketing | Ret | Ora | Risposte in 48 h (§6 M4) |
| 136 | Developer Relations | Ref | Q2 | Il progetto come caso di studio SwiftUI |
| 137 | Two-Sided Referrals | Ref | Skip | Niente da dare |
| 138 | Podcast Tours | Acq | Q2 | Gitbar, Daily Cogito, podcast iOS EN dopo HN |
| 139 | Customer Language | Acq | Ora | Recensioni 1–3★ dei concorrenti (spec.py) nelle pagine alternativa |

### Giochi (v2): idee che cambiano o si aggiungono
| # | Idea | Fase | Stato giochi | Per i giochi |
|---|---|---|---|---|
| 12 | Marketing Jiu-Jitsu | Acq | Ora | Video e post il giorno in cui la pubblicità nei giochi fa notizia (§4 G6) |
| 15 | Engineering as Marketing | Acq | Skip (giochi) | Niente versione web: i giochi solo come app native (decisione 18/10) |
| 38 | Reddit Marketing | Acq | Ora | r/iosgaming, r/AppHookup, r/puzzles (§4 G4) |
| 42 | Short Form Video | Acq | Ora | Gameplay a matita, "l'ho rifatto senza pubblicità" (§4 G3) |
| 87 | Powered By Marketing | Ref | Ora | `sbu.dev/games` nel testo condiviso (§7 G1) |
| 93 | Viral Loops | Ref | Ora | Partita del giorno + "battimi su questa partita" (§7) |
| 111 | Challenges as Marketing | Ret | Ora | Partita del giorno, uguale per tutti (§6 G1) |
| 114 | Moneyball Marketing | Acq | Ora | "No ads" nell'ASO: una keyword che i concorrenti non possono usare |
| 117 | Product Competitions | Acq | Q2 (era Skip) | Settimana del record: la partita più difficile del mese, risultati condivisi da chi vuole, nessun premio |
| 126 | YouTube Reviews | Acq | Q2 | Canali di giochi mobile IT/EN dopo il secondo gioco |
| 78 | Product Hunt Launch | Acq | Q2 | `sbu.dev/games` come collezione, quando ci sono 3 giochi |
| 110 | Awards as Marketing | Acq | Q3+ | Apple Design Award categoria "Delight and Fun" |

Riepilogo con i giochi: Ora 33 · Q2 21 · Q3+ 10 · Q4+ 3 · Skip 72 (#117 passa da Skip a Q2).

### Software / Sbu Commerce
I dettagli del progetto restano nella copia privata del piano finché il progetto non è annunciato.

---

## 13. Measurement, RACI, open decisions, appendix

### North star
**Installazioni totali al mese di tutte le app sbu.dev** (App Store Connect, "First-time downloads", tutte le app sommate).
Unisce i quattro obiettivi di "famoso": i download sono il prodotto, e ogni altro canale (brand, Matteo, open source) esiste per farli crescere. Si guarda il primo lunedì di ogni mese.

### Indicatori per fase
| Fase | Indicatore | Fonte | Base (17/10) | Obiettivo 10 gen | Obiettivo ott 2027 |
|---|---|---|---|---|---|
| Acq · brand | Posizione per "sbu.dev" e "Sbu <Nome>" | GSC | non indicizzato/ignoto | 1° | 1° |
| Acq · SEO | Clic organici/mese | GSC | ignoto (~0) | 300+ | 2.000–5.000 |
| Acq · SEO | Pagine alternativa indicizzate / in prima pagina | GSC | 0 / 0 | 8 / 3 | 30 / 15 |
| Acq · autorità | Domini che rimandano a sbu.dev | GSC "Link" | ~0 | 20 | 100+ |
| Acq · AI | sbu.dev citato da ChatGPT/Perplexity per "app iPhone gratis senza abbonamento" | prova manuale mensile | no | sì per 1 query | sì per 5 query |
| Acq · founder | Follower totali (X, TikTok, IG, YT, LinkedIn, Bluesky) | piattaforme | ~0 (Instagram e Bluesky appena aperti) | 500 | 5.000 |
| Acq · founder | Video sopra 10.000 visualizzazioni | piattaforme | 0 | 1 | 10 |
| Acq · open source | Stelle GitHub | GitHub | 1 | 300+ | 1.000–2.000 |
| Acq · stampa | Articoli che parlano di sbu.dev | Google Alert "sbu.dev" | 0 | 2 | 10 (IT + EN) |
| Act | Conversione pagina prodotto App Store | ASC Analytics | da leggere | +20% vs base | — |
| Act | Installazioni per sorgente `ct=` | ASC Analytics | 0 | misurato | — |
| Ret | Retention giorno 7 per app | ASC Analytics | da leggere | nota per ogni app | — |
| Ret | Recensioni (somma app live) | App Store | 1 | 40+ | 500+ |
| Ret | Recensioni con risposta entro 48 h | ASC | — | 100% | 100% |
| Ref | Condivisioni `SbuFigureCard` | non misurabile in app (scelta) | — | proxy: installazioni `ct=` da link sbu.dev | — |

### RACI
R = fa · A = decide · C = consultato · I = informato
| Attività | Matteo | Claude |
|---|---|---|
| Strategia, priorità, approvazione di questo piano | A, R | C |
| Pagine sito (alternativa, hub, strumenti) | A | R |
| Codice SbuKit (review request, condividi, figure card) | A (review prima di ogni push) | R |
| Metadati e screenshot App Store | A | R |
| Invio app ad Apple | A, R | C (`release-review`, `originality-check`) |
| Video | A, R (faccia, voce) | C (traccia) |
| Post X / LinkedIn / blog | A, R (pubblica) | R (bozza) |
| Risposte alle recensioni | A, R (invia) | R (bozza) |
| Mail alla stampa | A, R (invia) | R (bozza in Gmail) |
| Show HN, Product Hunt | A, R | C |
| Revisione metriche mensile | A | R (report da export) |

### Decisioni aperte (in ordine di impatto)
| # | Decisione | Raccomandazione | Entro |
|---|---|---|---|
| 1 | **Raccontare "una persona + Claude, un'app a settimana"?** | Sì, sui canali dev (X, HN, LinkedIn, blog), non nelle pagine app né nei metadati | Prima del primo post (sett. 3) |
| 2 | **Altre app di sbu.dev in Impostazioni**: rischio di essere letta come pubblicità da Apple? | Sì, in Impostazioni, lista inclusa nell'app, verifica `appstore-review` prima dell'invio | Sett. 2 |
| 3 | Data dello Show HN della collezione | 15 dic se ≥ 8 app live, altrimenti 12 gen | Sett. 8 |
| 5 | Analytics sul sito | Solo GSC + `ct=` per 90 giorni | Revisione 10 gen |
| 7 | Budget "dipende" | 0 € fino al cancello ASA (§10); poi 100–150 € una tantum | Q2 |
| 8 | Dati di base mancanti (download, conversione, retention dalle app live) | Export ASC alla settimana 1, per riempire la colonna "Base" | Sett. 1 |
| 9 | Accesso di Claude a GSC | Export CSV settimanale nella cartella `materials/` del piano, o MCP | Sett. 3 |

### Decisioni chiuse (18/10)
| # | Decisione | Esito |
|---|---|---|
| #588 | Newsletter | No, solo RSS |
| #589 | GitHub Sponsors e "Sostieni" | No, per ora; non si ripropone |
| #590 | Show HN | Uno per app, Find per primo il giorno 1; più quello della collezione a dicembre |
| — | Nuove app | Ferme finché la coda "pronte su ASC" non si svuota (`docs/stato.md`) |

### Rischi
- **4.3 / spam di Apple**: il marketing aggressivo ("cloni gratis") può arrivare ai revisori. Mitigazione: §2 vincoli 1–2, `originality-check` prima di ogni invio.
- **Marchi**: pagine alternativa solo fattuali, mai loghi o UI altrui; se arriva una diffida, si toglie il nome e si tiene la pagina di categoria.
- **Coda dello Store**: con un invio a settimana e il test insieme che manca, al 15/12 le app live possono essere meno di 8; in quel caso lo Show HN della collezione va al 12/01 e gli Show HN per app tengono il ritmo.
- **Tempo di Matteo**: se il marketing supera 10 h/settimana, si taglia prima X (il più costoso in tempo), poi LinkedIn; video e SEO restano.
- **Backlash AI**: raccontato per primi e con numeri (§2 vincolo 5).

### Appendice
- Ricerca INIT: `research.md` di questo piano.
- Regole di prodotto e voce: `CLAUDE.md` del repo sbu-apps.
- Design system: `Design/README.md`, `Design/tokens.json`.
- ADR rilevanti: 0001 (shell), 0008 (iCloud), 0009 (condivisione), 0013 (Quaderno), 0015 (Giochi), 0016 (Software).
- Stato verificato su App Store Connect: `docs/stato.md` del repo sbu-apps.
- Rifiuto 4.3 del 14/10/2026: memoria di progetto e risposta inviata ad Apple.

### Giochi (v2)
**Indicatori**
| Indicatore | Fonte | Base (18/10) | Obiettivo 10 gen | Obiettivo ott 2027 |
|---|---|---|---|---|
| Giochi live | App Store | 0 | 1 | 10 |
| Posizione per "block puzzle no ads" / "block puzzle senza pubblicità" | App Store search, prova manuale mensile | — | top 10 | top 3 |
| Download giochi / download app | ASC | — | misurato | i giochi portano più download delle app |
| Retention giorno 7 Squares | ASC Analytics | — | misurata | sopra la media delle app sbu.dev |
| Installazioni da `sbu.dev/games` (`ct=games-*`) | ASC | — | misurato | — |
| Recensioni giochi | App Store | 0 | 20 | 1.000+ |

**RACI giochi**: come le app (Matteo decide, rivede e invia; Claude prototipa, scrive codice e testi). Il playtest è di Matteo.

**Decisioni aperte (giochi)**
| # | Decisione | Raccomandazione | Entro |
|---|---|---|---|
| G1 | **ADR giochi** | **Chiusa**: ADR-0015 (18/10) | — |
| G2 | Nome del primo gioco | **Chiusa**: Sbu Squares | — |
| G3 | Game Center (classifiche) | No al lancio: è una chiamata di rete verso Apple e un account; da riconsiderare solo se le recensioni lo chiedono | Revisione 10 gen |
| G4 | Video Instagram DecfvksvHiW mandato da Matteo | Farsi descrivere la meccanica: può cambiare il primo gioco | Prima di G2 |
| G5 | `/games` anche nella versione IT del sito | **Chiusa**: online con slug inglese | — |

**Rischi giochi**
- **4.3 in un genere saturo** (forum Apple 2025: rifiuti anche con codice e grafica rifatti). Mitigazione: look Quaderno, partita del giorno, niente dark pattern come differenza dichiarata nelle note per la review, appello se serve; un gioco al mese, mai due invii di giochi nella stessa settimana.
- **Trade dress**: mai blocchi colorati con gemme, mai i nomi altrui.
- **Tempo di Matteo**: un gioco al mese in aggiunta a un'app a settimana. Se non regge, i giochi scendono a uno ogni sei settimane prima che le app rallentino.

### Software / Sbu Commerce
I dettagli del progetto restano nella copia privata del piano finché il progetto non è annunciato.

---

