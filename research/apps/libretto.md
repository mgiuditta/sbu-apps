# Sbu Libretto: sintesi su MyLibretto

Originale: MyLibretto - Università (id 914172791, store IT, Lorenzo Greco, v4.0.6 del 30/08/2026, iOS 15+). Dati in `research/914172791/` (`meta.json`, `screenshots/` 7 immagini, `reviews.json` con 8 recensioni da 1 a 3 stelle). Concorrenti: Folium (6755937684), Uniwhere (872690072), UniLibretto (1492076392), Klim (6786771075), UniMedia Free (654455476), stessi file nelle loro cartelle.

`spec.json` non c'è: `Tools/spec.py` richiede `ANTHROPIC_API_KEY`, non impostata in questa sessione. Il feed XML delle recensioni era vuoto: le recensioni vengono dal feed JSON pubblico (`mostrecent` + `mosthelpful`, store IT), stesso formato di `reviews.json`. L'analisi qui sotto è fatta a mano su listing, screenshot e recensioni. Nessuna app decompilata o estratta.

## Valutazioni (itunes lookup, 16/10/2026)

| App | IT | US | Modello |
|---|---|---|---|
| MyLibretto | 4,63 su 6.856 | non in vendita | Gratis con pubblicità; PRO una tantum 3,49 € (backup, temi, più piani di studio); tracking dichiarato (identificatori, dati d'uso) |
| Uniwhere | 4,26 su 9.612 | non in vendita | Login al portale dell'ateneo, server, annunci aggiunti, recensioni esami diventate PRO |
| Folium | 4,49 su 259 | 5,0 su 1 | Abbonamento 1,99 €/mese, 9,99 €/anno, 19,99 € a vita; tracking; community e aule studio online; import con IA |
| UniLibretto | 4,37 su 160 | 0 | Pubblicità a ogni voto inserito, abbonamento premium, IA; ateneo obbligatorio |
| Klim | 4,55 su 22 | 0 | Pro 4,99 € una tantum; "nessun dato raccolto"; simulazione voto di laurea e widget solo Pro; iOS 26+ |
| UniMedia Free | 4,67 su 58 | 0 | Fermo al 2017 (iOS 8); esami futuri, iCloud ed export solo nella versione completa |

## Schermate di MyLibretto, in ordine

Tab bar a quattro voci (dagli screenshot):

1. **Dashboard**: saluto e card del corso (ateneo, corso, triennale/magistrale); media ponderata grande con variazione dall'ultimo esame (+0,26); CFU acquisiti su totali con barra; azioni "Registra voto" e "Simula esame"; Statistiche con grafico dell'andamento della media.
2. **Piano di studi**: riepilogo (media, CFU acquisiti/totali, esami e crediti pianificati); filtro Tutti/anno; ordinamento per data, voto, CFU; lista esami raggruppata per anno con CFU, data e voto, oppure "?" se da sostenere; pulsante +.
3. **Simulazione media** (da Dashboard): media attuale e CFU totali; CFU del prossimo esame con stepper; tabella "scenari futuri" da 30L in giù con nuova media e differenza.
4. **Università**: ateneo e corso, link al sito; parametri CFU totali (180), valore lode (31), CFU eliminabili (10); Calendario lezioni (settimana, blocchi orari); Tasse universitarie (storico pagamenti, importo, pagata il).
5. **Domande d'esame**: per insegnamento, domande condivise con docente e voti +/-.
6. **Profilo**: foto, nome, matricola, piani di studi (multipli PRO), tema chiaro/scuro/sistema, colori.

## Funzioni compatibili (gratis in Sbu, tutto sul dispositivo)

| Funzione | Priorità | Note |
|---|---|---|
| Esame: nome, CFU (anche decimali), voto 18-30, lode, data, anno | core | Esame senza voto = da sostenere (appello pianificato). Idoneità: CFU contati, fuori dalla media |
| Media ponderata e aritmetica, CFU acquisiti su totali | core | Ponderata come cifra unica con il punto fermo |
| Base di laurea configurabile | core | Vedi formule sotto |
| Simulatore: tabella voto → nuova media e base, dato i CFU del prossimo esame | core | Anche "voto necessario" per una media obiettivo (Uniwhere, Klim lo fanno) |
| Grafico andamento media (Swift Charts) | core | |
| Piano di studi: filtro dati/da dare e anno, ordinamento data/voto/CFU | core | |
| Prossimi appelli con countdown | core | Dalla data degli esami da sostenere |
| Orario lezioni settimanale | nice | Inserimento manuale |
| Widget media e prossimo appello | nice | Gratis (in Klim è Pro) |
| Tasse universitarie (scadenze, pagata/da pagare) | nice | Locale, nessun legame col portale; fuori dai ticket attuali |
| Più piani di studio (triennale + magistrale) | nice | PRO nell'originale |
| Backup | nice | iCloud spento di default (ADR-0008) o export CSV |

## Funzioni da saltare

- Domande d'esame condivise, community, recensioni esami, aule studio, classifiche: server e account.
- Login al portale dell'ateneo e import automatico di libretto e tasse (Uniwhere): rete e credenziali; è anche la prima fonte di 1 stella di Uniwhere.
- Import con IA da PDF/foto (Folium, Klim): rete. Un import locale da PDF resta aperto nella mappa.
- Elenco atenei obbligatorio: in UniLibretto blocca chi studia all'estero. In Sbu nome dell'ateneo libero e facoltativo.
- Foto profilo, saluto, matricola, temi colorati, pubblicità, PRO, tracking.

## Cosa chiedono le recensioni 1-3 stelle

- MyLibretto (8): sync iPhone/iPad e iPad nativo (2), esami parziali/moduli raggruppati (1), arrotondamenti per convalide (1), inserire esami prima di darli (1), bug orari AM/PM (1), crash (1), import dal portale (1).
- UniLibretto (8): pubblicità a ogni voto (1), voti duplicati (1), ateneo obbligatorio o mancante (3), CFU limitati a 3-12 (2).
- Uniwhere (20): login al portale che fallisce, crash, dati non aggiornati (15), funzioni diventate a pagamento (3).

Da cui: CFU liberi (anche 1-2 e decimali), nessun ateneo obbligatorio, nessuna rete.

## Base di laurea: formule

Comune: media ponderata sui CFU in trentesimi, quasi sempre × 110 / 30. Cambiano fattore di conversione, lode, esclusioni, bonus e arrotondamento, anche tra corsi dello stesso ateneo.

- **UniMi** (Facoltà SPES, versione 25/11/2024): Σ(voto × CFU) / CFU conseguiti × 110/30; **30 e lode conta 33**; +1 Erasmus o tesi all'estero (non cumulabili), +3 laurea in corso nella sessione estiva/autunnale del terzo anno, +1 nella sessione invernale; elaborato triennale da 0 a 6 punti. Fonte: [unimi.it](https://sie.cdl.unimi.it/sites/lb20/files/2025-03/Attribuzione_punteggi_prove_finali_%28v._dic%202024%29_1.pdf).
- **PoliMi** (regolamento d'ateneo): media pesata sui crediti in centodecimi **senza lodi** e senza attività in soprannumero, più il punteggio della commissione; somma arrotondata all'intero (0,50 per eccesso), massimo 110, minimo 66; lode solo da 111 prima dell'arrotondamento. Fonte: [normativa.polimi.it](https://www.normativa.polimi.it/fileadmin/user_upload/regolamenti/studenti/Regolamento_esami_di_laurea_triennale_e_magistrale_-_Revisione.pdf). I corsi aggiungono formule per la prova finale, per esempio Ing. Informatica I = 1 + M/6 ([inginformatica.polimi.it](https://www.inginformatica.polimi.it/wp-content/uploads/2022/11/Regolamento-integrativo-prova-finale-triennale.pdf)).
- **UniBo** (Ing. Elettronica): idoneità escluse, **lode = 30**, × 110/30, poi **× 1,0325 se in corso** (× 1,016 al primo anno fuori corso), fino a 4 punti per la prova finale. Fonte: [corsi.unibo.it](https://corsi.unibo.it/laurea/IngegneriaElettronica/redazione-della-tesi-e-voto-finale).
- **Sapienza** (Ing. Civile triennale): media pesata **× 4**, non × 110/30; **lode = 31**; 110 e lode solo con almeno 115 dagli esami. Fonte: [uniroma1.it](https://corsidilaurea.uniroma1.it/sites/default/files/avvisi/regolamento_voto_finale_laurea_bcvr.pdf).
- Altri: MyLibretto offre valore lode e "CFU eliminabili" (i voti peggiori fuori dalla media); 110eLode offre escludi peggiore/migliore e CFU decimali.

Quindi il modello configurabile: CFU totali; fattore di conversione (110/30 predefinito, 4 per Sapienza Ing. Civile); valore della lode (30, 31, 33 o altro); CFU o esami peggiori esclusi; bonus in punti (somma) e moltiplicatore facoltativo; arrotondamento (nessuno, all'intero, 0,50 per eccesso); tetto 110. Impostazione predefinita: lode 30, nessuna esclusione, nessun bonus, due decimali. Le formule degli atenei restano esempi nell'aiuto, non preset: cambiano per corso e anno.

## Esiste un'alternativa gratis e pulita?

No. Il più vicino è Klim (nessun dato raccolto, nessun abbonamento), ma simulazione del voto di laurea e widget sono nel Pro da 4,99 €, ed è solo iOS 26. Folium si dice senza pubblicità, ma ha abbonamento, tracking e sblocchi con video pubblicitari. MyLibretto ha pubblicità e tracking. Nessun progetto open source su iOS trovato. La mappa prosegue.

Fonti esterne: [tuttoandroid.net su Folium](https://www.tuttoandroid.net/news/2026/01/06/folium-app-libretto-universitario-1133828/), schede App Store IT di MyLibretto, Folium e Klim (acquisti in-app e privacy).
