# Test book: Sbu Inventory 1.0

Collaudo manuale su iPhone vero prima di TestFlight. Ogni prova ha precondizioni, passi, risultato atteso e una casella: segna passa o non passa, senza interpretare. Se qualcosa non va, annota il numero della prova e cosa hai visto (screenshot se puoi).

Cosa serve: un iPhone con iOS 17 o più recente (A12 o più nuovo, per la lettura dei codici), qualche oggetto di casa con un codice a barre stampato (una confezione di pasta, un libro con ISBN) e una scatola con un QR o un codice a barre attaccato, l'app File, e per la prova 21 un Mac o un'altra app che apra un file ZIP.

Prima di iniziare: elimina Sbu Inventory se c'è già, installa la build da provare. Lingua dell'iPhone italiano, regione Italia, testo standard, tema chiaro, salvo dove la prova dice altro.

Le prove 1–12 si possono fare solo sul telefono vero (fotocamera, codici veri, permessi, notifiche, file, schermo). Le altre il simulatore le ha già passate: ripassale veloce.

---

## A. Solo sul telefono vero

### 1. Primo avvio, nessun permesso chiesto
- Precondizioni: app appena installata, mai aperta.
- Passi: apri Sbu Inventory.
- Atteso: nessuna richiesta di permessi. Al centro la scatola, "Inventario vuoto", "Aggiungi le cose che hai, con una foto, dove sono e quante.", il pulsante verde pieno "Aggiungi oggetto" e sotto "Prova con un esempio" su fondo bianco con testo verde. In alto a sinistra + e il simbolo del codice a barre, a destra l'ingranaggio. In basso il campo Cerca.
- [ ] Passa

### 2. Foto dalla fotocamera, permesso concesso
- Passi: "Aggiungi oggetto" → "Scatta una foto". Alla richiesta tocca Consenti. Fotografa un oggetto tenendo l'iPhone in verticale, tocca "Usa foto". Scrivi "Tazza", Salva.
- Atteso: la richiesta dice "Sbu Inventory usa la fotocamera per fotografare i tuoi oggetti e leggere le etichette che ci hai messo. Foto e codici restano su questo iPhone." Nel modulo compare la miniatura dritta (non girata di 90°). Nell'elenco la riga "Tazza" mostra la foto quadrata a sinistra e 1 a destra. Il totale in alto dice 1 con il quadratino verde.
- [ ] Passa

### 3. Foto dalla libreria, senza permesso
- Passi: apri Tazza → Modifica → "Scegli dalle foto". Scegli 2 foto, di cui una scattata in orizzontale. Salva.
- Atteso: nessuna richiesta di accesso alle foto. Compare un indicatore di avanzamento, poi le 2 miniature dopo la prima, tutte dritte. Nel dettaglio le 3 foto scorrono di lato con i puntini; un tocco apre la foto intera su fondo carta con "1 di 3" in alto e Fine.
- [ ] Passa

### 4. Massimo 8 foto
- Passi: Modifica → aggiungi foto finché puoi.
- Atteso: con 8 foto spariscono "Scegli dalle foto" e "Scatta una foto" e sotto la sezione c'è "Hai aggiunto 8 foto, il massimo per un oggetto.". Tieni premuta una miniatura: "Metti per prima" e "Rimuovi" funzionano. Annulla → "Le modifiche non sono salvate" → "Ignora le modifiche".
- [ ] Passa

### 5. Fotocamera negata
- Passi: Impostazioni iPhone → Sbu Inventory → Fotocamera spenta. Torna nell'app: aggiungi oggetto → "Scatta una foto".
- Atteso: avviso "Fotocamera non consentita" con il testo che spiega e i pulsanti "Apri Impostazioni" (porta alla pagina di Sbu Inventory) e Annulla. "Scegli dalle foto" continua a funzionare.
- [ ] Passa

### 6. Etichetta vera: collegare una scatola
- Precondizioni: fotocamera di nuovo consentita. "Prova con un esempio" fatto (prova 13) oppure una cartella qualsiasi.
- Passi: in alto a sinistra il simbolo del codice a barre ("Trova dall'etichetta"). Inquadra il QR o il codice a barre attaccato alla scatola.
- Atteso: l'inquadratura evidenzia il codice, l'iPhone vibra una volta, il foglio si chiude e si apre "Trova dall'etichetta" con "Etichetta nuova" e "Nessun oggetto ha questa etichetta…". Il contenuto del codice (numero o indirizzo) NON compare da nessuna parte, nessun link si apre. Tocca la cartella "Scatola 3" sotto "Collega a una cartella": si apre la cartella Scatola 3.
- [ ] Passa

