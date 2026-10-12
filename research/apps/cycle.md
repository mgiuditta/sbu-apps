# Sbu Cycle: sintesi della ricerca su Flo

> **Attenzione: la funzione principale di Flo è gratuita.** Registrare le mestruazioni, le previsioni di mestruazioni e ovulazione, il calendario, i sintomi, lo storico e i promemoria non richiedono l'abbonamento. Sono a pagamento i contenuti, gli insight, il report per il medico, l'assistente e il partner completo. La regola sbu.dev è copiare solo app la cui funzione principale è a pagamento: Sbu Cycle va approvata come eccezione o scartata (ticket grilling dedicato). L'argomento a favore: le recensioni dicono che la parte gratuita è sempre più stretta e coperta da pop-up Premium, e il report per il medico è a pagamento.

Originale: Flo (id 1038369065), Health & Fitness, 4,6 su 150.733 valutazioni IT, iOS 17+. Dati: `research/1038369065/` (`meta.json`, `screenshots/`, `reviews.json` con 57 recensioni 1-3 stelle, `spec.json`, `ux.md`).

## Matrice delle feature

| Feature | A pagamento in Flo? | Sbu | Framework iOS 17+ | Conflitto con CLAUDE.md? |
|---|---|---|---|---|
| Registrazione mestruazioni (inizio, fine, flusso) | No | core | SwiftData | No |
| Schermata Oggi: giorno del ciclo, giorni alle prossime | No | core | SwiftUI, `SbuStat` + `SbuFullStop` | No: una cifra, un punto |
| Calendario con mestruazioni previste e finestra fertile | No | core | SwiftUI (griglia), `Calendar` | Colori: solo accento e `inkMuted`, la finestra fertile non può avere un secondo colore |
| Previsione prossime mestruazioni | No | core | tipo puro + Swift Testing | No |
| Ovulazione e finestra fertile (7-14 giorni) | No | core | tipo puro | Claim medici: decidere testo e avvisi |
| Probabilità di gravidanza del giorno | No | nice | tipo puro | Sì, claim medico |
| Registro umore, sintomi, perdite, sesso, test | No | core | SwiftData, SF Symbols | No (SF Symbols al posto delle illustrazioni) |
| Temperatura basale e muco cervicale | No | nice | HealthKit `basalBodyTemperature`, `cervicalMucusQuality` | No |
| Storico e grafici dei cicli | No | core | Swift Charts | No |
| Tendenze e pattern dei sintomi | Sì | nice | Swift Charts, tipo puro | Evitare giudizi "nella norma" |
| Report per il medico (6 mesi) | Sì | core | `ImageRenderer`/PDF, `ShareLink` | No: locale, nessun server |
| Promemoria (mestruazioni, ovulazione, pillola) | No | core | UserNotifications locali | No |
| Registro pillola | No | nice | SwiftData, notifiche | No |
| Apple Salute lettura e scrittura | No (e Flo non scrive le mestruazioni) | core | HealthKit `menstrualFlow`, `intermenstrualBleeding`, `ovulationTestResult`, `sexualActivity`, sintomi | No; linee guida 5.1.3 |
| Blocco con Face ID | No | core | LocalAuthentication | No |
| Modalità gravidanza | In parte | nice | contatore settimane | Contenuti medici esclusi: da decidere |
| Perimenopausa (punteggio, timeline) | Sì | skip | | Contenuto medico redazionale |
| Consigli, articoli, video | Sì | skip | | Rete, contenuti online |
| Assistente e symptom checker | Sì | skip | | Server, diagnosi |
| Community (Secret Chats) | No | skip | | Account, server |
| Flo a due (partner) | In parte | skip | | Account, server |
| Modalità anonima, account, backup cloud | No | skip | | Sbu non ha account |
| App Apple Watch | No | nice | watchOS, WidgetKit | Fuori dal perimetro attuale |
| Widget | n.d. | nice | WidgetKit | No |

## Problemi principali degli utenti (dalle recensioni)

1. **Pop-up Premium a ogni apertura** (14 recensioni): 2-4 inviti da chiudere prima di segnare l'inizio del ciclo, alcuni senza X.
2. **Troppo a pagamento** (16): "tutto ciò che non è la data del ciclo è a pagamento"; la salute mestruale non dovrebbe essere un abbonamento.
3. **Privacy** (4 e cronaca): dati condivisi con Meta e altri; accordo FTC 2021, class action 2025.
4. **Previsioni sbagliate o che cambiano** (6).
5. **Apple Salute**: le mestruazioni registrate non arrivano in Salute.
6. **Promemoria pillola** che non arrivano o assenti (3).
7. **Dati persi**, nessun backup senza account, reinstallare significa rifare l'onboarding (3).
8. **Notifiche insensibili**: dopo un aborto spontaneo l'app continua a dire che il ciclo è in ritardo.
9. Voci mancanti: coaguli, PMA, parto e post parto.

## Cosa Sbu fa meglio

- **Dati solo sul dispositivo**: nessun account, nessun server, nessun SDK, nessuna etichetta privacy oltre "Dati non raccolti". È la risposta diretta al caso Flo.
- **Nessun paywall, nessun pop-up**: si apre e si segna il giorno, una cifra sola sulla schermata Oggi.
- **Report per il medico gratis**, generato in PDF sul telefono e condiviso con il foglio di condivisione.
- **Apple Salute nei due sensi**, incluse le mestruazioni: anche il backup passa da Salute/iCloud dell'utente, non da un nostro server.
- **Blocco Face ID** e protezione dei file completa.
- **Previsioni trasparenti**: mostra su quanti cicli si basa la stima e allarga la finestra quando i cicli variano, senza promesse contraccettive.
- **Pausa delle previsioni** (da decidere) per gravidanza o perdita, contro le notifiche insensibili.

## Vincoli da ricordare

- Linea guida 4.1: stessa funzione, stile Sbu (carta, `ink`, un accento), niente copia di cerchi rosa, illustrazioni, emoji o testi.
- Linea guida 1.4.1: un'app sanitaria che dà stime deve dichiarare i limiti e non presentarsi come contraccettivo; 5.1.3: dati HealthKit mai per pubblicità o terzi, mai in iCloud fuori da HealthKit senza consenso, privacy policy obbligatoria.
- Età: Flo richiede 18+ per alcune funzioni; Sbu non raccoglie l'età.
