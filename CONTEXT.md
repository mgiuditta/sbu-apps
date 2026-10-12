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
I giorni di fila in cui tutte le abitudini previste quel giorno sono state fatte; le abitudini settimanali non vi entrano. È la **Cifra** di Sbu Habits.
_Avoid_: serie totale, giornata perfetta

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
