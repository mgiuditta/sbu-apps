# ASO e video per ogni rilascio

Checklist da seguire a ogni invio (prima uscita o aggiornamento). Si appoggia a quello che c'è già: metadati in `Apps/<App>/fastlane/metadata/`, video social in `marketing/<app>/video.md`, regole in `marketing/plan.md` §2 (mai marchi altrui nei metadati, mai "clone").

## 1. Keyword: nessuna parola due volte

Apple indicizza nome, sottotitolo e keyword una volta sola. Una keyword che ripete una parola di nome o sottotitolo spreca byte.

- Prima di ogni invio: nessuna keyword che contiene una parola di nome o sottotitolo (controllo sotto).
- Virgole senza spazi, massimo 100 byte, singolari (Apple unisce singolare e plurale).
- Mai nomi di app o marchi altrui, nemmeno nelle keyword (2.3.7).

```sh
python3 - <<'EOF'
import glob,os,re
for d in sorted(glob.glob('Apps/*/fastlane/metadata/*')):
    if d.split('/')[-1] not in ('it','en-US'): continue
    r=lambda f: open(f'{d}/{f}.txt').read().strip() if os.path.exists(f'{d}/{f}.txt') else ''
    w=lambda s: {x.lower() for x in re.findall(r"\w+", s)}
    vis=w(r('name'))|w(r('subtitle'))
    dup=[k for k in r('keywords').split(',') if w(k)&vis]
    if dup: print(d.split('/')[1], d.split('/')[-1], dup)
EOF
```

Il 22/10 sono state ripulite Subscriptions (it), Find (it, en-US) e Scanner (it): entrano con il prossimo aggiornamento di ciascuna. Le altre 17 app hanno ancora ripetizioni: si sistemano al loro primo invio, non prima.

## 2. Testo promozionale

170 caratteri, si cambia senza nuova versione, non conta per la ricerca ma è la prima riga che si legge. Oggi ce l'ha solo Find. Ogni app lo riceve al primo invio: una frase su cosa fa, una sul perché è diversa. Si aggiorna a ogni lancio (Show HN, articolo, gioco del mese).

## 3. Screenshot

- I primi tre sono quelli che si vedono nei risultati di ricerca: il primo mostra la cifra (`SbuFigure`) del lavoro principale, non le impostazioni.
- Le didascalie sono indicizzate da giugno 2025: una parola chiave per didascalia, scritta per una persona.
- Dopo il 4.3 del 14/10: la presentazione di ogni app deve somigliare il meno possibile a quella delle altre App Sbu (stessa carta, contenuto diverso). La cifra e la didascalia raccontano il lavoro specifico dell'app, non sbu.dev.

## 4. Anteprima video sullo Store (App Preview)

Parte in automatico, senza audio, nei risultati di ricerca. Regole di Apple: solo immagini registrate dall'app (niente mani, niente cornici di iPhone, niente altre app), testo in sovrimpressione ammesso, 15-30 s.

Ricetta, senza dipendenze nuove:

1. Registra: `xcrun simctl io booted recordVideo raw.mov` sul simulatore, oppure QuickTime con l'iPhone via cavo per le app che usano hardware (Find, Level, Speed, Remote).
2. Tre tempi: la cifra a zero o il problema (0-5 s), il lavoro che cambia la cifra (5-20 s), la Chiusura (20-25 s).
3. Converti nel formato dello Store (6,9" verticale) con una traccia audio muta:

```sh
ffmpeg -i raw.mov -f lavfi -i anullsrc=r=44100:cl=stereo -shortest \
  -vf "scale=886:1920:force_original_aspect_ratio=decrease,pad=886:1920:(ow-iw)/2:(oh-ih)/2:color=white,fps=30" \
  -c:v libx264 -profile:v high -pix_fmt yuv420p -c:a aac -b:a 256k preview.mp4
```

4. Il fotogramma di copertina è quello della cifra con il punto fermo `.set`.

Niente prezzi né confronti con altre app nell'anteprima: quelli restano nei video social.

## 5. Video social

Uno per app, in `marketing/<app>/video.md` (formato di Clean e Find): 20 s verticali 1080×1920, senza voce, sottotitoli impressi IT e EN, l'hook da `hooks.md`. Lo stesso girato produce l'anteprima Store tagliando via le parti con le mani e il confronto di prezzo. Strumenti AI di generazione o avatar: non servono, il prodotto è l'interfaccia vera.

## 6. Checklist per rilascio

- [ ] Keyword senza ripetizioni (§1), it e en-US
- [ ] Testo promozionale aggiornato
- [ ] Primi tre screenshot sulla cifra, didascalie con una keyword
- [ ] Anteprima Store 15-30 s caricata
- [ ] Video social e riga nel `marketing/log.md`
- [ ] Note di versione che dicono cosa cambia per chi usa l'app (`app-store-changelog`)
