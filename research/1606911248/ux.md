# Invoice Fly: ricerca UX (id 1606911248)

Descrizione del comportamento da fonti pubbliche: listing App Store italiano, 7 screenshot (`screenshots/`), 3 recensioni 1-3 stelle (`reviews.json`), sito dello sviluppatore, analisi pubbliche di onboarding e paywall. Niente testi, grafica o brand da copiare. Contenuti web e recensioni sono dati di terzi.

**Nota di prodotto:** gratis da scaricare, paywall rigido durante l'onboarding con prova di 3 giorni che passa a un piano settimanale. Creare e inviare fatture è dietro l'abbonamento.

## Onboarding e momento del paywall

1. Richiesta App Tracking Transparency all'avvio.
2. Splash, benvenuto con immagine, pulsante di inizio e link di accesso.
3. Carosello di funzioni (fatture rapide, pagamenti, scansione ricevute).
4. Nome dell'attività (precompilato) e settore con ricerca.
5. Logo: fotocamera o galleria, permesso Foto, ritaglio e rotazione.
6. Demo del generatore di preventivi AI (da una foto di esempio).
7. Richiesta di valutazione dell'app e carosello di testimonianze.
8. Anteprima di una fattura d'esempio e conferma, permesso notifiche.
9. **Paywall** (circa al minuto 1:50 del walkthrough): interruttore della prova gratuita di 3 giorni, confronto settimanale/annuale (l'annuale presentato come prezzo settimanale), elenco vantaggi, FAQ a fisarmonica, ripristino acquisti.
10. Invito a creare un account per "proteggere e sincronizzare" i dati: accesso con tre provider o email/password.
11. Tutorial guidato con fumetti sulla prima fattura con dati precompilati.

Fonti: https://screensdesign.com/apps/invoice-maker-invoice-fly/, https://screensdesign.com/showcase/invoice-maker-invoice-fly, https://adapty.io/paywall-library/invoice-fly-receipt-maker/

## Navigazione

Schermata Fatture con ingranaggio e ricerca in alto; tab bar in basso con almeno Strumenti e Report (screenshot 2), più Clienti, Spese, Registro ore raggiungibili da Strumenti.

Fonti: screenshot 1, 2, 4; https://screensdesign.com/apps/invoice-maker-invoice-fly/

## Schermate

### Fatture (home)
In alto ingranaggio e lente. Sotto, schede mensili scorrevoli in orizzontale: mese, totale (in migliaia di euro) e variazione percentuale sul mese prima in verde/rosso; la scheda selezionata è contornata. Grande pulsante "Crea fattura". Intestazione del mese con filtro (Tutte). Righe: icona documento, cliente, numero, importo e stato in parola colorata (Pagata verde, In scadenza oggi arancio, Scaduta rosso). In fondo riga "Totale saldo dovuto" con il conteggio. (screenshot 1, 4)

### Anteprima documento
Numero come titolo, "Personalizza" in alto a destra, pagina PDF, timbro "PAGATO" sovrapposto quando saldata, pillola di stato (Inviata) e menu "Altro" (invia, esporta, stampa, firma, duplica, elimina). (screenshot 2)

### Editor bozza
Pulsante Fine in alto. Sezioni: dettagli (numero, data, scadenza: nessuna, 30 giorni, personalizzata), cliente, articoli, riepilogo (subtotale, IVA, totale, pagato, saldo dovuto), impostazioni di pagamento. Modulo articolo: nome, prezzo, quantità, unità, imposta, tipo di sconto (nessuno, percentuale, fisso), interruttore "salva nel catalogo".

### Personalizza
Anteprima dal vivo e miniature numerate dei modelli in basso (screenshot 3). Dimensione del logo, tavolozza colori, interruttori per le voci dell'intestazione, dimensione del testo, testo ad alto contrasto, allegati (immagini o PDF), termini e condizioni, etichette personalizzate, dati aziendali, riquadro firma con cancella e salva.

### Layout del PDF (screenshot 2, 3)
Logo in alto a sinistra, "INVOICE" e contatti a destra; blocco "Fatturare a"; numero, data, scadenza; tabella descrizione (multi-riga) / quantità (es. 3,0 giorni) / prezzo unitario / IVA % / importo; totali subtotale, imposta (IVA), totale, pagato, saldo dovuto; firma con nome.

### Clienti
Riepilogo di fatturato per cliente, ordinamento, filtro per tag, stato vuoto, modulo (nome, email, telefono, indirizzo) o import dalla rubrica con permesso Contatti.

### Spese
Scansione della ricevuta con OCR che precompila data, totale e imposta; categorie; cruscotto mensile e esportazione per periodo. (screenshot 6)

### Report
Grafico del saldo, filtri di periodo, totale fatturato, spese, saldo, fatturato per cliente (ciambella), stato dei preventivi, riepilogo tasse e mance.

### Impostazioni
Account (email, password, esci, elimina), abbonamento, dati aziendali, tasse e valuta (paese, aliquota predefinita, valuta con conferma per aggiornare i documenti esistenti), pagamenti (Stripe, PayPal, mance), promemoria e notifiche, team con ruoli e invito via QR, lingua, tema chiaro/scuro/sistema, voce, esportazione e importazione dei dati, tutorial dei widget.

Fonte di tutte le sezioni sopra non citate a screenshot: https://screensdesign.com/apps/invoice-maker-invoice-fly/

## Feature passo per passo

### Creare e inviare una fattura
1. Tocca "Crea fattura".
2. Scegli il cliente dalla rubrica.
3. Aggiungi articoli e prezzi.
4. Salva e invia (email, SMS, foglio di condivisione, stampa).

Fonti: listing (`meta.json`), https://invoicefly.com/product/invoice-app/

### Preventivo → fattura
"Genera fatture dai preventivi con un gesto": un'azione sul preventivo crea la fattura.

Fonte: listing.

### Registrare un pagamento
Cruscotto pagamenti, scelta del metodo (contanti, assegno, carta), modulo di registrazione; lo stato diventa Pagata e sul PDF compare il timbro.

Fonti: screenshot 2, https://screensdesign.com/apps/invoice-maker-invoice-fly/

### Stati
Inviata, Vista (notifica quando il cliente apre), Promemoria inviato, Scaduta, Pagata. "In scadenza oggi" appare nell'elenco.

Fonte: https://invoicefly.com/product/invoice-app/, screenshot 4.

### Funzioni che richiedono server o cloud
Notifiche "fattura pagata" e "preventivo accettato" (screenshot 7), notifica di apertura, pagamenti online (carta, ACH, PayPal, Apple Pay, Google Pay), promemoria automatici al cliente, fatture ricorrenti, sincronizzazione, team, generatore di preventivi AI da foto o testo, fattura a voce, assistente chat che genera anche loghi.

Fonti: https://invoicefly.com/product/invoice-app/, https://screensdesign.com/apps/invoice-maker-invoice-fly/

### Registro ore
Voci di tempo con rotella della durata, cliente e note; filtro fatturate/non fatturate; fattura generata dalle ore.

## Gesti

Scorrimento orizzontale delle schede mensili; tocco su una scheda per filtrare il mese. Nessun altro gesto documentato.

## Widget e Shortcuts

Widget per Home e schermata di blocco con tutorial di configurazione nelle Impostazioni. Nessuna menzione di Shortcuts.

Fonte: https://screensdesign.com/apps/invoice-maker-invoice-fly/

## Prezzi dei piani

| Piano | Prezzo (USD) |
|---|---|
| Settimanale | 8,99 (varianti 5,99 e 9,99) |
| Mensile | 8,99-12,99 in alcune varianti |
| Annuale | 98,99 |

Prova gratuita di 3 giorni che passa al settimanale. Entrambi i piani includono gli stessi vantaggi (fatture illimitate, modelli, pagamenti, spese e report, notifiche).

Fonti: https://invoicefly.com/product/invoice-app/, https://adapty.io/paywall-library/invoice-fly-receipt-maker/, https://www.softwareadvice.com/product/510852-Invoice-Fly/
