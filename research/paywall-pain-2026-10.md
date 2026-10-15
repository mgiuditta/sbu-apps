# Paywall e recensioni 1-3★ della coda (ottobre 2026)

Issue #462. Tutta la coda di `docs/factory.md` (già avviate, nuove, wave, candidate da Android): 47 app. Solo dati pubblici dello Store (ADR-0003).

## Metodo

- **Fonti.** iTunes Lookup US e IT, feed RSS pubblico delle recensioni (`itunes.apple.com/<cc>/rss/customerreviews/...`, più recenti, fino a 10 pagine per paese), tenute solo le 1-3★. Raccolta del 15/10/2026.
- **Dati nuovi.** 25 originali che non avevano dati: `meta.json` da `Tools/discover.py --ids <id> --countries us it --no-screenshots`, `listing.json` (lookup US e IT) e `reviews.json` (1-3★ US e IT, campo `country`, formato compatibile con `spec.py`) in `research/<id>/`. Paprika aveva un `reviews.json` vuoto: rifatto.
- **Dati esistenti.** Già avviate: `research/<id>/reviews.json` scaricato da `spec.py` (un solo paese, 3 pagine), quindi campioni piccoli. Wave: `research/<slug>/`, solo l'Originale.
- **Quota paywall.** Recensioni 1-3★ che nominano abbonamento, paywall, prezzo, prova gratuita, addebito, rimborso, premium/plus, "a pagamento" (regex IT/EN, più 订阅/会员). È una stima per parole chiave: conta anche chi dice "ho pagato e non va". Sotto 30 recensioni il numero è indicativo.
- **Modello.** Prezzo dal lookup US; abbonamento o acquisti in-app dalla descrizione dell'app e dalle recensioni. Il lookup non elenca gli IAP.
- **Pains.** Le 3 più frequenti, lette dai titoli e dai testi, escluso il paywall (che ha la sua colonna).

## Tabella

Valutazioni: numero di valutazioni US / IT. n: recensioni 1-3★ lette. Paywall: quota di n.

### Già avviate

| App Sbu | Originale (ID) | Modello | Valutazioni | n | Paywall | 3 pains |
|---|---|---|---|---|---|---|
| Subscriptions | Orbit (6692620188) | gratis + abbonamento | 127 / 99 | 6 | 83% | notifiche che non arrivano, funzioni incomplete, sviluppatore che non risponde |
| Scanner | QR Reader, TapMedia (368494609) | gratis + abbonamento | 1,4 mln / 47 mila | 31 | 23% | "gratis ma poi paghi", non legge o non funziona, poco accessibile ai non vedenti |
| Docs | CamScanner+ (388624839), riferimento | 0,99 $ + abbonamento | 17 mila / 586 | 21 | 38% | file persi, filigrana, instabile e crash |
| Cards | AnkiMobile (373493387) | 24,99 $ una tantum | 2,4 mila / 90 | 20 | 30% | manca l'italiano, interfaccia difficile, iPhone indietro rispetto al desktop |
| Block | Wipr 2 (1662217862) | 4,99 $ una tantum | 1,3 mila / 91 | 10 | 30% | pop-up e annunci che passano, rompe alcuni siti, "non funziona come promesso" |
| Dark | Noir (1581140954) | 2,99 $ una tantum | 1,4 mila / 79 | 112 | 21% | rallenta Safari, siti rotti o illeggibili, licenza Mac da ricomprare |
| Clean | Cleanup (1510944943) | gratis + abbonamento | 737 mila / 34 mila | 69 | 65% | "truffa", gratis solo di nome, non si avvia |
| Authenticator | Authenticator App (6754900760) | gratis + abbonamento | 5,9 mila / 71 | 122 | 47% | addebiti e "scam", codici o account persi, disdetta introvabile |
| Invoice | Invoice Simple (694831622) | gratis + abbonamento | 123 mila / 881 | 27 | 22% | export solo a pagamento, mancano regole fiscali italiane, crash e lentezza |
| Transcribe | Otter (1276437113) | gratis + abbonamento | 85 mila / 247 | 36 | 42% | non trascrive l'italiano, registrazioni perse o tagliate, serve l'account |
| Find | Find Air (1507917112) | gratis + abbonamento | 27 mila / 262 | 74 | 47% | non trova il dispositivo, addebiti settimanali dopo la disdetta, pubblicità |
| Remote | TV Remote (1539090879) | gratis + abbonamento | 623 mila / 971 | 16 | 88% | inutilizzabile senza abbonamento, non si collega alla TV, spam |
| Tuner | GuitarTuna (527588389) | gratis + abbonamento | 148 mila / 7,9 mila | 13 | 31% | pubblicità di Yousician, richiede internet, canzoni sparite |
| Cycle | Flo (1038369065) | gratis + abbonamento | 2 mln / 151 mila | 57 | 60% | tutto premium, pubblicità e pop-up, privacy |
| Steps | Stompers (6477849675) | gratis | 12 mila / 14 | 75 | 24% | passi non sincronizzati, conteggio impreciso, glitch e notifiche |

