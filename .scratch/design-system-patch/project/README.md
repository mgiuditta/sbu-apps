sbu.dev è una collezione di app iOS completamente gratuite che rifanno, una per una, le utility a pagamento in cima all'App Store. Ogni app fa una cosa sola, non chiede un account, non ha pubblicità, non manda dati fuori dal telefono. Questo sistema serve a far sembrare tutte le app sorelle: stessa grammatica di icona, stessi colori di base, stessi componenti SwiftUI (`SbuKit`), un accento diverso per app.

## Principi

1. **Una cosa sola.** Ogni app ha una cifra o un oggetto al centro (il totale mensile, i giorni di streak, i gradi di inclinazione). Quella cifra è in `stat`, una volta per schermata, in `ink`. Tutto il resto è secondario e sta in `ink-muted`.
2. **Nativa, non travestita.** Usa i controlli di sistema SwiftUI (List `.insetGrouped`, Form, NavigationStack, sheet). I token qui mappano i colori e le dimensioni di sistema, non li sostituiscono: `surface` = `systemGroupedBackground`, `surface-raised` = `secondarySystemGroupedBackground`, `line` = `separator`.
3. **Il colore è l'app.** Dentro un'app l'unico colore vivo è il suo `accent-*` (tint di SwiftUI). `brand` compare solo nel footer "parte di sbu.dev" e nello splash. Mai due accenti nella stessa schermata.
4. **Niente che sembri un paywall.** Nessun gradiente, nessuna card con bordo colorato, nessuna stella, nessun "PRO". Il badge `FreeBadge` dice il contrario di un paywall e sta in fondo a ogni Impostazioni.
5. **Lo strumento è un campo di colore.** La schermata in cui l'app fa la sua cosa (livella, tuner, timer, rumore) è un campo pieno `field-*`, scuro, con la cifra enorme in `on-field`. Tutto il resto (liste, impostazioni, storico) è su `surface`. Vedi *Direzione visiva*.

## Direzione visiva (ottobre 2026)

Riferimento scelto: **Guitar Wiz** (Apple Design Award 2026, Inclusivity), con la logica dei grafici di **Tide Guide** (ADA 2026, Visuals and Graphics). Guitar Wiz è una utility gratuita con più strumenti dentro: ogni strumento è una schermata a campo pieno di un solo colore profondo (nero per gli accordi, verde per il tuner, blu notte per le progressioni, viola per il metronomo), la cifra al centro è enorme e monospaziata (`G3 · 196.84 Hz`, `120 BPM`), i controlli sono pill chiare semitrasparenti sopra il campo, la navigazione è Liquid Glass di sistema. È esattamente la struttura di una suite di cloni: un colore per strumento, lo stesso scheletro per tutti.

Cosa prendiamo e cosa no:

- **Prendiamo** il campo pieno per strumento, la cifra-eroe, le pill sul campo, la navigazione di sistema lasciata in vetro. Da Tide Guide: il dato è il disegno (la curva della marea è la schermata), e la palette che segue il contenuto.
- **Non prendiamo** il neo-brutalismo (bordi neri 3px, ombre dure, `#F4F4F0`): su Dribbble vive quasi solo in dashboard SaaS e landing; sotto una tab bar Liquid Glass stona, e in iOS 27 il vetro non si può più disattivare. Non prendiamo nemmeno il pastello alla Structured: è una scelta di brand loro, e un rosa pieno non regge nove accenti diversi.
- **Non prendiamo** i kit "iOS 26 Liquid Glass" di Dribbble: sono vetro sopra foto, non layout di contenuto.

Regole che ne derivano:

