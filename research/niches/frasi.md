# Nicchia: Frasi (citazioni quotidiane)

Ricerca del 15/10/2026, solo dati pubblici: lookup API IT/US, pagine App Store IT/US (sezione acquisti in-app), RSS recensioni IT e US (3 pagine ciascuna, 205 recensioni lette, 101 da 1-3 stelle). Nessun download o estrazione dall'app.

## 1. Leader IT e USA

Il leader è lo stesso nei due paesi: **Motivation - Giornaliere / Motivation - Daily quotes**, Monkey Taps, id **876080126** (sito motivation.app). Lo stesso sviluppatore ha anche **I am - Affermazioni quotidiane** (id 874656917, 735.347 valutazioni US), che nella coda era in posizione 14 sempre nella nicchia Frasi: per ADR-0004 è la stessa nicchia, si fa una sola app.

| | IT | US |
|---|---|---|
| Prezzo | gratis (con abbonamento) | gratis (con abbonamento) |
| Valutazione | 4,70 su 16.520 | 4,82 su 1.075.060 |
| Versione | 7.4.0, iOS 18+, 251 MB, 12+ | uguale |
| Categoria | Salute e fitness, Stile di vita | uguale |

Altri nella ricerca US "motivation daily quotes": Daily Quote - Positive quotes (586028606, 66k), Motivational Quotes Daily+ (1440414093, 38k), Daily Bible Verse & Motivation (1455390863, 11k). Nessuno si avvicina: l'equivalente top US è lo stesso Motivation.

Acquisti in-app dichiarati sulla pagina (più livelli e prezzi di prova A/B):
- IT: Motivation Premium 3,99 / 11,99 €; Premium (1 anno) 19,99 €; Premium Motivation 5,49 / 9,99 / 19,99 / 59,99 € (59,99 è presumibilmente il "a vita").
- US: $3.99, $4.99, $9.99, $11.99, $14.99, $19.99, $23.99, $35.99, $39.99, $47.99.
- Dalle recensioni: prova di 3 giorni che passa all'annuale (~20 €/anno IT, $35-50/anno US), paywall a fine onboarding senza "Salta".

## 2. Cosa sta dietro il paywall

Gratis (oggi molto poco, molti dicono "non c'è un piano gratuito"):
- Frase del giorno e lettura delle frasi in un insieme ridotto di categorie.
- 2-3 temi (sfondi) gratuiti, qualche sfondo che ruota ogni giorno.
- Preferiti, condivisione dell'immagine della frase.
- Widget e un numero limitato di promemoria.
- Annunci.

Premium (dalla descrizione e dalle recensioni):
- Nessun annuncio.
- Tutti i temi e tutte le categorie (amore, sport, Bibbia, filosofia, ansia, lutto, ecc.).
- Foto propria come sfondo.
- Promemoria illimitati durante il giorno.
- Ricerca nelle frasi.
- Collezioni personali, frasi proprie, font aggiuntivi, sfondi animati per la schermata di blocco.

## 3. UX

### Flusso schermata per schermata

1. **Onboarding lungo** (molte domande: nome, genere, età, religione, obiettivi, "tough love sì/no", quante notifiche e in che fascia oraria), poi richiesta notifiche, poi **paywall con prova di 3 giorni** senza uscita evidente.
2. **Schermata principale**: una frase a tutto schermo su sfondo/tema, scorrimento verticale tipo feed per la successiva. Sotto: cuore (preferito), condividi. In basso: categorie, temi, profilo/impostazioni.
3. **Azione chiave**: leggere, scorrere, salvare la frase che "arriva al momento giusto"; per molti l'azione vera è guardare il **widget** in Home o in schermata di blocco senza aprire l'app.
4. **Categorie**: griglia di argomenti, "mix" personale da più categorie.
5. **Temi**: griglia di sfondi, font e colori; foto propria (premium).
6. **Condividi**: genera un'immagine della frase per Instagram/sfondo.
7. **Impostazioni**: promemoria (numero al giorno, inizio/fine, giorni), widget (categoria e tema per widget), lingua delle frasi, genere per le frasi, serie di giorni (streak) e "attività del giorno" aggiunte di recente.

