# Sbu Grid: sintesi su DrawinGrid

Originale: DrawinGrid di BUTTERFLYRAY LIMITED (id 1508298774). Concorrente: GridArt - Drawing Grid (id 6474590995). Dati: `research/1508298774/` e `research/6474590995/` (`meta.json` da `Tools/discover.py`; `reviews.json` con le 13 recensioni da 1 a 3 stelle di DrawinGrid; il feed di GridArt è vuoto). Gli screenshot stanno in `screenshots/`, esclusi da git. `Tools/spec.py` non ha generato `spec.json` perché in questa sessione manca `ANTHROPIC_API_KEY`: ho letto gli screenshot a mano e le schermate qui sotto vengono da lì.

## Numeri (itunes lookup, 16/10/2026)

| App | US | IT | Monetizzazione (scheda US) |
|---|---|---|---|
| DrawinGrid 3.4.0 | 4,73874 su 4995 | 4,73332 su 135 | Pubblicità, Remove Ads 10 $, Pro 8 $ e 86 $; account; tracking dichiarato (dati d'uso) |
| GridArt 2.0.6 | 4,5283 su 212 | 4,53333 su 15 | Pubblicità, Weekly 3,99 $, Monthly 12,99 $; tracking (ID dispositivo, posizione approssimativa) |

## Cosa fa DrawinGrid (le schermate in ordine)

1. **Griglia**: la foto riempie lo schermo con la griglia sopra. Pulsanti flottanti a destra: impostazioni griglia, ritaglio, schermo intero, carica immagine. Il menu a sinistra porta a progetti e account.
2. **Impostazioni griglia**: anteprima in alto, poi Carica immagine, Colore linea, Colonne e Righe (le righe si bloccano quando le celle sono quadrate), Spessore linea in pixel, Filtro (bianco e nero, seppia), interruttore Quadrati, interruttore Numeri.
3. **Ritaglio**: maniglie su lati e angoli, dimensione in pixel mostrata al centro, Ritaglia o Annulla.
4. **Schermo intero**: solo foto e griglia, con un pulsante per chiudere.
5. Dalla scheda, senza screenshot: **AR Sketch** (la foto semitrasparente sopra la fotocamera, per ricalcare sulla carta), **Traccia sullo schermo** (disegno col dito), export della foto con la griglia.

GridArt aggiunge: diagonali, linee tratteggiate, opacità, etichette (stile, colore, dimensione del testo), filtro schizzo, ritaglio a rapporti e formati carta (16:9, A1-A4, 3:4), celle in mm, cm o pollici, rotazione.

## Funzioni compatibili (da fare)

- Foto da PhotosPicker, senza permesso sulla libreria intera.
- Griglia con colonne e righe indipendenti, oppure celle quadrate; diagonali; etichette di riga e colonna; spessore e opacità della linea.
- Bianco e nero (Core Image) per leggere meglio i valori.
- Zoom e trascinamento; schermo intero.
- Ritaglio al formato del foglio (A5, A4, A3, Letter, personalizzato) con celle in cm o pollici; le righe e le colonne vengono dal foglio.
- Export in Foto o condivisione, e PDF in scala reale da stampare.
- Ricalco con la fotocamera: foto semitrasparente con la griglia sopra la vista della fotocamera, opacità regolabile, telefono su un supporto.

## Funzioni da saltare

- Account, progetti nel cloud, sincronizzazione, galleria pubblica, "segna come venduta", titoli suggeriti dall'AI: servono server o account.
- Pubblicità, Remove Ads, Pro, abbonamenti, richiesta di valutazione.
- Traccia sullo schermo e pennelli: disegno digitale, fuori scope (Sbu Grid aiuta a disegnare sulla carta).
- Filtro seppia e filtro schizzo: decorativi; resta solo il bianco e nero.
- Colori liberi della linea: il design system non ammette colori inventati. La linea usa `ink` o `surface` (scuro o chiaro, per il contrasto con la foto), da decidere nel task.

## Cosa chiedono le recensioni basse (13, DrawinGrid)

1. Pubblicità e Pro trasformato in abbonamento (2): "bait and switch".
2. Niente istruzioni, termini non spiegati (3).
3. Righe non modificabili o numero di linee non impostabile (2): succede con le celle quadrate attive.
4. Nessun formato del foglio né righello (2): il motivo del download.
5. Foto che non si caricano anche con l'accesso completo (3).
6. Maniglia di ritaglio in basso irraggiungibile su iPhone SE (1).
7. Nessuno strumento di disegno (1): fuori scope per Sbu, va detto nella scheda.

## Esiste un'alternativa gratuita pulita?

Ricerca: App Store, alternativeto, Reddit (nessun thread utile trovato). Candidate:

- **Gridy** (id 1504019093): gratis, "Data Not Collected", nessuna pubblicità dichiarata, 8 valutazioni US, ultima versione 1.1 del 16/02/2024. Fa solo righe, colonne (da 5 a 100), colore e spessore. Mancano ritaglio al foglio, misure, etichette, diagonali, bianco e nero, export, fotocamera.
- **MindGrids** (id 1582136020): gratis, nessun dato raccolto, 2 valutazioni, ferma al 2021. Solo griglia, colore e spessore.
- **Grid: Drawing tool** (id 6755344360): niente pubblicità, ma le funzioni sono sbloccate a pagamento (2,99-12,99 $). Non è gratis.
- **DrawGrid** (id 6743029255): gratis, ma contiene pubblicità.
- **Drawing Grid** (id 500885379): pulita ma costa 1,99 $.

Verdetto: nessuna app gratis e pulita copre la destinazione. Gridy e MindGrids sono pulite ma fanno solo la griglia di base, senza foglio, misure, export né fotocamera; sono lo stesso caso di "Knit Row Counter" nel filtro (gratis ma parziale). La mappa prosegue. Se Matteo legge la regola 4 in modo stretto ("anche oscura, anche parziale"), Gridy è il caso da decidere.

Fonti: [DrawinGrid](https://apps.apple.com/us/app/id1508298774), [GridArt](https://apps.apple.com/us/app/id6474590995), [Gridy](https://apps.apple.com/us/app/id1504019093), [MindGrids](https://apps.apple.com/us/app/id1582136020), [Grid: Drawing tool](https://apps.apple.com/us/app/id6755344360), [DrawGrid](https://apps.apple.com/us/app/id6743029255), [Drawing Grid](https://apps.apple.com/us/app/id500885379).

## Schermate di Sbu Grid, in ordine

1. **Griglia** (tab principale): stato vuoto con "Scegli una foto"; poi la foto con la griglia, zoom e trascinamento. La cifra unica è la misura della cella ("2 cm"), chiusa dal punto fermo.
2. **Griglia, impostazioni** (sheet, `Form`): colonne, righe, celle quadrate, diagonali, etichette, spessore, opacità, bianco e nero.
3. **Foglio** (sheet): formato, orientamento, unità, misura della cella, ritaglio con maniglie raggiungibili anche su iPhone SE.
4. **Schermo intero**: solo foto e griglia.
5. **Ricalca**: fotocamera con foto e griglia sopra, opacità.
6. **Esporta**: Foto, condividi, PDF in scala.
7. **Impostazioni**: promesse, aiuto in tre righe (le recensioni lo chiedono), licenze, sbu.dev.