### 7. Etichetta vera: ritrovare la scatola
- Passi: torna in cima, "Trova dall'etichetta", inquadra di nuovo la stessa scatola.
- Atteso: si apre direttamente la cartella Scatola 3, senza fogli intermedi.
- [ ] Passa

### 8. Codice a barre su un oggetto nuovo
- Passi: "Trova dall'etichetta" → inquadra il codice a barre della pasta → "Aggiungi un oggetto con questa etichetta" → nome "Pasta", quantità 3 → Salva.
- Atteso: il modulo mostra in "Etichetta" la riga Codice con le cifre del codice a barre. Dopo Salva si apre il dettaglio di Pasta. Una nuova scansione della stessa confezione apre Pasta.
- [ ] Passa

### 9. Scansione con fotocamera negata
- Passi: spegni di nuovo la fotocamera per Sbu Inventory. "Trova dall'etichetta".
- Atteso: niente inquadratura: "Fotocamera non consentita" in arancio con simbolo, "Apri Impostazioni", e il campo "Codice dell'etichetta". Scrivi le cifre della pasta e tocca Cerca: si apre Pasta. Riaccendi la fotocamera alla fine.
- [ ] Passa

### 10. Promemoria Da ricomprare a un'ora vera
- Precondizioni: esempio caricato (Pile AA 2 con minimo 4).
- Passi: Impostazioni → sezione "Da ricomprare" → Avvisami. Consenti le notifiche. Imposta Ora a 2 minuti da adesso. Esci dall'app e aspetta.
- Atteso: alla richiesta del permesso tocca Consenti; l'interruttore resta acceso e compare Ora. All'ora scelta arriva una notifica "Da ricomprare" con il testo "Pile AA". Se l'app è aperta arriva lo stesso, come banner.
- [ ] Passa

### 11. Notifiche negate
- Passi: Impostazioni iPhone → Sbu Inventory → Notifiche spente. Torna in Impostazioni dell'app.
- Atteso: sotto Avvisami compaiono "Notifiche spente per Sbu Inventory" in arancio con il triangolo e "Apri Impostazioni"; il piede dice "Senza notifiche nessun avviso arriva. Attivale nelle Impostazioni dell'iPhone." Spegni Avvisami: le righe spariscono.
- [ ] Passa

### 12. Esporta in File e reimporta
- Passi: Impostazioni → "Esporta archivio con foto" → Salva su File → In questo iPhone. Poi "Esporta CSV" → Salva su File. Elimina la cartella Esempio e Tazza (scorri a sinistra → Elimina → conferma). Impostazioni → Importa → scegli lo ZIP.
- Atteso: lo ZIP si chiama sbu-inventory-AAAA-MM-GG.zip, il CSV sbu-inventory-AAAA-MM-GG.csv. Dopo Importa: "Importare N oggetti?" con "Le cartelle che mancano vengono create…" → Importa → "Importazione completata" con il numero di oggetti. Tutto torna com'era: cartelle, quantità, prezzi, tag, etichette (la scansione della scatola apre di nuovo Scatola 3), foto dritte. Importa di nuovo lo stesso ZIP: "0 oggetti importati, N già presenti", niente doppioni. Apri il CSV in Numeri: una riga per oggetto, colonna "percorso" con "Esempio > Casa > Garage".
- [ ] Passa

## B. Inventario

### 13. Prova con un esempio
- Passi: dall'inventario vuoto, "Prova con un esempio".
- Atteso: compare la cartella "Esempio" (41 a destra, "7 voci" sotto). In alto OGGETTI 41 con il quadratino verde subito dopo, e sotto "7 voci in 5 cartelle · 575,90 €". Riga "Da ricomprare" in arancio con il carrello e 1 a destra.
- [ ] Passa

### 14. Cartelle e totali
- Passi: Esempio → Casa → Garage.
- Atteso: Garage mostra OGGETTI 10 e "4 voci in 1 cartella · 537,60 €"; sotto Cartelle "Scatola 3" (7, 2 voci) e sotto Oggetti "Bicicletta" 1 e "Pile AA" 2 con "Da ricomprare". Il campo in basso dice "Cerca in Garage".
- [ ] Passa

### 15. Quantità nel dettaglio
- Passi: tocca Pile AA. Tocca + due volte.
- Atteso: il numero passa a 3 e poi a 4 e "Da ricomprare" resta (4 è il minimo). Un altro +: 5 e "Da ricomprare" sparisce; nella cima la riga Da ricomprare sparisce. Sotto il numero "0,80 € l'uno · 4,00 € in tutto" si aggiorna.
- [ ] Passa

### 16. Sposta in
- Passi: nel dettaglio di Pile AA tocca la riga "Casa › Garage … Sposta" → scegli "Cucina".
- Atteso: il foglio mostra Inventario, le cartelle rientrate per livello e il segno di spunta su Garage. Dopo la scelta la riga dice "Esempio › Casa › Cucina". Prova anche a spostare la cartella Casa: nel foglio non compaiono Casa né le cartelle dentro.
- [ ] Passa