### Nuove

| App Sbu | Originale (ID) | Modello | Valutazioni | n | Paywall | 3 pains |
|---|---|---|---|---|---|---|
| Meter | GrayZone (6757147623) | 2,99 $ | 5 / 20 | 4 | 0% | misure sbagliate, Zone System incompleto, nessuna lettura di riferimento |
| Decibel | SPL Meter (309206756) | 0,99 $ | 28 / 4 | 30 | 20% | letture incoerenti, non compatibile o rotto dopo gli aggiornamenti, interfaccia sgranata |
| Intervals | Seconds Pro (363978811) | 7,99 $ una tantum | 12 mila / 123 | 168 | 18% | aggiornamento che rompe le cose, sync e Apple Watch, import dei timer |
| Magnet | Magnetometro (944150988) | 0,99 $ | 1 / 1 | 0 | n.d. | nessuna recensione: nicchia senza domanda misurabile |
| Prompter | PromptSmart Pro (894811756) | 29,99 $ + abbonamento | 12 mila / non in vendita | 385 | 51% | crash e blocchi, abbonamento dopo 30 $ pagati, voice scrolling instabile |

### Wave

| App Sbu | Originale (ID) | Modello | Valutazioni | n | Paywall | 3 pains |
|---|---|---|---|---|---|---|
| Chats | The Cringe (6766070732) | gratis + abbonamento | 446 / 105 | 10 | 80% | tutto a pagamento, non funziona, metodo di pagamento |
| Focus | Forest (866450515) | gratis + abbonamento | 50 mila / 8,7 mila | 163 | 23% | nuova interfaccia 2026, pop-up e IA, disdetta difficile |
| Alarm | Alarmy (1163786766) | gratis + abbonamento | 249 mila / 4,4 mila | 76 | 20% | consuma batteria, sveglia che non suona, blocca il telefono |
| Lift | Hevy (1458862350) | gratis + abbonamento | 98 mila / 7,7 mila | 8 | 25% | limite di 4 schede gratis, libreria esercizi scarsa, Watch vecchi esclusi |
| Collage | SCRL (1289057196) | gratis + abbonamento | 125 mila / 6,6 mila | 59 | 53% | export che fallisce, addebito dopo la prova, lento |
| PDF | GoodReader (777310222) | 6,99 $ + abbonamento Pro Pack | 14 mila / 1,2 mila | 97 | 33% | abbonamento dopo l'acquisto, sync cloud rotta, aggiornamento peggiorato |
| Words | Vocabulary (1084540807) | gratis + abbonamento | 220 mila / 989 | 102 | 44% | addebiti senza avviso, definizioni sbagliate, contenuti inappropriati |

### Candidate da Android

