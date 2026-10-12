# Patch pendente per il design system (v8, issue #19)

Correzioni a https://claude.ai/artifact/A9vJiSmn34wgxe9ePFHLfA per #19. Non pubblicate: l'artifact nasce da un Artifact type e Claude Code non può pubblicarci (publish rifiutato il 2026-10-12). Pubblicare da una sessione claude.ai che può scriverci.

File in `project/` = versione 1791792473-3ad9 con le modifiche applicate:

- `tokens.json`: `accent-scan` → `accent-docs`, `field-scan` → `field-docs`, usage "Sbu Docs"; `version` 2 → 3. Valori invariati.
- `README.md`: "Sbu Scan" → "Sbu Docs" nell'elenco nomi; schermata strumento = radice del `NavigationStack`, titolo inline, ingranaggio che apre le Impostazioni in un foglio, niente tab bar; "Tab bar, toolbar…" → "Toolbar, bottoni di navigazione e fogli…"; "sotto una tab bar" → "sotto le barre".
- `components/ToolField/README.md`: niente "prima tab" né tab bar; toolbar con titolo inline e ingranaggio `on-field`.
- `components/ToolField/preview.html`: tolta la tab bar in vetro dai tre telefoni; titolo centrato e ingranaggio in alto a destra; `space-8` sotto le pill.
- `components/AppIcon/preview.html`, `Cover/preview.html`, `ListRow/preview.html`, `assets/App Icons/README.md`: Scan → Docs, `accent-scan` → `accent-docs`.
- `design-system.json`: record `sbu-scan.svg` rinominato `sbu-docs.svg` (stesso blob: il glifo è già un foglio), `order` e `lastChange`.

Per applicarle: rileggere l'artifact, riapplicare le stesse modifiche sulla versione corrente (non ripubblicare questi file così come sono se nel frattempo è cambiata), pubblicare con l'indice per ultimo. Poi cancellare questa cartella e chiudere #19.
