# sbu-apps

Free iOS apps from [sbu.dev](https://sbu.dev). Each one remakes a single paid utility from the top of the App Store: no subscription, no in-app purchases, no account, no ads, no tracking, data only on the device.

```
Design/            design system snapshot: tokens.json, icons, logos, fonts
Packages/SbuKit/   SwiftUI package: SbuTheme tokens, components, app shell
Apps/Sbu<Name>/    one XcodeGen project per app, with fastlane
Tools/             discover, spec, icons, token sync, new app scaffold
.claude/skills/    Swift agent skills to load before writing Swift (see CLAUDE.md)
```

Design system: https://claude.ai/artifact/A9vJiSmn34wgxe9ePFHLfA

## Setup, once

```sh
brew install xcodegen fastlane
python3 -m venv .venv && .venv/bin/pip install -r Tools/requirements.txt
export ANTHROPIC_API_KEY=...   # only for Tools/spec.py
```

Xcode 26 with an iOS simulator runtime (`xcodebuild -downloadPlatform iOS`).

## Add an app in 5 commands

```sh
python3 Tools/discover.py                           # 1. top-paid IT + US -> research/<app-id>/meta.json + screenshots
.venv/bin/python Tools/spec.py 357421934            # 2. listing + screenshots + 1-3★ reviews -> research/<app-id>/spec.json
Tools/new_app.sh Noise accent-noise noise           # 3. Apps/SbuNoise: project, dev.sbu.noise, SbuKit, icon, fastlane
cd Apps/SbuNoise && fastlane test                   # 4. build the app from spec.json, run the tests
fastlane snapshot && fastlane frameit && fastlane beta   # 5. App Store screenshots, frames, TestFlight
```

Between 3 and 4 you write the app: start from `MainView.swift`, put strings in `Localizable.xcstrings` (Italian source, English translation), and fill the placeholders in `fastlane/metadata/{it,en-US}`. `new_app.sh` arguments: an English noun, an `accent-*` token not used by a nearby category, and a glyph preset from `Tools/make_icons.py` or raw SVG elements in 1024 coordinates.

`fastlane release` uploads build, metadata and framed screenshots without submitting. `beta` and `release` read `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_PATH` and `SBU_TEAM_ID`.

## Tools

| | |
|---|---|
| `sync_tokens.py` | Regenerates SbuKit colors (asset catalog, light/dark) and metrics from `Design/tokens.json`. CI fails if they drift. |
| `make_icons.py` | `{name, accent, glyph}` → `Design/icons/sbu-<name>.svg` (rx 230) and a 1024 PNG without alpha for `AppIcon.appiconset`. Warns if the glyph leaves the 560 box. |
| `discover.py` | Top-paid charts (Apple marketing RSS) + iTunes Lookup: description, screenshots, price, release notes, genre. |
| `spec.py` | Claude (`claude-opus-5-5`, vision, structured output) → `features[]`, `screens[]`, `flows[]`, `data_model`, `monetization`, `user_pains[]`. |
| `new_app.sh` | Scaffolds `Apps/Sbu<Name>` from `Tools/templates/app`. |

Specs come only from public App Store data. Nothing here decompiles or extracts assets from other apps.

## Apps

| App | Accent | Remakes |
|---|---|---|
| [Sbu Level](Apps/SbuLevel) | `accent-level` | Clinometer + bubble level |
| [Sbu Habits](Apps/SbuHabits) | `accent-habits` | Streaks |
