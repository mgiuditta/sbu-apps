# Stato di sbu.dev — 18 ottobre 2026

Fotografia verificata il 18/10 alle 15:30: stati letti dall'API di App Store Connect, branch e CI letti da git e GitHub. Sostituisce la tabella "Stato delle app" di `docs/factory.md`, ferma al 16/10.

## In una frase

Il codice è molto più avanti dello Store: 20 app scritte, 2 pubblicate, 1 in revisione. Il collo di bottiglia non è costruire, sono tre cose: la risposta di Apple al rifiuto 4.3 del 14/10, il test insieme sul tuo iPhone, e TestFlight che sul tuo iPhone non installa.

## 1. Sullo Store oggi

| App | Stato su App Store Connect | Da quando |
|---|---|---|
| Sbu Subscriptions | **2.0.0 pubblicata**; 2.1.0 preparata, non inviata | 2.0 live dal 16/10 |
| Sbu Scanner | **2.0.0 pubblicata** | confermata il 17/10 |
| Sbu Find | **1.0 pubblicata** (approvata dopo l'appello al Board) | live dal 21/10 |

Tutto il resto non è sullo Store.

## 2. Tutte le app, una riga ciascuna

Ogni app è su `main` (tutti i branch `app/*` sono già fusi). "Prossimo passo" è l'unica cosa che sblocca l'app.

### Respinte il 14/10 (4.3 / 4.2.6)

| App | ASC | Prossimo passo | Chi |
|---|---|---|---|
| Habits | 1.0 REJECTED, risposta respinta il 22/10 | appello all'App Review Board con `docs/rejections/2026-10-14-guideline-4.3/appeal-habits.md` | Matteo |
| Clean | 1.0 REJECTED, risposta respinta il 22/10 | ferma fino all'esito dell'appello di Habits | – |
| Noise | 1.0 REJECTED, risposta respinta il 22/10 | ferma fino all'esito dell'appello di Habits | – |
| Moon | 1.0 REJECTED, risposta respinta il 22/10 | ferma fino all'esito dell'appello di Habits | – |
| Level | 1.1 REJECTED (stato vecchio del 14/10, la 1.1 non è mai stata inviata) | test sul device, screenshot Sight/Trips, reinvio in uno slot | insieme |
| Speed | 1.1 REJECTED (idem) | prova su strada, screenshot, reinvio in uno slot, mai nella stessa settimana di Level | insieme |

### Pronte su ASC, non inviate

| App | ASC | Manca | Chi |
|---|---|---|---|
| Subscriptions 2.1 | 2.1.0 PREPARE_FOR_SUBMISSION, nessuna build agganciata | `fastlane select_build build:7`, test insieme sul device, Invia | Claude + Matteo |
| Chats | 1.0 PREPARE_FOR_SUBMISSION | App Privacy sul web, test insieme, slot | Matteo |
| Fuel | 1.0 PREPARE_FOR_SUBMISSION | App Privacy sul web, test insieme, slot | Matteo |
| Inventory | 1.0 PREPARE_FOR_SUBMISSION | foto di esempio per gli screenshot, App Privacy, test insieme, slot | insieme |

### Scritte, mai su ASC

| App | Manca |
|---|---|
| Shrink, Grid, Tidy, Libretto | test sul device, record ASC, TestFlight |
| Meds | test del task in background sul device, record ASC, TestFlight |
| Remote | prova su una TV vera, richiesta entitlement multicast (Matteo, `docs/remote-multicast-entitlement.md`), conferma delle scelte provvisorie, record ASC |
| Squares (primo Gioco) | prova completa, screenshot Store, record ASC, TestFlight; invio previsto a inizio dicembre |

### Pianificate, non iniziate

Cycle, Cast, Image, Gif, Tags, Knit, Chores, Reader, Exposure.

## 3. Bloccanti, in ordine di peso

1. **Apple ha respinto le risposte sul 4.3 il 22/10** (messaggio generico, `docs/rejections/2026-10-14-guideline-4.3/risposta-apple-2026-10-22.md`). Prossimo passo: appello del Board solo per Habits; Clean, Noise, Moon, Level e Speed ferme fino all'esito. Resta la regola: un invio a settimana.
2. **TestFlight non installa sul tuo iPhone** ("The requested app is not available or doesn't exist", dal 16/10, caso aperto con Developer Support). Ripiego: build Release via cavo per il test insieme.
3. **Il test insieme è il passaggio che manca a quasi tutto**: Subscriptions 2.1, Chats, Fuel, Inventory, Level, Speed, Squares, e le sei scritte. Nessuna di queste va inviata senza.
4. **CI rossa su main**: i test UI di Clean e Noise falliscono sui runner GitHub (timeout dell'audit, testo tagliato), Habits cancellato. Il sito invece si pubblica (workflow Site verde).

## 4. Calendario delle prossime settimane

| Quando | Cosa |
|---|---|
| ora | Find in revisione. All'approvazione: giorno 0 del lancio, checklist `marketing/find/lancio.md`, Show HN il giorno 1 |
| 21/10 | se Apple tace, follow-up su Habits nello stesso thread |
| dal 24/10 | Subscriptions 2.1 (un aggiornamento: secondo `docs/factory.md` non occupa lo slot, quindi può andare anche prima, decidi tu) |
| settimana successiva alla risposta di Apple | primo slot nuovo: Clean se Apple la accetta, altrimenti la prima tra Chats e Fuel che ha superato il test insieme |
| inizio dicembre | Squares in revisione |
| metà dicembre | lancio della collezione: Show HN + Product Hunt |

## 5. Gli altri due rami

- **Giochi**: ADR-0015, Squares su main e installato sul tuo iPhone ("per ora funziona bene"). Uno al mese dopo Squares: Tiles, Sudoku, Arrows, Sort, Solitaire, Words.
- **Software**: ADR-0016 e pagine `/software` e `/software/commerce` sul sito. Il repo `sbu-commerce` non esiste ancora; nessuna riga di codice. Primo passo: lo spike di compatibilità (catalogo, prodotto, carrello). Non annunciato: nessun nome di piattaforma nel materiale pubblico.

## 6. Marketing

Fatto: sito live con i tre rami, Search Console e Bing, Smart App Banner, `sameAs` e `llms.txt`, pagine alternativa, generatore QR e calcolatore abbonamenti, badge con link campagna, RSS, Instagram @sbudevapp, foto stampa, listing AlternativeTo (in moderazione), open-source-ios-apps: Subscriptions in lista (#2443), Scanner in PR #2446 (una PR per app). In SbuKit (su main, arrivano con la prossima versione di ogni app): richiesta di recensione dopo la Chiusura, Condividi l'app, `SbuFigureCard`. Piano 12 mesi v3.2 in `marketing/plan.md` (copia pubblica), punteggio 51/85.

Deciso e chiuso: niente newsletter (solo RSS), niente GitHub Sponsors, un Show HN per app.

Aperto: indicizzazione delle pagine nuove (#575), handle su X/TikTok/YouTube/LinkedIn, video di Find e "costa 40 € l'anno, l'ho rifatta gratis", articolo "sei app rifiutate" (bozza IT), lancio di Find all'approvazione.

## 7. Cosa serve da te (Matteo)

1. App Privacy "nessun dato" sul web per Chats, Fuel, Inventory.
2. Il 21/10: mandare o no il follow-up Habits.
3. Una sessione di test insieme, via cavo, partendo da Subscriptions 2.1 (è la prossima a poter uscire).
4. Decidere se Subscriptions 2.1 aspetta il 24/10 o esce prima (aggiornamento, fuori slot).
5. Richiesta entitlement multicast per Remote, quando vuoi riprenderla.

## 8. Cosa NON fare adesso

Il rischio vero è disperdersi: 20 app scritte, tre rami, 274 ticket aperti. Finché Apple e il test insieme sono il collo di bottiglia, ogni app nuova allunga la coda senza far uscire niente.

- Nessuna app nuova (Cycle e le pianificate restano ferme) finché la coda "pronte su ASC" non si svuota.
- Software resta allo spike, niente lancio prima di una demo che gira.
- Un fronte al giorno: test insieme, poi invio, poi lancio.

## 9. Pulizia in sospeso

- ~30 branch `worktree-agent-*` locali e i branch `app/*` già fusi: si possono cancellare.
- `Apps/SbuDuo` è un residuo non tracciato (Duo vive sul branch `duo`).
- La tabella stati e il calendario di `docs/factory.md` vanno allineati a questo file o tolti.
