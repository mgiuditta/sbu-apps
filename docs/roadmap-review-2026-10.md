# Revisione della roadmap: 7 app nuove contro le regole di App Review (ottobre 2026)

Fonti: `research/apple-review-2026.md` (feedback Apple nella repo e regole 2026), `research/<slug>/` (lookup e recensioni 1-3 stelle, US e IT, del 15/10/2026), `specs/<slug>/spec.json`. Tutti gli endpoint Apple hanno risposto: lookup iTunes, feed delle recensioni, pagina delle Guidelines (aggiornata l'8/6/2026) e News. La pagina Google Play di WhatStat non si è lasciata leggere: per Chats valgono la nota di fattibilità e gli originali iOS.

Fuori da questa revisione restano le proposte che coincidono con app già in coda (Clean, Docs, Steps, Authenticator, Remote, Cycle): vedi `docs/factory.md`.

## Il contesto che cambia tutto

Il 14/10 Apple ha rifiutato sei app 1.0 insieme per 4.3(a), 4.3(b) e 4.2.6. A giugno 2026 la regola 4.3 è stata riscritta: le categorie "well established" (tra cui i **timer semplici**) passano solo con un'esperienza davvero diversa. Finché Apple non risponde alle sei, ogni nuovo invio aumenta il rischio sull'account. Da qui il ritmo: **un invio alla settimana, dopo la risposta**, con la riga "come si distingue dalle altre App Sbu" nelle note.

## Tabella per app

| App | Rischio App Review più serio | Mitigazione | Entitlement / permessi | Framework iOS 26 | Le 3 pains più citate (1-3★) |
|---|---|---|---|---|---|
| **Chats** | 5.2.5 e marchi: "WhatsApp" nel nome, nel sottotitolo o nelle keyword. 5.1.2: gli export contengono dati personali di altre persone. 2.1: il revisore non ha una chat da esportare | Il nome non contiene "WhatsApp"; la guida all'export sta sul sito e nell'aiuto in-app, con la nota sul marchio Meta. Niente rete, niente iCloud, "Data Not Collected". Una chat di esempio scritta da noi nell'app | Nessuno (tipi di documento per .zip e .txt) | nessuno | Tutto a pagamento, una analisi ogni 24 ore (21); import che si blocca o sbaglia (17); funziona solo con WhatsApp (8) |
| **Focus** | Family Controls: entitlement di distribuzione per l'app e per ognuna delle 3 estensioni, nuova clausola 3.3.3(Q) della License Agreement. Senza blocco app è un "timer semplice" (4.3 di giugno) e si sovrappone a Sbu Intervals. "Focus" è anche il nome di una funzione di iOS (5.2.5) | **Chiedere subito** l'entitlement (Family Controls Distribution) per app, Shield Configuration, Shield Action e DeviceActivityMonitor: sui forum Apple le risposte arrivano dopo settimane. Costruire solo dopo l'approvazione. Valutare un altro nome | **FamilyControls (Distribution)** ×4 target | nessuno | Troppi tocchi e schermate di premio (59); redesign 2026 peggiore (54); anello del tempo tolto (28) |
| **Alarm** | 4.3(a): Sbu Noise ha già una sveglia con dissolvenza e prova di AlarmKit, mentre la sua risposta 4.3 è in sospeso. Su iOS 17-25 la modalità silenziosa ammutolisce la notifica, quindi l'app ripete il primo difetto di Alarmy; il keep-alive con audio muto è vietato (2.5.4) | Alarm è un'app iOS 26: o si alza il minimo solo per lei (eccezione ad ADR-0002, da decidere), o la sveglia con missioni diventa una funzione di Noise | AlarmKit (`NSAlarmKitUsageDescription`), notifiche | **AlarmKit** con presentazione Live Activity; missioni come "sveglia di guardia" che si annulla a missione fatta | Non suona, suona tardi o solo vibra (28); batteria (16); impossibile spegnerla dal blocco schermo (10) |
| **Lift** | 4.3(b): tracker di allenamento affollati. Il database di wger non è utilizzabile: codice AGPL-3.0, dati Creative Commons per voce (probabilmente CC BY-SA). Dichiarazione di dispositivo medico (categoria Salute e fitness, 26/3/2026); 5.1.3(ii) vieta i dati sanitari su iCloud | Elenco di circa 200 esercizi scritto da noi, nell'app. iCloud solo per routine ed esercizi personali, mai per dati sanitari. Dichiarare "non dispositivo medico" | HealthKit (scrittura allenamenti) | `HKWorkoutSession` su iPhone, AlarmKit per il recupero (P2, con ripiego) | "Gratis" ma abbonamento dopo l'onboarding (8); libreria esercizi scadente (6); allenamenti persi (5). Solo 8 recensioni su 34 sono di Hevy |
| **Collage** | 4.3(b): collage tra le nicchie più piene; 4.1: il carosello senza stacchi è il flusso distintivo di SCRL | Griglia di collage come prodotto, l'export a fette 1080×1350 come una delle opzioni | Nessuno: `PhotosPicker` senza permesso, scrittura "solo aggiunta" al salvataggio | nessuno | Funzioni spostate dietro abbonamento (17); crash e lentezza (9); export diverso dall'editor (8) |
| **PDF** | 4.3(a): sovrapposizione con Sbu Docs; 5.2.5: non imitare Anteprima, File o Markup | Confine: niente fotocamera, OCR, immagini-in-PDF o archivio (sono di Docs). Solo selettore file di sistema | Nessuno | nessuno (Translation da iOS 17.4) | App pagata, poi abbonamento per le funzioni base (21); file persi dopo aggiornamenti o cambio telefono (11); crash (10) |
| **Words** | 4.3(b): "parola del giorno" affollata. Licenze: WordNet (Princeton, permissiva ma non MIT/Apache), Wiktionary IT (CC BY-SA, share-alike) e Open English WordNet (CC BY 4.0) **violano la regola "solo MIT/Apache"** | Elenco curato da noi più il dizionario di sistema; oppure decidere un'eccezione alla regola delle licenze. La curatela supera i 5 giorni stimati | Notifiche | Foundation Models solo per una frase d'esempio in più, etichettata, spenta di default | Tutto a pagamento (22); addebito dopo la prova senza avviso (20); difficoltà sbagliata (12) |

## Chats: cosa cambia rispetto alla nota di fattibilità

- **Dipendenze:** GRDB.swift e ZIPFoundation sono MIT, ma CLAUDE.md ammette solo SbuKit e i framework Apple. Al loro posto: `sqlite3` di sistema (FTS5 incluso) e un lettore ZIP sul framework Compression (circa 150 righe, testate su export veri).
- **Target:** iOS 17 (ADR-0002), non iOS 26.
- **Schermata strumento:** niente dashboard a campo colorato. La cifra (totale messaggi) è un `SbuStat` su `surface`.
- **Metadati:** la regola di `docs/factory.md` vieta nomi di app terze nei metadati dello Store, quindi "WhatsApp" non va neanche nella descrizione. La nota di fattibilità lo metteva nella descrizione: va deciso.
- **Originale:** WhatStat esiste solo su Android, e ADR-0003 vuole spec da dati App Store. L'Originale è quindi The Cringe: Chat Wrapped (6766070732, statistiche dietro abbonamento); ChatScope e ChatRecap AI sono Concorrenti.

## Entitlement e decisioni da prendere subito

1. **FamilyControls Distribution** per Focus, su quattro target. È l'unico entitlement con attese di settimane: si chiede oggi anche se Focus parte in Wave 2.
2. **ADR-0002**: un'eccezione iOS 26 per Alarm, oppure Alarm dentro Noise.
3. **ADR-0008**: escludere i dati sanitari dal sync iCloud (5.1.3(ii)). Tocca Lift, e anche Cycle e Steps già in coda.
4. **Licenze dei dati** per Words e Lift: la regola "solo MIT/Apache" esclude WordNet, Wiktionary e wger.
5. **"WhatsApp" nei metadati** di Chats: no, come dice la regola, oppure un'eccezione solo per la descrizione.

## Framework iOS 26 che sbloccano una funzione

- **AlarmKit**: è l'unico modo pubblico per una sveglia che suona in modalità silenziosa e con Full Focus. Serve ad Alarm; per Lift è facoltativo.
- **Foundation Models**: frasi d'esempio in Words. Sono comodità, mai il nucleo, e c'è sempre un ripiego. In Chats è escluso: giudicherebbe altre persone dai loro messaggi.
- **Translation**: non serve come nucleo a nessuna. In PDF è un'opzione, da iOS 17.4.

Il target resta iOS 17 (ADR-0002): ogni API 26 va dietro `#available`. Dal 28/4/2026 si compila con l'SDK iOS 26, e da aprile 2027 servirà l'SDK 27.

## Ordine di sviluppo consigliato

Diverso dalle wave, per tre motivi: le sovrapposizioni interne che il 4.3 punisce, le attese di Apple sugli entitlement, e la forza del "sostituisce un abbonamento" nelle recensioni.

| # | App | Motivo |
|---|---|---|
| 1 | Chats | Wave 1. Nessuna sovrapposizione con altre App Sbu, nicchia piccola, paywall contestato (21 recensioni su 45). Il rischio vero è il parser: servono export veri come fixture prima di iniziare |
| 2 | **PDF, anticipata dalla Wave 3** | Paywall forte (21 recensioni: app pagata, poi abbonamento) e nessun entitlement da aspettare. Il confine con Docs è già scritto nella spec |
| 3 | Collage | Nessun permesso e nessun entitlement; serve il prodotto a griglia per stare lontano da 4.1 |
| 4 | Lift | Dopo aver scritto l'elenco degli esercizi e corretto ADR-0008 |
| 5 | Words | Dopo la decisione sulle licenze |
| – | **Focus, posticipata** | Si chiede l'entitlement oggi e si costruisce solo dopo l'approvazione. Senza blocco app è un timer semplice, e si sovrappone a Intervals |
| – | **Alarm, posticipata** | Su iOS 17-25 non può suonare in modalità silenziosa; si sovrappone alla sveglia di Noise. Prima va decisa l'eccezione iOS 26 oppure la fusione con Noise |

Gli invii restano uno alla settimana, e solo dopo che Apple ha risposto sul lotto del 14/10.