### Cosa amano gli utenti
- La frase che arriva "al momento giusto" in notifica o nel widget, senza aprire l'app.
- Il widget in Home e in schermata di blocco, anche per studio (iPad).
- Personalizzazione semplice di font e colori, categorie per il momento che si vive.
- Chiedono: frasi proprie, nota/obiettivo accanto alla frase, notifiche brevi leggibili per intero.

### Cosa odiano (1-3 stelle)
- Il prezzo per delle frasi: "pagare 20€ per una app che ti da citazioni prese poi da internet mi sembra una follia" (IT 1★); "20 euro all'anno per delle frasi motivazionali prese da Internet e buttate a caso? Siamo seri??" (IT 1★); "Non c'è nemmeno un piano gratuito… adesso lo stress ti viene perché devi pagare" (IT 1★).
- Prova che si trasforma in annuale: "I tried a free trial and was automatically charged a full year, not monthly" (US 1★); "charges $50 without warning you that trial is ending" (US 1★).
- Paywall a fine onboarding: "I can't get passed the paid wall… I tried looking for an X or skip button and nothing" (US 1★); troppe domande ("too many questions", IT 1★).
- Dati personali: "Asking my age is not ok. This is a quote app not a medical device!!!" (US 1★); "there is a lot of tracking and data collection" (US 3★).
- Notifiche e streak colpevolizzanti: "don't lose your progress, don't let today be a reason for your failure" (IT 3★); "Way too many notifications" (US 1★); "Io ho scelto di avere una frase al giorno, invece la app ne mostra una nuova ogni ora" (IT 1★); "Please let us turn that off" sulla streak (US 3★).
- Poche frasi, ripetute, banali o volgari: "ho ricevuto dall'app le stesse identiche frasi ogni giorno" (IT 3★); "Very few quotes… repeats almost every day" (US 2★); più recensioni contro le parolacce.
- Widget rotto o frase troncata: "non mi fa vedere le affermazioni nel widget" (IT 3★); "nel centro notifiche non mi fa leggere l'intera frase" (IT 1★).
- Sync: "le collezioni di citazioni create su un dispositivo non esistono sull'altro" (IT 2★); peso 600 MB; schermo nero all'avvio; font tolti dopo aggiornamento.

## 4. Fattibilità iOS senza server

| Funzione | Framework Apple | Note |
|---|---|---|
| Archivio frasi per categoria, IT/EN | JSON in bundle + Swift puro | Nessuna rete. Rotazione senza ripetizioni (mazzo mescolato con seme, persistito). |
| Feed a scorrimento | SwiftUI `ScrollView` + `.scrollTargetBehavior(.paging)` (iOS 17) | |
| Preferiti, collezioni, frasi proprie | SwiftData | Sync iCloud opzionale off di default (ADR-0008). |
| Ricerca | Filtro locale con `localizedStandardContains` | Gratis, era premium. |
| Promemoria | UserNotifications, `UNCalendarNotificationTrigger` | Limite 64 notifiche in attesa: ripianificare a ogni apertura e con `BGAppRefreshTask` (BackgroundTasks). Testo breve che entra intero nel banner. |
| Widget Home, blocco, StandBy | WidgetKit + `AppIntentConfiguration` (categoria per widget) | Estensione widget + App Group per leggere preferiti. Timeline con una frase per fascia oraria. |
| Condividi come immagine / sfondo | `ImageRenderer` + `ShareLink`; salvataggio con PhotoKit solo-aggiunta | Permesso `NSPhotoLibraryAddUsageDescription`, chiesto solo al primo salvataggio. |
| Foto propria come sfondo dell'immagine | `PhotosPicker` (PhotosUI) | Nessun permesso di libreria. |
| Shortcuts / Siri "frase del giorno" | App Intents | Facoltativo. |
| Lettura ad alta voce | AVSpeechSynthesizer | Facoltativo. |

Entitlement ed estensioni: Widget Extension, App Group, Background Modes (fetch) facoltativo, iCloud/CloudKit solo se si attiva la sync. Nessuna keyboard o share extension necessaria.

