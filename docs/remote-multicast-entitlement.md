# Sbu Remote: richiesta dell'entitlement multicast

Testo pronto per il modulo Apple "Multicast Networking Entitlement Request" (https://developer.apple.com/contact/request/networking-multicast). Lo compila e lo invia Matteo, titolare dell'account sviluppatore, dopo aver creato l'App ID `dev.sbu.remote` (#360, #484). Nessuno lo ha inviato.

Quando Apple lo concede:

1. In `Apps/SbuRemote/project.yml`, nelle `entitlements` del target `SbuRemote`, aggiungere `com.apple.developer.networking.multicast: true`.
2. In `Apps/SbuRemote/SbuRemote/Discovery/NetworkFeatures.swift`, `isMulticastEntitled = true`: si accendono la ricerca SSDP e il Wake-on-LAN in broadcast, già scritti e testati.
3. Rigenerare i profili (firma automatica) e provare su una TV vera.

## Campi del modulo

- **App name**: Sbu Remote
- **Bundle ID**: dev.sbu.remote
- **Platform**: iOS
- **Protocols and ports**: SSDP, UDP 1900, gruppo multicast 239.255.255.250 (M-SEARCH, sola ricerca); Wake-on-LAN, UDP 9, broadcast 255.255.255.255 (pacchetto magico).
- **Is the app available on the App Store?** Non ancora: prima versione in preparazione.

## Motivazione (English, for the form)

Sbu Remote is a free TV remote for the user's own television, with no account, no ads and no tracking. The iPhone has no infrared, so the remote works over the home Wi-Fi.

We need multicast for two things only:

1. **SSDP discovery (UDP 1900, group 239.255.255.250).** Samsung, LG and Sony televisions announce their remote-control service through SSDP, not Bonjour. The app sends one M-SEARCH per brand when the user opens "Add a TV", reads the replies, and shows the TVs found. Without it, the user has to find and type the TV's IP address.
2. **Wake-on-LAN (UDP 9, broadcast).** A TV in standby has no IP route the phone can use; the magic packet must be broadcast on the local network so the TV's network card can wake it. This is how the remote turns the TV on, which is the most requested feature in reviews of apps like ours.

All traffic stays on the local network and goes only to the user's TV. The app never contacts the internet or any server, and no data leaves the device. Bonjour (`_androidtvremote2._tcp`, `_airplay._tcp`) and a manual IP field already work without the entitlement; multicast completes discovery and power-on for the brands that need it.

## Motivazione (italiano, per riferimento)

Sbu Remote è un telecomando gratuito per la TV dell'utente, senza account, pubblicità né tracciamento. L'iPhone non ha infrarossi, quindi il telecomando passa dalla Wi-Fi di casa.

Il multicast serve solo a due cose:

1. **Ricerca SSDP (UDP 1900, gruppo 239.255.255.250).** Le TV Samsung, LG e Sony annunciano il servizio di telecomando con SSDP, non con Bonjour. L'app manda una M-SEARCH per marca quando l'utente apre "Aggiungi una TV", legge le risposte e mostra le TV trovate. Senza, l'utente deve cercare e scrivere l'indirizzo IP della TV.
2. **Wake-on-LAN (UDP 9, broadcast).** Una TV in standby non ha un percorso IP che il telefono possa usare; il pacchetto magico va mandato in broadcast sulla rete locale perché la scheda di rete della TV la accenda. È così che il telecomando accende la TV, la funzione più chiesta nelle recensioni di app come la nostra.

Tutto il traffico resta sulla rete locale e va solo alla TV dell'utente. L'app non contatta mai internet né alcun server, e nessun dato esce dal dispositivo. Bonjour (`_androidtvremote2._tcp`, `_airplay._tcp`) e il campo per l'IP funzionano già senza l'entitlement; il multicast completa ricerca e accensione per le marche che ne hanno bisogno.
