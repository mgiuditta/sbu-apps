# Nicchia: Dividi

Ricerca del 15/10/2026, solo dati pubblici: lookup API IT/US (Splitwise 458023433, tricount 349866256, Splid 991473495, Settle Up 737534985, Sesterce 1239566667), ricerca US "split expenses", pagine App Store IT/US (elenco acquisti in-app, etichette privacy), RSS recensioni IT e US (500 recensioni lette, 5 pagine per paese; 101 da 1-3★ in IT, 142 in US), sito dello sviluppatore (splitwise.com/pro). Posizione 3 nella top-grossing Finanza IT del 15/10 (`research/it-top-grossing-2026-10-15.md`, riga 215; mappa riga 521).

## 1. Leader IT e USA

| | IT | US |
|---|---|---|
| App | Splitwise | Splitwise (stessa app) |
| id | 458023433 | 458023433 |
| Sviluppatore | Splitwise, Inc. | idem |
| Prezzo | Gratis, con acquisti in-app | Free, with IAP |
| Valutazione | 4,45 su 4.260 voti | 4,00 su 28.805 voti |
| Versione | 26.9.2 (11/10/2026), iOS 16+, 70 MB | idem |
| Online dal | 24/08/2011 | idem |
| Categoria | Finanza | Finance |

Il leader per incasso è lo stesso nei due paesi. Per voti e gradimento però la nicchia è guidata dalle alternative **gratuite e illimitate**, ed è questo il dato che conta:

| App | id | IT | US | Modello |
|---|---|---|---|---|
| tricount (Tricount SA, gruppo bunq) | 349866256 | 4,81 su 13.344 | 4,88 su 7.400 | gratis, "nessun limite", vive dei pagamenti bunq |
| Splid | 991473495 | 4,85 su 7.049 | 4,91 su 4.145 | gratis, 12 MB, offline |
| Settle Up | 737534985 | 4,76 su 1.232 | 4,82 su 1.764 | freemium |
| Sesterce | 1239566667 | 4,76 su 21 | 4,98 su 61 | freemium |
| Splittr | 588332804 | n/d | 4,84 su 619 | |
| Split – Pay Together | 6753594526 | n/d | 4,70 su 775 | |

Equivalente US principale diverso dal leader: **tricount** (349866256), il più votato nella ricerca "split expenses" dopo Splitwise e il nome che le recensioni negative di Splitwise citano di più come rifugio ("Usate Tricount", "Viva tricount!").

Acquisti in-app di Splitwise (tutti "Splitwise Pro", pagina App Store):

| IT | US |
|---|---|
| 0,99 € | $2.99 (×3) |
| 2,99 € (×5) | $3.99 |
| 29,99 € (×3) | $4.99 (×4) |
| 47,99 € | $29.99 |
| | $39.99 |

Lettura: mensile 2,99 €, annuale 29,99 € in IT (47,99 € probabilmente un annuale di prezzo pieno o famiglia); in US $4.99/mese, $39.99/anno. Le recensioni US citano prezzi più alti mostrati in app: "$8 a month" (01/10/2026), "$59"/"$60 per year" (01/10, 21/09, 23/08/2026). In IT una recensione (01/08/2026) segnala che il mensile è sparito ("Ora hanno solo il piano di abbonamento annuale"), un'altra (13/09/2026) un addebito annuale dopo aver scelto il mensile.

Etichette privacy: "Dati collegati a te" usati per Analisi (e altro); pubblicità interstiziali prima di aggiungere una spesa (recensioni). Account obbligatorio (email/password, numero di telefono; niente Accedi con Apple secondo una recensione del 23/08/2024).

## 2. Cosa sta dietro il paywall

Gratis (con pubblicità e limiti):
- Gruppi (casa, viaggio, coppia, altro) e "amicizie" private uno a uno.
- Aggiungere una spesa: descrizione, importo, chi ha pagato, divisione in parti uguali o diverse (percentuali, quote, importi esatti, "aggiustamenti"), più pagatori su una stessa spesa.
- **Solo 3-5 spese al giorno**, finestra di 24 ore mobile (non a mezzanotte), conta anche quelle cancellate ("even if you delete one, it counts against your 4", 14/09/2026). Pubblicità o attesa di 10 secondi prima di ogni spesa ("makes you wait 10 seconds while adding expenses", 09/10/2026).
- Saldi per persona e per gruppo, totale con una persona su tutti i gruppi.
- Semplifica i debiti (piano di rimborso con meno trasferimenti).
- Registrare un rimborso in contanti ("Salda").
- Spese ricorrenti (settimanale, quindicinale, mensile, annuale).
- Categorie, commenti sulle spese, foto della ricevuta a bassa risoluzione.
- Feed attività, notifiche push, cronologia modifiche, ripristino di gruppi e spese cancellate.
- Esporta CSV (dal sito).
- Pagamenti integrati: Venmo, PayPal, Splitwise Pay (solo US), Paytm (India).
- 100+ valute, ma senza conversione.

