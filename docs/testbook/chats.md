# Sbu Chats: libro dei test su iPhone

Branch `app/chats-1.0`. Prova su un iPhone vero con WhatsApp e almeno una chat lunga (meglio un anno o più, con foto). Spunta ogni casella; se qualcosa non va, annota il numero del passo.

Le tue chat vere restano sul telefono: **non metterle mai nel repo** (#467). I file di test nel repo sono tutti inventati (`Apps/SbuChats/scripts/make_fixtures.py`).

## Mappa delle schermate: The Cringe → Sbu Chats

| The Cringe: Chat Wrapped | Sbu Chats | Differenze volute |
|---|---|---|
| Onboarding e paywall | Elenco vuoto: "Nessuna chat", come esportare, "Scegli un file", "Prova con una chat di esempio" | Niente paywall, nessuna statistica bloccata |
| Upload con caricamento | Foglio "Leggo la chat" con barra e Annulla | Errori spiegati, mai una rotella infinita |
| Scelta della persona | Foglio "Chi sei?" | Ricordato per le chat dopo |
| Dashboard colorata | Schermata della chat su carta: cifra "MESSAGGI" con il punto fermo, periodo, una sezione per persona | Un solo colore, la cifra in inchiostro |
| Grafici | Attività: Ora, Giorno, Mese, Anno, tu in viola e gli altri in grigio | |
| Parole frequenti | Parole ed emoji, di tutti o di una persona | |
| (non c'è) | Cerca nei messaggi, Periodo, reimport che aggiunge i nuovi | |

## A. Solo sul telefono vero (prima di tutto)

1. [ ] **Export da iPhone, senza media, dal foglio di condivisione.** In WhatsApp apri una chat a due lunga → tocca il nome in alto → Esporta chat → Senza media. Nel foglio di condivisione cerca **Sbu Chats** nella riga delle app (se non c'è, tocca "Altro" in fondo alla riga). Atteso: Sbu Chats si apre, compare "Leggo la chat" con la barra che avanza, poi il foglio "Chi sei?" con i nomi della chat (il tuo è come appare nella chat, di solito il tuo nome profilo WhatsApp). Scegli il tuo nome → Conferma: si apre la chat con "MESSAGGI" e il numero chiuso dal quadratino viola, sotto le date dal primo all'ultimo messaggio. Annota: secondi dall'apertura al foglio "Chi sei?" (atteso sotto 5 s per una chat da 40.000 messaggi).
2. [ ] **Numeri credibili.** Sulla stessa chat: la data finale è il giorno dell'export; la data iniziale non è più vecchia di quanto WhatsApp ha esportato (al massimo ~40.000 messaggi). Controlla 3 cose a mano in WhatsApp: (a) l'ultimo messaggio della chat c'è, cercandone una parola in "Cerca nei messaggi" esce con l'ora giusta; (b) un messaggio su più righe si trova intero; (c) "Foto, video e altri file" della persona che ne manda di più è nell'ordine di grandezza giusto.
3. [ ] **Export con media (ZIP grande).** Rifai l'export della stessa chat scegliendo **Allega media**. Condividi con Sbu Chats. Atteso: nessun blocco anche con uno ZIP di centinaia di MB (legge solo il testo), poi **nessun "Chi sei?"** (la chat è riconosciuta) e la chat si apre con in alto "✓ Nessun messaggio nuovo: la chat era già aggiornata" (o "Aggiunti N messaggi nuovi" se ne sono arrivati nel frattempo). Nell'elenco c'è ancora **una sola** chat.
4. [ ] **Reimport con messaggi nuovi.** Scriviti 3 messaggi nella chat, esportala di nuovo senza media, condividila. Atteso: "Aggiunti 3 messaggi nuovi" (anche "Aggiunto 1 messaggio nuovo" al singolare se ne mandi uno), il totale cresce di 3, una sola chat nell'elenco.
5. [ ] **Da File.** Esporta una seconda chat con "Salva su File". In Sbu Chats tocca l'icona in alto a sinistra (Importa una chat) e scegli il file. Atteso: come al passo 1. Il file resta in File (non viene cancellato).
6. [ ] **Export da Android** (se hai un Android o chiedi a qualcuno). Su Android: chat → ⋮ → Altro → Esporta chat → Senza media; mandati il .txt (email o Drive) e aprilo con Sbu Chats. Atteso: importa, il titolo è il nome della chat, gli orari sono giusti (confronta 2 messaggi). Prova anche, se puoi, un telefono in inglese con orario a 12 ore (AM/PM).
7. [ ] **Chat di gruppo.** Esporta un gruppo con più di 4 persone. Atteso: "Chi sei?" elenca tutti; nella chat compare la sezione "Persone" con ogni nome, messaggi e percentuale; toccando un nome si apre la sua scheda. Gli avvisi di WhatsApp ("X ha aggiunto Y", "I messaggi e le chiamate sono crittografati…") **non** contano come messaggi.
8. [ ] **Chi sei ricordato.** Importa un'altra chat in cui ci sei tu: atteso **nessun** "Chi sei?", la sezione "Tu · <tuo nome>" è già la prima.
9. [ ] **File sbagliato.** Condividi con Sbu Chats una nota o un .txt qualsiasi (da File). Atteso: foglio "Importazione" con "Non riconosco il formato", la prima riga del file in "Riga trovata", "Come esportare una chat" e "Nulla è stato importato. Il file resta dov'era." Chiudi: l'elenco è com'era.
10. [ ] **Annulla.** Importa la chat più lunga che hai con media e tocca subito Annulla. Atteso: il foglio si chiude, nessuna chat nuova o a metà nell'elenco.
11. [ ] **Senza rete.** Attiva la modalità aereo e ripeti un import (passo 5). Atteso: funziona uguale. Sbu Chats non chiede mai l'accesso alla rete locale né ad altro.
12. [ ] **Persistenza e aggiornamento.** Chiudi l'app dal multitasking e riaprila: le chat ci sono, con il tuo "Chi sei". Installa sopra una build nuova: idem.

## B. Funzioni (anche sul simulatore, ma ricontrolla sul telefono)

13. [ ] **Periodo.** Nella chat, Periodo → Ultimi 30 giorni: il totale scende, sotto compare "Fino all'ultimo messaggio della chat, il <data>." Personalizzato: compaiono "Dal" e "Al", cambiando le date tutti i numeri cambiano. Tutta la chat: torna il totale iniziale.
14. [ ] **Tempi di risposta.** "Risposta tipica" e "Risposta media" per ognuno, in "s", "min", "h", "g". Chi risponde più in fretta nella vita ha la tipica più bassa. Il footer della sezione "La chat" spiega 6 ore e 24 ore.
15. [ ] **Attività.** Ora / Giorno / Mese / Anno: le barre viola sono i tuoi messaggi, quelle grigie gli altri (legenda "Tu", nome dell'altro). In alto "Il momento più attivo: …". Tocca o trascina una barra: in alto il suo nome, i messaggi e la divisione "Tu N · Altro M". Nessuna etichetta dell'asse tagliata con "…".
16. [ ] **Parole ed emoji.** Le prime parole non sono "che", "di", "il", "the", "and" né pezzi di link. Le emoji con la pelle (👍🏽) e le famiglie (👨‍👩‍👧) contano come una. "Di chi" cambia classifica.
17. [ ] **Cerca.** Cerca una parola: elenco dal più recente, con chi, quando e la parola in grassetto. Prova `"frase esatta"` tra virgolette e `pizza OR cinema`. "Di chi" filtra per persona. Una parola che non c'è: "Nessun risultato per …".
18. [ ] **Menu della chat (•••).** "Chi sei?" cambia la persona: la sezione "Tu · …" diventa l'altra. "Rinomina" cambia il titolo in alto e nell'elenco. "Elimina la chat" chiede "Eliminare "…"?" e solo dopo cancella; torni all'elenco. Anche lo scorrimento a sinistra nell'elenco chiede prima.
19. [ ] **Chat di esempio.** Su un'installazione pulita, "Prova con una chat di esempio": chat "Chat di esempio" tra Giulia e Marco, circa 5.300 messaggi. Serve anche alla revisione Apple.
20. [ ] **Impostazioni (ingranaggio).** "Come esportare una chat" apre la guida con la nota "WhatsApp è un marchio di Meta Platforms, Inc. Sbu Chats non è affiliata a Meta."; la sezione "Sei tu" elenca i nomi scelti; scorrendo a sinistra se ne dimentica uno. In fondo la promessa sbu.dev.

## C. Accessibilità, aspetto, lingue

21. [ ] **VoiceOver.** Elenco: ogni chat si legge "nome, date, N messaggi". Chat: la cifra si legge "Messaggi, N, date" e il quadratino non si legge. Grafico: un solo elemento, "Messaggi per ora del giorno" e i valori in ordine. Parole: "1. pizza, 214 volte".
22. [ ] **Testo grande.** Impostazioni → Accessibilità → Testo più grande al massimo. Nessun testo troncato a metà parola nei titoli; il Periodo diventa una riga che apre l'elenco delle scelte; nelle Parole il numero va sotto la parola. Nota: in Impostazioni le pillole della promessa sbu.dev escono dallo schermo a destra (componente SbuKit, non di questa app; vedi report).
23. [ ] **Scuro.** Tutto su fondo scuro, il viola più chiaro, nessun testo illeggibile; i grafici restano viola e grigio.
24. [ ] **Inglese.** iPhone in inglese: "Sample chat", "Who Are You?", "Words and Emoji", "Busiest: 8 PM", date tipo "Aug 16, 2025", numeri "5,305", "Messages per day 14.8".
25. [ ] **Icona e accento.** Icona: contapersone inciso su carta con il quadrato orchidea in basso a destra. L'orchidea (`accent-chats`) è nuova: dimmi se ti va bene o se ne vuoi un'altra.
