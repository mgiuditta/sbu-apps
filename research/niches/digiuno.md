# Nicchia: Digiuno (timer per il digiuno intermittente)

Ricerca del 15/10/2026, solo dati pubblici: lookup API iTunes (IT/US), pagine web App Store (sezione acquisti in-app), RSS recensioni IT/US. Riga 74 della classifica top-grossing IT (`research/it-top-grossing-2026-10-15.md`), esito KEEP.

## 1. Leader IT e USA

| | BodyFast (leader IT) | Zero (leader US) |
|---|---|---|
| id | **1189568780** (stesso id IT e US) | **1168348542** |
| Nome sullo Store | IT "BodyFast Digiuno Intermittente", US "BodyFast: Intermittent Fasting" | "Zero: Fasting & Food Tracker" |
| Sviluppatore | BodyFast GmbH | Zero Longevity Science |
| Versione | 4.5.0 | 7.15.0 |
| Prezzo app | gratis | gratis |
| Valutazioni IT | 4,50 su 22.814 | 4,70 su 1.690 |
| Valutazioni US | 4,70 su 146.135 | 4,82 su 445.295 |

Ricerca US "intermittent fasting" (prime posizioni): Intermittent Fasting Tracker (6448909309, 51.782), **Zero** (445.295, il più votato), Intermittent Fasting Tracker (1498018285, 29.099), BodyFast, Fastic (1459260306, 246.098), FastEasy (1553036888, 78.862). L'equivalente US di riferimento è Zero.

