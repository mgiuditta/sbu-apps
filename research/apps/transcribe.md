# Sbu Transcribe: sintesi su Otter e Summary

> In entrambi gli originali la funzione principale, trascrivere, è a pagamento: la regola "copiamo solo app la cui funzione principale è a pagamento" è rispettata.
> Otter dà 300 minuti al mese con un tetto di 30 minuti a conversazione e 3 import in tutto; velocità di riproduzione, esportazione pdf/docx/srt e salto dei silenzi sono Pro (16,99 USD/mese). Summary mette tutto dietro una prova di 3 giorni che diventa 5,99-8,99 USD a settimana.
> Entrambi trascrivono e riassumono sui server, con account obbligatorio. Sbu Transcribe trascrive sul dispositivo con il framework Speech: nessun account, nessun minuto contato, l'audio non lascia l'iPhone.

Fonti: `research/1276437113/` (Otter) e `research/6670175056/` (Summary): `meta.json`, screenshot, `reviews.json`, `spec.json`, `ux.md`.

## Matrice delle feature

| Feature | Originale | A pagamento? | Sbu | Framework iOS (iOS 17+) | Conflitto con CLAUDE.md? |
|---|---|---|---|---|---|
| Registrazione con un tocco, pausa e ripresa | entrambi | Otter: tetto 30 min gratis; Summary: sì | core | AVAudioSession `.record`/`.playAndRecord`, AVAudioRecorder (m4a AAC) o AVAudioEngine | no; permesso microfono con stringa IT/EN |
| Registrazione in background e a schermo bloccato | entrambi | come sopra | core | `UIBackgroundModes` audio, gestione interruzioni (`AVAudioSession.interruptionNotification`), skill `background-execution` | no |
| Durata illimitata | Summary (Otter: 30/90 min/4 h per piano) | sì | core | file su disco; trascrizione a blocchi su iOS 17 | no |
| Trascrizione dal vivo durante la registrazione | entrambi (Otter solo online) | sì | core | SFSpeechRecognizer + `SFSpeechAudioBufferRecognitionRequest`, `requiresOnDeviceRecognition = true`, `addsPunctuation`; richieste ricominciate a blocchi per il limite di durata della singola richiesta | no |
| Trascrizione con SpeechAnalyzer / SpeechTranscriber | n/d (tecnica) | n/d | da decidere | iOS 26 solo, `if #available(iOS 26, *)`, modelli scaricati con AssetInventory | **sì, possibile**: target iOS 17, due motori da mantenere |
| Punteggiatura, maiuscole, paragrafi | entrambi | sì | core | `addsPunctuation` (iOS 16+), pause tra i segmenti per i paragrafi | no |
| Lingua di trascrizione | Otter: 4-6 lingue, niente italiano; Summary: molte, auto-rilevamento | sì | core | `SFSpeechRecognizer.supportedLocales()` filtrate per `supportsOnDeviceRecognition`; nessun auto-rilevamento sul dispositivo: si sceglie, default lingua del telefono | no |
| Etichette dei parlanti | entrambi (automatiche) | sì | nice, manuali | nessuna API Apple di diarizzazione on-device (né iOS 17 né 26) | **sì, per l'automatico**: servirebbe un modello di terze parti, vietato in SbuKit/app |
| Archivio delle registrazioni (lista, rinomina, elimina) | entrambi | no | core | SwiftData, audio in Application Support; skill `swiftdata-pro` | no; emoji e card colorate degli originali vietate |
| Riproduzione sincronizzata: parola evidenziata, tocco per saltare, velocità | Otter | velocità sì (Pro) | core | AVAudioPlayer `rate`/`enableRate`, timestamp dei `SFTranscriptionSegment` | no |
| Salto dei silenzi | Otter | sì (Pro) | nice | buchi tra segmenti o livelli audio | no |
| Ricerca nel testo (globale e nella nota, con salto all'istante) | entrambi | no | core | `#Predicate` su SwiftData o filtro in memoria, `.searchable` | no |
| Modifica della trascrizione e copia completa | Otter | no | core | `TextEditor`/editing per paragrafo, `UIPasteboard` | no; recensioni: Otter non copia tutto in una volta |
| Vocabolario personalizzato | Otter | no | nice | `contextualStrings` sulla richiesta | no |
| Evidenziare un momento mentre registri | Otter | no | nice | timestamp salvato | no |
| Foto nella trascrizione | Otter | no | da decidere | PhotosPicker / fotocamera | possibile: una cosa sola |
| Import di file audio e video | entrambi | Otter: 3 in tutto gratis | core | `fileImporter` (UTType.audio, .movie), `SFSpeechURLRecognitionRequest` o lettura a blocchi con AVAssetReader | no |
| Esportazione testo, SRT, audio, PDF | entrambi | Otter: srt/pdf Pro; Summary: sì | core | `ShareLink`, `Transferable`, SRT da timestamp, PDF con `ImageRenderer` | no |
| Live Activity durante la registrazione | nessuno documentato | n/d | nice | ActivityKit (iOS 16.1+), widget extension; skill `widgets` | da verificare con il design system: niente secondo punto fermo |
| Widget e Comando rapido per registrare | entrambi | no | nice | WidgetKit + App Intents (`openAppWhenRun`); skill `app-intents` | no |
| Riassunto, azioni, schema | entrambi | sì | da decidere | Foundation Models (iOS 26, Apple Intelligence, contesto 4096 token) | **sì**: iOS 26 e solo dispositivi con Apple Intelligence; testi lunghi da spezzare |
| Chat IA sulle registrazioni | entrambi | sì | skip (da confermare) | Foundation Models | **sì**: fuori da "una cosa sola" |
| Traduzione | Summary | sì | da decidere | Translation (iOS 17.4 foglio, iOS 18 `TranslationSession`) | possibile: una cosa sola, download lingue |
| Cartelle, preferiti, cestino 30 giorni | entrambi | no | nice | SwiftData | colori ed emoji vietati |
| App Apple Watch | Summary | sì | da decidere | watchOS + WatchConnectivity | possibile: secondo prodotto |
| Bot che entra in Zoom/Meet/Teams, calendario | entrambi | sì | skip | n/d | **sì**: account, server, rete |
| Condivisione, commenti, canali, link pubblici | Otter | parziale | skip | n/d | **sì**: account, server |
| Link YouTube, registrazione chiamate | Summary | sì | skip | n/d | **sì**: rete, server, contenuti di terzi |
| Account, cloud, ATT, richiesta di valutazione e testimonianze in onboarding | entrambi | n/d | skip | n/d | **sì**: vietati |

## Problemi principali degli utenti

1. **Niente italiano** (Otter, 6 recensioni IT su 7): l'italiano viene trascritto come un inglese inventato, scoperto dopo aver pagato. Summary: trascrizioni italiane sbagliate, lingue miste confuse.
2. **Prezzo e paywall** (entrambi, 12+ recensioni): "si paga tutto", prova di 3 giorni poi 8,99 USD a settimana, limiti nascosti (100 minuti di chiamate, una lezione al giorno gratis), rinnovi inattesi.
3. **Registrazioni perse o troncate** (entrambi, 9+ recensioni): si ferma a metà, "nessun dato" a fine riunione, solo i primi 2 minuti, riunioni dal Watch perse.
4. **Dati in ostaggio** (Otter): a fine abbonamento non si scarica neanche l'audio.
5. **Riassunti corti o sbagliati** (Summary): mezza pagina per due ore di lezione.
6. **Parlanti non riconosciuti** (Summary).
7. **Account obbligatorio e avvio complicato** (entrambi).
8. **Copia e modifica scomode** (Otter): si copia un paragrafo alla volta.

## Cosa fa meglio Sbu

- Trascrive sul dispositivo, gratis e senza limiti di minuti, anche in aereo. L'audio non lascia l'iPhone: nessun account, nessun cloud, nessun dato in ostaggio.
- Italiano dal primo giorno, con tutte le lingue offline del sistema e la scelta esplicita della lingua (niente auto-rilevamento che sbaglia).
- Si apre su un pulsante: registra. Nessun onboarding, nessuna prova che si rinnova.
- Affidabilità prima di tutto: l'audio si scrive su disco mentre registri, sopravvive a interruzioni e chiusure, e la trascrizione si può rifare dal file.
- Esportazione libera in testo, SRT e audio; copia di tutta la trascrizione in un tocco.
- Una cifra sola sulla schermata di registrazione (la durata), chiusa dal punto fermo; la trascrizione sotto, in `inkMuted` mentre arriva.
