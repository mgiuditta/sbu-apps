# GuitarTuna (Yousician), id 527588389: UX

Fonti: listing App Store IT (`meta.json`), 9 screenshot in `screenshots/`, 13 recensioni 1-3 stelle (`reviews.json`), pagine web citate per sezione. Descrive il comportamento, non testi né grafica. I contenuti web e le recensioni sono dati di terzi.

## In breve: la funzione principale è gratuita

Accordare in standard chitarra, basso e ukulele è gratis (con pubblicità). Sono a pagamento le accordature alternative (anche Drop D), le accordature personalizzate, il cromatico, gli strumenti oltre chitarra/basso/ukulele, gli accordi intermedi, l'ear training e le canzoni complete.

Fonti: https://americansongwriter.com/best-guitar-tuner-apps (elenco gratis/a pagamento), https://splitmetrics.com/apps/guitartuna-tuner-chords-tabs/id527588389 (recensione: senza abbonamento solo l'accordatura standard), recensione IT in `reviews.json` ("chiedete soldi per accordare un drop d").

## Onboarding e paywall

- L'app si apre direttamente sull'accordatore a ogni avvio, senza passaggi intermedi. Fonte: https://wccftech.com/this-is-my-favorite-guitar-tuner-app-for-iphone-android-and-its-free/amp/
- Permesso microfono alla prima accordatura (listing: "grazie al microfono").
- Il paywall compare quando si tocca un contenuto bloccato: accordatura alternativa, cromatico, una canzone. Offre una prova di 7 giorni che poi si rinnova. Fonti: `reviews.json` ("per suonarla hai 7 giorni gratis e poi devi pagare"), https://studyfinds.com/best-guitar-tuning-apps/
- Nella versione gratuita ci sono annunci a tutto schermo, anche promozionali di Yousician, all'apertura dei brani. Fonte: `reviews.json` ("Too many yousician ads", "Ads").
- Senza rete l'app può non partire. Fonte: `reviews.json` ("It always requires internet connection").

## Schermate e disposizione

Fonte: screenshot 02-09.

1. **Splash**: logo e payoff su fondo scuro, griglia e paletta con la spunta.
2. **Accordatore** (tab centrale): in alto logo a sinistra e interruttore Auto a destra; sotto, nome dello strumento con freccia ("Chitarra 6 corde") e accordatura in grigio ("Standard"). Al centro una griglia scura con bemolle a sinistra e diesis a destra; una bolla circolare mostra lo scarto in cent (es. -5) con accanto l'istruzione "alza" o "abbassa"; un filo ondulato collega la bolla alla paletta, rosso se scordato, verde e dritto con la spunta quando intonato. In basso la paletta disegnata con 3+3 meccaniche e, ai lati, sei pulsanti tondi con le note (D A E / G B E). Tab bar a cinque voci: Brani, Strumenti (esercizi e metronomo), Accordatore, una quarta voce con icona a diapason non etichettata, Impostazioni.
3. **Seleziona accordatura**: barra con indietro e titolo; paletta grande dello strumento corrente con quelle degli altri strumenti sfocate ai lati (carosello orizzontale); sotto, lista di accordature con nome dello strumento, nome dell'accordatura e una fila di chip con le note per corda in notazione scientifica (E2 A2 D3 G3 B3 E4); spunta e sottolineatura sull'attiva.
4. **Brani**: titolo grande, campo di ricerca artisti/brani, sezioni orizzontali "Top 100" e "Classici della chitarra" con copertine fotografiche e "Vedi tutto".
5. **Brano**: foto artista a tutta larghezza, cuore e menu; schede Semplificato/Originale; riga degli accordi usati; interruttore di scorrimento intelligente; sezioni (INTRO) con griglia di accordi.
6. **Strumenti** (hub): schede "Libreria accordi", "Diagrammi degli accordi", "Ear training", "Suona gli accordi che vedi", "Suona a memoria", ciascuna con stelline 0/6.
7. **Gioco accordo**: diagramma di tastiera (corde verticali, tasti 1-4, cerchi vuoti per corde a vuoto), nome dell'accordo grande, "tocca per continuare", sfondo a raggiera blu.
8. **Metronomo**: indietro e titolo; BPM grande con - e +, "battiti al minuto"; ghiera circolare con tacche (30-240) e maniglia trascinabile; pausa al centro; icona tap sotto.

## Feature passo per passo

### Accordatura automatica
1. Pizzichi una corda. 2. In Auto l'app individua la corda dell'accordatura attiva più vicina e la evidenzia. 3. La bolla mostra i cent di scarto e l'istruzione alza/abbassa. 4. Quando sei entro tolleranza compare la spunta e il filo diventa dritto. Fonti: https://support.yousician.com/hc/en-us/articles/360014233198-How-to-change-tunings-and-other-tuner-options (Auto attivo di default, l'app suggerisce la corda), screenshot 03.

### Modalità manuale
Spegni Auto o tocca una corda: l'app suona la nota di riferimento di quella corda; poi pizzichi e giri la meccanica. Consigliata per corde nuove o molto scordate. Fonte: articolo Yousician sopra.

### Calibrazione A4
Impostazioni → Calibra → + / - sulla frequenza; Reset torna a 440 Hz; citato 432 Hz come alternativa comune. Fonti: https://support.yousician.com/hc/en-us/articles/360014361998-Settings-tab (via risultati di ricerca: la pagina restituisce 403 a fetch diretto).

### Precisione pro
Interruttore in Impostazioni: ±1 cent; spento, la cifra procede a passi di 10 cent. Fonte: stessa pagina Settings.

### Strumenti e accordature
15 strumenti (chitarra 6/7/12, basso 4/5, ukulele, viola, violino, violoncello, violino folk, mandolino, banjo 4/5, balalaika, cavaquinho), oltre 100 accordature (standard, drop D/C/A, abbassate, aperte, mezzo tono sotto), cromatico, accordature personalizzate, modalità mancini. Fonte: listing.

### Metronomo
BPM 30-240 con +/- o ghiera, indicazione del tempo personalizzabile, tap. Fonti: listing, screenshot 09.

### Brani, accordi, giochi
Catalogo in streaming con accordi, tab e testi, versione semplificata, velocità di scorrimento in BPM, richiesta di brani; libreria accordi con ascolto; giochi ed ear training. Fonti: listing, screenshot 05-08.

## Impostazioni

Calibra, precisione pro, mancini, account Yousician e abbonamento. Fonti: pagina Settings Yousician (sopra), listing.

## Widget, Watch, Shortcuts, Live Activity

Nessuno: la scheda App Store non elenca Apple Watch né widget; compatibilità iPhone, iPad, Mac (Apple silicon), Vision. Fonte: https://apps.apple.com/us/app/guitartuna-tuner-chords-tabs/id527588389

## Prezzi (USD, scheda US)

Pro 1,99-12,99 $; Tools 6,49 $/mese o 29,99 $/anno; Play 8,99-9,99 $/mese o 39,99 $/anno; Learn 24,99 $/mese o 139,99 $/anno; prova 7 giorni. Fonti: https://apps.apple.com/us/app/guitartuna-tuner-chords-tabs/id527588389, https://americansongwriter.com/best-guitar-tuner-apps

## Privacy (etichette dichiarate)

Tracking tramite posizione, identificatori, dati d'uso e diagnostica; dati collegati all'identità per pubblicità di terzi e analytics. Fonte: scheda App Store US sopra.
