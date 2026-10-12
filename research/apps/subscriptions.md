# Sbu Subscriptions 2.0: sintesi su Orbit

Originale: Subscription Manager: Orbit (id 6692620188, Flooben Ltd), gratis con acquisti in-app $12.99-$39.99. Fonti: `research/6692620188/` (`meta.json`, 6 screenshot, `reviews.json` con 6 recensioni 1-3 stelle, `spec.json`, `ux.md`), più le recensioni pubbliche di Bobby lette solo come contesto. App Sbu: Sbu Subscriptions, già in vendita (ASC 6780154928, `dev.sbu.subscriptions`, 1.0.0 del 15 giugno 2026), da rifare in Swift/SbuKit come 2.0 della stessa scheda.

**Cosa sola proposta:** "sai quanto ti costano gli abbonamenti e nessun rinnovo ti sorprende". **Cifra** candidata: il totale mensile (o annuale) nella valuta principale, chiuso dal punto fermo.

## La 1.0 di oggi e cosa serve per la 2.0

La 1.0 è un'app Expo/React Native (`~/dev/sbu.dev/apps/subscriptions`, fuori da questo repo), iOS 16.4+, font Space Grotesk, nessuna valutazione sulla scheda.

| | 1.0 (in vendita) | 2.0 (pari a Orbit, stile Sbu) |
|---|---|---|
| Struttura | tab bar Home / Calendario / Impostazioni | `SbuAppShell`, `NavigationStack`, Impostazioni in foglio (ADR-0001), calendario come schermata di gestione |
| Catalogo | 150 servizi con loghi dei marchi da `simple-icons` | catalogo locale; loghi dei marchi da decidere (grilling), ripiego su monogramma o SF Symbol |
| Cicli | settimanale, mensile, trimestrale, annuale | giornaliero, settimanale, mensile, annuale e "ogni N"; una tantum, rate a durata fissa, pausa, annullato |
| Valute | una valuta per abbonamento, ma il totale somma importi di valute diverse e li etichetta con la valuta del primo (bug); importi `REAL` | `Decimal`, valuta principale, conversione con tassi locali (grilling) |
| Promemoria | nessuno, giorno stesso, 1, 3, 7 giorni prima; fine prova | stessi più orario e giorni personalizzati; riprogrammati all'avvio; nessuno per annullati o in pausa |
| Prove gratuite | flag + data di fine | sezione dedicata con il prezzo dopo la prova |
| Totali | annuo e mensile | una sola **Cifra** per schermata; da pagare questo mese come secondario |
| Calendario dei rinnovi | sì | sì, con totale del mese e aggiunta da un giorno |
| Categorie e note | 17 categorie fisse, note, colore | categorie modificabili, liste, metodi di pagamento, URL, note; niente colore per abbonamento |
| Storico | no | cronologia prezzi e di fatturazione |
| Dati | SQLite (`expo-sqlite`, `sbu_subscriptions.db`), esporta CSV | SwiftData in App Group, esporta/importa CSV, iCloud opzionale (ADR-0008), migrazione dal file della 1.0 |
| Widget, Siri, Spotlight | no | widget pagamenti in arrivo; App Intents |
| Altro | pannello lingua, richiesta valutazione | lingua di sistema; niente richiesta di valutazione (da verificare con le regole) |

Per arrivare alla 2.0 servono: scaffold con lo stesso bundle `dev.sbu.subscriptions` (deployment target sale da 16.4 a 17: chi è su iOS 16 resta sulla 1.0), migrazione dei dati e delle notifiche programmate della 1.0, icona nuova (incisione: registratore di cassa), scheda e screenshot nuovi sullo stesso app record. La descrizione della 1.0 scrive ancora "nessun tracking invasivo" e "pubblicita" senza accento: il blocco promesse va riallineato a CLAUDE.md.

## Matrice feature

