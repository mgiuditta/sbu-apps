# Sbu Remote: entitlement multicast nel 2026

Ticket: [#484](https://github.com/mgiuditta/sbu-apps-private/issues/484), mappa [#365](https://github.com/mgiuditta/sbu-apps-private/issues/365). Ricerca del 16/10/2026. Collegati: [#360](https://github.com/mgiuditta/sbu-apps-private/issues/360) (entitlement o solo Bonjour?), [#303](https://github.com/mgiuditta/sbu-apps-private/issues/303) (ricerca TV), [#341](https://github.com/mgiuditta/sbu-apps-private/issues/341) (Wake-on-LAN). Protocolli per marca in `research/1539090879/protocols.md`.

## Cosa richiede l'entitlement

Fonte primaria: [TN3179 Understanding local network privacy](https://developer.apple.com/documentation/technotes/tn3179-understanding-local-network-privacy), ultima revisione 6/10/2026.

| Operazione su iOS | Permesso rete locale | Entitlement multicast |
|---|---|---|
| TCP in uscita verso un IP locale (HTTP, WebSocket, TLS) | sì | no |
| UDP unicast in uscita, ricezione UDP unicast | sì / no | no |
| UDP multicast (es. SSDP M-SEARCH a 239.255.255.250:1900) | sì | **sì** |
| UDP broadcast, anche 255.255.255.255 (Wake-on-LAN classico) | sì | **sì** |
| Browse/resolve Bonjour di tipi dichiarati in `NSBonjourServices` | sì | no |
| Bonjour di tipi arbitrari o browse di tutti i tipi (`_services._dns-sd._udp`) | sì | **sì** |
| AirPlay, `AVRoutePickerView`, DeviceDiscoveryUI, AccessorySetupKit | no | no |

Citazione: "To send or receive multicast or broadcast traffic, sign your app with the `com.apple.developer.networking.multicast` entitlement." Su macOS non serve.

## Tempi e modulo

- **Tempi**: Quinn (Apple DTS), [giugno 2025](https://developer.apple.com/forums/thread/786597): "these applications are usually processed pretty quickly (within a week or two)". Report più vecchi: circa 5 giorni ([thread 666240](https://developer.apple.com/forums/thread/666240)); Tuya scrive 3-5 giorni lavorativi ([guida](https://developer.tuya.com/en/docs/iot/oem-ez-privacy-apply?id=Kb8avep9c7wg6), 2024). Nessun dato 2026 pubblicato. Ci sono casi senza conferma di ricezione: arriva solo la mail di approvazione ([thread 703328](https://developer.apple.com/forums/thread/703328)). In pratica: **1-2 settimane**, da chiedere prima di tutto il resto.
- **Modulo**: [developer.apple.com/contact/request/networking-multicast](https://developer.apple.com/contact/request/networking-multicast), con login dell'Account Holder. Campi (dalla guida Tuya, il modulo richiede login): nome app, URL App Store (si può chiedere prima della pubblicazione, come fa [ShowRecorder #290](https://github.com/ericdahl-dev/ShowRecorder/issues/290) dell'ottobre 2026), Apple ID dell'app (facoltativo), categoria, scopo principale dell'app, e "perché l'app deve mandare traffico multicast o broadcast o sfogliare tutti i tipi Bonjour", indicando porte e protocolli.
- **Risposta proposta per Sbu Remote**: telecomando per la TV dell'utente sulla sua Wi-Fi; SSDP M-SEARCH UDP verso 239.255.255.250:1900 per trovare TV Samsung, LG, Roku, Sony che non pubblicano Bonjour; magic packet Wake-on-LAN in broadcast UDP (porta 9) per accendere la TV dallo standby; nessun server, nessun dato fuori dalla rete locale.
- Dopo l'approvazione la capability compare tra quelle dell'App ID; va aggiunta all'entitlements file e rigenerato il profilo. Con la firma automatica di Xcode basta abilitarla (TN3179).

## Cosa si fa senza entitlement

- **Bonjour con `NSBonjourServices`**: Android TV / Google TV (`_androidtvremote2._tcp`, `_googlecast._tcp`) e le TV con AirPlay 2 (`_airplay._tcp`: molte Samsung, LG, Sony, Vizio dal 2019). AirPlay dice che una TV c'è e il suo IP, non che parla il protocollo del telecomando: dopo serve una prova unicast (es. `GET http://<ip>:8001/api/v2/` per Samsung).
- **IP manuale**: sempre possibile, TCP unicast.
- **SSDP unicast**: M-SEARCH UDP inviato a `<ip>:1900` è unicast, quindi niente entitlement, e la risposta arriva in unicast. Serve però conoscere l'IP. Spazzare la /24 un indirizzo alla volta è tecnicamente lecito (lo fa ShowRecorder in attesa dell'entitlement), ma è lento e Quinn lo sconsiglia.
- **Accensione**: Wake-on-LAN classico è broadcast, quindi richiede l'entitlement. Senza, restano il tasto Power via WebSocket sulle Samsung che restano in rete in standby e il magic packet in unicast all'IP della TV, che funziona solo se il router conserva la voce ARP: non affidabile.
- **Cast DLNA**: trovare i renderer UPnP è SSDP multicast (entitlement). Servire i file da un `NWListener` HTTP sull'iPhone non lo richiede (ricevere TCP in ingresso non chiede nemmeno il permesso). L'alternativa senza entitlement è AirPlay di sistema.

## Conclusione

Chiedere l'entitlement subito, appena esiste l'App ID di Sbu Remote: costa un modulo e 1-2 settimane, e sblocca SSDP, Wake-on-LAN e DLNA. Nel frattempo, e come piano B se Apple rifiuta, l'app funziona con Bonjour, IP manuale e SSDP unicast. Nessuna funzione core dipende solo dall'entitlement, tranne l'accensione da standby delle TV che si svegliano solo con Wake-on-LAN, come le LG.
