# sbu-apps

Monorepo of free iOS apps for sbu.dev: Swift 6, SwiftUI, iOS 17+, shared `Packages/SbuKit`, one XcodeGen project per app in `Apps/`. Commands and layout are in README.md.

## Swift skills: mandatory

Before writing or reviewing any Swift, load the skills in `.claude/skills/` that cover the work (vendored from the twostraws/swift-agent-skills index, MIT, licence kept per skill). Always:

- `swiftui-pro`, `swift-concurrency-pro`, `swift-testing-pro` (Paul Hudson): the baseline for every Swift change.
- `swiftui-ui-patterns`, `swiftui-view-refactor`, `swiftui-design-principles`: views and screens.
- `swift-format-style`: anything that shows a number, date or measurement.
- `ios-accessibility`, `swiftui-accessibility-auditor`: every new view.
- `swift-api-design-guidelines-skill`: public SbuKit API.

Load the others when the task touches them: SwiftData (`swiftdata-pro`, `swiftdata-expert-skill`, `swiftdata-testing`), Core Data, widgets, App Intents, background execution, security/Keychain, App Store (`appstore-review`, `app-store-aso`, `asc-*`, `app-store-changelog`), simulator automation, performance audits.

Where a skill and these rules disagree, these rules win: iOS 17 deployment target (not 26), `CGFloat` theme metrics, design-system radii (not the 10pt card radius in `swiftui-design-principles`).

## Design system: the only source

Source: https://claude.ai/artifact/A9vJiSmn34wgxe9ePFHLfA, snapshot in `Design/tokens.json`. Never invent a color, size, spacing, radius or font.

- Use `SbuTheme.<token>` (camel-cased token names: `surfaceRaised`, `space4`, `radiusLg`). No literal colors or spacings in app code.
- Colors and metrics are generated: edit `Design/tokens.json`, run `python3 Tools/sync_tokens.py`. Never edit `SbuTheme+Tokens.swift` or the colorsets by hand.
- One thing per app: one `SbuStat` per screen, in `ink`, `.monospacedDigit()`; everything else secondary in `inkMuted`.
- Native controls (`List .insetGrouped`, `Form`, `NavigationStack`, sheets). Every app runs inside `SbuAppShell`.
- The only living color is the app's `accent*` (tint). `brand` only in the sbu.dev footer and splash. Never two accents on a screen. On `accentLevel`, text is `onAccentLevel`, never white.
- Nothing that looks like a paywall: no gradients, colored-border cards, stars, "PRO", shadows.
- Status colors (`success`, `warning`, `danger`) always come with a word or SF Symbol. Delete and reset are `danger` and confirm (`SbuButton(kind: .destructive)` does it).
- Dynamic Type text styles only; `stat`/`statSmall` scale with `@ScaledMetric`. SF Symbols at `.medium` weight and scale, no custom icons in the UI.
- App icon grammar: full `accent-*` field, rx 230 at 1024, one white glyph, stroke 96 with round caps, inside the 560 box. Generate with `Tools/make_icons.py`.
- Bricolage Grotesque (`Design/fonts`) is for screenshots and marketing only, never inside an app.

## Product rules

- No third-party dependencies in SbuKit. Apps depend only on SbuKit and Apple frameworks.
- No analytics, accounts, network calls, ads or tracking in apps. Data stays on the device. Links to sbu.dev open Safari.
- Every user-facing string in Italian (source) and English, in `Localizable.xcstrings`. Second person singular, short sentences, no emoji, no exclamation marks. Actions are infinitive verbs ("Calibra"), results are participles ("Calibrata").
- App Store descriptions start with the fixed promise block, in this order: nessun abbonamento · nessun acquisto in-app · nessun account · nessuna pubblicità · nessun tracking · dati solo sul dispositivo. Then features, then "Sbu fa una cosa sola: …".
- Specs come only from public App Store data (`Tools/discover.py`, `Tools/spec.py`). Never write code that decompiles, unpacks or extracts assets from other apps.

## Code conventions

- Swift 6 with `MainActor` default isolation (apps and SbuKit). Mark pure value types `nonisolated`.
- One type per file; folders by feature (`Level/`, `Views/`).
- Logic in `@Observable` models or pure types with Swift Testing tests (structs, `#expect`, parameterized). XCTest only for UI tests: the snapshot test and flow tests that drive the screen and run `performAccessibilityAudit`.
- `#Preview` light and dark for every view.
- After changing Swift: `xcodebuild test` on an iPhone simulator for SbuKit and the touched app, as CI does.
- Commit after each completed step.

## Agent skills

### Issue tracker

GitHub Issues of mgiuditta/sbu-apps, via `gh`. See `docs/agents/issue-tracker.md`.

### Triage labels

Standard labels: needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
