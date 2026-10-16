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

Where a skill and these rules disagree, these rules win: iOS 17 deployment target (not 26), `CGFloat` theme metrics, design-system radii (`radiusCard` 6, not the 10pt card radius in `swiftui-design-principles`).

## Design system: the only source

Direction **Quaderno** (v5, ADR-0013, supersedes v4 "Carta e punto fermo"): Sbu is a squared notebook; the full stop is the one filled cell on the page, and everything else follows from the cell. Source: `Design/tokens.json` (v5), rules and reference canvas in `Design/README.md`. Never invent a color, size, spacing, radius, duration or font.

- Use `SbuTheme.<token>` (camel-cased token names: `paper`, `surfaceRaised`, `space4`, `radiusCard`, `gridCell`) and `SbuAccent.<app>`. No literal colors, spacings or durations in app code.
- Colors and metrics are generated: edit `Design/tokens.json`, run `python3 Tools/sync_tokens.py` (it fails if a promised contrast pair drops below WCAG). Never edit `SbuTheme+Tokens.swift`, the colorsets or `Site/src/styles/tokens.css` by hand.
- Paper and grid: every screen on `paper`. Paper areas (figure zone, empty states, first run) get the 24 pt grid with `.sbuPaper(grid: true)`; never under `List`/`Form` rows or user content (photos, PDFs, previews).
- One figure per screen: `SbuFigure` (Bricolage ExtraBold variable, tabular, 144–216 pt on the grid, `ViewThatFits` wdth 100/87/75, one line up to AX5, one VoiceOver element), in `ink`; everything else secondary in `inkMuted`.
- The full stop (`SbuFullStop`): states `absent`, `waiting` (`inkMuted`, nothing to count or in progress), `set` (the app's accent); sizes `hero` 24, `inline` 16, `mark` 10. Exactly one `.set` per screen or widget (DEBUG warns otherwise), never decorative, never on list containers. VoiceOver ignores it.
- Titles: the tool screen opens with `SbuScreenTitle(title:cartiglio:)`, Bricolage 34 wdth 87 plus the cartiglio in IBM Plex Mono 11 uppercase (`SBU · ABITUDINI · SAB 17 OTT`). Plex Mono only for metadata, never for figures. All other text is SF, Dynamic Type styles only. SF Symbols at `.medium`, no custom icons in the UI.
- Ink, not color: tint, controls, filled buttons and links are `ink`. `Toggle` gets `SbuToggleStyle` from the shell; checkboxes are `Toggle` + `SbuCheckboxStyle`; row status is `SbuRowMark(filled:)` plus a word. Custom styles on system controls, never views that replace them. The only color on a screen is the `.set` full stop.
- Cards: `radiusCard` 6 for cards and buttons; `SbuListCard` (white, 1 px `line` border) for lists on paper. Management screens keep native `List .insetGrouped`/`Form` (system radii).
- Closure: the completion moment (`.sbuClosure(_:word:)`): one participle plus the full stop for 2 s in an ink block (radius 14, word in `paper`, stop in `accentOnInk`). Never at launch, at most once per event.
- Dark surfaces: only the Closure and Sbu Speed's Parabrezza (ADR-0011). No other dark or colored screen without a new ADR.
- Motion and haptics are tokens (ADR-0014): `SbuMotion`, `SbuHaptic` (`tick`, `dot`, `closure`), `.sbuAffectsFigure` on controls that change the figure. Reduce Motion: opacity only, zero duration.
- Empty and first run: `SbuEmpty(sentence:action:)`, "0" with a waiting stop, one second-person sentence, one native button. No illustrations, carousels or early permission prompts. No drawn indicator that repeats the figure (Level's bubble is gone).
- Widgets and Live Activities: `SbuWidgetFigure` / `SbuLiveFigure` only; a `.set` Live Activity ends after 4 s; Lock Screen stop `.widgetAccentable()`, inline `■`.
- Shell: every app runs inside `SbuAppShell`: no tab bar, settings in a sheet (ADR-0001), with `SbuIconPicker` (Carta / Inversa) and Licenze (Bricolage, Plex Mono). The one exception: Sbu Subscriptions runs inside `SbuTabShell`, three tabs with Impostazioni as the last (ADR-0012). `SbuStat`, `SbuToolField` and the `accent: Color` shell init are deprecated for one release.
- `brand` is the logo's warm black: logo, sbu.dev footer and splash. `onAccent` only for marketing and icons.
- Nothing that looks like a paywall: no gradients, shadows (marketing only), colored-border cards, stars, "PRO".
- Status colors (`success`, `warning`, `danger`) always come with a word or SF Symbol. Delete and reset are `danger` and confirm (`SbuButton(kind: .destructive)` does it).
- App icon grammar: the real instrument behind the app, engraved in `ink` on paper, closed by the square full stop in the app's accent at the bottom right; dark is light ink on warm black, tinted is greys. One alternate icon for every app, **Inversa** (paper on ink, `AppIcon-Inversa`). Subjects in `Design/icons/engravings.json`, ink masks in `Design/icons/source/`. Generate with `Tools/make_icons.py` (`--generate` uses Gemini, `--inverse` the alternate).
- The logo (`Design/logos/sbu-logo.svg`: lowercase `sbu` plus the square, `#0A0A00`) is never redrawn; `sbu-mark.svg` is the same wordmark in paper on warm black.

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
