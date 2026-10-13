# Test book: Sbu Level 1.0

Prova manuale su iPhone reale, branch `app/level-1.0`. Il simulatore non ha il sensore di movimento: tutto ciò che riguarda angoli veri, calibrazione e schermo acceso si verifica solo qui.

Cosa serve: un tavolo, una porta con stipite, un oggetto con un angolo noto di 45° (squadra da disegno, o un foglio A4 piegato lungo la diagonale di un quadrato), una superficie leggermente inclinata (un libro sotto una gamba di un tagliere), una cover tolta se sporge dai bordi.

Come leggere il quadrante: 0° quando il bordo inferiore (o superiore) è in bolla, 90° quando è in bolla un bordo laterale, come in Clinometer. La lancetta punta sempre verso l'alto.

## 1. Primo avvio

Precondizioni: app installata da zero (cancellala prima, se c'era).

1. Apri l'app con l'iPhone in mano, verticale.
- [ ] Nessuna richiesta di permessi (il sensore di movimento non ne chiede).
- [ ] Titolo "Sbu Level", sopra "INCLINAZIONE", la cifra al decimo con "°" e il quadratino in accento, sotto "Sul bordo".
- [ ] Quadrante con tacche, 0° in alto e in basso, 90° ai lati, 45° in diagonale; lancetta nera verso l'alto e spicchio grigio tra 0° e la lancetta.
- [ ] In basso le pillole "Calibra" e "Blocca" (lucchetto aperto).

## 2. Clinometro 0–90° (il bug dei ±45° è risolto)

Precondizioni: nessuna calibrazione (Impostazioni → Calibrazione: tutti "Non calibrata").

1. Appoggia il bordo inferiore sul tavolo, iPhone in piedi.
- [ ] Legge circa 0,0° e "In bolla"; una vibrazione quando arriva a 0,0.
2. Inclina lentamente l'iPhone verso destra fino a metterlo sul bordo destro, guardando la cifra.
- [ ] La cifra sale con continuità da 0 a 90 senza saltare: a metà strada passa per 45, poi 60, 70, 80. Non torna mai indietro verso 30 (prima 60° si leggeva 30°).
- [ ] Sul bordo destro appoggiato al tavolo legge circa 90,0° e "In bolla".
3. Ripeti verso sinistra fino al bordo sinistro.
- [ ] Stesso comportamento, circa 90,0° sul bordo sinistro.
4. Capovolgi l'iPhone sul bordo superiore.
- [ ] Circa 0,0°, "In bolla"; la lancetta punta verso lo 0° in basso e lo spicchio parte da lì.
5. Tieni l'iPhone fermo attorno a 45° (a metà tra due bordi) e muovilo di un grado avanti e indietro.
- [ ] La cifra cambia in modo continuo, niente salti né sfarfallio.

## 3. Angoli noti

1. Stipite della porta: appoggia il bordo destro (o sinistro) dell'iPhone, in verticale, contro lo stipite.
- [ ] Legge 0,0° ± 0,2° (lo stipite è verticale, quindi il bordo inferiore è in bolla). Annota il valore: ___
2. Pavimento: appoggia il bordo inferiore a terra.
- [ ] 0,0° ± 0,2°. Annota: ___
3. Oggetto a 45°: appoggia il bordo inferiore sull'ipotenusa della squadra posata sul tavolo.
- [ ] 45,0° ± 0,5°. Annota: ___
4. Stesso oggetto, bordo destro sull'ipotenusa (iPhone in orizzontale).
- [ ] 45,0° ± 0,5° (sul bordo laterale il quadrante legge l'angolo dal verticale: 90 − 45 = 45).
5. Una rampa o un tetto di cui conosci la pendenza, se ce l'hai.
- [ ] Il valore torna con quello noto. Annota: ___

## 4. Passaggio bolla ↔ clinometro

1. Appoggia l'iPhone sul tavolo, schermo in su.
- [ ] Il quadrante passa con una dissolvenza alla bolla (cerchio nero), le etichette 0°/45°/90° spariscono, contesto "In piano" o "In bolla".
2. Solleva piano il lato superiore: verso i 45° rispetto al tavolo passa a clinometro. Ora riabbassalo di poco.
- [ ] Il cambio avviene una volta sola: vicino alla soglia la vista non sfarfalla tra bolla e quadrante (tiene la modalità per circa 5° oltre la soglia).
3. In piano, inclina verso destra.
- [ ] La bolla va verso sinistra (lato alto), come una livella vera.

## 5. Blocco della lettura

1. Metti l'iPhone su un bordo a un angolo qualsiasi, tocca "Blocca".
- [ ] La pillola diventa "Sblocca" con lucchetto chiuso e fondo più scuro, in grassetto (lo stato si capisce senza colore).
- [ ] Sotto la cifra: lucchetto + "Lettura bloccata".
2. Muovi l'iPhone in ogni direzione, anche in piano.
- [ ] Cifra, lancetta e bolla restano ferme. Nessuna vibrazione anche passando per lo 0.
3. Tocca "Sblocca".
- [ ] La cifra torna a seguire l'iPhone.

## 6. Schermo sempre acceso

Precondizioni: Impostazioni iOS → Schermo e luminosità → Blocco automatico a 30 secondi.

1. Apri l'app e lasciala ferma 2 minuti senza toccarla.
- [ ] Lo schermo non si spegne.
2. Impostazioni dell'app → "Schermo sempre acceso" spento, chiudi le impostazioni, aspetta 1 minuto.
- [ ] Lo schermo si spegne dopo i 30 secondi.
3. Riaccendilo, torna nell'app, riaccendi l'interruttore. Vai alla Home e aspetta 1 minuto.
- [ ] Fuori dall'app lo schermo si spegne normalmente.
- [ ] Riaprendo l'app l'interruttore è ancora acceso (si ricorda la scelta).

## 7. Calibrazione in due passi

Precondizioni: superficie leggermente inclinata (1–3°, per esempio un tagliere con un libro sotto un lato). Segna con una matita il punto dove appoggi l'iPhone.

1. Appoggia il bordo inferiore sulla superficie, sul segno. Tocca "Calibra".
- [ ] Si apre un foglio a metà schermo: "Lato: Bordo inferiore", "Passo 1 di 2", "Misura". Il quadrante resta visibile sopra.
2. Tocca "Misura" senza toccare l'iPhone.
- [ ] Barra di avanzamento "Misura in corso: tieni fermo l'iPhone" per circa un secondo, poi "Passo 2 di 2".
3. Gira l'iPhone di 180° (lo schermo ora guarda dall'altra parte), stesso bordo, stesso punto. Tocca "Misura".
- [ ] Dopo un secondo: "Risultato", spunta verde e "Calibrata", pulsante "Fine".
4. Tocca "Fine". Rimetti l'iPhone sulla superficie inclinata nel verso del passo 1, poi in quello del passo 2.
- [ ] Le due letture sono uguali (la pendenza della superficie), con al massimo 0,1° di differenza. Prima di calibrare potevano differire.
5. Ripeti per bordo destro, bordo sinistro, bordo superiore e per il piano (iPhone appoggiato sul retro, giro di 180° sul tavolo).
- [ ] Il lato nel foglio si riconosce da solo ogni volta ("Bordo destro", "Piano", ecc.).
6. Durante un passo, tocca "Misura" e muovi l'iPhone.
- [ ] Avviso in arancione con triangolo: "L'iPhone si è mosso: la misura ricomincia." La barra riparte da zero.
7. Al passo 2 appoggia l'iPhone su un altro lato.
- [ ] Avviso: "Appoggia l'iPhone sullo stesso lato della prima misura." Non prosegue finché non torni sul lato giusto.
8. Apri "Calibra" e tocca "Annulla" al passo 2.
- [ ] Il foglio si chiude, la calibrazione di quel lato non cambia.

## 8. Impostazioni: stato e ripristino per lato

1. Apri Impostazioni (ingranaggio).
- [ ] Sezione "Durante la misura" con "Schermo sempre acceso".
- [ ] Sezione "Calibrazione" con Piano, Bordo inferiore, Bordo destro, Bordo superiore, Bordo sinistro e accanto "Calibrata" o "Non calibrata".
- [ ] Riga "Calibra" (apre lo stesso foglio del punto 7) e, solo se almeno un lato è calibrato, "Ripristina calibrazione" in rosso.
2. Tocca "Ripristina calibrazione".
- [ ] Conferma con titolo "Ripristina calibrazione", un pulsante per ogni lato calibrato e "Tutti i lati" se sono più di uno.
3. Scegli un solo lato.
- [ ] Solo quel lato torna "Non calibrata"; gli altri restano.
4. Chiudi e riapri l'app.
- [ ] Le calibrazioni rimaste sono ancora lì.

## 9. Aggiornamento da una build precedente

Precondizioni: una build precedente (TestFlight 1.0 build 1) già calibrata con il vecchio "Calibra" a un passo.

1. Installa sopra questa build senza cancellare l'app.
- [ ] Le letture sono uguali a prima: la vecchia calibrazione vale per tutti e quattro i bordi finché non ricalibri.
- [ ] In Impostazioni i lati risultano "Calibrata".

## 10. Testo grande

1. Impostazioni iOS → Accessibilità → Schermo e dimensione testo → Testo più grande, massimo.
- [ ] Cifra, "INCLINAZIONE" e contesto grandi e interi; il quadrante si rimpicciolisce ma resta leggibile (le etichette del quadrante smettono di crescere oltre una certa misura, di proposito).
- [ ] Le pillole "Calibra" e "Blocca" stanno una sopra l'altra, parole intere.
- [ ] Il foglio di calibrazione si apre a tutto schermo e si scorre fino a "Misura".
- [ ] Impostazioni leggibili, niente testo tagliato.

## 11. VoiceOver

1. Attiva VoiceOver, apri l'app.
- [ ] La cifra si legge come un elemento solo: "Inclinazione, 32,4 gradi, Sul bordo" (o simile). Il quadrante non viene letto.
- [ ] "Calibra" e "Blocca" sono pulsanti.
2. Tocca due volte "Blocca".
- [ ] VoiceOver annuncia "Lettura bloccata, <valore>°". Il pulsante ora dice "Sblocca", selezionato.
3. Tocca due volte "Sblocca".
- [ ] Annuncia "Lettura sbloccata".
4. Fai una calibrazione con VoiceOver.
- [ ] Si arriva a "Misura", il passo e gli avvisi si leggono; "Calibrata" alla fine.

## 12. Tema scuro

1. Attiva il tema scuro.
- [ ] Fondo nero caldo, cifra e lancetta chiare, spicchio visibile ma discreto, quadratino in accento.
- [ ] Foglio di calibrazione e Impostazioni leggibili.

## 13. Inglese

1. Impostazioni iOS → App → Sbu Level → Lingua → English.
- [ ] "TILT", "On its edge", "Calibrate", "Lock"/"Unlock", "Reading locked".
- [ ] Foglio: "Side", "Step 1 of 2", "Measure", "Calibrated", "Calibrate another side".
- [ ] Impostazioni: "While measuring", "Keep screen on", "Bottom edge" ecc., "Reset calibration", "All sides".
- [ ] La cifra usa il punto decimale (32.4).

## 14. Sensore assente

Non verificabile su iPhone (tutti hanno il sensore). Nel simulatore senza dati finti si vede "Sensore di movimento non disponibile" e le pillole sono disattivate.
- [ ] Solo da controllare a vista se capita su un dispositivo strano.
