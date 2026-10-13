## How to work (same for all five agents)

You are one of five agents, each finishing one Sbu app in its own git worktree. Matteo (the owner) is away from home and gave full autonomy: decide yourself following the rules below, never wait for him. He will test everything later on a real iPhone with the test book you write.

Rules: read and follow /CLAUDE.md of the repo (it overrides anything else): design system, Italian source + English strings in Localizable.xcstrings, no network/analytics/IAP, one figure + one full stop per screen, Dynamic Type, VoiceOver, `#Preview` light and dark, Swift 6 MainActor default, one type per file, logic in @Observable models or pure types with Swift Testing tests. Before writing Swift, load the skills CLAUDE.md lists as mandatory (swiftui-pro, swift-concurrency-pro, swift-testing-pro, swiftui-ui-patterns, swiftui-view-refactor, swiftui-design-principles, swift-format-style, ios-accessibility, swiftui-accessibility-auditor) plus any task-specific one (widgets, background-execution, etc.).
Scope: the "1.0 minima" items for your app in docs/parity.md, as detailed below. Nothing from "Dopo (1.1+)". Read the linked GitHub issues (`gh issue view N --comments`) for decisions already taken.

Boundaries, so the five agents don't collide:
- Touch only Apps/<YourApp>/, Site/src/content/apps/<app>.md, research/ for your app, and docs/testbook/<app>.md. Do NOT edit Packages/SbuKit, Design/tokens.json, Tools/, .github/, other apps. If you truly need a SbuKit change, build it inside your app instead and note it in your report as a candidate for SbuKit.
- Work on a branch named app/<app>-1.0 (create it in your worktree). Commit after each completed step with a clear message ending with:
  Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
  Claude-Session: https://claude.ai/code/session_01UYFDPwfXGynLPDQ5FhVWMQ
- Do NOT merge into main, do NOT push, do NOT upload to App Store Connect/TestFlight, do NOT close issues. You may comment progress on your app's issues with `gh issue comment` (Italian, short).
- Simulator: create your own so five agents don't fight over one: `xcrun simctl create "Sbu-<App>-agent" "iPhone 17"` (fall back to any available iPhone device type), then test with `-destination "id=<udid>"`. Shut it down and delete it at the end.
- Tests: after each feature run `xcodegen generate` and `xcodebuild test -project <App>.xcodeproj -scheme <App> -destination ...` in Apps/<App>. Also build/test SbuKit only if you changed something it depends on (you shouldn't). Fix until green. Add Swift Testing unit tests for new logic, and extend the XCTest flow tests with performAccessibilityAudit for new screens. Take simulator screenshots of new screens (light, dark, largest accessibility text size) with `xcrun simctl io <udid> screenshot` and look at them to catch layout bugs; fix what you see.
- If a feature turns out not feasible (needs hardware the simulator lacks, a decision only Matteo can take, an external account), implement what you can, leave it clean (no disabled dead buttons in the UI), and list it in the report.

Deliverables:
1. Features implemented, tests green, committed on app/<app>-1.0.
2. docs/testbook/<app>.md in Italian: a numbered manual test script for Matteo on a real iPhone. For each feature: preconditions, steps, expected result, a checkbox. Include first launch, permissions denied, large text, VoiceOver, dark mode, English, and anything the simulator could not verify (sensors, GPS, notifications at real times, audio in background). Commit it.
3. Final report (your last message), Italian, short: what's done, test results (counts), what's NOT done and why, anything Matteo must decide, SbuKit candidates, branch name and worktree path.
