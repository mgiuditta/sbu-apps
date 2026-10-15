# Nicchia Pdf

Ricerca del 15/10/2026, solo dati pubblici: lookup API (IT e US), pagine App Store (elenco acquisti in-app), RSS delle recensioni (IT e US, più recenti). Nessuna app scaricata.

Nota di partenza: **Sbu Docs** (scanner documenti → PDF, ADR-0006) e **Sbu Invoice** (fatture in PDF) esistono già, e in coda c'è la nicchia **Firma** (Signeasy, Firma Digitale). Sbu Pdf deve stare lontana da entrambe.

## 1. Leader IT e USA

| | Adobe Acrobat Reader | PDF (SMM service) | PDF Expert (Readdle), concorrente |
|---|---|---|---|
| id | **469337564** (stesso id IT e US) | **1532638515** ("PDF" in IT, "PDF Editor ®" in US) | 743974925 |
| Prezzo | gratis | gratis | gratis |
| Classifica | IT #2 Economia | IT #9 Economia (KEEP) | IT #68 top-grossing generale |
| Valutazioni IT | 93.826, media 4,62 | 2.460, media 4,46 | 17.616, media 4,59 |
| Valutazioni US | 660.308, media 4,64 | 29.252, media 4,53 | 216.149, media 4,67 |
| Versione | 26.09.00, 553 MB, iOS 16+ | 3.4.11, 293 MB | 7.26.2 |

Il leader US è lo stesso: la ricerca "pdf" sullo Store US dà Acrobat Reader al primo posto, poi PDF Editor ® di SMM, poi CamScanner (scanner, già Sbu Docs) e PDF Expert.

**Acquisti in-app, Acrobat (pagina Store IT):** Acrobat Premium annuale 77,99 € / 76,99 €; Premium mensile 10,99 € / 16,49 € / 4,49 € (promo); "Modifica e converti PDF / mese" 10,99 €; "Premium - Modifica e crea PDF" 10,99 €; PDF Pack 9,99 €; Adobe ExportPDF 23,99 €; AI Assistant 7,99 €. Prova gratuita 7 giorni, poi 76,99 €/anno.
**US:** Premium mensile $12.99 / $14.99, annuale $69.99 / $48.99, **settimanale $9.99**, Edit & Convert $12.99/mese, PDF Pack $9.99, AI Assistant $6.99.

**Acquisti in-app, PDF di SMM (IT):** settimanale 6,99 € / 7,99 €, mensile 12,99 € / 14,99 € (promo 8,99 €), annuale 49,99 € / 59,99 €. **US:** settimanale $6.99, mensile $12.99 (promo $7.99), annuale $59.99 / $69.99. Il modello è il settimanale con prova che parte da sola.

**PDF Expert (IT):** Premium 44,99-52,99 €/anno, mensile 10,99 €, Mac & iOS 84,99-89,99 €/anno.

## 2. Cosa sta dietro il paywall

### Acrobat Reader

| Gratis | A pagamento |
|---|---|
| Apri e leggi PDF, ricerca, zoom | Modifica testo e immagini del PDF |
| Liquid Mode (testo ridisposto, dimensione e spaziatura carattere) | OCR: scansioni → testo ricercabile e modificabile |
| Annota: evidenzia, note adesive, commenti | Unisci, dividi file |
| Compila e firma moduli (Fill & Sign) | Organizza pagine: inserisci, elimina, ruota, ritaglia, riordina |
| Collega OneDrive, Dropbox, Google Drive; preferiti | Crea PDF da Office, Google Docs, immagini, pagine web |
| Apri scansioni di Adobe Scan | Esporta in Word, Excel, PowerPoint, immagini |
| Lettura ad alta voce con voci base | Comprimi PDF |
| | Proteggi con password |
| | Voci di alta qualità |
| | Assistente IA: domande, riassunti, PDF Spaces (cloud) |

Dalle recensioni US: anche la firma con Apple Pencil su iPad risulta bloccata ("That feature is locked out unless I have the premium subscription").

### PDF di SMM (KEEP)

La descrizione non separa gratis e a pagamento. Le recensioni dicono che quasi tutto è dietro il paywall, e che il paywall arriva **al momento di salvare**: si modifica, poi l'unica scelta è pagare o scartare. Funzioni dichiarate: lettura, ricerca, zoom; scanner con prospettiva, colori, ritaglio automatico; annotazioni (note, disegno, evidenzia, elenco commenti, Apple Pencil); compilazione moduli; firma col dito o Pencil; file solo sul dispositivo, export via condivisione.

