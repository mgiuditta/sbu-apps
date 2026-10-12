# Stompers: ricerca UX

Fonti pubbliche: listing App Store, screenshot in `screenshots/`, 75 recensioni 1-3 stelle in `reviews.json`, pagine web citate per sezione. Il comportamento è descritto, non copiato: niente testi, grafica o marchio di Stompers.

## Cosa è gratis e cosa no

Il conteggio dei passi di oggi e la partita giornaliera sono gratuiti. Super Stompers sblocca la "modalità 24 ore": senza, la partita smette di contare alle 21 ora locale (i passi successivi restano in Apple Health ma non nel punteggio). Le recensioni aggiungono lo storico dei giorni passati e parte dei cosmetici tra le cose a pagamento.

Fonti: https://www.stompers.com/help, https://insidehook.com/wellness/stompers-walking-app, `reviews.json` ("Pay to win", "Money grab", "As a night shift worker…").

## Onboarding e momento del paywall

1. Registrazione con numero di telefono (codice di verifica) o Sign in with Apple. L'account è sul server.
2. Creazione dello Stomper: flusso a passi con barra di avanzamento, una domanda per pagina ("hai i capelli?"), anteprima animata del personaggio e una griglia di opzioni (screenshot 04).
3. Permesso Apple Health in lettura dei passi.
4. Permesso contatti per trovare amici e permesso notifiche; le recensioni dicono che entrambi vengono richiesti di nuovo a ogni apertura.
5. Paywall Super Stompers con prova gratuita (7 giorni secondo le recensioni). Superwall documenta un test A/B: paywall a pagina singola (valore, funzioni, scelta annuale/mensile) contro una sequenza di più schermate con promemoria della prova; la pagina singola ha portato +16% di conversione. Il paywall ritorna dentro la partita con il pulsante "sblocca 24 ore" e da Me → Impostazioni.

Fonti: https://superwall.com/case-studies/stompers.md, https://www.stompers.com/help, https://sorens.beehiiv.com/p/introducing-stompers, `reviews.json`.

## Schermate

- **Home (partita)**: in alto un menu a tendina per il gruppo e il badge del profilo; sotto una striscia della settimana (L-D) con l'avatar del vincitore di ogni giorno passato e "?" per oggi; al centro l'etichetta "passi oggi", la cifra molto grande e il tempo rimasto alla fine della partita. Sotto, una pista illustrata (deserto) dove gli avatar degli amici camminano, ognuno con un fumetto di posizione e passi, il nome e da quanto si è aggiornato; oggetti raccoglibili sulla pista. In basso un pannello a scomparsa con una barra orizzontale che mette tutti i giocatori su una linea, e la tab bar a quattro voci (Home, Aggiungi, Negozio, Profilo). Screenshot 01, 03.
- **Risultato del giorno**: sheet con l'avatar, il piazzamento, la data e il totale; sotto, la classifica a schede con posizione, nome, username e passi. Screenshot 02.
- **Condividi**: anteprima di un'immagine con il podio, sotto la classifica e pulsanti verso Instagram Story, Snapchat, X e il foglio di condivisione di sistema. Screenshot 05.
- **Negozio / pacchetti**: griglia di carte illustrate con skin rare (meccanica a pacchetto). Screenshot 06.
- **Contest**: illustrazione, titolo, descrizione, tre slot per i partecipanti, pulsante Crea. Screenshot 07.
- **Me / Impostazioni**: ingranaggio con abbonamento, numero di telefono, eliminazione account.

Fonti: screenshot 01-07, https://www.stompers.com/help.

## Funzioni passo per passo

- **Conteggio passi**: Stompers non legge i sensori né gli orologi direttamente, solo Apple Health (Health Connect su Android). I passi entrano nel gioco quando apri l'app; se non la apri prima della fine, il risultato può cambiare dopo. Garmin, Fitbit e Samsung funzionano solo se scrivono i passi in Health. Fonte: https://www.stompers.com/help.
- **Giornata di gioco**: la partita va da mezzanotte alle 21 locali, poi entra in "modalità notte" e viene rivelato il podio. L'orario non è modificabile. Fonti: https://www.stompers.com/help, https://insidehook.com/wellness/stompers-walking-app.
- **Oggetti**: compaiono sulla pista circa ogni 2 ore; li raccogli se sei abbastanza vicino, altrimenti c'è un pulsante "prendi oggetto". La mazza toglie 500-750 passi a un amico, la dinamite ti spinge avanti di centinaia di passi, la banana ha il 50% di aiutare invece di colpire, il casco protegge. Gli effetti arrivano in ritardo tra fusi diversi. Fonti: https://www.stompers.com/help, https://insidehook.com/wellness/stompers-walking-app, https://embedded.substack.com/p/the-evil-genius-of-cursed-app-design.
- **Contest**: gare con regole e durata scelte e amici invitati. Fonte: screenshot 07.
- **Condivisione**: immagine del podio verso i social. Fonte: screenshot 05.

## Gamification

L'idea dichiarata dai fondatori: il conteggio dei passi non è sacro, gli amici possono sabotarlo. Avatar disegnati da un animatore professionista, classifica giornaliera, podio, striscia settimanale dei vincitori, skin rare a pacchetto, monete. Fonti: https://embedded.substack.com/p/the-evil-genius-of-cursed-app-design, https://sorens.beehiiv.com/p/introducing-stompers.

## Gesti

Tap sugli oggetti per raccoglierli e lanciarli, pannello inferiore trascinabile (maniglia visibile), sheet a scorrimento per il risultato. Nessun gesto documentato oltre a questi. Fonte: screenshot 01-03, 05.

## Impostazioni

Me → ingranaggio: Super Stompers, numero di telefono, elimina account (non annulla l'abbonamento). Nessuna regolazione delle notifiche, richiesta nelle recensioni. Fonti: https://www.stompers.com/help, `reviews.json` ("Chill on the notifications").

## Widget, Watch, Live Activity

- **Widget**: mostra la tua posizione; si aggiorna quando iOS lo decide, il FAQ consiglia di aprire l'app. Fonti: https://www.stompers.com, https://www.stompers.com/help.
- **Apple Watch**: l'evento in-app sullo Store promuove "i passi al polso"; il FAQ dice che il Watch passa da Apple Health. Non risulta un'app watchOS dedicata. Fonti: https://apps.apple.com/us/app/stompers-walking-step-counter/id6477849675, https://www.stompers.com/help.
- **Live Activity**: nessuna traccia pubblica.

## Prezzi

Super Stompers: settimanale 4,99 $, mensile 9,99 $, annuale 39,99 $ o 59,99 $ (Superwall riporta test a 49,99 $ e 79,99 $). Monete: 1,99 $, 3,99 $, 7,99 $, 13,99 $; due offerte da 3,99 $. Etichette privacy: identificatori usati per il tracciamento; salute, acquisti, contatti, contenuti, utilizzo legati all'identità. Fonti: https://apps.apple.com/us/app/stompers-walking-step-counter/id6477849675, https://superwall.com/case-studies/stompers.md.

## Viralità

App "dell'estate" 2024 secondo InsideHook, nata da Soren Iverson, designer noto per i concept satirici virali su X/Twitter. Leve: classifica tra amici, sabotaggio, condivisione del podio sui social, inviti dai contatti, notifiche. Circa 12.000 valutazioni a 4,8 negli USA. Nessuna prova pubblica di un picco su TikTok. Fonti: https://insidehook.com/wellness/stompers-walking-app, https://embedded.substack.com/p/the-evil-genius-of-cursed-app-design, https://apps.apple.com/us/app/stompers-walking-step-counter/id6477849675.
