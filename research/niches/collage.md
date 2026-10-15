# Nicchia: Collage

Ricerca del 15/10/2026, solo dati pubblici: lookup API (IT e US), pagine App Store (sezione acquisti in-app), RSS recensioni IT e US. Nessun download o analisi dei binari.

## 1. Leader IT e USA

| | Leader IT | Top USA nella nicchia |
|---|---|---|
| App | Collage Foto: cornici e bordi (in US: "Layout - Photo Collage Maker") | PicCollage: Magic Photo Editor |
| id | 1472157401 (stesso id IT e US) | 448639966 |
| Sviluppatore | Fitness Labs SRL | Cardinal Blue Software, Inc |
| Prezzo | Gratis, iOS 15.6+, 200 MB, 4+ | Gratis, iOS 18.0+, 221 MB, 4+ |
| Versione | 5.4.6 del 25/09/2026 | 8.67.1 del 06/10/2026 |
| Valutazioni IT | 4,56 su 19.452 | 4,68 su 123.357 |
| Valutazioni US | 4,63 su 47.242 | 4,79 su 1.844.328 |
| Abbonamento | settimanale, mensile, annuale (dal testo legale). IAP in pagina IT: "Collage Maker Pro" 2,99 € e 4,99 € (settimanale, prova 7 giorni), "Photo Collage Maker" 4,99 €, "Collage Pro" / "Photo Collage Maker Pro" 29,99 € e 19,99 € (annuale), "Collage Maker Pro - Family Plan" 39,99 € | VIP mensile 4,99 € (US $4,99), VIP annuale 36,99-39,99 € (US $35,99), "Remove Watermark and Ads" $1,99, decine di pacchetti adesivi/sfondi 0,99-2,99 € |

Altri della nicchia (per contesto, ratings IT/US): Collageable 1085652055 (14.251 / 511.657), SCRL 1289057196 (6.614 / 124.774, caroselli continui), PhotoGrid 543577420 (2.031 / 118.054, collage video).

