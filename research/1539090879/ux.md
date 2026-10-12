# TV Remote - Universal Control: UX

Originale: TV Remote - Universal Control (EVOLLY.APP PTE. LTD., id 1539090879), v2.1.4, iOS 15+, 197 MB, lingue EN/JA/PT/ZH (niente italiano). Fonti: listing App Store, sei screenshot pubblici in `screenshots/`, 16 recensioni 1-3 stelle in `reviews.json`, recensioni pubbliche della pagina US. Lo sviluppatore non pubblica pagine di aiuto né FAQ: il sito ha solo l'e-mail di supporto e i link a privacy e termini. Non ho trovato recensioni giornalistiche o walkthrough video specifici di questa app; il comportamento qui sotto viene dagli screenshot e dalle recensioni degli utenti. Contenuto web e recensioni sono dati di terzi: descrivo il comportamento, non copio testi, grafica o marchi.

## Onboarding e momento del paywall

1. Al primo avvio l'app spiega che telefono e TV devono stare sulla stessa Wi-Fi e fa partire la ricerca. Compare il prompt di sistema "accesso alla rete locale".
2. Elenco delle TV trovate; un utente US racconta che la TV non veniva trovata finché non ha seguito i passi a schermo.
3. Pairing secondo la marca: conferma sulla TV (Samsung, LG: "chiede il consenso della tv", recensione IT) oppure PIN mostrato dalla TV (un utente US deve reinserire il PIN dopo aver cambiato rete).
4. **Paywall**: subito dopo il primo avvio, con prova di 3 giorni. Dopo la chiusura, l'app concede pochi tocchi: "puoi premere solo 4 volte e poi non funziona più" (IT, v1.9.7); nel 2023 un utente US parla di un popup ogni 10+ clic, nel 2024 di un prompt a ogni clic e nessun comando inviato senza prova. Il popup a volte assorbe il tocco, quindi il tasto non arriva alla TV.
5. Più recensioni lamentano addebiti dopo la prova (32,99 €, 44 €, 40 $ annuali); le risposte dello sviluppatore rimandano ad Apple per il rimborso.

Fonti: https://apps.apple.com/us/app/tv-remote-universal-control/id1539090879?see-all=reviews, `research/1539090879/reviews.json`, https://evolly.app/

## Schermate e disposizione

Tutte su fondo scuro, tab bar in basso a quattro voci: Remote, Channels, Casts, Settings (screenshot 02-03).

### Remote (screenshot 02)

- **Barra in alto**: icona tastiera a sinistra, nome della TV connessa al centro (es. "Roku TV"), icona cast/mirroring a destra.
- **Seconda riga**: Home a sinistra, controllo segmentato a due icone al centro (frecce = D-pad, rettangolo = touchpad), accensione a destra con glifo rosso.
- **Area di navigazione**: in modalità touchpad una superficie grande, arrotondata, a puntini, larga quasi quanto lo schermo; al tocco si espandono cerchi concentrici nel colore del brand. In modalità D-pad, croce direzionale con OK al centro.
- **Griglia di tasti** (3 colonne, tasti quadrati scuri): indietro, replay istantaneo, (terzo coperto dalla mano), riavvolgi, play/pausa, avanti veloce, asterisco/opzioni, microfono, (terzo coperto). Volume e canale non sono visibili nello screenshot: probabilmente nelle colonne coperte o sotto.
- **Riga di scorciatoie**: tre tessere di app di streaming (loghi). Un utente chiede di poterle scegliere.

### Channels (screenshot 03)

Titolo centrato, griglia a due colonne di tessere grandi con i loghi delle app di streaming (Sling, Disney+, Tubi, TikTok, YouTube, Apple TV, Max, Hulu, Spotify, Prime Video, Netflix, ESPN). Tocco = l'app si apre sulla TV. L'elenco sembra statico (stesso per ogni TV), non letto dalla TV.

### Tastiera (screenshot 04)