| App Sbu | Originale (ID) | Modello | Valutazioni | n | Paywall | 3 pains |
|---|---|---|---|---|---|---|
| Exif | Exif Metadata (1455197364) | gratis + abbonamento o una tantum, pubblicità | 6,1 mila / 226 | 124 | 24% | pubblicità ovunque, crash dopo l'aggiornamento, foto perse o ricompresse |
| Vault | Private Photo Vault (417571834) | gratis + abbonamento | 1 mln / 51 mila | 86 | 48% | "a vita" diventato abbonamento, pubblicità, foto perse al cambio telefono |
| Mood | Daylio (1194023242) | gratis + abbonamento | 62 mila / 3,3 mila | 61 | 48% | voci perse, troppi upsell e richieste di recensione, disdetta difficile |
| Scale | Happy Scale (532430574) | gratis + abbonamento | 58 mila / 161 | 43 | 44% | abbonamento per una cosa semplice, dati persi, una sola pesata al giorno |
| Baby | Baby Tracker (779656557) | gratis + abbonamento | 227 mila / 913 | 185 | 14% | aggiornamento di settembre 2026 con IA forzata, pubblicità anche a chi ha pagato, pulsanti spostati |
| Fuel | Fuelly (295905460) | gratis + abbonamento | 30 mila / 73 | 239 | 50% | da acquisto a abbonamento, dati persi, login e supporto assente |
| Player | Doppler (1468459747) | gratis + sblocco una tantum | 1,6 mila / 38 | 93 | 18% | crash in CarPlay, manca l'equalizzatore, librerie grandi e metadati |
| Comics | Panels (1236567663) | gratis + abbonamento | 13 mila / 1,2 mila | 209 | 28% | fumetti che non si aprono, store e pop-up, sync OPDS/SMB |
| Camera | Halide (885697368) | gratis + abbonamento | 14 mila / 768 | 402 | 59% | da acquisto a abbonamento, lenta e crash, foto perse o sottoesposte |
| Net | Network Analyzer Pro (557405467) | 3,99 $ | 9,2 mila / 401 | 25 | 20% | scansione Wi-Fi e ARP limitate da iOS, funzioni rimosse, crash |
| Sky | Star Walk 2 (1112481571) | gratis + abbonamento | 96 mila / 21 mila | 253 | 25% | pubblicità invadenti, disdetta impossibile, posizione e ora sbagliate |
| Loyalty | Key Ring (372547556) | gratis, offerte e pubblicità | 20 mila / non in vendita | 145 | 7% | tessere sparite, login e account, non si aggiungono foto o codici |
| Fasting | Zero (1168348542) | gratis + abbonamento | 445 mila / 1,7 mila | 430 | 62% | prova gratuita non saltabile, aggiornamento peggiorato, account non cancellabile |
| Expenses | Money Manager (560481810) | gratis + abbonamento, pubblicità | 20 mila / 3,3 mila | 53 | 11% | pubblicità, dati cancellati dall'aggiornamento, niente import da Android |
| Inventory | Sortly (529353551) | gratis + abbonamento | 9,5 mila / 38 | 216 | 68% | aumenti di prezzo, limite di 100 oggetti, dati persi e supporto assente |
| Recipes | Paprika 3 (1303222868) | 4,99 $ una tantum per piattaforma | 54 mila / 152 | 111 | 27% | import ricette rotto, sync e ricette perse, sviluppatore sparito |
| Pixel | Pixel Art Maker (897806469) | gratis + premium, pubblicità | 11 mila / non in vendita | 36 | 3% | pubblicità per adulti in un'app 4+, disegni non salvati, crash |
| GIF | ImgPlay (989843523) | gratis + abbonamento | 45 mila / 6 mila | 123 | 45% | filigrana a pagamento, niente acquisto una tantum, export rotto |
| Ringtone | Ringtones Maker (1358107315) | gratis + IAP, pubblicità | 439 mila / 18 mila | 206 | 3% | pubblicità a ogni tocco, difficile impostare la suoneria, non funziona |
| Plants | Planta (1410126781) | gratis + abbonamento | 114 mila / 2,5 mila | 320 | 55% | consigli di cura sbagliati (IA), addebiti dopo la disdetta, pop-up |

## Cosa dice

- **Paywall forte** (quota ≥ 50% su almeno 50 recensioni): Sortly 68%, Cleanup 65%, Zero 62%, Flo 60%, Halide 59%, Planta 55%, SCRL 53%, PromptSmart 51%, Fuelly 50%. Con campioni piccoli anche TV Remote (88% su 16), The Cringe (80% su 10) e Orbit (83% su 6).
- **Paywall debole**: Ringtones Maker 3% e Pixel Art Maker 3% (il problema è la pubblicità, non il prezzo), Key Ring 7% e Money Manager 11% (dati persi, pubblicità), Baby Tracker 14% (l'aggiornamento con IA), Seconds Pro e Doppler 18% (app a pagamento una tantum, si lamentano dei bug).
- **Il tema che torna**: l'app comprata una volta che diventa abbonamento (Halide, Fuelly, GoodReader, Private Photo Vault, PromptSmart, ImgPlay). Una promessa "gratis, senza abbonamento" risponde proprio a quello.
- **Senza dati utili**: Magnetometro (1 valutazione, 0 recensioni), GrayZone (4 recensioni). Per queste il paywall non è un argomento: costano poco e nessuno ne parla.
