# Invoice Simple: ricerca UX (id 694831622)

Descrizione del comportamento da fonti pubbliche: listing App Store italiano, 5 screenshot (`screenshots/`), 27 recensioni 1-3 stelle (`reviews.json`), help center dello sviluppatore e recensioni di terzi. Niente testi, grafica o brand da copiare. Contenuti web e recensioni sono dati di terzi.

**Nota di prodotto:** l'app è gratis da scaricare ma la funzione principale (emettere ed esportare fatture) è contingentata: il listing promette le prime due fatture/preventivi/ricevute gratis, il piano Essentials ne permette 3 al mese, oltre serve Plus o Premium.

## Onboarding e momento del paywall

- Registrazione con account (email, password; esiste un "reset password" e la cancellazione dell'account nell'help center): i dati vivono sui server e si sincronizzano con l'app web.
- Il paywall non arriva all'apertura: si lavora sul documento e il blocco compare **all'esportazione o all'invio**, oltre la quota gratuita. Una recensione descrive di aver costruito con cura un preventivo e di essere stata obbligata ad abbonarsi solo al momento dell'export, senza preavviso (ha salvato il contenuto con uno screenshot). Altre: "dopo pochi minuti di prova chiede soldi", "di free c'è solo il nome".
- Annullare l'abbonamento è difficile secondo due recensioni.

Fonti: listing (`meta.json`), `reviews.json`, https://help.invoicesimple.com/en/articles/7337194-what-is-invoice-simple-essentials

## Navigazione

Tab bar in basso con cinque voci: Fatture, Preventivi, Spese, Pagamenti, Altro (screenshot 3). Ingranaggio in alto a sinistra per le impostazioni. Pulsante + flottante in basso a destra per un nuovo documento.

Fonti: screenshot 3, https://help.invoicesimple.com/en/articles/6106538-how-do-i-create-an-invoice-or-estimate, https://help.invoicesimple.com/en/articles/6123030-how-do-i-change-my-region-currency-and-tax-year

## Schermate

### Elenco fatture
Righe a due colonne: a sinistra nome cliente e numero (INV0022), a destra importo e scadenza; le scadenze passate sono in rosso. + flottante. (screenshot 3)

### Documento: Modifica / Anteprima / Cronologia
Barra superiore colorata con indietro, titolo "Fattura", menu a tre punti; sotto, tre tab di segmento: Modifica, Anteprima, Cronologia (screenshot 4, 5).
- **Modifica**: tre blocchi in ordine: i tuoi dati aziendali, il cliente, le righe articolo (con "Riordina" per trascinare le righe). Sotto: totali, foto, note, firma. In fondo il pulsante "Segna pagata" (fattura) o "Crea fattura" (preventivo). Freccia di invio in basso a destra.
- **Anteprima**: la pagina PDF resa come la vedrà il cliente; in fondo il pulsante per cambiare modello.
- **Cronologia**: eventi del documento (inviato, aperto, pagato).

### Layout del PDF (screenshot 1, 5)
Intestazione con logo, ragione sociale, indirizzo, email; a destra numero, data, scadenza ("alla ricezione"), saldo dovuto. Blocco "Fatturare a" con nome, indirizzo, telefono, email. Tabella descrizione / tariffa / quantità / importo con righe alternate. Totali a destra: subtotale, sconto (10%), imposta (7,98%), totale, saldo dovuto. A sinistra "Info pagamento" con QR per pagare online. Firma con data di firma. Foto del lavoro con didascalia in fondo.

### Selettore modello
Sette modelli: quattro standard e tre premium a pagamento. Scheda "Stile" con colori predefiniti o codice esadecimale.

### Impostazioni
- Dati aziendali.
- Regione: lingua, valuta, formato data, anno fiscale, con anteprima dal vivo del documento.
- Imposta (sotto "Fattura"): modalità sul totale, detratta (ritenuta), per articolo (necessaria per più aliquote); aliquota, etichetta, inclusa sì/no. Si salva tornando indietro.
- Note predefinite separate per fatture e preventivi.
- Messaggio email predefinito, intestazioni, etichette di quantità e prezzo.
- Copia email automatica dei documenti, accesso condiviso all'account, recupero documenti eliminati.