A pagamento (Splitwise Pro):
- **Spese illimitate**, nessuna pubblicità.
- Conversione valute con tassi del giorno (Open Exchange Rates).
- Grafici: spesa per categoria e andamento nel tempo.
- Scansione ricevuta con OCR e **suddivisione per voce** (assegni ogni piatto a una persona).
- Ricerca nella cronologia delle spese.
- Divisione predefinita del gruppo (es. 55/45, quote per famiglia).
- Import transazioni dalla carta (solo US).
- Ricevute ad alta risoluzione nel cloud (10 GB), backup JSON.
- Accesso anticipato alle novità.

## 3. UX

Flusso principale (dalla descrizione, dalla pagina Pro e dalle recensioni; nessuno screenshot copiato):

1. **Onboarding.** Registrazione obbligatoria (email, password, telefono); su un nuovo telefono un codice via SMS ("peccato che non arrivi mai", 10/09/2025). Google SSO funziona sul sito ma non nell'app (25/09/2026, 16/03/2026). Poi offerta Pro.
2. **Schermata principale.** Tab Gruppi / Amici / Attività / Account. In cima il saldo complessivo ("ti devono", "devi"); sotto l'elenco di gruppi e persone con il saldo di ciascuno in verde o arancio. Pulsante flottante "Aggiungi spesa".
3. **Gruppo.** Copertina, saldi dei membri, elenco spese per mese; pulsanti "Salda", "Saldi", "Totali", "Esporta". Aggiungere membri ora richiede invitarli o il numero di telefono ("Non posso più aggiungere membri senza invitarli", 02/08/2026).
4. **Azione chiave, aggiungere una spesa.** Con chi (gruppo o persone), descrizione con categoria automatica, importo e valuta, "Pagato da te e diviso in parti uguali" come riga toccabile che apre: chi ha pagato (anche più persone), come dividere (uguale, esatto, percentuale, quote, aggiustamento), data, gruppo, foto, nota. Gratis: pubblicità o attesa prima del salvataggio, poi muro dopo la terza-quinta spesa.
5. **Saldare.** "Salda" propone chi paga chi (con semplificazione dei debiti), registra contanti o apre Venmo/PayPal. Una recensione (27/08/2026) lamenta che propone di pagare tutto a chi ha messo l'ultima spesa.
6. **Impostazioni.** Profilo, valuta predefinita, notifiche via email e push, Splitwise Pro, esporta, privacy.

Cosa amano (5★ IT): "Mai più litigi in viaggio per i soldi" (11/07/2026); viaggi con amici, coinquilini, coppia; "per chi come me è separato, le spese straordinarie legate a nostro figlio diventano di semplice gestione" (10/04/2026); "cassa comune viaggi" (07/04/2026); semplice e intuitiva quando funziona.

