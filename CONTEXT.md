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
La schermata principale di un'**App Sbu**, dove fa la sua **Cosa sola**: carta (`paper`) con il **Reticolo**, **Titolo** e **Cartiglio**, la **Cifra** chiusa dal **Punto fermo**.
_Avoid_: home, dashboard, prima tab

**Schermata di gestione** (_Management screen_):
Ogni altra schermata di un'**App Sbu** (impostazioni, storico, liste): `List`/`Form` nativi su `paper`, senza **Reticolo**.
_Avoid_: schermata secondaria

**Accento** (_Accent_):
Il colore di una sola **App Sbu**: solo il **Punto fermo** `set` e il quadrato dell'icona. Il tint dell'interfaccia è `ink`.
_Avoid_: colore primario, tint

**Brand**:
Il colore di sbu.dev, che in un'**App Sbu** compare solo nel footer "Parte di sbu.dev".
_Avoid_: accento di sbu.dev

**Incisione** (_Engraving_):
Lo strumento reale dietro la **Cosa sola**, inciso in `ink` sulla carta dell'icona, chiuso dal quadrato nell'**Accento**. Sostituisce il **Glifo**, ritirato.
_Avoid_: glifo, logo, illustrazione, metafora creativa

**Inversa** (_Inverse_):
L'unica icona alternativa, carta su inchiostro, uguale per tutte le **App Sbu**, scelta nelle Impostazioni.
_Avoid_: icona scura, tema

**Reticolo** (_Grid_):
Il quadrettato da una cella (24 pt) delle aree carta: zona della **Cifra**, stati vuoti, primo avvio. Mai sotto liste o contenuti dell'utente.
_Avoid_: pattern, texture, sfondo

