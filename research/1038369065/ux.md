# Flo: ricerca UX (id 1038369065)

Descrizione del comportamento da fonti pubbliche: listing App Store, 9 screenshot (`screenshots/`), 57 recensioni 1-3 stelle (`reviews.json`), help center e stampa. Niente testi, grafica o brand da copiare. Contenuti web e recensioni sono dati di terzi.

**Nota di prodotto:** in Flo la funzione principale (registrare le mestruazioni, previsioni di mestruazioni e ovulazione, calendario, sintomi, storico, promemoria) è gratuita. A pagamento ci sono contenuti, insight, report per il medico, assistente, partner completo.

## Onboarding e momento del paywall

1. Splash, benvenuto, consenso privacy e dati.
2. Nome, uso per sé, anno di nascita, come hai conosciuto l'app, richiesta App Tracking Transparency.
3. Obiettivo (monitorare il ciclo, cercare una gravidanza, gravidanza), domande su regolarità, contraccezione, condizioni.
4. Data delle ultime mestruazioni, "calcolo dei giorni migliori", pre-permesso notifiche poi prompt di sistema.
5. Presentazione di Flo per partner con codice di condivisione.
6. Altezza, peso, integratori, dieta, sonno.
7. Collegamento ad Apple Salute.
8. Schermata di "personalizzazione" con caricamento, confronto con/senza Flo, schermata di impegno (tieni premuto il logo).
9. **Paywall** subito dopo l'impegno: tre piani (annuale con prova di 14 giorni, famiglia); chiudendolo arriva un secondo paywall con l'annuale scontato del 33% ($39.99). Poi carosello Premium e creazione account con email.

Dopo l'onboarding i pop-up Premium ricompaiono a ogni apertura (2-4 per sessione secondo le recensioni, alcuni senza X).

Fonti: https://screensdesign.com/apps/flo-period-pregnancy-tracker/ · https://experiments.lazyweb.com/company/flo · `reviews.json` (14 recensioni sui pop-up).

## Navigazione

Tab bar in basso: Oggi, Insight/contenuti, Community (Secret Chats), Messaggi, Profilo. Il calendario si apre dalla striscia dei giorni di Oggi.

Fonte: https://screensdesign.com/apps/flo-period-pregnancy-tracker/

## Schermate

