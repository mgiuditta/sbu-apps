# Parità con l'Originale

Mappa del 13 ottobre 2026: ogni funzione dell'Originale (dati pubblici dello Store in `research/<id>/`) confrontata con il codice della App Sbu. Stati: Fatto, Parziale, Manca, Esclusa (regole di prodotto o design system).

| App Sbu | Originale | Copertura | Pronta per l'invio? |
|---|---|---|---|
| Habits | Streaks | 22 di 27 | Sì, dopo #439, #95, #96 |
| Moon | My Moon Phase Pro | 8 di 24 | Manca il cuore "Alerts": notifiche di fase, sorgere e tramonto |
| Speed | Speedometer 55 Pro | 8 di 44 (il resto è fuori dalla cosa sola) | Quasi: nodi, durata, orizzontale |
| Noise | White Noise | 7 di 21 | No: 5 suoni soli, due pulsanti disabilitati |
| Level | Clinometer | 1 di 20 | No: il clinometro ripiega a ±45°, 60° si legge 30° |

### Sbu Habits ← Streaks
Copertura: 22 di 27 funzioni fatte, 3 parziali, 1 mancante, 2 escluse (temi colore e temi stagionali). La griglia, il segno, la serie e le altre funzioni centrali sono tutte fatte.

| Funzione dell'Originale | Stato | Dove / Issue |
|---|---|---|
| Home 2×3 a pagine con punti, fino a 24 abitudini, "Aggiungi" nel primo posto libero | Fatto | `HabitGrid`, `HabitPage`, `PageDots`, `HomeBar`, `HomePages`, `AddHabitCell` · #110, #126 |
| Anello di avanzamento con la serie nel cerchio, simbolo per Salute e per "da evitare" | Fatto | `HabitRing`, `HabitRingFace`, `SlotCaption`, `HabitKindMark` |
| Tenere premuto per segnare, con vibrazione; annullare il segno | Fatto | `HabitCell` (`onLongPressGesture`, `sensoryFeedback`), `HabitsModel.undoLast` |
| Serie attuale e migliore; i giorni non previsti non rompono la serie | Fatto | `Streak`, `DayState`, `HabitStatistics` |
| Più volte al giorno (anello a segmenti) | Fatto | `HabitSettings.timesPerDay`, `HabitRing` |
| Abitudini da evitare | Fatto | `HabitKind.toAvoid`; in più un limite al giorno (`HabitGoal.limit`) |
| Abitudini a tempo: countdown, Pausa/Riprendi/Annulla, segnata da sola alla fine | Fatto | `HabitTimer`, `TimerView` · #113, #118 |
| Live Activity del timer (blocco e Dynamic Island) | Fatto | `TimerLiveActivity` · #398 |
| Pianificazione: ogni giorno, giorni scelti, N volte a settimana o al mese, un giorno solo | Fatto | `Schedule`, `HabitDaysScreen` · #119 |
| Centinaia di icone con categorie e ricerca | Fatto | 375 SF Symbols in 14 categorie, `SymbolSearch` · #122 |
| Titolo automatico dal modello, contatore di caratteri | Fatto | `HabitDraft`, `HabitTitleSection` |
| Aggiungi: Generale, Salute, Alimentazione, A tempo, Da evitare; modelli e ricerca | Fatto | 45 modelli, `TemplateSearch`, `AddHabitSheet` · #111, #121 |
| Configurazione: anteprima, icona, Tipo / Obiettivo / Giorni / Notifiche | Fatto | `HabitFormScreen` e schermate collegate · #114, #401 |
| Notifiche: nessuna, automatiche, orari personalizzati | Fatto | `ReminderMode`, `AutomaticReminder`, `ReminderPlan` · #125 |
| Notifiche: sensibili al tempo, suono, avviso a completamento | Parziale: l'avviso di completamento c'è solo per i segni da Salute | `NotificationStyle`, `ReminderSound` |
| Statistiche: tutte le abitudini, poi una pagina per abitudine | Fatto | `StatisticsView`, `StatisticsPage` · #112, #120 |
| Statistiche: serie migliore, completamento %, totali, periodo | Fatto | `HabitStatistics`, `PeriodMenu` |
| Grafici: linea, barre per giorno, curva per ora | Fatto | `CompletionLineChart`, `WeekdayChart`, `HourChart` · #397 |
| Condividi le statistiche come immagine | Fatto | `StatisticsShareRenderer` · #124 |
| Nota del giorno | Parziale: l'editor non ha frecce né calendario per cambiare giorno | `DailyNoteEditor`, `HistoryGrid` · #123 |
| Abitudini da Salute che si segnano da sole, anche in background | Parziale: 13 misure; mancano minuti nelle zone cardiache e farmaci | `HealthMeasure`, `HealthKitReader` · #128 |
| Widget (griglia, singolo, serie, linea, barre, calendario), interattivi | Fatto | `SbuHabitsWidget/` · #127 |
| App per Apple Watch | Fatto | `SbuHabitsWatch/` · #129, #429 |
| Impostazioni: inizio giornata, Salute, esporta/importa JSON, riordino | Fatto | `StartOfDaySection`, `HealthSection`, `DataSection`, `HabitOrderSection` |
| Archiviare un'abitudine senza perdere lo storico | Manca: si può solo eliminare | nessuna issue |
| Sincronizzazione iCloud | Fatto, spenta di default (ADR-0008) | `Sync/` · #115, #399 |
| Abitudini condivise | Fatto, in sola lettura (ADR-0009) | `Sharing/` · #116, #400 |
| Temi colore (sfondo sfumato, accento) | Esclusa: design system | #117 |
| Temi stagionali | Esclusa: design system, decorativi | #117 |

