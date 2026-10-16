# Sbu Meds: sintesi della ricerca su Medisafe

Ricerca del 16/10/2026 per la mappa #480 (ticket #481 e #482). Solo dati pubblici: App Store, iTunes Lookup, documentazione Apple, pagine dei produttori. Niente decompilazione.

## Valutazioni esatte (iTunes Lookup, 16/10/2026)

| App | Paese | Media | Valutazioni | Versione | iOS min | Prezzo |
|---|---|---|---|---|---|---|
| Medisafe (573916946) | US | 4,709 | 101.467 | 9.52.2 | 17.0 | gratis + abbonamento |
| Medisafe (573916946) | IT | 4,610 | 4.686 | 9.52.2 | 17.0 | gratis + abbonamento |
| Med ART, "Medication Reminder & Pill Log" (1448776934) | US | 4,603 | 706 | 8.3 | 18.6 | gratis + Premium 9,99 $/mese, 59,99 $/anno |
| Med ART (1448776934) | IT | 5,0 | 1 | 8.3 | 18.6 | come sopra |

Dati: `research/573916946/` e `research/1448776934/` (`meta.json`, `ratings.json`, `screenshots/`; `reviews.json` con 29 recensioni 1-3 stelle per Medisafe, feed vuoto per Med ART). `spec.json` non generato: `Tools/spec.py` richiede `ANTHROPIC_API_KEY`, assente in questo ambiente; la sintesi sotto è fatta a mano da listing, screenshot e recensioni.

## Il varco: Medisafe a pagamento fuori dagli USA

Dal 1° gennaio 2026 Medisafe richiede un abbonamento per gli utenti fuori dagli Stati Uniti (4,99 $/mese o 39,99 $/anno). Premium include farmaci illimitati, Medfriend e familiari a carico illimitati, tracker di salute, suonerie e colori. L'app resta senza pubblicità. Fonte: [Medisafe Help Center](https://help-center.medisafe.com/en/articles/13052285-medisafe-is-now-a-fully-paid-app-for-users-outside-the-u-s). In Italia, quindi, anche la funzione base è a pagamento: Sbu Meds rientra nella regola.

## Cosa fa Medisafe (schermate in ordine)

1. **Casa (Oggi)**: profilo in alto (avatar e nome, si cambia persona), striscia della settimana, dosi raggruppate per orario; ogni dose mostra farmaco, dose, stato ("Presa alle 09:09"). `+` per aggiungere.
2. **Scheda della dose** (tap su una dose): Salta, Prendi, Modifica orario; info, elimina, modifica.
3. **Aggiunta farmaco** (procedura guidata): nome, forma e colore della pillola, dose, frequenza (ogni giorno, giorni specifici, ogni N ore, ciclico, al bisogno), orari, durata, scorte.
4. **Dettaglio farmaco**: prossimo promemoria, schema, scheda informativa e video, interazioni, Ricarica (scorte), Aggiungi dose extra.
5. **Rapporto**: aderenza settimanale in percentuale, giorno per giorno presi/mancati; Invia come PDF.
6. **Medfriend**: invita un amico avvisato via server se salti una dose.
7. **Tracker di salute**: misurazioni (pressione, glicemia, peso, colesterolo) con grafico e lista, sincronizzate con Apple Salute.
8. Tab: Casa, Aggiornamenti (contenuti), Farmaci (lista), Altro (profili, impostazioni).

Med ART segue lo stesso schema (Oggi con striscia settimana e "Completa tutto", notifica con "Completa tutto" e "Ricordamelo tra 30 minuti", profili multipli, PDF per il medico, widget, Siri), ma è senza account e sincronizza con iCloud.

## Funzioni compatibili con Sbu

| Funzione | Sbu | Framework |
|---|---|---|
| Profili per più persone su un iPhone | core (è il varco) | SwiftData |
| Farmaci con forma, dose, nota | core | SwiftData, SF Symbols (niente immagini di pillole) |
| Schema: ogni giorno, giorni scelti, ogni N ore, ciclico, al bisogno, durata | core | tipo puro + Swift Testing |
| Oggi: dosi per orario, Preso/Saltato/Sposta, "Prendi tutto" | core | SwiftUI List |
| Notifiche con azioni Preso, Salta, Rimanda | core | UserNotifications (categorie con azioni), notifiche locali |
| Promemoria ripetuto se non segni la dose, intervallo scelto | core | notifiche locali |
| Storico completo, senza limite di 30 giorni | core | SwiftData |
| Scorte e promemoria di ricarica | core | tipo puro, notifiche |
| Rapporto aderenza e PDF per il medico | core | `ImageRenderer`/PDF, `ShareLink` |
| Widget prossima dose | core | WidgetKit |
| Orario fisso quando cambi fuso orario | core | `DateComponents` senza fuso |
| Lettura dei Farmaci di Apple Salute (import) | nice | HealthKit iOS 26, vedi sotto |
| App Apple Watch | nice | fuori perimetro attuale |
| Blocco Face ID | nice | LocalAuthentication |

