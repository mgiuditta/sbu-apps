# Revisione della roadmap: 12 app contro le regole di App Review (ottobre 2026)

Fonti: `research/apple-review-2026.md` (feedback Apple nella repo e regole 2026), `research/<slug>/` (lookup e recensioni 1-3 stelle, US e IT, del 15/10/2026), `specs/<slug>/spec.json`. Tutti gli endpoint Apple hanno risposto: lookup iTunes, feed delle recensioni, pagina delle Guidelines (aggiornata l'8/6/2026) e News.

## Il contesto che cambia tutto

Il 14/10 Apple ha rifiutato sei app 1.0 insieme per 4.3(a), 4.3(b) e 4.2.6. A giugno 2026 la regola 4.3 è stata riscritta: le categorie "well established" (tra cui i **timer semplici**) passano solo con un'esperienza davvero diversa. Finché Apple non risponde alle sei, ogni nuovo invio aumenta il rischio sull'account. Da qui il ritmo: **un invio alla settimana, dopo la risposta**, con la riga "come si distingue dalle altre App Sbu" nelle note.

Cinque delle dodici app esistono già nella repo con un altro nome (vedi `docs/factory.md`): Sweep è Sbu Clean, Scan è Sbu Docs, Auth è Sbu Authenticator, Steps, Remote e Cycle sono già in coda.

## Tabella per app

| App | Rischio App Review più serio | Mitigazione | Entitlement / permessi da chiedere | Framework iOS 26 | Le 3 pains più citate (1-3★) |
|---|---|---|---|---|---|
| **Sweep** (= Clean) | 4.3(a)/(b) e 4.2.6: Clean 1.0 è già rifiutata, in una delle nicchie più affollate | Non reinviare: aspettare la risposta al Resolution Center. Sweep non è una nuova app, è la 1.0 di Clean | Foto (accesso completo, con percorso per accesso limitato) | nessuno | Non è gratis, elimina solo a pagamento (88); pubblicità (36); prova addebitata, impossibile disdire (31) |
| **Scan** (= Docs) | 4.3(a): "Sbu Scan" accanto a Sbu Scanner QR, e sovrapposizione con Sbu PDF; 4.3(b): Note e File scansionano gratis | Tenere il nome Sbu Docs; confine scritto con PDF (Docs crea PDF da carta e foto, PDF modifica PDF esistenti); archivio di file PDF (ADR-0006) | Fotocamera | Vision `RecognizeDocumentsRequest`, Foundation Models per i titoli (con ripiego iOS 17) | Pubblicità a ogni passo (96); funzioni base a pagamento (28); acquisto non riconosciuto o revocato (10) |
| **Steps** | 4.3(a): Sbu Habits legge già i passi da HealthKit con obiettivi e serie | Decidere prima: Steps come app a sé (storico, widget, Watch) o funzione di Habits. Dichiarare "non dispositivo medico" (regola del 26/3) | HealthKit (lettura), Motion | nessuno | Passi diversi da Salute/Watch (14); a pagamento (5); pubblicità (3) |
| **Auth** (= Authenticator) | 4.3(b): categoria affollata, e "perché non sta in Sbu Scanner che legge già i QR?" | Note: Keychain, codici offline, export cifrato, nessuna sincronizzazione di default; Scanner legge i QR otpauth ma non li conserva | Fotocamera; Face ID (`NSFaceIDUsageDescription`) | nessuno (AutoFill iOS 18 dietro `#available`) | Prezzo settimanale e prova addebitata subito (29); impossibile disdire (27); configurazione impossibile (18) |
| **Focus** | Family Controls: entitlement di distribuzione per l'app e per ognuna delle 3 estensioni, nuova clausola 3.3.3(Q) della License Agreement. Senza blocco app è un "timer semplice" (4.3 di giugno) e si sovrappone a Sbu Intervals. "Focus" è anche il nome di una funzione di iOS (5.2.5) | **Chiedere subito** l'entitlement (Family Controls Distribution) per app, Shield Configuration, Shield Action e DeviceActivityMonitor: sui forum Apple le risposte arrivano dopo settimane. Costruire solo dopo l'approvazione. Valutare un altro nome | **FamilyControls (Distribution)** ×4 target | nessuno | Troppi tocchi e schermate di premio (59); redesign 2026 peggiore (54); anello del tempo tolto (28) |
| **Alarm** | 4.3(a): Sbu Noise ha già una sveglia con dissolvenza e prova di AlarmKit, mentre la sua risposta 4.3 è in sospeso. Su iOS 17-25 la modalità silenziosa ammutolisce la notifica, quindi l'app ripete il primo difetto di Alarmy; il keep-alive con audio muto è vietato (2.5.4) | Alarm è un'app iOS 26: o si alza il minimo solo per lei (eccezione ad ADR-0002, da decidere), o la sveglia con missioni diventa una funzione di Noise | AlarmKit (`NSAlarmKitUsageDescription`), notifiche | **AlarmKit** con presentazione Live Activity; missioni come "sveglia di guardia" che si annulla a missione fatta | Non suona, suona tardi o solo vibra (28); batteria (16); impossibile spegnerla dal blocco schermo (10) |
| **Remote** | 4.3(b): telecomandi TV affollati; 2.1: il revisore può non avere una TV per provarlo | Video dimostrativo nelle note; nessun marchio TV nei metadati dello Store (solo sul sito); niente che imiti il telecomando di Apple TV (5.2.5); solo API pubbliche (2.5.1) | Rete locale (`NSLocalNetworkUsageDescription`, `NSBonjourServices`); multicast se serve SSDP (`com.apple.developer.networking.multicast`, da chiedere) | nessuno (controllo in Centro di Controllo, iOS 18) | Tasti bloccati dopo pochi tocchi (81); prezzo e addebiti (52); pubblicità e pop-up (47) |
| **Cycle** | 1.4.1 sulle previsioni del periodo fertile, più la dichiarazione di dispositivo medico (26/3/2026). 5.1.3(ii) vieta i dati sanitari personali su iCloud: **in conflitto con ADR-0008**, che cita il diario di Cycle come caso di sync | Mostrare il metodo, "stima" ovunque, nessuna % di gravidanza, nessuna promessa contraccettiva. Niente iCloud: backup JSON e Salute facoltativa. Correggere ADR-0008. Il nucleo di Flo è gratis: l'eccezione va approvata | HealthKit (lettura/scrittura ciclo), Face ID per il blocco | nessuno | Funzioni bloccate da Premium (41); pop-up Premium (32); previsioni sbagliate (15) |
| **Lift** | 4.3(b): tracker di allenamento affollati. Il database di wger non è utilizzabile: codice AGPL-3.0, dati Creative Commons per voce (probabilmente CC BY-SA) | Elenco di circa 200 esercizi scritto da noi, nell'app. iCloud solo per routine ed esercizi personali, mai per dati sanitari | HealthKit (scrittura allenamenti) | `HKWorkoutSession` su iPhone, AlarmKit per il recupero (P2, con ripiego) | "Gratis" ma abbonamento dopo l'onboarding (8); libreria esercizi scadente (6); allenamenti persi (5). Solo 8 recensioni su 34 sono di Hevy |
| **Collage** | 4.3(b): collage tra le nicchie più piene; 4.1: il carosello senza stacchi è il flusso distintivo di SCRL | Griglia di collage come prodotto, l'export a fette 1080×1350 come una delle opzioni | Nessuno: `PhotosPicker` senza permesso, scrittura "solo aggiunta" al salvataggio | nessuno | Funzioni spostate dietro abbonamento (17); crash e lentezza (9); export diverso dall'editor (8) |
| **PDF** | 4.3(a): sovrapposizione con Sbu Docs; 5.2.5: non imitare Anteprima, File o Markup | Confine: niente fotocamera, OCR, immagini-in-PDF o archivio (sono di Docs). Solo selettore file di sistema | Nessuno | nessuno (Translation da iOS 17.4) | App pagata, poi abbonamento per le funzioni base (21); file persi dopo aggiornamenti o cambio telefono (11); crash (10) |
| **Words** | 4.3(b): "parola del giorno" affollata. Licenze: WordNet (Princeton, permissiva ma non MIT/Apache), Wiktionary IT (CC BY-SA, share-alike) e Open English WordNet (CC BY 4.0) **violano la regola "solo MIT/Apache"** | Elenco curato da noi più il dizionario di sistema; oppure decidere un'eccezione alla regola delle licenze. La curatela supera i 5 giorni stimati | Notifiche | Foundation Models solo per una frase d'esempio in più, etichettata, spenta di default | Tutto a pagamento (22); addebito dopo la prova senza avviso (20); difficoltà sbagliata (12) |

## Entitlement e decisioni da prendere subito

1. **FamilyControls Distribution** per Focus, su quattro target. È l'unico entitlement con attese di settimane: si chiede oggi anche se Focus parte in Wave 2.
2. **Multicast networking** per Remote, se il rilevamento SSDP (Roku, DIAL) resta in v1. Altrimenti basta Bonjour.
3. **ADR-0008**: togliere Cycle dagli esempi di sync iCloud (5.1.3(ii)), e dire lo stesso per i dati sanitari di Steps e Lift.
4. **ADR-0002**: un'eccezione iOS 26 per Alarm, oppure Alarm dentro Noise.
5. **Licenze dei dati** per Words e Lift: la regola "solo MIT/Apache" esclude WordNet, Wiktionary e wger.
6. **Chats**, in Wave 1, non esiste nella repo: serve un Originale prima di contarla.

## Framework iOS 26 che sbloccano una funzione

- **AlarmKit**: è l'unico modo pubblico per una sveglia che suona in modalità silenziosa e con Full Focus. Serve ad Alarm; per Lift è facoltativo.
- **Foundation Models**: titoli automatici in Scan, frasi d'esempio in Words. Sono comodità, mai il nucleo, e c'è sempre un ripiego.
- **Vision `RecognizeDocumentsRequest`**: struttura del documento in Scan (con ripiego `VNRecognizeTextRequest`).
- **Translation**: non serve a nessuna delle dodici come nucleo. In PDF è un'opzione, da iOS 17.4.

Il target resta iOS 17 (ADR-0002): ogni API 26 va dietro `#available`. Dal 28/4/2026 si compila con l'SDK iOS 26, e da aprile 2027 servirà l'SDK 27.

## Ordine di sviluppo consigliato

Diverso dalle wave, per tre motivi: le sovrapposizioni interne che il 4.3 punisce, le attese di Apple sugli entitlement, e la forza del "sostituisce un abbonamento" nelle recensioni.

| # | App | Motivo |
|---|---|---|
| 1 | Auth (Authenticator) | 3 giorni. Nucleo davvero a pagamento (29 + 27 recensioni su prezzo e disdetta). Nessuna sovrapposizione seria |
| 2 | Scan (Docs) | Pain enorme (96 sulla pubblicità), già in coda, ADR pronto. Il nome resta Docs |
| 3 | **Remote, anticipata dalla Wave 3** | È il dolore da paywall più forte della lista (81 recensioni: tasti bloccati dopo pochi tocchi), ADR-0007 già scritto, nessuna sovrapposizione interna. Sono 10 giorni, quindi conviene partire presto |
| 4 | PDF | Dopo Docs, così il confine tra le due si scrive una volta sola |
| 5 | Cycle | Dopo la correzione di ADR-0008 e la decisione sull'eccezione (il nucleo di Flo è gratis) |
| 6 | Lift | Dopo aver scritto l'elenco degli esercizi |
| 7 | Collage | Nicchia affollata: serve il prodotto a griglia per non cadere in 4.1 |
| 8 | Words | Dopo la decisione sulle licenze |
| – | Sweep (Clean) | Non si sviluppa: aspetta la risposta di Apple al 4.3 del 14/10 |
| – | **Focus, posticipata** | Si chiede l'entitlement oggi e si costruisce solo dopo l'approvazione. Senza blocco app è un timer semplice, e si sovrappone a Intervals |
| – | **Alarm, posticipata** | Su iOS 17-25 non può suonare in modalità silenziosa; si sovrappone alla sveglia di Noise. Prima va decisa l'eccezione iOS 26 oppure la fusione con Noise |
| – | Steps, posticipata | Il nucleo di StepsApp è gratis e Habits legge già i passi. Da decidere: app a sé o funzione di Habits |

Gli invii restano uno alla settimana, e solo dopo che Apple ha risposto sul lotto del 14/10.
