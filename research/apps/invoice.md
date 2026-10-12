# Sbu Invoice: sintesi su Invoice Simple e Invoice Fly

Originali studiati: Invoice Simple (id 694831622, Zenvoice Inc.) e Invoice Fly (id 1606911248, Labhouse Mobile). Fonti: `research/694831622/` e `research/1606911248/` (`spec.json`, `ux.md`, `reviews.json` con 27 e 3 recensioni 1-3 stelle, screenshot).

**Attenzione prima di tutto:** ADR-0004 vuole un solo **Originale** per App Sbu; l'altra app della nicchia è un **Concorrente**. Proposta: Invoice Simple Originale (più recensioni italiane, funzione principale identica, più vecchia e più scaricata in IT), Invoice Fly Concorrente. Da chiudere in un grilling prima di costruire.

**Cosa sola proposta:** "fai una fattura e la mandi". **Cifra** candidata: l'importo della fattura aperta nell'editor, o il totale da incassare nell'elenco (grilling).

## Matrice feature

| Feature | Originale | A pagamento? | Sbu | Framework iOS (iOS 17+) | Conflitto con CLAUDE.md? |
|---|---|---|---|---|---|
| Dati della tua attività e logo | entrambi | Sì (oltre la quota / dopo il paywall) | core | SwiftData, `PhotosPicker` | No |
| Coordinate bancarie e note predefinite | Simple (Fly: istruzioni di pagamento) | Sì | core | SwiftData, `@AppStorage` | No |
| Clienti, anche dalla rubrica | entrambi | Sì | core | SwiftData, `CNContactPickerViewController` (nessun permesso) | No |
| Catalogo articoli salvati | Fly (Simple: autocompletamento in Plus) | Sì (Plus) | core | SwiftData, `@Query` | No |
| Editor fattura: righe, quantità, prezzo, riordino | entrambi | Sì | core | `Form`, `List` + `onMove`, `Decimal` | No |
| Imposte (sul totale, per riga, inclusa, ritenuta) e sconti | entrambi | Sì | core | tipi puri `Decimal`, Swift Testing | No; campi italiani da decidere |
| Valuta e formati | entrambi | Sì | core | `Decimal.FormatStyle.Currency`, `Date.FormatStyle`, `Locale` | No |
| Numerazione progressiva | entrambi | Sì | core | SwiftData, tipo puro | No |
| PDF e anteprima | entrambi | Sì (export oltre la quota) | core | `UIGraphicsPDFRenderer`, `PDFKit.PDFView` | Sì, di design: il PDF segue il design system? |
| Invio via foglio di condivisione, Mail, Messaggi, stampa | entrambi | Sì | core | `ShareLink`/`UIActivityViewController`, `MFMailComposeViewController`, `UIPrintInteractionController` | No |
| Firma | entrambi | Sì | core | PencilKit `PKCanvasView` | No |
| Stato pagata / non pagata / scaduta, metodo di pagamento | entrambi | Sì | core | SwiftData, stato derivato dalla data | No (stato con parola o SF Symbol) |
| Preventivo → fattura | entrambi | Sì | core | copia di modello SwiftData | No |
| Duplica documento | Fly (Simple no, chiesto nelle recensioni) | Sì | core | SwiftData | No |
| Ricevuta di pagamento | Simple | Sì | nice | PDF variante | No |
| Foto allegate al documento | entrambi | Sì (Plus) | nice | `PhotosPicker`, PDF | No |
| Elenco con schede mensili e filtro | Fly | Sì | nice | `@Query`, `SbuStat` | Sì se più cifre per schermata: una sola |
| Report (fatturato, per cliente, tasse) | entrambi | Sì (Plus) | nice | Swift Charts | Grilling: seconda cosa? |
| Esportazione e importazione dei dati | Fly | Sì | core | `FileDocument`/`fileExporter`, JSON | No: è il backup senza account |
| Promemoria locale di scadenza | entrambi (lato server) | Sì | nice | `UNUserNotificationCenter` locale | No se locale |
| Widget "da incassare" | Fly | Sì | nice | WidgetKit, App Group | No |
| Modelli e colori del documento | entrambi | Sì (modelli premium) | da decidere | — | Sì: un solo accento, niente colori inventati |
| Fatture e Preventivi in due tab | Simple (5 tab), Fly (tab) | — | da decidere | `NavigationStack` | Sì: ADR-0001 niente tab bar |
| Campi fiscali italiani (P.IVA/CF cliente, ritenuta, rivalsa INPS, bollo, forfettario) | nessuno (chiesti nelle recensioni) | — | da decidere | tipi puri | Ambito e responsabilità legale |
| Fattura elettronica SDI / XML FatturaPA | nessuno | — | da decidere | `XMLDocument` non c'è su iOS: XML generato a mano | Sì: l'invio allo SDI richiede intermediario e rete |
| Notifica di lettura / "fattura vista" | entrambi | Sì | skip | — | Sì: server e link ospitato |
| Pagamenti online (carta, PayPal, Stripe, QR) | entrambi | Sì | skip | — | Sì: account, server, pagamenti |
| Promemoria automatici al cliente, fatture ricorrenti inviate da sole | entrambi | Sì | skip | — | Sì: server |
| Spese, scansione ricevute | entrambi | Sì | skip | VisionKit | Una cosa sola |
| Registro ore | Fly | Sì | skip | — | Una cosa sola |
| AI (preventivi da foto, fattura a voce, assistente, loghi) | Fly | Sì | skip | — | Rete, cloud AI |
| Account, sincronizzazione, team | entrambi | — | skip | — | Sì |
| Contratti | Simple | Sì | skip | — | Una cosa sola |
| Abbonamento, prova, quota mensile | entrambi | — | skip | — | Sì |

## Problemi principali degli utenti

1. **Non è a norma in Italia** (11 recensioni Simple, 2 Fly): manca P.IVA o codice fiscale del cliente, più aliquote, ritenuta d'acconto, rivalsa INPS 4%, Enasarco, marca da bollo, regime forfettario; "programma non legale", "inutilizzabile per una fattura dovuta".
2. **Paywall a sorpresa** (6): si scrive il preventivo e il blocco arriva all'export; "gratis solo per pochi minuti". Invoice Fly mette il paywall settimanale prima della prima fattura.
3. **Crash, schermate bianche, PDF lento** dopo gli aggiornamenti (4).
4. **Abbonamento difficile da annullare** (2) e prezzo alto (1).
5. **Dati persi e sincronizzazione** (2): "persi tutte le fatture del 2017".
6. Manca **duplica** (1), ricerca rapida clienti (1), prezzi con tre decimali (1), fattura elettronica (1).

## Cosa Sbu fa meglio

- Tutte le fatture e i preventivi che vuoi, PDF ed export compresi: nessuna quota, nessun paywall a metà lavoro.
- Pensata in italiano: P.IVA e codice fiscale del cliente, IVA per riga, ritenuta e contributi come righe del riepilogo (perimetro da decidere nel grilling), importi in euro formattati bene, prezzi con più decimali.
- Duplica e preventivo → fattura in un tocco.
- Dati solo sul dispositivo, nessun account: esportazione e importazione in un file come backup, PDF tuoi anche senza l'app.
- Invio con gli strumenti di iOS (Mail, Messaggi, AirDrop, stampa): nessun server tra te e il cliente.
- Una cosa sola: fare la fattura e mandarla. Niente spese, AI, contratti, prestiti.
