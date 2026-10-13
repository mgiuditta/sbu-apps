# sbu.dev

Collezione di app iOS gratuite che rifanno, una per una, le utility a pagamento in cima all'App Store. Questo glossario vale per SbuKit, per ogni app e per gli strumenti di ricerca.

## Language

### Ricerca

**Candidato** (_Candidate_):
Un'app a pagamento trovata nelle classifiche top-paid, non ancora valutata.
_Avoid_: lead, research app

**Spec**:
La descrizione del comportamento di un **Candidato**, ricavata solo da dati pubblici dell'App Store.
_Avoid_: requisiti, PRD

**Scartato** (_Discarded_):
Un **Candidato** che non diventerà **Originale**, sempre con il motivo.

### App

**App Sbu** (_Sbu app_):
Un'app iOS gratuita di sbu.dev che rifà un solo **Originale**.
_Avoid_: "app" da sola quando può voler dire l'Originale

**Originale** (_Original_):
L'app a pagamento dell'App Store che un'**App Sbu** rifà.
_Avoid_: target, paid app, "app" da sola

**Cosa sola** (_One thing_):
L'unico compito di un'**App Sbu**, detto in una frase alla seconda persona ("ti dice se una cosa è dritta").
_Avoid_: feature principale, core feature

**Cifra** (_Figure_):
Il numero che misura la **Cosa sola**, mostrato in grande una volta per schermata.
_Avoid_: KPI, metrica, valore

**Schermata strumento** (_Tool screen_):
La schermata principale di un'**App Sbu**, dove fa la sua **Cosa sola**, su un campo scuro del colore dell'app.
_Avoid_: home, dashboard, prima tab

**Schermata di gestione** (_Management screen_):
Ogni altra schermata di un'**App Sbu** (impostazioni, storico, liste), su fondo chiaro di sistema.
_Avoid_: schermata secondaria

**Accento** (_Accent_):
Il colore di una sola **App Sbu**, tinta dell'interfaccia e campo della sua icona.
_Avoid_: colore primario, tint

**Brand**:
Il colore di sbu.dev, che in un'**App Sbu** compare solo nel footer "Parte di sbu.dev".
_Avoid_: accento di sbu.dev

**Glifo** (_Glyph_):
Il segno bianco, al massimo due tratti, dell'icona di un'**App Sbu**: l'oggetto della **Cosa sola** o il simbolo che iOS usa già per quel concetto.
_Avoid_: logo, illustrazione, metafora creativa

**Promesse** (_Promises_):
Le sei garanzie di ogni **App Sbu**: nessun abbonamento, nessun acquisto in-app, nessun account, nessuna pubblicità, nessun tracking, dati solo sul dispositivo.
_Avoid_: "tracking invasivo", privacy policy, feature

**FreeBadge**:
Il segno visibile delle **Promesse** in app e negli screenshot, che ne mostra quattro.
_Avoid_: badge gratuito, banner

**Concorrente** (_Competitor_):
Un'altra app a pagamento della stessa nicchia di un **Originale**, studiata ma non rifatta.
_Avoid_: secondo Originale, alternativa

### Sbu Habits

**Serie** (_Streak_):
I giorni previsti di fila in cui un'abitudine è stata fatta; i giorni non previsti non la interrompono.
_Avoid_: streak, catena

**Serie piena** (_Full streak_):
I giorni di fila in cui tutte le abitudini previste quel giorno sono state fatte; le abitudini settimanali e mensili non vi entrano, un'**Attività di un giorno** solo nel suo giorno. È la **Cifra** di Sbu Habits.
_Avoid_: serie totale, giornata perfetta

**Volte al mese** (_Times a month_):
Un'abitudine da fare in un numero di giorni qualsiasi del mese di calendario, da 1 a 27: conta i giorni fatti dal primo all'ultimo del mese, e la sua **Serie** conta i mesi di fila con l'obiettivo raggiunto. Il mese in corso non la interrompe finché non finisce; ogni giorno saltato abbassa l'obiettivo di quel mese di uno. Come le Volte a settimana, non entra nella **Serie piena** e non è mai un'**Abitudine da evitare**.
_Avoid_: mensile fisso, giorno del mese

**Attività di un giorno** (_One-day task_):
Un'abitudine da fare prevista in un solo giorno scelto, oggi o più avanti: compare nella griglia e nei widget solo quel giorno, ha promemoria solo quel giorno, e quel giorno entra nella **Serie piena** come ogni abitudine prevista (saltarla la lascia neutra). Negli altri giorni è neutra; passato il suo giorno resta in Statistiche con il suo storico finché non la elimini. Non è mai un'**Abitudine da evitare**.
_Avoid_: evento, promemoria, to-do

**Abitudine da evitare** (_Habit to avoid_):
Un'abitudine da tenere entro un **Limite**: segni ogni volta che cedi, e un giorno è fatto se a fine giornata sei rimasto entro il Limite. Oggi non conta finché non finisce, ma superare il Limite interrompe subito la **Serie**. Il tipo si sceglie alla creazione e non cambia; non ha promemoria né programmazione a settimana.
_Avoid_: cattiva abitudine, vizio, abitudine negativa

