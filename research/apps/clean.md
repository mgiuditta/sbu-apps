# Sbu Clean: sintesi di Cleanup e Swipewipe

Originali: **Cleanup: Phone Storage Cleaner** (`research/1510944943/`, Codeway, 4,5 su 34 mila voti) e **Swipewipe: Photo Cleaner** (`research/1583884012/`, MWM, 4,6). Entrambe gratis da scaricare, con l'eliminazione dietro abbonamento settimanale. Fonti: `meta.json`, screenshot, `reviews.json` (69 e 22 recensioni 1-3 stelle), `spec.json`, `ux.md` di ciascuna.

Sbu Clean fa una cosa sola: libera spazio nella libreria Foto, una decisione alla volta, e chiude con lo spazio liberato.

## Matrice feature

| Feature | Originale | A pagamento? | Sbu | Framework iOS 17+ | Conflitto con CLAUDE.md? |
|---|---|---|---|---|---|
| Swipe per tenere / eliminare | entrambe | sì (limite giornaliero) | core | SwiftUI `DragGesture`, PhotoKit `PHAsset`, `PHImageManager` | no |
| Timeline mese per mese, Recenti, Casuale | Swipewipe | sì | core | `PHFetchOptions` con predicate su `creationDate` | righe colorate dell'Originale: sì, si usa `List .insetGrouped` |
| Tocco indietro, pressione lunga per i metadati | Swipewipe | sì | core | `PHAsset`, `PHAssetResource` | il nome del luogo richiederebbe `CLGeocoder` (rete): si mostra senza |
| Cestino con revisione e conferma | entrambe | sì | core | `PHAssetChangeRequest.deleteAssets` (dialogo di sistema), `SbuButton(kind: .destructive)` | no |
| Segnalibri / da decidere dopo | Swipewipe | sì | core | stato locale (identificatori) | no |
| Lista da tenere (mai più proposti) | Cleanup | sì | nice | stato locale | no |
| Duplicati | Cleanup | sì | core | Vision `VNGenerateImageFeaturePrintRequest` (soglia stretta) | no |
| Simili con foto migliore suggerita | Cleanup | sì | core | Vision feature print + `VNDetectFaceCaptureQualityRequest`, `isFavorite`, `hasAdjustments` | preselezione automatica: decisione aperta |
| Screenshot e registrazioni schermo | Cleanup | sì | core | `mediaSubtypes .photoScreenshot`, smart album | no |
| Video ordinati per dimensione | Cleanup | sì | core | `PHAssetResource` (`fileSize`), `AVPlayer` | no |
| Live Photo in foto statica | Cleanup | sì | nice | `PHAssetCreationRequest` + eliminazione originale | no, ma perde la parte video: conferma |
| Compressione video | Cleanup | sì | nice | `AVAssetExportSession` | no |
| Spazio liberato e statistiche | entrambe | no | core | `ByteCountFormatStyle`, `URLResourceValues` capacità volume | coriandoli, "ore guadagnate": sì, fuori |
| Accadde oggi (coda per data) | Swipewipe | sì | nice | PhotoKit, predicate per giorno/mese | serie giornaliera: gamification, da decidere |
| Album uno per volta | Swipewipe | sì | nice | `PHAssetCollection` | no |
| Widget spazio libero | Cleanup | no | nice | WidgetKit | widget batteria: fuori dalla cosa sola |
| Widget Accadde oggi | Swipewipe | no | skip | WidgetKit | non pulizia |
| Foto delle chat (WhatsApp ecc.) | Cleanup | sì | grilling | solo euristiche (EXIF assente, album con nome app) | risultati inaffidabili |
| Unire contatti duplicati | Cleanup | sì | grilling | Contacts (`CNContactStore`, `CNSaveRequest`) | fuori dalla cosa sola, rischio perdita dati |
| Pulizia calendario (eventi vecchi) | nessuna | – | grilling | EventKit | fuori dalla cosa sola |
| Pulizia email e annulla iscrizione | Cleanup | sì | skip | – | sì: account e rete |
| Pulizia iCloud | Cleanup (claim) | sì | skip | – | sì: rete; iCloud Foto segue la libreria da solo |
| Mappa ricordi, Supercut, miglioramento IA | Swipewipe | sì | skip | – | sì: non pulizia, IA su server |
| Temi, trofei, Wrapped, serie | Swipewipe | sì | skip/grilling | – | sì: design system e una cosa sola |
| Abbonamento, prova, limite giornaliero, pubblicità | entrambe | – | skip | – | sì: niente abbonamenti né pubblicità |
| Richiesta di valutazione dopo l'eliminazione | Cleanup | – | skip | – | non è una funzione per l'utente |

## Problemi principali degli utenti

1. **"Gratis" che non lo è** (Cleanup 42 su 69, Swipewipe 9 su 22): si scarica, si fa tutto il lavoro di scelta, e l'eliminazione è bloccata. Un utente scopre il paywall dopo 30 minuti di swipe.
2. **Prova addebitata subito o rinnovo non chiaro** (Cleanup 10, Swipewipe 2): 7-13 EUR a settimana, carta chiesta per la prova.
3. **Limiti assurdi nel gratuito** (Cleanup 4, Swipewipe 5): 5 foto al giorno, oppure 7 foto poi 8 ore di attesa, oppure un annuncio che non parte.
4. **Si blocca o non si apre** (Cleanup 5 su iOS 27, Swipewipe 4).
5. **Eliminazioni sbagliate e progressi persi** (Cleanup 3: contatti, email, cartella Nascosti; Swipewipe 3: mesi azzerati dopo un aggiornamento, foto già viste che riappaiono, video che non partono ed eliminati alla cieca).
6. **Spazio che non torna** (Cleanup 2): gli utenti non sanno che le foto restano 30 giorni in "Eliminati di recente".

## Cosa Sbu fa meglio

- **Tutto gratis, per sempre, senza limiti**: nessun abbonamento, nessuna prova, nessuna carta, nessun annuncio. È il dolore numero uno di entrambe.
- **Solo foto, sul dispositivo**: niente email, niente account, niente rete. Contatti e calendario solo se la decisione lo conferma.
- **Il cestino è onesto**: revisione prima, `danger` e conferma, e dopo l'eliminazione dice chiaramente che le foto restano 30 giorni in "Eliminati di recente" e che lo spazio torna quando lo svuoti.
- **Progressi che non si perdono**: decisioni e avanzamento per mese salvati in modo stabile (identificatori PhotoKit), con test di migrazione.
- **Video che si vedono**: ogni video si riproduce nella carta prima di decidere.
- **Nessuna preselezione aggressiva**: la foto migliore è un suggerimento; cosa si preseleziona è una decisione aperta.
- **Una cifra**: lo spazio liberabile, poi lo spazio liberato, chiuso dal punto fermo. Niente coriandoli né "ore guadagnate".
- **Accessibile**: lo swipe ha sempre i pulsanti equivalenti (Tieni, Elimina, Indietro) e azioni VoiceOver.
