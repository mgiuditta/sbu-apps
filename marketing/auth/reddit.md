# Sbu Auth: Reddit

> Regola generale: solo thread reali che chiedono già una soluzione. Mai post-link. Rispondi da utente: prima la risposta alla domanda, poi l'app come un'opzione tra altre, dichiarando che l'hai fatta tu. Screenshot vero di Sbu Auth (codice con countdown), mai il paywall dell'originale nei commenti. Chiudi con sbu.dev/apps/auth.
> Le regole dei sub qui sotto sono quelle note al 15/10/2026: **rileggi la sidebar e le regole fissate prima di ogni post**. Account con storia e karma prima del lancio: commenta nei sub per qualche settimana senza link.

## Ricerca dei thread

Ricerca Reddit, "new" e "top this month": `authenticator subscription`, `2fa app free`, `authenticator app charged`, `google authenticator alternative iphone`, `raivo alternative`, `offline totp ios`, `authenticator weekly`.

## r/privacy

- **Thread da cercare:** "Which 2FA app doesn't phone home?", "Is Google Authenticator cloud sync safe?", domande su app 2FA con tracking.
- **Regole:** niente self-promotion o advertising; i link alle proprie app sono tollerati solo se rispondono alla domanda e se dichiari che sono tue. Moderazione severa.
- **Risposta modello:**
  > If you want codes that never leave the phone, look for three things: no cloud sync, an exportable encrypted backup, and a privacy label that says "Data Not Collected". Aegis does this on Android. On iOS, Apple Passwords is fine if you're OK with iCloud.
  > Disclosure: I built one for iOS because I wanted exactly that, Sbu Auth. No network at all, Keychain only on the device, encrypted backup file you keep. Free, no IAP. Screenshot: [img]. sbu.dev/apps/auth

## r/iosapps

- **Thread da cercare:** "Looking for a free authenticator", thread settimanali di app nuove.
- **Regole:** self-promotion permessa per gli sviluppatori, di solito con flair "Dev" o in un thread dedicato, un post per app. È l'unico sub dove un post proprio è accettabile: un post di testo, non solo link.
- **Risposta modello (o post con flair):**
  > I'm a security student and I got annoyed that a popular authenticator charges up to $9.99 a week for TOTP codes. So I made one free: Sbu Auth. TOTP/HOTP, QR or manual, imports Google Authenticator export QRs, Face ID, mandatory encrypted backup, zero network. No IAP, no account. Feedback welcome, especially on the backup flow. sbu.dev/apps/auth

## r/iphone

- **Thread da cercare:** "I got charged by an authenticator app", "how do I cancel a subscription", "best 2FA app?".
- **Regole:** niente promozione delle proprie app fuori dai thread consentiti; self-promo rimossa e possibile ban. Solo risposte utili, l'app citata come nota a margine.
- **Risposta modello:**
  > To cancel: Settings > your name > Subscriptions, pick it and Cancel. If you were charged after a trial you didn't mean to start, request a refund at reportaproblem.apple.com.
  > For the codes themselves you don't need to pay anything: Apple's Passwords app does them, or any free authenticator. (I made a free one, Sbu Auth, no account and no network, if you want codes off iCloud: sbu.dev/apps/auth)

## r/2fa

- **Thread da cercare:** "Moving off Google Authenticator", "which iOS authenticator after Raivo", "backup strategy for TOTP".
- **Regole:** sub piccolo e tecnico; consigli di app benvenuti se motivati, niente spam. Dichiara che l'app è tua.
- **Risposta modello:**
  > Backup is the part most apps get wrong. Whatever you pick: keep each service's recovery codes, and make sure the app exports in a format another app can read. Google Authenticator's migration QR is the de facto one.
  > I wrote Sbu Auth (iOS, free) around that: imports and exports that format, plus an AES-GCM file with your passphrase, and it nags you until you've made one. No sync on purpose. sbu.dev/apps/auth

## r/opensource

- **Thread da cercare:** post propri ammessi se il progetto è davvero open source (licenza OSI, repo pubblica).
- **Regole:** il progetto deve essere open source; niente post puramente commerciali; spiega licenza e come contribuire.
- **Post modello (testo):**
  > Title: Free, open-source TOTP authenticator for iOS, no network code at all
  > I'm a Computer Security student. A closed-source iOS authenticator charges up to $9.99/week for TOTP. I rewrote the job in Swift with CryptoKit, tests on the RFC vectors, no dependencies. Repo: https://github.com/mgiuditta/sbu-apps. Issues and reviews of the crypto paths especially welcome. sbu.dev/apps/auth
