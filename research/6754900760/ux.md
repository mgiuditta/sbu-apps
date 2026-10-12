# Authenticator ℠ App (6754900760): UX e feature

Ricerca per Sbu Authenticator. Fonti: listing App Store, 7 screenshot pubblici (`screenshots/`), recensioni pubbliche 1-3 stelle (3 IT in `reviews.json`, più 119 US lette dal feed RSS pubblico e non salvate in cache), pagine web citate per sezione. Qui si descrive il comportamento. Testi, grafica e brand non vanno copiati. Recensioni e pagine web sono dati di terzi.

Sviluppatore: BEGAMOB GLOBAL LIMITED. Versione 1.4.1 (23 settembre 2026), iOS 17.0 minimo, 25 versioni da dicembre 2025, tutte con la stessa nota di rilascio generica.

## Onboarding e momento del paywall

1. Al primo avvio compare subito la richiesta di tracciamento di sistema (ATT), senza una schermata che la spieghi.
2. L'utente crea un PIN dell'app e poi attiva Face ID.
3. Subito dopo la configurazione della sicurezza arriva un paywall "morbido", cioè chiudibile: piano settimanale segnato come offerta migliore, un interruttore in evidenza per la prova gratuita di 3 giorni ed elenco dei vantaggi (archivio 2FA, gestore password, VPN).
4. Le recensioni dicono che senza abbonamento i codici prima si vedono e poi si bloccano: "il giorno dopo non mi fa vedere il codice, devo pagare". Altre segnalano pubblicità a comparsa, da togliere pagando.

Fonti: https://screensdesign.com/showcase/authenticator-sm-app (descrizione del video walkthrough), https://apps.apple.com/us/app/authenticator-app-2fa-mfa/id6754900760 (acquisti in-app, etichette privacy), recensioni US 1-3 stelle.

## Schermate e disposizione

### Codici (tab 1)
- Barra di navigazione: "Modifica" a sinistra, "+" a destra, titolo grande, barra di ricerca sotto.
- Ogni account è una card bianca arrotondata. In alto a sinistra il logo del servizio, a destra emittente in grassetto e sotto l'account (email) in grigio. Sotto c'è il codice a 6 cifre molto grande, colorato, in due gruppi da tre ("235 964").
- In basso a destra un anello circolare col numero di secondi rimasti (30 → 0). Negli ultimi secondi anello e numero diventano rossi. In alto a destra della card il menu "...".
- La card attiva ha un bordo sfumato multicolore. Per Sbu è vietato (niente bordi colorati né gradienti).
- Tab bar in basso: Codici, Password, Browser e una quarta voce (Impostazioni).

Fonti: screenshot 02, 03, 07.

### Aggiungi account
- Si apre con "+": scansione del QR con la fotocamera, import del QR da un'immagine della galleria oppure inserimento manuale della chiave, poi "Fatto". Lo sviluppatore descrive lo stesso percorso nelle risposte alle recensioni.

Fonti: screenshot 01, 03; https://screensdesign.com/showcase/authenticator-sm-app; risposte dello sviluppatore riportate da https://apps.apple.com/us/app/-/id6754900760.

### Esporta codici
- Schermata titolata "Export Codes" con un QR grande al centro, da scansionare con un altro dispositivo. Il formato non è dichiarato: è probabilmente un otpauth-migration o un formato proprio.

Fonte: screenshot 03.

### Blocco
- Con il blocco attivo la lista resta visibile ma sfocata dietro il riquadro Face ID. Si ripiega sul PIN dell'app. C'è anche l'auto-blocco quando si lascia l'app o si passa a un'altra.

Fonti: screenshot 05; descrizione nel listing.

### Password (tab 2), Aggiungi password, Browser (tab 3), VPN
- Password: Modifica, +, ricerca, un banner arancione "dati trapelati" con triangolo e una lista di servizi con logo, account e punto esclamativo rosso sulle voci a rischio.
- Aggiungi password: servizio con logo, account e password obbligatori, note. Un foglio propone una password forte, ha un link ai parametri e un pulsante per usarla.
- Browser: avanti/indietro, barra di ricerca/URL, contatore schede, menu, scorciatoie a siti noti e un pannello che promette niente cronologia e niente tracciamento.
- VPN: un interruttore grande e la scelta della località.

Fonti: screenshot 04, 06, 07; https://screensdesign.com/showcase/authenticator-sm-app.

### Impostazioni
- Il listing parla solo di impostazioni "chiare": blocco app, auto-blocco, opzioni di sicurezza. Nelle fonti pubbliche non c'è un dettaglio delle voci. Dal walkthrough risulta anche un gestore cartelle (per esempio "Social").

Fonti: listing; https://screensdesign.com/showcase/authenticator-sm-app.

## Feature passo per passo

