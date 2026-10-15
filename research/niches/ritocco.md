# Nicchia: Ritocco

Data: 15 ottobre 2026. Fonti solo pubbliche: lookup API iTunes (IT/US), RSS recensioni IT/US (pagine 1-2, più recenti), descrizioni dello Store. Nessun download o analisi del binario.

## 1. Leader IT e USA

| | Facelab (leader IT) | Facelab (US) | Facetune (top US equivalente) |
|---|---|---|---|
| ID | 1361012099 | 1361012099 | 1149994032 |
| Nome scheda | Facelab・Modifica Viso, Corpo | Facelab: Face & Body Editor | Facetune: Photo & Video Editor (IT: "Facetune: Modifica Foto e IA") |
| Sviluppatore | IRONTECH LIMITED (irontech.mobi) | idem | Lightricks Ltd. |
| Prezzo | gratis + IAP | gratis + IAP | gratis + IAP |
| Versione | 2.96 (7 ott 2026) | 2.96 | 26.33 |
| Valutazione | 4,50 su 14.186 | 4,64 su 87.744 | IT 4,47 su 14.607 · US 4,62 su 379.470 |

Abbonamento Facelab (dalla descrizione, prezzi USD): settimanale 4,99 $/sett. con 7 giorni di prova; mensile 7,99 $; annuale 35,99 $ con 7 giorni di prova; acquisto a vita 69,99 $. Le recensioni IT citano addebiti da 22,99 € e circa 50 € (annuale). Facetune: nelle recensioni US 11,99-12 $/settimana, abbonamento "VIP", watermark sull'export gratuito.

Altri della nicchia nella classifica IT: Bodytune (1222515036), Peachy (1390423469), PrettyUp (1544211932, video), Body Editor. (1473047769); negli US anche Tune Face & Body (491712618) ed Everlook (1460643887). Nicchia molto affollata.

## 2. Cosa sta dietro il paywall

Dalla descrizione e dalle recensioni (la scheda non separa gratis e Premium; "Premium dà accesso illimitato a tutte le funzioni").

**Gratis (sempre meno, secondo le recensioni)**
- Apertura foto, rilevamento viso, alcuni strumenti base (filtri base, ritocchi pelle limitati).
- In passato alcune funzioni sbloccabili guardando pubblicità o seguendo il profilo Instagram: le recensioni recenti dicono che non è più possibile.
- Pubblicità intrusive nella versione gratuita.

**A pagamento (Premium)**
- Rimodella (reshape) viso e corpo: spostato a Premium in un aggiornamento recente, causa principale delle 1★ US.
- Slim/dimagrire, muscoli, rimodella corpo nei video.
- Patch, rimozione IA di oggetti e persone, sostituzione sfondo.
- Acconciature, colore capelli, barba (prova virtuale).
- Makeup completo "un tocco", look IA.
- Prova vestiti, ricolora vestiti.
- 200+ filtri, filtri pelle speciali, crop/uncrop.
- In diversi casi anche il salvataggio della foto senza pagare ("non ti fa salvare neanche una foto prima dell'abbonamento").

## 3. UX

### Flusso principale (ricostruito da descrizione e recensioni)
1. **Onboarding**: schermate promozionali prima/dopo, poi paywall con prova gratuita di 7 giorni (pre-selezionata sul piano settimanale o annuale). Molte recensioni lamentano addebito immediato o confusione tra due abbonamenti.
2. **Schermata principale**: griglia della libreria foto (permesso Foto) più sezioni "Ritocca", "Video", "Look IA", galleria di esempi.
3. **Editor**: foto al centro, barra inferiore di categorie (Viso, Pelle, Occhi, Naso, Labbra, Corpo, Makeup, Capelli, Filtri, Rimuovi, Vestiti). Ogni strumento: rilevamento automatico del viso, cursore di intensità, pressione lunga per confronto prima/dopo, annulla/ripeti, applica. Strumenti manuali a pennello (Patch, rimodella con dito, sfoca) con gomma per correggere la maschera.
4. **Azione chiave**: rimodella (assottiglia viso/mascella, ingrandisci occhi, naso, labbra; corpo: vita, gambe, braccia) e leviga pelle. Poi Salva/Condividi, che spesso apre il paywall.
5. **Impostazioni**: gestione abbonamento, ripristina acquisti, contatti, privacy. Le recensioni dicono che disdire dall'app non è chiaro.

