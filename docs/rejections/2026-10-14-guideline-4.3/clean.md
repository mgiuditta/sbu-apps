# Sbu Clean 1.0 (build 3), reply to Guidelines 4.3 and 4.2.6

Thank you for the review. I believe Sbu Clean meets 4.3(a), 4.3(b) and 4.2.6, so I am not resubmitting. Answers to the nine questions:

1. Sbu Clean frees space in the Photos library. Through PhotoKit it shows how much space can be reclaimed and the iPhone's storage, then offers five ways to decide: swipe review (month by month, recent, random, "on this day", one album), left to the bin, right to keep, with undo, a saved position and a "maybe" pile; duplicates and similar photos found on the device with Vision feature prints, with the best photo proposed by faces, sharpness, favourite and edited status; screenshots and screen recordings in a grid; videos by size, each compressible with AVFoundation into a new copy while the original stays; Live Photos turned into stills. Nothing is deleted until the user reviews the bin and confirms, then iOS asks again; the app says iOS keeps deleted photos 30 days. An iCloud-only video is downloaded only on request. A widget shows free space. No account, no server, no network.

2. People whose iPhone or iCloud storage is full, often not technical: parents with thousands of near-identical photos, people who screenshot everything, people who shoot long videos.

3. The top apps in this category charge a weekly or yearly subscription, cap swipes per day on the free tier, or run a trial that converts, and some analyse photos on their servers. Sbu Clean is free with nothing to buy, has no daily limit, no trial, no account, no ads, no analytics, analyses entirely on the device, keeps the original of every compressed video, and has a final review before any deletion. Usable with VoiceOver (keep, bin and undo are actions) and the largest Dynamic Type sizes.

4. Internal: TestFlight builds on a physical iPhone 15 Pro Max with a real library, worked through a written pass/fail checklist (first launch and permission explanation, denied and limited access, the five modes, bin review and deletion, compression, Live Photo conversion, widget, largest text, VoiceOver, light/dark, Italian/English, relaunch) plus iPhone SE in the simulator. No external testers for 1.0. Fixed before this build: on a large library the scan stuttered and blocked the home, now incremental; iCloud-only videos were downloaded during the scan, now only when opened or compressed; duplicate tests grouped differently on the device, now they use its own Vision prints; a selection mark hid the photo.

5. Standalone. It is one of the apps I publish under the sbu.dev name, each doing one task in a different category: Clean (free up Photos space), Habits (habit streaks), Level (level and clinometer), Moon (moon phase), Noise (sleep sounds), Speed (GPS speedometer), plus Sbu Scanner QR Barcode and Sbu Subscriptions, on the App Store since May and June 2026. I never publish two apps in the same category. Clean is the only one that touches the Photos library or uses Vision.

6. No. No other app of mine has anything to do with photos or storage; bundling would force full Photos library access on users of an unrelated app. All my apps are free with no in-app purchases, so a paid feature expansion is not possible.

7. Yes: SbuKit, my own Swift package, about 1,700 lines shared by all my apps: colour and type tokens, button styles, the large-number component, the "no subscription / no account / no ads / no tracking" pills, and the Settings screen with privacy policy and font licence. No photo, Vision or business logic. Clean's own code is about 6,200 lines.

8. None. Only Apple frameworks (SwiftUI, PhotoKit, Vision, AVFoundation, WidgetKit). The only outside asset is the Bricolage Grotesque typeface (SIL OFL), credited in Settings.

9. No. I am Matteo Giuditta, an individual developer; I designed and wrote the app myself in Swift and SwiftUI, in my own repository. No template, app generation service or third party provided code, content, concept or branding. sbu.dev is my site.

Happy to provide a screen recording or more detail.