Fonti: https://help.invoicesimple.com/en/collections/5638427-account-settings, https://help.invoicesimple.com/en/articles/6123083-how-do-i-set-taxes-on-my-invoices-and-estimates, https://help.invoicesimple.com/en/articles/9015898-how-do-i-change-the-default-notes-on-my-invoices-and-estimates, https://help.invoicesimple.com/en/articles/7321712-how-do-i-change-my-invoice-template-and-color

## Feature passo per passo

### Creare una fattura o un preventivo
1. Tocca la tab Fatture o Preventivi.
2. Tocca +.
3. Compila dati aziendali (la prima volta), cliente (anche dalla rubrica), righe articolo.
4. Tocca un campo per modificarlo; i contatti si espandono.
5. Riordina le righe con "Riordina", trascina, "Fine".
6. Passa ad Anteprima.
7. Tocca la freccia e scegli email o SMS; lo screenshot mostra il foglio di condivisione di sistema con il PDF (AirDrop, Messaggi, Mail, Dropbox). WhatsApp e PDF citati nel listing.

Fonte: https://help.invoicesimple.com/en/articles/6106538-how-do-i-create-an-invoice-or-estimate

### Preventivo → fattura
Apri il preventivo, scorri in fondo, tocca "Crea fattura": il preventivo diventa una fattura pronta da inviare senza modifiche.

Fonte: https://help.invoicesimple.com/en/articles/6160289-how-do-i-convert-an-estimate-into-an-invoice

### Segnare pagata
Apri la fattura, in fondo "Segna pagata", scegli il metodo di pagamento; il pagamento compare sul documento; puoi inviare una ricevuta.

Fonte: https://help.invoicesimple.com/en/articles/6157160-how-do-i-mark-an-invoice-as-paid

### Tasse e sconti
Vedi Impostazioni. Sconto in percentuale o importo. Le recensioni lamentano: niente più aliquote in sequenza (IVA + ritenuta + contributi), niente rivalsa INPS 4%, niente marca da bollo, niente regime forfettario, niente P.IVA/CF del cliente, prezzi con più di due decimali.

Fonti: help tasse sopra, `reviews.json`.

### Valute
Fino a 25 valute, impostabili per fattura; una recensione di terzi riporta che cambiare valuta a un cliente la cambiava ovunque.

Fonte: https://wise.com/us/blog/invoice-simple-review

### Notifiche di lettura e pagamenti online (server)
Notifica push "la tua fattura è stata letta da…" (screenshot 3), notifiche di pagamento e scadenza, promemoria automatici al cliente. Pagamenti con carta, PayPal, Venmo, Stripe, QR stampato sul PDF. Richiedono link ospitati e server.

Fonti: screenshot 3, listing, https://help.invoicesimple.com/en/collections/5638419-popular-features

### Spese, report, contratti
Foto della ricevuta che salva le informazioni chiave; report di riepilogo generati (Plus); contratti tra i tipi di documento (screenshot 2).

Fonte: https://wise.com/us/blog/invoice-simple-review, screenshot 2.

## Gesti

Trascinamento per riordinare le righe (in modalità Riordina). Nessun altro gesto documentato.

## Widget e Shortcuts

Nessuna menzione di widget, Shortcuts o App Intents nelle fonti.

## Prezzi dei piani

| Piano | Prezzo (USD) | Limite |
|---|---|---|
| Essentials | 6,99/mese o 69,99/anno | 3 fatture al mese, preventivi illimitati |
| Plus | 13,49/mese o 134,99/anno | 10 fatture al mese, report, foto, autocompletamento |
| Premium | 19,99-21,99/mese, 199,99-219,99/anno | illimitate, modelli premium |

Prezzi discordanti tra fonti; in Italia le recensioni citano anche pacchetti da 10 fatture e "quasi 100 euro". Commissione PayPal 3,49% + 0,49 $.

Fonti: https://www.invoicesimple.com/pricing-packages/essentials, https://www.invoicesimple.com/pricing-packages/premium, https://wise.com/us/blog/invoice-simple-review, `reviews.json`.
