# Sbu Speed 1.0: test book

Prova manuale su iPhone reale, prima dell'invio. Ramo `app/speed-1.0`. Spunta ogni caso; se qualcosa non torna, annota il numero del caso e cosa hai visto.

Il simulatore ha già verificato: unità e conversioni (test unitari), durata formattata, layout verticale e orizzontale a testo normale, XXXL e AX5, tema scuro, inglese, un viaggio simulato a 20 nodi (velocità, massima, distanza 0,1 nmi, durata 20 secondi). Non ha verificato: GPS vero, vibrazione e suono, schermo acceso a lungo, rotazione in un supporto vero, VoiceOver a voce.

Prima di iniziare: installa la build del ramo, Impostazioni iPhone in italiano, testo a dimensione standard, tema chiaro.

## 1. Primo avvio

- [ ] **1.1 Permesso posizione.** Precondizione: app mai aperta (o rimossa e reinstallata). Passi: apri Sbu Speed. Atteso: la riga sotto la cifra dice "Consenti la posizione", poi compare la richiesta di sistema con il testo "Sbu Speed usa la posizione solo mentre è aperta…". Tocca "Consenti mentre usi l'app".
- [ ] **1.2 Ricerca segnale.** Passi: resta all'aperto. Atteso: la cifra è un trattino e la riga dice "Cerco il segnale GPS", poi compare la velocità e la riga diventa "Fermo".
- [ ] **1.3 Unità della regione.** Atteso: con regione Italia la velocità è in km/h. In Impostazioni → Unità la scelta è "km/h".
- [ ] **1.4 Viaggio vuoto.** Atteso: Massima 0 km/h, Media 0 km/h, Distanza 0,0 km, Durata 0:00:00. "Azzera viaggio" è disattivato.

## 2. Permessi negati

- [ ] **2.1 Posizione negata.** Passi: Impostazioni iPhone → Privacy → Localizzazione → Sbu Speed → Mai. Torna nell'app. Atteso: trattino, riga "Posizione non consentita", al posto di "Azzera viaggio" c'è "Apri Impostazioni" che apre la pagina dell'app in Impostazioni.
- [ ] **2.2 Posizione approssimativa.** Passi: rimetti "Mentre usi l'app" ma spegni "Posizione esatta". Atteso: riga "Serve la posizione esatta" e pill "Apri Impostazioni".
- [ ] **2.3 Ritorno.** Passi: riaccendi "Posizione esatta". Atteso: la velocità torna senza riaprire l'app; il viaggio di prima è ancora lì.

## 3. Velocità e viaggio (in auto, da passeggero, o in bici)

- [ ] **3.1 Cifra.** Passi: muoviti. Atteso: la cifra grande segue la velocità del tachimetro dell'auto (il GPS di solito segna 2–5 km/h meno del tachimetro, è normale), riga "In movimento", l'arco del quadrante si riempie nel colore dell'app.
- [ ] **3.2 Massima.** Atteso: "Massima" resta al valore più alto raggiunto anche quando rallenti.
- [ ] **3.3 Media.** Passi: fermati a un semaforo per un minuto. Atteso: la media non scende durante la sosta.
- [ ] **3.4 Distanza.** Passi: fai un tratto di cui conosci la lunghezza (almeno 2 km). Atteso: la distanza è vicina, a una cifra decimale.
- [ ] **3.5 Durata (nuova).** Atteso: "Durata" conta i secondi solo mentre ti muovi (formato ore:minuti:secondi, ad esempio 0:12:34); al semaforo si ferma, poi riparte.
- [ ] **3.6 Viaggio salvato.** Passi: chiudi l'app dal multitasking e riaprila. Atteso: Massima, Media, Distanza e Durata sono quelle di prima e continuano a salire.
- [ ] **3.7 Azzera viaggio.** Passi: tocca "Azzera viaggio". Atteso: compare una conferma con "Azzera viaggio" in rosso; annulla e il viaggio resta; ripeti e conferma: tutti e quattro i valori tornano a zero.
- [ ] **3.8 Quadrante adattivo.** Atteso: sotto i 60 km/h l'arco è pieno a 60; oltre, la scala sale a 120, 200, 300 e non torna indietro finché la massima del viaggio la tiene.
- [ ] **3.9 Schermo acceso.** Passi: lascia l'app aperta senza toccarla per più del blocco automatico. Atteso: lo schermo non si spegne. Andando alla Home, l'iPhone torna a bloccarsi come sempre.

## 4. Nodi (nuovo)

- [ ] **4.1 Scelta.** Passi: Impostazioni → Unità → Velocità: "kn". Atteso: il piè di pagina dice "La distanza segue la velocità: chilometri con km/h, miglia con mph, miglia nautiche con i nodi." Chiudi: la cifra è in "kn", Massima e Media in kn, Distanza in "nmi" (ad esempio "6,7 nmi").
- [ ] **4.2 Conversione.** Atteso: 50 km/h corrispondono a circa 27 kn (1 kn = 1,852 km/h). Controlla con un'app di navigazione o un calcolo veloce.
- [ ] **4.3 Persistenza.** Passi: chiudi e riapri l'app. Atteso: resta in nodi.
- [ ] **4.4 Limiti in nodi.** Passi: Impostazioni → Limite di velocità → Limite. Atteso: le scelte sono Nessuno, 5, 10, 15, 20, 25, 30 kn.
- [ ] **4.5 Limite che segue l'unità.** Passi: in km/h scegli 50 km/h, poi passa a kn. Atteso: il limite diventa 25 kn. Torna a km/h: diventa 50 km/h.
- [ ] **4.6 Ritorno a km/h e mph.** Atteso: tutte e tre le unità si scelgono e la distanza segue (km, mi, nmi).

