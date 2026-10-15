# Fabbrica di app Sbu

Obiettivo: ogni app a pagamento che non ha bisogno di un server ha la sua App Sbu gratuita. Riferimento pubblico: [ArtCraft](https://propakistani.pk/2026/10/09/free-open-source-copies-of-photoshop-premiere-and-lightroom-are-here/), sette cloni gratuiti e open source delle app Adobe costruiti con Claude Opus 5.5.

Traguardi: ~~25 app in revisione entro il 31 ottobre 2026, 100 entro fine anno~~, abbandonati dopo il rifiuto 4.3 del 14/10: conta la salute dell'account (vedi il calendario sotto). Il codice non è il collo di bottiglia: lo sono la revisione Apple e il test insieme.

## Roadmap punta di lancia (15 ottobre 2026)

Sostituisce le wave precedenti. Le utility non diventano virali da sole: diventano virali il numero (il paywall settimanale moltiplicato per 52) e la persona (uno studente di Sicurezza Informatica che rifà le app a pagamento e le regala). Piano di marketing in `docs/lancio-sbu.md`, motivi degli spostamenti in `docs/priorita-2026-10.md`.

Prezzi: acquisti in-app mostrati da apps.apple.com/it il 15/10/2026, il più alto settimanale (o annuo dove non c'è un settimanale). "Equivalente annuo" = settimanale × 52. `launch_tier`: **spearhead** (piano di 14 giorni), **loop** (checklist ripetibile), **silent** (release senza contenuti).

| Wave | App | Slug | Originale (ID) | paywall_weekly | paywall_yearly_equiv | hook | launch_tier | Giorni | Stato al 15/10 |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Sbu Auth | `auth` | Authenticator ℠ App (6754900760) | 9,99 € (US fino a 14,90 $) | 519 € | Un generatore di codici 2FA costa 9,99 € a settimana. Sbu Auth è gratis, aperta e non tocca mai la rete. | spearhead | 3 | ricerca fatta, spec pronta |
| 1 | Sbu Clean ("Sweep") | `clean` | Cleanup (1510944943); Swipewipe (1583884012) | 12,99 € (Swipewipe 9,99 €) | 675 € (Swipewipe 519 €) | Cleanup ti fa scegliere le foto per mezz'ora e poi chiede 12,99 € a settimana per eliminarle. Sbu Clean le elimina gratis. | spearhead | 6 (fatta) | costruita, respinta il 14/10 (4.3), risposta in attesa |
| 1 | Sbu Steps | `steps` | Stompers (6477849675) | 5,99 € (giornata intera e storico) | 311 € | Stompers smette di contare i tuoi passi alle 21 se non paghi. Sbu Steps conta tutta la giornata, gratis. | loop | 3 | ricerca fatta, spec da fare |
| 1 | Sbu Docs ("Scan") | `docs` | CamScanner+ (388624839) | nessuno (Premium 49,99 $/anno) | 50 $ | Scansionare un foglio non dovrebbe costare 50 $ l'anno e una filigrana. | loop | 7 | accento pronto, spec da fare |
| 1 | Sbu Level 1.1 | `level` | Clinometer | una tantum | – | – | silent | in corso | reinvio dopo il 4.3 |
| 2 | Sbu Focus | `focus` | Forest (866450515) | nessuno (27,99 €/anno) | 28 € | Forest ti fa pagare per scegliere quali app restano aperte. | loop | 4 | spec; entitlement FamilyControls da chiedere |
| 2 | Sbu Alarm | `alarm` | Alarmy (1163786766) | n.v. (fino a 59,99 €/anno) | 60 € | Una sveglia non dovrebbe avere un abbonamento. | loop | 6 | spec; decisione iOS 26 o Noise |
| 2 | Sbu Cycle | `cycle` | Flo (1038369065) | nessuno (39,99 €/anno) | 40 € | Il tuo ciclo resta sul tuo telefono, non su un server. | loop | n.d. | ricerca fatta; dati sanitari |
| 2 | Sbu Chats | `chats` | The Cringe (6766070732) | 9,99 € | 519 € | Le statistiche delle tue chat costano 9,99 € a settimana. Qui sono gratis e non escono dal telefono. | loop | 12 (fatta) | pronta per il test insieme |
| 2 | Sbu PDF | `pdf` | GoodReader (777310222) | nessuno (29,99 €/anno, Pro Pack 99,99 €) | 30 € | Hai già pagato GoodReader. Ora vuole anche un abbonamento. | loop | 6 | spec |
| 3 | Sbu Remote | `remote` | TV Remote (1539090879) | 7,99 € | 415 € | Un telecomando per la TV a 7,99 € a settimana. | loop | n.d. | ricerca fatta |
| 3 | Sbu Lift | `lift` | Hevy (1458862350) | nessuno (26,49 €/anno) | 26 € | – | silent | 8 | spec; elenco esercizi da scrivere |
| 3 | Sbu Collage | `collage` | SCRL (1289057196) | 5,99 € | 311 € | – | silent | 6 | spec |
| 3 | Sbu Words | `words` | Vocabulary (1084540807) | nessuno (39,99 €/anno) | 40 € | – | silent | 5 | spec; licenze dei dati |
| 3 | Sbu Habits | `habits` | Streaks | una tantum | – | – | silent | fatta | respinta il 14/10, risposta in attesa |
| 3 | Sbu Cards | `cards` | AnkiMobile | una tantum (24,99 $) | – | – | silent | n.d. | accento pronto |
| 3 | Sbu Noise | `noise` | – | – | – | – | silent | fatta | respinta il 14/10, risposta in attesa |
| 3 | Sbu Dark + Block | `dark`, `block` | Noir, Wipr 2 | una tantum | – | – | silent | n.d. | accento pronto |

Fuori dalle wave e senza marketing (release silenziose negli slot liberi): Fuel e Inventory (pronte), Speed 1.1, Scanner 2.0, Subscriptions 2.0, Moon.

Le app una tantum a prezzo equo (Streaks, AnkiMobile, Noir, Wipr) non si attaccano mai nei contenuti: nessuna indignazione, rischio antipatia.

## Calendario degli invii dopo il rifiuto 4.3 (15 ottobre 2026)

Criterio: l'abbonamento è stupido da pagare se la funzione non ha bisogno di un server; una App Sbu per ogni nicchia così, l'affollamento non esclude. Dati: `research/it-top-grossing-2026-10-15.md`, `research/us-top-grossing-2026-10-15.md`, `research/niches/`.

Regole: uno slot a settimana dalla risposta di Apple; app nuove e reinvii (Level 1.1, Speed 1.1) si alternano; prima le app già in corso, poi gli strumenti veri, le app veloci in nicchie sature solo dopo; al massimo un'app con dati sanitari al mese; fuori le nicchie che si sovrappongono a un'App Sbu finché il confine non è deciso. Scanner 2.0 è un aggiornamento e parte appena passa il test insieme.

| Settimana | Invio | Originale | Tier | Stato al 15/10 |
|---|---|---|---|---|
| 1 | Auth | Authenticator ℠ App | spearhead | da costruire (3 giorni) |
| 2 | Clean | Cleanup | spearhead | reinvio o approvazione della risposta 4.3 |
| 3 | Level 1.1 | Clinometer | silent | reinvio |
| 4 | Steps | Stompers | loop | da costruire |
| 5 | Speed 1.1 | Speedometer 55 | silent | reinvio |
| 6 | Docs | CamScanner+ | loop | da costruire |
| 7 | Chats | The Cringe | loop | pronta per il test insieme |
| 8 | Fuel | Fuelly | silent | pronta per il test insieme |
| 9 | Inventory | Sortly | silent | in costruzione |
| 10 | Focus | Forest | loop | dopo l'entitlement |

Se Apple approva Clean dalla risposta al Resolution Center prima della settimana 2, lo slot 2 passa a Steps e il resto scala.

Riserve, in ordine: Calcolatrice, Font, Frasi, Impostore, Dividi, Spese, Collage.
Ferme finché non si decide il confine: Pdf (con Docs), Cassaforte e Duo, Quaderno (con Pdf). Patente: aspetta la licenza del catalogo ministeriale. Ritocco e Gravidanza grandi; Palestra e Turni con paywall debole.

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

## Coda: le prossime 25

Le 5 fatte (Level, Habits, Noise, Moon, Speed) più 20. Dalle classifiche top-paid IT e US del 13 ottobre 2026.

**Già avviate (accento e spec pronti):**

| App Sbu | Originale | Nota |
|---|---|---|
| Subscriptions | Orbit | 2.0 in corso |
| Scanner | QR Reader for iPhone (TapMedia) | 2.0 sulla scheda 6772572337 |
| Docs | da definire | archivio PDF (ADR-0006) |
| Cards | AnkiMobile Flashcards | |
| Block | Wipr 2 | estensione Safari |
| Dark | Noir | estensione Safari |
| Clean | Cleanup | |
| Authenticator | Authenticator App | Keychain |
| Invoice | Invoice Simple | |
| Transcribe | Otter | riconoscimento vocale sul dispositivo |
| Find | Find Air | Bluetooth |
| Remote | TV Remote | rete locale (ADR-0007) |
| Tuner | GuitarTuna o Tuner Pro | una sola delle due |
| Cycle | Flo | |
| Steps | Stompers | |

**Nuove, senza server, nicchie diverse dalle precedenti:**

| App Sbu | Originale | Classifica | Strumento per l'icona |
|---|---|---|---|
| Meter | GrayZone - Esposimetro | it12 | esposimetro a lancetta |
| Decibel | SPL Meter | it95 | fonometro |
| Intervals | Seconds Pro | us92 | cronometro da allenamento |
| Magnet | Magnetometro | it55 | bussola magnetica |
| Prompter | PromptSmart Pro | us86 | leggio |

**Riserve**, se una delle prime salta: Due (promemoria insistenti, it24), AutoSnore (it72), Sun Seeker (us91), Print to Size (us68), Color Wheel (it87).

Scartate per ora: servono server o rete (Blitzer, Threema, Veicolo+, Rilevatore Terremoto, IPTV, Goblin Tools), sono troppo grandi per ottobre (Procreate, Nomad Sculpt, LumaFusion, FL Studio), oppure stanno in una nicchia che abbiamo già (TonalEnergy con Tuner, Bear Focus Timer con Intervals).

## Roadmap a wave: app nuove che sostituiscono un abbonamento (15 ottobre 2026)

Sette app nuove, che non coincidono con nessuna app già in repo o in coda. Dati pubblici in `research/<slug>/` (`listing.json`, `reviews.json`: lookup e recensioni 1-3 stelle US e IT), spec in `specs/<slug>/spec.json`, rischi in `docs/roadmap-review-2026-10.md`. Stato di tutte: **planned**. Dove ci sono più originali, il primo è l'**Originale**, gli altri sono **Concorrenti** (ADR-0004).

| # | App | Slug | Originale (ID US) | Concorrenti (ID) | Categoria | Accento | Giorni |
|---|---|---|---|---|---|---|---|
| 1 | Sbu Chats | `chats` | The Cringe: Chat Wrapped (6766070732) | ChatScope (6745802989), ChatRecap AI (6738325645); WhatStat (Android, `com.whatstats`) solo come riferimento | Utility | `accent-chats` (da creare) | 12 |
| 2 | Sbu Focus | `focus` | Forest (866450515) | | Produttività | `accent-focus` (da creare) | 4 |
| 3 | Sbu Alarm | `alarm` | Alarmy (1163786766) | | Utility | `accent-alarm` (da creare) | 6 |
| 4 | Sbu Lift | `lift` | Hevy (1458862350) | Lyfta (6443740936) | Salute e fitness | `accent-lift` (da creare) | 8 |
| 5 | Sbu Collage | `collage` | SCRL (1289057196) | | Foto e video | `accent-collage` (da creare) | 6 |
| 6 | Sbu PDF | `pdf` | GoodReader (777310222) | | Produttività | `accent-pdf` (da creare) | 6 |
| 7 | Sbu Words | `words` | Vocabulary (1084540807) | | Istruzione | `accent-words` (da creare) | 5 |

Gli accenti si aggiungono in `Design/tokens.json` con `sync_tokens.py` quando l'app parte, non prima.

Wave superate dalla roadmap punta di lancia, in cima a questo documento.

Le proposte che coincidevano con app già in coda (Cleanup e Swipewipe con Clean, CamScanner con Docs, StepsApp con Steps, Authenticator con Authenticator, i telecomandi TV con Remote, Flo con Cycle) restano dove sono nella coda qui sopra e non entrano nelle wave. Level è stata rifiutata il 14/10 e tolta dal sito il 15/10: "in corso" vale solo per la risposta al Resolution Center. Focus sta nella nicchia che ha fatto scartare Bear Focus Timer (Intervals), Alarm in quella della sveglia di Sbu Noise: vedi l'analisi.

## Candidate da Android: gratis lì, a pagamento su iOS (15 ottobre 2026)

Venti nicchie dove su Android c'è un'app gratuita (in grassetto le open source, soprattutto da F-Droid) e su iOS l'originale è a pagamento o ad abbonamento. Gli originali iOS sono verificati con la ricerca dell'App Store (US, 15/10); le valutazioni sono arrotondate. Stato: **candidate**, nessuna ricerca né spec ancora, tranne Paprika (`research/1303222868/`). Le app Android servono solo come riferimento: la spec si fa sull'originale iOS (ADR-0003) e non si decompila niente.

| # | App Sbu | Android, gratis | Originale iOS (ID, valutazioni) | Nota o rischio |
|---|---|---|---|---|
| 1 | Exif | **Scrambled Exif** | Exif Metadata (1455197364, 6 mila) | Toglie posizione e metadati prima di condividere; solo il selettore Foto |
| 2 | Vault | **Fossify Gallery** (cartelle nascoste) | Private Photo Vault (417571834, 1 milione) | Mercato enorme e ad abbonamento; nicchia affollata, 4.3(b) |
| 3 | Mood | Daylio è a pagamento anche su Android: equivalente gratis da verificare | Daylio (1194023242, 62 mila) | Diario dell'umore; confine con Habits |
| 4 | Scale | **openScale** | Happy Scale (532430574, 58 mila) | Peso con media mobile, HealthKit; dati sanitari mai su iCloud (5.1.3) |
| 5 | Baby | Baby Daybook | Baby Tracker - Newborn Log (779656557, 227 mila) | Poppate, sonno, pannolini; dichiarare che non è un dispositivo medico |
| 6 | Fuel | Fuelio | Fuelly (295905460, 30 mila) | Rifornimenti, consumi, scadenze; lontano dal registro viaggi di Speed |
| 7 | Player | **Auxio** | Doppler (1468459747), FLAC Player+ (577346786) | Musica propria da File, FLAC compreso |
| 8 | Comics | **Librera**, Seeneva | Panels (1236567663, 12 mila), YACReader (635717885) | Solo CBZ e PDF: CBR richiede unrar, con licenza non libera |
| 9 | Camera | **Open Camera** | Halide (885697368), ProCam (730712409, 35 mila) | Fotocamera manuale e RAW; lavoro grande, 4.1 se imita Halide |
| 10 | Net | **PortAuthority** | Network Analyzer Pro (557405467, 9 mila), Fing (430921107) | Scansione della propria rete (ADR-0007); ping limitato su iOS, entitlement multicast |
| 11 | Sky | **Sky Map** (Apache 2.0) | Star Walk 2 (1112481571, 96 mila), SkyView (404990064) | Cataloghi di stelle di pubblico dominio; sovrapposizione con Moon da valutare |
| 12 | Loyalty | **Catima** | Key Ring (372547556, 20 mila) | Tessere fedeltà con codice a barre; non chiamarla "Wallet" (5.2.5) |
| 13 | Fasting | app gratuite di digiuno | Zero (1168348542, 445 mila) | Storico, fasi, Salute; non deve sembrare un "timer semplice" (4.3) |
| 14 | Expenses | **My Expenses** | Money Manager (560481810, 20 mila), Spendee (635861140) | Spese giornaliere, non pagamenti ricorrenti: confine con Subscriptions |
| 15 | Inventory | app gratuite di inventario | Sortly (529353551, 10 mila) | Oggetti di casa con foto e posizione; lettura codici, confine con Scanner |
| 16 | Recipes | Recipe Keeper | Paprika 3 (1303222868, 4,99 $, 54 mila) | Import dal web con l'estensione di Safari sulla pagina aperta, senza rete dell'app |
| 17 | Pixel | Pixel Studio | Pixel Art Maker (897806469), 8bit Painter (894301273) | Editor di pixel art con animazione |
| 18 | GIF | **Image Toolbox** | ImgPlay (989843523, 45 mila) | Da video o foto a GIF; confine con Collage |
| 19 | Ringtone | **Ringdroid** (Apache 2.0) | Ringtones Maker (1358107315, 439 mila) | Abbonamenti aggressivi; passo finale per impostare la suoneria su iOS da verificare |
| 20 | Plants | app gratuite di promemoria | Planta (1410126781, 114 mila) | Solo calendario di cura e promemoria; l'identificazione richiede un server |

Le più forti per paywall e distanza dal resto del catalogo: Vault, Ringtone, Baby, Exif, Loyalty, Comics. Le più rischiose: Camera (grande, vicina a 4.1), Sky, Expenses e Mood (sovrapposizione con Moon, Subscriptions e Habits).

Scartate: registratore (Memo Vocali di Apple, sovrapposizione con Transcribe), calcolatrice e convertitori (nicchie piene), widget e temi (categoria sfondi, 4.3), farmaci (lo fa l'app Salute), metronomo (nicchia di Tuner, come TonalEnergy), meteo, podcast e RSS (servono la rete).

Con 34 app già pianificate se ne sceglie poche: la regola 4.3 punisce il numero di invii, non la qualità.
