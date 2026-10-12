# Protocolli di controllo TV in rete locale

Riferimento per Sbu Remote. Fonti: documentazione pubblica dei produttori e progetti open source letti come descrizione del protocollo (nessun codice copiato; SbuKit e le app non dipendono da librerie terze). L'iPhone non ha emettitore IR: tutto passa dalla Wi-Fi, quindi la TV deve essere accesa o in standby di rete e sulla stessa sottorete del telefono.

Le note "da verificare" segnano dettagli presi da progetti open source e non da documentazione del produttore: vanno confermati sulla TV reale nel primo test.

## Requisiti iOS comuni (iOS 17+)

| Cosa | Perché | Note |
|---|---|---|
| `NSLocalNetworkUsageDescription` (Info.plist, IT/EN) | Qualsiasi connessione a un IP della rete locale fa comparire il prompt di sistema una volta sola | Senza la chiave l'accesso fallisce in silenzio. L'app non può chiedere il permesso in anticipo: il prompt parte al primo accesso. Se negato, va spiegato come riattivarlo in Impostazioni > Privacy > Rete locale. |
| `NSBonjourServices` | Ogni tipo di servizio Bonjour sfogliato con `NWBrowser` va dichiarato | Es. `_androidtvremote2._tcp` (da verificare), `_googlecast._tcp`, `_airplay._tcp`. |
| Entitlement `com.apple.developer.networking.multicast` | SSDP (M-SEARCH UDP su 239.255.255.250:1900) e Wake-on-LAN (broadcast UDP) | Va richiesto ad Apple con un modulo e motivato; i tempi di approvazione vanno messi in conto. Senza: si può solo Bonjour (mDNS gestito dal sistema) o IP manuale. |
| Framework | `Network` (`NWBrowser`, `NWConnection` UDP/TCP/TLS, `NWProtocolWebSocket`), `URLSession` per HTTP/REST, `Security`/`CryptoKit` per certificato client e chiave (Android TV), Keychain per token e PSK | Tutto Apple, nessuna dipendenza. Protobuf (Android TV) va serializzato a mano: il formato è semplice (varint + length-delimited) e i messaggi sono pochi. |
| ATS | Le TV parlano HTTP in chiaro o HTTPS con certificati autofirmati | Gli indirizzi locali sono esenti da ATS (`NSAllowsLocalNetworking`); i certificati autofirmati vanno accettati per host specifico, con pin del certificato visto al pairing. |

Fonte: Apple TN3179 Understanding local network privacy, https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy

## Quote di mercato indicative

- **Europa (Omdia 2025, sistemi operativi preinstallati sulle TV)**: Android/Google TV circa 32 %, Tizen (Samsung) meno di un quarto, webOS (LG) circa un quinto, VIDAA (Hisense) circa 14 % in crescita, Titan OS (Philips) circa 5 %, Fire TV, TiVo e Roku sotto. Dati specifici italiani non pubblici; in Italia Samsung e LG sono i marchi più venduti, TCL/Hisense crescono sulla fascia bassa. Fonti: https://www.smartworld.it/news/android-tv-calo-europa-piattaforme-smart-tv-2030.html, https://www.tuttoandroid.net/news/2026/04/29/google-tv-domina-mercato-smart-tv-europa-1151312/
- **USA (Parks Associates 2025-2026)**: tra i possessori di smart TV Tizen 34 %; contando anche stick e box Roku 28 %, Tizen 23 %, poi Fire TV, webOS, Vizio. Fonti: https://www.parksassociates.com/index.php/blogs/in-the-news/samsung-tizen-tops-smart-tv-os-usage-in-us-parks-associates-finds, https://www.mactech.com/2026/04/23/roku-os-28-and-samsungs-tizen-os-23-account-for-the-largest-share-of-tv-operating-system-usage-in-the-us/amp/

## Roku (ECP)

