# Sbu Noise 1.0: libro dei test su iPhone

Branch `app/noise-1.0`. Build installata sul tuo iPhone. Le prime prove (1–14) si possono fare **solo su un telefono vero**: audio, cuffie, schermo bloccato, notifiche e sveglie a orari veri. Le altre (15–24) le ho già controllate sul simulatore; qui servono solo per conferma. Ogni prova dice cosa fare e cosa deve succedere esattamente: è superata solo se succede tutto quello che c'è scritto.

Prima di iniziare: volume dell'iPhone a metà, Full immersion spenta, cuffie a portata di mano, app appena installata. Per le prove 8–12 serve un iPhone con iOS 26; se hai anche un iPhone con iOS 17–25, la 13 va fatta lì.

## Solo su iPhone

1. **Ascolto delle registrazioni** (il controllo che le misure non possono fare)
   - Con le cuffie, ascolta ogni suono di Pioggia, Acqua, Natura, Casa e Viaggio per almeno 70 secondi: è il giro completo del loop. Temporale va ascoltato 2 minuti e 10 secondi, Mare 1 minuto e 40.
   - Atteso: niente voci, cani, clacson, annunci, musica o bip. Nessun colpo, buco o salto quando il loop ricomincia. Passando da un suono all'altro il volume percepito resta lo stesso (tutti sono a −18 LUFS).
   - Ascolta con più attenzione Città (traffico di Città del Messico), Treno (ho tolto un tratto con un bip a 1000 Hz), Orologio (al giro il ticchettio può fare un passo irregolare), Bosco (uccelli) e Fusa del gatto.
   - Se un suono non va, scrivi il suo nome e il secondo in cui lo senti.
   - [ ]

2. **Rumori contro registrazioni**: suona Rumore rosa per 10 secondi, poi passa a Pioggia forte con ⏭︎. Atteso: il volume percepito resta lo stesso, entro "poco più forte" o "poco più piano"; nessuno dei due è il doppio dell'altro.
   - [ ]

3. **Schermo bloccato, 30 minuti**: fai partire Mare, blocca lo schermo, aspetta 30 minuti. Atteso: suona senza pause per tutti i 30 minuti, e ogni 90 secondi (il giro) non si sente nessuno stacco. Sulla schermata bloccata c'è la scheda "Mare / Sbu Noise", e pausa e play funzionano.
   - [ ]

4. **Cuffie**: con un suono in riproduzione, stacca le cuffie a filo o togli gli AirPods. Atteso: il suono va in pausa entro un secondo e non riparte dall'altoparlante.
   - [ ]

5. **Mix con 5 registrazioni**: Crea → Nuovo mix con Pioggia forte, Fuoco, Vento tra i pini, Ruscello e Notte → Avanti → Fine → Salva. Lascialo suonare 5 minuti, poi scorri avanti e indietro tra 10 suoni. Atteso: l'app non si chiude e non si blocca, e ogni cambio di pagina suona entro mezzo secondo.
   - [ ]

6. **Sveglia nell'app, schermo bloccato** (il caso principale)
   - Timer → + → Nuova sveglia: ora attuale + 3 minuti, Suono Rintocchi, Dissolvenza in entrata 1 minuto → Salva. La prima volta l'iPhone chiede il permesso: tocca Consenti.
   - Fai partire Pioggia forte e blocca lo schermo.
   - Atteso: all'ora esatta (±5 secondi) la pioggia si ferma e i Rintocchi partono dal silenzio, fino al volume pieno in circa 60 secondi. Sulla schermata bloccata compare la notifica "Sveglia – Tocca per fermarla." con Rimanda e Ferma, e la scheda In riproduzione dice "Sveglia".
   - Tocca Ferma. Atteso: silenzio subito. Nei 5 minuti seguenti non arriva nessuna notifica e non suona nessuna sveglia di sistema. Riaprendo l'app, l'interruttore della sveglia è spento.
   - [ ]

7. **Rimanda**: ripeti la 6 e tocca Rimanda. Atteso: silenzio. Nel player la riga in alto dice "Sveglia alle" con l'ora di adesso più 9 minuti. Dopo 9 minuti (±10 secondi) suona di nuovo: nell'app se lo schermo era acceso, altrimenti come riserva.
   - [ ]

