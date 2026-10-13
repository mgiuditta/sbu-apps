# Test book: Sbu Moon 1.0

Prova manuale su un iPhone vero, branch `app/moon-1.0`. Ogni passo ha precondizioni, azioni e risultato atteso. Segna la casella quando il risultato è quello atteso; se no, annota cosa vedi.

Riferimento per gli orari: [USNO, Rise/Set/Transit](https://aa.usno.navy.mil/data/RS_OneDay) o timeanddate.com per la stessa città e lo stesso giorno. Sbu Moon deve stare entro 2 minuti.

## 1. Primo avvio

Precondizioni: app appena installata (cancellala prima se c'era). iPhone in italiano.

1. Apri Sbu Moon.
   - Atteso: nessuna richiesta di permessi (né notifiche né posizione). Si vede "Illuminazione", la cifra con il quadratino viola, il nome della fase, la luna disegnata.
   - Sotto la luna c'è una sola pillola "Mostra sorgere e tramonto". Poi le prossime quattro fasi, età e distanza, in grigio. In basso la pillola "Oggi".
   - [ ] OK
2. Conta i quadratini viola sullo schermo.
   - Atteso: uno solo, dopo la cifra.
   - [ ] OK

## 2. Sorgere e tramonto con la posizione

Precondizioni: Localizzazione attiva sull'iPhone, Sbu Moon mai autorizzata.

1. Tocca "Mostra sorgere e tramonto".
   - Atteso: si apre il foglio "Luogo" con "Usa la mia posizione" in alto, la nota "Letta una volta, con la precisione di un chilometro. Resta su questo iPhone." e l'elenco "Città".
   - [ ] OK
2. Tocca "Usa la mia posizione".
   - Atteso: iOS chiede la posizione "mentre usi l'app", con il testo "Sbu Moon usa la posizione una volta, quando la chiedi…".
   - [ ] OK
3. Scegli "Consenti una volta" o "Consenti mentre usi l'app". Prova anche con "Posizione esatta" disattivata.
   - Atteso: compare per un attimo una rotella, poi il foglio si chiude. Sotto la luna: "Sorge" e "Tramonta" con l'ora, e una pillola "La tua posizione".
   - [ ] OK
4. Confronta gli orari con il riferimento per la tua città, oggi.
   - Atteso: differenza di 2 minuti al massimo.
   - [ ] OK
5. Chiudi l'app dal multitasking e riaprila.
   - Atteso: "Sorge" e "Tramonta" ci sono ancora, senza nuove richieste di posizione.
   - [ ] OK
6. Scorri a sinistra per domani, poi a destra due volte per ieri.
   - Atteso: gli orari cambiano con il giorno mostrato (la luna sorge circa 50 minuti più tardi ogni giorno).
   - [ ] OK
7. Cerca nei prossimi giorni un giorno in cui la luna non sorge o non tramonta (succede circa una volta al mese).
   - Atteso: "Non sorge oggi" o "Non tramonta oggi" al posto dell'ora.
   - [ ] OK

## 3. Posizione negata

Precondizioni: Impostazioni iPhone → Sbu Moon → Posizione → "Mai".

1. Apri Sbu Moon, tocca la pillola del luogo, poi "Usa la mia posizione".
   - Atteso: nessun prompt. Sotto compare "Apri Impostazioni" e la nota "La posizione è disattivata per Sbu Moon. Attivala nelle Impostazioni dell'iPhone, o scegli una città." Il luogo di prima resta.
   - [ ] OK
2. Tocca "Apri Impostazioni".
   - Atteso: si apre la pagina di Sbu Moon nelle Impostazioni.
   - [ ] OK
3. Torna su Sbu Moon e scegli una città.
   - Atteso: funziona senza posizione.
   - [ ] OK
4. Con Modalità aereo e Wi-Fi spento, posizione consentita, tocca "Usa la mia posizione" al chiuso.
   - Atteso: o arriva una posizione, o compare "Posizione non trovata. Riprova all'aperto, o scegli una città." Mai una rotella infinita.
   - [ ] OK

## 4. Città dall'elenco (senza GPS)

1. Tocca la pillola del luogo, scrivi "zuri" nella ricerca.
   - Atteso: compare "Zurigo". Con "xyz" compare la schermata vuota di ricerca.
   - [ ] OK
2. Scegli "New York".
   - Atteso: il foglio si chiude, la pillola dice "New York". Gli orari sono nel fuso dell'iPhone (non di New York): per esempio un sorgere alle 10:21 a New York si legge 16:21 in Italia.
   - [ ] OK
3. Riapri il foglio.
   - Atteso: New York ha la spunta, "Usa la mia posizione" no.
   - [ ] OK
4. Scegli una città nordica in inverno o in estate (Reykjavík, Oslo) e guarda qualche giorno.
   - Atteso: orari sensati. Se la luna resta sopra o sotto l'orizzonte tutto il giorno: una riga "Sorgere e tramonto" con "Sopra l'orizzonte tutto il giorno" o "Sotto l'orizzonte tutto il giorno".
   - [ ] OK

## 5. Avvisi di fase

Precondizioni: Sbu Moon non ha mai chiesto le notifiche.

1. Tocca l'ingranaggio.
   - Atteso: sezione "Avvisi di fase" con quattro interruttori spenti (Luna nuova, Primo quarto, Luna piena, Ultimo quarto) e la nota "Ti avvisa il giorno della fase, all'ora che scegli." Poi "Calcolo".
   - [ ] OK
2. Accendi "Luna piena".
   - Atteso: iOS chiede le notifiche. Consenti. Compare "Ora dell'avviso" alle 9:00.
   - [ ] OK
3. Prova vera: guarda in "Prossime fasi" il giorno della prossima fase. Il giorno prima, imposta "Ora dell'avviso" a qualche minuto da adesso e accendi quella fase; poi aspetta il giorno dopo a quell'ora con l'app chiusa.
   - Atteso: arriva la notifica "Luna piena" (o la fase scelta) con "Oggi alle HH:MM." uguale all'ora della fase mostrata nell'app.
   - [ ] OK
4. Stessa prova con l'app aperta.
   - Atteso: il banner compare anche sopra l'app.
   - [ ] OK
5. Spegni tutti gli interruttori.
   - Atteso: sparisce "Ora dell'avviso" e non arriva più niente.
   - [ ] OK
6. Accendi tutte e quattro le fasi, chiudi e riapri l'app.
   - Atteso: gli interruttori restano accesi e l'ora resta quella scelta. (iOS tiene al massimo 64 avvisi: l'app ne pianifica circa un anno, meno di 64.)
   - [ ] OK
7. Cambia fuso orario (Impostazioni → Generali → Data e ora) e riapri l'app.
   - Atteso: gli avvisi seguono l'ora scelta nel nuovo fuso (l'app li ripianifica ogni volta che torna in primo piano).
   - [ ] OK

