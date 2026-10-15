# Feedback di App Review e regole Apple 2026 (al 15 ottobre 2026)

Base per i `review_risks` delle spec in `specs/<slug>/spec.json` e per `docs/roadmap-review-2026-10.md`.

## a. Cosa dice la repo su Sbu Subscriptions e Sbu Scanner QR

Nessun rifiuto e nessuna osservazione di App Review su queste due app è registrata nella repo (niente in `docs/rejections/`, nelle issue GitHub o nei commit). Le 1.x sono sullo Store da maggio e giugno 2026 e sono state approvate. Subscriptions 2.0 è in Waiting for Review; Scanner 2.0 è pronta ma non inviata, per scelta, finché Apple non risponde sul lotto del 14/10.

L'unico feedback Apple nella repo è il rifiuto del 14/10 a sei app 1.0 (Clean, Speed, Moon, Habits, Noise, Level), stesso messaggio per tutte (`docs/rejections/2026-10-14-guideline-4.3/README.md`). Punti e regole:

| # | Punto | Regola |
|---|---|---|
| 1 | App duplicate dello stesso sviluppatore | 4.3(a) |
| 2 | Variante opportunistica in una categoria satura | 4.3(b) |
| 3 | App da template o servizio di generazione | 4.2.6 |
| 4 | Nove domande da rispondere nel Resolution Center invece di reinviare: cosa fa, per chi, differenza dal resto dello Store, beta test, rapporto con le altre app, perché non è una funzione di un'altra app, codice condiviso, codice di terzi, chi l'ha scritta | 4.3 / 4.2.6 |

Segnali che hanno scatenato il rifiuto, secondo l'analisi della repo: sei app create in 7 minuti e inviate insieme; blocco promesse identico in testa a ogni descrizione; stesso nome "Sbu X", stessa icona e stessi screenshot; nicchie affollate (livella, luna, rumore bianco, tachimetro, abitudini, pulizia foto); SbuKit condiviso.

Lezioni che le note di revisione di Subscriptions e Scanner 2.0 applicano già, e che valgono per le 12 nuove app:

- Riga "How it differs from the other Sbu apps" nelle note per la revisione.
- Ogni permesso o entitlement spiegato con il pulsante che lo usa (Scanner: Hotspot Configuration solo per "Connect").
- Permessi chiesti solo quando servono, mai al lancio (notifiche di Subscriptions).
- Dati dichiarati: dove stanno, cosa va su iCloud, che niente va in rete.
- Metadati senza nomi di app terze né prezzi (commit 909af97 su Clean).

## b. Regole correnti e modifiche 2026

Fonte principale: https://developer.apple.com/app-store/review/guidelines/ (Last Updated: June 8, 2026) e https://developer.apple.com/news/. Entrambe hanno risposto. Le pagine sui singoli entitlement e alcuni dettagli vengono da fonti secondarie, indicate.

