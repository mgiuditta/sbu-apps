# Design

Direzione **Carta e punto fermo** (design system v4): Sbu fa una cosa sola e la chiude con un punto. Carta, il nero caldo del logo, un solo quadrato per schermata.

- `tokens.json`: unica fonte per colori, tipografia, spaziature, raggi, tratti e punto fermo (`mark-*`). Dopo ogni modifica lancia `python3 Tools/sync_tokens.py`: genera SbuKit e `Site/src/styles/tokens.css` e si ferma se un contrasto promesso scende sotto WCAG.
- `logos/`: `sbu-logo.svg` (il logo, non si ridisegna), `sbu-mark.svg` (il logo in bianco su nero caldo).
- `icons/`: icone app incise (strumento in nero caldo su carta, punto fermo nell'accento), generate da `Tools/make_icons.py`. `engravings.json` tiene il soggetto di ogni app, `source/` le maschere d'inchiostro, così le icone si rifanno senza rigenerare l'incisione. Le incisioni sono generate con Gemini 2.5 Flash Image.
- `fonts/`: Bricolage Grotesque (OFL). Sito e marketing; nelle app solo per le cifre `stat` e `stat-hero`.

Decisioni e motivazioni: mappa "Design system Sbu riconoscibile (sito e app)" su GitHub Issues (#79).