## Funzioni da saltare

- Medfriend e caregiver remoto (server, account): fuori perimetro (mappa).
- Database farmaci, schede, video, interazioni: rete e contenuti medici, linea guida 1.4.1.
- Feed "Aggiornamenti"/"Per te", articoli, richieste di recensione.
- Tracker di misurazioni (pressione, glicemia, peso): è un'altra app, non "una cosa sola".
- Temi colorati, suonerie a pagamento, forme di pillole decorative.
- Account e backup sul loro cloud (al massimo iCloud dell'utente, ADR-0008).

## Problemi degli utenti (29 recensioni 1-3 stelle)

1. **Crash e schermo nero** su iPhone e Apple Watch dopo gli ultimi aggiornamenti (12).
2. **Notifiche sbagliate**: ripetute ogni 10 minuti senza poter cambiare intervallo, promemoria fantasma, avvisi anche dopo aver segnato la dose (5).
3. **Storico limitato** a 30 giorni o all'anno corrente (3).
4. **Schemi rovinati**: dosi mattina/sera scambiate, scalaggio che cambia dose e date, orari non modificabili (4).
5. **Fuso orario**: domanda confusa, vogliono "non cambiare mai l'orario" (1).
6. **Schermata "Per te"** imposta all'apertura invece della lista di oggi (1).
7. **Passaggio a pagamento** citato come motivo per andarsene (2).
8. Non si può segnare in anticipo un gruppo di dosi prima dell'orario (1).

## Alternative gratuite pulite (regola 4 del filtro)

Nessuna rende inutile Sbu Meds: chi è gratis senza pubblicità non ha i profili famiglia gratis.

| App | Gratis | Pubblicità/tracking | Account | Più persone |
|---|---|---|---|---|
| [MyTherapy](https://apps.apple.com/us/app/pill-reminder-mytherapy/id662170995) (4,77, 8.557) | sì | **pubblicità e tracking** (Identificatori); abbonamento senza pubblicità | profili "in un account" | sì |
| [GoodPill](https://apps.apple.com/us/app/goodpill-pill-reminder/id6759840986) (4,0, 2) | in parte | nessuna | no | **solo Pro** (14,99 $/anno); PDF solo Pro |
| [Medmento](https://apps.apple.com/us/app/medmento-medication-reminder/id1594860019) (5,0, 3) | sì | analytics (dati non collegati) | no | no, solo export CSV |
| Med ART (1448776934) | in parte | analytics | no | sì, Premium 59,99 $/anno |
| Apple Salute, Farmaci | sì | nessuna | Apple Account | **no**, vedi #482 |

Fonti: listing App Store, [AlternativeTo](https://alternativeto.net/software/medisafe/), [MyTherapy](https://www.mytherapyapp.com/). Reddit non ha restituito thread utili.

## Apple Salute: Farmaci in iOS 26 (#482)

- **Più persone: no.** I Farmaci di Salute registrano i farmaci di chi possiede l'iPhone. La documentazione Apple non prevede profili per altre persone; il caso famiglia passa solo dalla condivisione dei dati Salute, in sola lettura, verso l'account di un'altra persona ("If you share your health data with family and friends, you can also include which medications you're taking"). La funzione non è disponibile sugli Apple Watch configurati con In famiglia. Fonte: [Apple Support 105064](https://support.apple.com/en-us/105064). Le note di iOS 26 ([Newsroom](https://www.apple.com/newsroom/2025/06/apple-elevates-the-iphone-experience-with-ios-26/)) non citano novità per i Farmaci.
- **API HealthKit (iOS 26): sola lettura.** WWDC25 sessione 321 "Meet the HealthKit Medications API": "We're adding the ability to read medications and dose events". Tipi: `HKUserAnnotatedMedication`, `HKMedicationConcept`, `HKMedicationDoseEvent` (campione con stato preso/saltato, quantità, orario previsto). Autorizzazione per oggetto (`requestPerObjectReadAuthorization(for:predicate:completion:)`); autorizzare un farmaco dà accesso anche alle sue dosi. `HKMedicationDoseEvent` non ha inizializzatori pubblici: le app non possono scrivere farmaci né dosi. Fonti: [WWDC25 321](https://developer.apple.com/videos/play/wwdc2025/321/), [HKUserAnnotatedMedication](https://developer.apple.com/documentation/healthkit/hkuserannotatedmedication), [HKMedicationDoseEvent](https://developer.apple.com/documentation/healthkit/hkmedicationdoseevent).
- **Conseguenza**: Salute non copre il caso famiglia, il varco resta (criterio 3 superato). Integrazione possibile solo come importazione, facoltativa e con deployment iOS 26 condizionale (`if #available`), per il profilo di chi usa l'iPhone. Niente scrittura verso Salute.

## Esito

Sbu Meds procede: Medisafe è a pagamento in Italia dal 2026, i profili famiglia sono Premium ovunque, nessuna alternativa gratis e pulita li offre, e Apple Salute resta mono-persona con API in sola lettura.
