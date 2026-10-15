# Sbu Auth: Show HN

> Giorno 1 dalla release, martedì-giovedì, 14:00-16:00 ora italiana (mattina US East). Resta nel thread per 4 ore e rispondi a tutto.

## Titolo (max 80 caratteri)

Principale (79):
`Show HN: I rebuilt a $9.99/week authenticator as a free, zero-network iOS app`

Alternative:
- `Show HN: A free, open-source TOTP app for iOS that never touches the network` (77)
- `Show HN: The $519/year 2FA app, rebuilt free and offline in Swift` (65)

## Primo commento

```
Hi HN, I'm Matteo, a Computer Security student in Milan.

There's an iOS app called Authenticator ℠ App with ~6k US ratings. It generates TOTP codes, which is RFC 6238 and a few lines of HMAC. Its listed in-app prices are weekly: $5.99 to $14.90, most often $9.99. That's up to $519/year for six digits every 30 seconds. Its 1-3 star reviews are mostly people who can't cancel, or whose codes became visible only after paying.

So I rebuilt it and made it free. Sbu Auth:
- TOTP and HOTP (SHA1/256/512, 6-8 digits, custom periods), CryptoKit only
- add by camera QR, QR in a photo, or manual Base32
- imports Google Authenticator's migration QR, and exports the same format, so you're never locked in
- secrets in the Keychain, WhenUnlockedThisDeviceOnly; Face ID lock
- a mandatory encrypted backup: AES-GCM file with your passphrase, saved where you choose, with a reminder

What it does NOT do: no network at all (no sync, no iCloud, no analytics, no account), no autofill (iOS 18+ only, maybe later), no service logos, no widgets, no password manager.

Method: the spec comes only from public App Store data (listing, screenshots, 1-3 star reviews). I never decompile or open other apps' binaries. The code is written with Claude and reviewed by me; every crypto path has tests against the RFC vectors.

Code: https://github.com/mgiuditta/sbu-apps
App and privacy page: https://sbu.dev/apps/auth

Happy to be told what I got wrong.
```

## Risposte pronte

**1. "What happens to my codes if I lose the phone?"**
Nothing leaves the device, so there's no cloud copy by design. That's why the backup is mandatory: on first setup and after every new account the app asks you to export an AES-GCM encrypted file with a passphrase to Files, iCloud Drive or a USB stick, your choice. You can also export everything as Google Authenticator migration QRs and print them. Keep recovery codes from each service too; that's the real last line.

**2. "Why should I trust a student and AI-assisted code with my 2FA secrets?"**
You shouldn't trust me, you should check. The app has no network code path to exfiltrate anything, and the App Store privacy label is "Data Not Collected". The repo is public, the crypto is CryptoKit (no hand-rolled primitives), and the TOTP/HOTP tests use the RFC 4226/6238 vectors. AI wrote drafts; I reviewed every line touching secrets. If you find something, report it through GitHub's private vulnerability reporting on the repo and I'll fix it in public.

**3. "How is this different from Raivo?"**
Raivo was a good open-source app that was sold in 2023; an update then wiped codes for some users and trust collapsed. Sbu Auth can't be "sold" into a data business: no account, no server, no network, and the code stays public. And the backup is mandatory precisely because of what happened to Raivo users.

**4. "2FAS is already free and open source. Why another one?"**
2FAS is good, use it if you like it. It offers cloud backup and a browser extension, so it talks to the network. Sbu Auth is for people who want the opposite trade-off: codes that never leave the device, a local encrypted file as the only backup, and nothing else in the app. Aegis is the closest in spirit, but it's Android only.

**5. "Apple's Passwords app already does TOTP."**
True, and it's the better choice if you're happy with iCloud Keychain: it syncs and autofills. Sbu Auth is for codes you don't want in iCloud, for HOTP and non-standard parameters Passwords doesn't handle, and for moving in and out via Google Authenticator's format. Different trade-off, not a replacement.
