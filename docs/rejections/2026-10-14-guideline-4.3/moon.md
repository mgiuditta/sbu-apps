# Sbu Moon 1.0 (build 2), reply to Guidelines 4.3 and 4.2.6

Thank you for the review. I believe Sbu Moon meets 4.3(a), 4.3(b) and 4.2.6, so I am not resubmitting. Answers to the nine questions:

1. Sbu Moon shows the state of the moon for any day, computed on the device with the algorithms from Jean Meeus's Astronomical Algorithms, with no network. It opens on today's moon drawn as it looks, the illuminated percentage as the main figure, waxing or waning, the phase name, date and time of the next four principal phases, the moon's age and distance. The user swipes to the previous or next day or picks any day from 1900 to 2100. Moonrise and moonset come from the position read once (about a kilometre, When In Use, only on tapping "Use my location") or from a built-in city list, shown in the city's own clock when it differs. Phase alerts are local notifications at the hour the user picks. No account, no server of mine.

2. People who follow the moon for a practical reason: gardeners and fishermen planning by the phase, night photographers and amateur astronomers who want the next full or new moon with its time, anyone who wants a full-moon alert.

3. The moon apps I studied are paid or carry ads, several need the network for rise and set, and some keep location on. Sbu Moon is free with nothing to buy, has no ads, no account, no analytics, works entirely offline including rise and set for a city, reads location once and only on request, covers 1900 to 2100, and has alerts at a chosen hour. Usable with VoiceOver and the largest Dynamic Type sizes.

4. Internal: TestFlight builds on a physical iPhone 15 Pro Max, worked through a written pass/fail checklist (today's moon, swiping days, the calendar at the range limits, location request and denial, city list, alerts, largest text, VoiceOver, light/dark, Italian/English, relaunch) plus iPhone SE in the simulator; rise and set are unit-tested against United States Naval Observatory values. No external testers for 1.0. Fixed before this build: rise and set for a chosen city were shown in the iPhone's time zone, now in the city's own clock, named when different; the percent sign made the figure look misaligned at large text, now treated as the unit on the baseline; a precision pass found wording and spacing defects on the phases list and the alerts screen.

5. Standalone. It is one of the apps I publish under the sbu.dev name, each doing one task in a different category: Moon (moon phase), Habits (habit streaks), Level (level and clinometer), Noise (sleep sounds), Speed (GPS speedometer), Clean (free up Photos space), plus Sbu Scanner QR Barcode and Sbu Subscriptions, on the App Store since May and June 2026. I never publish two apps in the same category. Moon is the only one that computes anything astronomical.

6. No. No other app of mine concerns the sky, past or future dates, or location-based times; bundling would add a location request and a city list where nobody asked for them. All my apps are free with no in-app purchases, so a paid feature expansion is not possible.

7. Yes: SbuKit, my own Swift package, about 1,700 lines shared by all my apps: colour and type tokens, button styles, the large-number component, the "no subscription / no account / no ads / no tracking" pills, and the Settings screen with privacy policy and font licence. No astronomical or business logic. Moon's own code is about 2,300 lines, including the tests against USNO.

8. None. Only Apple frameworks (SwiftUI, Core Location, UserNotifications). The algorithms come from a published textbook, implemented by me. The only outside asset is the Bricolage Grotesque typeface (SIL OFL), credited in Settings.

9. No. I am Matteo Giuditta, an individual developer; I designed and wrote the app myself in Swift and SwiftUI, in my own repository. No template, app generation service or third party provided code, content, concept or branding. sbu.dev is my site.

Happy to provide a screen recording or more detail.
