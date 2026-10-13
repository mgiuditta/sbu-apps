# Test book: Sbu Moon 1.0

Prova manuale su un iPhone vero, branch `app/moon-1.0`. Ogni controllo dice cosa fare e cosa deve succedere, parola per parola: se vedi altro, è un errore. iPhone in italiano, salvo dove è scritto.

Riferimento orari: [USNO, Rise/Set/Transit](https://aa.usno.navy.mil/data/RS_OneDay) per la stessa città e lo stesso giorno. Sbu Moon deve stare entro 2 minuti.

## A. Solo su un iPhone vero

### Primo avvio e posizione

1. **Primo avvio senza permessi.** Cancella l'app, reinstallala, aprila.
   - Atteso: nessuna richiesta di permessi. Sotto la luna c'è la sola pillola "Mostra sorgere e tramonto". Sullo schermo c'è un solo quadratino viola, dopo la cifra.
   - [ ] OK
2. **Prompt della posizione.** Tocca "Mostra sorgere e tramonto", poi "Usa la mia posizione".
   - Atteso: iOS chiede la posizione con il testo "Sbu Moon usa la posizione una volta, quando la chiedi, per calcolare il sorgere e il tramonto della luna. La posizione resta su questo iPhone."
   - [ ] OK
3. **Posizione consentita.** Scegli "Consenti mentre usi l'app".
   - Atteso: entro 5 secondi la rotella sparisce e il foglio si chiude. Sotto la luna: "Sorge" e "Tramonta" con l'ora, e la pillola "La tua posizione". Nessuna riga "Ora locale di…".
   - [ ] OK
4. **Orari giusti dove sei.** Confronta "Sorge" e "Tramonta" di oggi con l'USNO per la tua città.
   - Atteso: differenza di 2 minuti al massimo per ciascuno.
   - [ ] OK
5. **Posizione approssimativa.** Impostazioni iPhone → Sbu Moon → Posizione → "Posizione esatta" spenta. In Sbu Moon tocca la pillola del luogo, poi "Usa la mia posizione".
   - Atteso: funziona come al passo 3; gli orari cambiano al massimo di un minuto.
   - [ ] OK
6. **Posizione negata.** Impostazioni iPhone → Sbu Moon → Posizione → "Mai". In Sbu Moon tocca la pillola del luogo, poi "Usa la mia posizione".
   - Atteso: nessun prompt. Sotto compare "Apri Impostazioni" e la nota "La posizione è disattivata per Sbu Moon. Attivala nelle Impostazioni dell'iPhone, o scegli una città." Il luogo di prima resta.
   - [ ] OK
7. **Apri Impostazioni.** Tocca "Apri Impostazioni".
   - Atteso: si apre la pagina di Sbu Moon nelle Impostazioni dell'iPhone.
   - [ ] OK
8. **Senza segnale.** Posizione consentita, Modalità aereo attiva e Wi-Fi spento, al chiuso. Tocca "Usa la mia posizione".
   - Atteso: entro un minuto o arriva una posizione, o compare "Posizione non trovata. Riprova all'aperto, o scegli una città." Mai una rotella che gira per sempre.
   - [ ] OK

### Città e fusi orari

9. **Città nel tuo fuso.** Tocca la pillola del luogo, cerca "Parigi", sceglila.
   - Atteso: la pillola dice "Parigi", nessuna riga "Ora locale di…" (Parigi ha la stessa ora dell'Italia).
   - [ ] OK
10. **Città in un altro fuso.** Scegli "New York". Confronta con l'USNO per New York, oggi.
    - Atteso: "Sorge" e "Tramonta" sono nell'ora di New York e coincidono con l'USNO entro 2 minuti; sotto c'è "Ora locale di New York". Esempio: il 13 ottobre 2026 "Sorge 10:20", "Tramonta 19:34".
    - [ ] OK
11. **Il giorno è quello della pillola.** Con New York scelta, dopo mezzanotte in Italia (ma prima di mezzanotte a New York) guarda gli orari.
    - Atteso: sono quelli di New York per la data scritta nella pillola "Oggi" (la data italiana), non per il giorno prima.
    - [ ] OK
12. **Città salvata.** Chiudi l'app dal multitasking e riaprila.
    - Atteso: la pillola dice ancora "New York", senza nuove richieste.
    - [ ] OK

### Avvisi di fase

13. **Prompt delle notifiche.** Ingranaggio → "Avvisi di fase" → accendi "Luna piena".
    - Atteso: iOS chiede le notifiche solo adesso. Consenti. Compare "Ora dell'avviso" con "09:00".
    - [ ] OK
14. **Avviso all'ora vera, app chiusa.** Guarda in "Prossime fasi" il giorno della prossima fase. Il giorno prima (o quello stesso, se l'ora non è passata) imposta "Ora dell'avviso" a 3 minuti da adesso del giorno della fase e accendi quella fase; chiudi l'app.
    - Atteso: all'ora scelta, nel giorno della fase, arriva una notifica con il nome della fase come titolo e "Oggi alle HH:MM." uguale all'ora della fase mostrata nell'app.
    - [ ] OK
15. **Avviso con l'app aperta.** Ripeti il passo 14 tenendo l'app aperta.
    - Atteso: il banner compare sopra l'app.
    - [ ] OK
16. **Notifiche negate.** Impostazioni iPhone → Notifiche → Sbu Moon → spente. Riapri l'ingranaggio di Sbu Moon.
    - Atteso: sotto gli interruttori "Apri Impostazioni" e la nota "Le notifiche di Sbu Moon sono disattivate: gli avvisi non arrivano. Attivale nelle Impostazioni dell'iPhone." Riattivale e torna: la nota sparisce.
    - [ ] OK
17. **Cambio di fuso.** Impostazioni → Generali → Data e ora → scegli un altro fuso, riapri l'app, poi rimetti il fuso.
    - Atteso: "Prossime fasi" cambiano ora; gli avvisi arrivano all'"Ora dell'avviso" del nuovo fuso.
    - [ ] OK

### Schermi veri

18. **iPhone piccolo e testo grande.** Su un iPhone SE o 16e (o il tuo), testo al massimo non di accessibilità (Impostazioni → Schermo → Dimensioni testo, ultimo scatto senza "Caratteri più grandi").
    - Atteso: nessuna riga con la data spezzata su due righe a destra: se non ci sta, il valore va sotto l'etichetta. Niente testo tagliato.
    - [ ] OK
19. **VoiceOver.** Con un luogo scelto, scorri la schermata principale.
    - Atteso: "Sorge, 10:20", "Tramonta, 19:34" (o gli orari del giorno), "Ora locale di New York", poi "Luogo: New York, pulsante, Scegli un altro luogo". Il quadratino non viene letto. Nel foglio "Luogo" la città scelta è "selezionato".
    - [ ] OK

## B. Anche sul simulatore, da ripassare a occhio

20. **Giorno senza sorgere.** Scorri a sinistra giorno per giorno finché in una riga compare "Non in questo giorno" (succede circa una volta al mese).
    - Atteso: la scritta è "Non in questo giorno", mai "oggi" su un giorno che non è oggi.
    - [ ] OK
21. **Ricerca vuota.** Nel foglio "Luogo" cerca "xyz".
    - Atteso: "Nessun risultato per "xyz"" e nessuna intestazione "Città" sopra.
    - [ ] OK
22. **Modalità scura.** Giro su schermata principale, "Luogo" e impostazioni.
    - Atteso: testi leggibili, accento viola chiaro, un solo quadratino.
    - [ ] OK
23. **Inglese.** Lingua di Sbu Moon in inglese, giro completo.
    - Atteso: "Rises", "Sets", "New York local time", "Show moonrise and moonset", "Use my location", "Cities" con nomi inglesi (Rome, Munich, Florence), "Phase alerts", "Alert time" con "9:00 AM", notifica "Today at …".
    - [ ] OK
24. **Testo di accessibilità al massimo.** Giro completo con "Caratteri più grandi" al massimo.
    - Atteso: righe una sotto l'altra, pillole che vanno a capo, niente tagliato, tutto raggiungibile scorrendo.
    - [ ] OK
