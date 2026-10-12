# Subscription Manager: Orbit (6692620188): UX

Ricerca su dati pubblici: scheda App Store IT e US (`meta.json`, cronologia versioni), 6 screenshot, 6 recensioni 1-3 stelle (`reviews.json`, 3 IT e 3 US), sito e guide dello sviluppatore, informativa privacy, bacheca roadmap pubblica. Come contesto, senza salvarle, le recensioni 1-3 stelle di Bobby (concorrente). Descrive il comportamento; testi, grafica, mascotte e marchio dell'Originale non vanno copiati. Nessun video o thread Reddit/Product Hunt utile trovato.

Fonti generali:
- Scheda US e cronologia versioni: https://apps.apple.com/us/app/subscription-manager-orbit/id6692620188
- Sito: https://tryorbit.com, https://tryorbit.com/about
- Guide e pagine funzione: https://learn.tryorbit.com
- Privacy: https://flooben.com/privacypolicy
- Roadmap: https://orbit.userjot.com

## Onboarding e momento del paywall

- La scheda promette "Magic Import" come "configurazione guidata": la prima esperienza è costruire l'elenco da prove esistenti (screenshot, estratto conto, CSV, PDF, testo incollato) oppure da una guida "Subscription Finder" in Impostazioni che aiuta a ricordare dove cercare. Fonti: `meta.json`, https://learn.tryorbit.com/features/magic-import/, note versione "Subscription Finder Guide".
- Permesso notifiche per i promemoria; la guida ai promemoria rimanda alle Impostazioni di iOS se non arrivano. Fonte: https://learn.tryorbit.com/features/subscription-reminders/
- Il paywall arriva presto: il livello gratuito tiene pochi abbonamenti (5 al lancio secondo una recensione della 1.0.1, 3 secondo una recensione IT della 1.1.8). Superato il limite compare Orbit Plus. Una nota di versione corregge un bug che chiedeva l'upgrade anche a chi aveva già pagato. Fonti: `reviews.json`, cronologia versioni.
- I widget sono stati "aperti a tutti per provarli" con l'aggiornamento iOS 26, ma la descrizione li elenca tra le funzioni Plus. Fonte: cronologia versioni, scheda US.

## Prezzi dei piani

- Gratis da scaricare. Acquisti in-app (US, 28 settembre 2026): Orbit Plus $12.99, Orbit Plus Annual $19.99, Orbit Plus Lifetime $24.99 e $39.99 (due livelli di "a vita", probabilmente prezzo pieno e scontato). In Australia Lifetime da $29.99. La descrizione dice "acquisto una tantum, nessun abbonamento" ma esiste anche un piano annuale. Family Sharing su alcuni acquisti.
- Plus sblocca: abbonamenti illimitati, liste personalizzate, sync iCloud, widget, Magic Import (inserimento a testo esplicitamente Plus), "funzioni prioritarie".
- Analytics Mixpanel e Crashlytics; Magic Import manda il testo, ripulito sul dispositivo dai dati personali, a un servizio AI.
- Fonti: https://learn.tryorbit.com/facts/orbit-pricing-reviews-and-product-facts/, https://apps.apple.com/us/app/subscription-manager-orbit/id6692620188, https://flooben.com/privacypolicy

## Schermate e disposizione

Fonti: screenshot 01-06, cronologia versioni.

