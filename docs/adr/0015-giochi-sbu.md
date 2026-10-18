# Giochi Sbu: i giochi più giocati, senza pubblicità, con le regole del Quaderno

sbu.dev rifà anche i giochi gratuiti più giocati dell'App Store (Block Blast per primo), senza pubblicità né acquisti, uno al mese in aggiunta alle **App Sbu**. Un **Gioco Sbu** ha un **Originale** come un'App Sbu, ma la sua **Cosa sola** è una meccanica, e i giochi in classifica sono già gratis: si rifà il gioco togliendo il motore dei soldi, non il prezzo. Le regole del Quaderno valgono con queste eccezioni e aggiunte:

- **La Cifra è il punteggio.** Una per schermata, in `ink`, Bricolage tabulare, `wdth` 87. Tra 72 e 144 pt (non 144–216): la griglia di gioco deve stare con il vassoio dei pezzi in una schermata, anche su iPhone SE.
- **Il Punto fermo** è `waiting` durante la partita e diventa `set` solo quando la partita batte il **Record**.
- **I pezzi hanno colore** (eccezione a "inchiostro, non colore", decisa da Matteo il 18/10 dopo la prova sul telefono): ogni forma prende l'accento di un'altra App Sbu (Subscriptions, Scanner, Habits, Clean, Moon, Level, Libretto, Tidy), mai quello del gioco, che resta al punto fermo. L'ombra del pezzo trascinato e le righe che completa prendono il suo colore. I controlli restano in inchiostro: il selettore Del giorno / Libera è disegnato sulla carta, non è un controllo di vetro sulla barra di vetro.
- **La Chiusura** ("Battuto.") arriva solo quando batti un Record che esisteva già, mai a ogni partita e mai alla prima.
- **La Partita del giorno**: pezzi generati da un seme che è la data, uguali per tutti, un tentativo al giorno, calcolati sul dispositivo. I pezzi vengono solo dal generatore: nessuna difficoltà adattiva, nessun pezzo scelto per farti perdere o per farti tornare.
- **Niente dark pattern**: niente vite, energia, monete, attese, streak che si perdono, notifiche per tornare, pubblicità, acquisti o Game Center al lancio. La partita si salva a ogni mossa e si chiude quando vuoi tu.
- **Movimento**: oltre a `SbuMotion`, il pezzo trascinato segue il dito senza animazione (è il gesto, non un'animazione) e si posa con la molla `spring`; le righe completate si svuotano in `short`. Aptica: `tick` quando il pezzo entra nella griglia, `dot` quando si posa, `closure` sul Record. Con Riduci movimento, solo opacità.
- **Shell**: `SbuAppShell` come ogni App Sbu; nelle impostazioni il Record e gli altri giochi di sbu.dev.

Motivo: il genere è saturo e Apple rifiuta i cloni con la 4.3 anche quando codice e grafica sono rifatti (rifiuto sbu.dev del 14/10/2026). La differenza dichiarata, che regge in review e nel marketing, è la stessa meccanica senza il motore dei soldi, disegnata come tutto sbu.dev: inchiostro su carta a quadretti.
