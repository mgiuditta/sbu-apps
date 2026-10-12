# Sbu Remote: sintesi della ricerca

Originale: **TV Remote - Universal Control** (EVOLLY.APP, id 1539090879). Gratis da scaricare, ma il telecomando smette di funzionare dopo pochi tocchi senza abbonamento (settimanale 4,99-6,99 $, mensile 8,99 $, annuale 19,99-39,99 $, a vita 44,99 $). Pubblicità e tracking dichiarati nell'etichetta privacy.

Dettagli: `research/1539090879/spec.json` (spec), `ux.md` (schermate e flussi), `protocols.md` (protocolli per marca), `reviews.json` (16 recensioni 1-3 stelle), `screenshots/`.

**Vincolo fisico**: l'iPhone non ha emettitore IR. Sbu Remote può funzionare solo via Wi-Fi verso la TV dell'utente, quindi ogni funzione principale richiede connessioni in rete locale. È in tensione con la regola "nessuna chiamata di rete" di CLAUDE.md: serve un'eccezione scritta (ADR) prima di tutto il resto.

## Matrice feature

| Feature | A pagamento nell'originale? | Sbu | Framework iOS (iOS 17+) | Conflitto con CLAUDE.md? |
|---|---|---|---|---|
| Ricerca TV sulla Wi-Fi | No (ma inutile senza i tasti) | core | `Network` (`NWBrowser` Bonjour, `NWConnection` UDP per SSDP), entitlement multicast | Sì: rete locale, serve l'ADR |
| Inserimento IP manuale | Non visto | core | `Network` | Come sopra |
| Pairing (prompt, PIN, token) | No | core | `URLSession`, `NWProtocolWebSocket`, `Security` (certificato client), Keychain | Come sopra; segreti nel Keychain sul dispositivo |
| Power, Home, Indietro, D-pad, OK | Sì, dopo 4-10 tocchi | core | SwiftUI, `sensoryFeedback` | Rete locale. Design: il telecomando non ha una "cifra" per il punto fermo |
| Touchpad (swipe = freccia, tap = OK) | Sì | core | SwiftUI `DragGesture`/`SpatialTapGesture` | Il touchpad deve stare su `surface`, niente campo scuro |
| Volume, mute, canale | Sì | core | SwiftUI | No |
| Tasti media (riavvolgi, play, avanti, replay, opzioni) | Sì | core | SwiftUI | No |
| Tastiera verso la TV | Sì | core | SwiftUI `TextField`, `@FocusState` | No |
| Ricerca vocale | Sì | nice | `Speech` (`SFSpeechRecognizer`, `requiresOnDeviceRecognition`), `AVAudioEngine` | Solo se il riconoscimento resta sul dispositivo (lingue supportate offline); permessi microfono e riconoscimento |
| Scorciatoie app (Channels) | Sì | core | SwiftUI `List`/`Grid` | Sì: i loghi delle app sono marchi e icone non SF; serve testo + SF Symbol |
| Scelta sorgente HDMI | Sì | nice | SwiftUI `Picker`/`List` | No |
| Accensione da standby (Wake-on-LAN) | Sì | nice | `Network` UDP broadcast, entitlement multicast | Rete locale |
| Più TV e cambio rapido | Non chiaro | nice | `Codable` + file/UserDefaults | No |
| Cast foto/video | Sì | nice | AirPlay di sistema: `AVRoutePickerView`, `AVPlayer`, `PhotosPicker` | AirPlay di sistema no; server DLNA locale sì (scartare) |
| Widget / controllo nel Centro di Controllo | Non esiste | nice | WidgetKit + App Intents (`Button(intent:)` iOS 17; `ControlWidget` solo iOS 18) | Il controllo nel Centro di Controllo richiede iOS 18: disponibile solo con `if #available` |
| Siri / Comandi rapidi ("abbassa il volume") | Non esiste | nice | App Intents | No |
| Mirroring schermo | Non esiste (solo cast) | skip | AirPlay di sistema già lo fa | Duplicherebbe il sistema |
| Fire TV | Dichiarata | skip | ADB o protocollo non documentato | Studiare l'app ufficiale = estrazione, vietata |
| Hisense VIDAA, Philips JointSpace | Dichiarate | skip | MQTT/TLS, HTTP Digest | I progetti noti usano segreti ricavati dalle app ufficiali: vietato |
| Pubblicità, abbonamento, prova | Sì | skip | - | Vietati |

## Problemi principali degli utenti (16 recensioni 1-3 stelle)

1. **Non funziona senza pagare** (9): dopo 4 tocchi il telecomando si ferma, nemmeno il volume.
2. **Prezzo e addebiti dopo la prova** (6): 19, 32,99, 44, 60 €; "costa meno comprare un telecomando".
3. **Pagato e non connette** (3).
4. **Non accende la TV** (1, LG): manca il Wake-on-LAN o non è spiegato.
5. **Il consenso sulla TV** (1): pairing non spiegato.
6. **Pubblicità e spam** (1).

Dalle recensioni US: connessione persa quando il telefono va in standby o si cambia app; PIN da reinserire dopo un cambio rete; pressione prolungata che non ripete; scorciatoie non personalizzabili; consumo batteria.

## Ordine consigliato delle marche

1. **Samsung Tizen**: prima in Italia e USA, WebSocket + token.
2. **LG webOS**: seconda in Italia, simile, con puntatore vero.
3. **Android TV / Google TV**: una implementazione per Sony recenti, TCL, Philips Android, Xiaomi, Hisense Google TV; la più costosa (TLS con certificato client, protobuf).
4. **Roku ECP**: banale ma conta solo negli USA, e i termini Roku vietano i comandi da app mobili di terzi: decisione aperta.
5. **Sony REST/IRCC** per le Bravia non Android.

Il primo protocollo lo decide la TV che Matteo ha in casa (serve hardware reale per il test).

## Cosa fa meglio Sbu

- **Funziona tutto, subito, gratis**: nessun limite di tocchi, nessuna prova che si trasforma in addebito. Risponde a 15 recensioni su 16.
- **Nessun tracking**: l'unico traffico è verso la propria TV in rete locale; niente pubblicità, niente analytics (l'originale traccia posizione e identificatori).
- **Pairing spiegato per marca**: cosa comparirà sulla TV, quale impostazione attivare ("Solo la prima volta" su Samsung, "LG Connect Apps", "Controllo tramite app mobili" su Roku).
- **Onestà sull'accensione**: Wake-on-LAN dove c'è, e una riga che dice quale impostazione della TV serve; niente pulsante che "a volte" accende.
- **Riconnessione automatica** al ritorno in primo piano (`scenePhase`), il problema più citato nelle recensioni US.
- **Pressione prolungata** che ripete (keydown/keyup, START_LONG/END_LONG).
- **Italiano**: l'originale non è localizzato in italiano.
- **Scorciatoie lette dalla TV** e scelte dall'utente, senza loghi.

## Decisioni aperte (ticket grilling)

- Eccezione alla regola "nessuna chiamata di rete" per la rete locale verso i propri dispositivi (ADR): bloccante.
- Quale TV ha Matteo per il primo test.
- Qual è "la cifra" del telecomando per il punto fermo (nome della TV? volume?), e come il touchpad resta su `surface`.
- Scorciatoie app senza loghi.
- Cast via AirPlay di sistema o niente.
- Roku: usare ECP nonostante i termini.
- Accento: nessun `accent-remote` in `Design/tokens.json`; va scelto e aggiunto.
- Entitlement multicast: richiederlo ad Apple o limitarsi a Bonjour + IP manuale.