## 3. UX

Flusso dedotto da descrizioni, testi dello Store e recensioni (non ho aperto le app; le schermate vanno confermate prima della spec).

**Acrobat Reader**
1. **Onboarding:** schermate di benvenuto, invito ad accedere con un Adobe ID (o Apple/Google), offerta di prova 7 giorni ("Gratis per 1 settimana, poi 76,99 €/anno" è l'offerta pre-installazione).
2. **Schermata principale:** Home con file recenti, preferiti (stella), sezione File con locali, Adobe cloud e servizi collegati; condivisi; "PDF Spaces".
3. **Azione chiave:** apri un PDF → visualizzatore a pagina continua, ricerca, Liquid Mode; barra strumenti con Commenta, Compila e firma (gratis) e Modifica, Organizza pagine, Esporta, Comprimi, Proteggi (lucchetto → paywall). Firma: disegna, salva, posiziona.
4. **Condividi:** di default condivide un link al cloud Adobe; per avere il file serve un passo in più (recensione US: "it sends a link so you never have an actual pdf").
5. **Impostazioni:** account, abbonamento, notifiche, cloud collegati, preferenze di visualizzazione.

**PDF di SMM**
1. Onboarding con paywall e prova settimanale (più recensioni dicono che la prova parte da sola).
2. Elenco documenti locali, + per importare da File, Foto o fotocamera (scanner).
3. Apri → visualizzatore con strumenti in basso: annota, firma, testo, pagine.
4. Salvare o esportare apre il paywall; chiudere significa perdere il lavoro.

**Cosa amano** (4-5★): "molto intuitiva … evidenze, note e appunti in modo semplice" (IT, Acrobat); "Extremely user friendly and reliable" (US, Acrobat); "super facile da usare" (IT, SMM); un solo posto per leggere, annotare e firmare.

**Cosa odiano.** Ho letto 342 recensioni recenti (Acrobat IT 100, US 100; SMM IT 42, US 100): 204 da 1-3★. Medie del campione recente: Acrobat IT 3,1-3,4, US 2,8-3,2; SMM IT 2,3, US 1,8-1,9, molto sotto la media storica dello Store.
- Tutto a pagamento, anche cose semplici: "48 euro al mese per modificare un pdf? Voi siete impazziti" (IT, Acrobat, 1★); "Mi dici a cosa serve un applicazione per leggere i pdf se per crearli ed esportarli devi pagare … 70 euro??" (IT, Acrobat, 1★); "Free doesn't mean it's free. I shouldn't have to pay to convert my files to PDF" (US, SMM, 1★).
- Paywall dopo il lavoro: "They discarded my 2 hours of work because i didnt pay" (IT, SMM, 1★); "Basic function - remove page from the file. Give me money. No, discard … then crash" (US, SMM, 1★); "It opens the edit screen but there's no way to save the changes" (US, SMM, 1★).
- Addebiti e prove: "This app tricks you into a $6.99 weekly charge" (US, SMM, 1★); "Mi hanno continuato ad addebitare dei soldi senza il mio consenso" (IT, Acrobat, 1★); "they charge a $70 cancellation fee" (US, Acrobat, 1★).
- Crash e lavoro perso: "dopo l'ultimo quando apro dei pdf piu' grandi va in crash" (IT, Acrobat, 1★); "the entire app froze and shut down. When I opened it again everything was gone" (US, SMM, 1★); "it cancels your notes" (IT, Acrobat, 2★).
- Lentezza e file chiusi nel cloud: "Impiega tantissimo ad aprire i file" (IT, Acrobat, 1★); "They have removed the ability to save locally to your device OUTSIDE of their controlled files in the cloud" (US, Acrobat, 2★); "You have to edit pages 1 by 1" (US, Acrobat, 1★).

Cosa chiedono e manca: riordinare più pagine insieme, salvare un vero file e non un link, salvataggio automatico, nessun paywall a metà.

## 4. Fattibilità iOS senza server

| Funzione | Framework Apple | Note |
|---|---|---|
| Libreria, apri da File e da altre app | `UIDocumentPickerViewController` / `fileImporter`, `CFBundleDocumentTypes` per `com.adobe.pdf`, `LSSupportsOpeningDocumentsInPlace`, `UIFileSharingEnabled` | Come in Sbu Docs: i file sono la verità, niente database |
| Lettura, ricerca, zoom, miniature, indice | PDFKit `PDFView`, `PDFThumbnailView`, `PDFDocument.findString`, `outlineRoot` | |
| Lettura semplificata (tipo Liquid Mode) | `PDFDocument.string` / `PDFPage.attributedString` in una vista testo con Dynamic Type | Ridisposizione approssimata, senza IA |
| Evidenzia, sottolinea, barrato, nota, testo libero, forme | `PDFAnnotation` (highlight, underline, strikeOut, text, freeText, square, ink) | Si salvano dentro il PDF con `write(to:)` |
| Disegno a mano e Apple Pencil | PencilKit `PKCanvasView` sopra la pagina (`PDFPageOverlayViewProvider`, iOS 16+), poi annotazione `ink` | |
| Firma | PencilKit per disegnarla, salvata in locale (Keychain o file protetto), stampata come annotazione stamp/ink | Firma grafica, non firma digitale qualificata |
| Compila moduli | `PDFAnnotation` widget (`widgetFieldType` testo, checkbox, radio, scelta) | AcroForm sì, XFA no |
| Organizza pagine | `PDFDocument.insert/removePage/exchangePage`, `PDFPage.rotation`, `setBounds(_:for: .cropBox)` | Selezione multipla e trascina in una griglia: risponde alla recensione "edit pages 1 by 1" |
| Unisci, dividi, estrai | PDFKit, copia di `PDFPage` tra documenti | |
| Crea PDF da foto e file | PhotoKit (`PhotosPicker`), `UIGraphicsPDFRenderer`; Office/testo via QuickLook o `WKWebView.createPDF` su file locale | La scansione resta in Sbu Docs (`VNDocumentCameraViewController`): qui no |
| Esporta immagini e testo | `PDFPage.thumbnail(of:for:)` / rendering in `CGContext` → JPEG/PNG; `PDFDocument.string` → .txt | |
| Comprimi | Re-render delle immagini con ImageIO a qualità ridotta; `PDFDocumentWriteOption.saveImagesAsJPEGOption` e `optimizeImagesForScreenOption` (iOS 16.4+, da verificare) | Mostrare dimensione prima/dopo |
| Password | `write(to:withOptions:)` con `userPasswordOption` / `ownerPasswordOption`; `unlock(withPassword:)` | |
| OCR, PDF ricercabile | Vision `VNRecognizeTextRequest` (italiano e inglese on-device), testo invisibile sotto l'immagine | Stessa tecnica di Sbu Docs: condividere il codice in SbuKit |
| Oscura dati sensibili | Rettangolo nero + rasterizzazione della pagina, così il testo sotto sparisce davvero | |
| Leggi ad alta voce | AVFoundation `AVSpeechSynthesizer`, voci di sistema (anche Premium/Enhanced scaricate dall'utente) | |
| Stampa | `UIPrintInteractionController` | |

**Entitlement ed estensioni:** nessun entitlement speciale. Servono i tipi documento nel Info.plist; utile ma non obbligatoria una **Action extension** ("Apri in Sbu Pdf" dal foglio di condivisione). Nessun HealthKit, nessuna tastiera, nessuna rete. iCloud solo se si vuole la sincronizzazione (ADR-0008, spenta di default), non necessaria: i file stanno in File.

**Parti NON copiabili e alternativa on-device:**
- Modifica del testo originale del PDF (riscrivere un paragrafo con lo stesso carattere): PDFKit non la offre. Alternativa: copri con un rettangolo del colore di sfondo e scrivi sopra una casella di testo.
- Conversione PDF → Word, Excel, PowerPoint: è cloud Adobe. Alternativa: esporta testo e immagini; niente .docx.
- Pagina web → PDF: richiede rete; Safari lo fa già ("Crea PDF").
- Assistente IA, riassunti, PDF Spaces, condivisione via link: cloud. Alternativa: niente in 1.0; più avanti, se si alza il target, Foundation Models (iOS 26) solo dove disponibile.
- Voci di alta qualità: sono licenze cloud. Alternativa: voci di sistema.
- Cloud Adobe, Dropbox, OneDrive, Google Drive: gli SDK sono terzi. Alternativa: il selettore di File vede già i provider installati.
- Firma digitale con certificato (PAdES, firma qualificata): servono certificati e un ente terzo. Fuori.

## 5. Rischi App Review

- **4.3, somiglianza con altre Sbu:** il più alto. Sbu Docs fa già "documenti in PDF sul telefono" con OCR e file PDF in File. Se Sbu Pdf importa da fotocamera, fa OCR come azione principale o ha una libreria di PDF simile, Apple vede due app quasi uguali dello stesso sviluppatore, nella settimana dopo sei rifiuti 4.3. Regole: niente scanner in Sbu Pdf, nessuna schermata in comune, testo descrittivo che separa "acquisisci carta" (Docs) da "lavora su un PDF che hai già" (Pdf). E la nicchia **Firma** (Signeasy, Firma Digitale) va **fusa** qui come concorrente (ADR-0004), non fatta come app a parte.
- **4.3, nicchia:** la categoria PDF è satura di cloni (ricerca US: decine di "PDF Editor", "PDF Converter"). Serve un nome e un'icona Sbu riconoscibili e uno strumento vero e completo, non un visualizzatore.
- **4.2 / 4.2.2, funzionalità minima:** iOS fa già molto. File unisce immagini in PDF e ruota; Markup annota e firma; Anteprima Quick Look compila moduli. Un'app che fa solo lettura e annotazione rischia "replica di funzioni di sistema". L'organizzatore pagine a selezione multipla, compressione con dimensione prima/dopo, password, oscuramento e OCR la rendono più di Markup.
- **5.1.1 / 5.1.2 privacy:** basso. Niente rete; i PDF possono contenere dati sensibili, quindi va detto che restano sul dispositivo. Accesso a Foto solo con `PhotosPicker` (nessun permesso). Firma salvata in locale. Privacy manifest con le API a motivo dichiarato (file timestamp, UserDefaults).
- **5.2.5 e marchi:** "PDF" è un formato ISO, utilizzabile; non usare "Acrobat", "Adobe", "Liquid Mode", "Fill & Sign", "PDF Expert" nei metadati. Il nome "PDF" da solo (come SMM) è generico: meglio "Sbu Pdf" con sottotitolo descrittivo. Niente icona che richiami il logo rosso di Acrobat.
- **2.5.x:** API pubbliche soltanto (PDFKit, PencilKit, Vision). Le opzioni di scrittura PDFKit vanno controllate per disponibilità su iOS 17. Nessun codice scaricato.
- **3.1.x:** nessun acquisto, quindi nessun rischio di paywall; è anche il messaggio contro le recensioni.

**La Cosa sola:** *sistemare un PDF che hai già e restituirlo come file.* Apri, metti in ordine le pagine, annota o firma, comprimi o proteggi, salva un vero PDF in File. Niente acquisizione (è Docs), niente cloud. Cifra possibile: la dimensione del file salvato (o il numero di pagine), chiusa dal punto fermo.

## 6. Stima

| Blocco | Giorni-agente |
|---|---|
| Libreria su File, apertura da altre app, visualizzatore, ricerca, miniature | 1,5 |
| Organizzatore pagine: griglia, selezione multipla, riordina, ruota, elimina, ritaglia, unisci, dividi, estrai | 2 |
| Annotazioni, PencilKit, firma salvata | 2 |
| Moduli, testo libero, oscuramento | 1 |
| Comprimi, password, OCR (codice in comune con Docs), leggi ad alta voce, esporta immagini e testo, stampa | 1,5 |
| Action extension, stringhe IT/EN, test Swift Testing, audit accessibilità, snapshot, metadati | 2 |
| **Totale per una 1.0 pari al leader (senza cloud, IA e conversione Office)** | **10** |

**Complessità: L** (molte funzioni, PDFKit ha spigoli: annotazioni e PencilKit sovrapposti, salvataggio sicuro di file grandi).

**Abbonamento stupido da pagare: 5/5.** 10,99 €/mese o 77,99 €/anno, e SMM 6,99 € a settimana, per unire, ruotare o comprimere pagine: tutto quello che PDFKit fa in locale da iOS 11.

**Fattibilità: 4/5.** Tutto il cuore è PDFKit, PencilKit e Vision senza server; restano fuori solo modifica del testo originale, conversione Office e IA, e il vero lavoro è tenere l'app distinta da Sbu Docs.