| Feature | A pagamento in Orbit? | Sbu | Framework iOS 17+ | Conflitto con le regole? |
|---|---|---|---|---|
| Aggiunta da catalogo e personalizzata | No (entro il limite) | core | SwiftData, `Form`, `.searchable` | Loghi: marchi di terzi (grilling) |
| Numero di abbonamenti | Sì: 3-5 gratis, poi Plus | core, illimitati | — | No |
| Cicli (giorno, settimana, mese, anno, ogni N) | No | core | `Calendar`, tipi puri testati | No |
| Una tantum, rate, pausa, annullato, completato | No | core (stato), nice (rate) | enum di stato | No |
| Totale mensile e annuale | No | core: la **Cifra** | `Decimal.FormatStyle.Currency`, `SbuStat` | Una sola cifra per schermata |
| Valute multiple e conversione | No (conversione live) | core | `Locale.Currency`, `FormatStyle` | Sì: tassi live = rete (grilling) |
| Promemoria prima del rinnovo e della fine prova | No | core | `UNUserNotificationCenter`, `UNCalendarNotificationTrigger` | No; limite 64 notifiche in coda |
| Prove gratuite | No | core | SwiftData | No |
| Calendario dei pagamenti | No | core | `LazyVGrid`, `Calendar` | Loghi nelle celle (grilling); niente colori inventati |
| Dettaglio con modifica | No | core | `List`, foglio | No |
| Cronologia prezzi | No | nice | SwiftData relazione | No |
| Cronologia di fatturazione, segna come pagato | No (pagato in roadmap) | nice | SwiftData | No |
| Categorie modificabili | No | core | SwiftData, SF Symbols | No |
| Liste (Personale, Famiglia, Lavoro) | Sì | nice | SwiftData | No |
| Metodi di pagamento | No | nice | etichetta di testo | Mai dati di carta |
| Ordina, filtra, raggruppa, cerca | No | core (ricerca nice) | `@AppStorage`, `.searchable` | No |
| Widget pagamenti in arrivo | Sì (prova aperta a tutti) | core | WidgetKit, App Group | No |
| Siri, Comandi Rapidi, Spotlight | No | nice | App Intents, `AppEntity`, `AppShortcutsProvider` | No |
| Esporta CSV | No | core | `fileExporter`, `ShareLink` | No |
| Importa CSV con revisione | Sì (Magic Import) | nice | `fileImporter`, parser puro | No |
| Sync iCloud | Sì | nice, opzionale | SwiftData + CloudKit privato | No (ADR-0008, spento di default) |
| Aiuto ad annullare (link al servizio, abbonamenti App Store) | No (solo guide web) | nice | campo URL, `showManageSubscriptions` di StoreKit | Link aprono Safari |
| Guida "dove cercare gli abbonamenti" | No | nice | testo locale | No |
| Magic Import da screenshot e PDF | Sì | skip nella forma Orbit | — | Sì: AI su server. Variante con Vision on-device da decidere (grilling) |
| Ricerca loghi online, icone dall'App Store | No | skip | — | Rete e marchi |
| Liste condivise con altri | In lavorazione | skip | — | CloudKit sharing tra account, fuori dalla Cosa sola |
| Pianeta animato con lune | No | skip | — | Decorativo, linea guida 4.1, design system |
| Orbit Plus, analytics Mixpanel/Crashlytics | — | skip | — | Sì |
| Collegamento banca, lettura email | (non in Orbit) | skip | — | Sì: account e server |

## Problemi principali degli utenti

1. **Livello gratuito minimo** (Orbit 2 su 6; Bobby più volte): 3-5 abbonamenti gratis, poi pagamento; "pressoché inutile".
2. **Notifiche che non arrivano** (Orbit 1; Bobby il lamento più frequente in IT e US): è lo scopo dell'app.
3. **Import pagato che non funziona** (Orbit 1, $25 spesi).
4. **Nessun aiuto per annullare** ciò che si è trovato (Orbit 1).
5. **Troppo lavoro manuale** (Orbit 1); loghi mancanti per servizi meno noti (justuseapp).
6. Contesto Bobby: **decimali del prezzo impossibili da digitare**, sync iCloud rotta e dati persi, dark mode a pagamento, manca "segna come pagato", manca ordinamento per costo mensile normalizzato, mancano i widget.

## Cosa Sbu fa meglio

- Abbonamenti illimitati, widget, liste, export, iCloud: tutto gratis, nessun limite che arriva al quarto abbonamento.
- Promemoria affidabili: riprogrammati a ogni modifica e all'avvio, con una riga in Impostazioni che dice se le notifiche sono spente e un test.
- Campo prezzo nativo con tastiera decimale e `Decimal`, nessun cursore che salta; totali corretti con valute miste (oggi la 1.0 sbaglia).
- Nessun analytics, nessun testo mandato a un servizio AI: "dati solo sul dispositivo" è vero anche nell'import.
- Link diretto alla pagina per annullare e al foglio di sistema degli abbonamenti App Store.
- Ordinamento per costo mensile normalizzato e "da pagare questo mese".
