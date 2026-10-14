# Sbu Noise 1.0 (build 3), reply to Guidelines 4.3 and 4.2.6

Thank you for reviewing Sbu Noise. I believe it meets 4.3 and 4.2.6 as submitted, so I'm replying here instead of resubmitting.

1. Sbu Noise plays a sound you can fall asleep to. It ships with 34 looping sounds: coloured noises the app generates itself, and public-domain field recordings of rain, water, nature, home and travel, all brought to the same loudness and looped without an audible seam. Nothing streams. You pick a sound, favourite it, hide or reorder sounds, and can build a mix of up to five with their own volumes, placed around you in headphones. A sleep timer fades out and can repeat on chosen days. An alarm fades a sound in, with snooze, backed by a system alarm (AlarmKit on iOS 26, Time Sensitive notifications earlier) that rings only if the app isn't running. A bedside clock with its own brightness. Playback continues in the background and locked, works with AirPlay and headphone buttons, and starts or stops from a widget, a Control Center control, Shortcuts or Siri. No account, no server, no network.

2. People who sleep badly or somewhere noisy, shift workers sleeping by day, parents settling a baby, people with tinnitus, people who work in headphones.

3. The sleep-sound apps I studied stream their catalogues (network, usually an account), put most sounds, mixes or the alarm behind a subscription, or show ads. Sbu Noise is free, offline, no account, no ads, no analytics, does spatial mixes, backs its alarm with a system alarm, has Control Center and Siri, and keeps every sound at equal loudness so switching at 3 a.m. doesn't startle you. VoiceOver and the largest Dynamic Type sizes are supported.

4. Internal testing. TestFlight builds on my iPhone 15 Pro Max, with and without headphones, run through a written checklist with pass/fail results: every sound and group, favourites, hide and reorder, mixes, sleep timer, the alarm with the app killed, bedside clock, background and lock-screen playback, widget and Control Center, largest text, VoiceOver, light and dark, Italian and English, relaunch; iPhone SE in the simulator. No outside testers for 1.0. Fixes that came out of it: the sounds varied a lot in loudness, so all are now normalised to -18 LUFS; several recordings clicked at the loop point, so the loop now wraps through the decoded padding; the train recording had station beeps in it and got trimmed.

5. Standalone. It's one of the sbu.dev apps, each doing a single job in its own category: Noise for sleep sounds, Habits (streaks), Level (level and clinometer), Moon (moon phase), Speed (GPS speedometer), Clean (freeing Photos space), plus Sbu Scanner QR Barcode and Sbu Subscriptions, on the store since May and June 2026. I keep to one app per category. Noise is the only one that plays audio and the only one with the background audio mode.

6. No. No other app of mine plays sound or has anything to do with sleep. Dropping 34 sounds and background audio into a habit tracker would weigh it down for everyone. My apps are free with no in-app purchases, so a paid feature expansion isn't possible.

7. Yes, SbuKit: my own Swift package, about 1,700 lines, imported by every app I publish. It contains the design system (colour and type tokens, button styles, the big-number view, the "no subscription / no account / no ads / no tracking" pills) and the Settings screen with the privacy policy and font licence. No audio or business logic. Noise's own code is about 5,200 lines.

8. None. Only Apple frameworks: SwiftUI, AVFoundation, AlarmKit, WidgetKit, App Intents, MediaPlayer. Outside assets are the field recordings, all CC0 and credited individually under Settings > Sound Credits, and the Bricolage Grotesque typeface (SIL OFL).

9. No. I'm Matteo Giuditta, an individual developer. I designed and wrote the app myself in Swift and SwiftUI, in my own repository. No template, no app generation service, nobody else's content, concept or branding. sbu.dev is mine.

Happy to send a screen recording if useful.
