# Sbu Authenticator: sintesi su Authenticator ℠ App

Originale: Authenticator ℠ App (id 6754900760, BEGAMOB GLOBAL LIMITED), gratis da scaricare ma con la funzione principale dietro un abbonamento settimanale da 5,99 a 14,90 $. Fonti: `research/6754900760/spec.json`, `research/6754900760/ux.md`, screenshot e recensioni pubbliche.

Slug Sbu: `authenticator`. Cartella prevista: `Apps/SbuAuthenticator`, da creare con `Tools/new_app.sh`. Il token di accento non esiste ancora.

## Matrice feature

| Feature | A pagamento nell'originale? | Sbu | Framework iOS (17+) | Conflitto con CLAUDE.md? |
|---|---|---|---|---|
| Codici TOTP (RFC 6238) | sì, dopo il periodo iniziale | core | CryptoKit (HMAC SHA1/256/512) | no |
| HOTP (RFC 4226) e parametri otpauth (cifre, periodo, algoritmo) | non dichiarato | core | CryptoKit | no |
| Aggiunta da QR con fotocamera | no (prima del blocco) | core | VisionKit `DataScannerViewController` / AVFoundation | no (permesso fotocamera IT/EN) |
| Aggiunta da immagine in galleria | no | core | PhotosUI `PhotosPicker` + Vision | no |
| Inserimento manuale chiave Base32 | no | core | SwiftUI `Form` | no |
| Copia del codice con un tocco | sì (codici bloccati) | core | UIPasteboard (scadenza locale) | no |
| Lista con ricerca, modifica, riordino ed eliminazione | sì | core | `List .insetGrouped`, `.searchable`, `EditButton` | no. Una sola cifra per schermata: la lista mostra i codici come `statSmall` e il full stop non va sulla lista |
| Blocco con Face ID / codice e auto-blocco | sì | core | LocalAuthentication, `scenePhase` | no |
| Archivio sicuro | n/d | core | Security (Keychain, `WhenUnlockedThisDeviceOnly`) | no |
| Esportazione account come QR | sì | core | CoreImage `CIQRCodeGenerator` | no |
| Import dal QR di migrazione di Google Authenticator | non presente | core | decoder protobuf scritto a mano | no (nessuna dipendenza in SbuKit) |
| Backup cifrato in file locale | non presente | core | CryptoKit AES-GCM + HKDF/PBKDF, `fileExporter`/`fileImporter` | no |
| Cartelle | sì | nice | SwiftUI | no |
| Sincronizzazione iCloud (Portachiavi o CloudKit) | non dichiarato | grilling | Security `kSecAttrSynchronizable` / CloudKit | **sì**: è rete Apple, contro "dati solo sul dispositivo" |
| Widget con codici | non presente | grilling | WidgetKit | **dubbio**: segreti visibili fuori dall'app bloccata |
| AutoFill dei codici | non presente | grilling | AuthenticationServices `ASOneTimeCodeCredential`: **solo iOS 18+** | **dubbio**: richiede `#available`, target 17 |
| Loghi dei servizi | sì | grilling (skip proposto) | asset di terzi | **sì**: marchi di terzi, scaricarli è rete. "SF Symbols, niente icone custom" |
| Gestore password e generatore | sì | skip | n/d | **sì**: seconda funzione. Sbu fa una cosa sola e iOS ha già Password |
| Avviso dati trapelati | sì | skip | n/d | **sì**: rete |
| Browser privato | sì | skip | n/d | **sì**: rete, seconda funzione |
| VPN | sì | skip | n/d | **sì**: rete, server |
| Abbonamento settimanale, prova di 3 giorni | n/d | skip | n/d | **sì**: niente acquisti |
| ATT, pubblicità, analytics | n/d | skip | n/d | **sì**: niente tracking né ads |

## Problemi principali degli utenti

Fonte: 122 recensioni da 1 a 3 stelle (3 IT, 119 US).

1. **Disdetta impossibile e addebiti dopo la disdetta** (circa 24 menzioni). La prova di 3 giorni addebita subito o viene scambiata per gratuita, e i piani sono settimanali da 7 a 10 $.
2. **Confusione con Google o Microsoft Authenticator** (circa 9). Nome e immagini dello store richiamano le app ufficiali, e un reparto IT racconta di ticket arrabbiati dei dipendenti.
3. **Codici presi in ostaggio**: dopo averci messo gli account, i codici diventano visibili solo pagando.
4. **Codici persi** senza backup ("ho aperto l'app e avevo perso tutti i codici"), che significa restare chiusi fuori dagli account.
5. **Difficile da configurare** (circa 15): QR non riconosciuti, nessuna guida su dove incollare il codice, troppe schermate, poco adatta agli anziani.
6. Pubblicità a comparsa e crash.

## Cosa Sbu fa meglio

- **I codici non si bloccano mai.** Niente paywall, niente prova, niente abbonamento da disdire: elimina alla radice il problema numero 1 e il numero 3.
- **Nome onesto.** "Sbu Authenticator" con l'icona incisa e il full stop non imita Google né Microsoft (linea guida 4.1), e la scheda lo dice chiaramente.
- **Non si perde nulla.** Il backup cifrato va in un file che l'utente tiene dove vuole, il Keychain è solo del dispositivo, ogni eliminazione chiede conferma (`SbuButton(kind: .destructive)`) e c'è un avviso se non c'è un backup recente.
- **Cambio app in un minuto.** Si importa dal QR di esportazione di Google Authenticator, che l'originale non supporta, e si esporta nello stesso formato: l'utente non resta mai bloccato in Sbu.
- **Una cosa sola.** Solo codici 2FA: niente password, browser o VPN. Per le password resta l'app Password di iOS.
- **Rispetto ad Apple Password**: Sbu non manda i segreti su iCloud, non lega il codice a una voce password con dominio, supporta HOTP e i parametri non standard, e importa ed esporta. Password resta più comoda per l'autocompilazione, e Sbu non prova a sostituirla.

## Decisioni aperte (grilling)

- Sincronizzazione iCloud: ammessa come "rete Apple" o no?
- Widget: mostrare codici fuori dall'app bloccata?
- AutoFill dei codici: solo iOS 18+, ne vale la pena con target 17?
- Loghi dei servizi o iniziali/SF Symbols?
- La figura della schermata: il codice dell'account selezionato come `SbuStat` col full stop, oppure una lista senza figura?
- Token `accent-authenticator` nuovo in `Design/tokens.json`.