Parti NON copiabili:
- **Il catalogo di frasi**: è il contenuto del leader (e delle sue fonti, molte moderne e sotto copyright: libri, film, influencer, pastori). Alternativa: corpus curato da noi di autori in **pubblico dominio** (Seneca, Marco Aurelio, Epitteto, Confucio, Dante, Leopardi, Montaigne, Emerson, Thoreau, Twain, Wilde, Marie Curie, ecc.) con traduzioni nostre IT/EN, più proverbi e frasi scritte da Sbu. Wikiquote è CC BY-SA: utile solo per verificare l'attribuzione, non da copiare. Obiettivo 1.0: ~1.000 frasi verificate, nessuna parolaccia, attribuzione corretta.
- Personalizzazione per genere/religione/età: richiede profilazione, salto (e risolve una lamentela).
- Sfondi fotografici e animati con licenza: salto; l'immagine condivisa usa la carta Sbu o una foto dell'utente.
- Blog e libri consigliati: salto (rete).

Conflitto col design system: il leader vive di temi colorati e sfondi a tutto schermo; Sbu vuole carta `surface`, un figura in `ink`. In app la frase è la figura (testo SF grande, Dynamic Type) su carta. Per l'immagine da condividere o lo sfondo, va deciso se è ammessa una variante (foto dell'utente) fuori dalle schermate: punto da approvare nella spec.

## 5. Rischi App Review

- **4.3 (spam), rischio principale.** La nicchia "citazioni/affermazioni" è satura: centinaia di app quasi identiche, e 4.3(b) cita le categorie sature. Con sei rifiuti 4.3/4.2.6 del 14/10, un'app di frasi è il tipo di app che un revisore etichetta come "template". Serve una differenza evidente: corpus proprio e curato, widget configurabili, frasi proprie, zero onboarding. Tra le Sbu: sovrapposizione con **Habits** se si aggiunge una streak (non aggiungerla); nessuna sovrapposizione con le altre. Fondere "I am" (affermazioni) nella stessa app, non farne due.
- **4.2 (funzionalità minima)**: una lista di frasi in bundle può sembrare "un libro statico". Mitigazione: widget, promemoria pianificati, collezioni, frasi proprie, immagine da condividere.
- **5.1.1/5.1.2 privacy**: nessun dato raccolto, niente domande su età, genere, religione; permessi chiesti solo all'uso. Categoria "Stile di vita", non "Salute": evita qualunque promessa terapeutica su ansia/depressione (1.4.1 / 5.1.3).
- **5.2.1/5.2.5 marchi e IP**: niente "Motivation" nel nome o nei metadati; frasi di autori moderni sotto copyright sono un rischio 5.2.1, per questo solo pubblico dominio e testi propri. Niente parole chiave di terzi.
- **2.5.x**: widget e notifiche con API pubbliche, nessun contenuto scaricato dopo la revisione (2.5.2 ok, il corpus è in bundle). Background refresh solo per ripianificare.
- **2.3.x metadati**: screenshot con frasi nostre, non quelle del leader.

**La cosa sola**: *una frase al giorno, quando la vuoi tu*. La figura è la frase del momento, chiusa dal punto fermo; tutto il resto (categorie, preferiti, widget, orario) serve a quella.

## 6. Stima

- Giorni-agente per una 1.0 pari al leader (senza pubblicità e paywall): **5**. App, SwiftData, notifiche, widget configurabile, immagine da condividere: 3 giorni. Corpus di ~1.000 frasi IT/EN in pubblico dominio, con verifica delle attribuzioni: 2 giorni (è il lavoro vero e il collo di bottiglia della qualità).
- Complessità: **M** (codice S, contenuto e widget lo portano a M).
- Abbonamento stupido da pagare: **5/5**. Fino a 50 $/anno per frasi prese da internet e un widget, con prova che scatta sull'annuale: è il caso perfetto per Sbu.
- Fattibilità: **4/5**. Tutto on-device con framework Apple; si perde solo il catalogo del leader, e il rischio 4.3 da nicchia satura è alto.