1. **Due tipi di schermata.** *Strumento*: sfondo `field-<app>` in entrambi i temi (la schermata strumento è sempre scura, come una fotocamera), testo `on-field`, secondario `on-field-muted`, controlli `field-control`, la cifra in `stat-hero`. *Gestione* (liste, storico, impostazioni, onboarding): `surface` / `surface-raised` / `ink`, come prima. Una app ha una sola schermata strumento, ed è la sua schermata principale.
2. **Il vetro resta di Apple.** Tab bar, toolbar e bottoni di navigazione sono Liquid Glass di sistema, mai ridisegnati. Da iOS 27 l'opt-out non esiste più e l'utente ha uno slider di trasparenza: il contenuto sotto deve reggere sia il vetro quasi limpido sia quello tinto. Quindi: sfondi uniformi sotto le barre, niente pattern, niente testo a filo del bordo inferiore (`space-8` di respiro sopra il bordo inferiore e le barre di sistema), scroll edge effect lasciato di default.
3. **Card opache, zero ombre, zero bordi.** La gerarchia la fanno `surface` / `surface-raised` e `radius-lg`. Sul campo, le card sono `field-control` (bianco al 14%) con `radius-lg`.
4. **La cifra è il disegno.** Sullo strumento la cifra è `stat-hero` (64px mono) in `on-field`, l'unità in `on-field-muted`; quando esiste una curva o un grafico (decibel nel tempo, inclinazione, streak), è lui la schermata, in `accent-*` sul campo, e la cifra gli sta sopra.
5. **Un accento, tre usi.** Lo stesso `accent-<app>` fa: icona, tint di sistema sulle schermate gestione, tratto del grafico e indicatore sul campo. Mai un secondo colore vivo nella stessa app.

## Voce e testi

- Italiano e inglese, seconda persona singolare, frasi brevi. Primo esempio reale: *"Sbu fa una cosa sola: ti aiuta a tenere sotto controllo gli abbonamenti senza chiederti dati personali."*
- Nome dell'app sempre `Sbu` + sostantivo inglese al singolare o plurale naturale: Sbu Subscriptions, Sbu Scanner, Sbu Level, Sbu Noise, Sbu Scan, Sbu Habits, Sbu Cards, Sbu Block, Sbu Dark. Il sottotitolo App Store dice la cosa in italiano: *"Spese, rinnovi e promemoria"*.
- Ogni descrizione App Store ha lo stesso blocco fisso, nell'ordine: nessun abbonamento · nessun acquisto in-app · nessun account · nessuna pubblicità · nessun tracking · dati solo sul dispositivo. Poi le feature specifiche, poi la frase di chiusura "Sbu fa una cosa sola: …".
- Niente emoji nei testi dell'app né nei listing. Niente punti esclamativi.
- Le azioni sono verbi all'infinito: "Aggiungi abbonamento", "Esporta CSV", "Elimina". Il risultato è un participio: "Esportato".

## Colore

- Fondo `surface`, contenuti su `surface-raised`, input su `surface-sunken`. Testo `ink`, secondario `ink-muted`, separatori `line` a `hairline`.
- Tint dell'app = il suo `accent-*`. Testo sopra un accento pieno = `on-accent` (bianco), con l'unica eccezione di `accent-level` che vuole `ink` light.
- `brand` cambia valore in dark (si schiarisce): il testo sopra è `on-brand`, mai bianco fisso.
- Stati: `success`, `warning`, `danger` sempre accompagnati da parola o simbolo SF. Elimina e azzera sono `danger` e chiedono conferma.
- Verifica eseguita: `ink-muted` su `surface` 5.5:1 light / 7.0:1 dark; `brand` su `surface-raised` 5.2:1 light / 6.1:1 dark; `on-brand` su `brand` 5.2:1 / 6.1:1.
- Campi strumento: `field-<app>` è l'accento portato quasi al nero (stessa tinta, luminosità 8–15%), identico nei due temi. `on-field` sopra ogni campo ≥ 13.7:1, `on-field-muted` ≥ 7.0:1, l'`accent-*` dark sopra il proprio campo ≥ 5.4:1 (il peggiore è subscriptions). Sul campo il tint di sistema è il valore dark dell'accento, anche in light mode.

