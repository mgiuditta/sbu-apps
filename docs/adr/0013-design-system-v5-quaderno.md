# Design system v5 "Quaderno": il punto fermo è un quadretto riempito

Sostituisce la direzione v4 "Carta e punto fermo" (regole di design in CLAUDE.md, `Design/tokens.json` v4). Sbu è un quaderno a quadretti: il **Punto fermo** è l'unico quadretto colorato della pagina, e tutto il resto discende dal quadretto. Il **Reticolo** da una cella (24 pt) sta sotto le aree carta, la **Cifra** si allinea alle celle, il punto fermo grande misura esattamente una cella, controlli e marcatori sono quadrati in inchiostro. Fonte unica resta `Design/tokens.json` (v5), da cui escono SbuKit e le CSS vars del sito.

Deroghe alla v4, approvate qui:

- **Titoli in Bricolage.** I titoli di schermata sono Bricolage Grotesque ExtraBold 34 pt, larghezza 87; prima tutto il testo era SF. Il resto del testo resta SF con stili Dynamic Type.
- **Controlli nativi con stile custom.** `Toggle` usa `SbuToggleStyle` (pista e pomello quadrati in inchiostro), la checkbox è un `Toggle` con `SbuCheckboxStyle`; prima i controlli erano intoccati. Restano controlli di sistema: tratti, stati e accessibilità sono quelli di Apple, mai viste che li sostituiscono.
- **Punto fermo con tre stati.** `absent`, `waiting` (in `inkMuted`, quando non c'è nulla da contare o il processo è in corso) e `set` (accento); prima era sempre nell'accento. Uno solo `set` per schermata o per widget.
- **Reticolo come texture.** Le aree carta (zona della figura, stati vuoti, primo avvio) hanno il reticolo disegnato in `Canvas`; prima il fondo era uniforme. Mai sotto righe di `List`/`Form` né sotto contenuti dell'utente.
- **Blocco d'inchiostro per la Chiusura.** Alla **Chiusura** la figura lascia il posto a una parola sola e al punto fermo, per 2 s, dentro un rettangolo `ink` con raggio 14; prima nessuna superficie scura. È la seconda superficie scura ammessa dopo il Parabrezza (ADR-0011), solo durante la Chiusura, mai all'avvio, al massimo una volta per evento.
- **Plex Mono per i metadati.** IBM Plex Mono Medium 11, maiuscolo, solo per il **Cartiglio** e i metadati (date, contatori di riga, unità nelle righe); mai per le cifre.
- **Tint in inchiostro.** I controlli, i bottoni pieni e i link sono in `ink`; prima il tint era l'accento. L'unico colore della schermata è il punto fermo `set`, schiarito in `accentOnInk` dentro il blocco d'inchiostro.

Restano vietati gradienti, ombre (solo marketing), bordi colorati, stelle, "PRO", aspetto da paywall, icone personalizzate nell'interfaccia, schermate scure o colorate fuori da Chiusura e Parabrezza, emoji e punti esclamativi. Le icone app restano incise; si aggiunge una sola icona alternativa, **Inversa** (carta su inchiostro), uguale per tutte le app e scelta nel foglio Impostazioni condiviso. ADR-0001 e ADR-0012 restano validi: la tab bar di Sbu Subscriptions prende lo stile v5 senza nuove eccezioni.

Motivo: la v4 era riconoscibile solo per il quadrato; con 18 app serviva una regola che generi da sola schermate, widget e sito senza decisioni per app. Alternative scartate: "Blocco d'inchiostro" come zona della figura sempre scura (contro la carta), "La cifra è la pagina" (taglia la cifra ai bordi, fragile con Dynamic Type) e "Stampato" (filetti e grana, meno legato al quadretto).