**Limite** (_Limit_):
Quante volte al giorno puoi cedere a un'**Abitudine da evitare** restando nel giorno fatto: 0 per "non fumare", 2 per "massimo due caffè".
_Avoid_: soglia, tetto, obiettivo

**Abitudine collegata** (_Linked habit_):
Un'abitudine da fare collegata a una misura di Salute con un obiettivo al giorno: si segna da sola quando il totale del giorno logico raggiunge l'obiettivo, e conta una volta al giorno. Salute aggiunge soltanto: non toglie mai un segno, e puoi sempre segnarla a mano (se neghi l'accesso, la segni sempre tu). Sbu Habits legge da Salute e non scrive mai; un'**Abitudine da evitare** non si collega.
_Avoid_: abitudine automatica, sincronizzata, integrazione

**Abitudine a tempo** (_Timed habit_):
Un'abitudine da fare con una durata: il play sull'anello apre il Timer, e quando il conto alla rovescia finisce si segna da sola, una volta al giorno, sul giorno logico in cui è partito. Un timer alla volta; regge background e chiusura dell'app. Non si collega a Salute e non è mai un'**Abitudine da evitare**.
_Avoid_: abitudine cronometrata, countdown

**Nota del giorno** (_Daily note_):
Un breve testo che scrivi su un'abitudine per un giorno, oggi o un giorno passato: una nota per abitudine per giorno, riscrivibile. Un testo vuoto non è una nota. Salta oggi la lascia dov'è; eliminare l'abitudine elimina le sue note. Viaggia con Esporta e Importa, mai con un'**Abitudine condivisa**.
_Avoid_: diario, commento, memo

**Abitudine condivisa** (_Shared habit_):
Un'abitudine che il proprietario condivide via iCloud con altre persone: loro la vedono in sola lettura, con storico e statistiche, e scelgono un'emoji per il proprietario. Non si segna, non entra nella loro **Serie piena** né nei loro widget; sparisce quando il proprietario smette di condividerla o la elimina.
_Avoid_: abitudine di gruppo, abitudine sincronizzata, sfida

### Sbu Cards

**Nota** (_Note_):
Quello che scrivi o importi: un insieme di campi (fronte, retro, testo con lacune) con dei tag.
_Avoid_: flashcard, scheda

**Carta** (_Card_):
Una domanda da ripassare, generata da una **Nota**; una Nota ne genera una o più (inversa, una per lacuna).
_Avoid_: flashcard, nota

**Mazzo** (_Deck_):
Un gruppo di **Carte** con le sue impostazioni di ripasso; può contenere sottomazzi.
_Avoid_: collezione, cartella

## Relationships

- Un **Candidato** ha al più uno **Spec**, scritto prima di decidere
- Un **Candidato** diventa **Originale** quando si decide di costruirne l'**App Sbu**, altrimenti è **Scartato** (serve un server o un account, è già rifatto da un'altra **App Sbu**, oppure è un **Concorrente** di un **Originale** esistente); una funzione già presente in iOS non basta a scartarlo
- Il PRD si scrive per un'**App Sbu**, mai per un **Candidato**
- Un'**App Sbu** rifà esattamente un **Originale**
- Un'**App Sbu** ha esattamente una **Cosa sola** e zero o una **Cifra** (Sbu Scanner non ne ha)
- Un'**App Sbu** ha esattamente un **Accento**, e un **Accento** appartiene a una sola **App Sbu**
- L'**Accento** di Sbu Subscriptions ha lo stesso valore del **Brand** ma resta un concetto distinto
- Un'**App Sbu** ha esattamente una **Schermata strumento**, che mostra la **Cifra** se esiste, e zero o più **Schermate di gestione**
- L'icona di un'**App Sbu** è il suo **Accento** pieno con un solo **Glifo**
- Un'**App Sbu** rispetta tutte le **Promesse**; se ne viola una non si pubblica
- Il **FreeBadge** mostra un sottoinsieme fisso di quattro **Promesse**
- Un **Originale** può avere zero o più **Concorrenti**; un **Concorrente** non genera una nuova **App Sbu**

## Flagged ambiguities

- "app" indicava sia l'**App Sbu** sia l'**Originale** (README del design system, `spec.py`, cartelle `research/<app-id>/`) — risolto: sono concetti distinti; "app" da sola significa sempre **App Sbu**.
- Il design system scriveva "nessun tracking invasivo" e "dati salvati solo su questo dispositivo" nel blocco della descrizione, e quattro frasi diverse nel **FreeBadge** — risolto: le **Promesse** sono sei, senza "invasivo"; "dati solo su questo iPhone" nel badge è la stessa promessa di "dati solo sul dispositivo".
- Il design system diceva che il **Glifo** è "l'oggetto dell'app, non una metafora", ma Sbu Dark (luna) e Sbu Block (scudo) usano metafore — risolto: sono ammessi i simboli che iOS usa già per quel concetto; restano vietate le metafore creative (lampadine, razzi).
- "già coperto" come motivo di **Scartato** poteva voler dire coperto da iOS o da un'altra **App Sbu** — risolto: solo un'altra **App Sbu**; scanner di Note e Suoni di sottofondo di iOS non scartano CamScanner+ e White Noise.