- **Discovery**: SSDP M-SEARCH con `ST: roku:ecp`; la risposta ha `Location: http://<ip>:8060/` e il seriale in `USN`. Serve l'entitlement multicast; in alternativa IP manuale.
- **Pairing**: nessuno. Dal Roku OS 14.1 l'impostazione Sistema > Impostazioni di sistema avanzate > Controllo tramite app mobili deve essere "Abilitato" per i comandi tasto.
- **Comandi**: HTTP POST `/keypress/<Key>` (anche `keydown`/`keyup` per la pressione prolungata): Home, Rev, Fwd, Play, Select, frecce, Back, InstantReplay, Info, Backspace, Search, Enter; sulle Roku TV anche VolumeUp/Down/Mute, PowerOff, ChannelUp/Down, InputTuner, InputHDMI1-4, InputAV1. Testo: `keypress/Lit_<carattere URL-encoded>`. App: `POST /launch/<channelId>` (deep link con `contentID`), elenco con `GET /query/apps`, icone con `/query/icon/<id>`. Info: `GET /query/device-info` (dal Roku OS 15 dice anche se supporta accensione e volume).
- **Accensione**: `keypress/PowerOn` sulle Roku TV con "avvio rapido" attivo (da verificare); niente WOL documentato.
- **Difficoltà**: bassa tecnicamente (HTTP in chiaro, nessuna auth). **Rischio**: la documentazione Roku dice che i comandi ECP non possono essere inviati da piattaforme di terze parti, ad esempio app mobili. Molte app in App Store lo fanno, ma è un vincolo dei termini da valutare (vedi grilling).
- **Mercato**: forte in USA, marginale in Italia (Roku TV quasi assenti, stick poco diffusi).
- **Fonte**: https://developer.roku.com/docs/developer-program/dev-tools/external-control-api.md

## Samsung (Tizen, 2016+)

- **Discovery**: SSDP (`ST: urn:samsung.com:device:RemoteControlReceiver:1` o DIAL `urn:dial-multiscreen-org:service:dial:1`, da verificare), poi `GET http://<ip>:8001/api/v2/` restituisce nome, modello, MAC, se supporta il token.
- **Pairing**: WebSocket `ws://<ip>:8001/api/v2/channels/samsung.remote.control?name=<base64 nome>` oppure, sui modelli recenti, `wss://<ip>:8002/...` (certificato autofirmato). Alla prima connessione la TV mostra "Consenti/Nega"; se consentito, risponde con un `token` da riusare nell'URL. Sulle TV nuove la richiesta si ripete a ogni connessione finché l'utente non imposta Gestione connessione dispositivi > Notifica di accesso > "Solo la prima volta".
- **Comandi**: messaggi JSON `ms.remote.control` con `DataOfCmd` = `KEY_*` (POWER, HOME, RETURN, UP/DOWN/LEFT/RIGHT, ENTER, VOLUP/VOLDOWN, MUTE, CHUP/CHDOWN, SOURCE, PLAY/PAUSE, FF/REWIND, numeri) e `Cmd` Click/Press/Release per la pressione prolungata; testo con `SendInputString` (base64) quando la tastiera della TV è aperta; app con `ed.apps.launch` (id app Tizen) ed elenco con `ed.installedApp.get`. Sorgente: solo il tasto SOURCE, non HDMI diretto.
- **Accensione**: Wake-on-LAN al MAC (broadcast UDP, entitlement multicast) se la TV ha la rete attiva in standby; su molti modelli il WebSocket resta raggiungibile in standby e `KEY_POWER` la riaccende.
- **Difficoltà**: media. Il WebSocket fallisce tra sottoreti/VLAN diverse. I modelli H/J (2014-2015, Orsay) usano un protocollo cifrato con pairing PIN: fuori dalla prima versione.
- **Mercato**: prima marca in Italia e negli USA tra le smart TV.
- **Fonti**: https://github.com/xchwarze/samsung-tv-ws-api, https://www.home-assistant.io/integrations/samsungtv/

## LG (webOS, SSAP)

- **Discovery**: SSDP con `ST: urn:lge-com:service:webos-second-screen:1` (da verificare); risposta con IP e nome.
- **Pairing**: WebSocket `ws://<ip>:3000` o `wss://<ip>:3001` (obbligatorio sui firmware recenti, certificato autofirmato). Messaggio `register` con un manifest dei permessi richiesti; la TV mostra un prompt; se accettato restituisce un `client-key` da salvare e rimandare nelle connessioni successive (niente prompt la seconda volta). Sulla TV deve essere attivo "LG Connect Apps" (o "Mobile App" sui vecchi modelli).
- **Comandi**: richieste `ssap://` (volume su/giù/imposta, mute, canale su/giù/elenco, `system.launcher/launch` e `listApps`, `tv/switchInput` e `listInputs`, media play/pause/stop/ff/rew, spegnimento, toast di notifica). Tasti di navigazione e puntatore passano da un secondo socket ottenuto con `getPointerInputSocket`: messaggi testuali `type:button name:UP`, `type:move dx dy` (vero puntatore del mouse LG), `type:click`, scroll. Testo con `insertText` quando la tastiera della TV è aperta.
- **Accensione**: solo Wake-on-LAN (Impostazioni > Generali > Accensione TV mobile > Accendi via Wi-Fi; sui 2025 Supporto > Impostazioni controllo IP > Wake on LAN). Funziona meglio via cavo. La recensione LG "senza telecomando non puoi accendere" viene da qui.
- **Difficoltà**: media. Il puntatore LG permette un touchpad "vero" (cursore libero), unico tra le marche.
- **Mercato**: seconda marca in Italia; terza/quarta negli USA.
- **Fonti**: https://github.com/supersaiyanmode/PyWebOSTV, https://www.home-assistant.io/integrations/webostv/

