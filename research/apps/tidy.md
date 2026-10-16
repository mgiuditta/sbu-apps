# Sbu Tidy: sintesi su Tody

Originale: Tody (id 595339588, Looploop IVS). Concorrente: Sweepy (id 1498897320, Appsent). Dati: `research/595339588/` e `research/1498897320/` (`meta.json`, `screenshots/`, `reviews.json`). Ticket: mgiuditta/sbu-apps-private#477, mappa #476.

`spec.json` non c'è: `Tools/spec.py` si ferma senza `ANTHROPIC_API_KEY` in questa sessione. Le recensioni 1-3 stelle sono state scaricate dallo stesso feed pubblico che usa `spec.py` (Atom XML), su più storefront perché il feed US tornava vuoto: 13 per Tody, 11 per Sweepy, con il campo `country`. Lo spec qui sotto è scritto a mano da listing, screenshot e recensioni.

## Valutazioni esatte (iTunes Lookup, 16/10/2026)

| App | US | IT | Versione |
|---|---|---|---|
| Tody | 4,83 su 10.757 | 4,59 su 41 | 6.6.9 US, 6.6.10 IT (15/10/2026) |
| Sweepy | 4,72 su 10.655 | 4,67 su 318 | 6.2.0 (04/02/2026) |

Prezzi dalla pagina App Store US. Tody: Premium Solo 9,99 $, Premium+ Duo 24,99 $, Family 39,99 $, Team 79,99 $; privacy: solo dati d'uso non collegati (analytics). Sweepy: 3,99 $/mese, 19,99 $/anno con prova di 3 giorni; privacy: email, nome, foto, ID utente collegati; posizione approssimativa e dati pubblicitari non collegati.

## Cosa fa Tody

Una lista di pulizie guidata dal bisogno, non da date. Ogni attività ha una frequenza; dall'ultima volta fatta cresce un livello di sporco (barra verde, gialla, arancio) con due tacche: "da fare" e "in ritardo". Niente scadenze rigide, notifiche opzionali. Premium: sync tra persone di casa, assegnazioni, statistiche, stagioni.

## Schermate in ordine (dagli screenshot)

1. **Aree** (home): lista delle stanze, ognuna con la barra di stato media; "+ Area" in fondo. Tab bar: statistiche, Da fare, Aree, impostazioni.
2. **Stanza**: attività ordinate per urgenza; per ognuna nome, sforzo (1-3 pallini), barra e testo "Tra 7 giorni" / "6 giorni di ritardo"; "+ Attività". Illustrazione della stanza in basso.
3. **Attività**: titolo, grafico a dente di sega dello sporco nel tempo, frequenza, sforzo, giorni alla scadenza (negativo se in ritardo), barra grande; pulsanti "Fatta ora", "Fatta il…" (data passata), "Pausa". Schede Stato, Note, Modifica, Storico.
4. **Da fare**: filtro "Da fare" / "In scadenza", per persona, raggruppato per stanza con conteggio; totale in alto.
5. **Nuova attività**: nome (picker di preset per la stanza: Base / Speciali), frequenza (numero + unità giorni/settimane/mesi), stagioni attive, sforzo 1-3, assegnazione.

Sweepy ha lo stesso modello (stanza, attività, frequenza, stato a parole: "Sta brillando", "Va abbastanza bene", "A lavoro"), più piano giornaliero a punti sforzo, classifica di famiglia e monete per arredare una stanza.

## Funzioni compatibili (Sbu)

