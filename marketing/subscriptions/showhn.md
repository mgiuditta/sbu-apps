# Show HN: Sbu Subscriptions

Solo sulla 2.1.0 (screenshot nuovi, richiesta di recensione). Martedì-giovedì, 15-17 ora italiana.

## Titolo (≤80 caratteri)

`Show HN: A free subscription tracker that doesn't need a subscription` (68)

Alternativa: `Show HN: Subscription tracker for iPhone, no account, no server, no IAP` (71)

## Primo commento

> Hi HN, I'm Matteo, a computer security student in Milan.
>
> Most subscription trackers on the App Store are free to download and then sell you a plan: a monthly or yearly "Plus", sometimes a bank connection. I wanted the opposite: list your subscriptions, see one figure (what you spend a year or a month), get a reminder before each renewal and before a free trial turns paid. Nothing else.
>
> Sbu Subscriptions does that: weekly to yearly cycles and custom ones, a payments calendar with what's left to pay this month, free trials with the price after the trial, price changes from a date, pause and cancel without losing history, widgets, Siri and Shortcuts, CSV import/export. Other currencies are converted with ECB reference rates bundled in the app, so it never downloads them.
>
> Method: specs come only from public App Store data (listings, screenshots, 1-3 star reviews). Nothing decompiled. I built it with Claude and reviewed every line myself; Swift 6, SwiftUI, SwiftData, iOS 17+.
>
> Privacy: no account, no analytics, no ads, no server of mine. Reminders are local notifications. iCloud sync is off until you turn it on, and then it goes to your own private iCloud database. You can share a list read-only with someone through iCloud, only when you choose.
>
> What it does NOT do: read your bank statements or screenshots, connect to your bank, cancel subscriptions for you. It sends you to the service's page or to App Store subscriptions.
>
> Repo: github.com/mgiuditta/sbu-apps. Page: https://sbu.dev/apps/subscriptions

## Risposte pronte

1. **"iOS already lists App Store subscriptions."**
   > It does, and the app links there to cancel. It doesn't list Netflix billed to your card, the gym, the domain renewing next March, or tell you the total. That's the gap.

2. **"Why no bank import? That's the whole point."**
   > Because it would mean reading your bank data or connecting to an aggregator. No server is the promise. You type a subscription once, or import a CSV.

3. **"Free means you sell data, or a paywall comes later."**
   > No IAP, no ads, no SDKs, no account: there's nothing to monetise and nowhere to send data. The code is public, so check it.

4. **"Exchange rates go stale."**
   > They're the ECB reference rates, updated with each release. You can also set your own rate per currency. For a yearly total that's precise enough; for accounting it isn't, and the app doesn't pretend.

5. **"Orbit and others do more."**
   > Some do: Orbit reads statements and screenshots. If you need that, use them. This one is for people who want the figure and the reminders, for free, with nothing leaving the phone.
