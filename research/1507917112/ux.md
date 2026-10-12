# Find Air: ricerca UX

Originale: Find Air - My Device Tracker (Air Apps Systems, id 1507917112). Fonti: scheda App Store IT e US, i 3 screenshot in `screenshots/`, 74 recensioni da 1 a 3 stelle in `reviews.json` (2 IT, 72 US), la pagina prodotto dello sviluppatore, documentazione Apple e guide tecniche pubbliche. Il testo descrive il comportamento; non riprende testi, grafica o marchio. Non esistono recensioni giornalistiche indipendenti né pagine di aiuto con risposte: le domande nelle FAQ dello sviluppatore sono quasi tutte senza risposta.

## Onboarding e paywall

- All'avvio: alcune pagine introduttive, poi il paywall dell'abbonamento Air Apps One con prova gratuita. Diverse recensioni dicono che compare prima di poter usare l'app. Poco dopo arriva la richiesta "ti piace l'app?", e immagini generate per vendere l'abbonamento.
- Il paywall torna su azioni bloccate: "cerca di nuovo" e l'apertura del dispositivo trovato. Senza abbonamento in pratica si fa una scansione sola.
- Notifiche: chi ha attivato l'avviso di perdita racconta di notifiche ogni 10 minuti anche dopo aver disinstallato.

Fonti: recensioni US in `reviews.json` ("Does not work at all…", "App absolutely sucks", "Wish I could give it none.", "It sucks", "Alright buddy"); https://apps.apple.com/us/app/find-air-my-device-tracker/id1507917112

## Schermate e disposizione

1. **Lista dispositivi (home).** Ingranaggio in alto a sinistra, punto interrogativo in alto a destra, titolo grande con il nome dell'app. Sotto, righe arrotondate: a sinistra l'immagine del tipo di dispositivo dentro un anello che si riempie col segnale, al centro nome e percentuale, a destra una freccia. (screenshot 03)
2. **Foglio di scansione.** Foglio dal basso sopra la lista, titolo "Scansione…", pulsante di chiusura a destra, cerchi concentrici che pulsano attorno al simbolo Bluetooth. (screenshot 03)
3. **Dettaglio / ricerca.** Indietro in alto, nome del dispositivo come titolo grande, suggerimento "muoviti perché il segnale cresca", riga con interruttore "avvisa se perso", al centro un grande anello che si riempie attorno all'immagine del dispositivo, sotto il valore in percentuale grande. (screenshot 02)
4. **Paywall.** Piani settimanale, mensile, annuale, prova gratuita, chiusura. (recensioni)
5. **Impostazioni.** Abbonamento, ripristino acquisti, valuta, altre app, privacy e termini. (dedotto dalla scheda e dal pattern Air Apps; non visibile negli screenshot)
6. **Aiuto.** Consigli per la ricerca. (pulsante ? nello screenshot 03; contenuto non pubblico)

Fonti: `screenshots/01.jpg`-`03.jpg`; https://airapps.co/find

## Feature, passo per passo

- **Scansione vicina.** Apri l'app, concedi il Bluetooth, la scansione parte; i dispositivi BLE che trasmettono compaiono in lista con il segnale. Lo sviluppatore la descrive come rilevamento in tempo reale dei dispositivi intorno, solo a corto raggio e al chiuso, senza internet. https://airapps.co/find
- **Caldo/freddo.** Tocchi il dispositivo, cammini, l'anello e la percentuale salgono man mano che ti avvicini. Lo sviluppatore: "segui il segnale mentre si rafforza". Le recensioni dicono che il valore salta, che può salire allontanandosi, che tra metallo e coperte non distingue nulla. https://airapps.co/find, `reviews.json`
- **Più dispositivi.** Tutti i dispositivi visti in un'unica lista. https://airapps.co/find
- **Batteria.** Dalla 3.10.0 mostra il livello di batteria di "alcuni" dispositivi accoppiati; per lo sviluppatore serve a capire se il dispositivo è acceso e quindi rilevabile. https://apps.apple.com/us/app/find-air-my-device-tracker/id1507917112
- **Avvisa se perso.** Interruttore nel dettaglio; notifica quando il dispositivo esce dalla portata. Funzionamento non documentato. (screenshot 02, recensioni)
- **Gesti.** Solo tocchi: riga per aprire, chiudi sul foglio, indietro. Nessun gesto speciale visto.
- **Widget, Siri, Watch.** Nessuno indicato nella scheda.