## 5. Limite di velocità

- [ ] **5.1 Superamento.** Precondizione: limite a 30 km/h (o 20 mph, o 10 kn in barca). Passi: superalo. Atteso: la riga sotto la cifra diventa "Oltre il limite di 30 km/h" in rosso con il triangolo; la cifra resta nera; l'iPhone vibra e suona una volta.
- [ ] **5.2 Niente ripetizioni.** Passi: resta intorno al limite. Atteso: nessun altro suono finché non scendi di almeno 3 unità sotto il limite e lo superi di nuovo.
- [ ] **5.3 Silenzioso.** Passi: interruttore silenzioso attivo. Atteso: vibra senza suono (comportamento di sistema).

## 6. Orizzontale (nuovo)

- [ ] **6.1 Rotazione.** Precondizione: blocco rotazione spento in Centro di Controllo. Passi: gira l'iPhone in orizzontale, sia a sinistra sia a destra. Atteso: la cifra con "Velocità", la riga di stato e "Azzera viaggio" stanno a sinistra; il quadrante e i quattro valori del viaggio (due per due) a destra. Niente è tagliato, niente esce dallo schermo, l'isola dinamica non copre nulla.
- [ ] **6.2 Nel supporto.** Passi: metti l'iPhone nel supporto dell'auto in orizzontale e guida (da passeggero, o guardando solo a semaforo fermo). Atteso: la cifra si legge a colpo d'occhio, i valori si aggiornano.
- [ ] **6.3 Rotazione con la conferma aperta.** Passi: tocca "Azzera viaggio" e, con la conferma aperta, ruota. Atteso: niente si rompe; la conferma resta o si chiude senza azzerare.
- [ ] **6.4 Impostazioni in orizzontale.** Passi: tocca l'ingranaggio in orizzontale. Atteso: il foglio si apre e scorre; tutto leggibile.
- [ ] **6.5 Ritorno in verticale.** Atteso: il layout verticale è come prima (cifra, quadrante, viaggio due per due, pill in basso).

## 7. Testo grande

- [ ] **7.1 XXXL.** Passi: Impostazioni iPhone → Schermo e luminosità → Dimensioni testo al massimo (senza "Caratteri più grandi"). Atteso: in verticale e in orizzontale tutto sta nello schermo senza scorrere, niente tagliato.
- [ ] **7.2 Accessibilità al massimo.** Passi: Accessibilità → Schermo e dimensione testo → Testo più grande, attivo e al massimo. Atteso: la schermata scorre; il quadrante sparisce (è solo un disegno); i quattro valori sono uno sotto l'altro; scorrendo si arriva ad "Azzera viaggio". In orizzontale idem: si scorre fino in fondo.
- [ ] **7.3 Durata a testo grande.** Atteso: "0:16:10" non va a capo a metà.

## 8. VoiceOver

- [ ] **8.1 Cifra.** Passi: attiva VoiceOver, scorri. Atteso: legge "Velocità, 52 km/h, In movimento" (il quadratino e il quadrante non vengono letti).
- [ ] **8.2 Viaggio.** Atteso: ogni valore si legge come etichetta e valore, ad esempio "Massima, 87 chilometri orari"; la Durata si legge a parole: "Durata, 16 minuti e 10 secondi", non "zero due punti sedici".
- [ ] **8.3 Nodi.** Atteso: in nodi legge "nodi" e "miglia nautiche".
- [ ] **8.4 Orizzontale.** Atteso: in orizzontale l'ordine è cifra, Azzera viaggio, poi il viaggio (o comunque logico, senza salti strani).

## 9. Tema scuro

- [ ] **9.1** Passi: attiva il tema scuro. Atteso: fondo nero caldo, cifra chiara, quadratino e arco nel verde dell'app, testi secondari grigi leggibili, sia in verticale sia in orizzontale.

## 10. Inglese

- [ ] **10.1** Passi: lingua iPhone in inglese, regione Stati Uniti, reinstalla l'app (o cancella i dati). Atteso: unità iniziale mph; etichette "Top", "Average", "Distance", "Time"; pill "Reset trip".
- [ ] **10.2** Atteso: in Impostazioni "Distance follows speed: kilometres with km/h, miles with mph, nautical miles with knots."; con i nodi i valori sono "kn" e "nmi"; la durata VoiceOver è "16 minutes, 10 seconds".

## 11. Impostazioni e promessa

- [ ] **11.1** Atteso: in Impostazioni ci sono Unità, Limite di velocità, Privacy (apre sbu.dev in Safari), Licenze (con Bricolage Grotesque), le pill della promessa e il piede sbu.dev.
- [ ] **11.2 Nessuna rete.** Passi: modalità aereo con GPS acceso. Atteso: l'app funziona uguale (il GPS non richiede rete).