8. **Riserva iOS 26, app chiusa**: sveglia tra 3 minuti, poi chiudi l'app dal selettore delle app (scorri verso l'alto). Atteso: all'ora esatta suona la sveglia di sistema, anche con l'interruttore del silenzioso attivo, a schermo intero, titolo "Sveglia", pulsante "Ferma". Il suono deve essere quello dei Rintocchi; se senti il suono di sveglia standard di iOS, scrivilo (serve per #424).
   - [ ]

9. **Riserva iOS 26, suono in pausa**: sveglia tra 3 minuti, app aperta in background con il suono in pausa, schermo bloccato. Atteso: come la 8.
   - [ ]

10. **iOS 26, nessun doppione** (#424): sveglia tra 3 minuti con Pioggia forte in riproduzione e schermo bloccato. Atteso: suona solo la sveglia dell'app, come nella 6; la sveglia di sistema non compare né prima né dopo. Se compaiono tutte e due, oppure se la pioggia si interrompe prima dell'ora, scrivi l'orario esatto.
    - [ ]

11. **Permesso negato e Apri Impostazioni**: in Impostazioni di iOS → Sbu Noise, spegni Sveglie (iOS 26) o Notifiche (iOS 17–25), poi torna nell'app → Timer. Atteso: sotto le sveglie una riga con il triangolo: "Le sveglie di Sbu Noise sono spente: se l'app non è aperta, la sveglia non suona." (oppure "Le notifiche…"), e sotto il pulsante "Apri Impostazioni". Toccandolo si apre la pagina di Sbu Noise nelle Impostazioni.
    - [ ]

12. **Timer prima della sveglia**: aggiungi un timer di 30 minuti e una sveglia tra 2 ore. Atteso: in Timer, sotto la sveglia, compare "Il suono si ferma prima: la sveglia arriva solo come sveglia di sistema, senza dissolvenza." (su iOS 17–25: "…solo come notifica.").
    - [ ]

13. **Riserva iOS 17–25** (solo se hai un iPhone con iOS 17–25): sveglia tra 3 minuti, app chiusa dal selettore. Atteso: all'ora esatta arriva la notifica "Sveglia – Sono le HH:MM. Tocca per fermarla." con il suono dei Rintocchi, poi un'altra a ogni minuto, 5 in tutto. Toccandone una, l'app si apre e le altre spariscono. Con il silenzioso attivo la notifica vibra senza suono: è previsto.
    - [ ]

14. **Orologio Dormi, 10 minuti**: Dormi → lascia l'iPhone appoggiato per 10 minuti. Atteso: lo schermo non si spegne mai e l'ora cambia allo scoccare di ogni minuto. Tocca X: dopo il tempo di blocco automatico delle Impostazioni lo schermo torna a spegnersi da solo.
    - [ ]

## Conferme (già controllate sul simulatore)

15. **Primo avvio**: all'apertura si vede "Rumore bianco", e sotto "Suoni · 1 di 34". Nessun permesso chiesto finché non salvi una sveglia.
    - [ ]

16. **Preferiti**: tocca il cuore su Pioggia forte, poi ☰ → Preferiti. Atteso: "Preferiti · 1 di 1". Togli il cuore: compaiono "Nessun preferito" e la frase sul cuore, e i controlli diventano grigi.
    - [ ]

17. **Gruppi**: su Mare, apri ☰ → Acqua. Atteso: resta su Mare e continua a suonare, con "Acqua · 1 di 6". Poi ☰ → Pioggia: va su "Pioggia forte", "Pioggia · 1 di 6".
    - [ ]

18. **Gestisci**: scorri a sinistra su Treno e tocca Nascondi. Atteso: Treno va in "Nascosti" in fondo e non compare più nel player; toccandolo in Nascosti torna. Poi tocca Modifica, trascina Mare in cima e tocca Fine. Atteso: Mare è il primo in Suoni. Cerca "zzz": compare "Nessun risultato per "zzz"".
    - [ ]

19. **Eliminare chiede conferma**: in Timer scorri a sinistra su una sveglia e tocca Elimina. Atteso: compare la domanda "Elimina sveglia"; solo confermando la sveglia sparisce.
    - [ ]

20. **Dati che restano**: metti un cuore, nascondi un suono, crea una sveglia, chiudi l'app dal selettore e riaprila. Atteso: ritrovi tutto, e il player riapre sull'ultimo suono.
    - [ ]

21. **Crediti**: Impostazioni → Crediti dei suoni. Atteso: in cima la frase su Freesound e CC0, poi 24 registrazioni, ognuna con titolo originale, autore, "CC0 1.0" e la pagina (testo, non un link), e in fondo l'elenco "Creati da Sbu Noise".
    - [ ]

22. **Testo enorme** (Impostazioni → Accessibilità → Schermo e dimensioni testo → Testo più grande, al massimo): player, Gestisci, Timer, Nuova sveglia, la sveglia che suona, Dormi. Atteso: nessun testo tagliato; se il nome del suono va a capo, il quadratino resta attaccato all'ultima parola.
    - [ ]

23. **VoiceOver**: sul player, scorrendo, si sentono nell'ordine il nome del suono (come titolo), "Suoni · 6 di 34", Aggiungi ai preferiti, Precedente, Riproduci, Successivo, Informazioni. In Gestisci il rotore Azioni su un suono offre Nascondi e Aggiungi ai preferiti. Il quadratino non viene mai letto.
    - [ ]

24. **Inglese e scuro**: iPhone in inglese e in modalità scura. Atteso: "White Noise", "Timers and Alarms", "No Timers or Alarms", "Sound Credits"; tutto su fondo scuro con il solo accento blu. Dormi è sempre scuro, anche in modalità chiara.
    - [ ]

## Note

- I file audio vengono dalle anteprime pubbliche HQ (MP3 a 128 kbps) delle pagine Freesound CC0, ricodificate in AAC a 96 kbps. Gli originali WAV richiedono un login a Freesound: con il login si possono rifare con `SoundTools/make_sounds.py`.
- Per l'App ID va abilitata la capability Time Sensitive Notifications, che è già negli entitlements; con la firma automatica la aggiunge Xcode.
