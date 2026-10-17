# Lancio di Sbu Find: checklist

Schema generale in `docs/lancio-sbu.md`, sezione c. Qui solo l'ordine, con i file da copiare. Stato il 18/10/2026: 1.0 in `WAITING_FOR_REVIEW` su App Store Connect (app 6823934135), rilascio **automatico dopo l'approvazione** (`AFTER_APPROVAL`): il giorno 0 è il giorno in cui Apple approva, anche di sabato o domenica. Non si cambia senza ritirare la build dalla revisione: non farlo.

## Giorno 0: Apple approva

Fatto quando: `curl -s "https://itunes.apple.com/lookup?id=6823934135&country=it"` restituisce `resultCount: 1`.

- [ ] Prezzi Find Air riletti oggi su apps.apple.com (IT e US). Aggiornare data e prezzi in `hooks.md`, `docs/lancio-sbu.md` (sezione a) e in `Site/src/content/alternatives/{it,en}/find-air.md` (`checked`, `facts`).
- [ ] Sito: in `Site/src/content/apps/find.md` `status: live` e `appStoreId: 6823934135`, poi push e deploy. Così escono anche `/alternatives/find-air` (oggi 404) e il badge con `ct=site-find`. Verificare con `curl -s -o /dev/null -w "%{http_code}" https://sbu.dev/alternatives/find-air` (200).
- [ ] LinkedIn e X: post del giorno 0 di `linkedin.md`, immagine = prima slide degli screenshot 1.0. Link sbu.dev nel primo commento.
- [ ] Video 20 s (`video.md`), nativo su Reels, Shorts, TikTok, se è già girato. Va girato su iPhone vero: senza il video si parte lo stesso, il video esce al giorno 7 con il taglio sul numero.
- [ ] Riga in `marketing/log.md` per ogni post.

## Giorno 1: Show HN

Il primo martedì, mercoledì o giovedì dopo il giorno 0, tra le 15 e le 17 ora italiana. Se Apple approva lunedì: martedì. Se approva da martedì a giovedì: il giorno dopo, se non è venerdì; altrimenti il martedì seguente.

- [ ] Nessun altro Show HN nella stessa settimana (Subscriptions 2.1 va in un'altra settimana).
- [ ] Titolo e primo commento da `showhn.md`. Matteo risponde per 6 ore con le risposte pronte.
- [ ] Link al thread in `marketing/log.md`.

## Giorni 1-3: Reddit

- [ ] Rileggere sidebar e regole di ogni sub prima di scrivere.
- [ ] Un thread reale per sub, risposta da `reddit.md`, dichiarando che l'app è tua. Mai post-link, mai lo stesso testo in due sub.
- [ ] Ogni commento in `marketing/log.md`.

## Giorni 4-7: stampa, solo se un thread ha preso

Soglia: front page HN o 100+ upvote su Reddit. Altrimenti si salta.

- [ ] Una mail per testata da `press.md`, con il link al thread. Nessun follow-up prima di 5 giorni.

## Giorno 7 e giorno 14

- [ ] Giorno 7: post "come l'ho fatta" (`linkedin.md`), numeri da `git log` e `cloc` su `Apps/SbuFind`. Taglio video con l'hook 4.
- [ ] Giorno 14: post "due settimane dopo" con download (App Store Connect, 3 giorni dopo ogni post), recensioni, stelle GitHub. Il totale si calcola solo con le app pubblicate quel giorno.

## Se Apple rifiuta

- [ ] Leggere il messaggio nel Resolution Center prima di tutto. Post "Apple ha rifiutato" di `linkedin.md` solo dopo aver deciso la correzione.
