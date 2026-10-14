# Sbu Speed 1.0 (build 2), reply to Guidelines 4.3 and 4.2.6

Thank you for the review. I believe Sbu Speed meets 4.3(a), 4.3(b) and 4.2.6, so I am not resubmitting. Answers to the nine questions:

1. Sbu Speed shows the current GPS speed (Core Location, When In Use only) as one large whole number readable from a distance, in km/h, mph or knots. Under it, the trip: top speed, average speed, distance and duration, kept until reset with a confirmation. The average counts only time in motion, so stops do not pull it down. With knots, distance is in nautical miles and the limit presets are the ones used on the water. An optional limit shows under the figure when exceeded, with one vibration and one sound per crossing. The dial scale adapts (60, 120, 200, 300 km/h). In landscape, as in a car mount, the figure sits left and the trip right; the screen stays on. No position is stored or logged, location is used only with the app open. No account, no server, no network.

2. Cyclists, runners, e-scooter riders and boat owners without a speedometer, and drivers cross-checking an old gauge. The large figure and landscape layout are for a phone in a mount, glanced at, never touched.

3. The GPS speedometer apps I studied are paid, carry ads, or sell the limit alert, units or trip as in-app purchases, and several log the route in the background. Sbu Speed is free with nothing to buy, no ads, no account, no analytics, never uses background location and keeps no route, has a moving-time average, nautical units with matching distances and limits, and a limit alert with sound and haptics. Usable with VoiceOver and the largest Dynamic Type sizes.

4. Internal: TestFlight builds on a physical iPhone 15 Pro Max checked outdoors on foot, worked through a written pass/fail checklist (first fix within 30 seconds, stopped reads 0, units, limit alert, landscape, denied location, largest text, VoiceOver, light/dark, Italian/English, relaunch); higher speeds and trip values with simulated routes in Xcode and unit tests of the trip maths; iPhone SE in the simulator. No long road test in a car mount yet, no external testers for 1.0. Fixed before this build: the reset confirmation did not say what would be cleared, now it names the four values; "Stopped" appeared in Italian in the English interface and unit names were not localised.

5. Standalone. It is one of the apps I publish under the sbu.dev name, each doing one task in a different category: Speed (GPS speedometer), Habits (habit streaks), Level (level and clinometer), Moon (moon phase), Noise (sleep sounds), Clean (free up Photos space), plus Sbu Scanner QR Barcode and Sbu Subscriptions, on the App Store since May and June 2026. I never publish two apps in the same category. Speed is the only one that uses continuous location.

6. No. The only other app of mine that touches location, Sbu Moon, reads it once for moonrise; bundling a speedometer anywhere would add continuous location to users who never asked for it. All my apps are free with no in-app purchases, so a paid feature expansion is not possible.

7. Yes: SbuKit, my own Swift package, about 1,700 lines shared by all my apps: colour and type tokens, button styles, the large-number component, the "no subscription / no account / no ads / no tracking" pills, and the Settings screen with privacy policy and font licence. No location or business logic. Speed's own code is about 1,000 lines: location reading, trip accumulation, units, the limit alert, the dial, layouts and tests.

8. None. Only Apple frameworks (SwiftUI, Core Location, Core Haptics, AVFoundation for the alert sound). The only outside asset is the Bricolage Grotesque typeface (SIL OFL), credited in Settings.

9. No. I am Matteo Giuditta, an individual developer; I designed and wrote the app myself in Swift and SwiftUI, in my own repository. No template, app generation service or third party provided code, content, concept or branding. sbu.dev is my site.

Happy to provide a screen recording or more detail.
