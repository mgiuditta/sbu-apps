# Sbu Speed 1.0: test book

Prova su iPhone reale, ramo `app/speed-1.0`. Ogni caso ha un esito netto: passa o non passa. Se non passa, annota il numero e cosa hai visto.

Il simulatore ha già controllato, su iPhone 17 e iPhone SE (3ª gen.), in chiaro, scuro, italiano, inglese, testo standard, XXXL e AX5: tutte le schermate, la richiesta di permesso, lo stato negato, la conferma di azzeramento, le Impostazioni con i menu, il superamento del limite, l'orizzontale; un viaggio simulato a 20 nodi (20 kn, 0,1 nmi, 20 secondi). Qui sotto resta quello che solo un iPhone vero può dire.

Prima di iniziare: build del ramo installata, iPhone in italiano con regione Italia, testo standard, tema chiaro, suoneria attiva, volume a metà. Se l'app era già installata, cancellala e reinstallala.

## A. Solo su iPhone vero (in ordine)

1. [ ] **Permesso al primo avvio.** Apri Sbu Speed. Atteso: compare subito la richiesta di sistema con il testo "Sbu Speed usa la posizione solo mentre è aperta, per leggere la tua velocità. La posizione resta su questo iPhone." Sotto la cifra, dietro la richiesta, c'è "Consenti la posizione". Tocca "Consenti mentre usi l'app".
2. [ ] **Primo fix.** All'aperto, fermo. Atteso: entro 30 secondi la riga passa da "Cerco il segnale GPS" a "Fermo" e la cifra da "–" a "0". Massima "0 km/h", Media "0 km/h", Distanza "0,0 km", Durata "0:00:00"; "Azzera viaggio" è grigio e non risponde al tocco.
3. [ ] **Velocità in auto.** Da passeggero, a velocità costante di 50 km/h sul tachimetro dell'auto. Atteso: la cifra segna tra 45 e 50 (il tachimetro delle auto segna in eccesso di qualche km/h); riga "In movimento"; l'arco si riempie fino a circa 5/6 della scala da 60.
4. [ ] **Scala del quadrante.** Supera i 60 km/h. Atteso: l'arco si riduce di colpo (la scala passa a 120) e non torna alla scala da 60 quando rallenti, perché la massima la tiene.
5. [ ] **Massima.** Atteso: "Massima" è la velocità più alta letta sulla cifra (al km/h, o 1 in più per arrotondamento) e non scende quando rallenti.
6. [ ] **Soste.** Fermati a un semaforo per almeno 30 secondi. Atteso: Durata si ferma (i secondi non avanzano), Media non cambia, Distanza non cambia, riga "Fermo". Ripartendo, Durata riprende a contare.
7. [ ] **Distanza.** Percorri un tratto noto di almeno 5 km (cartello o Mappe). Atteso: la Distanza aumenta di quel valore con uno scarto massimo del 3% (5 km: tra 4,9 e 5,2).
8. [ ] **Durata.** Fai partire il cronometro dell'iPhone quando ti metti in moto e guida 3 minuti senza fermarti. Atteso: Durata aumenta di 3 minuti, con uno scarto massimo di 5 secondi.
9. [ ] **Limite: avviso.** Impostazioni → Limite di velocità → Limite: "30 km/h". Supera i 30 km/h. Atteso: nello stesso istante la riga diventa "Oltre il limite di 30 km/h" in rosso con il triangolo, la cifra resta nera, l'iPhone vibra una volta e suona una volta.
10. [ ] **Limite: niente ripetizioni.** Resta tra 29 e 33 km/h per 30 secondi. Atteso: nessun altro suono né vibrazione. Scendi sotto i 27 km/h e torna sopra 30: un solo nuovo avviso.
11. [ ] **Limite in silenzioso.** Interruttore silenzioso attivo (o modalità Silenzioso), supera il limite. Atteso: vibra, nessun suono.
12. [ ] **Schermo acceso.** Blocco automatico a 30 secondi, lascia l'app aperta senza toccarla per 2 minuti. Atteso: lo schermo resta acceso. Torna alla Home e aspetta 30 secondi: lo schermo si spegne come sempre.
13. [ ] **Orizzontale nel supporto.** Blocco rotazione spento. Metti l'iPhone in orizzontale nel supporto dell'auto, prima con il tasto laterale in alto, poi in basso. Atteso in entrambi i versi: a sinistra "VELOCITÀ", la cifra, la riga di stato e "Azzera viaggio"; a destra il quadrante e i quattro valori due per due; niente tagliato, niente sotto l'isola dinamica o gli angoli. Da passeggero: la cifra si legge a colpo d'occhio a un braccio di distanza.
14. [ ] **Rientro dopo una pausa.** Durante un viaggio, vai alla Home per 2 minuti mentre l'auto si muove, poi riapri. Atteso: la Distanza non aggiunge i km fatti mentre l'app era chiusa (il viaggio conta solo con l'app aperta) e riprende a contare subito.
15. [ ] **Viaggio salvato.** Chiudi l'app dal multitasking e riaprila. Atteso: Massima, Media, Distanza e Durata sono identiche a prima di chiuderla.
16. [ ] **Nodi in barca o in auto.** Impostazioni → Unità → Velocità: "Nodi". Atteso: la cifra mostra "kn"; a 50 km/h legge 27 kn (±1); Distanza in "nmi" (10 km = 5,4 nmi). Limite → le scelte sono Nessuno, 5, 10, 15, 20, 25, 30 kn. Se il limite era 30 km/h ora è "15 kn".
17. [ ] **Permesso negato.** Impostazioni iPhone → Privacy e sicurezza → Localizzazione → Sbu Speed → "Mai". Torna nell'app. Atteso: cifra "–", riga "Posizione non consentita", pill "Apri Impostazioni" che apre la pagina di Sbu Speed nelle Impostazioni. Rimetti "Mentre usi l'app": la velocità torna senza riaprire l'app e il viaggio è intatto.
18. [ ] **Posizione approssimativa.** Nella stessa pagina spegni "Posizione esatta". Atteso: riga "Serve la posizione esatta", pill "Apri Impostazioni". Riaccendila: la velocità torna.
19. [ ] **VoiceOver.** Attiva VoiceOver e scorri da sinistra a destra. Atteso, in quest'ordine: "Sbu Speed", "Impostazioni, pulsante", "Velocità, 52, km/h, In movimento" (con la tua velocità), "Massima, 87 km/h", "Media, …", "Distanza, …", "Durata, 16 minuti e 10 secondi" (a parole, non "zero due punti sedici"), "Azzera viaggio, pulsante". Il quadratino colorato e l'arco non vengono letti.
20. [ ] **Azzera viaggio.** Tocca "Azzera viaggio". Atteso: compare un riquadro con "Azzera viaggio", il testo "Il viaggio riparte da zero." e il pulsante rosso "Azzera viaggio". Tocca fuori: non cambia nulla. Ripeti e conferma: i quattro valori tornano a "0 km/h", "0 km/h", "0,0 km", "0:00:00" e il pulsante diventa grigio.

## B. Aspetto (veloce, il simulatore li ha già visti)

21. [ ] **Tema scuro**, in verticale e in orizzontale: fondo nero caldo, cifra chiara, quadratino e arco nel verde dell'app, avviso del limite rosso leggibile.
22. [ ] **Testo AX5** (Accessibilità → Schermo e dimensione testo → Testo più grande al massimo): la schermata scorre fino ad "Azzera viaggio", il quadrante sparisce, i quattro valori sono uno sotto l'altro, nessuna parola tagliata. In orizzontale idem.
23. [ ] **Inglese** (lingua iPhone inglese, regione Stati Uniti, app reinstallata): unità iniziale mph; etichette "TOP", "AVERAGE", "DISTANCE", "TIME"; riga "Stopped" da fermo; pill "Reset trip"; in Impostazioni il piè di pagina "Distance follows speed: kilometres, miles or nautical miles."
24. [ ] **Impostazioni**: Privacy apre sbu.dev in Safari; Licenze elenca Bricolage Grotesque; in basso le pill della promessa e "Parte di sbu.dev".
25. [ ] **Modalità aereo** con la posizione accesa: l'app funziona uguale (il GPS non usa la rete).
