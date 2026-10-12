# Sbu Steps: sintesi su Stompers

> **Attenzione: la funzione principale di Stompers come contapassi non è a pagamento.** I passi di oggi e la partita giornaliera sono gratuiti. Il paywall (Super Stompers, prova di 7 giorni, poi 4,99 $/settimana fino a 59,99 $/anno) colpisce la **modalità 24 ore** (dopo le 21 i passi non contano più nella partita), lo **storico dei giorni passati** e i cosmetici. La funzione per cui la gente paga è il gioco sociale, che Sbu non può fare (account, server). La regola "copiamo solo app la cui funzione principale è a pagamento" è rispettata solo in parte: decidere prima di costruire (grilling).

Originale: Stompers: Walking Step Counter (id 6477849675), Stompers LLC. Fonti: `research/6477849675/` (meta.json, spec.json, ux.md, reviews.json, screenshots).

## Matrice delle funzioni

| Funzione | A pagamento? | Sbu | Framework iOS 17+ | Conflitto con CLAUDE.md? |
|---|---|---|---|---|
| Passi di oggi, cifra grande | No | core | CoreMotion `CMPedometer` (live), HealthKit `HKStatisticsQuery` somma passi | No: è la cifra unica con il punto fermo |
| Giornata intera (24 ore) | Sì (Super Stompers) | core | Come sopra, giorno di calendario locale | No |
| Storico giorni passati | Sì (dalle recensioni) | core | HealthKit `HKStatisticsCollectionQuery` (storico lungo); `CMPedometer` solo 7 giorni senza Health | No, in `List .insetGrouped`; nessun secondo quadrato |
| Obiettivo giornaliero | Non esiste | core | `@AppStorage` / App Group | Da decidere come mostrarlo senza seconda cifra |
| Widget | No | core | WidgetKit (`.systemSmall`, accessory per la schermata di blocco) + HealthKit nell'estensione | No |
| Live Activity | Non esiste | nice | ActivityKit | Decisione aperta: senza timer o sessione non ha un inizio e una fine |
| Apple Watch | Via Health | nice | I passi del Watch arrivano già in HealthKit; target watchOS opzionale | Nuovo target, da decidere |
| Distanza e piani | No (non mostrati) | nice | `CMPedometer` distance/floorsAscended, HealthKit | Solo come testo secondario in `inkMuted` |
| Condivisione dei passi di oggi | No | nice | `ShareLink` + `ImageRenderer` | No se l'immagine è nello stile Sbu e non apre SDK social |
| Partita giornaliera con amici e classifica | No | skip | — | Sì: account, server, rete |
| Oggetti e sabotaggi | No (monete per alcuni) | skip | — | Sì: rete; e falsa una misura |
| Avatar animato personalizzabile | Parziale (monete) | skip / grilling | — | Sì: illustrazioni e personaggi contro "una cifra sola" |
| Pacchetti, monete, skin rare | Sì | skip | — | Sì: acquisti in-app |
| Contest con amici | No | skip | — | Sì: account, server |
| Inviti dai contatti, notifiche di gioco | No | skip | — | Sì: rete; in più pain degli utenti |

## Problemi principali degli utenti (75 recensioni 1-3 stelle)

1. **I passi non tornano** (circa 22 recensioni): il numero dell'app è diverso da Salute o dal Watch, perché il gioco conta solo una finestra oraria e sincronizza solo quando apri l'app.
2. **"Gratis" ingannevole** (circa 11): prova che diventa abbonamento, addebiti annuali, rimborsi negati.
3. **La giornata finisce alle 21 se non paghi** (circa 5): esclude chi lavora di notte.
4. **Bug, blocchi, batteria** (circa 9).
5. **Account persi, login ripetuti** (circa 5), **richieste insistenti** di contatti e notifiche (circa 4).
6. **Tutto costa**: storico, cosmetici, giornata intera.

## Cosa Sbu fa meglio

- Il numero è **uguale a quello di Salute**: stessa somma HealthKit, giorno di calendario intero, nessuna finestra, nessun sabotaggio.
- **Lo storico è gratis** e lungo quanto Salute.
- **Nessun account**, nessun contatto, nessuna notifica non richiesta, nessuna prova che si rinnova.
- **Funziona senza aprire l'app**: widget e query HealthKit leggono il dato aggiornato; `CMPedometer` dà il conteggio live anche senza Health.
- Turnisti: opzionale l'inizio della giornata spostabile (decisione aperta).

## Perché è virale

Stompers non vende un contapassi, vende una **gara quotidiana tra amici** con un ritmo fisso (podio alle 21), **sabotaggi** che rendono la classifica imprevedibile e personaggi disegnati da un animatore professionista, più immagini del podio pronte per le storie Instagram e Snapchat. Il fondatore aveva già un pubblico su X con concept satirici. La viralità è tutta sociale e di rete: Sbu non la può copiare. La promessa Sbu è l'opposto: il numero vero, gratis, senza account. Prima di partire va deciso se questo basta (il mercato dei contapassi gratuiti è affollato, compresa l'app Salute).