| Tema | Stato al 15/10/2026 | App toccate |
|---|---|---|
| **4.3 Spam** | Riscritta l'8/6/2026: 4.3(a) e 4.3(b) con nuovi esempi; categorie "well established" (dating, torcia, effetti sonori, sfondi, **timer semplici**, oroscopi) accettate solo con esperienza "meaningfully different or improved"; Apple può rimuovere le app esistenti di quelle categorie se non aggiornate o senza utenti. [MacRumors](https://www.macrumors.com/2026/06/09/app-store-guidelines-low-quality-apps/), [9to5Mac](https://9to5mac.com/2026/06/09/apple-tightens-app-review-guidelines-against-apps-that-do-not-add-value-to-the-app-store/) | tutte; Focus (timer), Alarm, Sweep (nicchia affollata) |
| **4.1 Copycats** | 4.1(a) non copiare l'app popolare cambiando nome o UI; 4.1(b) impersonare altre app viola il Code of Conduct e può portare all'espulsione dal programma. Nessuna modifica 2026 trovata. | tutte, soprattutto quelle con flussi distintivi (Forest, Alarmy, SCRL) |
| **4.2.6** | Template o servizi di generazione rifiutati. Già citata nel rifiuto del 14/10. | tutte |
| **5.2.5** | Niente che somigli a prodotti o app Apple. | PDF (non imitare Anteprima/File), Remote (non imitare il telecomando di Apple TV in Centro di Controllo), Steps (non imitare gli anelli Attività) |
| **1.4.1** | App mediche che possono dare dati inaccurati: esame più severo, rifiuto se la metodologia non è validabile. | Cycle (fertilità, contraccezione), Steps |
| **5.1.1** | Privacy policy nei metadati e nell'app; consenso per qualunque raccolta. Nessuna modifica 2026 trovata. | tutte |
| **5.1.2(vi) / 5.1.3** | Dati HealthKit mai per marketing o data mining; **5.1.3(ii): niente dati sanitari personali su iCloud** e niente dati falsi scritti in HealthKit. | Cycle, Steps, Lift: il sync iCloud di ADR-0008 non vale per i dati sanitari |
| **2.5.1** | Solo API pubbliche, deve girare sull'OS corrente; HealthKit solo per salute e fitness e integrato con l'app Salute. | Steps, Cycle, Lift; Remote (niente API private per AirPlay o Apple TV) |
| **Dispositivi medici regolamentati** | Dal 26/3/2026 le app in categoria Salute e fitness o Medicina dichiarano in App Store Connect se sono un dispositivo medico regolamentato (EEA, UK, US); obbligatorio subito per le app nuove. [9to5Mac](https://9to5mac.com/2026/03/26/new-app-store-policy-requires-medical-device-disclosures-for-some-health-apps/) | Steps, Cycle, Lift: dichiarare "non è un dispositivo medico" e non promettere contraccezione o diagnosi |
| **SDK minimo** | Dal 28/4/2026 build con l'SDK iOS 26 (Xcode 26). Da aprile 2027 SDK iOS 27. iOS 27 è uscito a settembre 2026. | tutte: il target resta iOS 17 (ADR-0002), le API 26 dietro `if #available` |
| **Family Controls** | Il 30/3/2026 la License Agreement ha aggiunto la sezione 3.3.3(Q) con requisiti specifici per il framework Family Controls. L'entitlement di distribuzione va chiesto ad Apple, e ogni estensione (Shield, DeviceActivityMonitor) lo richiede a parte; sui forum Apple molte richieste restano senza risposta per settimane (marzo-maggio 2026). [Forum Apple](https://developer.apple.com/forums/thread/818553) | Focus: chiedere subito |
| **Age rating** | Nuovo questionario (13+, 16+, 18+, domande su temi medici e wellness) obbligatorio dal 31/1/2026; domande sui social obbligatorie da settembre 2026. | Cycle (temi medici), tutte |
| **AlarmKit** | API iOS 26 per sveglie che suonano come quelle di sistema anche in silenzioso e Full Focus; nessuna notizia 2026 sulle regole. Solo iOS 26+: con il target iOS 17 serve un ripiego. | Alarm, Noise (già provata in #424) |
| **Accesso limitato a Foto** | Nessuna notizia 2026. Resta la regola di sempre: l'app deve funzionare con accesso limitato o negato (5.1.1(iv)). | Sweep, Collage, Scan |
| **Foundation Models, Translation** | Foundation Models nella License Agreement dal 9/6/2025 (3.3.8(I)); nessun cambio 2026 trovato. | Words (definizioni ed esempi sul dispositivo), Scan (titoli dei documenti) |

Non trovato: nessuna regola specifica 2026 su app di pulizia foto, autenticatori o telecomandi TV. La parte della pagina delle Guidelines tra 5.3.4 e 5.4 non è stata letta per intero dallo strumento di lettura.

## c. Dati degli originali

`research/<slug>/listing.json` (iTunes Lookup US e IT) e `research/<slug>/reviews.json` (feed recensioni recenti, pagine 1-3, solo 1-3 stelle), scaricati il 15/10/2026 con curl. Tutti gli endpoint hanno risposto.
