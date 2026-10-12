# Design

Snapshot del design system Sbu: https://claude.ai/artifact/A9vJiSmn34wgxe9ePFHLfA

- `tokens.json`: copia 1:1 di `project/tokens.json`. Unica fonte per colori, tipografia, spaziature, raggi, tratti.
- `icons/`, `logos/`: SVG pubblicati nel design system.

Se il design system cambia, aggiorna `tokens.json` qui e rilancia `python3 Tools/sync_tokens.py`.
