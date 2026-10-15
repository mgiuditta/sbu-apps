# Priorità di ottobre 2026: la punta di lancia

Riassunto della sessione del 15/10/2026. Roadmap in `docs/factory.md`, piano in `docs/lancio-sbu.md`, spec in `specs/auth/` e `specs/clean/`, asset in `marketing/auth/` e `marketing/clean/`, sito in `docs/site-todo.md`.

## Corrispondenza tra il brief e la repo

| Nel brief | Nella repo | Perché |
|---|---|---|
| Sbu Auth, `auth` | nuova, slug `auth`, token `accent-authenticator` (già esistente) | la ricerca la chiamava Authenticator; il token resta, il nome cambia |
| Sbu Sweep | **Sbu Clean**, `Apps/SbuClean`, già costruita | il nome è su App Store Connect e la 1.0 aspetta la risposta al 4.3: rinominarla ora costa un reinvio |
| Scan | **Sbu Docs** (CamScanner+) | i sub del brief (r/paperless, r/GoodNotes) parlano di documenti. Sbu Scanner è il lettore QR, 2.0 su TestFlight |
| `apps.json` | non esiste: la roadmap vive in `docs/factory.md`, le app del sito in `Site/src/content/apps/*.md` | rispettato il formato esistente |
| `docs/charts-app-abbonamento.md` | non esiste; al suo posto `research/paywall-pain-2026-10.md` e le classifiche del 15/10 | |
| iOS 26 | iOS 17 (ADR-0002), le API 26 dietro `#available` | CLAUDE.md vince |

## Ordine di sviluppo definitivo

| # | App | Tier | Prima | Motivo dello spostamento |
|---|---|---|---|---|
| 1 | Auth | spearhead | in coda "già avviate", senza data | Il numero più pulito (9,99 €/settimana per una funzione che è un HMAC), la persona giusta (studente di sicurezza), 3 giorni di lavoro, nessun entitlement |
| 2 | Clean | spearhead | costruita, respinta il 14/10 | Già fatta: costa solo la risposta ad Apple. 834 mila valutazioni tra Cleanup e Swipewipe, il paywall più odiato (65% delle recensioni 1-3★) |
| 3 | Level 1.1 | silent | settimana 2 | Resta in corso come esercizio di SbuKit, ma non è una storia: Clinometer costa una volta sola |
| 4 | Steps | loop | in coda, con dubbio sul paywall | Il paywall di Stompers è sulla giornata intera e sullo storico: l'hook lo dice con precisione |
| 5 | Speed 1.1 | silent | settimana 4 | invariata |
| 6 | Docs | loop | in coda, originale "da definire" | Ora l'originale è CamScanner+; numero debole (50 $/anno, niente settimanale): loop, non punta |
| 7 | Chats | loop | settimana 1 | Scende: è pronta, ma The Cringe ha 446 valutazioni. Stesso paywall di Auth (9,99 €/settimana), pubblico minuscolo |
| 8-9 | Fuel, Inventory | silent | settimane 3 e 5 | Pronte, fuori dalla storia di lancio |
| 10 | Focus | loop | Wave 2 | Entitlement FamilyControls da chiedere **subito**, costruire dopo |
| – | Alarm, Cycle, PDF | loop, Wave 2 | Wave 2-3 | Cycle sale (Flo, dati sanitari, privacy come storia); PDF scende dal #2 della revisione: numero debole |
| – | Remote, Lift, Collage, Words, Habits, Cards, Noise, Dark + Block | Wave 3 | Wave 1-3 | Habits, Cards, Noise, Dark, Block clonano app una tantum a prezzo equo: nessuna indignazione, rischio antipatia. Remote ha un numero (7,99 €/settimana) e resta l'unica loop della Wave 3 |

Lo slot è uno a settimana e parte solo dopo la risposta di Apple sul lotto del 14/10: la data della settimana 1 non dipende da noi.

## I 5 rischi

