# Test book: Sbu Habits 1.0

Collaudo manuale su iPhone vero prima di TestFlight. È la prima app che esce: va provato tutto il flusso, da zero. Ogni prova ha precondizioni, passi, risultato atteso e una casella. Se qualcosa non va, annota il numero della prova e cosa hai visto (screenshot se puoi).

Cosa serve: un iPhone con iOS 17 o più recente (ideale: il 15 Pro Max e, se c'è, un iPhone piccolo tipo SE), un Apple Watch abbinato, un account iCloud con iCloud Drive acceso, una seconda persona (o un secondo ID Apple) con Sbu Habits per la condivisione.

Prima di iniziare: elimina Sbu Habits dall'iPhone se c'è già, poi installa la build da provare. Impostazioni → Accessibilità → Schermo e dimensione testo → Testo più grande: spento (testo standard) per le prove 1–30.

---

## A. Primo avvio

### 1. Schermata vuota
- Precondizioni: app appena installata, mai aperta.
- Passi: apri Sbu Habits.
- Atteso: nessuna richiesta di permessi all'avvio. In alto "SERIE PIENA", 0 giorni con il quadratino verde dopo "giorni" (uno solo sulla schermata). Sotto, "Aggiungi la prima abitudine" e l'anello con il +. In basso l'ingranaggio a sinistra e la stella a destra (stella disattivata). Sfondo carta, nessun colore oltre al verde dell'app.
- [ ] Fatto

### 2. Impostazioni e promessa
- Passi: tocca l'ingranaggio.
- Atteso: foglio Impostazioni con nome e versione 1.0, Inizio della giornata, Ordine delle abitudini (disattivato senza abitudini), Dati (Sincronizza con iCloud spento, Esporta, Importa), Licenze, link alla privacy. Nel piede le pillole della promessa intere, non tagliate dall'angolo della sezione. Con iCloud spento la pillola dice "Dati solo su questo iPhone". Fine chiude.
- [ ] Fatto

## B. Aggiungere un'abitudine

### 3. Il foglio Aggiungi
- Passi: tocca l'anello con il +.
- Atteso: foglio "Aggiungi" con cinque schede rotonde (Generale, Salute, Alimentazione, A tempo, Da evitare), la scelta in verde. Sotto: la frase che spiega la scheda, la riga "Personalizzata", poi i Modelli. In alto a destra la lente.
- [ ] Fatto

### 4. Le schede e la ricerca
- Passi: tocca ogni scheda. Poi tocca la lente e scrivi "acqua", poi "zzzz".
- Atteso: ogni scheda cambia frase e Modelli. In Salute ogni Modello ha il cuore. La ricerca trova i Modelli con il tipo sotto il titolo; con "zzzz" dice che non trova niente.
- [ ] Fatto

### 5. Un Modello
- Passi: scheda Generale → "Leggere".
- Atteso: modulo "Nuova abitudine" con anello e titolo in maiuscolo, il campo Titolo, le righe Tipo, Obiettivo, Giorni, Notifiche (e Salute se disponibile). Pulsante verde fisso "Aggiungi abitudine" in basso. Il pulsante indietro dice "Aggiungi".
- Passi: tocca "Aggiungi abitudine".
- Atteso: il foglio si chiude, Leggere è sulla griglia con l'anello vuoto.
- [ ] Fatto

### 6. Titolo automatico
- Passi: Aggiungi → Personalizzata. Non scrivere il titolo. Tocca "…" sull'anello e scegli un simbolo (prova anche la ricerca dei simboli). Tocca Aggiungi abitudine.
- Atteso: il campo Titolo mostra "Automatico" e il contatore 0/30; l'abitudine prende il nome del simbolo.
- [ ] Fatto

### 7. Più volte al giorno
- Passi: Aggiungi → Alimentazione → acqua (o Personalizzata), Obiettivo → 8 volte. Aggiungi.
- Atteso: l'anello è diviso in 8 segmenti.
- [ ] Fatto

### 8. Giorni
- Passi: Personalizzata → Giorni: prova Ogni giorno, Giorni scelti (alcuni giorni), N volte a settimana (stepper: dice "3 volte"), N volte al mese, Un giorno solo (data). Salva una con giorni scelti che NON include oggi.
- Atteso: la riga Giorni riassume la scelta. L'abitudine non prevista oggi non appare nella griglia di oggi (resta nelle Statistiche).
- [ ] Fatto

### 9. Fino a 24 abitudini e pagine
- Passi: aggiungi abitudini fino a superare 6 posti.
- Atteso: la settima va a pagina 2; i puntini sotto la griglia mostrano la pagina; si passa con lo scorrimento laterale. "Aggiungi" occupa il primo posto libero. Gli anelli di una pagina hanno tutti la stessa misura, anche con titoli lunghi.
- [ ] Fatto

## C. Segnare

### 10. Tenere premuto
- Passi: tieni premuto l'anello di Leggere per mezzo secondo.
- Atteso: l'anello si riempie mentre tieni, vibrazione di successo, il simbolo diventa la spunta, la Serie piena in alto sale a 1 se è l'unica abitudine prevista oggi.
- [ ] Fatto

### 11. Annullare
- Passi: tieni premuto di nuovo Leggere. Poi segna l'acqua 3 volte e toccala una volta: menu → "Annulla l'ultimo segno".
- Atteso: Leggere torna da fare. L'acqua scende a 2 segmenti.
- [ ] Fatto

### 12. Salta oggi
- Passi: tocca un'abitudine → "Salta oggi". Poi di nuovo → "Annulla il salto di oggi".
- Atteso: l'anello mostra il salto e la serie non si rompe; annullando torna da fare.
- [ ] Fatto

### 13. Nota del giorno
- Passi: tocca un'abitudine → "Scrivi nota", scrivi due righe, Fine. Riapri → "Modifica nota", cancella tutto, Fine.
- Atteso: con la nota compare il simboletto della nota accanto al titolo; dopo averla svuotata sparisce. Sull'iPhone piccolo l'ultima riga resta sopra Fine e la tastiera.
- [ ] Fatto

### 14. Abitudine da evitare
- Passi: Aggiungi → Da evitare → "Niente dolci" (o Caffè con Limite 2). Tieni premuto tre volte.
- Atteso: davanti al titolo c'è ⊘. Ogni pressione è una volta in cui hai ceduto; entro il limite l'anello mostra il margine, oltre il limite l'anello è pieno con la croce e vibrazione di avviso. La serie si rompe subito.
- [ ] Fatto

## D. Abitudini a tempo

### 15. Timer
- Passi: Aggiungi → A tempo → Leggere (o Personalizzata con Durata 1 minuto). Sulla griglia tocca il play verde sull'anello.
- Atteso: iOS chiede le notifiche la prima volta (solo ora, non all'avvio). Si apre il Timer con Pausa, Annulla e "Segna come fatta". Pausa/Riprendi funzionano.
- [ ] Fatto

### 16. Fine del conto alla rovescia, app chiusa
- Precondizioni: notifiche consentite, timer da 1 minuto.
- Passi: avvia, blocca l'iPhone e aspetta.
- Atteso: sulla schermata di blocco e nella Dynamic Island c'è il conto alla rovescia (Live Activity) con Pausa/Riprendi. Alla fine arriva la notifica e l'abitudine risulta fatta quando riapri l'app.
- [ ] Fatto

### 17. Play sugli anelli piccoli (punto B)
- Precondizioni: iPhone piccolo (SE) oppure molte abitudini sulla pagina.
- Passi: guarda il play su un anello piccolo; toccalo appena fuori dal cerchio verde.
- Atteso: su un anello piccolo il play è più piccolo e non copre il simbolo né la Serie; il tocco funziona anche un po' fuori dal disco (area di 44 punti).
- [ ] Fatto

### 18. Timer dopo il riavvio
- Passi: avvia un timer, chiudi l'app dal multitasking, riaprila.
- Atteso: il Timer è ancora lì e prosegue.
- [ ] Fatto

## E. Notifiche (servono orari reali)

### 19. Promemoria personalizzato
- Passi: modifica un'abitudine → Notifiche → orari personalizzati → un orario fra 3 minuti. Salva. Non segnarla.
- Atteso: la notifica arriva all'ora scelta. Se la segni prima, non arriva. Nei giorni non previsti non arriva.
- [ ] Fatto

### 20. Automatiche, sensibili al tempo, suono
- Passi: Notifiche → Automatiche; attiva Sensibili al tempo e scegli un suono di Sbu (Carta, Punto). Lascia passare qualche giorno segnandola sempre alla stessa ora.
- Atteso: il promemoria automatico arriva verso l'ora in cui di solito la fai, con il suono scelto; con una Full Immersion che consente le notifiche sensibili al tempo arriva lo stesso.
- [ ] Fatto

### 21. Notifiche negate
- Passi: Impostazioni iPhone → Sbu Habits → Notifiche spente. Apri Notifiche nel modulo.
- Atteso: la schermata dice "Attiva le notifiche di Sbu Habits nelle Impostazioni dell'iPhone." Nessun crash, nessun pulsante morto.
- [ ] Fatto

## F. Salute

### 22. Collegare a Salute
- Passi: Aggiungi → Salute → Camminare (passi), obiettivo basso (es. 500). Aggiungi abitudine.
- Atteso: solo ora iOS chiede l'accesso in lettura (i testi IT dicono che legge solo le misure che colleghi e che i dati restano sull'iPhone). Consenti. Davanti al titolo il cuore. Se hai già superato 500 passi, si segna da sola.
- [ ] Fatto

### 23. In background
- Passi: con l'app chiusa, cammina fino all'obiettivo (o aggiungi un valore in Salute: Sfoglia → Attività → Passi → Aggiungi dati).
- Atteso: l'abitudine risulta fatta anche senza aprire l'app (il widget lo mostra). Se attivo "Ti avvisa quando Salute la segna fatta", arriva l'avviso.
- [ ] Fatto

### 24. Simbolo dalla misura (punto E)
- Passi: Personalizzata con simbolo predefinito → Salute → collega a Sonno. Poi un'altra con un simbolo scelto da te → collega a Passi.
- Atteso: la prima prende il simbolo della misura; la seconda tiene il tuo.
- [ ] Fatto

### 25. Accesso negato
- Passi: Impostazioni iPhone → Salute → Accesso ai dati → Sbu Habits: spegni tutto. Torna nell'app.
- Atteso: l'abitudine collegata si segna a mano come le altre; il modulo dice "Se neghi l'accesso, la segni tu."
- [ ] Fatto

## G. Statistiche

### 26. Tutte le abitudini e per abitudine
- Precondizioni: qualche abitudine con segni su più giorni.
- Passi: tocca la stella. Cambia periodo dal menu. Scorri le pagine delle singole abitudini.
- Atteso: una cifra sola (completamento) con il punto verde; serie migliore, totali, grafico a linea, barre per giorno della settimana, curva per ora (6 e 18, o 6 AM / 6 PM in inglese), storico a griglia. Con meno di due punti: "Troppo pochi giorni per la linea". Senza completamenti: un solo riquadro vuoto per Completamenti. Periodo senza giorni previsti: il trattino senza punto.
- [ ] Fatto

### 27. Condividi come immagine
- Passi: nelle Statistiche tocca Condividi.
- Atteso: si apre il foglio di condivisione con l'immagine della pagina mostrata; salvala in Foto e controlla che sia leggibile in chiaro e scuro.
- [ ] Fatto

## H. Dati

### 28. Esporta e importa
- Passi: Impostazioni → Esporta → salva in File. Elimina un'abitudine. Impostazioni → Importa → scegli il file.
- Atteso: Importa mostra cosa contiene il file e chiede "Sostituisci i dati attuali". Confermando torna tutto com'era. Prova anche un file non valido (es. un PDF): compare un avviso d'errore chiaro, i dati restano come sono.
- [ ] Fatto

### 29. Inizio della giornata e ordine
- Passi: Inizio della giornata → 04:00. Segna un'abitudine fra mezzanotte e le 4 (o cambia l'ora dell'iPhone). Poi Ordine delle abitudini: trascina per riordinare.
- Atteso: il segno prima delle 4 conta per il giorno prima. La griglia segue il nuovo ordine.
- [ ] Fatto

### 30. Modificare ed eliminare
- Passi: tocca un'abitudine → Modifica, cambia il titolo, Salva abitudine. Di nuovo Modifica → Elimina.
- Atteso: la conferma nomina l'abitudine ("Eliminare “…”?"); a testo standard è un fumetto sopra il pulsante, a testo grande un avviso. Confermando sparisce; lo storico delle altre resta.
- [ ] Fatto

## I. iCloud (spento finché non lo attivi)

### 31. Sincronizza con iCloud
- Precondizioni: iCloud e iCloud Drive attivi; un secondo dispositivo (iPad o altro iPhone) con Sbu Habits e lo stesso ID Apple.
- Passi: Impostazioni → Sincronizza con iCloud: attiva su entrambi. Aggiungi e segna sul primo.
- Atteso: l'interruttore parte spento. Acceso, la pillola diventa "Dati solo sui tuoi dispositivi". Le abitudini compaiono sull'altro dispositivo e i segni si uniscono, senza doppioni. Spegnendo, smette.
- [ ] Fatto

### 32. Senza iCloud
- Passi: esci da iCloud (o spegni iCloud Drive) e apri Impostazioni → Dati.
- Atteso: l'interruttore è spento e non si attiva; il piede dice perché.
- [ ] Fatto

### 33. Condividere un'abitudine
- Passi: Modifica di un'abitudine → Condividi → invita la seconda persona (Messaggi). Lei apre l'invito.
- Atteso: si apre la schermata di condivisione di iOS. Da lei l'abitudine compare sulla griglia con il distintivo della persona, in sola lettura: tenendola premuta dice "Condivisa da un'altra persona: solo da vedere". Toccandola si apre "Abitudine condivisa" con le statistiche e la fila di emoji: sceglierne una cambia il distintivo. Quando tu segni, da lei si aggiorna (anche dopo qualche minuto).
- [ ] Fatto

### 34. Rimuovere un'abitudine condivisa
- Passi (dalla seconda persona): Abitudine condivisa → Rimuovi → conferma.
- Atteso: chiede conferma nominando l'abitudine; sparisce dal suo iPhone, a te non cambia niente.
- [ ] Fatto

## J. Widget, Watch, Siri

### 35. Widget interattivi
- Passi: aggiungi i widget "Abitudini di oggi" e "Un'abitudine". Tocca un'abitudine nel widget.
- Atteso: si segna senza aprire l'app; l'app, riaperta, è allineata.
- [ ] Fatto

### 36. Widget di un'abitudine
- Passi: aggiungi Serie, Completamento, Giorni della settimana, Calendario; tienili premuti → Modifica widget → scegli l'abitudine.
- Atteso: mostrano i numeri dell'abitudine scelta; in modalità tinta e scura restano leggibili. A mezzanotte (o all'inizio della giornata scelto) passano al giorno nuovo.
- [ ] Fatto

