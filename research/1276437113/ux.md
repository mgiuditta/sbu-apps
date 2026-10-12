# Otter Transcribe Voice Notes: UX

Fonti: scheda App Store (`meta.json`), 6 screenshot (`screenshots/`), 7 recensioni 1-3 stelle IT (`reviews.json`) più il feed pubblico US letto senza salvarlo, pagine web citate per sezione. Descrive il comportamento, non copia testi o grafica.

## Onboarding e paywall

- Primo avvio con creazione di un account Otter: note, audio e trascrizione vivono nel cloud (una recensione lamenta di dover registrarsi anche solo per importare un file). Il piano Basic è gratuito, il paywall Pro appare quando si tocca una funzione bloccata (velocità di riproduzione, esportazione pdf/docx/srt, salto dei silenzi) o si supera un limite (30 minuti per conversazione, 300 minuti al mese, 3 import in tutto).
- Recensioni: la prova gratuita di una settimana viene trovata troppo corta; "si paga tutto"; a fine abbonamento le note vecchie (anche l'audio) non sono più scaricabili.
- Fonti: https://otter.ai/pricing, scheda App Store, feed recensioni US.

## Schermate e disposizione

1. **Home**: barra superiore con menu a sinistra, campana notifiche con badge, ricerca e caricamento file a destra. Sezione "In arrivo" con card orizzontali dei meeting di calendario (titolo, orario, interruttore riassunto automatico) e link all'agenda. Sotto, le note di oggi come card: titolo, avatar partecipanti, ora, durata, proprietario, cartella, tre punti di riassunto, immagine della slide catturata. Pulsante microfono flottante in basso a destra. Tab bar con Home e Chat IA. (screenshot 01)
2. **Scelta registrazione**: foglio dal basso, se c'è un evento in corso: riga evento con orario, riga "nuova registrazione". (screenshot 03)
3. **Nota, tab Trascrizione**: titolo con aggiungi persone, espandi, altro. Chip orizzontali Riassunto / Trascrizione / Chat / Commenti. Titolo grande, data, durata, proprietario. Paragrafi con avatar, nome del parlante e timestamp. Durante la registrazione, barra in basso: punto rosso, onda, tempo, pausa, stop, evidenzia, commento, foto. (screenshot 02)
4. **Nota, tab Riassunto**: paragrafo di sintesi, elenco azioni con checkbox e avatar assegnatario, riga "aggiungi azione", schema per argomenti con punti elenco. (screenshot 04)
5. **Nota, tab Chat**: conversazione con l'assistente, campo messaggio in basso. (screenshot 05)
6. **Chat IA globale**: domande su tutte le riunioni, risposte con link alle note sorgente. (screenshot 06)
7. **Impostazioni**: account, vocabolario personalizzato (aggiungi nomi e termini), lingua di trascrizione, calendari e contatti collegati, notifiche. Fonte: https://gotranscript.com/public/comprehensive-guide-to-using-otter-ai-for-note-taking-on-your-smartphone

## Feature passo per passo

- **Registrare**: tocco sul microfono → (scelta evento) → la trascrizione compare dal vivo, solo se online → pausa (il microfono diventa ripresa) → stop avvia l'elaborazione. Lo schermo può essere spento, la registrazione continua. Fonte: guida gotranscript sopra; scheda App Store ("transcribe in real time when online").
- **Evidenziare**: tocco sul pulsante evidenzia marca la frase appena detta; le evidenze si raccolgono in un pannello "Takeaways" e il conteggio compare sulla nota. Fonte: guida gotranscript; scheda App Store.
- **Foto**: il pulsante fotocamera apre la fotocamera; la foto finisce nella trascrizione al momento dello scatto. Fonte: guida gotranscript.
- **Riproduzione**: play sotto la nota; la parola corrente è evidenziata; tocco su una parola salta l'audio lì; velocità 0,5x-3x e salto silenzi solo a pagamento. Fonti: scheda App Store, https://otter.ai/pricing
- **Ricerca**: icona sulla home per tutte le note; dentro la nota mostra il numero di risultati e li evidenzia. Fonte: guida gotranscript.
- **Modifica**: tocco sul paragrafo, modifica, conferma con spunta; matita per la modalità modifica; titolo modificabile. Etichetta dei parlanti manuale, poi Otter impara la voce. Fonti: guida gotranscript, scheda App Store.
- **Import**: icona nuvola → file audio/video → trascrizione. Basic: 3 import in tutto; Pro 10 al mese. Fonte: https://otter.ai/pricing
- **Esportazione**: audio mp3 e testo txt gratis; pdf, docx, srt da Pro; esportazione multipla da Business. Una recensione lamenta di non poter copiare tutta la trascrizione in una volta. Fonte: https://otter.ai/pricing
- **Riassunto e chat IA**: generati sui server dopo la riunione; chat con limiti mensili (20 domande gratis, 3 per conversazione). Fonte: https://otter.ai/pricing
- **OtterPilot**: bot che entra in Zoom/Meet/Teams dai calendari, cattura slide e scrive il riassunto. Recensioni: a volte non entra. Fonte: scheda App Store.
- **Lingue**: inglese, spagnolo, francese, giapponese secondo la scheda IT; altre fonti citano anche tedesco e cinese. Niente italiano: è il primo motivo delle stelle basse IT. Fonti: scheda App Store, https://sonix.ai/resources/otter-ai-review/

## Gesti

Tocco su parola per saltare l'audio; scorrimento orizzontale delle card "In arrivo" e delle chip della nota; multiselezione con spunta per spostare in cartella (menu tre puntini → Sposta in cartella). Fonte: guida gotranscript.

## Widget, Watch, Shortcuts, Live Activity

- Widget Home Screen e Siri Shortcut per avviare e fermare la registrazione; registrazione via AirPods. Fonte: scheda App Store ("Start/Stop recording with Siri Shortcut & home widget").
- Nessuna Live Activity o widget Lock Screen documentati nelle fonti trovate. Nessuna app Watch citata nella scheda.

## Prezzi

| Piano | Prezzo | Minuti/mese | Max per conversazione | Import |
|---|---|---|---|---|
| Basic | gratis | 300 | 30 min | 3 in tutto |
| Pro | 16,99 USD/mese o 8,33 USD/mese annuale | 1.200 | 90 min | 10/mese |
| Business | 30 USD/mese o 19,99 USD/mese annuale | illimitati | 4 h | illimitati |
| Enterprise | su richiesta | illimitati | 4 h | illimitati |

Fonte: https://otter.ai/pricing (confermato da https://sonix.ai/resources/otter-ai-pricing/).
