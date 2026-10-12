# Sbu Tuner: sintesi su GuitarTuna e Tuner Pro

> **Attenzione: in entrambi gli originali la funzione principale, accordare, è gratuita.**
> GuitarTuna accorda gratis in standard chitarra, basso e ukulele (con pubblicità). A pagamento ci sono le accordature alternative (anche Drop D), le personalizzate, il cromatico, gli altri 12 strumenti, canzoni, accordi e giochi.
> Tuner Pro, secondo il listing, mette a pagamento solo accordi completi, tap tempo e suddivisioni del metronomo, giochi e rimozione degli annunci; l'accordatore non è nell'elenco. In pratica però il paywall in onboarding, subito dopo il permesso microfono, fa credere alle persone che l'app sia a pagamento: 25 recensioni basse su 25 parlano di abbonamento.
> La regola "copiamo solo app la cui funzione principale è a pagamento" **non è rispettata alla lettera**. Il caso a favore: GuitarTuna fa pagare metà dell'accordatore (alternative, cromatico, strumenti), e Tuner Pro, in pratica, si fa pagare da chi voleva solo accordare. Decisione aperta in un ticket grilling.

Fonti: `research/527588389/` e `research/1438248122/` (`meta.json`, screenshot, `reviews.json`, `spec.json`, `ux.md`).

## Matrice delle feature

| Feature | Originale | A pagamento? | Sbu | Framework iOS (iOS 17+) | Conflitto con CLAUDE.md? |
|---|---|---|---|---|---|
| Rilevamento della nota dal microfono | entrambi | no | core | AVAudioEngine (input tap), Accelerate/vDSP, YIN o autocorrelazione in un tipo puro | no; permesso microfono con stringa IT/EN, nulla registrato |
| Accordatore per corde, Auto: corda più vicina, cent, alza/abbassa, intonata | entrambi | no (standard) | core | SwiftUI, `SbuToolField` + `SbuStat` | la paletta disegnata va sostituita: copia visiva e illustrazione fuori dal design system |
| Modalità manuale con nota di riferimento | entrambi | no | core | AVAudioSourceNode (sinusoide o pizzico sintetizzato) | no |
| Strumenti e accordature (chitarra 6/7/12, basso 4/5, ukulele, violino, viola, violoncello, mandolino, banjo, balalaika, cavaquinho; standard, drop, aperte, abbassate) | GuitarTuna (15 strumenti, 100+ accordature); Tuner Pro (chitarra, basso, ukulele) | GuitarTuna: sì, oltre lo standard | core | catalogo statico in un tipo `nonisolated`, `List .insetGrouped` | no |
| Accordatore cromatico (nota, Hz, cent) | entrambi | GuitarTuna: sì | core | stesso motore | no |
| Calibrazione A4 (es. 415-466 Hz, reset 440) | GuitarTuna (documentato) | no | core | `@AppStorage`, `Stepper` | no |
| Precisione fine (±1 cent) | GuitarTuna (interruttore "pro") | no | core, sempre attiva | `swift-format-style` per cent e Hz | no |
| Accordature personalizzate | GuitarTuna | sì | nice | SwiftData o JSON in UserDefaults | no |
| Modalità mancini | GuitarTuna | no | nice | ordine delle corde invertito | no |
| Notazione Do Re Mi / lettere | nessuno documentato | n/d | core per l'italiano | `Locale`, impostazione | no |
| Metronomo (BPM, tap, misura, suddivisioni, suono) | entrambi | Tuner Pro: tap e suddivisioni | nice, da decidere | AVAudioEngine con `AVAudioPlayerNode.scheduleBuffer(at:)` su tempo campione | **sì, possibile**: seconda funzione contro "una cosa sola" |
| Libreria accordi con diagrammi e ascolto | entrambi | sì (completa) | nice, da decidere | diagrammi generati da teoria musicale, Canvas | **sì, possibile**: una cosa sola; contenuti |
| Canzoni con accordi, tab, testi | GuitarTuna | sì | skip | n/d | **sì**: rete, server, licenze editoriali dei testi |
| Basi di accompagnamento | Tuner Pro | parziale | skip | n/d | **sì**: contenuti scaricati, rete |
| Accordi e testi generati da AI | Tuner Pro | sì | skip | n/d | **sì**: server, rete, diritti |
| Lezioni, giochi, ear training, stelle, streak | entrambi | sì | skip | n/d | **sì**: stelle e lucchetti vietati, fuori dalla funzione |
| Account, pubblicità, tracking (ATT) | entrambi | n/d | skip | n/d | **sì**: vietati |
| Widget, Watch, Shortcuts, Live Activity | nessuno | n/d | non previsti | n/d | n/d |

## Problemi principali degli utenti

1. **Abbonamento non voluto e disdetta impossibile** (Tuner Pro, 8+ recensioni): il paywall arriva in onboarding accanto al permesso microfono; la prova si converte in 7-8 € a settimana; chi cancella l'app continua a pagare.
2. **Prezzo assurdo per un accordatore** (6 recensioni): "con 12 euro mi compro un accordatore a pinza".
3. **Si paga per accordature banali** (GuitarTuna): Drop D a pagamento.
4. **Pubblicità e richieste di acquisto continue** (GuitarTuna, 3 recensioni).
5. **Non funziona senza internet** (GuitarTuna, 4 recensioni): non parte o non apre i brani offline.
6. **Corda rotta** (GuitarTuna, 1): probabilmente l'accordatore ha agganciato l'ottava sbagliata. Va protetto: mai suggerire di alzare una corda di un'ottava.

## Cosa fa meglio Sbu

- Tutto l'accordatore gratis e offline: ogni strumento, ogni accordatura, cromatico, calibrazione. Niente prova che si rinnova, niente paywall accanto al permesso microfono.
- Si apre sull'accordatore, senza onboarding e senza schermata di caricamento.
- Una cifra sola, i cent (o la nota), chiusa dal punto fermo; il resto secondario. Leggibile a un metro sul leggio, con Dynamic Type e VoiceOver che annuncia "nota, cent, alza/abbassa".
- Notazione Do Re Mi per chi suona in italiano.
- Protezione dall'ottava sbagliata: la corda si confronta con la sua ottava attesa, e "alza" di più di un semitono mostra un avviso.
- Gamma più ampia di Tuner Pro (che si ferma ad Ab1 e D5): B0 del basso a 5 corde fino al Mi cantino del violino.