**Abbonamenti BodyFast "Coach"** (pagina App Store, più livelli di prezzo per gli A/B test):
- IT: 1 mese 7,49 / 10,49 / 11,99 / 14,99 €; 3 mesi 14,99 / 20,99 / 23,99 / 29,99 €; 12 mesi 29,99 / 59,99 €. Il più venduto in cima: "Pieno accesso per 3 mesi" 29,99 €. Prova settimanale da circa 6 € citata nelle recensioni.
- US: 1 mese $11.99 / $13.49 / $16.99; 3 mesi $17.49 / $24.49 / $27.99 / $34.99; 6 mesi $54.99; 12 mesi $34.99 / $69.99.
- Una recensione IT parla di "32 euro al mese" dopo la prova (rinnovo trimestrale letto come mensile, o prezzo alto dell'A/B test).

**Zero Plus** (US): $9.99 al mese, $69.99 / $89.99 all'anno, prova di 7 giorni.

## 2. Cosa sta dietro il paywall

**BodyFast**

| Gratis | Coach (abbonamento) |
|---|---|
| Più di 10 piani (16:8, 5:2, ecc.) | Piano settimanale "personalizzato" dal Coach |
| Timer del digiuno con promemoria | Tutti i piani sbloccati, piani preferiti, piano personale creato da te |
| Peso e misure corporee | Coaching quotidiano (frasi, consigli, compiti) |
| Fasi del digiuno (cosa succede nel corpo) | 100+ ricette, "food facts" |
| Tracker dell'acqua | Sfide settimanali, trofei |
| Articoli sul digiuno | "Joker Day" (giorno di pausa), SOS dal team di esperti |

**Zero**

| Gratis | Zero Plus |
|---|---|
| Timer, streak, trend settimanali | Digiuni personalizzati e preset salvati |
| Articoli degli esperti, sfide | Pasti da foto con AI (macro, "Protein Score") |
| | Acqua, umore, abitudini, "Fat-Burning Mode" |
| | Grafici mensili/annuali, articoli premium |
| | Storico passato (dalle recensioni US: senza Plus non vedi i digiuni vecchi) |

Nelle recensioni recenti di Zero il gratis è di fatto sparito: dopo account e questionario c'è un paywall senza X.

## 3. UX

### Flusso principale (dai testi dello Store e dalle recensioni)

1. **Onboarding**: questionario lungo (obiettivo, sesso, età, altezza, peso, peso obiettivo, abitudini), poi "piano calcolato" e paywall con prova di 7 giorni. Zero chiede l'account prima; BodyFast ha account web (`my.bodyfast.app`) e acquisti anche fuori dall'app.
2. **Schermata principale**: anello/cerchio del timer con tempo trascorso o rimanente, fase del digiuno corrente (zuccheri, chetosi, autofagia), orario di inizio e fine finestra, pulsante "Inizia/Termina digiuno". BodyFast mostra la settimana del piano con i giorni di digiuno.
3. **Azione chiave**: un tocco per iniziare il digiuno, possibilità di correggere l'orario di inizio; alla fine "Termina", con riepilogo (ore, obiettivo raggiunto sì/no), poi umore/pasto (Zero).
4. **Storico/progressi**: calendario o barre dei digiuni, streak, curva del peso, misure.
5. **Impostazioni**: piano (16:8, 18:6, 20:4, OMAD, 5:2, personalizzato), promemoria inizio/fine, unità, Apple Salute (Zero), esporta dati (Zero).

### Cosa amano

- Semplicità del cronometro: "facile, intuitiva e super motivante", "1 tap, con la possibilità di cambiare l'ora di inizio" (Zero, 5★).
- Le fasi del digiuno spiegate, gli articoli per principianti.
- Notifiche puntuali, possibilità di sospendere senza perdere tutto.
- Esportare i dati (Zero, IT 5★).
- Richieste aperte: widget con timer in tempo reale (BodyFast, 5★), acqua sincronizzata con Salute (BodyFast, 5★).

### Cosa odiano (lette 200 recensioni BodyFast e 156 Zero, IT+US; BodyFast 98 da 1★ su 200, Zero 68)

BodyFast:
- "L app è fondamentalmente un timer: Difficile annullare abbonamento" (1★): "trovo che il prezzo non valga il servizio, fondamentalmente un timer che tiene conto delle ore di digiuno".
- "Dopo una prova settimanale da 6€, hanno rinnovato tacitamente senza preavviso estorcendomi 32€." (1★, "Truffa")
- "Promettono il coaching ma il coach è una IA che dopo 1 settimana da' il digiuno 16-8 tutti i giorni come base." (2★)
- "Se voglio cambiare le ore di pasto posticipando lo slot non me lo permette" (1★, "Il piano non è modificabile"); in US "couldnt even change the fasting times" (1★).
- "posso fare la stessa cosa con la sveglia dell'iPhone a gratis, inoltre costa tantissimo" (1★, "Inutile").
- "Non riesco a capire come funziona. Non capisco neanche se sono abbonato." (1★)
- Decine di 1★ su rinnovo automatico, addebiti dopo la disdetta, account web separato.

Zero:
- "70 bucks a year for a timer." (1★)
- "Paywall after creating the account" / "No free plan ... there is not cross button" (1★, più recensioni).
- "it doesn't even let you see your past fast if you don't pay now ... 1300+ streak" (1★, US).
- "Is there a method to automatically start fasting after 8 hours?" (2★): manca l'avvio automatico.
- "Limited to 168 hours" (3★) e "longer than 7 days this app will not allow you to plan" (1★): digiuni lunghi bloccati.
- "A me utente europeo mi fa inserire libbre e ft ... non trovo un modo per editare l'altezza in metri" (2★).
- "New timer design is so confusing" / "Troppo complessa" (1★): l'utente vuole il timer semplice di prima.
- "app ask always to log-in ... connection is compulsory" (2★): non funziona offline.

Sintesi per Sbu: chi paga vuole solo **un timer affidabile con storico**; tutto il resto (coach, ricette, AI) è percepito come pretesto per l'abbonamento.

## 4. Fattibilità iOS senza server

| Funzione | Framework Apple | Note |
|---|---|---|
| Timer del digiuno (anello, tempo trascorso/rimanente) | SwiftUI `TimelineView`, `Text(timerInterval:)`, `Date` | Nessun timer in background: si salvano inizio e obiettivo, il tempo si calcola |
| Piani 12:12, 14:10, 16:8, 18:6, 20:4, OMAD, 36 h, 5:2, personalizzato, digiuni oltre 7 giorni | modello puro + SwiftData | Nessun limite a 168 h |
| Correggere inizio/fine di un digiuno | SwiftUI `DatePicker` | |
| Avvio automatico del digiuno a orario fisso | calcolo dal piano + `UserNotifications` | Il digiuno "parte" per calcolo, non serve codice in background |
| Promemoria inizio/fine, fasi raggiunte | `UserNotifications` (notifiche locali a orario) | |
| Live Activity / Dynamic Island con il conto alla rovescia | ActivityKit + estensione widget | Richiesto dagli utenti; target widget extension |
| Widget Home/Lock Screen | WidgetKit (stessa estensione) | `Text(timerInterval:)` si aggiorna da solo |
| Controllo in Centro di Controllo / Shortcuts "Inizia digiuno" | App Intents (`ControlWidget` è iOS 18, opzionale) | |
| Storico, streak, calendario, grafico ore | SwiftData + Swift Charts | |
| Peso e misure | SwiftData; lettura/scrittura peso con HealthKit (`bodyMass`) opzionale | Entitlement HealthKit, permesso solo quando lo attivi |
| Acqua | HealthKit `dietaryWater` | Facoltativo; rischio 4.3 con Habits (vedi sotto) |
| Fasi del digiuno (spiegazione testuale) | testi propri nel catalogo stringhe | Scrivere testi nostri, prudenti, senza promesse mediche |
| Esporta CSV | `ShareLink` + `FileDocument` / `Transferable` | |
| Sync | CloudKit privato, spento di default (ADR-0008) | |
| Apple Watch (avvio/stop dal polso) | watchOS + WatchConnectivity | Possibile in 1.1, non per la 1.0 |

**Non copiabili e alternativa on-device**
- Coach "personalizzato" settimanale: è una regola, non un servizio. Alternativa: piano progressivo locale (es. 12→14→16 h in 3 settimane) calcolato da un modello puro, senza promesse di dimagrimento.
- 100+ ricette e "food facts": contenuti con licenza. Saltare (fuori dalla cosa sola).
- Foto del pasto con AI e Protein Score (Zero): AI cloud. Saltare; nessun Foundation Models (iOS 26, e target iOS 17).
- Articoli degli esperti (Peter Attia ecc.) e SOS del team: contenuti e persone. Alternativa: 5-6 schede brevi scritte da noi sulle fasi, con avviso "non è un consiglio medico".
- Community, Facebook group, account: saltati per regola.

Nessuna estensione obbligatoria per la 1.0; consigliata la widget extension (widget + Live Activity), che è anche il motivo per scegliere Sbu.

## 5. Rischi App Review

- **4.3 tra le Sbu**: il rischio principale. Habits (streak, HealthKit, abitudini giornaliere), Cycle (calendario di salute con previsioni), Steps (salute) e Noise (timer/sveglia) sono vicini. Un timer di digiuno con streak e acqua può sembrare un "Habits con un timer". Mitigazione: niente acqua, niente abitudini, niente streak in primo piano; la figura è il conto delle ore del digiuno in corso, lo storico in ore. Nelle note di revisione: "Sbu Digiuno misura un solo digiuno alla volta, dalla prima all'ultima ora; Habits segna abitudini sì/no, non ha timer". Dopo i rifiuti 4.3/4.2.6 del 14/10, inviarla non vicino a Habits o Cycle.
- **4.3 nella nicchia**: la categoria è satura di timer di digiuno quasi identici; Apple la considera un mercato affollato (4.3(b)). Serve un elemento proprio: digiuni lunghi senza limite, avvio automatico dal piano, Live Activity, nessun account, funziona offline. Sono anche le richieste delle recensioni.
- **4.2 funzionalità minima**: "solo un timer" è proprio la critica delle recensioni; con piani, storico, grafici, correzione orari, widget e Live Activity la soglia è superata.
- **5.1.1 / 5.1.3 salute**: con HealthKit servono privacy policy, stringhe di permesso chiare, nessun dato fuori dal dispositivo; i dati di Salute non vanno in iCloud se non con la sync esplicita. HealthKit facoltativo e chiesto solo quando serve.
- **1.4.1 / sicurezza fisica**: il digiuno ha rischi (diabete, gravidanza, disturbi alimentari). Apple può chiedere avvertenze: aggiungere "non è un dispositivo medico, chiedi al tuo medico" nel primo avvio e nelle schede fasi, niente promesse ("perdi peso", "previeni il diabete": BodyFast lo scrive, noi no). Sotto i 18 anni: età 12+ o 17+ da valutare; nessun obiettivo di peso aggressivo.
- **5.2.5 / marchi**: niente "BodyFast", "Zero", "Fastic" nei metadati; "Intermittent Fasting" e "16:8" sono termini generici. Nome proposto: Sbu Digiuno / Sbu Fast.
- **2.5.x**: Live Activity entro i limiti (8 ore attive, poi termina: per digiuni oltre 8 h serve aggiornamento locale o ripresa all'apertura, vedi limiti ActivityKit); notifiche solo locali; nessuna API privata. Widget extension e App Intents dichiarati correttamente.
- **3.1.x**: non applicabile, nessun acquisto.

**La cosa sola**: *sapere da quante ore stai digiunando e quando finisce.* Figura unica: ore e minuti del digiuno in corso (`statHero`), chiusa dal punto fermo. Tutto il resto (piano, storico, peso) è secondario.

## 6. Stima

- **Giorni-agente per una 1.0 pari al leader (parte gratis di BodyFast + Plus di Zero senza AI/ricette)**: 6-8 giorni. Modello e piani 1, timer e schermata principale 1, storico/grafici 1, notifiche e avvio automatico 1, widget + Live Activity 1-2, HealthKit peso 0,5, stringhe IT/EN, test, accessibilità, screenshot 1-1,5.
- **Complessità**: M (il nucleo è S, la estensione widget/Live Activity e HealthKit la portano a M).
- **"Abbonamento stupido da pagare": 5/5.** Fino a 59,99 € l'anno (Zero $89.99) per un cronometro con storico; le recensioni lo dicono testualmente ("70 bucks a year for a timer").
- **Fattibilità: 5/5.** Tutto on-device con framework Apple; le parti a pagamento non copiabili (ricette, AI foto, coach umano) sono proprio quelle che gli utenti non vogliono.
- Rischio principale: 4.3 per somiglianza con Habits/Cycle e nicchia satura; da gestire con la cosa sola stretta (ore del digiuno in corso) e invio lontano dalle app salute.