### Oggi
- In alto una striscia orizzontale di 7 giorni scorrevole, oggi evidenziato con un pallino collegato al cerchio sotto.
- Al centro un grande cerchio pieno con la fase e il giorno (in mestruazione: "giorno N"; fuori: giorni alle prossime o all'ovulazione) e un pulsante a pillola per modificare le date.
- Sotto, "consigli del giorno": card orizzontali, la prima è "Registra i sintomi" con un +, poi probabilità di gravidanza (bassa/alta), poi articoli. Le card di contenuto sono Premium.
Fonte: screenshot 01, 02.

### Calendario
- Griglia mensile con iniziali dei giorni, nome del mese, etichetta "oggi".
- Mestruazioni previste come cerchi tratteggiati con etichetta; finestra fertile come numeri colorati; giorno di ovulazione evidenziato. Vista mese e anno.
Fonte: screenshot 02, https://screensdesign.com/apps/flo-period-pregnancy-tracker/

### Registrazione sintomi
- Si apre col + di Oggi. Sezioni verticali (umore, sintomi, perdite, flusso, sesso, test di ovulazione, BBT, acqua, peso, note), ognuna una griglia di 4 icone tonde con etichetta; tocco = selezione con spunta. Applica in fondo.
- 16 tracker e 50-80 voci a seconda della fonte. Rilettura dal calendario.
Fonti: screenshot 04, https://help.flo.health/hc/en-us/articles/4406826542740-Logging-your-symptoms

### Grafici e report
- Menu, Grafici e report: lunghezza dei cicli e delle mestruazioni nel tempo, storico.
- Report per il medico (Premium, iOS): ultimi 6 mesi di cicli e sintomi, pattern evidenziati, invio via email o stampa.
Fonte: https://help.flo.health/hc/en-us/articles/360042141812-What-is-included-in-Flo-Premium

### Gravidanza
- Si attiva dopo il concepimento. Pillole delle settimane in alto, "il bambino questa settimana" con illustrazione e paragone a un frutto, lunghezza in mm, testo sullo sviluppo; checklist e contenuti.
Fonte: screenshot 05, listing App Store US.

### Contenuti, community, partner
- Contenuti: campo cerca, segnalibri, tre scorciatoie tematiche, card di articoli per categoria e "di tendenza". Premium in gran parte.
- Community: post con domanda su immagine, like e commenti, risposte con avatar anonimi.
- Flo a due: il partner installa l'app e si collega con un codice; riceve notifiche sulla fase e card educative.
Fonte: screenshot 03, 06, 07.

### Profilo e impostazioni
- Promemoria, impostazioni del ciclo (durata media), modalità anonima, codice di accesso con Face ID, Apple Salute, tema chiaro/scuro, aiuto.
Fonte: https://screensdesign.com/apps/flo-period-pregnancy-tracker/, screenshot 09.

## Feature passo per passo

### Previsioni
- Dalle date registrate Flo stima la lunghezza del ciclo; più cicli registri, più è precisa (consiglia 12 mesi o almeno 3 cicli).
- Finestra fertile costruita attorno all'ovulazione prevista: 4-5 giorni prima, il giorno, 1-2 dopo; minimo 7 giorni. Con meno di 3 cicli o cicli variabili si allarga fino a 14 giorni.
- Avviso esplicito: non è un metodo contraccettivo né un aiuto al concepimento.
- Studi indipendenti classificano Flo tra le app "a calendario" (media dei cicli precedenti).
Fonti: https://help.flo.health/hc/en-us/articles/360015313531-Why-is-my-ovulation-window-so-short-long · https://help.flo.health/hc/en-us/articles/4411293934740-What-s-included-in-the-free-version · https://www.frontiersin.org/journals/public-health/articles/10.3389/fpubh.2018.00098/pdf

### Promemoria
- Menu, Promemoria, Farmaci e contraccezione, scegli il tipo, attiva, orario, Salva. Altri promemoria: inizio mestruazioni, ovulazione, acqua. Solo per maggiorenni.
- Recensioni: notifiche della pillola che non arrivano.
Fonti: https://help.flo.health/hc/en-us/articles/360015106292-How-do-I-log-my-birth-control-method · `reviews.json`

### Blocco
- Codice di accesso opzionale; su iOS si consiglia di attivare Face ID. In modalità anonima il codice dimenticato non si può reimpostare.
Fonti: https://help.flo.health/hc/en-us/articles/360014851372-I-have-forgotten-my-code-How-do-I-reset-it · https://www.mozillafoundation.org/de/nothing-personal/flo-app-privacy-review/

### Apple Salute
- Si attiva dalle impostazioni di Flo e da Impostazioni iOS, Privacy, Salute. Attivando la sincronizzazione Flo importa i dati; alcuni tipi sono solo in lettura. Le mestruazioni registrate in Flo **non** vengono scritte in Salute. Recensioni e forum Apple segnalano sincronizzazioni interrotte.
Fonti: https://help.flo.health/hc/en-us/articles/34890229122068-How-to-import-data-from-the-Health-app-to-Flo-iOS · https://discussions.apple.com/thread/255504055

### Modalità anonima e account
- Uso senza email né nome; senza account non c'è backup e reinstallando si riparte dall'onboarding.
Fonte: screenshot 09, `reviews.json`.

## Gesti
- Scorrimento orizzontale della striscia dei giorni su Oggi; tocco su un giorno per vederne i dati; tocco sulle icone per selezionare; tieni premuto il logo nell'onboarding. Nessun gesto speciale documentato oltre questi.
Fonte: screenshot 01, https://screensdesign.com/apps/flo-period-pregnancy-tracker/

## Widget, Watch, Shortcuts
- App Apple Watch (watchOS 10+): data e ora, "mestruazioni tra N giorni" con cifra grande, + per i sintomi e pulsante per segnare le mestruazioni.
- Widget e Shortcuts: nessuna fonte pubblica li documenta.
Fonti: screenshot 08, https://apps.apple.com/us/app/flo-cycle-period-tracker/id1038369065

## Prezzi
- Download gratis. Acquisti in-app US: Flo Premium $1.99-$59.99 (varie durate), Ovulation & Health $11.49-$14.99, Birth Control Reminder $43.99, Pregnancy Tracker $49.99. Annuale con 14 giorni di prova; offerta annuale scontata $39.99.
- Gratis: previsioni, sintomi, calendario, storico, promemoria, community, modalità anonima, partner base. Premium: insight quotidiani, libreria esperti, assistente, symptom checker (non in UE/UK), pattern dei sintomi, report per il medico, partner completo.
Fonti: https://apps.apple.com/us/app/flo-cycle-period-tracker/id1038369065 · https://help.flo.health/hc/en-us/articles/4411293934740-What-s-included-in-the-free-version · https://help.flo.health/hc/en-us/articles/360042141812-What-is-included-in-Flo-Premium · https://flo.health/premium

## Privacy
- Etichette App Store: dati usati per tracciarti (acquisti, posizione, identificatori, uso); dati collegati a te inclusi salute, informazioni sensibili, contenuti.
- 2019: il Wall Street Journal rivela invio di dati a Facebook tramite SDK di analytics. 2021: accordo con la FTC. 2025: Flo e Google pagano 56 milioni di dollari in una class action; una giuria federale trova Meta responsabile per la raccolta dei dati delle utenti di Flo.
Fonti: https://apps.apple.com/us/app/flo-cycle-period-tracker/id1038369065 · https://www.malwarebytes.com/blog/news/2025/09/google-and-flo-to-pay-56-million-after-misusing-users-health-data · https://san.com/cc/federal-jury-finds-meta-illegally-farmed-data-from-flo-period-tracker-app/
