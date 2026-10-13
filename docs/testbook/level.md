# Test book: Sbu Level 1.0

Prova manuale su iPhone reale, branch `app/level-1.0`. Ogni controllo ha un risultato esatto: passa o non passa, senza interpretazioni. I numeri sono in italiano (virgola decimale).

Come legge il quadrante, come Clinometer: 0° quando il bordo inferiore o superiore è in bolla, 90° quando lo è un bordo laterale. La lancetta punta sempre verso l'alto. "In bolla" compare esattamente quando la cifra mostra 0,0 (o 90,0 su un bordo laterale).

Cosa serve: un tavolo stabile, uno stipite di porta, una squadra da disegno a 45° (o un foglio quadrato piegato sulla diagonale), un libro spesso 2–3 cm, una matita. Togli la cover se sporge dai bordi.

## A. Solo su iPhone reale (sensore, vibrazione, schermo)

1. **Aggiornamento dalla build precedente.** Installa sopra la build che leggeva 9,2° sul tavolo, senza cancellare l'app. Appoggia l'iPhone sul retro, sul tavolo.
   - [ ] La cifra è tra 0,0° e 0,5°, non 9,2°.
   - [ ] Impostazioni → Calibrazione: tutte e cinque le righe dicono "Non calibrato" e la riga "Ripristina calibrazione" non c'è.

2. **Bordo inferiore in bolla.** iPhone in piedi sul bordo inferiore, sul tavolo, tenuto dritto con un dito.
   - [ ] La cifra è tra 0,0° e 0,5°. Contesto "Sul bordo", oppure "In bolla" se legge 0,0.
   - [ ] Quando la cifra arriva a 0,0 senti una sola vibrazione e il contesto dice "In bolla".

3. **Da 0 a 90 senza salti (il vecchio errore dei ±45°).** Dal punto 2, ruota l'iPhone lentamente in senso orario, restando sul piano dello schermo, fino a farlo poggiare sul bordo laterale.
   - [ ] La cifra sale con continuità: passa per 30, 45, 60, 75 e arriva tra 89,5° e 90,0°. Non scende mai, in nessun punto (prima a 60° si leggeva 30°).
   - [ ] Sul bordo laterale a 90,0 il contesto dice "In bolla".
   - [ ] Ripeti in senso antiorario fino all'altro bordo laterale: stesso risultato.

4. **Bordo superiore.** Capovolgi l'iPhone sul bordo superiore.
   - [ ] La cifra è tra 0,0° e 0,5°; la lancetta punta verso lo 0° in basso nel quadrante e lo spicchio grigio parte da lì.

5. **Nessun sfarfallio sulla diagonale.** Tieni l'iPhone a circa 45° tra due bordi e oscillalo di ±2°.
   - [ ] Cifra e lancetta si muovono con continuità; nessun salto di valore.

6. **Stipite verticale.** Appoggia un bordo laterale contro lo stipite di una porta, con l'iPhone in verticale.
   - [ ] Legge 0,0° ± 0,3° (lo stipite è verticale, quindi il bordo inferiore è in bolla). Annota: ____

7. **Angolo noto di 45°.** Squadra posata sul tavolo, bordo inferiore dell'iPhone sull'ipotenusa.
   - [ ] Legge 45,0° ± 0,5°. Annota: ____
   - [ ] Con il bordo laterale sull'ipotenusa (iPhone in orizzontale) legge ancora 45,0° ± 0,5° (90 − 45).

8. **Passaggio alla bolla con isteresi.** Dal bordo inferiore, abbassa lentamente l'iPhone verso il tavolo, schermo in su.
   - [ ] Sotto i 40° circa di inclinazione dello schermo il quadrante sfuma nella bolla (cerchio pieno), le etichette 0°/45°/90° spariscono.
   - [ ] Rialzandolo di 5–8° resta bolla; torna quadrante solo oltre i 50° circa. Nessun va e vieni vicino alla soglia.

9. **Bolla.** iPhone sul retro, sul tavolo. Infila il libro sotto il lato destro.
   - [ ] La bolla va a sinistra (lato alto). Contesto "In piano".
   - [ ] Togli il libro: la cifra torna sotto 0,5°.

10. **Calibrazione su una superficie inclinata (bordo).** Libro sotto un lato del tagliere: inclinazione di 1–3°. Fai un segno a matita. Bordo inferiore sul segno, tocca "Calibra".
    - [ ] Foglio a metà schermo: titolo "Calibrazione", "Passo 1 di 2", riga "Lato: Bordo inferiore", pulsante "Misura" visibile senza scorrere.
    - Tocca "Misura" senza toccare l'iPhone.
    - [ ] Barra "Misura in corso: tieni fermo l'iPhone" per circa 1 secondo, poi "Passo 2 di 2".
    - Gira l'iPhone di 180° (lo schermo guarda dall'altra parte), stesso bordo, stesso segno, tocca "Misura".
    - [ ] Dopo circa 1 secondo: in cima "Calibrata" con spunta verde, pulsante "Fine" in alto a destra.
    - Tocca "Fine". Rimettilo sul segno nel verso del passo 1, poi in quello del passo 2.
    - [ ] Le due letture differiscono al massimo di 0,1° (sono la pendenza del tagliere).

