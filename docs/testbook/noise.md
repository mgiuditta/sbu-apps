# Sbu Noise 1.0: libro dei test su iPhone

Branch `app/noise-1.0`. Da fare su un iPhone vero, con la build di questo branch. Ogni prova ha le condizioni di partenza, i passi, il risultato atteso e una casella. Se un risultato non torna, annota il numero della prova e cosa hai visto.

Servono: cuffie (filo o AirPods), un iPhone con iOS 26 per la parte AlarmKit (se c'è anche un iPhone con iOS 17–25, meglio), 30 minuti la sera e 15 la mattina per le sveglie.

## A. Primo avvio

1. **Primo avvio pulito**
   - Prima: app cancellata e reinstallata.
   - Passi: apri l'app.
   - Atteso: player su "Rumore bianco", "Suoni · 1 di 34". Nessun permesso chiesto (né notifiche né sveglie): arrivano solo quando salvi la prima sveglia.
   - [ ]

2. **Uscita e rientro**
   - Passi: metti un cuore, nascondi un suono in Gestisci, crea una sveglia, chiudi l'app dal selettore, riaprila.
   - Atteso: cuore, suono nascosto, ordine e sveglia ci sono ancora; il player riapre sull'ultimo suono.
   - [ ]

## B. Catalogo e ascolto (#414, #423)

3. **Ascolto di ogni registrazione** (il controllo che l'analisi automatica non può fare)
   - Prima: cuffie.
   - Passi: per ognuno dei 29 suoni non "Rumore", ascolta almeno 70 secondi (il giro completo; Temporale 2 minuti, Mare 1 minuto e mezzo).
   - Atteso: niente voci, cani, annunci, clacson forti, musica; nessun colpo o salto al punto in cui il loop ricomincia; volume simile tra i suoni.
   - Da guardare con più attenzione: Città (traffico di Città del Messico: possibili clacson), Treno (sorgente quasi mono), Orologio (il ticchettio può "inciampare" una volta al minuto, al giro), Bosco (uccelli), Pioggia sulla tenda, Lavatrice, Fusa del gatto.
   - Se un suono non va: scrivi l'id (es. `travel.city`), lo sostituisco o lo tolgo.
   - [ ]

4. **Suoni sintetizzati**: Vento, Condizionatore, Aereo, Gocce. Atteso: credibili, senza stacchi al giro. Se uno suona finto, dimmelo: si può togliere.
   - [ ]

5. **Categorie nel menu ☰**
   - Passi: ☰ → Pioggia; scorri; ☰ → Casa; ☰ → Suoni.
   - Atteso: nella riga sotto il nome "Pioggia · 1 di 6" ecc.; il suono che sta suonando continua se resta nella lista, cambia se scorri.
   - [ ]

6. **Gestisci**
   - Passi: tocca Gestisci. Cerca "pioggia". Filtro (icona imbuto) → Acqua. Togli il filtro. Modifica → trascina "Mare" in cima → Fine. Scorri a sinistra su "Treno" → Nascondi. Scorri a destra su "Fuoco" → cuore. Tocca "Rumore rosa".
   - Atteso: la ricerca e il filtro funzionano; "Mare" diventa il primo in Suoni; "Treno" va in "Nascosti" in fondo e sparisce dal player; "Fuoco" compare in Preferiti; il tocco chiude Gestisci e suona Rumore rosa.
   - Poi: in Gestisci tocca "Treno" in Nascosti. Atteso: torna nel player.
   - [ ]

7. **Info del suono e crediti**
   - Passi: su "Pioggia forte" tocca ⓘ. Poi Impostazioni (ingranaggio) → Crediti dei suoni; poi Licenze.
   - Atteso: autore, licenza CC0 1.0, pagina Freesound (testo selezionabile, nessun link che apre il web). In Crediti tutte le 24 registrazioni con autore e pagina, e l'elenco dei suoni creati da Sbu Noise. Licenze mostra ancora il font.
   - [ ]

8. **Mix con registrazioni**: Crea → Nuovo mix con Pioggia forte, Fuoco e Vento, sposta i gettoni. Atteso: suonano insieme, si sentono spostarsi in cuffia (davanti/dietro con AirPods).
   - [ ]

## C. Preferiti (#415)

9. **Cuore**: tocca il cuore su un suono e su un mix; ☰ → Preferiti. Atteso: entrambi in Preferiti, "Preferiti · 1 di 2". Togli il cuore a quello sullo schermo: il player passa al vicino. Con nessun preferito: "Nessun preferito" e il testo che spiega il cuore.
   - [ ]

## D. Sveglia (#417, #424), da provare con orari veri

Prima di tutto: volume multimediale a metà.

10. **Primo salvataggio e permesso**
    - Passi: Timer → + → Nuova sveglia → Salva.
    - Atteso iOS 26: chiede il permesso per le sveglie (testo "Sbu Noise usa una sveglia di sistema come riserva…"). iOS 17–25: chiede le notifiche. Footer sotto il modulo: "La sveglia suona se Noise resta aperta con un suono attivo. Altrimenti …".
    - [ ]

11. **Sveglia con il suono che gira, schermo bloccato** (il caso principale)
    - Prima: sveglia tra 3 minuti, Suono "Rintocchi", Dissolvenza 1 minuto. Fai partire Pioggia forte, blocca lo schermo.
    - Atteso: all'ora la pioggia si ferma e i Rintocchi salgono dal silenzio in circa 1 minuto; sulla schermata bloccata c'è la scheda "Sveglia" con Rimanda e Ferma, e la scheda In riproduzione dice "Sveglia". Ferma (dalla notifica o con pausa sulla scheda) la spegne. Nessuna notifica di riserva arriva dopo (nemmeno nei 5 minuti successivi). Su iOS 26: nessuna sveglia di sistema suona sopra.
    - [ ]

12. **Rimanda**: come la 11, ma con Rimanda (9 minuti). Atteso: silenzio, poi dopo 9 minuti suona di nuovo (nell'app se lo schermo era acceso, altrimenti la riserva). Sul player la riga "Sveglia alle …" mostra l'ora del rinvio.
    - [ ]

13. **App aperta sullo schermo, senza suono**: sveglia tra 2 minuti, app aperta (anche sull'orologio Dormi), nessun suono. Atteso: suona a schermo intero nell'app, nessuna notifica sopra.
    - [ ]

14. **Riserva: app chiusa**
    - Prima: sveglia tra 3 minuti; chiudi l'app dal selettore.
    - Atteso iOS 17–25: all'ora arriva la notifica "Sveglia" con il suono dei Rintocchi, poi una al minuto per 5 minuti; Ferma o un tocco le toglie tutte; la sveglia singola risulta spenta riaprendo l'app.
    - Atteso iOS 26: suona la sveglia di sistema (AlarmKit) col suono dei Rintocchi, anche con il silenzioso; Ferma la spegne.
    - Annota per #424: formato e durata accettati dal suono AlarmKit (se suona il suono di default invece dei Rintocchi, scrivilo).
    - [ ]

15. **Riserva con suono in pausa**: come la 14 ma con l'app in background e il suono in pausa (l'app viene sospesa). Atteso: come la 14.
    - [ ]

16. **AlarmKit e sessione audio (#424)**, iOS 26: sveglia tra 3 minuti, Pioggia in riproduzione, schermo bloccato. Atteso: suona solo la sveglia dell'app (la sveglia di sistema viene annullata 2 secondi prima). Se suonano tutte e due, o se la sveglia di sistema interrompe la pioggia prima dell'ora, scrivilo con l'orario.
    - [ ]

17. **Ripetizione**: sveglia per domani su un giorno della settimana. Atteso: in lista "Sveglia · lun · Rintocchi"; dopo Ferma resta accesa per il giorno dopo.
    - [ ]

18. **Avvisi**
    - Notifiche (o sveglie iOS 26) negate in Impostazioni di iOS, poi torna nell'app: in Timer, sotto le sveglie, la riga col triangolo "Le notifiche di Sbu Noise sono spente…" (o "Le sveglie…").
    - Un timer di 30 minuti attivo e una sveglia tra 2 ore: riga "Il suono si ferma prima: la sveglia arriva solo come notifica." (o "come sveglia di sistema").
    - [ ]

19. **Timer e sveglia insieme**: timer di 1 minuto con dissolvenza 30 secondi mentre la sveglia sta suonando. Atteso: il timer non spegne la sveglia.
    - [ ]

20. **Suono della sveglia dal catalogo**: sveglia con Suono "Mare". Atteso: suona il mare in dissolvenza; la riserva usa comunque i Rintocchi.
    - [ ]

21. **Cuffie**: sveglia con le cuffie collegate. Atteso: suona in cuffia (scelta voluta, decisione #407). Scollegandole durante la sveglia: annota cosa succede.
    - [ ]

## E. Orologio da comodino (#421)

22. **Dormi**: tocca Dormi (luna). Atteso: sfondo scuro anche con iOS in chiaro, ora grande col quadratino, data, "Sveglia alle …" o "Nessuna sveglia", il suono in corso con play/pausa, cursore della luminosità. Lascialo aperto 5 minuti: lo schermo non si spegne. Chiudi (X): lo schermo torna a spegnersi da solo.
    - [ ]

23. **Luminosità**: sposta il cursore al minimo, chiudi e riapri. Atteso: tutto molto tenue ma leggibile da vicino; il valore resta.
    - [ ]

24. **Sveglia dentro Dormi**: con l'orologio aperto e una sveglia tra 2 minuti. Atteso: la sveglia appare dentro l'orologio con Ferma e Rimanda; dopo Ferma torna l'orologio.
    - [ ]

## F. Accessibilità, aspetto, lingua

25. **Testo enorme** (Impostazioni → Accessibilità → Testo più grande, massimo): player, Gestisci, Timer, Nuova sveglia, sveglia che suona, Dormi, Crediti. Atteso: niente testo tagliato o sovrapposto; il simbolo del suono si rimpicciolisce per lasciare spazio al nome.
    - [ ]

26. **VoiceOver**: sul player, in Gestisci (azioni Nascondi / Aggiungi ai preferiti dal rotore Azioni), nella sveglia che suona (Ferma, Rimanda), in Dormi (cursore "Luminosità" con valore in percentuale). Atteso: ogni elemento ha un nome in italiano; il quadratino non viene letto.
    - [ ]

27. **Scuro**: tutte le schermate sopra in modalità scura. Atteso: carta scura, un solo accento.
    - [ ]

28. **Inglese**: lingua dell'iPhone in inglese. Atteso: nomi dei suoni, gruppi, sveglia, Gestisci, crediti in inglese; il permesso AlarmKit in inglese.
    - [ ]

## G. Audio in background (non verificabile sul simulatore)

29. Suono di una registrazione (es. Mare) con schermo bloccato per 30 minuti: nessuno stacco al giro del loop, nessuna interruzione. Comandi dalla schermata bloccata e dalle cuffie funzionano.
    - [ ]

30. Memoria: un mix di 5 registrazioni per 10 minuti, poi scorri tra 10 suoni. Atteso: nessun blocco o chiusura dell'app.
    - [ ]

## Note per chi prova

- I file audio sono le anteprime pubbliche HQ (MP3 128 kbps) delle pagine Freesound CC0, ricodificate in AAC 96 kbps. Se un suono suona povero, si può rifare dall'originale WAV (serve un login Freesound) con `SoundTools/make_sounds.py`.
- Su App Store Connect va abilitata per l'App ID la capability "Time Sensitive Notifications" (aggiunta negli entitlements); con la firma automatica di Xcode si aggiunge da sola.