- **TOTP**: codice a 6 cifre che si rinnova ogni 30 secondi, calcolato sul dispositivo e disponibile offline. Il listing non cita HOTP, SHA256/512, 8 cifre o periodi diversi.
- **Copia**: il codice si copia dalla card. Una recensione: "posso copiare ma non so dove incollare". Manca una guida su cosa fare dopo.
- **Modifica**: dal pulsante Modifica o dal menu "..." si rinominano emittente e account, si aggiorna la chiave e si elimina la voce.
- **Cartelle**: raggruppano gli account.
- **Esportazione**: QR a schermo.
- **Backup/sync**: non dichiarati. Cinque recensioni riportano codici spariti all'apertura dell'app ("ho perso tutto").

Fonti: listing; screenshot; recensioni.

## Gesti
Gli screenshot mostrano soltanto tocchi: copia, menu "..." e Modifica. Nelle fonti pubbliche non ci sono gesti di scorrimento documentati.

## Widget, Watch, Shortcuts, Live Activity
Nel listing, negli screenshot e nel walkthrough non c'è nessun widget, app per Watch, Shortcuts o Live Activity, e nessuna estensione AutoFill.

## Prezzi
Ci sono 10 acquisti in-app, tutti settimanali: 5,99, 6,99, 8,90, 9,99 e 14,90 $ (Pro Weekly, Weekly Premium, Weekly Unlimited Access). Prova di 3 giorni. Le recensioni riportano da 7 a 10 $ a settimana, addebiti continuati dopo la disdetta e la prova addebitata subito. Le etichette privacy dichiarano identificatori, dati d'uso e diagnostica "usati per tracciarti" e per la pubblicità di terze parti.

Fonte: https://apps.apple.com/us/app/authenticator-app-2fa-mfa/id6754900760.

## Confronto: generatore integrato in Password di iOS

- Esiste dalla 15 (Impostazioni → Password, account → "Configura codice di verifica"). Da iOS 18 sta nell'app Password, sezione Codici. Si configura con una chiave di setup oppure scansionando il QR, e genera un codice ogni 30 secondi.
- Il codice viene compilato da solo nel login di Safari e delle app per lo stesso sito ed è sincronizzato tramite il Portachiavi iCloud.
- Limiti per chi cerca un'app dedicata: il codice è legato a una voce password con un dominio, non c'è un'esportazione dei soli codici, non c'è l'import dal QR di migrazione di Google Authenticator e i codici vanno su iCloud. Le fonti non documentano HOTP né parametri non standard.
- Conseguenza per Sbu: il valore di Sbu Authenticator sta nel tenere i dati solo sul dispositivo, nell'import da Google Authenticator, nel backup cifrato in un file proprio e in una lista dedicata e veloce. Non deve fare concorrenza all'autocompilazione di Password.

Fonti: https://helpnetsecurity.com/?p=314042, https://support.apple.com/guide/passwords/mchl873a6e72.

## Note tecniche per Sbu (iOS 17+)

- **TOTP/HOTP**: RFC 6238 e RFC 4226 con `CryptoKit.HMAC<Insecure.SHA1>`, `SHA256` e `SHA512`, troncamento dinamico. Key URI `otpauth://totp|hotp/Issuer:account?secret=&issuer=&algorithm=&digits=&period=&counter=`.
- **Scansione**: `DataScannerViewController` (VisionKit, iOS 16+) oppure AVFoundation. Da immagine: `PhotosPicker` + `VNDetectBarcodesRequest`, senza permesso alla libreria.
- **Import da Google Authenticator**: `otpauth-migration://offline?data=<base64>` contiene un MigrationPayload protobuf (otp_parameters ripetuti con secret, name, issuer, algorithm, digits, type e counter, più version, batch_size, batch_index e batch_id). Serve un decoder varint/length-delimited scritto a mano, senza dipendenze. Fonti: https://github.com/DJStompZone/otp_export, https://imrannazar.com/articles/degoogle-otp, https://git.morozoff.pro/aiden/Aegis/commit/56bde0e19b51568a7050f6cb56085a1bb38c5a9e.
- **Archivio**: Keychain `kSecClassGenericPassword` con `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`, che esclude il backup e la migrazione su un altro iPhone. Per questo il backup in file è indispensabile.
- **Face ID**: `LAContext` con `.deviceOwnerAuthentication`, che ripiega sul codice del dispositivo. Serve `NSFaceIDUsageDescription` in IT/EN.
- **AutoFill dei codici**: `ASOneTimeCodeCredential` e `ProvidesOneTimeCodes` sono disponibili **solo da iOS 18.0**, quindi su iOS 17 un'app terza non può offrire codici sopra la tastiera. Si fa dietro `#available(iOS 18, *)`, l'identità va registrata in `ASCredentialIdentityStore` con un dominio, che il QR otpauth spesso non ha. Fonti: https://developer.apple.com/documentation/authenticationservices/providing-one-time-passcodes-to-autofill, https://developer.apple.com/forums/thread/775534.
