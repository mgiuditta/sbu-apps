# Summary - AI Note Taker (Labhouse): UX

Fonti: scheda App Store IT (`meta.json`), 9 screenshot (`screenshots/`), 7 recensioni 1-3 stelle IT (`reviews.json`) più il feed pubblico US letto senza salvarlo, pagine web citate per sezione. Descrive il comportamento, non copia testi o grafica.

## Onboarding e paywall

Ordine osservato nei walkthrough pubblici:

1. Richiesta App Tracking Transparency (tracciamento per pubblicità personalizzata).
2. Splash e schermata introduttiva con numeri di download e "inizia".
3. Accesso obbligatorio con Apple o Google (una recensione lo considera un motivo per non usarla).
4. Tour di circa otto schermate, una funzione ciascuna (registrazione, riassunti, azioni, trascrizione parola per parola, personalizza/esporta/condividi), con permesso notifiche nel mezzo.
5. Schermata privacy, richiesta di valutazione, testimonianze.
6. **Paywall** dopo la prova sociale: prova gratuita di 3 giorni con interruttore attivo di default, confronto Free contro Unlimited, piani settimanale e annuale con badge di risparmio, FAQ. Una fonte lo descrive chiudibile (paywall morbido), un'altra dice che serve abbonarsi per entrare: in ogni caso le funzioni principali restano bloccate.
7. Libreria vuota con invito a fare la prima registrazione.

Fonti: https://screensdesign.com/apps/summary-ai-note-taker/ , https://screensdesign.com/showcase/summary-ai-note-taker

## Schermate e disposizione

1. **Libreria**: titolo grande con icona microfono, campo di ricerca e ingranaggio, chip filtro Tutti / Preferiti / Cartelle / YouTube, righe con miniatura emoji generata, titolo, badge della fonte, ora o data, durata, menu tre puntini. Pulsante per un nuovo riassunto. In multiselezione barra in basso con sposta, unisci, preferito, elimina. (screenshot 08; screensdesign)
2. **Foglio "nuovo"**: registra audio, carica file (audio, PDF), crea nota, registra chiamata. (screensdesign)
3. **Registrazione**: onda, timer, interruttore trascrizione dal vivo, annulla, pausa (che mostra annulla e riprendi), stop. Dopo lo stop, schermata di avanzamento in fasi: caricamento, trascrizione, riconoscimento parlanti, riassunto. (screensdesign showcase)
4. **Nota**: indietro, cuore preferito, condividi, altro; titolo; controllo segmentato Riassunto / Trascrizione / Chat; lettore audio fisso in basso con cursore e durata totale. (screenshot 02, 04, 05)
   - **Riassunto**: sezioni Riassunto, Azioni (casella, chip col nome dell'assegnatario, titolo, descrizione), Punti salienti, Prossimi passi, Conclusione. Pulsante Modifica per lunghezza, lingua e modello del riassunto. (screenshot 03, 05)
   - **Trascrizione**: paragrafi con parlante e timestamp, pannello di riproduzione flottante.
   - **Chat**: saluto dell'assistente, domande suggerite, bolle. (screenshot 04)
5. **Condividi**: foglio con "condividi riassunto" (testo) e "condividi PDF", poi il foglio di sistema (AirDrop, Messaggi, Mail, link). Tooltip la prima volta. (screenshot 05)
6. **Lingue**: elenco cercabile di lingue con rilevamento automatico; lingua del riassunto separata. (screenshot 06)
7. **Impostazioni**: account (email, esci, elimina con scorrimento), integrazioni (calendari Google/Outlook, Apple Watch, accesso da desktop), lingua app e riassunto, lunghezza riassunto con cursore, modelli, interruttori per parlanti ed etichette automatiche, notifiche (riassunti pronti, promemoria, 5 minuti prima del meeting), tema, supporto, privacy. Cestino con scadenza a 30 giorni. Fonte: https://screensdesign.com/apps/summary-ai-note-taker/

## Feature passo per passo

- **Registrare**: nuovo → registra audio → registrazione senza limiti di durata, anche a schermo bloccato o in un'altra app → stop → elaborazione sui server → la nota si apre sul Riassunto. Fonte: scheda App Store.
- **Import**: nuovo → carica file → scelta dal file system; anche PDF da riassumere. Fonte: screensdesign.
- **YouTube**: incolla un link, la nota ha il badge YouTube. Fonte: screenshot 08.
- **Chiamate**: verifica del numero di telefono, 100 minuti al mese anche a pagamento (recensioni US). Fonte: screensdesign, feed recensioni.
- **Ricerca**: parola chiave → salto al punto della registrazione. Fonte: scheda App Store.
- **Traduzione**: registra in una lingua e traduci in altre. Fonte: screenshot 06.
- **Esportazione**: PDF o testo, riassunto o trascrizione completa. Fonte: scheda App Store, screenshot 05.
- **Bot meeting**: collegato al calendario, deve essere ammesso nella chiamata. Fonte: screensdesign.

## Gesti

Tocchi su chip e segmenti; cursore del lettore; scorrimento per eliminare l'account; selezione multipla. Nessun gesto particolare documentato. Fonte: https://screensdesign.com/showcase/summary-ai-note-taker

## Widget, Watch, Shortcuts, Live Activity

- Widget Home Screen e Lock Screen con microfono per registrare, configurazione di un Comando rapido. Fonte: screensdesign.
- App Apple Watch per registrare; una recensione US riporta riunioni registrate dal Watch rimaste "in riassunto" e poi perse.
- Live Activity non documentata nelle fonti trovate.

## Prezzi

Acquisti in-app (App Store, aprile 2026): settimanale 5,99 / 7,99 / 8,99 USD, mensile 17,99 USD, annuale 79,99 / 99,99 USD. Prova di 3 giorni sul settimanale. Fonte: https://apppricinglab.com/iap/apple/6670175056

Recensioni: "3 giorni di prova poi costa un botto", "8,99 a settimana", limiti nascosti (100 minuti di chiamate, una lezione al giorno gratis).
