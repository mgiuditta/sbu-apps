# Show HN: Sbu Find

Giorno 1 dopo l'uscita della 1.0, martedì-giovedì, 15-17 ora italiana. Mai nella stessa settimana di un altro Show HN.

## Titolo (≤80 caratteri)

`Show HN: Find lost earbuds by Bluetooth signal, free, no weekly subscription` (76)

Alternativa: `Show HN: A hot-and-cold Bluetooth finder for iPhone that doesn't lie about meters` (80)

## Primo commento

> Hi HN, I'm Matteo, a computer security student in Milan.
>
> The top "find my earbuds" apps on the App Store are free to download, then the search sits behind a subscription, in one case listed at up to $12.99 a week. The job itself is small: scan Bluetooth Low Energy, read the signal strength, tell you if you're getting warmer.
>
> Sbu Find does that for free. It lists nearby devices with a signal ring; pick one and you get a filtered percentage that doesn't jump around, a word (Cold, Warm, Hot, Very close), and a tick that speeds up with a haptic, so you can search under the couch without looking. It can play a sound in headphones still connected to the phone, notify you when one of your devices goes quiet, show on a map where your phone last heard it, and keep the search on the Lock Screen and in the Dynamic Island.
>
> What it does NOT do: give you meters. RSSI is not distance; it changes with your body, walls and the case. Any app that shows "1.2 m" is dressing up a guess. It also can't hear devices that are off, flat or inside a closed case, and it doesn't use Apple's Find My network. The app says so and sends you to Find My when that's the right tool.
>
> Method: specs come only from public App Store data (listings, screenshots, 1-3 star reviews). Nothing decompiled. Built with Claude, every line reviewed by me; Swift 6, SwiftUI, Core Bluetooth, iOS 17+.
>
> Privacy: no account, no analytics, no ads, no server. Bluetooth and location stay on the phone; location is only used for the "last heard here" pin, and only if you allow it.
>
> It's one of a set of free iPhone apps I'm building at sbu.dev, each doing one thing with no subscription.
>
> Repo: github.com/mgiuditta/sbu-apps. Page: https://sbu.dev/apps/find

## Risposte pronte

1. **"Find My already does this for AirPods."**
   > For AirPods, yes, and if they're in the case or far away it's the better tool. Find My doesn't cover most non-Apple earbuds, speakers or watches. Sbu Find hears any BLE device that's advertising.

2. **"RSSI is useless, it jumps everywhere."**
   > Raw, yes. The percentage is smoothed and the word has hysteresis, so it doesn't flip between Warm and Hot on every sample. It's good for the last few meters, which is the problem: you know they're in the room.

3. **"Why does it need location?"**
   > Only for the map pin of where your phone last heard a device. Without permission everything else works.

4. **"Free means a paywall later."**
   > No IAP, no ads, no SDKs, no account. There's nothing to monetise. The code is public.

5. **"Background scanning drains the battery."**
   > The lost-device alert is opt-in. iOS throttles background BLE anyway; the app doesn't fight it.
