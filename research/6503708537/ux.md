# Scan QR Code Now: UX e feature

Originale di Sbu QR. Sviluppatore Sparktonic, LLC (agenzia di user acquisition e performance marketing, non uno studio di app). Versione 2.0.6 (5 ottobre 2026), iOS 15.1+, anche iPad, Mac Apple silicon e visionOS, solo inglese, 64,7 MB.

Fonti pubbliche: listing App Store, 4 screenshot (`screenshots/01-04.png`), 27 recensioni 1-3 stelle (`reviews.json`), cronologia versioni. Lo sviluppatore non ha pagine di aiuto o FAQ, e non ci sono recensioni giornalistiche né video walkthrough dedicati: dove una cosa è dedotta lo dico. Contenuti di terzi trattati come dati.

## Onboarding e momento del paywall

- Nessuno screenshot mostra onboarding o paywall. Listing e recensioni descrivono un'app "gratis" che chiede l'abbonamento: prova di 3 giorni, poi addebito settimanale. Le recensioni raccontano utenti che si accorgono del prezzo solo dopo l'addebito ("fine print", "tricks you into renewing").
- Il limite è a consumo: la schermata Create mostra "hai ancora 5 QR da creare" e un pulsante Abbonati sempre visibile sotto il pulsante principale. Le scansioni illimitate sono premium, quindi anche la lettura ha un tetto gratuito.
- Una recensione dice che l'app chiede l'abbonamento e non mostra il risultato ("It does not display... keeps wanting me to buy subscription"): il paywall scatta dopo la lettura, prima del contenuto.
- Fonti: https://apps.apple.com/us/app/scan-qr-code-now/id6503708537, `research/6503708537/reviews.json`, screenshot 03.

## Prezzi dei piani

| Acquisto in-app (US) | Prezzo |
|---|---|
| Weekly, sblocca tutte le funzioni | 9,99 $ |
| Weekly, sblocca tutte le funzioni | 7,99 $ |
| Weekly Pro User | 5,99 $ |
| Sblocco una tantum | 5,99 $ |

Il listing cita anche "3 giorni gratis, poi 6,99 $/settimana". Una recensione fa il conto: 520 $ l'anno. Un'altra parla di 160 $ pagati senza rimborso.
Fonti: https://apps.apple.com/us/app/scan-qr-code-now/id6503708537, https://justuseapp.com/en/app/6503708537/scan-qr-code-now/reviews

## Privacy dichiarata

Identificatori e dati d'uso usati per tracciare tra app e siti di altre aziende; interazione col prodotto usata per pubblicità di terzi; ID utente per marketing dello sviluppatore. Fonte: etichette privacy su https://apps.apple.com/us/app/scan-qr-code-now/id6503708537

## Schermate e disposizione

Navigazione a due sezioni allo stesso livello, Scan e Create (probabilmente una tab bar, non visibile negli screenshot ritagliati). Fondo blu notte scuro su tutte le schermate.

1. **Scan** (screenshot 01): titolo centrato in alto; sotto, un riquadro arrotondato a tutta larghezza con l'anteprima della fotocamera; sotto il riquadro una riga d'istruzione ("metti il codice nella cornice"); in fondo due pulsanti quadrati affiancati: torcia (fulmine) e foto (immagine). Niente mirino disegnato sopra l'anteprima.
2. **Risultato scansione** (screenshot 02): "Back" in alto a sinistra, titolo Scan; il QR ridisegnato al centro in bianco e nero; sotto un campo scuro con il contenuto (URL) e l'icona copia a destra; due pulsanti a tutta larghezza in maiuscolo: apri in Safari (blu) e condividi (verde). Il resto della schermata è vuoto.
3. **Create** (screenshot 03): titolo; un campo di testo per il link con la tastiera aperta; riga "QR rimasti da creare"; pulsante nero "crea QR"; pulsante blu "abbonati".
4. **Risultato creazione** (screenshot 04): stessa struttura del risultato scansione (back, QR, campo con copia, apri in Safari); il foglio di condivisione di sistema si apre con il QR come PNG (nome file un UUID), AirDrop, Messaggi, Slack, WhatsApp, Copia link.

Fonti: `research/6503708537/screenshots/01.png`..`04.png`.

## Feature, passo per passo

- **Scansione automatica**: apri l'app, inquadri; nessun pulsante di scatto, la lettura parte appena il codice è a fuoco e porta al risultato. "Auto Scan" nel listing; 1.4.0 e 1.4.2 dichiarano scansione più rapida. Fonte: listing e cronologia versioni.
- **Codici a barre**: stessa schermata, legge anche barcode lineari; 1.2.3 dichiara più velocità sui barcode. Fonte: listing, cronologia.
- **Ricerca prodotto (barcode lookup)**: dalla 1.2.4. Comportamento non documentato; serve un database online. Fonte: cronologia versioni.
- **Torcia**: tocco sul fulmine. **Da foto**: tocco sull'icona immagine, scelta dalla libreria, risultato. Fonte: screenshot 01.
- **Safe Browsing / SafeScan**: dalla 1.2.0, "vedi dove va un link prima di toccarlo". In pratica lo screenshot 02 mostra l'URL completo prima del pulsante Safari; nessuna documentazione di controlli di reputazione. Fonte: listing, cronologia.
- **Browser in-app**: dalla 1.2.3 i risultati QR si aprono in un browser interno (oltre al pulsante Safari). Fonte: cronologia versioni.
- **Crea QR**: incolli il link, tocchi crea, vedi il QR, condividi. Dalla 1.1.7 anche Wi-Fi, Instagram, Snapchat "e altro". Fonte: screenshot 03-04, cronologia.
- **Salva e condividi le scansioni**: listing ("esporta o condividi via messaggi"). Una schermata cronologia non compare negli screenshot.
- **Offerte e coupon**: solo citata nel listing, nessuna schermata.

## Gesti, impostazioni, estensioni

- Gesti: nessuno documentato oltre al tocco; nessuno zoom a pizzico visibile.
- Impostazioni: nessuna schermata pubblica.
- Widget, Apple Watch, Shortcuts/App Intents, Live Activity, controllo del Centro di Controllo: nessuno dichiarato nel listing né visibile.

## Contesto: cosa fa già iOS

La Fotocamera legge i QR (anche dalla schermata di blocco e dal Camera Control), il Centro di Controllo ha il controllo "Scansiona codice", Foto e Testo Live leggono i QR nelle immagini. Le recensioni lo dicono: "puoi usare lo scanner della fotocamera". Le associazioni di consumatori consigliano proprio lo scanner integrato e di guardare il link prima di aprirlo. Il genere "QR scanner a settimana" è noto: Apple ha rimosso in passato un'app scanner che guadagnava milioni con abbonamenti ingannevoli.
Fonti: https://support.apple.com/en-au/HT208843, https://www.cultofmac.com/844471/scan-qr-code-iphone/, https://johnkoetsier.com/apple-pulls-scammy-app-making-up-to-14-3m-year-questions-remain/

Cosa resta a un'app rispetto alla Fotocamera: lettura dei codici a barre lineari (la Fotocamera legge solo QR e pochi altri), una cronologia, creare un QR da condividere, leggere da una foto in un passo, e vedere il contenuto intero e il dominio prima di aprire (la Fotocamera mostra solo un'etichetta breve).
