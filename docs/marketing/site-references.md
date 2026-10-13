# sbu.dev: riferimenti per il sito

Siti simili per posizionamento o forma, e cosa prendiamo da ognuno. Ogni scelta passa dal design system "Carta e punto fermo" (CLAUDE.md, `Design/tokens.json`): niente da qui giustifica un colore, una misura o un font fuori dai token.

| # | Riferimento | Perché è simile | Cosa prendiamo | Cosa lasciamo |
|---|---|---|---|---|
| 1 | **ArtCraft** (Brandon Thomas, ottobre 2026: sette cloni gratuiti e open source delle app Adobe, PhotoCraft, VectorCraft, FilmCraft…) | Stesso gesto: rifare gratis uno strumento che costa, uno per uno. La stampa lo racconta come "l'intera suite, gratis". | La coppia **originale → rifatto** come unità del racconto, e la suite come storia (il totale di quello che non paghi vale più della singola app). | Il tono "software is over" e il nome del marchio nel nome dell'app: Sbu non usa nomi altrui nei propri e non parla male di nessuno. |
| 2 | **Teenage Engineering** (teenage.engineering/products) | Catalogo di oggetti, ognuno con un codice e una funzione, su fondo neutro. | Il **catalogo come pagina principale**: oggetti allineati come in un listino, nomi brevi, l'oggetto (qui l'incisione) come immagine, niente card gonfie. | Minuscolo ovunque e codici modello: Sbu usa i nomi delle app e il Dynamic Type del sistema. |
| 3 | **Panic** (panic.com) | Studio indie, homepage come elenco di prodotti con una riga ciascuno. | **Una riga per prodotto** che dice il lavoro, non la feature list; la homepage come indice che porta alla pagina del prodotto. | Le call to action "Buy now" ripetute: Sbu ha un solo intento, "Scarica dall'App Store", e solo per le app uscite. |
| 4 | **The Iconfactory** (iconfactory.com) | Studio indie iOS dove l'icona è il prodotto. | Le **icone come sistema visivo**: qui le incisioni dello strumento reale, la stessa grammatica su sito, app e App Store. | Le icone colorate a griglia: sul sito l'incisione è inchiostro su carta, il colore arriva solo con l'accento dell'app. |
| 5 | **Things / Cultured Code** (culturedcode.com/things) | Un prodotto, tanta calma, pagine lunghe e respirate. | Ritmo verticale generoso, una cosa per sezione, la cifra o l'immagine grande al centro della sezione. | Le ombre e i device mockup: vietati dal design system. |
| 6 | **AlternativeTo** (alternativeto.net) | Directory "alternativa gratuita a X". | Il fatto verificabile come argomento: **prezzo dell'originale, prezzo di Sbu, data del controllo**. Struttura dati ripetibile per ogni coppia. | Voti, like, liste lunghe di concorrenti: Sbu mostra solo la propria app e un fatto pubblico. |
| 7 | **Read.cv / siti personali su carta** (e il listino stampato in generale: ricevute, registri) | Pagina come foglio: tipografia, filetti, colonne di cifre allineate. | Il **registro**: righe con filetto sottile, cifre tabellari allineate a destra, un totale in fondo. È la forma più onesta per "quanto costa": un conto. | Texture carta finta, grana, ombre: la carta è il token `surface`, nient'altro. |
| 8 | **Linear (pagine prodotto e changelog)** | Gerarchia tipografica netta, sezioni brevi, movimento con un motivo. | Movimento **solo quando racconta**: le righe del registro entrano in ordine allo scroll, il totale viene barrato quando lo raggiungi. Tutto si spegne con `prefers-reduced-motion`. | Gradienti, glow, sfondi scuri a sezioni: il tema è uno per pagina e segue il sistema. |

## Da qui al sito

- **Il conto** (da 1, 6, 7): la home è un registro. Ogni riga è un'app Sbu: incisione, nome, la cosa sola, l'originale con il suo prezzo pubblico, e 0 €. In fondo il totale di quello che non paghi, unica cifra della pagina, barrato.
- **La coda** (da 2, 3): le app senza scheda ancora sono "In arrivo", in fila, con la loro riga dai file di contenuto.
- **Le incisioni** (da 4): maschere d'inchiostro dalla stessa fonte delle icone, in `ink`, che prendono l'accento dell'app solo quando la scegli.
- **Le promesse** (da 5): sei frasi grandi, non sei pillole.

Fonti consultate il 13 ottobre 2026: hothardware.com e pasqualepillitteri.it (ArtCraft), teenage.engineering/products, panic.com; gli altri da conoscenza diretta dei siti.