### 37. Apple Watch
- Passi: apri Sbu Habits sul Watch. Tocca un'abitudine. Aggiungi la complicazione al quadrante.
- Atteso: vedi la Serie piena e le abitudini di oggi ricevute dall'iPhone; un tocco segna e l'iPhone si aggiorna. La complicazione mostra la Serie piena.
- [ ] Fatto

### 38. Comandi rapidi
- Passi: app Comandi → aggiungi l'azione di Sbu Habits "Segna" su un'abitudine; eseguila. Prova anche "Ehi Siri".
- Atteso: l'abitudine si segna; la griglia lo mostra.
- [ ] Fatto

## K. Accessibilità e lingue

### 39. Testo grande (difetti di #439)
- Precondizioni: Impostazioni → Accessibilità → Schermo e dimensione testo → Testo più grande: attivo, cursore al massimo. Poi ripeti a metà delle dimensioni grandi.
- Passi: rifai le prove 3, 5, 8, 26, 30, 33 e 34.
- Atteso: Aggiungi: nelle righe il simbolo sta sopra il titolo e nessuna parola è spezzata a metà ("Personalizzata" intera). Modulo: nessuna riga finisce sotto il pulsante; a queste dimensioni "Aggiungi abitudine" / "Salva abitudine" non è fisso ma sta in fondo al modulo, dopo l'ultima riga (scorri fino in fondo). Le righe mostrano nome e valore interi. La griglia diventa una colonna sola che scorre. Abitudine condivisa: le emoji restano intere nei cerchi. Eliminare e Rimuovi chiedono conferma e confermando funzionano.
- [ ] Fatto