Cosa odiano (1-3★, citazioni dalle RSS):
- Limite giornaliero, la critica dominante (oltre metà delle 1-3★ in entrambi i paesi): "se si va in vacanza a 5 spese ci arrivo già prima di pranzo" (2★, 16/10/2025); "sono a metà viaggio e non posso più inserire le mie spese" (1★, 21/10/2024); "I'm in the middle of a group trip and can't upload anymore expenses without paying for pro" (1★, 12/09/2026).
- Abbonamento per un uso sporadico: "Non ha senso pagare l'app per 12 mesi quando uno ne ha l'esigenza un paio di volte l'anno" (1★, 16/08/2026); "you want to track who owes you $12? That'll be $60" (1★, 21/08/2026); "accetterei il pagamento una tantum" (2★, 28/04/2025).
- Pubblicità e spinta al Pro: "prima di ogni inserimento ci si deve sorbire una pubblicità" (1★, 15/06/2024); notifiche promozionali "even if you don't use it for a week" (1★, 16/09/2026).
- Account e login: "obbligate l'utente a fare un nuovo account sul vostro db proprietario" (1★, 16/03/2026); "ancora non implementa log in with Apple … La privacy conta" (1★, 23/08/2024).
- Conversione valute e ricerca a pagamento: "To search a group you must upgrade … To pay an expense recorded in a foreign currency, upgrade" (1★, 11/09/2026).
- Calcoli poco chiari: "non mi divide in modo giusto le spese" (1★, 13/03/2026); "The amount displayed at the top is wayyy wrong" (1★, 13/09/2026); "refuses to give an audit trail" (1★, 23/08/2026); "Chiudendo il conto con un'amica ho chiuso il conto di tutti" (2★, 03/08/2025).
- Complessità: "way too complex feeling for how simple it is" (2★, 16/09/2026); nuova scansione ricevute "Cannot set someone else as the person who paid now" (1★, 10/09/2026).
- Lentezza con gruppi lunghi (2★, 30/08/2025; 3★, 10/06/2025).

Cose chieste che il leader non fa (gratis): spese illimitate, conversione valute, ricerca, acquisto una tantum, divisione predefinita del gruppo, membri senza invito né telefono, conti chiari e verificabili spesa per spesa.

## 4. Fattibilità iOS senza server

| Funzione | Framework Apple | Note |
|---|---|---|
| Gruppi, membri, spese, rimborsi | SwiftData | membri sono solo nomi (o un contatto scelto), nessun account |
| Scegliere un membro dai contatti | ContactsUI `CNContactPickerViewController` | fuori processo, nessun permesso Contatti |
| Divisione uguale/esatta/percentuale/quote/aggiustamento, più pagatori | Swift puro, `Decimal` | test parametrizzati; resto dei centesimi assegnato in modo deterministico |
| Semplifica i debiti | Swift puro | algoritmo greedy creditori/debitori (al massimo n-1 trasferimenti) |
| Valute | `Locale.Currency`, `Decimal.FormatStyle.Currency` | elenco ISO dal sistema |
| Conversione valute | **non copiabile** (tassi live = rete) | alternativa: tasso inserito a mano per gruppo/spesa, ricordato |
| Spese ricorrenti, promemoria | `UserNotifications` locali | nessun push remoto |
| Scansione ricevuta | VisionKit `VNDocumentCameraViewController` + Vision `VNRecognizeTextRequest` | sul dispositivo; permesso fotocamera solo al tocco |
| Suddivisione per voce | Vision (righe di testo con bounding box) + parser prezzi | euristica on-device; `RecognizeDocumentsRequest` è iOS 26, quindi dietro `if #available` |
| Foto della ricevuta | PhotosUI `PhotosPicker` | nessun permesso Foto |
| Categorie automatiche | Swift (parole chiave) | niente AI cloud |
| Grafici per categoria e nel tempo | Swift Charts | |
| Ricerca | `.searchable` + `#Predicate` | |
| Esporta CSV e riepilogo PDF | `fileExporter`/`ShareLink`, `ImageRenderer` o PDFKit | |
| Condividere un gruppo con gli altri | CloudKit `CKShare` (ADR-0009), oppure file `.sbudividi` via AirDrop/Messaggi (`Transferable`, UTType esportato) | vedi sotto |
| Saldare con un'app di pagamento | `openURL` verso un link scritto dall'utente | facoltativo; nessuna integrazione, nessun marchio |
| Widget saldo | WidgetKit | 1.1 |

Entitlement ed estensioni: iCloud + CloudKit container (solo se si fa la condivisione, spenta per impostazione ADR-0008), App Group per il widget, UTType esportato per il file di gruppo. Nessuna estensione necessaria per la 1.0. Nessun HealthKit, nessuna rete locale.

Parti NON copiabili e alternativa on-device:
- **Gruppo condiviso in cui tutti scrivono (multi-scrittore in tempo reale).** È il cuore di Splitwise e passa dal loro server. ADR-0009 permette solo la condivisione in **sola lettura**. Alternative: (a) 1.0 con un "tesoriere" che tiene il gruppo e lo condivide in sola lettura via `CKShare` (gli altri vedono saldi e spese dal vivo), più invio di un file di gruppo che si fonde per UUID; (b) 1.1 con `CKShare` in lettura e scrittura, che richiede un nuovo ADR che estenda il 0009 (spese come record immutabili, modifiche come nuove versioni, conflitti risolti per ultima scrittura per campo). Gli altri devono avere l'app e un ID Apple: niente link web per chi ha Android.
- Tassi di cambio live: tasso manuale.
- Pagamenti integrati (Venmo, PayPal, Splitwise Pay), import transazioni dalla carta: saltati.
- Ricevute nel cloud da 10 GB: le foto restano sul dispositivo (e nell'iCloud dell'utente se attivo).
- Notifiche quando un amico aggiunge una spesa: solo con CloudKit (`CKQuerySubscription`/notifiche di zona condivisa), quindi dopo l'ADR.