### Cosa amano
- Risultati "naturali" quando funziona; "la più fedele" per uso di lavoro.
- Tutto in un'app: viso, corpo, makeup, filtri.
- Facilità: un cursore per strumento, prima/dopo immediato.

### Cosa odiano (1-3★, 200 recensioni lette, Facelab IT/US + Facetune US)
- Tutto a pagamento: "Fake gratis — Tutto a pagamento" (1★ IT); "quasi tutto a pagamento quindi non puoi fare niente se non paghi" (2★ IT); "They monitor which tool you use the most and make it a premium feature" (1★ US).
- Funzioni spostate a Premium o rimosse dopo update: "Recently they changed the reshape tool to premium only, which was really the only reason anyone had the app anymore" (1★ US); "Why was the slim/thin feature removed???" (3★ US).
- Prova gratuita e addebiti: "Mi sono stati addebitati €22,99 immediatamente subito dopo aver accettato il periodo di prova" (1★ IT); "Charges you before your free days are over" (1★ US).
- Non riconosce viso o corpo: "L'app non rileva praticamente mai il viso e quando finalmente sembra funzionare, si blocca continuamente" (1★ IT); "Non riesce mai a rilevare il corpo in nessun modo nemmeno a figura intera" (3★ IT); corpo maschile riconosciuto come femminile (2★ IT).
- Crash e lavoro perso: "ogni volta che torno sull'app il lavoro che avevo..." (2★ IT); crash con più volti nella stessa foto (2★ IT).
- Risultati finti dopo gli update: "It looks so fake!!" (2★ US); muscoli "extremely fake".
- Acconciature IA che non rispettano l'attaccatura (1★ IT, 2★ US).
- Watermark sull'export e video lenti o distorti (Facetune, Facelab video).
- Critica etica: incoraggia standard corporei irreali e disturbi alimentari ("molte ragazzine posso volere nella realtà quei fisici e finiscono per avere un DCA", 1★ IT; "Horrifically misogynistic", 1★ US).

Occasione per Sbu: tutto gratis, nessuna prova trappola, salvataggio non distruttivo con ripresa del lavoro, rilevamento più volti con scelta del volto, un'impostazione "naturale" di default.

## 4. Fattibilità iOS senza server

| Funzione | Framework Apple | Note |
|---|---|---|
| Scelta foto | PhotosUI `PhotosPicker` | Nessun permesso per leggere |
| Salvataggio | PhotoKit `PHPhotoLibrary` (solo aggiunta, `NSPhotoLibraryAddUsageDescription`) | Opzionale `PHContentEditingOutput` per modifiche reversibili nell'app Foto |
| Rilevamento viso e punti (occhi, naso, labbra, mascella, sopracciglia) | Vision `VNDetectFaceLandmarksRequest` (76 punti), `VNDetectFaceRectanglesRequest` | Più volti: elenco e scelta del volto |
| Rilevamento corpo | Vision `VNDetectHumanBodyPoseRequest` (2D) | iOS 17 ha anche `VNDetectHumanBodyPose3DRequest` |
| Rimodella viso/corpo (warp) | Core Image con kernel `CIWarpKernel` in Metal, oppure mesh warp in Metal | Liquify a dito e warp guidato dai punti. Lavoro principale |
| Leviga pelle | Core Image: separazione di frequenze (blur + high pass), maschera pelle da landmark | |
| Brufoli, macchie, Patch | Inpainting a patch scritto in Metal (PatchMatch), maschera a pennello | Nessuna API Apple di inpainting su iOS 17 |
| Sbianca denti, occhi | Maschere dai landmark + `CIColorControls`/regolazione tono | |
| Colore occhi, labbra, makeup base | Maschere dai landmark + metodi di fusione Core Image | Rossetto, blush, contour, eyeliner come livelli |
| Colore capelli | `VNGeneratePersonSegmentationRequest` (non separa i capelli); matte semantiche capelli/pelle/denti di AVFoundation (`AVSemanticSegmentationMatte`) presenti solo nelle foto Ritratto | Recolor solo con matte disponibile, altrimenti pennello |
| Sfoca sfondo | `VNGeneratePersonSegmentationRequest`, `VNGenerateForegroundInstanceMaskRequest` (iOS 17) | |
| Filtri | Core Image, `CIColorCubeWithColorSpace` con LUT nostre | LUT create da noi |
| Video (rimodella in video) | AVFoundation `AVVideoComposition` con handler Core Image, Vision per frame | Da rimandare dopo la 1.0 |