| Funzione | Sbu | Framework | Note |
|---|---|---|---|
| Stanze con preset IT/EN, aggiungi, rinomina, riordina, duplica | core | SwiftData | Duplicare stanza fa crashare Tody (recensione AU) |
| Attività con frequenza (giorni/settimane/mesi) e sforzo 1-3 | core | SwiftData | |
| Livello di sporco = tempo trascorso / frequenza, stati "pulita / da fare / in ritardo" | core | Tipo puro testato | Lo stato va detto a parole o simbolo, non solo colore |
| Lista "Da fare oggi" per urgenza, raggruppata per stanza | core | SwiftUI List | La cifra della schermata: attività da fare oggi, con il punto fermo |
| Fatta ora, Fatta il… (data passata), Pausa | core | SwiftData | |
| Storico completamenti per attività | core | SwiftData | Grafico a dente di sega: nice, in `inkMuted`, senza colori di stato |
| Note per attività | nice | SwiftData | |
| Attività una tantum che sparisce quando fatta | nice | SwiftData | Bug di Sweepy: tornano al massimo sporco |
| Promemoria locali per attività quando diventa "da fare" | core | UserNotifications | Sweepy avvisa in ritardo o con messaggi generici |
| Widget con le attività più urgenti | core | WidgetKit | Tody non ha widget, una recensione lo chiede |
| Stagioni attive | nice | SwiftData | Utile per terrazzo, giardino; decidere |
| Più persone in casa | grilling | ADR-0009 / un solo telefono | Senza account; Tody lo fa con sync a pagamento |
| iPad in orizzontale, inserimento da tastiera | core | SwiftUI | Due recensioni Tody lo chiedono; anche accessibilità |

## Funzioni da saltare

- Sync famiglia via server di Tody, account, password di sync (Tody non la fa recuperare: dati persi).
- Classifiche, punti, monete e negozio di arredi di Sweepy (gamification, sembra paywall).
- Statistiche "Reports" condivise con la casa via server.
- Assegnazione con avatar e approvazione del lavoro di Sweepy (richiede account).
- Illustrazioni delle stanze, barre colorate a gradiente: fuori dal design system.

## Cosa chiedono le recensioni 1-3 stelle

1. **Perdita di dati e sync rotto** (Tody 4): attività sparite dopo l'acquisto, sync tra partner che non funziona più, password di sync non recuperabile.
2. **Pagamenti** (Tody 2, Sweepy 3): l'acquisto una tantum convertito in abbonamento, condivisione in famiglia solo a pagamento, abbonamento "predatorio".
3. **Crash e app che non si apre** (Tody 4): anche duplicando una stanza.
4. **Notifiche inutili** (Sweepy 2): arrivano tardi o al mattino anche senza nulla da fare; servono per attività.
5. **Inserimento faticoso, niente orizzontale** (Tody 2): tastiera che salta, iPad solo verticale.
6. **Tono negativo e una tantum** (Sweepy 2): stato che "punisce"; attività una tantum che rovinano il punteggio.

## Alternativa gratuita pulita?

No. Nessuna rende inutile Sbu Tidy (regola 4 del filtro non scatta):

- **Donetick** (AlternativeTo, open source AGPL): l'app iOS (6742807441) ha Donetick Plus 4,99 $/mese o 39,99 $/anno, raccoglie l'email e richiede un server (cloud o self-hosted).
- **Spotless: A simply clean home** (1067203863): attività illimitate 4,99 $, abbonamento 1,99 $/mese, condivisione solo con abbonamento.
- **Tidy: House Cleaning Schedule** (1564891793, Chakhouski Artsiom): abbonamento 4,99-5,99 $/mese, login, analytics.
- Homio, MyChoreBoard, OurHome: faccende per bambini o famiglia con account, altra nicchia.
- Non ho trovato thread Reddit pertinenti con la ricerca web; i risultati erano directory e pagine SEO.

Attenzione al nome: esiste già **"Tidy: House Cleaning Schedule"** (1564891793) nella stessa categoria. "Sbu Tidy" resta distinto, ma va tenuto presente per ASO e per la revisione 4.3.

## Fonti

- iTunes Lookup: `https://itunes.apple.com/lookup?id=595339588&country=us|it`, idem 1498897320.
- Pagine App Store: [Tody](https://apps.apple.com/us/app/tody/id595339588), [Sweepy](https://apps.apple.com/us/app/sweepy-home-cleaning-schedule/id1498897320), [Donetick](https://apps.apple.com/us/app/donetick-shared-chore-chart/id6742807441), [Spotless](https://apps.apple.com/us/app/spotless-a-simply-clean-home/id1067203863), [Tidy](https://apps.apple.com/us/app/tidy-house-cleaning-schedule/id1564891793).
- [AlternativeTo: Tody](https://alternativeto.net/software/tody/).
- Feed recensioni: `https://itunes.apple.com/{cc}/rss/customerreviews/page={n}/id={id}/sortby={mostrecent|mosthelpful}/xml`.
