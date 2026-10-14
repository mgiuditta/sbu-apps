# Sbu Habits 1.0 (build 5), reply to Guidelines 4.3 and 4.2.6

Thank you for the review. I believe Sbu Habits meets 4.3(a), 4.3(b) and 4.2.6, so I am not resubmitting. Answers to the nine questions:

1. Sbu Habits is a habit tracker whose single figure is the "full streak": consecutive days on which every habit due that day was done. Up to 24 habits, yes/no or counted (8 glasses of water), scheduled daily, on chosen weekdays, N times a week or month, or on one day. Marked by touching and holding a ring. It handles what usually breaks a streak: habits to avoid with a daily limit (0 for "no smoking"), timed habits with a Live Activity countdown that mark themselves, habits linked read-only to Apple Health that mark themselves at the daily goal (also in the background), a note per day, "skip today" for illness, a start of the day for night shifts, reminders only on due days if not done. Interactive widgets, an Apple Watch app with a complication, statistics, JSON export/import. Opt-in, off by default: sync through the user's own iCloud and read-only sharing of one habit. No account, no server of mine.

2. People building or breaking a daily routine who want one honest number: shift workers, people who track activity in Health, people with a habit to limit, Watch users.

3. The habit apps I studied charge up front or by subscription for Health linking, Watch, timed habits and sharing, and most need an account. Sbu Habits is free with nothing to buy, no account, no ads, no analytics, never writes to Health, keeps iCloud opt-in, and treats habits to avoid and timed habits as first-class types. Fully usable with VoiceOver and the largest Dynamic Type sizes.

4. Internal: five TestFlight builds on a physical iPhone 15 Pro Max, worked through a written pass/fail checklist (first launch, add/mark/undo/skip, templates, notes, widgets, largest text, VoiceOver, light/dark, Italian/English, export/import, relaunch) plus iPhone SE in the simulator. Timed habits, Health, iCloud and Watch are covered by automated tests and the simulator, not yet over days on a device. No external testers for 1.0. Fixed before this build: a pre-release UI pass found ten defects; at the largest text sizes the add form overlapped its button and rows broke mid-word (issue #439); the play button covered small rings; a note's last line hid under the keyboard on a short iPhone.

5. Standalone. It is one of the apps I publish under the sbu.dev name, each doing one task in a different category: Habits (habit streaks), Level (level and clinometer), Moon (moon phase), Noise (sleep sounds), Speed (GPS speedometer), Clean (free up Photos space), plus Sbu Scanner QR Barcode and Sbu Subscriptions, on the App Store since May and June 2026. I never publish two apps in the same category. Habits is the only one that tracks anything over days, reads Health or has a Watch app.

6. No. The closest, Sbu Subscriptions, tracks recurring payments; no shared data model, screen or user need. Bundling would push Health and Watch into an app about money. All my apps are free with no in-app purchases, so a paid feature expansion is not possible.

7. Yes: SbuKit, my own Swift package, about 1,700 lines shared by all my apps: colour and type tokens, button styles, the large-number component, the "no subscription / no account / no ads / no tracking" pills, and the Settings screen with privacy policy and font licence. No habit, Health, sync or business logic. Habits' own code is about 14,600 lines.

8. None. Only Apple frameworks (SwiftUI, SwiftData, HealthKit, WidgetKit, ActivityKit, WatchConnectivity, CloudKit, UserNotifications). The only outside asset is the Bricolage Grotesque typeface (SIL OFL), credited in Settings.

9. No. I am Matteo Giuditta, an individual developer; I designed and wrote the app myself in Swift and SwiftUI, in my own repository. No template, app generation service or third party provided code, content, concept or branding. sbu.dev is my site.

Happy to provide a screen recording or more detail.
