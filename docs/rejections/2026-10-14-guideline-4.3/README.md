# Rifiuto 4.3 / 4.2.6 del 14 ottobre 2026

Sei app 1.0 rifiutate insieme la sera del 14/10 (Clean, Speed, Moon, Habits, Noise, Level), stesso messaggio: Guideline 4.3(a) duplicati, 4.3(b) variante opportunistica, 4.2.6 app da template o servizio di generazione. Apple non ha indicato nulla di specifico su nessuna app: è una valutazione del lotto.

Sbu Subscriptions 2.0 è in coda (Waiting for Review); Sbu Scanner 2.0 non è stata inviata. Le loro 1.x sono sullo Store da maggio e giugno 2026: due App Sbu già approvate con lo stesso brand, le stesse promesse e lo stesso SbuKit.

## Perché è successo

Segnali che un revisore (o il classificatore) legge come "template":

| Segnale | Fatto |
|---|---|
| Lotto | Sei app create su ASC tra le 10:49 e le 10:56 del 14/10 e inviate insieme. Il piano in `docs/factory.md` diceva 3 a settimana. |
| Descrizioni | Le prime sei righe sono identiche in tutte, poi l'ultima riga uguale ("Tema chiaro e scuro, testo dinamico, VoiceOver"), chiusura con la stessa formula. |
| Nome e icona | "Sbu X", stessa grammatica di icona, stessi screenshot con cornice. |
| Categoria | Livella, luna, rumore bianco, tachimetro, abitudini, pulizia foto: le sei nicchie più affollate dello Store, ciascuna con decine di cloni. Da qui il 4.3(b). |
| Codice | SbuKit condiviso. È piccolo (1.660 righe: tema, pulsanti, impostazioni, licenze) ma esiste, e Apple lo chiede al punto 7. |

Quello che non c'è: nessun template commerciale, nessun servizio, nessun cliente, codice e funzioni diverse per app (da 1.000 righe di Speed a 14.600 di Habits).

## Cosa fare

Apple dice: se credi che l'app sia conforme non reinviare, rispondi alle 9 domande. Le risposte stanno in questa cartella, una per app, in inglese, pronte da incollare nel Resolution Center di ciascuna. Sono fattuali, in prima persona, senza marketing, e dicono la verità anche dove è scomoda (punto 4: il beta test è stato interno, con un solo tester).

1. **Rispondere, non reinviare.** Per ognuna delle sei app, dal messaggio di Apple → Reply, incollare il testo del file. Meglio tutte e sei nella stessa serata, così chi legge vede che il punto 5 è coerente tra le app.
2. **Non toccare Subscriptions 2.0 in coda.** È l'aggiornamento di un'app approvata: se passa, è un precedente in più.
3. **Non inviare Scanner 2.0 finché non arriva una risposta** sulle sei.
4. **Se Apple accetta le risposte**, da qui in poi un invio alla settimana, mai due nella stessa settimana, e nelle note per la revisione la riga "come si distingue dalle altre App Sbu" (c'è già in Scanner e Subscriptions, manca nelle sei).
5. **Se Apple rifiuta di nuovo** sulle stesse 9 domande: appello all'App Review Board (developer.apple.com/contact/app-store, "Appeal"), una sola app per volta, partendo da Habits (la più grande, 14.600 righe, Watch, Salute, iCloud) o Clean. Non reinviare le sei insieme.

## Da decidere tu (non l'ho fatto)

- **Descrizioni dello Store.** Il blocco promesse identico in testa a sei descrizioni è il segnale più forte e più facile da togliere. Proposta: prima riga su cosa fa l'app, promesse in una riga sola in fondo. Cambia una regola di CLAUDE.md e del sito, quindi aspetto il tuo sì. Si può modificare anche mentre la versione è rifiutata, senza reinviare.
- **Beta esterno.** Un gruppo TestFlight pubblico con qualche persona vera prima dei prossimi invii renderebbe il punto 4 una risposta vera invece di una ammissione.

## Rischio

Un secondo rifiuto 4.3 sullo stesso lotto non chiude l'account, ma un terzo giro di invii uguali può portare a un avviso sull'account. Per questo: rispondere una volta, con cura, e non reinviare finché non si capisce cosa pensano.