Solo in Sbu: Serie piena, "Salta oggi" senza perdere la serie, limite al giorno per le abitudini da evitare, App Intents, storico a griglia, promemoria solo nei giorni previsti e solo se non l'hai ancora fatta.

1.0 minima: nessuna funzione centrale manca.
- #439: difetti a testo grande (7 test UI su 43 falliti sull'iPhone fisico) e punto B (play più piccolo sugli anelli piccoli, area di tocco 44 pt), poi test insieme.
- #95, #96: privacy e scheda per Salute, poi la build per la review.
- Scheda IT: la promessa "Dati solo sul dispositivo" convive con sync e condivisione iCloud; nell'elenco delle funzioni va detto che iCloud è spento finché non lo attivi.

Dopo (1.1+): archiviare un'abitudine; avviso di completamento per ogni abitudine; frecce e calendario nella nota; zone cardiache e farmaci da Salute.

### Sbu Moon ← My Moon Phase Pro
Copertura: 8 di 24 funzioni fatte, 2 parziali, 1 esclusa, 13 mancanti.

| Funzione dell'Originale | Stato | Dove / Issue |
|---|---|---|
| Nome della fase con percentuale illuminata ("Luna gibbosa calante (74%)") | Fatto | `MainView` → `SbuToolField` "Illuminazione" con il nome della fase come contesto (`MoonReading.illumination`, `MoonReading.phase`). Le otto fasi sono in `MoonPhase.swift` |
| Immagine della luna nella fase del giorno (foto su cielo stellato) | Fatto | `MoonDiscView` + `MoonLitShape`: è un disegno con terminatore e lato corretti, non una foto, per scelta di stile (design system) |
| Barra delle date a scorrimento (giorni della settimana, giorno selezionato sottolineato) | Parziale | Si scorre per il giorno prima o dopo (`MainView.swipe`) e ci sono le azioni VoiceOver. Manca la striscia visibile dei giorni vicini: si vede solo il giorno mostrato (`DatePill`) |
| Calendario per scegliere qualsiasi data (Annulla/Fine) | Fatto | `DatePickerSheet`: grafico, dal 1900 al 2100, con il pulsante "Oggi" (`MoonModel.dateRange`) |
| Tornare a oggi | Fatto | Pill "Oggi" in `MainView` e nel foglio. Con oggi selezionato si aggiorna ogni minuto (`TimelineView`) |
| Posizione attuale (pulsante mirino, GPS) | Manca | Nessun CoreLocation nell'app. Nessuna regola la vieta: è il PRD #99 che l'ha tolta |
| Posizione scelta a mano | Manca | Va fatta senza geocoding di rete: con un elenco di città incluso nell'app o con le coordinate |
| Previsione nuvolosità ("Cielo molto nuvoloso… si schiarirà alle 04:00") | Esclusa | Serve un servizio meteo, quindi la rete (regola: niente chiamate di rete) |
| Orari di sorgere e tramonto della luna | Manca | Si calcolano sull'iPhone (Meeus) ma servono latitudine e longitudine. È fuori perimetro nel PRD #99 e nel commento |
| Orari di alba e tramonto del sole | Manca | Come sopra |
| Prossime fasi principali con data e ora (ultimo quarto, nuova, primo quarto, piena) | Fatto | `NextPhasesView`: le quattro fasi successive, con giorno e ora nel fuso dell'iPhone (`MoonReading.upcomingPhases`) |
| Grafico "Ciclo successivo" (illuminazione 0–100% sulle quattro fasi) | Parziale | Le stesse date ci sono come righe di testo. Manca il grafico |
| Distanza Terra–Luna | Fatto | `MoonDetailsView` "Distanza dalla Terra" (`MoonDistance`, Meeus 47.A), in km |
| Età della luna | Fatto | `MoonDetailsView` "Età della luna" in giorni e ore (`MoonDetailFormat.age`) |
| Altitudine della luna | Manca | Serve la posizione |
| Azimut della luna (gradi e punto cardinale) | Manca | Serve la posizione |
| Segno zodiacale della luna | Manca | Si calcola sull'iPhone dalla longitudine eclittica (già in `LunarArguments`) senza posizione. Una recensione lo dà sbagliato di 1–2 segni nell'Originale |
| Ora d'oro (mattina e sera) | Manca | Serve la posizione. Una recensione dice che gli orari dell'Originale sono sbagliati |
| Ora blu (mattina e sera) | Manca | Serve la posizione |
| Notifiche quando la luna raggiunge la fase che scegli | Manca | Sarebbero notifiche locali, quindi ammesse. Il PRD #99 le esclude. Recensione: "Notifications don't work at all" |
| Avvisi di sorgere e tramonto della luna (citati in una recensione) | Manca | Servono posizione e notifiche locali |
| Condividi (pulsante in alto) | Manca | Nessun `ShareLink` in `Apps/SbuMoon` |
| Impostazioni (ingranaggio) | Fatto | Foglio di `SbuAppShell` con `CalculationSection` (fuso orario, metodo di calcolo) |
| App per Apple Watch e complicazioni (citate in una recensione) | Manca | Non c'è un target watchOS né un widget in `project.yml` |