## Tipografia

- Dentro l'app solo SF Pro via Dynamic Type: gli stili del gruppo *iOS* sono gli `Font.TextStyle` di SwiftUI, non ridefinirli con dimensioni fisse.
- La cifra centrale usa `stat` con `.monospacedDigit()`; nelle liste gli importi sono `stat-small` allineati a destra. Sulla schermata strumento la cifra sale a `stat-hero` (64px): è l'unico posto dove compare.
- `display-hero` e `display-title` (Bricolage Grotesque) esistono solo fuori dall'app: landing sbu.dev, screenshot App Store, press kit. Sul web il fallback è SF Pro Display / system-ui.
- `caption` è l'unico stile maiuscolo, con `letterSpacing` 0.4px: header di sezione e label sopra le cifre.

## Spaziatura e raggi

- Griglia 4pt. Margine laterale di schermata `space-4`; righe di lista `space-3` verticale; tra sezioni `space-6`.
- Card e righe raggruppate `radius-lg`; input e bottoni compatti `radius-md`; badge e filtri `radius-pill`; sheet `radius-xl`.
- Nessuna ombra nell'app. `shadow-marketing` solo sotto il device frame negli screenshot.
- Sulla schermata strumento: cifra e grafico centrati, controlli in una riga di pill a `space-4` dal bordo, `space-8` di respiro sopra il bordo inferiore e le barre Liquid Glass.

## Iconografia

- Dentro l'app: SF Symbols, peso `.medium`, scala `.medium`, colorati con `accent-*` quando sono azione e `ink-muted` quando sono decorazione. Niente icone custom nell'interfaccia.
- Icona app (`assets/App Icons/`): campo pieno in `accent-*` con raggio `radius-icon`, un solo glifo in `on-accent` con tratto `icon-stroke` ed estremità arrotondate, contenuto nel riquadro `icon-glyph-box`. Nessun testo, gradiente, ombra o secondo colore. Il glifo è l'oggetto dell'app (anello che si rinnova, livella, onde, documento) o il simbolo che iOS usa già per quel concetto (luna per il dark mode, scudo per il blocco); mai una metafora creativa (lampadine, razzi).
- Per creare l'icona di una nuova app: scegliere un accento che non sia già in uso in una categoria vicina, disegnare un glifo con al massimo due tratti, esportare da `make_icons.py` (SVG 1024) e poi rasterizzare a 1024 PNG per Xcode (`AppIcon.appiconset`, singolo asset 1024).
- Marchio sbu.dev (`assets/Logos/`): la tessera `brand` con anello e punto (la "cosa sola"). Wordmark `sbu.dev` in `display-title`, minuscolo. `sbu-wordmark.svg` su fondi chiari, `sbu-wordmark-paper.svg` su fondi scuri.

## Screenshot App Store

- Sfondo `surface` del tema chiaro, titolo in `display-title` in `ink` in alto a sinistra, device frame con `shadow-marketing`, margine `space-12`.
- Il primo screenshot mostra sempre la schermata strumento (campo `field-*` con la cifra `stat-hero`); il secondo la privacy (`FreeBadge` grande); gli altri le feature. Lo sfondo dello screenshot resta `surface` chiaro: il campo scuro dentro il device frame è ciò che distingue lo screenshot dal resto della pagina App Store.
- Il colore del titolo di ogni screenshot può essere l'`accent-*` dell'app, mai `brand` e mai un gradiente.

## Componenti (SbuKit)

`AppIcon`, `Button`, `ListRow`, `FreeBadge`, `Stat`, `ToolField`. Le anteprime qui sono HTML che riproducono il rendering SwiftUI; l'implementazione reale è il package Swift `SbuKit`, con gli stessi nomi di token in `SbuTheme`. `ToolField` è il contenitore della schermata strumento: campo, cifra-eroe, riga di pill.
