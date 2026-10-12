# Design

Direzione **Carta e punto fermo** (design system v4): Sbu fa una cosa sola e la chiude con un punto. Carta, il nero caldo del logo, un solo quadrato per schermata.

- `tokens.json`: unica fonte per colori, tipografia, spaziature, raggi, tratti e punto fermo (`mark-*`). Dopo ogni modifica lancia `python3 Tools/sync_tokens.py`: genera SbuKit e `Site/src/styles/tokens.css` e si ferma se un contrasto promesso scende sotto WCAG.
- `logos/`: `sbu-logo.svg` (il logo, non si ridisegna), `sbu-mark.svg` (il logo in bianco su nero caldo).
- `icons/`: icone app generate da `Tools/make_icons.py`.
- `fonts/`: Bricolage Grotesque (OFL). Sito e marketing; nelle app solo per le cifre `stat` e `stat-hero`.

Decisioni e motivazioni: mappa "Design system Sbu riconoscibile (sito e app)" su GitHub Issues (#79).