Il leader IT è il più forte in Italia nella classifica Grafica e design (#2 top grossing); in US domina PicCollage per volume, ma il modello (griglie + modelli + cornici dietro abbonamento) è lo stesso.

## 2. Cosa sta dietro il paywall

Leader IT (Layout), ricavato da descrizione e recensioni ("There are 2 free layouts you can choose from and the rest are usable if you do the free trial", "la maggior parte delle cose è vip"):

| Gratis | A pagamento (Pro) |
|---|---|
| Scelta foto dalla libreria | Oltre 500 modelli e cornici (tranne ~2 griglie) |
| 2 griglie base | Caroselli continui per Instagram |
| Esportazione base | Cornici pellicola, Polaroid, texture vintage |
| | Collage ibridi foto + video 4K |
| | Scontorno IA (rimozione sfondo, adesivi) |
| | Modelli "interfaccia social" (iMessage, Instagram, Google) |
| | Modelli stagionali settimanali, Riepilogo dell'anno, Top 9, striscia cabina fotografica, Prima e Dopo |
| | Esportazione ad alta risoluzione per la stampa, sfondi per il telefono |
| | "Unlimited edits" (il testo legale lega l'abbonamento al numero di modifiche) |

PicCollage: gratis collage libero, griglie, testo, adesivi base, ma con filigrana e pubblicità; VIP toglie filigrana, sblocca modelli animati, sfondi e adesivi d'artista, alcuni strumenti IA. Recensione 1★: "I can't save it download screenshot or anything ... I have to pay for a subscription".

## 3. UX

### Flusso principale (dalla descrizione, dagli screenshot pubblici e dalle recensioni)

1. **Onboarding**: 2-3 schermate promozionali, poi paywall con prova di 7 giorni in evidenza; chiusura poco visibile. Recensioni: "si viene praticamente obbligati a sottoscrivere l'abbonamento di prova", "Lo dice dopo che i 7 giorni sono iniziati".
2. **Schermata principale**: galleria di modelli per categoria (griglie, scrapbook, pellicola/Polaroid, caroselli, stagionali, social), quasi tutti con lucchetto. Pulsante per iniziare da foto.
3. **Azione chiave**: scegli N foto (o video) → l'app propone i layout con quel numero di celle → editor: trascina e scambia foto tra celle, pizzica per zoom dentro la cella, rifletti/ruota, spessore e raggio dei bordi, colore/texture di sfondo, formato (1:1, 4:5, 9:16 Storie/Reels/TikTok, Pinterest, stampa), testo e adesivi → Esporta / Condividi.
4. **Impostazioni**: abbonamento, ripristina acquisti, valuta l'app, termini. Mascotte pinguino che chiede la recensione a ogni collage.

### Cosa amano gli utenti (300 recensioni lette, 238 da 5★, IT+US)

- Varietà di cornici e layout, foto e video nella stessa pagina ("Best variety of options").
- Semplicità: "facile da usare", "trovi tutto ed è semplicissimo".
- Uso ricorrente per post e storie ("my go-to for making posts and stories for many years").
- Niente pubblicità ("zero pubblicità", "No advertisement at the moment").

### Cosa odiano (28 recensioni da 1-3★ su 300 lette)

- Paywall quasi totale: "Won't let you do anything without paying" (1★ US), "TROPPO DA PAGARE. Togliere il pagamento se no non si può fare nulla" (2★ IT), "troppo a pagamento" (3★ IT).
- Prezzo sproporzionato: "why on gods green earth would I pay $5-15 a month for a LAYOUT?" (1★ US), "Il costo è decisamente eccessivo" (1★ IT).
- Prova che si rinnova senza avviso: "non si viene avvisati dell'imminente rinnovo automatico ... impossibile ottenere un rimborso" (1★ IT), "Dice che è gratis ma non lo è veramente (solo 7 giorni)" (1★ IT).
- Richiesta di recensione ossessiva: "impertinente con le richieste di recensione" (1★ IT), "I don't wanna see the 'leave a review' every time I make a collage" (1★ US), "Constant nagging for a review" (2★ US).
- Era gratis prima: "Use to be free now they charge for it" (3★ US).
- Bug: formati Storie sbagliati ("the dimensions for story sizing wrong", 1★ US), "dopo l'ultimo aggiornamento non funziona più" (1★ IT), lentezza.
- Piano famiglia che funziona su un solo dispositivo, nessun supporto (1★ US).

Nota: l'alto numero di 5★ brevi coincide con il prompt di recensione insistente; la media va letta con cautela.

## 4. Fattibilità iOS senza server

| Funzione | Framework Apple | Note |
|---|---|---|
| Scelta foto e video | PhotosUI (`PhotosPicker`, selezione multipla, ordine di selezione) | Nessun permesso di lettura necessario |
| Salvataggio in Foto | PhotoKit (`PHPhotoLibrary.performChanges`, `PHAssetCreationRequest`) | Solo `NSPhotoLibraryAddUsageDescription`; in alternativa `ShareLink` |
| Griglie e layout | SwiftUI `Layout`/`Canvas`, modelli come dati (frazioni di rettangoli) | Libreria di layout nostra, generata da regole (righe/colonne, split ricorsivi): 100+ layout senza disegnarli a mano |
| Zoom/pan/rotazione nella cella | SwiftUI gesture (`MagnifyGesture`, `DragGesture`, `RotateGesture`) | |
| Bordi, raggio, sfondo colore | SwiftUI | Texture: solo generate (carta, grana) con Core Image, niente asset di terzi |
| Esportazione alta risoluzione | `ImageRenderer` o `UIGraphicsImageRenderer` a scala fissa (es. 3000-4000 px), JPEG/HEIC/PNG | Formati esatti: 1080x1080, 1080x1350, 1080x1920, 1000x1500, A4/10x15 a 300 dpi. Risolve il bug "story sizing wrong" |
| Carosello continuo | Render dell'immagine larga e taglio in N slice 4:5 | Si sovrappone alla nicchia "Griglia" (Panorama Scroll): decidere a quale app va |
| Cornice pellicola/Polaroid | SwiftUI forme + Core Image (grana, vignettatura, `CIPhotoEffect*`) | Disegnate da noi, nessuna texture con licenza |
| Testo | SwiftUI `Text` con font di sistema + font OFL inclusi | |
| Scontorno / adesivi | Vision `VNGenerateForegroundInstanceMaskRequest` (iOS 17, on-device) | Si sovrappone alla nicchia "Scontorno": tenerlo fuori o ridotto |
| Collage video | AVFoundation (`AVMutableComposition`, `AVMutableVideoComposition` con compositor custom o `AVVideoCompositionCoreAnimationTool`), `AVAssetExportSession` | La parte più costosa e più fragile (durate diverse, orientamento, audio) |
| Rilevamento soggetto per inquadrare | Vision `VNGenerateAttentionBasedSaliencyImageRequest`, `VNDetectFaceRectanglesRequest` | Centra automaticamente le facce nella cella |
| Striscia cabina, Prima e Dopo, Top 9 | Sono layout predefiniti | |
| Bozze salvate | SwiftData con riferimenti `PHAsset.localIdentifier` o copie delle immagini nel container | |

Entitlement ed estensioni: nessuno obbligatorio. Opzionale una **Share extension** ("Crea collage" dal foglio di condivisione di Foto con più immagini), che aggiunge un target ma è il flusso più naturale. Nessun HealthKit, rete, account.

Parti NON copiabili e alternativa on-device:

- Modelli stagionali settimanali, adesivi e sfondi d'artista (contenuti con licenza, PicCollage): sostituiti da layout generati e sfondi/texture procedurali; niente aggiornamenti settimanali di contenuti.
- Modelli "interfaccia social" (iMessage, Instagram, Google, Facebook): imitano interfacce e marchi di terzi, esclusi (5.2.x).
- Funzioni IA cloud di PicCollage (assistente collage, abbinamento font IA): sostituite da suggerimento di layout per numero/orientamento delle foto e saliency di Vision.
- "Riepilogo dell'anno" automatico: fattibile on-device con PhotoKit (lettura completa), ma richiede il permesso di accesso alla libreria; escluso dalla 1.0.

## 5. Rischi App Review

- **4.3 (spam), nicchia**: categoria satura, migliaia di app collage quasi identiche. Apple applica il 4.3(b) proprio a categorie come questa. Rischio alto, il più alto della scheda. Serve una cosa sola netta e riconoscibile, non "un altro collage maker".
- **4.3 verso le altre Sbu**: nessuna Sbu esistente compone foto (Scanner e Docs fanno documenti). Rischio interno solo se si costruiscono anche le nicchie "Scontorno" e "Griglia" (caroselli panoramici): tre app foto-editing dello stesso sviluppatore sono un segnale 4.3. Scegliere: Collage assorbe il carosello, Scontorno resta separata e Collage non scontorna.
- **4.2 (funzionalità minima)**: una sola griglia con esporta sarebbe troppo poco; la 1.0 deve avere libreria di layout ampia, editor con gesti, formati esatti e cornici.
- **5.1.1 privacy**: usare `PhotosPicker` (nessun permesso) e solo il permesso di aggiunta; niente accesso completo alla libreria nella 1.0. Nessun dato sanitario.
- **5.2.5 / 5.2.1 marchi**: niente "Instagram", "TikTok", "Reels", "Pinterest", "Polaroid" nel nome, sottotitolo e parole chiave; in app formati descritti per proporzione e uso ("Storia 9:16", "Post 4:5"). "Polaroid" è un marchio: usare "Istantanea".
- **2.5.x**: export video in background va gestito con `beginBackgroundTask` e nessuna API privata; rispettare i limiti di memoria con molte foto ad alta risoluzione (2.5.x/2.1 crash).
- **Regola Sbu "una cosa sola"**: Sbu Collage unisce più foto in un'immagine sola, pronta per il formato in cui la pubblichi o la stampi. La figura della schermata non è un numero ma il collage stesso: il quadrato punto fermo va a chiudere l'anteprima/il titolo dell'editor; da decidere con il design system (oggi la regola prevede `SbuStat` o `SbuToolField`, che qui non ci sono). Sfondo `surface` vale per l'interfaccia, non per il colore dello sfondo del collage scelto dall'utente: chiarire.

## 6. Stima

- **Giorni-agente per una 1.0 pari al leader (solo foto)**: 7-9. Libreria layout generata, editor con gesti, bordi/raggio/sfondo, formati esatti, cornici pellicola/istantanea, striscia cabina, Prima e Dopo, carosello continuo, testo, export e condivisione, bozze. **Con collage video**: +4-5 giorni (12-14 totali).
- **Complessità**: L con il video, M senza. Proposta: 1.0 solo foto, video nella 1.1.
- **Abbonamento stupido da pagare: 5/5**: fino a 15 $ al mese o 4,99 € a settimana per mettere foto in una griglia, con prova che si rinnova senza avviso; è la lamentela più frequente.
- **Fattibilità: 4/5**: tutto è on-device con SwiftUI, PhotosUI, Core Image e Vision; perdono punti il collage video (AVFoundation fragile) e l'assenza dei contenuti con licenza che fanno la varietà del leader.
