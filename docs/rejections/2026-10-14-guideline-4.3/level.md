# Sbu Level 1.0 (build 3), reply to Guidelines 4.3 and 4.2.6

Thank you for the review. I believe Sbu Level meets guidelines 4.3(a), 4.3(b) and 4.2.6, so I am not resubmitting. Here are the answers to the nine questions.

**1. What the app does and the problem it solves**

Sbu Level is a spirit level and clinometer built on the iPhone's motion sensors (Core Motion gravity vector). Laid flat, it shows a bubble level. Stood on any of its four edges, it becomes a clinometer that shows the tilt of that edge from 0° to 90° to a tenth of a degree, on a dial with a needle and as a large number. The user can lock the reading to read it later, keep the screen on while measuring, and feel a single haptic tap at exactly 0.0° (or 90.0° on a side edge).

The problem it solves is calibration on a surface that is not itself level. Every phone's sensor has a small offset, and a table is rarely perfectly flat, so a one-tap "zero here" calibration bakes the table's error into the phone. Sbu Level calibrates each side with two readings, asking the user to turn the phone 180° between them; the average cancels the surface error and keeps only the sensor's offset. Implausible calibrations are refused, and each side can be reset separately. The only data stored is these per-side offsets, on the device. The app asks for no permissions and never uses the network.

**2. Intended user**

People who hang shelves, pictures and curtain rails at home, check whether a table, washing machine or bed is level, or need a quick angle for a ramp, a roof pitch or a saw cut, and do not carry a physical level. It also serves people who rely on VoiceOver: the angle is read aloud and the lock and calibration controls are labelled.

**3. Need or gap**

The paid level apps I studied before building this one are either paid up front, carry ads, or ask for a subscription for the clinometer or the calibration. Most calibrate with a single reading, which only works on a surface that is already level. Sbu Level is free with nothing to buy, has no ads, no account and no network access, calibrates correctly on a tilted surface, measures on all four edges, and is fully usable with VoiceOver and the largest Dynamic Type sizes.

**4. Beta testing**

Testing was internal: TestFlight builds installed on a physical iPhone 15 Pro Max, worked through a written test checklist (first launch, the main flow, the largest text size, VoiceOver, light and dark, Italian and English, relaunch), with exact pass/fail values, plus the iPhone SE size in the simulator. I had no external beta testers for 1.0. Findings fixed before the production build:

- A fresh install read 9.2° on a flat table because of a stored calibration from an earlier build. Fix: that calibration is discarded and implausible calibrations are refused.
- Turning the phone from 0° to 90° in one movement made the reading dip (60° read as 30°). Fix: the dial maths was corrected and the test book now checks 30, 45, 60, 75 and 90 in sequence.
- On the iPhone SE the calibration sheet's "Measure" button was below the fold. Fix: the sheet was reduced to one section.
- The needle hid the dial marks. Fix: the needle breaks under the marks.

**5. Standalone or suite**

Sbu Level is a standalone app. It is one of the apps I publish under the sbu.dev name, each doing one task in a different category: Sbu Level (level and clinometer, Utilities), Sbu Moon (moon phase, Weather), Sbu Noise (sleep sounds, Health & Fitness), Sbu Speed (GPS speedometer, Navigation), Sbu Clean (free up Photos library space), Sbu Habits (habit streaks), plus Sbu Scanner QR Barcode and Sbu Subscriptions, both already on the App Store since May and June 2026. None of them overlaps another in function: I never publish two apps in the same category. Sbu Level is the only one that uses the motion sensors and the only one that measures an angle.

**6. Could it be a feature of another app on my account**

No. No other app on my account measures anything physical, and none of them shares a user need with a level: a person who wants a sleep sound or a subscription reminder has no use for a clinometer, and vice versa. Bundling would force unrelated features and permissions (Photos, Location, Health, background audio) into one app. The apps are also free with no in-app purchases, so delivering this as a purchasable feature expansion is not possible.

**7. Code shared with other apps on my account**

Yes, a small Swift package of mine called SbuKit, about 1,700 lines, shared by all my apps. It contains the colour and typography tokens of my design system, button styles, the large-number component, the "no subscription / no in-app purchases / no account / no ads / no tracking / data on the device" pills, and the Settings screen with the privacy policy and the font licence. It holds no measurement, sensor or business logic. Sbu Level's own code is about 1,400 lines: the motion reading, the four-edge detection, the dial, the two-reading calibration, the settings and the tests.

**8. Code shared with third-party apps**

None. The app uses only Apple frameworks (SwiftUI, Core Motion, Core Haptics). The only outside asset is the Bricolage Grotesque typeface (SIL Open Font License), used for the large number and credited in Settings.

**9. Client, partner or third party**

No. I am Matteo Giuditta, an individual developer; I designed and wrote Sbu Level myself in Swift and SwiftUI, in Xcode, in my own repository. No commercial template, app generation service or third party provided its code, content, concept or branding. sbu.dev is my own site.

I am happy to provide a screen recording or more detail on any point.