1. **App Review per Auth e Clean.** Auth: categoria affollata (4.3), sosia di Google/Microsoft Authenticator (4.1), il revisore non ha un account 2FA (2.1). Mitigazione: nome e icona Sbu, QR di prova nelle note, Auth inviata da sola. Clean: già respinta per 4.3. Se la risposta al Resolution Center non basta, reinvio da sola con la differenza da "Duplicati" di Foto nelle note. Un rifiuto non ferma il piano: diventa il post "Apple mi ha rifiutato" (`marketing/*/linkedin.md`).
2. **Il limite del backup dei codici.** Senza iCloud, chi perde l'iPhone senza un file di backup perde i codici. È anche la prima domanda su HN. Per questo il backup cifrato è P0, con promemoria nella lista finché non esiste un backup, e la risposta pronta in `marketing/auth/showhn.md`. Va detto prima che lo chiedano: "se perdi il telefono senza backup, perdi i codici, come con qualsiasi app offline".
3. **Accesso limitato a Foto.** Con l'accesso limitato Clean vede solo le foto scelte: lo spazio liberabile è piccolo e il video prima/dopo mente. Clean lo gestisce già (`LibraryAccess.swift`); nei contenuti la cifra si mostra con accesso completo e la FAQ lo spiega.
4. **Il thread HN che non prende.** Più probabile del contrario. Il piano non dipende da HN: Reddit e il video vanno comunque, la stampa parte solo con un thread che ha preso, e un secondo tentativo su HN si fa con Clean, non ripostando Auth. Se nessun canale supera i 200 download in 3 giorni, il problema è l'hook: si riscrive da `hooks.md` prima di Clean.
5. **Il tempo reale di Matteo.** Università e ripetizioni. Il piano chiede: giorno 1 sei ore di presenza su HN, giorni 1-3 un'ora al giorno su Reddit, i test insieme. Tutto il resto lo prepara un agente. Se una settimana non c'è tempo, salta il lancio e non la qualità: un loop dimezzato brucia l'app.

Altri due vincoli trovati in repo:
- ~~La repo è privata~~: pubblica dal 15/10 (vedi sotto).
- **Il totale "oltre 2.000 €" usa Heartica**, che non ha un'App Sbu. Va bene per raccontare il fenomeno, non nel post "4 app, 0 €" (con le quattro app vere il totale è circa 1.550 €). Vedi `docs/lancio-sbu.md`, sezione d.

## Endpoint Apple

Tutti hanno risposto il 15/10: `itunes.apple.com/lookup` (valutazioni e prezzo d'acquisto) e le pagine apps.apple.com IT e US (acquisti in-app). Il lookup non elenca gli acquisti in-app, quindi i prezzi settimanali vengono dalla pagina dello Store.

## Repo pubblica (fatto il 15/10)

- `mgiuditta/sbu-apps` è **pubblica**, licenza MIT, con la cronologia di `main` riscritta: il numero di telefono di App Review non c'è in nessun commit (il file resta solo sul Mac, ignorato da git). La vecchia repo è `mgiuditta/sbu-apps-private`: tiene le 466 issue, le PR e i 21 branch non uniti, che vanno riportati sulla nuova cronologia con `cherry-pick` se servono, mai con merge (riporterebbero la vecchia cronologia). Backup completo: `~/dev/sbu-apps-backup-2026-10-15.bundle`.
- Remote locali: `origin` = pubblica, `private` = privata. `gh` punta di default alla privata per le issue.
- Permessi della pubblica: `main` non si può cancellare né riscrivere (ruleset), token delle Actions in sola lettura, approvazione obbligatoria per i workflow da fork esterni, secret scanning e push protection, segnalazione privata delle vulnerabilità, issue/wiki/progetti spenti.
- Le Actions su una repo pubblica sono gratuite, anche macOS: la CI ripartita da sola al primo push.

## La prima azione di domani

Chiedere l'entitlement FamilyControls per Focus. Poi partire con Sbu Auth: `Tools/new_app.sh`, spec in `specs/auth/spec.json`, tre giorni.