11. **Calibrazione rifiutata.** Apri "Calibra", tocca "Misura" con l'iPhone sul bordo inferiore, poi al passo 2 alzalo di circa 10° prima di toccare "Misura".
    - [ ] Avviso con triangolo: "La superficie è troppo inclinata o l'iPhone si è mosso. Riprova su una superficie stabile." Il foglio torna a "Passo 1 di 2". In Impostazioni la calibrazione di quel lato non cambia.

12. **Movimento durante la misura.** Tocca "Misura" e muovi l'iPhone durante la barra.
    - [ ] Avviso: "L'iPhone si è mosso: la misura ricomincia." La barra riparte da zero.

13. **Lato sbagliato al passo 2.** Passo 1 sul bordo inferiore, passo 2 appoggiato sul bordo destro.
    - [ ] Avviso: "Appoggia l'iPhone sullo stesso lato della prima misura." Non passa a "Calibrata" finché non torni sul bordo inferiore.

14. **Calibrazione del piano.** iPhone sul retro, sul tagliere inclinato. Calibra, gira di 180° sul posto, calibra.
    - [ ] "Lato: Piano", poi "Calibrata". Dopo, nei due versi la cifra differisce al massimo di 0,1°.

15. **Schermo sempre acceso.** Impostazioni iOS → Blocco automatico: 30 secondi. Apri l'app e non toccarla per 2 minuti.
    - [ ] Lo schermo resta acceso.
    - Impostazioni dell'app → spegni "Schermo sempre acceso", chiudi e aspetta 40 secondi.
    - [ ] Lo schermo si spegne.
    - Riaccendi l'interruttore, vai alla Home e aspetta 40 secondi.
    - [ ] Fuori dall'app lo schermo si spegne. Riaprendo l'app l'interruttore è ancora acceso.

16. **Blocco.** Sul bordo a circa 20°, tocca "Blocca".
    - [ ] La pillola diventa "Sblocca" con lucchetto chiuso, fondo più scuro e testo in grassetto. Sotto la cifra: lucchetto e "Lettura bloccata".
    - Muovi l'iPhone ovunque, anche fino a 0,0.
    - [ ] Cifra e lancetta restano ferme; nessuna vibrazione.
    - Tocca "Sblocca".
    - [ ] La cifra torna a seguire l'iPhone.

## B. Impostazioni e stato

17. **Ripristino per lato.** Con almeno due lati calibrati (punti 10 e 14): Impostazioni → "Ripristina calibrazione".
    - [ ] Conferma con titolo "Ripristina calibrazione", testo "Il lato scelto torna alla lettura del sensore, senza correzioni.", un pulsante rosso per ogni lato calibrato e "Tutti i lati".
    - Scegli "Bordo inferiore".
    - [ ] Solo "Bordo inferiore" diventa "Non calibrato"; "Piano" resta "Calibrato".
    - [ ] Chiudi l'app dal multitasking e riaprila: lo stato è lo stesso.

18. **Calibra da Impostazioni.** Impostazioni → riga "Calibra".
    - [ ] Si apre lo stesso foglio di calibrazione, sopra le Impostazioni; "Annulla" lo chiude e torni alle Impostazioni.

## C. Accessibilità, aspetto, lingua

19. **VoiceOver.** Attiva VoiceOver.
    - [ ] La cifra si legge come un solo elemento: "Inclinazione, <valore> gradi, Sul bordo" (o "In bolla"/"In piano"). Il quadrante non viene letto.
    - [ ] Doppio tocco su "Blocca": annuncia "Lettura bloccata, <valore>°". Su "Sblocca": "Lettura sbloccata".
    - [ ] Nel foglio di calibrazione si raggiungono "Lato", il passo, "Misura" e, alla fine, "Calibrata".

20. **Testo più grande.** Accessibilità → Testo più grande al massimo.
    - [ ] Cifra, "INCLINAZIONE" e contesto interi. Le pillole sono una sopra l'altra con parole intere. Il quadrante è più piccolo, etichette leggibili.
    - [ ] Il foglio di calibrazione si apre a tutto schermo; scorrendo si arriva a "Misura".

21. **Tema scuro.** 
    - [ ] Fondo nero caldo, cifra e lancetta chiare, spicchio visibile, quadratino in accento; foglio e Impostazioni leggibili.

22. **Inglese.** Impostazioni iOS → App → Sbu Level → Lingua → English.
    - [ ] Cifra con il punto (32.4). "TILT", "On its edge", "Calibrate", "Lock"/"Unlock", "Reading locked".
    - [ ] Foglio: "Side", "Step 1 of 2", "Measure", "Calibrated", "Calibrate another side". Impostazioni: "While measuring", "Keep screen on", "Bottom edge", "Calibrated"/"Not calibrated", "Reset calibration", "All sides".

23. **iPhone piccolo** (se ne hai uno: SE o mini).
    - [ ] Schermata principale senza nulla tagliato; nel foglio di calibrazione "Misura" è visibile senza scorrere ai passi 1 e 2.