### 17. Cerca, tag e Da ricomprare
- Passi: in cima tocca Cerca, scrivi "trapano". Poi cancella e tocca il suggerimento "attrezzi". Poi la scheda "Da ricomprare" sopra i risultati.
- Atteso: "Trapano" con sotto "Esempio › Casa › Garage › Scatola 3". Con il tag attrezzi: Trapano e Cacciaviti. Con Da ricomprare: solo gli oggetti al minimo. Una parola che non c'è: "Nessun risultato per …".
- [ ] Passa

### 18. Eliminare una cartella
- Passi: scorri a sinistra su Esempio → Elimina.
- Atteso: avviso "Eliminare «Esempio»?" con "Va via anche quello che contiene: 7 voci e 4 cartelle, con le foto." e i pulsanti Annulla ed Elimina (rosso). Elimina: torna "Inventario vuoto". Riapri l'app: resta vuoto.
- [ ] Passa

### 19. Campi personalizzati
- Passi: Impostazioni → Campi personalizzati → Aggiungi campo → "Garanzia fino al", Tipo Data → Aggiungi. Apri un oggetto → Modifica → nella sezione Campi accendi "Garanzia fino al" e scegli una data → Salva.
- Atteso: il dettaglio mostra la sezione Campi con la data per esteso ("15 ottobre 2027"). Un campo lasciato vuoto non compare. Eliminare il campo chiede "Eliminare il campo «Garanzia fino al»?" con quanti oggetti lo hanno.
- [ ] Passa

### 20. Prezzo e data d'acquisto
- Passi: Modifica un oggetto: Prezzo di uno 12,50, Data d'acquisto accesa con una data, quantità 2.
- Atteso: nel dettaglio "12,50 € l'uno · 25,00 € in tutto" sotto il numero e la sezione Valore con Prezzo di uno 12,50 € e Data d'acquisto. In cima il valore totale aumenta di 25,00 €.
- [ ] Passa

### 21. Lo ZIP si apre fuori dall'app
- Passi: manda lo ZIP della prova 12 al Mac (AirDrop) e aprilo.
- Atteso: si apre senza errori; dentro inventory.csv e la cartella photos con file .heic che Anteprima apre dritti.
- [ ] Passa

## C. Accessibilità, temi, lingue

### 22. Testo più grande (AX5) e iPhone piccolo
- Passi: Impostazioni → Accessibilità → Schermo e dimensione testo → Testo più grande al massimo. Scorri inventario, una cartella, un oggetto, il modulo, Sposta in, Impostazioni.
- Atteso: niente testo tagliato con i puntini dentro le righe (solo il titolo in alto e il campo Cerca possono accorciarsi), nessuna parola spezzata a una lettera per riga. Nelle righe la miniatura sparisce e il numero va sotto il nome. Nel modulo "Quantità minima" va su una riga sua e − + sotto. Il quadratino resta attaccato al numero.
- [ ] Passa

### 23. VoiceOver
- Passi: attiva VoiceOver. Scorri l'inventario dell'esempio e il dettaglio di un oggetto con foto.
- Atteso: il totale si legge "Oggetti, 41, 7 voci in 5 cartelle, 575,90 €" (il quadratino non si legge). Una riga si legge come un solo elemento: nome, percorso o "Da ricomprare", "Quantità 2". Le foto si leggono "Foto 1 di 3". Nel modulo le miniature hanno l'azione Rimuovi.
- [ ] Passa

### 24. Tema scuro
- Passi: Centro di Controllo → Modalità scura. Ripassa inventario, dettaglio, modulo, Impostazioni.
- Atteso: fondo nero caldo, testi leggibili, il verde più chiaro, il testo sul pulsante verde scuro (non bianco). Nessun riquadro bianco rimasto.
- [ ] Passa

### 25. Inglese
- Passi: Impostazioni iPhone → Generali → Lingua e zona: inglese, regione Stati Uniti. Riapri l'app.
- Atteso: tutto in inglese ("Empty inventory", "Add item", "Try a sample", "To buy again", "Find by label"), l'esempio in inglese (Home, Garage, Box 3, AA batteries), importi in $ con il punto ("$575.90"). Rimetti l'italiano alla fine.
- [ ] Passa

---

Note per Matteo
- Il prezzo non ha una valuta propria: si mostra nella valuta della regione dell'iPhone. Cambiando regione, 12,50 € diventa $12.50 senza conversione (vedi report).
- Il trascinamento per spostare non c'è: si sposta con lo scorrimento, il menu tenendo premuto o "Sposta in".
