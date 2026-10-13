# Sbu Clean: libro dei test su iPhone

Branch `app/clean-1.0`. Prova su un iPhone vero con una libreria Foto reale (meglio se con doppioni, raffiche, screenshot, video lunghi e Live Photo). Spunta ogni casella; se qualcosa non va, annota il numero del passo.

Prima di iniziare: **fai un backup della libreria o usa un iPhone di prova**. L'app elimina davvero (dopo due conferme), e le foto finiscono in Eliminati di recente per 30 giorni.

## Mappa delle schermate: Cleanup → Sbu Clean

| Cleanup (o Swipewipe) | Sbu Clean | Differenze volute |
|---|---|---|
| Carosello e paywall all'avvio | Schermata d'accesso: una riga su cosa fa, "Consenti l'accesso" | Niente paywall né prova |
| Dashboard con barra della memoria e categorie | Home: cifra "Spazio liberabile" con il punto fermo, barra dell'iPhone, elenco delle categorie, pillole "Scorri le foto" e "Cestino" | Elenco nativo al posto delle schede; contatti ed email fuori |
| Duplicate / Simili (foto migliore a sinistra, riquadro "N foto, X GB", "Elimina X GB" in basso) | Duplicati e simili: cifra "Selezionati", una scheda per Duplicati e una per Simili con la migliore e "N foto in M gruppi", "Elimina X GB" in basso | "Elimina" porta prima al cestino (revisione finale) |
| Gruppo aperto (migliore con spunta, le altre con la X) | Duplicati / Simili: per ogni gruppo la migliore con "Migliore" e le altre già selezionate (cestino nell'angolo) | Bin nell'angolo al posto della X rossa |
| Carta swipe di Swipewipe (data, n/totale, annulla, TIENI/ELIMINA) | Scorri: cifra "Nel cestino" con n di totale e data, carta, Elimina · Dopo · Tieni sempre · Tieni, annulla in alto | Niente condividi, cuore, IA |
| Timeline arcobaleno di Swipewipe | Mese per mese: Recenti, Casuale, Accadde oggi, Da decidere dopo, poi un mese per riga con anello e "x di y" o "Finito" | Elenco nativo, un solo accento |
| Riepilogo/revisione di Swipewipe e cestino di Cleanup | Cestino: cifra "Nel cestino", griglia, tocco per togliere, "Elimina N elementi" rosso con conferma | Spiega i 30 giorni di Eliminati di recente |
| Congratulazioni (Prima/Dopo, coriandoli, ore guadagnate) | Foglio "Eliminati": cifra "Spazio liberato", totale, nota sui 30 giorni | Niente coriandoli né ore |
| Video per dimensione | Video: dal più pesante, durata e data, tocco sulla miniatura per guardarlo | |
| Compressore (prima/dopo, Basso/Medio/Alto, "Avvia la compressione") | Comprimi: video, cifra "Dopo, circa", Bassa/Media/Alta, "Avvia la compressione" | L'originale va nel cestino solo se confermi |
| Live Photo in foto statiche (Prima/Dopo) | Live Photo: griglia con "Prima X, dopo Y", "Converti N in foto fisse" | |
| Keep list | Da tenere sempre | |
| Album di Swipewipe | Album: uno alla volta in swipe | |
| Widget memoria | Widget "Spazio libero" piccolo e medio | Niente widget batteria |

## 1. Prima apertura e permessi

1. [ ] Installa da zero. All'avvio vedi "SBU CLEAN", una riga su cosa fa e la pillola "Consenti l'accesso". Nessun paywall, nessun carosello.
2. [ ] Tocca "Consenti l'accesso": compare il dialogo di iOS con il testo "Sbu Clean guarda le tue foto e i tuoi video per trovare doppioni…". Scegli **Consenti accesso completo**. La home appare con "Leggo la libreria", poi "Misuro N elementi", poi "Cerco doppioni e foto simili: x di y", infine "Su N foto e video".
3. [ ] Con una libreria grande (migliaia di foto) l'app resta fluida mentre misura e analizza; puoi aprire altre schermate intanto.
4. [ ] Negato: in Impostazioni → Sbu Clean → Foto scegli "Nessuna". Torna nell'app: vedi "Sbu Clean non può vedere le tue foto…" e la pillola "Apri Impostazioni", che apre le Impostazioni dell'app.
5. [ ] Limitato: scegli "Accesso limitato" con poche foto. La home funziona solo su quelle e in cima all'elenco dice "Vedi solo le foto che hai scelto…" con "Apri Impostazioni". Le decisioni già prese su altre foto non si perdono (torna ad "Accesso completo" e ricontrolla il cestino).
6. [ ] Impostazioni (ingranaggio): "Accesso alle foto" dice Tutte le foto / Solo quelle scelte / Non consentito; c'è la promessa sbu.dev in fondo.

## 2. Home: spazio liberabile

1. [ ] La cifra "SPAZIO LIBERABILE" è chiusa dal quadrato nell'accento e somma: cestino + copie selezionate nei duplicati e simili + screenshot + registrazioni dello schermo (non i video né le Live Photo).
2. [ ] La barra "iPhone: X usati su Y" corrisponde a Impostazioni → Generali → Spazio iPhone (unità decimali, possono differire di poco).
3. [ ] Ogni riga mostra numero e spazio; le righe senza spazio non mostrano "Zero kB".
4. [ ] Dopo aver eliminato qualcosa la cifra scende.

## 3. Scorri (swipe)

1. [ ] "Scorri le foto" apre Mese per mese. Tocca "Recenti": compare la carta con la foto intera, sopra "NEL CESTINO" e "1 di N · data".
2. [ ] Trascina a destra: durante il trascinamento compare "Tieni" con la spunta; rilascia oltre metà: la carta esce, passa alla successiva, il contatore sale.
3. [ ] Trascina a sinistra: compare "Elimina" rosso con il cestino; la foto va nel cestino e la cifra "Nel cestino" cresce.
4. [ ] Trascinamento breve e rilascio: la carta torna al centro.
5. [ ] Pulsante annulla (freccia in alto a destra): torna alla foto precedente e ne annulla la scelta (se era nel cestino, esce dal cestino).
6. [ ] Pulsanti Elimina, Dopo, Tieni sempre, Tieni fanno lo stesso dello swipe. Vibrazione leggera a ogni carta.
7. [ ] Pressione lunga sulla carta: foglio Dettagli con data, dimensione, risoluzione, fotocamera, obiettivo, nome del file. Nessun luogo.
8. [ ] Un video nella coda si riproduce dentro la carta con i controlli di sistema. Un video solo in iCloud ("Ottimizza spazio") mostra il fotogramma e "Solo in iCloud: Sbu Clean non scarica i video".
9. [ ] A fine coda: "Hai visto tutto qui.", "Rivedi il cestino" (se non è vuoto) e "Torna all'elenco".
10. [ ] Chiudi l'app a metà di un mese e riaprila: il mese riprende dalle foto non ancora viste; l'anello mostra il progresso. **Aggiorna l'app con una nuova build e verifica che progressi e cestino restino.**
11. [ ] Casuale: un giro di 50 foto a caso non ancora viste. Accadde oggi: solo foto dello stesso giorno degli anni passati. Da decidere dopo: le foto messe con "Dopo".
12. [ ] Tieni sempre: la foto sparisce da tutte le code e categorie e compare in "Da tenere sempre"; lì scorri a sinistra e "Non tenere più" la fa tornare.

## 4. Duplicati e simili

1. [ ] "Duplicati e simili": cifra "SELEZIONATI", poi le schede Duplicati e Simili con la migliore marcata "Migliore" e "N foto in M gruppi".
2. [ ] Durante l'analisi vedi "Analizzo le foto: x di y" e "Interrompi"; interrompi, poi "Riprendi l'analisi": riparte da dove era (non rianalizza tutto).
3. [ ] Chiudi e riapri l'app: l'analisi successiva è quasi istantanea (cache). Scatta 3 foto simili e torna: l'app analizza solo quelle nuove.
4. [ ] Apri Duplicati: ogni gruppo ha la migliore senza segno e le copie con il cestino nell'angolo. Tocca una foto: cambia stato. "Tieni tutte" / "Tieni solo la migliore" su ogni gruppo.
5. [ ] Controlla a occhio che la migliore sia sensata: una preferita o modificata vince; tra raffiche con persone vince quella con occhi aperti e volto migliore; una mossa perde contro una nitida.
6. [ ] Duplicati veri (stessa foto salvata due volte, anche a mesi di distanza) finiscono in Duplicati; raffiche e foto quasi uguali scattate a pochi minuti in Simili. Segnala falsi positivi (foto diverse raggruppate) e falsi negativi: le soglie sono tarate su immagini di prova, non su una libreria vera.
7. [ ] "Elimina X GB" in basso porta al Cestino con le copie dentro; niente è ancora eliminato.

## 5. Cestino ed eliminazione

1. [ ] Il Cestino mostra la cifra "NEL CESTINO", la griglia e "Tocca un elemento per toglierlo dal cestino."; un tocco toglie la foto.
2. [ ] "Elimina N elementi" (rosso) chiede conferma "Eliminare N elementi dalla libreria Foto?". Conferma: compare il dialogo di iOS. Scegli **Non consentire**: non succede nulla, il cestino resta com'era.
3. [ ] Ripeti e consenti: si apre il foglio "Eliminati" con "SPAZIO LIBERATO", il totale con Sbu Clean e la nota sui 30 giorni in Eliminati di recente. Vibrazione di successo.
4. [ ] In Foto → Eliminati di recente ci sono le foto appena eliminate; svuotalo e verifica che lo spazio dell'iPhone torni.
5. [ ] "Spazio liberato" (in fondo alla home) mostra totale, ultima eliminazione e spazio libero dell'iPhone.
6. [ ] Elimina una foto dall'app Foto mentre Sbu Clean è aperta: la home si aggiorna da sola.

## 6. Screenshot, registrazioni, video, Live Photo

1. [ ] Screenshot: griglia dal più pesante, "Seleziona tutto", "Scorri uno per uno" apre la coda swipe degli screenshot; "Elimina X MB" porta al cestino.
2. [ ] Registrazioni dello schermo: lo stesso, con la durata sulla miniatura.
3. [ ] Video: dal più pesante, con dimensione, durata e data; tocco sulla miniatura apre il player; tocco sulla riga seleziona.
4. [ ] Comprimi (scorri un video verso sinistra o pressione lunga → Comprimi): scegli Bassa, Media, Alta; "Dopo, circa" cambia. "Avvia la compressione": alla fine "Copia compressa salvata" chiede se mettere l'originale nel cestino. Controlla in Foto che la copia abbia stessa data e luogo e una qualità accettabile, e che la stima sia vicina alla dimensione reale.
5. [ ] Live Photo: griglia con "Prima X, dopo Y"; "Converti N in foto fisse" salva le foto fisse (stessa data, luogo, preferita) e porta al cestino con le originali. Verifica in Foto.
6. [ ] Album: elenco degli album con il numero di elementi; toccando uno lo scorri. In fondo la nota "Eliminare dal cestino toglie la foto dalla libreria e da tutti gli album".

## 7. Widget

1. [ ] Aggiungi il widget "Spazio libero" piccolo e medio. Mostra lo spazio libero dell'iPhone come cifra con il quadrato, e "Puoi liberare X" dopo aver aperto l'app una volta. Il medio aggiunge la barra "usati su".
2. [ ] Dopo un'eliminazione o un'analisi, il widget si aggiorna entro qualche minuto. Tocco sul widget: apre l'app.
3. [ ] Schermata Home in modalità scura e colorata (tinta): il quadrato resta visibile.

## 8. Accessibilità, lingua, aspetto

1. [ ] Modalità scura: tutte le schermate restano leggibili, carta scura, un solo colore vivo.
2. [ ] Testo più grande (Impostazioni → Accessibilità → Schermo e dimensione testo → Testo più grande, al massimo): la home si ferma alla prima dimensione di accessibilità e l'elenco scorre; nello swipe la carta resta grande e i pulsanti mostrano il visore per contenuti grandi (tieni premuto).
3. [ ] VoiceOver: sulla carta senti "Foto, data, dimensione" e con le azioni (scorri su/giù) Tieni, Metti nel cestino, Decidi dopo, Tieni sempre, Dettagli. Nei gruppi senti "Foto 2 di 4" con valore "Da eliminare" o "Da tenere". Il quadrato non viene letto.
4. [ ] Inglese: Impostazioni → Lingua dell'app → English. Testi tutti in inglese, plurali giusti ("1 item", "2 items"), numeri con il punto decimale.
5. [ ] Controllo vocale: "Tocca Tieni", "Tocca Elimina" funzionano nello swipe.

## 9. Cose che il simulatore non ha potuto verificare

- [ ] Vision vero: nel simulatore Vision non gira (niente Neural Engine), quindi lì l'analisi usa una miniatura grigia al posto del feature print. Duplicati, simili e qualità del volto vanno provati solo sul telefono.
- [ ] Velocità e memoria con decine di migliaia di foto (misura dimensioni e analisi).
- [ ] Analisi in background: avvia l'analisi, vai alla home di iOS per un minuto, torna: o è finita o riprende da dove era.
- [ ] Il dialogo di sistema per l'eliminazione e il passaggio in Eliminati di recente.
- [ ] Video e foto solo in iCloud con "Ottimizza spazio iPhone": niente download, messaggi chiari.
- [ ] Compressione e conversione Live Photo su file veri.
- [ ] Widget sulla schermata Home.