## 6. Notifiche negate

Precondizioni: Impostazioni iPhone → Notifiche → Sbu Moon → disattivate, almeno un avviso acceso.

1. Apri le impostazioni di Sbu Moon.
   - Atteso: sotto gli interruttori c'è "Apri Impostazioni" e la nota "Le notifiche di Sbu Moon sono disattivate: gli avvisi non arrivano. Attivale nelle Impostazioni dell'iPhone."
   - [ ] OK
2. Tocca "Apri Impostazioni", riattiva le notifiche, torna su Sbu Moon e riapri le impostazioni.
   - Atteso: il messaggio è sparito, gli avvisi sono ripianificati.
   - [ ] OK

## 7. Testo grande

Precondizioni: Impostazioni → Accessibilità → Schermo e dimensioni testo → Testo più grande, al massimo.

1. Schermata principale: scorri fino in fondo.
   - Atteso: "Sorge", "Tramonta" e le altre righe vanno a capo (etichetta sopra, valore sotto), niente testo tagliato, la pillola del luogo leggibile.
   - [ ] OK
2. Foglio "Luogo" e impostazioni.
   - Atteso: righe leggibili, interruttori al loro posto, niente testo tagliato.
   - [ ] OK

## 8. VoiceOver

1. Schermata principale con un luogo scelto: scorri gli elementi.
   - Atteso: "Sorge, 12:16", "Tramonta, 17:52" letti come un elemento ciascuno; la pillola dice "Luogo: Oslo, pulsante, Scegli un altro luogo". Il quadratino non viene letto.
   - [ ] OK
2. Foglio "Luogo": la città scelta è annunciata come "selezionato".
   - [ ] OK
3. Impostazioni: ogni interruttore dice il nome della fase e lo stato.
   - [ ] OK

## 9. Modalità scura

1. Attiva l'aspetto scuro e ripeti un giro su schermata principale, foglio "Luogo" e impostazioni.
   - Atteso: sfondo nero caldo, testi leggibili, accento viola chiaro, un solo quadratino.
   - [ ] OK

## 10. Inglese

Precondizioni: lingua dell'iPhone (o di Sbu Moon) in inglese.

1. Giro completo.
   - Atteso: "Rises", "Sets", "Show moonrise and moonset", "Place", "Use my location", "Cities" con nomi inglesi (Rome, Munich, Florence), "Phase alerts", "Alert time". La notifica dice "Today at …". Il prompt di posizione è in inglese.
   - [ ] OK

## 11. Cose che il simulatore non ha potuto verificare

- Posizione reale (GPS, posizione approssimativa) e il prompt di iOS: sezioni 2 e 3.
- Notifiche consegnate all'ora vera, con app chiusa e aperta: sezione 5, passi 3 e 4.
- Orari confrontati sul posto con un almanacco nella tua città: sezione 2, passo 4. I test automatici confrontano Roma, New York, Londra, Sydney e Longyearbyen con l'USNO.