1. **Home** (screenshot 02): pulsante + tondo in alto a destra; grande illustrazione animata di un pianeta con gli abbonamenti come lune in orbita (toccando il "sole" le lune diventano loghi). Sotto, a sinistra il numero di abbonamenti con selettore di lista ("Tutto"), a destra il totale annuale. Poi sezione "Prove gratuite" con il suo totale, sezione "Attivo" con ordinamento ("Prossimo" e frecce). Ogni riga: logo tondo del servizio, nome, data relativa ("Domani") e data assoluta, prezzo, chevron. Sezioni comprimibili, raggruppamento per ciclo, menu filtro per lista, categoria, ciclo, metodo di pagamento; le preferenze restano.
2. **Dettaglio abbonamento** (screenshot 04): foglio con maniglia, pulsante "Modifica" in alto a destra, logo grande, nome, prezzo grande in grigio. Righe chiave/valore: Fatturazione (Mensile), Prova gratuita (Domani), Prossimo pagamento, Categoria. Sotto, scheda "Cronologia prezzi" con data e prezzo; poi cronologia di fatturazione (iscritto, in pausa, annullato, rinnovato) e URL del servizio.
3. **Calendario** (screenshot 05): titolo del mese, intestazione Lun-Dom, griglia di celle quadrate arrotondate con il logo di ogni servizio nel giorno di rinnovo, oggi evidenziato. Totale del mese e importo ancora da pagare; giorni costosi messi in risalto; pressione lunga su un giorno per aggiungere un abbonamento da quella data.
4. **Magic Import / scoperta** (screenshot 03): elenco di servizi con logo e prezzo, ciascuno con un cerchio da spuntare, e in fondo il totale annuale dei selezionati. Revisione: salva, modifica o rifiuta ogni proposta.
5. **Aggiunta**: ricerca nel catalogo con loghi, o voce personalizzata; modulo con prezzo, valuta, ciclo, data, prova, promemoria, categoria, lista, metodo di pagamento, URL.
6. **Impostazioni**: valuta principale, modifica di liste, categorie e metodi di pagamento, esporta abbonamenti (CSV), guida Subscription Finder, bacheca feedback e roadmap, Orbit Plus.
7. **Notifica** (screenshot 04): titolo "prova gratuita in scadenza", corpo con servizio, "si rinnova domani" e importo che verrà addebitato.
8. **Widget**: piccolo con i pagamenti rimanenti del mese e i prossimi 3 abbonamenti; altri formati con l'elenco in arrivo; scelta di tutte le liste o di una. Aggiornamento giornaliero.

## Feature passo per passo

### Aggiunta abbonamento
1. Tocca + (o pressione lunga su un giorno del calendario).
2. Cerca il servizio nel catalogo o scegli "personalizzato".
3. Inserisci prezzo, valuta, ciclo, data di inizio o del prossimo pagamento; facoltativi prova gratuita con data di fine, promemoria, categoria, lista, metodo di pagamento, URL.
4. Salva: totale e calendario si aggiornano, il promemoria viene programmato.
Spostare una data di pagamento futura riallinea data d'inizio e cronologia (correzioni della 1.3). Fonti: cronologia versioni, https://learn.tryorbit.com/facts/what-is-orbit/

### Catalogo servizi e loghi
- Loghi dei marchi per i servizi noti; ricerca loghi online ("fixed logo search"), l'AI di Magic Import "trova i loghi". Servizi poco noti (Google Workspace, Fastmail, frame.io) mostrano un'emoji al posto del logo. In roadmap: importare icone dall'App Store. Fonti: privacy, https://justuseapp.com/en/app/6692620188/orbit-subscription-tracker/reviews, https://orbit.userjot.com
- Il sito pubblica un "Price Index" dei prezzi tipici per servizio (Netflix, Spotify, Disney+). Fonte: https://tryorbit.com

### Cicli di fatturazione
- Giornaliero (aggiunto in una versione), settimanale, mensile, annuale; gruppi "per ciclo" in home. Pagamenti una tantum, piani a rate con durata fissa, abbonamenti completati. Pausa senza annullare. In roadmap: "date di fatturazione flessibili". Fonti: cronologia versioni, https://tryorbit.com

### Valute
- 64 valute e 38 lingue (sito; la scheda dice 30+ lingue e valute). Si può tenere un abbonamento in una valuta e vedere i totali in un'altra, o entrambe; conversione "live" (rete). Correzioni su somme miste in calendario e ordinamento per prezzo con valute miste. Fonti: https://tryorbit.com, cronologia versioni.