## Android TV / Google TV (Remote v2)

Copre Sony Bravia recenti, TCL, Philips Android, Xiaomi, Nvidia Shield, Chromecast con Google TV, Hisense non VIDAA.

- **Discovery**: Bonjour `_androidtvremote2._tcp` (da verificare) o `_googlecast._tcp`; Bonjour non richiede l'entitlement multicast, solo `NSBonjourServices`.
- **Pairing**: il client genera una coppia di chiavi RSA e un certificato X.509 autofirmato; apre TLS con certificato client sulla porta **6467**; la TV mostra un codice esadecimale di 6 caratteri; l'utente lo digita; il client invia un hash (SHA-256 su moduli/esponenti dei due certificati più il codice) in un messaggio protobuf. Accettato il pairing, la TV si fida di quel certificato: le connessioni successive vanno sulla porta **6466** con lo stesso certificato. Chiave privata e certificato nel Keychain.
- **Comandi**: messaggi protobuf (`RemoteMessage`): `remote_key_inject` con keycode Android (DPAD_*, DPAD_CENTER, BACK, HOME, VOLUME_*, MUTE, POWER, MEDIA_*, CHANNEL_*, numeri) e direzione SHORT/START_LONG/END_LONG; `remote_app_link_launch_request` con un deep link (`https://www.youtube.com`, `netflix://`); IME per il testo nel campo attivo; ping/pong di keep-alive da rispettare o la TV chiude. Voce: stream PCM 16 bit 8 kHz mono. Nessun elenco app installate: le scorciatoie vanno definite come deep link.
- **Accensione**: `KEYCODE_POWER` se il servizio resta raggiungibile in standby (dipende dal modello; TCL richiede l'opzione "servizio senza schermo"), altrimenti WOL.
- **Difficoltà**: alta (TLS con certificato client, protobuf a mano, keep-alive), ma copre più marche di qualsiasi altro protocollo. Netflix ignora alcuni tasti. Fire TV non ha questo servizio.
- **Mercato**: primo sistema in Europa (circa 32 %); importante in Italia via Sony, TCL, Philips, Xiaomi, Chromecast.
- **Fonti**: https://github.com/tronikos/androidtvremote2, https://www.home-assistant.io/integrations/androidtv_remote/, https://github.com/kud/androidtv-remote

## Sony Bravia (IRCC-IP e REST)

- **Discovery**: SSDP `ST: urn:schemas-sony-com:service:ScalarWebAPI:1` (da verificare). Le Bravia Android/Google rispondono anche al protocollo Android TV sopra.
- **Pairing**: due vie. **PSK**: l'utente attiva Impostazioni > Rete > Configurazione rete domestica > Controllo IP > Autenticazione "Normale e chiave precondivisa" e sceglie una chiave; il client la manda nell'header `X-Auth-PSK`. **PIN**: chiamata `accessControl/actRegister`, la TV mostra 4 cifre, il client le rimanda con Basic auth e riceve un cookie `auth` da riusare.
- **Comandi**: IRCC = SOAP POST su `/sony/IRCC` con un codice IR in base64 (elenco ottenuto da `system/getRemoteControllerInfo`); REST JSON-RPC su `/sony/system` (accensione/spegnimento con `setPowerStatus`), `/sony/audio` (volume), `/sony/avContent` (ingressi HDMI, canali), `/sony/appControl` (elenco e avvio app, testo con `setTextForm`).
- **Accensione**: `setPowerStatus` funziona se "Avvio remoto" è attivo.
- **Difficoltà**: bassa con PSK, media con PIN. Il servizio WebApiCore della TV a volte si blocca per circa 30 secondi.
- **Mercato**: piccolo ma fedele in Italia; marginale negli USA.
- **Fonti**: https://pro-bravia.sony.net/develop/integrate/ircc-ip/overview/index.html, https://www.home-assistant.io/integrations/braviatv/

## Philips (JointSpace)

- **Discovery**: nessun servizio dedicato documentato; i modelli Android rispondono a Bonjour/Cast; altrimenti IP manuale e prova delle porte 1925 (HTTP) e 1926 (HTTPS).
- **Pairing**: Android TV Philips (API 6): `POST /6/pair/request` con id e nome dispositivo, la TV mostra un PIN, `POST /6/pair/grant` con PIN e una firma HMAC; ne escono utente e password per l'autenticazione HTTP Digest su 1926. Modelli non Android (2015-): nessuna auth su 1925.
- **Comandi**: `POST /6/input/key` con chiavi (Standby, Home, Back, CursorUp/Down/Left/Right, Confirm, VolumeUp/Down, Mute, ChannelStepUp/Down, PlayPause, Source, Digit0-9, tasti colorati, Ambilight), `/6/audio/volume`, `/6/sources`, `/6/activities/launch` per le app Android.
- **Accensione**: anche dallo standby profondo sulle Android, con un'opzione da abilitare.
- **Difficoltà**: media. **Attenzione**: il pairing usa una chiave segreta fissa che i progetti open source hanno ricavato dall'app ufficiale Philips; usarla significherebbe dipendere da un segreto estratto da un'altra app, contro la regola di CLAUDE.md. Le Philips Android/Google TV si controllano comunque col protocollo Android TV. Le nuove Philips con Titan OS non usano JointSpace (da verificare).
- **Mercato**: Titan OS circa 5 % in Europa; Philips Android TV ancora diffuse in Italia.
- **Fonte**: https://github.com/eslavnov/pylips

## Marche secondarie

- **Fire TV (Amazon)**: protocollo del telecomando ufficiale non documentato; le alternative note sono ADB (debug da attivare nelle opzioni sviluppatore, porta 5555) o lo studio del traffico dell'app ufficiale. Il secondo è fuori regola (niente estrazione da altre app); ADB è tecnicamente possibile ma richiede all'utente di attivare il debug. Da escludere nella prima versione. Fonte: https://dev.to/trannghiajsc/how-can-i-use-remote-control-with-fire-tv-without-adb-in-ios-4hc1
- **Hisense / VIDAA**: controllo via MQTT su TLS (porta 36669 secondo progetti open source) con un certificato client che i progetti ricavano dall'app ufficiale: fuori regola. Le Hisense con Google TV passano da Android TV. Da escludere finché non c'è una via documentata.
- **Vizio (SmartCast)**: REST HTTPS sulla porta 7345 (9000 sui vecchi firmware), pairing con PIN a 4 cifre mostrato sulla TV, token per le chiamate; tasti come coppie codeset/code (da verificare). Solo USA, irrilevante in Italia.
- **Apple TV**: già coperta dal telecomando nel Centro di Controllo di iOS; il protocollo (Companion) non è documentato. Fuori scopo.

## Cast e mirroring

- **AirPlay**: `AVRoutePickerView` / `AVPlayer` con `allowsExternalPlayback`: foto e video vanno a TV con AirPlay 2 (Samsung 2018+, LG 2018+, Sony e Vizio recenti, Roku compatibili) senza alcun codice di rete dell'app. Opzione più leggera e sicura per la funzione "Casts".
- **DLNA/UPnP AV** o **Google Cast**: l'app dovrebbe esporre un piccolo server HTTP locale con il file; Google Cast su iOS richiede l'SDK Google (dipendenza terza, vietata). Da scartare.
- **Mirroring dello schermo**: su iOS solo via AirPlay di sistema (ReplayKit broadcast per altri protocolli è complesso e fragile). Fuori scopo.

## Ordine consigliato

1. **Samsung Tizen** (prima marca in Italia e USA, WebSocket + token, protocollo semplice).
2. **LG webOS** (seconda in Italia, simile a Samsung, aggiunge un vero puntatore).
3. **Android TV / Google TV** (una sola implementazione copre Sony recenti, TCL, Philips Android, Xiaomi, Hisense Google TV, Chromecast; la più costosa).
4. **Roku ECP** (banale da implementare, conta negli USA; prima valutare il vincolo dei termini Roku).
5. **Sony REST/IRCC** (solo per le Bravia non Android; le altre sono già coperte da Android TV).
6. Fuori dalla prima versione: Fire TV, Hisense VIDAA, Philips JointSpace con segreto estratto, Vizio, Samsung 2014-2015 cifrate.

La TV di Matteo decide il primo protocollo da implementare e testare (ticket dedicato).
