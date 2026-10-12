# Icone app

Una icona per app, tutte dalla stessa grammatica: campo pieno nell'`accent-*` dell'app (raggio `radius-icon`), un glifo in `on-accent` con tratto `icon-stroke`, estremità arrotondate, dentro `icon-glyph-box`. Nessun testo né ombra.

| file | app | rifà | accento |
|---|---|---|---|
| sbu-subscriptions.svg | Sbu Subscriptions | tracker abbonamenti (già pubblicata) | `accent-subscriptions` |
| sbu-scanner.svg | Sbu Scanner QR Barcode | scanner QR (già pubblicata) | `accent-scanner` |
| sbu-level.svg | Sbu Level | Clinometer + bubble level | `accent-level` |
| sbu-noise.svg | Sbu Noise | White Noise | `accent-noise` |
| sbu-docs.svg | Sbu Docs | CamScanner+ | `accent-docs` |
| sbu-habits.svg | Sbu Habits | Streaks | `accent-habits` |
| sbu-cards.svg | Sbu Cards | AnkiMobile | `accent-cards` |
| sbu-block.svg | Sbu Block | Wipr 2 | `accent-block` |
| sbu-dark.svg | Sbu Dark | Noir | `accent-dark` |

SVG a 1024 generati da `make_icons.py`; per Xcode rasterizzare a PNG 1024 senza alpha.
