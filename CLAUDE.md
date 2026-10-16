# sbu-apps

Monorepo of free iOS apps for sbu.dev: Swift 6, SwiftUI, iOS 17+, shared `Packages/SbuKit`, one XcodeGen project per app in `Apps/`. Commands and layout are in README.md.

## Swift skills: mandatory

Before writing or reviewing any Swift, load the skills in `.claude/skills/` that cover the work (vendored from the twostraws/swift-agent-skills index and rshankras/claude-code-apple-skills, MIT, licence kept per skill). Always:

- `swiftui-pro`, `swift-concurrency-pro`, `swift-testing-pro` (Paul Hudson): the baseline for every Swift change.
- `swiftui-ui-patterns`, `swiftui-view-refactor`, `swiftui-design-principles`: views and screens.
- `swift-format-style`: anything that shows a number, date or measurement.
- `ios-accessibility`, `swiftui-accessibility-auditor`: every new view.
- `swift-api-design-guidelines-skill`: public SbuKit API.

Load the others when the task touches them: SwiftData (`swiftdata-pro`, `swiftdata-expert-skill`, `swiftdata-testing`), Core Data, widgets, App Intents, background execution, security/Keychain, App Store (`appstore-review`, `app-store-aso`, `asc-*`, `app-store-changelog`; before every submit `release-review`, `privacy-manifests`, `privacy-policy`, `originality-check`, and `rejection-handler` after a rejection), simulator automation, performance audits.

Where a skill and these rules disagree, these rules win: iOS 17 deployment target (not 26), `CGFloat` theme metrics, design-system radii (not the 10pt card radius in `swiftui-design-principles`).

## Design system: the only source

Direction **Carta e punto fermo**: Sbu fa una cosa sola e la chiude con un punto. Paper, the logo's warm black, one square per screen. Source: `Design/tokens.json` (v4), reference board linked in `Design/README.md`. Never invent a color, size, spacing, radius or font.

- Use `SbuTheme.<token>` (camel-cased token names: `surfaceRaised`, `space4`, `radiusLg`). No literal colors or spacings in app code.
- Colors and metrics are generated: edit `Design/tokens.json`, run `python3 Tools/sync_tokens.py` (it fails if a promised contrast pair drops below WCAG). Never edit `SbuTheme+Tokens.swift` or the colorsets by hand.
- The square is the full stop (`SbuFullStop`): exactly one per screen, closing the one figure (`SbuStat` or `SbuToolField`), in the app's accent; on the site it closes the page title. Size and gap come from `mark-size`/`mark-gap`, on the baseline. Never decorative, never two on a screen, never on list containers. VoiceOver ignores it.
- One thing per app: one figure per screen, in `ink`; everything else secondary in `inkMuted`. Every screen, the tool screen included, sits on `surface`: no colored or dark fields.
- The one exception: Sbu Speed's Parabrezza (windshield HUD) forces the dark scheme, mirrored figure on warm-black `surface` (ADR-0011). No other dark screen without a new ADR.
- Native controls (`List .insetGrouped`, `Form`, `NavigationStack`, sheets). Every app runs inside `SbuAppShell`.
- The only living color is the app's `accent*` (tint, the full stop, filled buttons). Text on an accent is `onAccent` (white in light, warm black in dark), never literal white. `brand` is the logo's warm black: logo, sbu.dev footer and splash. Never two accents on a screen.
- Nothing that looks like a paywall: no gradients, colored-border cards, stars, "PRO", shadows.
- Status colors (`success`, `warning`, `danger`) always come with a word or SF Symbol. Delete and reset are `danger` and confirm (`SbuButton(kind: .destructive)` does it).
- Type: SF for all text, Dynamic Type styles only. `stat` and `statHero` are Bricolage Grotesque ExtraBold (bundled in SbuKit, OFL, listed under Impostazioni → Licenze), sized with `@ScaledMetric` and `Font.custom(_:fixedSize:)`, tabular figures. `statSmall` is SF with `.monospacedDigit()`. SF Symbols at `.medium` weight and scale, no custom icons in the UI.
- App icon grammar: the real instrument behind the app, engraved in `ink` on `surface` paper, closed by the square full stop in the app's accent at the bottom right; dark is light ink on warm black, tinted is greys. Subjects in `Design/icons/engravings.json`, ink masks in `Design/icons/source/`. Generate with `Tools/make_icons.py` (`--generate` uses Gemini).
- The logo (`Design/logos/sbu-logo.svg`: lowercase `sbu` plus the square, `#0A0A00`) is never redrawn; `sbu-mark.svg` is the same wordmark in white on warm black.

## Product rules

- No third-party dependencies in SbuKit. Apps depend only on SbuKit and Apple frameworks.
- No analytics, accounts, network calls, ads or tracking in apps. Data stays on the device. Links to sbu.dev open Safari. Three exceptions: the local network to the user's own devices when the one thing needs it (ADR-0007), the user's own iCloud for sync/backup, off by default (ADR-0008), and sharing one item read-only with another person through iCloud, only when the user shares it (ADR-0009).
- Every user-facing string in Italian (source) and English, in `Localizable.xcstrings`. Second person singular, short sentences, no emoji, no exclamation marks. Actions are infinitive verbs ("Calibra"), results are participles ("Calibrata").
- App Store descriptions open with what the app does in one sentence, then features, then "Sbu fa una cosa sola: …", then the promises on one last line, in this order: nessun abbonamento · nessun acquisto in-app · nessun account · nessuna pubblicità · nessun tracking · dati solo sul dispositivo. Never the promises at the top: the identical opening across apps was a 4.3 signal (rejection of 14/10/2026).
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

GitHub Issues of mgiuditta/sbu-apps-private (the public repo mgiuditta/sbu-apps has issues off), via `gh`. See `docs/agents/issue-tracker.md`.

### Triage labels

Standard labels: needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
