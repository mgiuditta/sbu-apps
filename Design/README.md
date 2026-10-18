# Design

Direzione **Quaderno** (design system v5, ADR-0013): Sbu è un quaderno a quadretti. Il punto fermo è un quadretto riempito, l'unico colorato della pagina; tutto il resto discende dal quadretto. Riferimento visivo: canvas "Firma Sbu — prima e dopo", riga A · Quaderno e la Chiusura della riga B (https://claude.ai/artifact/P18NAmURkuVfeZwBkdYKna).

## Fonte

`tokens.json` (v5) è l'unica fonte per colori, tipo, spazi, raggi, reticolo, punto fermo, controlli, movimento. Dopo ogni modifica: `python3 Tools/sync_tokens.py`. Genera i colorset e `SbuTheme+Tokens.swift` (con `SbuAccent.<app>`) in SbuKit e `Site/src/styles/tokens.css`, e si ferma se un contrasto promesso scende sotto WCAG (testo 4,5:1, `ink` 7:1, punto fermo e `accent-on-ink` 3:1). `SbuContrast.ratio` rifà lo stesso controllo nei test di SbuKit.

## Regole

- **Carta e reticolo.** Fondo `paper`. Sulle aree carta (zona della figura, stati vuoti, primo avvio) il reticolo da una cella (`grid-cell` 24, linee 1 px in `grid`, una riga sul margine di 16): `.sbuPaper(grid: true)`, disegnato in `Canvas`. Mai sotto righe di `List`/`Form`, mai sotto foto, PDF o anteprime dell'utente. Mai gradienti o immagini.
- **Una figura.** `SbuFigure`: Bricolage Grotesque ExtraBold variabile, cifre tabellari, 144–216 pt allineata alle celle; `ViewThatFits` su wdth 100/87/75 e una riga sola (non va mai a capo, fino ad AX5). VoiceOver la legge come un solo elemento con l'etichetta completa.
- **Il punto fermo.** `SbuFullStop`: tre stati, `absent`, `waiting` (in `inkMuted`: nulla da contare o processo in corso), `set` (accento dell'app); tre taglie, `hero` 24 (una cella), `inline` 16, `mark` 10. Uno solo `set` per schermata o widget (in DEBUG SbuKit avvisa se sono di più). VoiceOver lo ignora.
- **Titolo e cartiglio.** `SbuScreenTitle`: titolo in Bricolage ExtraBold 34 wdth 87, sotto una riga di cartiglio in IBM Plex Mono Medium 11 maiuscolo, tracking 0,1 em, `inkMuted` (`SBU · ABITUDINI · SAB 17 OTT`). Plex Mono solo per metadati, mai per le cifre. Il resto del testo è SF con stili Dynamic Type.
- **Inchiostro.** Tint, controlli, bottoni pieni e link in `ink`. `SbuToggleStyle` (pista 50×28 raggio 4, pomello quadrato 22 raggio 2), `SbuCheckboxStyle` (22×22, bordo 1,8, raggio 3, spunta `paper` su `ink`): stili sopra i `Toggle` di sistema, mai viste che li sostituiscono. `SbuRowMark` (10×10 pieno o vuoto, bordo 1,6) è l'unico segno di stato nelle righe oltre al testo.
- **Card e raggi.** `radius-card` 6 per card e bottoni; `SbuListCard` è bianca (`surfaceRaised`) con bordo 1 px `line`. 10/14/20 solo per fogli e per quello che disegna il sistema.
- **Chiusura.** Al completamento la figura lascia il posto a una parola sola e al punto fermo per 2 s (`.sbuClosure`), in un blocco d'inchiostro (`ink`, raggio 14, parola in `paper`, punto in `accentOnInk`). L'unica superficie scura oltre al Parabrezza di Sbu Speed (ADR-0011); mai all'avvio, una volta per evento.
- **Un solo tempo** (ADR-0014). `SbuMotion.short` 180 ms easeOut, `.base` 320 ms easeInOut, `.spring` 0,42/0,82. `SbuHaptic`: `tick`, `dot`, `closure`. Riduci movimento: solo opacità, durata zero. Suono `punto.caf` opzionale, spento.
- **Vuoto e primo avvio.** `SbuEmpty`: "0" con punto `waiting`, una frase in seconda persona, un bottone nativo. Niente illustrazioni, caroselli o permessi chiesti in anticipo.
- **Widget e Live Activity.** `SbuWidgetFigure` (64) e `SbuLiveFigure` (40): figura, punto, etichetta su carta con reticolo. Punto `waiting` durante, `set` alla fine; una Live Activity `set` si chiude dopo 4 s. Lock Screen: punto `.widgetAccentable()`, inline `■`.
- **Vietato.** Gradienti, ombre (solo marketing), bordi colorati, stelle, "PRO", aspetto da paywall, icone personalizzate nell'interfaccia, schermate scure o colorate (eccetto Chiusura e Parabrezza), emoji e punti esclamativi.

## Perché non sembra piatta

Tre principi tengono insieme le regole; servono a decidere i casi che le regole non coprono.

- **Piani.** Dietro la carta col reticolo, al centro la figura grande, sopra i controlli. La profondità viene dalla scala e dal reticolo, non dalle ombre.
- **Un colore segnale.** Il punto fermo `set` è l'unico colore; tutto il resto è carta, inchiostro e quello che disegna il sistema. Se serve un secondo colore per farsi notare, l'elemento è nel piano sbagliato.
- **Due taglie.** Una enorme (la figura) e il resto piccolo (stili Dynamic Type da `body` in giù, più il titolo della schermata). Niente nel mezzo: un numero in `title2` dentro una riga fa concorrenza alla figura; va in `body` con cifre monospaziate.

## Cartelle

- `logos/`: `sbu-logo.svg` (il logo, non si ridisegna), `sbu-mark.svg` (il logo in carta su nero caldo).
- `icons/`: icone incise (strumento in `ink` su carta, quadrato nell'accento in basso a destra) da `Tools/make_icons.py`; `engravings.json` e `source/` tengono soggetti e maschere. Una sola icona alternativa, **Inversa** (carta su inchiostro), uguale per tutte le app (`--inverse`), scelta con `SbuIconPicker` nelle Impostazioni.
- `fonts/`: Bricolage Grotesque variabile (wght, wdth, opsz) e IBM Plex Mono Medium, OFL; le stesse in SbuKit e sul sito.