### Promemoria prima del rinnovo
- Notifica locale prima del rinnovo e della fine prova, con importo. Annullati e in pausa non notificano più (bug corretto due volte). In roadmap "notifiche multiple personalizzate". Una recensione IT dice che le notifiche non arrivano. Fonti: https://learn.tryorbit.com/features/subscription-reminders/, cronologia versioni, `reviews.json`, https://orbit.userjot.com

### Statistiche, totale mensile e annuale
- Home: numero di abbonamenti e totale annuale (pagamenti rimanenti del mese aggiunti in una versione). Calendario: totale del mese e in arrivo. "Approfondimenti di spesa migliori" sono in arrivo, oggi non ci sono grafici. In roadmap "totale in arrivo per un intervallo di date". Fonti: screenshot 02 e 05, https://tryorbit.com, roadmap.

### Categorie
- Predefinite (anche bollette: acqua, luce, gas, internet, affitto, mutuo, assicurazione) e personalizzabili in Impostazioni; filtro per categoria. Fonte: cronologia versioni.

### Liste
- Personale di default; liste personalizzate (Famiglia, Lavoro) sono Plus. Organizzazione, non collaborazione. Fonte: https://learn.tryorbit.com/features/custom-lists-for-subscriptions/

### Prove gratuite
- Interruttore "prova gratuita" con data di fine; sezione dedicata in home con il suo totale; notifica il giorno prima con l'importo che verrà addebitato. Fonti: screenshot 02 e 04, https://learn.tryorbit.com/guides/how-to-track-free-trials-on-iphone/

### Condivisione
- Nessuna condivisione oggi. "Liste condivise con amici/famiglia" e "Segna come pagato" in lavorazione; app Mac e iPad pianificate; collegamento a Google/Apple Calendar pianificato; ricerca abbonamenti pianificata. Export CSV da Impostazioni. Fonti: https://orbit.userjot.com, privacy.

### Widget
- Vedi Schermate, punto 8. Fonte: https://learn.tryorbit.com/features/widgets-for-subscription-renewals/, cronologia versioni.

### Apple Watch
- Non supportato (nessuna app Watch nella scheda). Fonte: scheda US.

### Shortcuts, Siri e Spotlight
- Su iOS 27 (versione 1.3): chiedere prezzi, date di rinnovo, pagamenti in arrivo e numero di abbonamenti della lista Personale; aprire un abbonamento, il calendario, Aggiungi o Magic Import; trovare gli abbonamenti in Spotlight. Fonte: `meta.json` (release notes).

### iCloud
- Sync iCloud solo con Plus. Fonte: https://learn.tryorbit.com/features/icloud-sync-for-subscription-tracking/

### Magic Import
1. Scegli screenshot, foto, file (PDF, CSV, estratto conto) o scrivi/incolla testo (Plus).
2. Sul dispositivo vengono tolti nomi, email, numeri di conto e carta.
3. Il testo ripulito va a un servizio AI che riconosce servizi e loghi.
4. Rivedi le proposte: salva, modifica o rifiuta; nulla viene aggiunto da solo.
Errori con file grandi: consiglia periodi più brevi o CSV. Una recensione US: l'import non funziona affatto dopo aver pagato $25. Fonti: https://learn.tryorbit.com/features/magic-import/, privacy, `reviews.json`.

## Recensioni (sintesi)

- Livello gratuito di 3-5 abbonamenti giudicato inutile (2 su 6).
- Funzioni di import pagate che non funzionano (1), notifiche che non arrivano (1), sviluppatore che non risponde (1), nessun aiuto per annullare ciò che l'app ha trovato (1), troppo lavoro manuale (1).
- Contesto Bobby: notifiche che non arrivano (il lamento più frequente, IT e US), impossibile digitare i decimali del prezzo, sync iCloud rotta e dati persi, 5 abbonamenti gratis poi pagamento, mancano widget, dark mode a pagamento, manca "segna come pagato", ordinamento per costo mensile normalizzato. Fonte: feed RSS pubblico delle recensioni di Bobby (id 1059152023), IT e US.
