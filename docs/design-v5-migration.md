# Migrazione al design system v5 "Quaderno"

Branch `design/v5-quaderno` (17/10/2026), locale, non pushato: da rivedere prima del merge. Decisioni in ADR-0013 (v5) e ADR-0014 (Un solo tempo); regole in `Design/README.md` e CLAUDE.md.

## Deroghe approvate (ADR-0013)

- Titoli di schermata in Bricolage ExtraBold 34, wdth 87 (prima solo SF).
- Controlli di sistema con stile custom: `SbuToggleStyle`, `SbuCheckboxStyle` (prima intoccati). La rappresentazione per VoiceOver resta il `Toggle` di sistema.
- Punto fermo con tre stati: `absent`, `waiting`, `set` (prima sempre nell'accento).
- Reticolo da 24 pt come texture sulle aree carta (prima fondo uniforme).
- Blocco d'inchiostro per la Chiusura: seconda superficie scura dopo il Parabrezza (ADR-0011).
- IBM Plex Mono solo per cartiglio e metadati, mai per le cifre.
- Tint in `ink`: controlli, bottoni pieni, link. L'accento resta solo sul punto fermo `set` e, schiarito (`accentOnInk`), nella Chiusura. Scelta confermata da Matteo il 17/10.
- Indicatori disegnati che ripetono la cifra rimossi (bolla, ago e scala di Level, tachimetro di Speed, anelli di Find, barra di Clean). Restano il disco di Moon, la griglia sulla foto di Grid e i grafici storici. Confermato da Matteo il 17/10.
- ADR-0012 (tab bar di Subscriptions) resta valido: nessun nuovo ADR per la tab bar.

## Token e strumenti

- `Design/tokens.json` v5: `surface` diventa `paper` (`SbuTheme.surface` resta come alias deprecato); nuovi `grid`, `accent-on-ink-<app>` (OKLCH L 0,70 su inchiostro chiaro; in dark l'accento light sul blocco chiaro), gruppi `grid`, `full-stop`, `control`, `figure`, `motion`, raggi `card` 6, `control` 4, `knob` 2, `checkbox` 3, `closure` 14, `sheet` 20. `ink` dark #f6f6f2, `ink-muted` #6b6b63/#9a9a92, `surface-raised` dark #141412.
- `Tools/sync_tokens.py`: genera `SbuAccent.<app>`, le nuove metriche e le CSS vars; il controllo WCAG aggiunge `paper` su `ink` (7:1) e `accent-on-ink` su `ink` (3:1). Contrasti verificati anche in Swift (`SbuContrast.ratio`, `ContrastTests`, su tutti gli asset in chiaro e scuro).
- Font: Bricolage Grotesque variabile (wght, wdth, opsz) e IBM Plex Mono Medium, OFL, in `Design/fonts`, SbuKit e sul sito (WOFF2). Il Bold statico è rimosso.
- `Tools/make_icons.py --inverse`: icona alternativa Inversa. `Tools/make_sounds.py punto`: `punto.caf` di 40 ms in SbuKit.

## SbuKit

| Componente | Cosa fa |
|---|---|
| `SbuPaper`, `.sbuPaper(grid:)` | Carta e reticolo in `Canvas`; linea sul margine (16) e sul bordo della safe area. Va sul contenuto dello scroll, non sullo scroll. |
| `SbuFigure(value:unit:fullStop:context:accessibilityLabel:)` | Cifra hero 216/192/168/144 per lunghezza, `ViewThatFits` su wdth 100/87/75, poi riduzione; base sul reticolo (snap una volta per comparsa, solo su carta), celle intere sotto per i discendenti; un solo elemento VoiceOver. |
| `SbuFullStop(_:size:)` | `absent`/`waiting`/`set`, `hero` 24/`inline` 16/`mark` 10; arriva dal basso con la molla e il `dot`, batte con `.sbuAffectsFigure`, `.widgetAccentable()`. In DEBUG la shell avvisa se ci sono più `set` (`SbuSetFullStopCount`). |
| `SbuScreenTitle(_:cartiglio:)` | Titolo Bricolage scalato con Dynamic Type, cartiglio Plex Mono maiuscolo. |
| `SbuEmpty(sentence:action:)` | "0" con punto in attesa, frase, bottone nativo; varianti con `Text` e senza bottone. |
| `.sbuClosure(_:word:playsHaptic:)` | Blocco d'inchiostro per 2 s, annuncio VoiceOver, aptica `closure`. |
| `SbuMotion`, `SbuHaptic`, `.sbuHaptic`, `.sbuAffectsFigure`, `\.sbuPlaysHaptics` | Un solo tempo e tre segni aptici; con Riduci movimento nessuna animazione di spostamento. |
| `SbuToggleStyle`, `SbuCheckboxStyle`, `SbuRowMark`, `SbuListCard` | Controlli quadrati in inchiostro, marcatore di riga, card bordata. |
| `SbuWidgetFigure`, `SbuLiveFigure` | Unico layout di widget e Live Activity, inline `■` sulla Lock Screen. |
| `SbuIconPicker` | Carta / Inversa nel foglio Impostazioni, solo se l'app ha `AppIcon-Inversa`. |
| `SbuContrast` | Rapporto WCAG su `Color.Resolved`. |
| Shell | `accent: SbuAccent`, tint `ink`, `SbuToggleStyle` per tutti i Toggle, titolo grande delle schermate di gestione in Bricolage, titolo della barra nascosto sulla schermata strumento, suono del punto fermo (spento) e icona nelle Impostazioni, Licenze con Bricolage e Plex Mono. |

Deprecati per una release (rimuovere nella prossima): `SbuStat`, `SbuToolField`, `SbuFullStop(fontSize:)`, `SbuTheme.stat`, `SbuTheme.statHero`, `SbuTheme.surface`, `mark-size`/`mark-gap`, gli init delle shell con `accent: Color`. Nessuna app li usa più.

## App

Ogni app: `accent: .<app>`, carta, titolo e cartiglio, `SbuFigure`, controlli in inchiostro, `SbuEmpty`, icona Inversa con le due impostazioni in `project.yml`, stringhe IT/EN, un test di flusso in più ad AX5 con `performAccessibilityAudit`.

| App | Chiusura (IT / EN) e quando | Note |
|---|---|---|
| Habits | Fatto / Done: l'ultima abitudine di oggi | Anelli diventati checkbox in una `SbuListCard` (OGGI/DOMANI); widget figura per Serie, Tasso, Singola; Live Activity del timer disegnata a mano con lo stesso layout (serve un `SbuLiveFigure` con `Text(timerInterval:)`). App Watch solo verificata a tipi: su questo Mac manca il runtime watchOS. |
| Subscriptions | Pagato / Paid: "Segna come pagato" nello Storico del dettaglio | Righe con `SbuRowMark` (entro 7 giorni pieno); home ancora `List` nativa (raggruppamento, ricerca), non `SbuListCard`; widget solo figura (liste rimosse). |
| Level | In bolla / Level: 1,5 s in tolleranza | Rimossi bolla, assi, ago, scala; il punto fermo è l'indicatore. Nuovo interruttore "Zero sui lati" in Impostazioni (sostituisce la rotazione del quadrante). |
| Scanner | Salvato / Saved: codice salvato in cronologia | Nessuna cifra; il risultato si apre dopo la Chiusura. Due interruttori di suono in Impostazioni (punto fermo di SbuKit e suono di scansione dell'app). |
| Clean | Liberato / Freed: cestino svuotato | Barra e anello rimossi; widget figura. |
| Find | Trovato / Found: dispositivo trovato | Anelli rimossi; Live Activity `SbuLiveFigure` chiusa 4 s dopo il "trovato"; tolto l'aptico `.warning` (non è uno dei tre segni). |
| Fuel | Registrato / Logged: rifornimento salvato dalla home | Primo avvio con un secondo bottone "Prova con dati di esempio". |
| Grid | Salvata / Saved: immagine salvata in Foto | Nessun reticolo sulla foto; schermata in ScrollView. |
| Inventory | Aggiunto / Added: nuovo oggetto | `SteadyFigure` nell'app (aggiramento del loop in List, ora risolto in SbuKit: si può togliere). |
| Libretto | Superato / Passed: esame salvato come superato | Widget figura; nel simulatore restano frecce verde/rosse con segno (colore di stato con simbolo). |
| Meds | Presa / Taken: l'ultima dose di oggi | Widget figura senza nome del farmaco. |
| Moon | Impostato / Set: avviso di fase attivato | Chiusura dentro il foglio Impostazioni (la shell non ha un callback di chiusura del foglio). Disco della luna in inchiostro. |
| Noise | Spento / Off: fine del timer | L'orologio da comodino resta scuro: serve un ADR o va tolto. L'allarme AlarmKit usa ancora l'accento (superficie di sistema). |
| Remote | Collegato / Paired: abbinamento riuscito | Nessuna cifra (#349). Il selettore TV spostato nel contenuto (la shell occupa il `principal`). |
| Shrink | Ridotto / Shrunk: compressione finita | |
| Speed | Salvato / Saved: viaggio salvato | Tachimetro rimosso; Parabrezza resta l'unica schermata scura e sostituisce la schermata strumento mentre è aperta. |
| Tidy | In ordine / Tidy: l'ultima faccenda di oggi spuntata su Oggi | Faccende come checkbox in `SbuListCard` per stanza; le fatte oggi restano spuntate (si possono togliere). Primo avvio con un solo bottone ("Usa le stanze di base"). |
| Chats | Importata / Imported: chat importata (sul dettaglio, non per la chat di esempio) | Figura sopra la `List` come inset fisso; ad AX5 occupa due terzi dello schermo. |

Sbu Duo non è su `main` (ramo `private/duo`): non migrata.

## Sito

`Site/` (Astro): font variabili self-hosted, reticolo reale da 24 px (maschera SVG in `public/grid-cell.svg`, per la CSP), home come foglio a quadretti con una cella piena per app che si chiude al tocco e vola sul titolo dell'app, sezione "Il numero" (14,97 €: i prezzi in repo sono una tantum, letti il 12/10/2026, quindi "€ una tantum" e non "€/anno"), pagina app come scheda con cartiglio e liste fa/non fa. OG e layout screenshot rigenerati con la stessa regola. Non esiste `apps.json`: la fonte resta `Site/src/content/apps/*.md`.

## Scelte dove la specifica taceva

- `SbuAccent` (base + onInk) generato per app al posto di un colore singolo.
- `SbuAppShell` resta il nome della shell, con un nuovo init; deprecato solo l'init con `Color`.
- Schermate di gestione: `List`/`Form` nativi su carta (raggi di sistema); `SbuListCard` solo sulle liste disegnate sulla carta.
- Titoli grandi della barra in Bricolage tramite `UINavigationBar.appearance`.
- Taglia della cifra per lunghezza in celle intere; ultima istanza con `minimumScaleFactor` 0,4 per non andare mai a capo.
- `absent` lascia lo spazio vuoto, la cifra non si sposta.
- Gap del punto fermo: `space3`/`space2`/`space1` per hero/inline/mark.
- Parola della Chiusura senza punto: il quadretto è il punto.
- Disabilitato: controlli in `inkMuted`, mai trasparenze.
- Parole di Chiusura per Moon, Noise, Speed, Remote, Chats e gli eventi che le attivano (tabella sopra).

## Falsi positivi noti dell'audit

`performAccessibilityAudit` segnala la cifra hero come "Dynamic Type unsupported" (per progetto non scala) e il cartiglio come "partially unsupported"/"Text clipped" anche se è intero. Ogni app filtra solo quegli elementi (etichetta della cifra, prefisso "SBU ·"), sul modello di `LevelFlowTests`. Anche le etichette dentro `SbuToggleStyle`/`SbuCheckboxStyle` risultano "clipped" (probabilmente misurate nella `accessibilityRepresentation`): Tidy le filtra. Da capire in SbuKit; Chats filtra anche il picker di sistema "Periodo" ad AX5.

## Da fare a mano

- Icone Inversa definitive: quelle in repo sono generate da `make_icons.py --inverse` (provvisorie).
- `punto.caf` definitivo: quello in SbuKit è un tono sintetico di 40 ms.
- Rilettura delle traduzioni EN nuove (parole di Chiusura, cartigli, frasi vuote).
- Test sul dispositivo di ogni app (memoria "Release joint test"), screenshot App Store da rifare con `fastlane snapshot && fastlane frames`.
- Build e test dell'app Watch di Habits su una macchina con il runtime watchOS.
- Orologio da comodino di Noise scuro: ADR o rimozione.
- Rimuovere i wrapper deprecati nella prossima release, e gli aggiramenti ora inutili (`WholeGridCells` in Subscriptions e Meds, `SteadyFigure` in Inventory).
- Ordine duplicato 13 di Fuel e Inventory nei contenuti del sito.

## Test (17/10, simulatore iPhone)

Unit e UI verdi: Chats, Find, Fuel, Grid, Level, Libretto, Meds, Moon, Noise, Remote, Scanner, Shrink, Tidy. Unit verdi, UI rossi:

- **Clean**: `testSwipeLeftMarksForTheBinAndUndoBringsItBack` (riga "Nel cestino · 1 di 22 · 16 ott 2026" tagliata), `SnapshotTests` (nessuna Cell da toccare); fallisce anche lo schema unit, che include il flow test.
- **Habits**: lo schema incorpora l'app Watch e qui manca watchOS 26.5; senza Watch fallisce `testSettingsOfferExportAndImportAndPassTheAccessibilityAudit` (`XCUIApplication+HabitForm.swift:12`).
- **Inventory**: `testFolderMoveSearchAndDelete` ("Sposta in" non trovato), `testItemDetailChangesQuantityAndDeletes` (`deleteItem` non trovato).
- **Speed**: `testDriveShowsSpeedAndTripInKnots` ("Posizione non consentita" nel simulatore).
- **Subscriptions**: `testFoldACycleSectionAndPickReminderDays`, `SnapshotTests`.

Da sistemare prima del merge su main.