### 40. VoiceOver
- Passi: attiva VoiceOver. Scorri la griglia, usa il rotore Azioni su un'abitudine ("Segna come fatta", "Annulla l'ultimo segno", "Salta oggi", "Scrivi nota", "Modifica"). Apri Aggiungi, il modulo, le Statistiche.
- Atteso: ogni anello legge titolo, stato, Serie, nota e Salute; il play è un pulsante a parte ("Avvia …"). Il quadratino verde non viene letto. Le schede di Aggiungi leggono il nome e "selezionato".
- [ ] Fatto

### 41. Modalità scura
- Passi: Centro di Controllo → Modalità scura. Rivedi griglia, Aggiungi, modulo, Statistiche, Timer, Impostazioni, widget.
- Atteso: tutto leggibile, testo sull'accento in nero caldo (non bianco), nessuno sfondo colorato.
- [ ] Fatto

### 42. Inglese
- Passi: Impostazioni iPhone → Generali → Lingua → English (o Impostazioni → Sbu Habits → Lingua). Rivedi le schermate principali e una notifica.
- Atteso: tutto in inglese, nessuna stringa italiana rimasta, nessuna chiave tecnica. Date e ore nel formato inglese.
- [ ] Fatto

## L. Prima di TestFlight

### 43. Reinstallazione
- Passi: esporta i dati, elimina l'app, reinstalla, importa.
- Atteso: dati di nuovo come prima; nessun permesso chiesto all'avvio.
- [ ] Fatto

### 44. Scheda App Store e privacy
- Passi: leggi `Apps/SbuHabits/fastlane/metadata/it/description.txt` e `en-US/description.txt`, guarda gli screenshot in `fastlane/screenshots`.
- Atteso: la descrizione inizia con il blocco della promessa; nell'elenco delle funzioni è detto che iCloud resta spento finché non lo attivi. Etichetta privacy in App Store Connect: "Dati non raccolti" (da confermare tu).
- [ ] Fatto
