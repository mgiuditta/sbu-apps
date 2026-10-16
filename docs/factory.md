# Fabbrica di app Sbu

Obiettivo: ogni app a pagamento che non ha bisogno di un server ha la sua App Sbu gratuita. Riferimento pubblico: [ArtCraft](https://propakistani.pk/2026/10/09/free-open-source-copies-of-photoshop-premiere-and-lightroom-are-here/), sette cloni gratuiti e open source delle app Adobe costruiti con Claude Opus 5.5.

Traguardi: ~~25 app in revisione entro il 31 ottobre 2026, 100 entro fine anno~~, abbandonati dopo il rifiuto 4.3 del 14/10: conta la salute dell'account (vedi il calendario sotto). Il codice non è il collo di bottiglia: lo sono la revisione Apple e il test insieme.

## Stato delle app (16 ottobre 2026)

Un solo stato per app, aggiornato a ogni passaggio: **pianificata** → **in sviluppo** → **TestFlight** → **in revisione** → **pubblicata il <data>** (o **respinta**, con il motivo). La mappa di ogni app porta l'app fino a TestFlight.

| App | Versione | Stato | Mappa |
|---|---|---|---|
| Sbu Subscriptions | 2.0.0 | pubblicata il 16/10/2026 | Sbu Subscriptions 2.0 pari a Orbit (#393) |
| Sbu Scanner | 2.0.0 (2) | TestFlight, test insieme da fare | Sbu Scanner 2.0 (#213) |
| Sbu Level | 1.1 (5) | TestFlight, reinvio dopo il 4.3 | Sbu Level (#130) |
| Sbu Speed | 1.1 (4) | TestFlight, reinvio dopo il 4.3 | Sbu Speed 1.1 (#459) |
| Sbu Chats | 1.0 (2) | TestFlight | Sbu Chats (#466) |
| Sbu Fuel | 1.0 (2) | TestFlight | Sbu Fuel (#469) |
| Sbu Inventory | 1.0 (2) | TestFlight | Sbu Inventory (#468) |
| Sbu Clean | 1.0 | respinta il 14/10 (4.3), risposta in attesa | Sbu Clean (#292) |
| Sbu Habits | 1.0 | respinta il 14/10 (4.3), risposta in attesa | Sbu Habits (#108) |
| Sbu Noise | 1.0 | respinta il 14/10 (4.3), risposta in attesa | Sbu Noise (#422) |
| Sbu Moon | 1.0 | respinta il 14/10 (4.2.6), risposta in attesa | – |
| Sbu Find | 1.0 | in sviluppo | Sbu Find (#248) |
| Sbu Shrink | 1.0 | pianificata, ricerca fatta | Sbu Shrink (#472) |
| Sbu Grid | 1.0 | pianificata, ricerca fatta | Sbu Grid (#474) |
| Sbu Tidy | 1.0 | in sviluppo su `app/tidy`: scaffold, modello | Sbu Tidy (#476) |
| Sbu Libretto | 1.0 | pianificata | Sbu Libretto (#478) |
| Sbu Meds | 1.0 | pianificata, dopo Cycle | Sbu Meds (#480) |
| Sbu Cycle | 1.0 | pianificata | Sbu Cycle (#230) |
| Sbu Remote | 1.0 | pianificata | Sbu Remote (#365) |
| Sbu Cast | 1.0 | pianificata | da creare |
| Sbu Image | 1.0 | pianificata | da creare |
| Sbu Gif | 1.0 | pianificata | da creare |
| Sbu Tags | 1.0 | pianificata | da creare |
| Sbu Knit | 1.0 | pianificata | da creare |
| Sbu Chores | 1.0 | pianificata | da creare |
| Sbu Reader | 1.0 | pianificata | da creare |
| Sbu Exposure | 1.0 | pianificata | da creare |

Ogni app nuova: UX identica all'originale (stesse schermate, stesso ordine, stessi casi limite, stile Sbu), unit test Swift Testing severi su tutta la logica (parametrizzati, casi limite, errori), zero bug di UI prima di TestFlight.

## Roadmap del filtro Sbu (16 ottobre 2026)

Sostituisce la roadmap punta di lancia, la coda delle 25, le wave del 15/10 e le candidate da Android. Fonte: `research/niche-filter-2026-10-16.md`, circa 110 nicchie passate ai cinque criteri (originale che abusa del prezzo, funzione senza server, sistema che non la copre, nessuna app gratis pulita anche oscura, al massimo 12 giorni). Le utility diventano virali con il numero (il settimanale × 52) e la persona; piano in `docs/lancio-sbu.md`.

Prossime sei, in ordine di costruzione:

| # | App | Slug | Originale (ID US) | Prezzo dell'originale | Giorni | Rischio review | Accento |
|---|---|---|---|---|---|---|---|
| 1 | Sbu Find | `find` | Wunderfind (1458601441), Find My Bluetooth Device (1522814560) | 7,99 $/sett. = 415 $/anno | 3-5 | 5.2.5: mai "Find My" nel nome; solo dispositivi BLE | `accent-find` |
| 2 | Sbu Shrink | `shrink` | Compress Videos & Resize Video (1473857051), Video Compressor + Resizer! (6742453124) | 6,99 $/sett. = 363 $/anno | 5-8 | 4.3: nome e icona distintivi | `accent-shrink` |
| 3 | Sbu Grid | `grid` | DrawinGrid (1508298774), GridArt (6474590995) | 3,99 $/sett. = 207 $/anno | 3-5 | 4.3 medio | `accent-grid` |
| 4 | Sbu Tidy | `tidy` | Tody (595339588), Sweepy (1498897320) | 3,99 $/mese; Tody 9,99 $ | 5-8 | 4.3 basso; niente sync famiglia, va detto | `accent-tidy` |
| 5 | Sbu Libretto | `libretto` | MyLibretto (914172791, IT) | banner + PRO 3,49 € | 5-8 | basso; esce prima della sessione invernale, lancio sul Discord SecAI | `accent-libretto` |
| 6 | Sbu Meds | `meds` | Medisafe (573916946), Med ART (1448776934) | 39,99 $/anno; profili famiglia a pagamento dal 2026 | 7-10 | 1.4.1: zero consigli di dosaggio; dopo Sbu Cycle | `accent-meds` |

Dopo: Sbu Remote (8-12 giorni, entitlement multicast da chiedere subito, fallback IP manuale), poi il cast DLNA che ne riusa un terzo; poi Sbu Image (resize px/cm/DPI, watermark, frame grabber in un'app sola), GIF editor e tag editor, appena chiuse le verifiche.

Altri PASS, in coda: contarighe maglia, faccende e paghetta, RSVP con EPUB, lunga esposizione. Con riserva da chiudere: scontrini OCR, screen recorder, archiver RAR/7z, libretto animali, comic reader, misuratore PPFD.

Estensioni invece di app nuove: manutenzione auto in Sbu Fuel (3-4 giorni), alba, tramonto e ora dorata in Sbu Moon (2-3), Wake-on-LAN in Sbu Remote (1), strumenti hash/encode/JWT come funzione, non come app.

Verifiche prima di aprire Xcode (un pomeriggio dal Mac): valutazioni esatte con `itunes.apple.com/lookup`; ricerche Reddit "free alternative to X" per video compressor, image resizer, GIF, maglia, speed reading; limiti veri del free tier di Wunderfind; tempi 2026 dell'entitlement multicast; Salute in iOS 26 e i profili multipli per i farmaci.

Accenti in `Design/tokens.json` e incisioni in `Design/icons/engravings.json` per le sei, Cycle, Remote e le otto in coda (Cast, Image, Gif, Tags, Knit, Chores, Reader, Exposure); sul sito tutte con il loro stato. Le nicchie con riserva entrano solo dopo la verifica.

### Tolte dal filtro

- **Bocciate dai dati:** Sbu BP e Sbu Pulse (alternative gratis pulite, rischio 1.4.1), Paprika (Crouton) e Money Pro (Dime). Quasi-PASS fermi sulla regola 4 finché Matteo non la allenta: OBD-II, EXIF, teleprompter, baby monitor, scanner di rete, dashcam, room scanner, chord finder, font installer.
- **Archiviate, fuori dal filtro:** Docs, Cards, Block, Dark (tolte dal sito il 16/10), Auth, Steps, Focus, Alarm, PDF, Lift, Collage, Words, Invoice, Transcribe, Tuner, le "nuove" della coda (Meter, Decibel, Intervals, Magnet, Prompter) e le candidate da Android. Ricerca e spec restano in `research/` e `specs/`.
- **Restano:** le app già costruite (Chats, Fuel, Inventory), i reinvii Level 1.1 e Speed 1.1, Scanner 2.0 e Subscriptions 2.0, Sbu Cycle come passo prima di Meds.

## Calendario degli invii (16 ottobre 2026)

Uno slot a settimana dalla risposta di Apple sul lotto del 14/10; app nuove e reinvii si alternano; al massimo un'app con dati sanitari al mese. Gli aggiornamenti non occupano lo slot.

| Settimana | Invio | Tier | Stato al 16/10 |
|---|---|---|---|
| 1 | Clean | spearhead | risposta 4.3 in attesa |
| 2 | Find | spearhead | da costruire |
| 3 | Level 1.1 | silent | reinvio |
| 4 | Shrink | spearhead | da costruire |
| 5 | Chats | loop | pronta per il test insieme |
| 6 | Grid | loop | da costruire |
| 7 | Speed 1.1 | silent | reinvio |
| 8 | Libretto | loop | prima della sessione invernale |
| 9 | Fuel | silent | pronta per il test insieme |
| 10 | Tidy | loop | in costruzione |
| 11 | Inventory | silent | in costruzione |
| 12 | Meds | loop | dopo Cycle |

## Cosa copiamo, cosa no

- **Sì, il più possibile:** funzioni, flussi, schermate, impostazioni, casi limite, tutto quello che la spec ricava dai dati pubblici dello Store. Più le cose che le recensioni da 1-3 stelle chiedono e l'originale non fa.
- **No:** nome, icona, testi, screenshot, grafica e marchi dell'originale. L'aspetto è sempre Sbu (design system, icona incisa, un accento). Nei metadati dello Store niente nomi di app terze (2.3.7, 5.2); il confronto vive solo sul sito, nelle pagine `alternatives/`.
- **Saltato:** qualunque funzione che richiede server, account, rete o pubblicità (`skip` nella spec).

## Pipeline

Tre controlli umani, il resto automatico.

| # | Passo | Chi | Comando |
|---|---|---|---|
| 1 | Scelta dell'Originale dalla coda qui sotto | **Matteo** | |
| 2 | Dati pubblici e spec | agente | `discover.py --ids <id>` → `spec.py <id>` |
| 3 | **Approvazione della spec**: cosa entra, cosa si salta | **Matteo**, 5 min | |
| 4 | Scaffold, icona incisa, sito | agente | `new_app.sh <Name> <accent> "<strumento>"` |
| 5 | App, stringhe IT/EN, test, audit accessibilità | agente | `fastlane test` |
| 6 | Screenshot, cornici, metadati IT/EN | agente | `fastlane snapshot && fastlane frames`; un'app con target Apple Watch ha anche lo screenshot Watch (`Tools/watch_screenshots.sh` nella lane `snapshot`, con una modalità demo nell'app Watch) |
| 7 | **Test insieme** su TestFlight, checklist sotto | **Matteo**, 15-20 min | `fastlane beta` |
| 8 | Upload senza invio | agente | `fastlane release` |
| 9 | **Invio in revisione** | **Matteo**, da App Store Connect | |
| 10 | Rifiuto: analisi e correzione, poi di nuovo al passo 7 | agente | skill `rejection-handler` |

Ritmo: 3-4 test insieme al giorno. Gli agenti lavorano in parallelo, un worktree per app.

## Regole contro il 4.3 (spam)

Apple rifiuta, e al limite chiude l'account, se uno sviluppatore pubblica molte app simili in poco tempo. Il brand comune va bene; le funzioni clonate tra noi no.

- Una **Cosa sola** diversa per app, mai due app nella stessa nicchia (ADR-0004). Due timer, due fotocamere o due tracker dello stesso tipo: se ne sceglie uno.
- Ogni app ha una funzione vera, non banale: niente app che sono una sola schermata con un numero.
- Invii scaglionati: **uno a settimana**, solo dopo la risposta di Apple sul lotto del 14/10. Gli aggiornamenti di app già pubblicate non occupano lo slot.
- Nelle note per la revisione, una riga su cosa fa l'app e perché è diversa dalle altre App Sbu.

## Checklist del test insieme

1. Primo avvio, pulito: nessun permesso chiesto prima che serva.
2. La Cosa sola dall'inizio alla fine, il flusso principale della spec.
3. Testo enorme (AX5) e VoiceOver sulla schermata principale.
4. Chiaro e scuro; inglese e italiano.
5. Impostazioni: promesse, licenze, link a sbu.dev in Safari.
6. Permesso negato: l'app lo spiega e non si blocca.
7. Uscita e rientro: i dati ci sono ancora.

Zero bug di UI prima del passo 8.

## Da costruire per reggere il ritmo

- ~~CI: un job per ogni `Apps/*`~~: fatto, matrice letta da `Apps/Sbu*`.
- ~~`new_app.sh`: creare anche l'app su App Store Connect~~: fatto, lane `create_app` (Apple ID in `FASTLANE_USER`, la API non crea app).
- Un token `accent-*` nuovo in `Design/tokens.json` per ogni app che non ne ha uno.
