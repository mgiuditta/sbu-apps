# Sbu Auth: video 20 secondi

> "Open" vale solo quando la repo mgiuditta/sbu-apps è pubblica. Prima: "gratis, zero rete".
> File unico verticale 1080×1920, 30 fps, H.264, senza voce. Caricato nativo su Reels, Shorts e TikTok (mai link a YouTube). Musica: solo dalla libreria della piattaforma, oppure silenzio.
> Sottotitoli bruciati nel video in due versioni (IT e EN), testo in SF bianco su fascia `surface` scura, centro schermo in basso, mai sopra la cifra.
> Nella descrizione del post e negli ultimi 2 secondi, piccola: "Authenticator ℠ App è un marchio del rispettivo proprietario; Sbu non è affiliata." / "Authenticator ℠ App is a trademark of its owner; Sbu is not affiliated."

## Storyboard

| Tempo | Immagine | Sovrimpressione IT | Sovrimpressione EN |
|---|---|---|---|
| 0-3 s | Screenshot del paywall dell'originale, ripreso dal proprio iPhone, zoom lento sul prezzo | **9,99 € a settimana** | **$9.99 a week** |
| 3-6 s | Lo stesso screenshot sfocato, il numero cresce | **× 52 = 519,48 € l'anno** | **× 52 = $519.48 a year** |
| 6-15 s | Screen recording di Sbu Auth: scansione QR, compare il codice grande, il countdown scende, tocco per copiare, Face ID | 6-10 s: **Lo stesso codice.** · 10-15 s: **Gratis. Nessun account.** | 6-10 s: **The same code.** · 10-15 s: **Free. No account.** |
| 15-20 s | Schermata strumento ferma, cifra con full stop; poi fondo carta con l'URL | **Gratis, open, zero rete.** · **sbu.dev/apps/auth** | **Free, open, zero network.** · **sbu.dev/apps/auth** |

## Produzione

- Screen recording dal simulatore o dal device (Controllo schermo), account di prova con segreto finto.
- Montaggio: frame 1080×1920 generati con `ImageRenderer` o fastlane frameit sopra la registrazione; testi con le misure del design system.
- Descrizione del post: hook 1 o 8 di `hooks.md`, poi sbu.dev/apps/auth, poi la riga sul marchio.
- Nessun codice reale di account veri nel video.