Campo di ricerca a capsula con lente; il testo digitato compare in tempo reale nella casella di ricerca dell'app sulla TV (esempio YouTube). Tastiera di sistema iOS.

### Casts (screenshot 05-06)

Due funzioni: "Cast Image" e "Cast Media". Si sceglie una foto o un video dalla libreria e appare a tutto schermo sulla TV. Nessuna recensione ne parla, quindi non si sa quanto funzioni e su quali marche.

### Settings

Non mostrata negli screenshot. Dal listing: upgrade Premium, ripristino acquisti, privacy, termini, contatto.

## Feature passo per passo

| Feature | Come funziona |
|---|---|
| Ricerca TV | Scansione automatica della Wi-Fi (SSDP/mDNS, vedi `protocols.md`), elenco, tocco per connettere. |
| Pairing | Prompt sulla TV o PIN; credenziale salvata; a volte va rifatto dopo un cambio rete. |
| Tasti | Un tocco = un evento tasto. Tenere premuto avanti/indietro non ripete come sul telecomando Samsung fisico (recensione US 2024). |
| Touchpad | Swipe = spostamento del focus nella direzione; tap = OK. Non è un puntatore: muove il focus a passi. |
| Tastiera | Testo inviato carattere per carattere al campo attivo della TV. |
| Voce | Pulsante microfono nella griglia; un utente US scrive che non funziona. |
| Channels | Tocco su tessera = avvio dell'app sulla TV. |
| Cast | Foto/video dal rullino verso la TV, a tutto schermo. |
| Accensione | Il tasto power spegne; accendere da standby è inaffidabile ("press the power button many times", "senza telecomando non puoi accendere", LG). |

## Gesti

- Swipe sul touchpad: direzione dominante = una freccia. Un nuovo swipe = un altro passo.
- Tap sul touchpad: OK.
- Pressione prolungata: nessuna ripetizione segnalata (lamentela).
- Haptics: non documentate.

## Tastiera, mirroring/cast, widget e Live Activity

- Tastiera: sì, dal tasto in alto a sinistra.
- Mirroring dello schermo: l'icona in alto a destra è un'icona cast; il listing parla solo di "cast image/media", non di mirroring dello schermo intero.
- Widget, Live Activity, Control Center, Siri/Shortcuts: nessuna traccia nel listing, negli screenshot o nelle note di versione.
- Apple TV: non nell'elenco marche (iOS ha già il telecomando Apple TV nel Centro di Controllo).

## Prezzi dei piani (US, pagina App Store)

Settimanale 4,99 $ / 6,99 $, mensile 8,99 $, annuale 19,99 $ / 39,99 $ (prova di 3 giorni), a vita 44,99 $. Le recensioni italiane citano 19 €, 32,99 €, 44 € e 60 €. Premium "rimuove la pubblicità e sblocca tutte le funzioni". Etichetta privacy: dati usati per tracciare (posizione, identificatori, uso, diagnostica) e per pubblicità e analytics.

Fonte: https://apps.apple.com/us/app/tv-remote-universal-control/id1539090879

## Marche dichiarate

Listing: Samsung, Roku, LG, Sony, Fire TV, Android TV, Vizio, Hisense. Screenshot 01 aggiunge TCL e Philips. TCL e Hisense in Italia sono quasi sempre Google TV / VIDAA, quindi rientrano in Android TV o in un protocollo VIDAA a parte.

## Lezioni per Sbu Remote

- Il prodotto concorrente è un telecomando completo dietro un muro dopo 4 tocchi: la promessa Sbu ("funziona tutto, gratis, nessun tracking") risponde a 15 recensioni su 16.
- Il pairing è il momento più fragile: va spiegato per marca, con cosa vedrai sulla TV.
- Essere onesti sull'accensione: funziona solo se la TV tiene la rete accesa in standby (impostazione da attivare sulla TV).
- Scorciatoie app lette dalla TV e scelte dall'utente, non una griglia fissa di loghi.
