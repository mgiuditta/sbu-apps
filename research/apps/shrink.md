# Sbu Shrink: sintesi su Compress Videos & Resize Video

Originale: Compress Videos & Resize Video, New Marketing Lab (id 1473857051). Concorrente: Video Compressor + Resizer! (id 6742453124). Dati in `research/1473857051/` e `research/6742453124/` (`meta.json`, `screenshots/`, `spec.json`).

Ricerca del 16/10/2026. Due limiti: il feed RSS delle recensioni da 1 a 3 stelle era vuoto per tutte e due le app (US e IT), quindi non c'è `reviews.json`; `spec.json` l'ho scritto a mano dagli stessi dati pubblici perché `spec.py` non aveva la chiave API.

## Valutazioni (iTunes Lookup, 16/10/2026)

| App | US | IT | Versione |
|---|---|---|---|
| Compress Videos & Resize Video | 4,68 su 17.701 | 4,64 su 260 | 2.16, 28/04/2026 |
| Video Compressor + Resizer! | 0 voti | non in vendita | 2.0, 02/03/2026 |

Monetizzazione dell'originale (pagina US): Pro a 4,99 $ al mese, 5,99 $ all'anno, 14,99 $ a vita. Senza Pro ci sono pubblicità, un limite di video al giorno e un solo video alla volta. Nell'etichetta privacy dichiara posizione, ID dispositivo, dati pubblicitari e diagnostica usati per tracciare.

## Cosa fa davvero

Meno di quanto dice la mappa #472. L'originale ha due sole manopole, **frame rate** (slider, consiglia 24) e **dimensioni** (percentuale della risoluzione, consiglia 80%). Non lascia scegliere il codec, non ha target in MB né bitrate, non converte MOV→MP4 e non toglie l'audio. Legge H.264, HEVC, .mov, .mp4 e .m4v.

Il concorrente ha **dimensioni %** e **qualità %** (cioè il bitrate, consiglia 60%), più import da File, anteprima del risultato e condivisione.

## Schermate in ordine (originale)

1. **Scelta**: selezione multipla da Foto.
2. **Impostazioni di compressione**: slider frame rate, slider dimensioni, miniature con il peso di ognuna (+N), dimensione totale, bottone Comprimi.
3. **Compressione**: anello con la percentuale totale, "video 2 di 5", barra per file, Annulla.
4. **Fatto**: N video salvati in libreria; Prima, Dopo, Risparmio; "Elimina originali" o "Tieni N originali".

L'output finisce nel rullino e in un album dedicato ai video compressi.

## Funzioni compatibili (core)

- Selezione multipla da Foto (PhotosPicker); import da File come nel concorrente.
- Frame rate, dimensioni %, qualità %: AVAssetReader/Writer con VideoToolbox, H.264/HEVC.
- Dimensione stimata prima di comprimere: è la cifra con il punto fermo.
- Batch con progresso per file e Annulla.
- Prima, dopo e risparmio; salva in Foto e in un album; condividi.
- Elimina originali: `danger` con conferma, via `PHAssetChangeRequest.deleteAssets` (iOS chiede comunque conferma).

Le cose in più rispetto all'originale, cioè target in MB, scelta del codec, MOV→MP4 e togli audio, hanno senso: sono il varco rispetto a Comandi rapidi e Squish. Ma il layout segue l'originale, quindi vanno in una sezione "Avanzate" e non nella prima schermata.

## Da saltare

- Abbonamento Pro, limite giornaliero, pubblicità, tracking pubblicitario.
- Grafica marketing con gradienti e corone d'alloro con stelle.

## Alternative gratis

- **Comandi rapidi, azione "Codifica contenuto multimediale"** (Encode Media): gratis e di Apple, ma va costruito a mano e non ha target in MB, stima o batch con risparmio.
- **iMovie**: esporta a una risoluzione più bassa, un video alla volta.
- **Video Compressor - Squish** (id 6783970355): niente pubblicità né abbonamento, target in MB, sul dispositivo. Però la risoluzione piena costa 5,99 $ (Pro), dichiara analytics, non ha batch, richiede iOS 18 e ha 0 voti.
- **Video Compressor (Apps Places)** e **Video Compressor & Save Space**: abbonamento o pubblicità.
- Su AlternativeTo non c'è una voce per l'originale, e non ho trovato un'app iOS open source equivalente. Le open source (HandBrake, VCompress) sono per desktop o Android.

**Verdetto**: nessuna app gratis pulita rende inutile Sbu Shrink, quindi la mappa continua. Squish è la più vicina, ma ha un acquisto in-app e gli analytics.

## Fonti

- iTunes Lookup: `https://itunes.apple.com/lookup?id=1473857051&country=us|it`, `id=6742453124`, `id=6783970355,1605480360,6465894302`.
- Pagine App Store: https://apps.apple.com/us/app/compress-videos-resize-video/id1473857051, https://apps.apple.com/us/app/video-compressor-squish/id6783970355.
- Screenshot e descrizioni in `research/<id>/meta.json` (`Tools/discover.py --ids`).
- Ricerca web: AlternativeTo (voci per la compressione video) e guide a Comandi rapidi / Encode Media (compresto.app, cleverfiles.com). Nessun thread Reddit tra i risultati.
