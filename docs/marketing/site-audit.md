# sbu.dev: audit del sito (13 ottobre 2026)

Sito prima del redesign (commit `3a0c3a4`), `npm run build` + `astro preview`, Chrome headless a 390 px e 1440 px, chiaro e scuro, `prefers-reduced-motion: reduce`. Pagine viste: `/`, `/en`, `/apps/level`, `/apps/habits`, `/principi`, `/abbonamenti`, `/stampa`. Screenshot prima/dopo fuori dal repo (vedi il rapporto finale).

Cosa funziona già e resta: token generati e rispettati (nessun colore letterale), punto fermo unico sul titolo, skip link, `:focus-visible`, menu del telefono come `<dialog>` nativo, hreflang e JSON-LD, nessuna richiesta di terze parti, nessun overflow orizzontale, contrasti `ink`/`ink-muted` su `surface` sopra AA (6,3:1 e più) in entrambi i temi.

## P0: bloccano lo scopo del sito

1. **La home non dice cosa fa Sbu per chi arriva.** "Sbu fa una cosa sola" e undici icone: niente dice che ogni app rifà gratis un'app a pagamento, cioè l'unico motivo per cui qualcuno cerca "alternativa gratuita a…". Il posizionamento (marketing-plan, content-strategy) non arriva mai sopra la piega.
2. **Il prezzo che non paghi non c'è da nessuna parte.** È l'argomento più forte (fatto pubblico, verificabile, datato) e il sito non lo mostra né in home né nelle pagine app. Le pagine app non nominano mai l'Originale finché la pagina alternativa è in bozza.
3. **Undici "In arrivo" identici.** App con pagina e app solo annunciate hanno la stessa tessera; le seconde aprono una scena che non porta da nessuna parte. Non si capisce cosa è pronto, cosa è in coda e in che ordine.

## P1: qualità, accessibilità, prestazioni

4. **Interazione principale nascosta.** Il trascinamento del punto è spiegato da "Prendi il punto" sotto le undici tessere, fuori dallo schermo su desktop; da tastiera e con VoiceOver resta un elenco di link che apre scene, non le pagine (il link vero si raggiunge solo con cmd-clic).
5. **Un ciclo `requestAnimationFrame` sempre acceso in home**, anche a pagina ferma e con movimento ridotto: legge `getBoundingClientRect` di ogni parola e tessera a ogni frame. Costa batteria sul telefono e layout a ogni frame.
6. **Immagini pesanti.** Lo sfondo inciso di ogni pagina e l'incisione della pagina app caricano le maschere originali a 1024 px (PNG da 100 a 950 kB). Nessuna ha dimensioni ridotte.
7. **Undici quadrati in home.** Ogni icona porta il proprio punto fermo nell'accento: con il punto del titolo fanno dodici quadrati e dodici accenti su una schermata. La regola è un solo quadrato e un solo accento per schermata.
8. **Icone invertite con un filtro in tema scuro** (`invert + hue-rotate`): l'accento del quadratino non è più il token scuro dell'app e la carta dell'icona diventa un riquadro nero bordato.
9. **Gerarchia dei titoli della home**: un `h1` e poi un solo `h2` ("Le promesse"); le app non hanno titolo, le scene nascoste portano tre `h2`.
10. **La privacy dice "L'unico script muove il punto della home"**: non è vero (c'è anche lo script del menu e degli strumenti).

## P2: rifiniture

11. **Font in TTF** (91 kB) invece di WOFF2; nessun `preload` del font del titolo, quindi il titolo si ridisegna (FOUT) sul primo caricamento.
12. **Le promesse sono pillole con un pallino verde**: sei pillole con sei pallini sembrano badge di stato, non promesse; il pallino `success` è un colore di stato usato come decorazione.
13. **Gli strumenti gratuiti** (Livella online, Quanto spendi in abbonamenti) sono solo nel footer: nessuna strada dalla home.
14. **Footer senza logo** e con sette link alla pari: niente distingue le pagine di servizio (privacy, stampa) dagli strumenti.
15. **Pagina app**: l'incisione e il titolo dividono la prima schermata ma su telefono l'incisione viene dopo il testo e la CTA "In arrivo" è una pillola con bordo che sembra un pulsante disattivato.
16. **Tabella confronto** (alternative): `rounded-lg bg-surface-raised` con righe a filetto; va bene, ma non segnala quale colonna è Sbu se non dal nome.

## Cosa cambia nel redesign

| Problema | Intervento |
|---|---|
| 1, 2, 3 | Home come **registro ("Il conto")**: per ogni app la cosa sola, l'Originale e il suo prezzo pubblico, 0 € per Sbu; in fondo il totale barrato come unica cifra. Le app senza scheda vanno in una **coda** numerata, separata. Sottotitolo dell'hero con il posizionamento in meno di 20 parole. |
| 2 | Pagina app: riga "Invece di" con Originale, prezzo e data del controllo. Prezzo in `apps/*.md`, verificato contro `research/<id>/meta.json` in build. |
| 4, 5 | Via il trascinamento e il ciclo continuo: solo CSS (scroll-driven dove c'è), nessuno script in home. |
| 6 | Incisioni ridimensionate con `astro:assets` (WebP piccoli) per registro, sfondo e pagina app. |
| 7, 8 | In home le incisioni sono maschere d'inchiostro (`ink`), senza quadratino; l'accento appare solo sulla riga che scegli. Un solo quadrato: quello del titolo. |
| 9 | `h2` per le sezioni, `h3` per ogni app. |
| 10 | Testo privacy aggiornato. |
| 11 | WOFF2 generato da `Design/fonts` e `preload`. |
| 12 | In home le promesse diventano sei frasi in grande; le pillole restano solo dove rispecchiano `SbuFreeBadge` (pagina app). |
| 13, 14 | Sezione "Nel browser" in home con i due strumenti; footer con logo e due gruppi. |