## Prezzi

- Descrizione: settimanale 4,99 $, mensile 9,99 $, annuale 69,99 $.
- Acquisti in-app elencati: Air Apps One 1 settimana 4,99/5,99/9,99 $, 1 mese 19,99 $, 1 anno 69,99 $; Air Apps Pro 9,99/19,99/69,99 $.
- Sito: Air Apps One 19,99 $/mese per 38+ app; Air Apps Pro 199,99 $/mese.
- Etichetta privacy: acquisti, identificatori, dati d'uso e diagnostica "usati per tracciarti". Età 4+ con pubblicità.

Fonti: https://apps.apple.com/us/app/find-air-my-device-tracker/id1507917112, https://airapps.co/find, `meta.json`

## Limiti tecnici di iOS (valgono anche per Sbu)

- **AirPods nella custodia chiusa** di norma non trasmettono; la custodia trasmette solo aperta o in carica. Una cuffia scarica o spenta non si trova. https://apps.apple.com/app/id1495817993 (FAQ di uno scanner simile), https://mwm.ai/apps/scanr-bluetooth-finder/1546690342
- **Cuffie Bluetooth classiche** (audio BR/EDR) non compaiono in una scansione CoreBluetooth se non trasmettono anche in BLE. https://developer.apple.com/documentation/corebluetooth
- **Identità instabile.** iOS non espone l'indirizzo MAC: ogni periferica ha un UUID per app che può cambiare quando il dispositivo ruota l'indirizzo (AirPods e altri prodotti Apple lo fanno). Riconoscere "le mie cuffie" tra una sessione e l'altra non è garantito. https://punchthrough.com/core-bluetooth-guide/, https://developer.apple.com/forums/thread/742792
- **RSSI.** Arriva a ogni pubblicità (da circa −30 a −99 dBm), varia col chip, col corpo, con metallo e muri; per letture continue servono i duplicati attivi. Va filtrato. https://punchthrough.com/core-bluetooth-guide/
- **Background.** In background la scansione richiede un filtro per UUID di servizio, ignora i duplicati ed è rallentata: un avviso di separazione affidabile per cuffie qualunque non si può fare. https://developer.apple.com/documentation/corebluetooth/cbcentralmanager/scanforperipherals(withservices:options:)
- **Rete Dov'è.** I dispositivi e gli accessori della rete Dov'è si localizzano solo dall'app Dov'è di Apple; nessuna API per terzi. https://support.apple.com/en-us/104978

## Confronto onesto con Dov'è di Apple

Dov'è è gratis, già sul telefono, trova AirPods, Apple Watch, iPhone, iPad e AirTag anche lontani tramite la rete Dov'è, mostra l'ultima posizione nota, fa suonare il dispositivo e con AirPods Pro 2 o successivi su iPhone con Ultra Wideband dà distanza e direzione (Trova nelle vicinanze). Per un dispositivo Apple registrato è sempre la prima scelta. https://support.apple.com/en-us/104978

Uno scanner BLE come Find Air (o Sbu Find) serve per ciò che Dov'è non vede: cuffie, smartwatch, fitness tracker, anelli, apparecchi acustici, altoparlanti di altre marche, purché accesi, fuori dalla custodia e entro una decina di metri. Non fa suonare nulla e non vede oltre la portata Bluetooth.