## 5. Rischi App Review

- **4.3 nella nicchia: alto.** La categoria è satura di app gratuite ben votate (tricount, Splid, Settle Up, Splittr e decine di cloni "Split expenses"). Apple usa 4.3(b) anche per "categoria satura": serve una differenza leggibile in 30 secondi dal revisore, cioè nessun account, nessun limite, funziona offline, conti verificabili spesa per spesa, scansione con suddivisione per voce sul dispositivo. Dopo i rifiuti 4.3/4.2.6 del 14/10 questa nicchia va inviata solo con un account in salute.
- **4.3 tra le Sbu: medio-basso.** Vicine per dominio "soldi": Subscriptions (abbonamenti), Invoice (fatture), Fuel (spese auto), Duo (lista regali con "quanto resta da spendere", sul branch `duo`). La cosa sola è diversa (chi deve quanto a chi tra più persone), ma metadati e screenshot non devono sembrare "un'altra app di spese". Nota per la revisione: una riga sulla differenza da Subscriptions e Invoice.
- **5.1.1/5.1.2 privacy: basso.** Nessun account, nessun dato raccolto; picker contatti fuori processo; fotocamera solo per la ricevuta con descrizione d'uso. Con `CKShare` aggiornare privacy policy come per Habits (ADR-0009). Nessun tema salute.
- **4.2 funzionalità minima: basso.** App vera con gruppi, divisioni, saldi, scansione.
- **5.2.5 / 5.2.1 marchi: basso se si rispettano le regole.** Mai "Splitwise", "tricount", "Venmo", "PayPal" nei metadati o nelle parole chiave (2.3.7); nessun loro logo nella schermata "Salda". Il nome "Dividi"/"Split" è generico.
- **3.1.x / finanza: basso.** Nessun movimento di denaro, nessun prestito: è un registro, non un servizio finanziario (3.2.1(viii) non si applica).
- **2.5.x: basso.** API pubbliche (Vision, VisionKit, CloudKit); `RecognizeDocumentsRequest` solo dietro controllo di disponibilità (2.5.1); niente codice scaricato.

Regola Sbu "una cosa sola": **sapere chi deve quanto a chi, e chiudere i conti.** La figura unica della schermata del gruppo è il saldo dell'utente ("Ti devono 42,50 €" o "Devi 12 €"), chiuso dal punto fermo nell'accento; quando tutti sono pari la figura diventa "Pari", il punto chiude la cosa. Budget, grafici e categorie sono secondari (grafici in 1.1 o in una sezione "Totali" senza figura).

## 6. Stima

- Giorni-agente per una 1.0 pari al leader (senza server): **7-9**. Modello e divisioni con test (1,5), UI gruppi/spese/saldi/salda (2), scansione e suddivisione per voce (1,5), ricorrenti, valute manuali, ricerca, esporta CSV/PDF (1), condivisione sola lettura `CKShare` + file di gruppo (1,5), stringhe, accessibilità, screenshot (1). Lettura e scrittura condivisa: +3-4 giorni e un ADR.
- Complessità: **M** (L con il gruppo condiviso in scrittura).
- "Abbonamento stupido da pagare": **5/5**. Fino a 60 $/anno o 30-48 €/anno per sommare e dividere, con un limite di 3-5 spese al giorno che blocca a metà viaggio: è la lamentela numero uno nelle 1-3★ in entrambi i paesi.
- Fattibilità: **3/5**. Tutto il calcolo, la scansione e l'esportazione sono on-device e semplici; ma l'esperienza di gruppo vera (tutti aggiungono spese) richiede `CKShare` in scrittura oltre l'ADR-0009 e un ID Apple per ogni amico, e la nicchia è già piena di alternative gratuite, quindi il valore aggiunto per l'utente è più basso del fastidio verso il leader.