**Punto fermo** (_Full stop_):
Il quadretto riempito che chiude la **Cifra**: `absent`, `waiting` (grigio, nulla da contare o in corso), `set` (nell'**Accento**). Uno solo `set` per schermata.
_Avoid_: quadrato, punto, bullet

**Cartiglio** (_Title block_):
La riga in IBM Plex Mono maiuscolo sotto il titolo di schermata: `SBU · ABITUDINI · SAB 17 OTT`. Solo metadati, mai cifre.
_Avoid_: sottotitolo, breadcrumb

**Chiusura** (_Closure_):
Il momento di completamento: per 2 s la **Cifra** lascia il posto a una parola sola ("Fatto.") e al **Punto fermo**, dentro il **Blocco d'inchiostro**.
_Avoid_: toast, celebrazione, conferma

**Blocco d'inchiostro** (_Ink block_):
Il rettangolo `ink` (raggio 14) della **Chiusura**, l'unica superficie scura oltre al Parabrezza di Sbu Speed.
_Avoid_: card scura, banner

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

**Sincronizzazione iCloud** (_iCloud sync_):
Le tue abitudini, con storico, salti, note, promemoria e inizio della giornata, uguali su tutti i tuoi dispositivi attraverso il tuo iCloud, mai attraverso sbu.dev. Spenta finché non la attivi in Dati; attivandola, i dati dei due lati si uniscono senza domande. Quando due dispositivi cambiano la stessa cosa: per i segni di un giorno vale il numero più alto, Salta oggi vale se uno dei due ha saltato, per impostazioni, ordine, inizio della giornata e note vale la modifica più recente, e un'abitudine eliminata resta eliminata. Ogni dispositivo pianifica le sue notifiche. Esporta e Importa restano. Non è un'**Abitudine condivisa**: riguarda solo te.
_Avoid_: backup, cloud, account

**Modello** (_Template_):
Un'abitudine pronta che scegli quando ne aggiungi una, raccolta in una delle cinque categorie (Generale, Salute, Alimentazione, A tempo, Da evitare): ti dà già titolo, simbolo, tipo, obiettivo e giorni, e tu li confermi o li cambi prima di aggiungerla. Ogni categoria ha anche la Personalizzata, che parte vuota come dice la categoria. Una volta aggiunta, l'abitudine è una come le altre e non ricorda da quale Modello viene.
_Avoid_: preset, suggerimento, abitudine predefinita

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

### Sbu Noise

**Suono** (_Sound_):
Una voce del catalogo che si ascolta in loop, generata o registrata; appartiene a una sola **Categoria**.
_Avoid_: traccia, brano, sample

**Suono generato** (_Generated sound_):
Un **Suono** prodotto in tempo reale dal codice dell'app, senza file e senza ripetizione.
_Avoid_: suono sintetico, rumore (da solo)

**Registrazione** (_Recording_):
Un **Suono** che viene da un file CC0 nel bundle, ripetuto in loop senza stacchi.
_Avoid_: sample, audio, campione

**Categoria** (_Category_):
Il gruppo di **Suoni** nel catalogo: Rumori, Pioggia, Acqua, Natura, Casa, Viaggio, Relax.
_Avoid_: sezione, scheda, il menu ☰ (che elenca Suoni, Mix, Playlist, Preferiti)

**Mix** (_Mix_):
Fino a 5 **Suoni** che suonano insieme, ciascuno con posizione, volume e tono propri; si salva con un nome.
_Avoid_: preset, scena, combinazione

**Playlist** (_Playlist_):
L'unica sequenza di **Suoni** e **Mix**, ciascuno per una durata, uno dopo l'altro.
_Avoid_: coda, scaletta

**Timer** (_Timer_):
Ferma il **Suono** a un'ora o dopo una durata, sfumandolo così che taccia proprio in quel momento. Una durata parte quando accendi il timer; se si ripete sempre, riparte a ogni nuovo suono. Un'ora si ripete nei giorni scelti, o vale una volta. Funziona solo finché un suono è in riproduzione.
_Avoid_: sleep timer, spegnimento automatico

**Sveglia** (_Alarm_):
L'ora a cui Noise ti sveglia con un suono che entra in dissolvenza; suona dentro l'app finché un **Suono** è in riproduzione.
_Avoid_: allarme, timer (il timer ferma o avvia un suono, non sveglia)

**Riserva** (_Backup alarm_):
Quello che suona se la **Sveglia** non può: notifiche locali su iOS 17–25, un allarme di sistema su iOS 26+. Si annulla quando fermi la Sveglia.
_Avoid_: fallback, sveglia di backup

## Relationships

- Un **Candidato** ha al più uno **Spec**, scritto prima di decidere
- Un **Candidato** diventa **Originale** quando si decide di costruirne l'**App Sbu**, altrimenti è **Scartato** (serve un server o un account, è già rifatto da un'altra **App Sbu**, oppure è un **Concorrente** di un **Originale** esistente); una funzione già presente in iOS non basta a scartarlo
- Il PRD si scrive per un'**App Sbu**, mai per un **Candidato**
- Un'**App Sbu** rifà esattamente un **Originale**
- Un'**App Sbu** ha esattamente una **Cosa sola** e zero o una **Cifra** (Sbu Scanner non ne ha)
- Un'**App Sbu** ha esattamente un **Accento**, e un **Accento** appartiene a una sola **App Sbu**
- L'**Accento** di Sbu Subscriptions ha lo stesso valore del **Brand** ma resta un concetto distinto
- Un'**App Sbu** ha esattamente una **Schermata strumento**, che mostra la **Cifra** se esiste, e zero o più **Schermate di gestione**
- L'icona di un'**App Sbu** è la sua **Incisione** su carta chiusa dal quadrato nell'**Accento**; l'**Inversa** è la stessa per tutte
- Una schermata ha al più un **Punto fermo** `set`; la **Chiusura** compare al più una volta per evento
- Un'**App Sbu** rispetta tutte le **Promesse**; se ne viola una non si pubblica
- Il **FreeBadge** mostra un sottoinsieme fisso di quattro **Promesse**
- Un **Originale** può avere zero o più **Concorrenti**; un **Concorrente** non genera una nuova **App Sbu**

## Flagged ambiguities

- "app" indicava sia l'**App Sbu** sia l'**Originale** (README del design system, `spec.py`, cartelle `research/<app-id>/`) — risolto: sono concetti distinti; "app" da sola significa sempre **App Sbu**.
- Il design system scriveva "nessun tracking invasivo" e "dati salvati solo su questo dispositivo" nel blocco della descrizione, e quattro frasi diverse nel **FreeBadge** — risolto: le **Promesse** sono sei, senza "invasivo"; "dati solo su questo iPhone" nel badge è la stessa promessa di "dati solo sul dispositivo".
- Il design system diceva che il **Glifo** è "l'oggetto dell'app, non una metafora", ma Sbu Dark (luna) e Sbu Block (scudo) usano metafore — risolto: sono ammessi i simboli che iOS usa già per quel concetto; restano vietate le metafore creative (lampadine, razzi).
- "già coperto" come motivo di **Scartato** poteva voler dire coperto da iOS o da un'altra **App Sbu** — risolto: solo un'altra **App Sbu**; scanner di Note e Suoni di sottofondo di iOS non scartano CamScanner+ e White Noise.
