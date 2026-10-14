# Sbu Clean 1.0 (build 3), reply to Guidelines 4.3 and 4.2.6

Thank you for the review. I'm confident Sbu Clean is within 4.3 and 4.2.6, so I'm not resubmitting. Here are the answers to your questions.

1. The app frees space in the Photos library. It reads the library through PhotoKit, shows how much space can be reclaimed next to the iPhone's storage, and gives five ways to decide what goes. Swipe review by month, recent, random, "on this day" or album: left for the bin, right to keep, with undo, a saved position and a "maybe" pile. Duplicates and near-duplicates found on the device with Vision feature prints; the app proposes the best shot of each group (faces, sharpness, favourite, edited) and you can overrule it. Screenshots and screen recordings in a grid. Videos by size, each compressible with AVFoundation into a new copy while the original stays. Live Photos flattened into stills. Nothing is deleted until you review the bin and confirm, then iOS asks again, and the app tells you iOS keeps deleted items 30 days. An iCloud-only video is fetched only if you open it. A widget shows free space. No account, no server, no network.

2. People whose iPhone or iCloud is full, often not technical: parents with thousands of near-identical photos, people who screenshot everything, people who shoot long videos.

3. The big apps here charge weekly or yearly, cap free swipes per day, or run a trial that becomes a subscription, and some analyse photos on their servers. Sbu Clean is free, no limit, no trial, no account, no ads, no analytics, analyses on the phone, keeps the original of every compressed video, and always ends with a review step before anything is removed. It works with VoiceOver (keep, bin and undo are exposed as actions) and at the largest Dynamic Type sizes.

4. Internal testing only. TestFlight builds on my iPhone 15 Pro Max against my real library, run through a written pass/fail checklist: first launch and the permission explanation, denied and limited access, each of the five modes, bin review and deletion, compression, Live Photo conversion, the widget, largest text, VoiceOver, light and dark, Italian and English, relaunch; iPhone SE in the simulator. No outside testers for 1.0. What it changed: the scan stuttered on a big library, so I made it incremental; iCloud-only videos were downloaded during the scan, now only when you open or compress one; duplicate tests grouped differently on the device than in the simulator, so they now use the device's own Vision prints; a selection mark hid the photo under it.

5. It's a standalone app, one of a small family I publish as sbu.dev. Each does one job in a different category: Clean here, Habits (habit streaks), Level (level and clinometer), Moon (moon phase), Noise (sleep sounds), Speed (GPS speedometer), and Sbu Scanner QR Barcode and Sbu Subscriptions, both live since May and June 2026. I never put two apps in the same category. Clean is the only one that reads the Photos library or uses Vision.

6. No. None of my other apps has anything to do with photos or storage, and bundling this in would mean asking users of an unrelated app for full library access. All my apps are free with no in-app purchases, so a paid add-on isn't possible.

7. Yes: SbuKit, a Swift package of mine shared by all my apps, roughly 1,700 lines. It holds the design system (colour and type tokens, button styles, the big-number view, the promise pills) and the Settings screen with privacy policy and licences. No photo, Vision or business logic. Clean's own code is about 6,200 lines.

8. None. Only Apple frameworks: SwiftUI, PhotoKit, Vision, AVFoundation, WidgetKit. The one outside asset is the Bricolage Grotesque typeface (SIL OFL), credited in Settings.

9. No. I'm Matteo Giuditta, an individual developer, and I designed and wrote Sbu Clean myself in Swift and SwiftUI, in my own repository. No template, no generation service, no third party behind the code, content, concept or branding. sbu.dev is my site.

I can send a screen recording if that helps.
