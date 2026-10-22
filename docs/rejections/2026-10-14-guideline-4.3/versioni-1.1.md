# Le 1.1 delle sei app respinte il 14/10

Preparate il 22/10, una per branch, nessuna su ASC: `app/habits-1.1`, `app/clean-1.1`, `app/noise-1.1`, `app/moon-1.1`, `app/level-1.1`, `app/speed-1.1`. Si fondono e si inviano una alla volta, dopo l'esito dell'appello di Habits (`risposta-apple-2026-10-22.md`, punto 5).

## Cosa cambia in tutte

- Versione 1.1 (Habits build 6; per le altre il numero lo dà `fastlane beta`).
- Icona v5 e icona alternativa Inversa (commit 64ff3680 del 17/10): le build del 14/10 avevano le vecchie.
- Design kit v5 Quaderno nel codice (ADR-0013): nessuna API deprecata nelle app, verificato con la build.
- Cinque slide per lo Store invece di due o tre, ognuna con la sua incisione e un segno d'inchiostro su un valore vero. I soggetti delle incisioni non si ripetono tra le app.
- La slide della promessa dice cosa resta sull'iPhone in quell'app, non la riga uguale per tutte.
- Note per la revisione: "How it differs from the other Sbu apps" e "Since 1.0".

## Quanto è cambiato il binario dal 14/10

Codice dell'app, senza SbuKit (che a sua volta è cresciuto di circa 5.400 righe con il v5):

| App | Commit | Righe dell'app | Cosa |
|---|---|---|---|
| Level | 15 | +2.352 / −394 | unità, Azzera qui, Mirino con la fotocamera, blocco, voce, suono, tasto volume, quadrante, Come si usa |
| Speed | 10 | +1.994 / −365 | limiti in un tocco, altitudine e rotta, registro viaggi con CSV, Parabrezza |
| Habits | 5 | +1.130 / −1.292 | passaggio al v5, immagine della cifra da condividere |
| Clean | 5 | +702 / −580 | passaggio al v5 |
| Moon | 4 | +330 / −127 | passaggio al v5, una correzione per il compilatore attuale |
| Noise | 6 | +199 / −219 | passaggio al v5 |

## Verdetto (originality-check)

| App | Funzione | Contenuto | Metadati | Verdetto |
|---|---|---|---|---|
| Level | unica nel catalogo (sensori, fotocamera) | 1.1 con funzioni nuove vere | slide nuove, testo riscritto | distinta |
| Speed | unica (GPS) | 1.1 con funzioni nuove vere | slide nuove, testo riscritto | distinta |
| Habits | unica (Salute, Watch, Live Activity) | 14.600 righe sue | slide nuove | distinta, la strada è l'appello |
| Clean | unica nel catalogo, nicchia affollatissima sullo Store | binario cambiato solo nell'aspetto | slide nuove | al limite |
| Noise | unica nel catalogo, nicchia affollata | binario cambiato solo nell'aspetto | slide nuove | al limite |
| Moon | unica nel catalogo, nicchia affollata, app piccola | binario cambiato solo nell'aspetto | slide nuove | al limite |

Il rischio che resta per tutte e sei è quello che Apple ha nominato il 22/10: "overall design and user experience". Le sei hanno lo stesso shell, le stesse Impostazioni (con le stesse pillole delle promesse), lo stesso cartiglio, la stessa grammatica. È voluto (è sbu.dev), ma per il revisore è il segnale di template.

## Ordine consigliato

1. Habits: solo se il Board accoglie l'appello.
2. Level, poi Speed, mai nella stessa settimana: sono le uniche con un binario davvero diverso dal 14/10.
3. Clean, Noise, Moon: ferme finché non decidi il modello (tante app piccole o meno app più grandi, `docs/rejections/2026-10-20-find-4.3/README.md`). Reinviarle con solo icona e slide nuove è il caso che la risposta del 22/10 sconsiglia.

## Trovati durante il lavoro, da decidere

- **Test di Habits e Moon non compilavano su `main`** con il compilatore attuale: corretti nei branch 1.1 (argomenti del test del timer; `MoonLitShape` `nonisolated`).
- **Speed, audit del Parabrezza**: falliva anche su `main`, perché legge come tagliata l'unità specchiata. Escluso il controllo del ritaglio solo lì, con il motivo nel test.
- **Habits, audit del foglio Aggiungi**: un nodo senza nome "Dynamic Type partially unsupported" che l'audit di iOS non attribuisce a nessun elemento. Il foglio non è stato toccato; da guardare a mano ai testi grandi.
- **Schermate strumento che scorrono** (Moon, e probabilmente le altre su SbuKit): il contenuto passa sotto l'ora senza una fascia di carta, e la cifra si vede tagliata sotto la barra di stato. Correzione nello shell, non in una app sola.
- **Orologio da comodino di Noise**: è scuro, e CLAUDE.md ammette superfici scure solo per la Closure e il Parabrezza. Serve un'ADR (come l'ADR-0011) o un orologio chiaro.
- **Mirino di Level**: lo screenshot si fa solo da un iPhone vero, nel test insieme.
- **Clessidra**: è l'icona di Habits e anche l'incisione della slide "prova gratuita" di Subscriptions (già pubblicata).
