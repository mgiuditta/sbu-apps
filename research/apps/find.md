# Sbu Find: sintesi su Find Air

Originale: Find Air - My Device Tracker (id 1507917112). Dati: `research/1507917112/` (`meta.json`, `screenshots/`, `reviews.json` con 74 recensioni da 1 a 3 stelle, `spec.json`, `ux.md`).

Find Air fa una cosa sola: scansiona i dispositivi Bluetooth vicini e mostra una percentuale di segnale che cresce quando ti avvicini. Quasi tutto il resto è abbonamento.

## Matrice feature

| Feature | A pagamento nell'originale? | Sbu | Framework iOS (iOS 17+) | Conflitto con CLAUDE.md? |
|---|---|---|---|---|
| Scansione BLE dei dispositivi vicini | Sì dopo la prima (cerca di nuovo è bloccato) | core | CoreBluetooth `CBCentralManager` | No. Serve `NSBluetoothAlwaysUsageDescription` IT/EN |
| Lista con nome, tipo e segnale | Parziale | core | SwiftUI `List .insetGrouped`, SF Symbols | No, se il segnale in lista è secondario (`inkMuted`) e niente anelli colorati |
| Misuratore caldo/freddo del singolo dispositivo | Sì | core | CoreBluetooth (RSSI con duplicati), filtro in un tipo puro | No. La cifra è una sola (`SbuStat`) chiusa dal punto fermo |
| Smoothing dell'RSSI e parole caldo/freddo | No (l'originale mostra il dato grezzo) | core | Tipo puro testato con Swift Testing | No |
| Suono e vibrazione di prossimità | Non presente | nice | Core Haptics / `UIImpactFeedbackGenerator`, AVFoundation con toni in bundle | No |
| Aiuto con limiti onesti | Libero | core | SwiftUI | No |
| Nascondi dispositivi senza nome, ordina per segnale | Non chiaro | nice | SwiftUI, `@AppStorage` | No |
| Rinomina e salva "i miei dispositivi" | Non visibile | nice | SwiftData | No, ma l'identità può cambiare (UUID ruotato): decisione aperta |
| Ultima posizione vista | Non presente in Find Air | nice | CoreLocation when-in-use, MapKit, salvataggio locale | Possibile; è una funzione in più rispetto all'originale: decisione aperta |
| Livello batteria per alcuni dispositivi | Probabilmente sì | nice | CoreBluetooth Battery Service 0x180F | No, ma vale solo per pochi dispositivi (non AirPods): decisione aperta |
| Avvisa se perso (separazione) | Sì | grilling | CoreBluetooth in background + `UNUserNotificationCenter` | Non viola regole, ma su iOS non è affidabile per cuffie qualsiasi: rischio di promessa falsa (linea guida 2.3) |
| Fai suonare il dispositivo perso | Non offerto | skip | Nessuna API per terzi | Promessa irrealizzabile |
| Trova dispositivi lontani | Non offerto (lo suggeriscono gli screenshot) | skip | Rete Dov'è non accessibile | Rete e server vietati |
| Abbonamento Air Apps One, paywall | — | skip | — | Vietato |
| Richiesta di valutazione, pubblicità, tracking | — | skip | — | Vietato |
| Grafica a gradiente, alloro con stelle, immagini prodotto | — | skip | — | Vietato (niente paywall look, niente icone custom) |

## Problemi principali degli utenti

1. **Non funziona senza pagare** (22 recensioni): paywall all'avvio, "cerca di nuovo" apre l'abbonamento, il dettaglio è bloccato.
2. **Prezzo e addebiti** (14): 9,99 $ a settimana, addebiti dopo la disdetta, prezzi non mostrati prima del download.
3. **Non trova o il numero non vuol dire nulla** (16): cuffie a 10 cm non trovate, percentuale che sale allontanandosi, AirPods sotto una coperta, metallo del furgone.
4. **Pressione continua** (8): richiesta di valutazione dopo pochi secondi, immagini generate, pubblicità, notifiche ogni 10 minuti.
5. **Screenshot ingannevoli** (3): fanno pensare a una localizzazione che l'app non fa.
6. **Dispositivi spenti o scarichi** (4): non si trovano, e l'app non lo dice.

## Cosa Sbu fa meglio

- Tutto gratis, scansioni illimitate, niente paywall né richieste di voto.
- Un segnale filtrato e detto a parole (freddo, tiepido, caldo, qui vicino) invece di una percentuale che salta. La cifra resta una, come vuole il design system.
- Suono e vibrazione che accelerano: cerchi sotto il divano senza guardare lo schermo, utile anche con VoiceOver.
- Limiti detti chiaro, nella schermata di aiuto e nella scheda App Store: custodia chiusa, batteria scarica, Bluetooth classico, quando usare Dov'è.
- Dati solo sul dispositivo; nessun tracking (l'originale dichiara identificatori e dati d'uso per tracciare).

## Cosa NON si può fare onestamente su iOS

- **Fare suonare AirPods, Apple Watch o altre cuffie.** Solo Dov'è di Apple può farlo per i prodotti Apple.
- **Vedere la rete Dov'è** o la posizione di un dispositivo lontano. Nessuna API pubblica; oltre la decina di metri Sbu Find non vede nulla.
- **Trovare AirPods nella custodia chiusa**, una cuffia scarica o spenta: non trasmettono.
- **Vedere cuffie solo Bluetooth classico** che non pubblicizzano in BLE.
- **Riconoscere sempre lo stesso dispositivo**: iOS dà un UUID per app e molti dispositivi ruotano l'indirizzo.
- **Avviso di separazione affidabile in background**: la scansione in background richiede UUID di servizio, ignora i duplicati ed è rallentata.
- **Distanza in metri precisa o direzione**: l'RSSI non è una distanza; la direzione richiede Ultra Wideband, che per AirPods e AirTag passa solo da Dov'è.
- **Batteria degli AirPods**: non leggibile da app di terzi.

## Confronto con Dov'è

Per un dispositivo Apple registrato, Dov'è è migliore: gratis, fa suonare, ultima posizione nota, rete globale, Trova nelle vicinanze con direzione su AirPods Pro 2 e AirTag. Sbu Find deve dirlo nell'aiuto e nella scheda. Il suo spazio è il resto: cuffie, tracker fitness, anelli, apparecchi acustici, altoparlanti di altre marche, quando sono accesi e vicini.
