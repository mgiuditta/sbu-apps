# Show HN: Sbu Clean

## Titolo (≤80 caratteri)

`Show HN: I rebuilt a $11.99/week iPhone photo cleaner as a free app` (66)

Alternativa: `Show HN: Free iPhone photo cleaner, no server, vs. a $623/year paywall` (71)

## Primo commento

> Hi HN, I'm Matteo, a computer security student in Milan.
>
> Cleanup (737K ratings on the US App Store) lets you swipe through your photos for free, then locks Delete behind a weekly plan: the store lists it at $5.95 to $11.99 a week (a $24.99/year plan also exists in some regions). Swipewipe does the same at up to $9.99 a week. 42 of 69 recent 1-3 star Cleanup reviews say "free isn't free".
>
> Sbu Clean does the same job for free: swipe keep/delete month by month, duplicates and similar photos (Vision, on the device; the best shot is a suggestion, never auto-deleted), screenshots, videos sorted by size. You review a bin, and deletion goes only through PhotoKit's performChanges, so iOS shows its own confirmation. It also tells you that deleted photos sit in Recently Deleted for 30 days, which is why "the space didn't come back".
>
> Method: specs come only from public App Store data (listing, screenshots, reviews). Nothing decompiled. I built it with Claude and reviewed every line myself; Swift 6, SwiftUI, iOS 17+.
>
> Privacy: no account, no analytics, no ads, no server of mine. The only download is an iCloud original, and only when you ask to view or compress it.
>
> What it does NOT do: email cleanup, contacts merge, iCloud "cleaning", AI enhance, streaks. One thing.
>
> Repo: github.com/mgiuditta/sbu-apps [SOLO QUANDO PUBBLICA]. Page: https://sbu.dev/apps/clean

## Risposte pronte

1. **"Why not Photos' Duplicates album?"**
   > If Duplicates is enough for you, use it. It finds exact and near-identical copies. It doesn't do swipe review month by month, screenshots, videos by size, or tell you how much space you can free. That's the gap Sbu Clean fills.

2. **"It needs full Photos access. Why trust it?"**
   > It needs to read the library to find duplicates. Analysis runs on the phone with Vision; there's no server to send anything to, and the App Store label is "Data Not Collected". Delete is iOS's own dialog, so nothing goes without you confirming twice. [Quando la repo è pubblica: the code is there, check it.]

3. **"What about Limited Photos access?"**
   > It works on the photos you shared with it. Duplicates are found only among those, and the app says so instead of failing silently.

4. **"Free means you sell data, or a paywall comes later."**
   > No IAP, no ads, no SDKs, no account: there's nothing to monetise and nowhere to send data. It's a student project, and the promise is written on every Sbu app page.

5. **"$11.99 a week is cherry-picked; there's a yearly plan."**
   > Fair. The store lists weekly plans from $5.95 to $11.99 and a yearly one in some regions; that's why I write "up to". The point stands: deleting a photo costs nothing in iOS.
