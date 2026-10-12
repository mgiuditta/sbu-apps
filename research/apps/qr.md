# Sbu QR: sintesi su Scan QR Code Now

Originale: Scan QR Code Now (id 6503708537, Sparktonic LLC). Fonti: `research/6503708537/spec.json`, `ux.md`, `reviews.json` (27 recensioni 1-3 stelle), screenshot.

**Attenzione prima di tutto:** la suite ha già Sbu Scanner (QR e codici a barre, `accent-scanner`, app Expo, voce "In arrivo" sul sito). Per ADR-0004 e CONTEXT.md un Candidato già rifatto da un'altra App Sbu è Scartato. Prima di costruire bisogna decidere se Scan QR Code Now diventa l'Originale di Sbu Scanner (rifatta in Swift) o se Sbu QR è un'app distinta. Vedi il grilling relativo.

## Matrice feature

| Feature | A pagamento? | Sbu | Framework iOS (iOS 17+) | Conflitto con CLAUDE.md? |
|---|---|---|---|---|
| Scansione QR automatica dalla fotocamera | Sì oltre il tetto gratuito | core | VisionKit `DataScannerViewController` (A12+, `isSupported`/`isAvailable`), fallback `AVCaptureMetadataOutput` | Sì, di design: anteprima scura a tutto campo contro "ogni schermata su `surface`", e quale Cifra chiude il punto fermo |
| Codici a barre (EAN/UPC/Code 128...) | Sì (incluso nelle scansioni) | core | stessi, `recognizedDataTypes: .barcode(symbologies:)` | No |
| Torcia | No | core | `AVCaptureDevice.torchMode` | No |
| Lettura da foto | Sì (scansione) | core | `PhotosPicker` + Vision `VNDetectBarcodesRequest` | No |
| Risultato: contenuto, copia, condividi, apri | Sì (dopo il paywall) | core | `UIPasteboard`, `ShareLink`, `openURL` | No |
| Anteprima del dominio prima di aprire (SafeScan) | Non chiaro | core | `URL`/`URLComponents`, punycode, analisi locale | No se resta locale; reputazione online sarebbe rete |
| Browser in-app | No | skip | `SFSafariViewController` | Sì: i link si aprono in Safari |
| Azioni per tipo (Wi-Fi, contatto, telefono, mail, SMS, posizione, evento) | Non dichiarato | nice | `NEHotspotConfiguration` (entitlement), `CNContactViewController`, `EKEventEditViewController`, URL `tel:`/`mailto:`/`sms:`/`maps` | No |
| Crea QR da link o testo | Sì, 5 gratis poi abbonamento | core | CoreImage `CIFilter.qrCodeGenerator()` | No |
| Crea QR Wi-Fi e contatto | Sì | nice | CoreImage, `CNContactVCardSerialization` | No |
| Preset social (Instagram, Snapchat) | Sì | skip | link normale | No, ma è solo un link: coperto da "da link" |
| Condividi QR come PNG | Sì | core | `ShareLink`, `Transferable`, `ImageRenderer` | No |
| Cronologia e esportazione delle scansioni | Sì | core | SwiftData, `ShareLink` CSV/testo | No |
| Ricerca prodotto da codice a barre | Probabile | skip | — | Sì: rete. Grilling |
| Offerte e coupon | — | skip | — | Sì: server, affiliazione |
| Shortcuts / tasto Azione "Scansiona" | Non esiste | nice | App Intents `OpenIntent`, `AppShortcutsProvider` | No |
| Due sezioni Scan / Create | — | da decidere | `NavigationStack`, foglio | Sì: ADR-0001 niente tab bar |
| Abbonamento settimanale, prova 3 giorni, tetto scansioni | — | skip | — | Sì |
| Tracking e pubblicità di terzi | — | skip | — | Sì |

## Problemi principali degli utenti

1. Addebiti settimanali scoperti tardi (7 recensioni): 9,99 $ a settimana, "520 $ l'anno", rimborso negato.
2. "Non è gratis" e paywall prima del risultato (4).
3. Prezzo assurdo per una funzione di base (3), "per leggere una scatola di cereali".
4. La Fotocamera dell'iPhone lo fa già (3), e un utente non riesce più a leggere QR dalla fotocamera dopo l'installazione.
5. Sensazione di truffa o app installata senza volerlo (5).
6. Non funziona / istruzioni scarse (3).

Nessuna recensione critica la funzione in sé: chi ci arriva la trova adeguata. Il problema è solo il modello di vendita.

## Cosa Sbu fa meglio

- Tutto gratis e senza tetto: scansioni e QR creati illimitati, nessun contatore "te ne restano 5".
- Il contenuto si vede subito, sempre: niente paywall tra lettura e risultato.
- Più della Fotocamera di iOS: codici a barre dei prodotti, contenuto intero e dominio evidenziato prima di aprire, lettura da foto in un tocco, cronologia, creazione e condivisione di QR (link, testo, Wi-Fi, contatto).
- Sicurezza onesta: l'anteprima del link è locale (dominio, http senza lucchetto, punycode, link accorciati), nessun browser interno e nessun tracking; il link si apre in Safari solo quando lo scegli.
- Italiano e inglese (l'Originale è solo in inglese), Dynamic Type e VoiceOver.
- Una cosa sola: leggere un codice e dirti cosa c'è dentro.
