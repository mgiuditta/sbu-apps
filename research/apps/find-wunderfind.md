# Sbu Find: Wunderfind e Find My Bluetooth Device

Ticket: [#483](https://github.com/mgiuditta/sbu-apps-private/issues/483), mappa [#248](https://github.com/mgiuditta/sbu-apps-private/issues/248). Ricerca del 16/10/2026, solo dati pubblici.

Dati: `research/1458601441/` (`meta.json` da `Tools/discover.py`, 4 screenshot, `reviews.json` con 11 recensioni da 1 a 3 stelle su 50 lette dal feed RSS pubblico). `spec.json` manca: `Tools/spec.py` richiede una chiave API che in questa sessione non c'era; la sintesi sotto la sostituisce.

## Wunderfind (1458601441)

- iTunes Lookup del 16/10/2026: gratis, versione 1.9.2 (5/3/2025), iOS 11+. Valutazioni: US 117.245 (4,51), JP 17.152, DE 15.252, GB 12.093, IT 3.333 (4,59). Sviluppatore a Berlino.
- Acquisti in-app ([scheda US](https://apps.apple.com/us/app/wunderfind-find-lost-device/id1458601441)): **Wunderfind Pro 4,99 $ una tantum**, più tre mance (0,99, 1,99, 2,99 $). Nessun abbonamento. Etichetta privacy: "The developer does not collect any data from this app."
- [AlternativeTo](https://alternativeto.net/software/wunderfind/about/): licenza perpetua da 5 $ più versione gratuita "con funzioni limitate".

### Gratis contro Pro

Dagli screenshot e dalle recensioni, non da una lista ufficiale (la scheda non la pubblica):

| Funzione | Free | Pro | Fonte |
|---|---|---|---|
| Radar: lista "I miei dispositivi" e "Altri dispositivi" con distanza stimata in metri | sì | sì | screenshot 04, descrizione |
| Punteggio distanza in percentuale nel dettaglio | sì | sì | screenshot 02, descrizione |
| "Riproduci un suono" sulle cuffie | no | sì | screenshot 02, recensioni IT 1.7.4, [TNW 2019](https://thenextweb.com/news/this-app-will-help-you-find-your-airpods-in-seconds) |
| Mappa con l'ultima posizione e "Visto l'ultima volta" | no | sì | screenshot 03, recensione IT 1.7.4 |
| "Notifica quando trovato" | no | sì | screenshot 03 |
| Avviso di separazione e complicazione su Apple Watch | no | sì | recensioni IT 1.7.9 |

Il free tier di Wunderfind è quindi già quello che Find Air fa pagare: scansione illimitata e misuratore. Paga solo memoria (mappa, notifiche) e il suono.

### Cosa chiedono le recensioni 1-3 stelle (11, tutte IT)

1. **Il suono non fa trovare la cuffia persa** (2): suona solo la cuffia collegata, cioè quella in mano; la mappa mostra la custodia, non la cuffia. Conferma che "far suonare" un auricolare perso non è possibile per un'app di terzi: si può solo mandare audio alla cuffia ancora collegata.
2. **Come cerco un solo AirPod?** (2): nessuna spiegazione di cosa fare con un auricolare solo.
3. **Avviso di separazione inaffidabile** (3): su Apple Watch non avvisa, richiede la posizione sempre attiva.
4. **Percentuale che non vuol dire nulla** (1): 35% a meno di un metro, 28% a 2 m.
5. **Dispositivo non trovato** (2): Apple Pencil in auto, AirTag mai visto.
6. **Mappa che non si apre** (1).

Rispetto a Find Air ([#158](https://github.com/mgiuditta/sbu-apps-private/issues/158)) manca la rabbia per il paywall e gli addebiti: è un acquisto unico onesto. Le nuove richieste sono il caso del singolo auricolare e le funzioni "memoria" (mappa, avviso).

## Find My Bluetooth Device (1522814560)

**Non è più sull'App Store.** iTunes Lookup vuoto in US, GB, DE, IT, FR, CA, AU, JP; `apps.apple.com/app/id1522814560` risponde 404. `discover.py` ha dato "not on the store in it us". Non c'è più niente di pubblico da leggere. Il filtro del 16/10 lo ha tenuto da un dato vecchio. Le app con nomi simili ancora in vendita ([Find My Bluetooth Device +](https://apps.apple.com/py/app/find-my-bluetooth-device/id1569927201), Air Finder, tracker detect) chiedono 4,99-6,99 $ a settimana: stesso modello di Find Air.

## Ricerca "free bluetooth finder no ads"

La ricerca web non ha trovato thread Reddit utili. In cima escono solo schede App Store, quasi tutte a abbonamento o con scansioni limitate. AlternativeTo per Wunderfind cita Prey, FMD e AirGuard: nessuna è uno scanner BLE gratuito per iOS senza pubblicità. Lo spazio di Sbu Find resta libero.

## Cosa cambia per la mappa #248

- **Originale di riferimento**: Wunderfind (117K valutazioni US) è il nome da citare nella scheda e sul sito accanto a Find Air. Find My Bluetooth Device va tolto dalle note.
- **Il confronto onesto è più duro**: Wunderfind dà gratis scansione e misuratore. Sbu deve battere Wunderfind gratis sul misuratore (parole caldo/freddo, filtro, suono e vibrazione di prossimità), non solo Find Air sul prezzo.
- **#207 Aiuto**: aggiungere il caso del singolo AirPod (trasmette solo fuori dalla custodia e acceso; per farlo suonare c'è Dov'è, che suona un auricolare alla volta).
- **Fuori scope invariato**: "far suonare" resta fuori. Il suono di Wunderfind va solo alla cuffia collegata, e le recensioni dicono che non serve.
- **#209 avviso se perso, #210 mappa**: sono le funzioni Pro di Wunderfind, e le recensioni ne mostrano i limiti (posizione sempre attiva, avviso che non parte). Sono già grilling aperti: questi dati vanno letti lì, senza nuovi task.