Solo in Sbu: tema chiaro e scuro, VoiceOver completo (azioni giorno precedente e successivo) e Dynamic Type, l'ora esatta del calcolo invece di "a mezzanotte", nessun permesso richiesto, gratis (l'Originale costa 3,99 €).

1.0 minima:
- Notifiche locali per luna piena e luna nuova, a scelta per fase. Sono la promessa "Alerts" dell'Originale e il suo punto debole nelle recensioni. Bastano UNUserNotificationCenter e le date di `MoonAstronomy.events`, senza posizione.
- Sorgere e tramonto della luna per oggi, calcolati sull'iPhone. Rispondono a "posso vederla stasera?". La posizione va chiesta solo quando serve, con una città scelta a mano come alternativa senza GPS.

Dopo (1.1+):
- Altitudine e azimut della luna (si appoggia alla posizione della 1.0).
- Alba e tramonto del sole, ora d'oro e ora blu.
- Segno zodiacale della luna.
- Grafico dell'illuminazione sul ciclo successivo.
- Striscia visibile dei giorni vicini sopra la luna.
- Condividi.
- Widget (schermata Home e blocco) e app con complicazioni per Apple Watch.
- Avvisi di sorgere e tramonto.

### Sbu Speed ← Speedometer 55 Pro
Copertura: 8 fatte e 3 parziali su 44; 5 escluse, 28 mancanti, quasi tutte fuori perimetro per scelta (#98). L'Originale è un coltellino svizzero: Sbu ne prende la cosa sola, il tachimetro.

| Funzione dell'Originale | Stato | Dove / Issue |
|---|---|---|
| Velocità attuale grande | Fatto (intera) | `MainView`, `SpeedFigureStyle` |
| Unità mph, km/h, nodi | Parziale: mancano i nodi | `SpeedUnit` |
| Unità di default secondo la regione | Fatto | `SpeedUnit.preferred(for:)` |
| Velocità massima, media, distanza | Fatto | `Trip`, `TripSummary` |
| Azzera contatori con conferma | Fatto | `MainView` |
| Viaggio salvato tra un'apertura e l'altra | Fatto | `SpeedModel` |
| Durata del viaggio | Manca: `movingTime` è calcolato ma non mostrato | `Trip.movingTime` |
| Pausa dei contatori | Manca | |
| Più viaggi, storico | Manca | #98 fuori perimetro |
| Forza del segnale GPS | Parziale: solo "Cerco il segnale GPS" | `SpeedStatus` |
| Altitudine, rotta, coordinate, alba e tramonto | Manca | |
| Limite con preset da un tocco e valori personalizzati | Parziale: preset fissi nelle Impostazioni | `SpeedLimit`, `SpeedLimitSection` |
| Avviso sonoro oltre il limite | Fatto | `SpeedLimitAlarm` |
| Cifre verdi/rosse | Esclusa: design system; Sbu usa la riga "Oltre il limite" in `danger` con simbolo | |
| Limiti ricordati per luogo | Manca | |
| Schermo sempre acceso | Fatto | `isIdleTimerDisabled` |
| HUD a specchio | Manca | |
| Orizzontale con campi grandi | Manca: solo verticale | `project.yml` |
| Campi e colori personalizzabili | Esclusa: design system | |
| Registrazione in background, tracce, grafici, mappa, GPX/KML | Manca | #98 fuori perimetro |
| Mappe Google e offline dal server dello sviluppatore | Esclusa: rete | |
| Waypoint, autovelox (import locale), costi carburante, chilometraggio, dash cam, video overlay, rally, G-Force, tassametro, nautica, parapendio, navigazione, voice coach, lettore musicale | Manca, fuori dalla cosa sola | #98 fuori perimetro |
| Comandi Siri | Manca | |
| iPad | Manca | `project.yml` |
| Upgrade a pagamento | Esclusa | |

Solo in Sbu: quadrante con fondo scala adattivo, limite che segue il cambio di unità, stati di accesso spiegati con "Apri Impostazioni", filtri contro i salti del GPS, VoiceOver e Dynamic Type.

1.0 minima:
- Nodi come terza unità, con miglia nautiche.
- Durata del viaggio come quarto valore (il dato c'è già).
- Schermata orizzontale (in auto il telefono sta sul supporto).

Dopo (1.1+): limite da un tocco e personalizzato; Siri per il limite; HUD a specchio; precisione GPS; altitudine e rotta; pausa; viaggio in background con Live Activity; iPad.

### Sbu Noise ← White Noise
Copertura: 7 di 21 funzioni fatte, 3 parziali, 11 mancanti (più 4 escluse).

| Funzione dell'Originale | Stato | Dove / Issue |
|---|---|---|
| Catalogo di suoni in loop (40+: pioggia, acqua, natura, casa, viaggio, rumori colorati) | Parziale: solo i 5 rumori generati; mancano registrazioni CC0 e categorie | `Sound.generated`, `NoiseGenerator` · #414, #423 |
| Player a schermo intero, swipe tra i suoni, ultimo suono ripreso | Fatto | `MainView`, `PlayerPage`, `PlayerModel` |
| Controlli: cuore, precedente, play/pausa, successivo, info, volume, AirPlay | Fatto | `PlayerControls`, `SystemVolumeSlider`, `RoutePicker` |
| Scheda info del suono | Fatto | `SoundInfoSheet` |
| Audio in background e a schermo bloccato | Fatto | `UIBackgroundModes: audio` |
| Controlli remoti, cuffie, interruzioni | Fatto | `SystemAudio`, `SystemEvent` |
| Preferiti con cuore e vista Preferiti | Parziale: solo in memoria (si perdono a ogni avvio), nessuna lista | `PlayerModel.favorites` · #415 |
| Menu con le categorie (Suoni, Mix, Preferiti, Registrazioni, Playlist) | Parziale: solo Suoni e Mix | `PlayerCategory` · #414, #415, #419, #420 |
| Gestisci: catalogo, ricerca, riordino, eliminazione, filtro | Manca: il pulsante c'è ma è disabilitato | `MainView` · #414 |
| Timer di spegnimento con dissolvenza, ripetizione per giorni | Fatto | `Timers/` |
| Timer che avviano suono, mix o playlist | Manca | `TimerEditor` · #425 |
| Sveglia con dissolvenza in entrata, suoni, snooze | Manca | #417, #424 |
| Mix Pad: gettoni attorno all'ascoltatore, volume, tono, varianza, salvataggio | Fatto (fino a 5 suoni) | `Mix/` |
| Registrare un suono dal microfono e farne un loop | Manca | #419 |
| Playlist: durata per voce, shuffle, riordino, loop | Manca | #420 |
| Orologio da comodino | Manca: il pulsante "Dormi" c'è ma è disabilitato | `MainView` · #421 |
| Generatore: rumore colorato personalizzato, binaurali, toni | Manca | nessuna issue |
| Musica della Libreria come sveglia o nel mix | Manca | nessuna issue |
| Impostazioni avanzate: bilanciamento, tono globale, mix con altre app | Manca | nessuna issue |
| Condividere ed esportare mix e registrazioni | Manca | nessuna issue |
| Orientamento orizzontale | Manca: solo verticale | `project.yml` |
| Market di suoni online | Esclusa: rete e account | #422 |
| App Apple TV e Watch | Esclusa: fuori dalla cosa sola | #422 |
| Pubblicità e richieste di valutazione | Esclusa | #422 |
| Versione completa a pagamento | Esclusa: niente acquisti in-app | CLAUDE.md |

Solo in Sbu: Mix Pad in 3D in cuffia (HRTF), Comandi rapidi e Siri, widget con play/pausa, controllo nel Centro di Controllo, varianza per ogni suono del mix.

1.0 minima:
- Catalogo vero: registrazioni CC0 in categorie e Gestisci funzionante (#414, #423).
- Preferiti salvati, con la categoria Preferiti (#415).
- Sveglia con dissolvenza e snooze (#417, #424).
- Orologio dietro "Dormi" (#421), oppure togliere il pulsante: Apple rifiuta i pulsanti disabilitati che non portano a niente.

Dopo (1.1+): registrare un suono (#419); playlist (#420); timer che avviano (#425); generatore gratis; impostazioni avanzate; condivisione; musica della Libreria; orizzontale. Le ultime cinque senza issue.

### Sbu Level ← Clinometer
Copertura: 1 di 20 funzioni ammesse fatta, 8 parziali, 11 mancanti; 4 escluse dalle regole (24 in totale).

| Funzione dell'Originale | Stato | Dove / Issue |
|---|---|---|
| Clinometro sul bordo: quadrante 0–90° con ago, spicchio tra 0° e l'angolo, scala interna in %, gradi interi grandi e decimi piccoli | Parziale: c'è solo la cifra al decimo e una barra che ruota. Manca il quadrante con scala, ago, spicchio e scala %. Soprattutto, l'angolo viene ripiegato in ±45° attorno all'angolo retto più vicino (`wrapped`), quindi 60° si legge 30° | `Level/LevelReading.swift` (`edgeDeviation`, `wrapped`), `Views/LevelIndicator.swift`; #132 (inventario in #131, chiuso) |
| Riconoscimento automatico dei 4 bordi | Parziale: l'angolo arriva da `atan2(x, -y)` su qualunque bordo, ma l'app non sa quale lato è appoggiato (nessuna identità del lato, un solo offset `edge`) | `LevelReading.edgeDeviation`, `Calibration.edge`; #104 |
| Livella a bolla in piano: sfera, due letture per asse X/Y grandi, inclinazione combinata con frecce di direzione | Parziale: bolla e angolo combinato ci sono. Mancano le letture per asse e le frecce | `LevelIndicator`/`BubbleView`, `LevelReading` (`flat`); #132 |
| Passaggio automatico tra clinometro e bolla con dissolvenza e isteresi | Parziale: il passaggio avviene a \|z\| ≥ √0,5 (45°) con un cambio di opacità. Non c'è isteresi, quindi vicino alla soglia la vista può sfarfallare | `LevelReading.mode(for:)`, `LevelIndicator` |
| Mirino con fotocamera (anteprima live, croce e orizzonte, angolo di elevazione) | Manca | #135 |
| 5 unità: gradi interi, gradi al decimo, %, x:12, 1V:H | Parziale: solo gradi al decimo, fissi | `MainView` (`.fractionLength(1)`, "°"); #100 |
| Calibrazione in due passi (giro di 180°) per ognuno dei 4 lati e per la bolla, con schermata guidata | Parziale: un solo passo ("Calibra" azzera la posizione attuale), quindi serve una superficie già in bolla. Un offset unico per i bordi più uno per il piano, nessuna schermata guidata | `Calibration.levelling`, `LevelModel.calibrate`, pillola "Calibra" in `MainView`; #104 |
| Azzera calibrazione | Fatto: in Impostazioni, con conferma e stato Calibrata/Non calibrata. Da rifare per lato | `Views/CalibrationSection.swift`; #105 |
| Angolo relativo (azzera qui, in tutte le modalità) | Manca | #102 |
| Blocco della lettura (icona lucchetto) | Manca | #101 |
| Blocco a lettura stabile (attesa di 2 s, tolleranza da ±0,1° a ±3°) | Manca | #136 |
| Bip alla misura | Manca. Sbu ha solo una vibrazione quando arriva in bolla, che è un'altra funzione | #137 |
| Lettura vocale dell'angolo | Manca | #138 |
| Tasto volume per bloccare | Manca | #139 |
| Rotazione del quadrante (scegli quale lato legge 0° e quale 90°) | Manca | #140 |
| Metodo di calcolo veloce o preciso | Parziale: c'è solo il calcolo preciso (atan2/asin sulla gravità completa), senza scelta. Probabilmente basta così | #141 |
| Schemi colore S/C (giorno, notte bianco su nero, notte rossa, diversi per bolla e clinometro) | Parziale: segue solo chiaro/scuro di sistema. La notte rossa e i preset per modalità vanno contro il design system (un solo accento, mai colori inventati) | #134 (proposta: aspetto Sistema/Chiaro/Scuro in `SbuAppShell`) |
| Tema cornice e colore cornice | Esclusa: design system (nessun colore inventato, nessun bordo colorato) | #134 |
| Schermo intero anti-tocco (tocco al centro) | Manca | #142 |
| Schermo sempre acceso | Manca (`isIdleTimerDisabled` non c'è da nessuna parte) | #103 |
| Pagina Info (modalità, come calibrare, significato delle unità, avviso sulla precisione) | Manca: le Impostazioni di `SbuAppShell` hanno solo Versione, Privacy e Licenze. Niente tab bar (ADR-0001) | #143 |
| Modalità a due dispositivi (peer) | Esclusa: rete. ADR-0007 non copre il caso, perché la misura si fa con un iPhone solo | #133 (proposta opzione 3: blocco, bip e voce al suo posto) |
| Acquisto in-app "Support dev & extra features" | Esclusa: niente acquisti in-app | #130 Out of scope |
| Link di supporto e feedback allo sviluppatore | Esclusa come da #130 (Sbu ha solo il link Privacy a sbu.dev in Safari) | #130 |

Fonti: reviews.json non esiste in `research/286215117`, quindi non ci sono recensioni da usare. Le funzioni vengono da meta.json, spec.json e dai 5 screenshot.

Solo in Sbu: vibrazione quando arriva esattamente in bolla (`sensoryFeedback`), stato "In bolla / In piano / Sul bordo", messaggio "Sensore di movimento non disponibile", VoiceOver, testo dinamico, tema scuro di sistema, gratis e senza acquisti in-app.

1.0 minima:
- Clinometro su 0–90° senza ripiegamento a ±45°, con il quadrante e la scala della schermata strumento (#132)
- Blocco della lettura (#101)
- Schermo sempre acceso durante la misura (#103)
- Calibrazione in due passi per lato, così funziona anche su una superficie non in bolla (#104, con #105)

Dopo (1.1+):
- Unità %, x:12, 1V:H (#100)
- Angolo relativo (#102)
- Letture X/Y per asse e frecce nella bolla, isteresi tra le modalità (#132)
- Blocco a lettura stabile (#136)
- Bip alla misura (#137)
- Lettura vocale (#138)
- Mirino con fotocamera (#135)
- Rotazione del quadrante (#140)
- Schermo intero anti-tocco (#142)
- Pagina Info (#143)
- Aspetto chiaro/scuro forzato nell'app (#134)
- Tasto volume (#139)
- Metodo di calcolo (#141, da chiudere probabilmente come non necessario)