Entitlement ed estensioni: nessun entitlement speciale. Estensione opzionale **Photo Editing Extension** (`PHContentEditingController`) per ritoccare dall'app Foto: buon elemento distintivo. Niente HealthKit, niente rete.

**Non copiabile**
- Acconciature, barba, prova vestiti, look IA, headshot IA, rimozione e sostituzione grandi oggetti/sfondi generativi: modelli generativi cloud. Alternativa: niente, oppure un piccolo modello Core ML di inpainting incluso (pesante, qualità incerta). Per la 1.0: saltare.
- 200+ filtri e palette makeup di marca: si creano LUT e palette proprie.
- Contenuti di esempio e foto promozionali: proprie o nessuna.

## 5. Rischi App Review

- **4.3 (spam), il rischio più alto.** La categoria "editor viso e corpo" è saturata (Facelab, Facetune, Bodytune, Peachy, Everlook, PrettyUp, Body Editor, Tune Face...). Dopo i rifiuti 4.3 del 14/10, una 1.0 che è "un altro face editor" è esposta a 4.3(b). Serve un taglio diverso e dichiarato: tutto locale, nessuna IA cloud, modifiche reversibili, estensione in Foto, impostazione "naturale".
- **4.3 verso altre Sbu**: nessuna sovrapposizione con le app esistenti (Clean pulisce la libreria, Scanner/Docs documenti). Sovrapposizione forte con nicchie in coda: **Gomma** (rimuovi oggetti), **Scontorno** (sfondo), **Filtri** (preset). Ritocco deve escludere gomma oggetti, scontorno e preset estetici, o queste nicchie vanno scartate (ADR-0004).
- **5.1.1 / 5.1.2(vi) privacy e dati del viso**: i dati da Vision sui volti non vanno usati per altro né lasciare il dispositivo; dichiararlo nella privacy policy e nella nota per la revisione. Etichetta privacy: nessun dato raccolto.
- **Salute e immagine corporea**: niente promesse di "dimagrire" o claim corporei nei metadati; screenshot non sessualizzati; classificazione d'età prudente (1.1 e 4 del questionario). Le recensioni mostrano critica etica reale.
- **4.2 funzionalità minima**: superata se il ritocco è vero (più strumenti, maschere, warp).
- **5.2.5 / 5.2.1 marchi**: nessun riferimento a Facelab/Facetune né a "Foto" di Apple nei metadati; l'estensione si descrive senza usare marchi Apple in modo improprio.
- **2.5.x**: solo API pubbliche; l'estensione di modifica foto deve rispettare `PHAdjustmentData` (2.5.1); prestazioni su iPhone vecchi (le recensioni citano crash): testare su device a 4 GB di RAM.
- **2.3.7**: nessun nome di concorrenti nelle parole chiave.

**La cosa sola**: ritoccare un ritratto in modo naturale, sul dispositivo. La cifra della schermata è l'intensità del ritocco (es. "30" con il punto fermo), in `ink`.

## 6. Stima

- 1.0 pari al leader senza le funzioni IA cloud (pelle, patch, denti/occhi, rimodella viso e corpo con liquify, makeup base, colore capelli da matte, sfoca sfondo, filtri propri, più volti, prima/dopo, annulla, salvataggio reversibile, estensione Foto): **14-18 giorni-agente**. Il grosso è il warp in Metal, l'inpainting e la qualità "naturale" (serve molto test a occhio). Video escluso (+6-8 giorni).
- Complessità: **L**.
- Abbonamento stupido da pagare: **4/5**. 4,99 $/settimana per filtri e warp che girano sul telefono; il voto non è 5 perché parte del valore percepito (capelli, vestiti, look IA) è generativo cloud.
- Fattibilità: **3/5**. Ritocco base e rimodella si fanno con Vision, Core Image e Metal, ma la parità piena è impossibile senza IA generativa, e la qualità "naturale" più il rischio 4.3 in una categoria saturata pesano.
