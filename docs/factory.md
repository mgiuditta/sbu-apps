# Fabbrica di app Sbu

Obiettivo: ogni app a pagamento che non ha bisogno di un server ha la sua App Sbu gratuita. Riferimento pubblico: [ArtCraft](https://propakistani.pk/2026/10/09/free-open-source-copies-of-photoshop-premiere-and-lightroom-are-here/), sette cloni gratuiti e open source delle app Adobe costruiti con Claude Opus 5.5.

Traguardi: **25 app in revisione entro il 31 ottobre 2026, 100 entro fine anno.** Il codice non è il collo di bottiglia: lo sono la revisione Apple e il test insieme.

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
| 6 | Screenshot, cornici, metadati IT/EN | agente | `fastlane snapshot && fastlane frames` |
| 7 | **Test insieme** su TestFlight, checklist sotto | **Matteo**, 15-20 min | `fastlane beta` |
| 8 | Upload senza invio | agente | `fastlane release` |
| 9 | **Invio in revisione** | **Matteo**, da App Store Connect | |
| 10 | Rifiuto: analisi e correzione, poi di nuovo al passo 7 | agente | skill `rejection-handler` |

Ritmo: 3-4 test insieme al giorno. Gli agenti lavorano in parallelo, un worktree per app.

## Regole contro il 4.3 (spam)

Apple rifiuta, e al limite chiude l'account, se uno sviluppatore pubblica molte app simili in poco tempo. Il brand comune va bene; le funzioni clonate tra noi no.

- Una **Cosa sola** diversa per app, mai due app nella stessa nicchia (ADR-0004). Due timer, due fotocamere o due tracker dello stesso tipo: se ne sceglie uno.
- Ogni app ha una funzione vera, non banale: niente app che sono una sola schermata con un numero.
- Invii scaglionati: **3 a settimana** finché non arrivano rifiuti 4.3, poi si sale. Al primo rifiuto 4.3 ci si ferma e si rivede la coda.
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
| Scanner | CamScanner | |
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
