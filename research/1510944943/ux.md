# Cleanup: Phone Storage Cleaner (1510944943): UX

Ricerca su dati pubblici: scheda App Store (`meta.json`), 10 screenshot, 69 recensioni 1-3 stelle (`reviews.json`), pagine web citate. Descrive il comportamento; testi, grafica e marchio dell'Originale non vanno copiati.

## Onboarding e momento del paywall

- Carosello breve di 2 schede sul valore, poi permesso Foto, poi paywall a 00:28 del walkthrough che blocca tutte le funzioni. Paywall "soft" (chiudibile) con prova di 7 giorni che diventa abbonamento settimanale; contatori animati simulano una pulizia in corso. Fonte: https://screensdesign.com/showcase/cleanup-phone-storage-cleaner
- La prova chiede la carta; molte recensioni riportano l'addebito già all'avvio della prova (10 menzioni in `reviews.json`).
- Il livello gratuito lascia scansionare ma blocca l'eliminazione: circa 5 foto al giorno (recensioni) oppure piccoli lotti sbloccati guardando una pubblicità. Un utente racconta il ciclo "tocca elimina, guarda annuncio, conferma, ripeti". Fonte: https://forum.network-inventory-advisor.com/t/cleanup-app-reviews-positive-or-mostly-complaints/2403/2
- Dopo una eliminazione riuscita compare la richiesta di valutazione (01:21). Fonte: screensdesign sopra.

## Schermate e disposizione

Fonti: screenshot 01-10, https://screensdesign.com/showcase/cleanup-phone-storage-cleaner

1. **Dashboard** (00:56): un'unica schermata con barra dello spazio occupato e categorie a schede (foto, video, contatti, email), ingranaggio. Il walkthrough la giudica affollata.
2. **Duplicate / Simili** (screenshot 03): titolo grande, sotto "Foto: N · X GB". Sezioni "Duplicate" e "Simili": per ogni gruppo la foto migliore a sinistra con spunta e badge "migliore", le altre con una X rossa e una pillola "N foto, X GB". In fondo un pulsante pieno "Elimina X GB".
3. **Ordinamento a swipe** (04:54): carta a tutto schermo, sinistra elimina, destra tiene.
4. **Keep list** (05:00): elenco di elementi protetti dalla pulizia.
5. **Video** (descrizione): video ordinati per dimensione, il più pesante prima.
6. **Compressore video** (screenshot 08, 02:59): anteprima divisa prima/dopo con play, "437 MB » 2.9 MB", selettore Basso/Medio/Alto, pulsante "Avvia la compressione".
7. **Live Photo in foto statiche** (screenshot 06): pila di Live Photo con barra "Prima", sotto la foto convertita con barra "Dopo".
8. **Foto delle chat** (screenshot 07): "N foto · X GB", griglia con etichetta dell'app di provenienza (WhatsApp, Snapchat, WeChat), "Elimina X GB".
9. **Contatti duplicati** (screenshot 09, 07:01): coppie con caselle, "Versione unita", pulsante "Unisci N contatti". Il permesso Contatti è chiesto solo entrando qui; offre un backup dei contatti.
10. **Email** (screenshot 04-05): categorie Social, Promozioni, Aggiornamenti, Spam, Forum con conteggi; elenco mittenti con "Mantieni" / "Annulla iscrizione". Richiede login all'account di posta.
11. **Risultato** (screenshot 02): barre "Prima" / "Dopo" dello spazio, coriandoli, "Hai eliminato X GB", "Guadagnate N ore".

## Feature passo per passo

- **Simili**: raggruppa scatti simili; propone la migliore secondo sguardo in camera, sorriso, messa a fuoco, foto modificate o preferite (descrizione in `meta.json`); le altre sono preselezionate; un tocco elimina. Fonte: screensdesign (01:33) e `meta.json`.
- **Cestino e revisione finale**: tutto ciò che marchi va in un cestino interno; alla fine l'app chiede una revisione prima di eliminare (descrizione in `meta.json`). Poi l'eliminazione passa per Foto, quindi in "Eliminati di recente".
- **Video per dimensione**: elenco ordinato dal più grande (`meta.json`).
- **Compressione**: scegli la qualità, guardi l'anteprima, avvii; salva la copia compressa.
- **Live Photo**: converte in foto statica per togliere la parte video.
- **Contatti**: trova duplicati per nome/numero, mostra la versione unita, unisce. Una recensione riporta contatti persi.
- **Email**: collega l'account, raggruppa per categoria e mittente, elimina o annulla l'iscrizione. Recensione: email cancellate per sbaglio senza recupero.
- **Privacy dichiarata**: funziona offline, foto elaborate sul dispositivo (`meta.json`); l'email è l'eccezione.

## Gesti

- Swipe sinistra elimina, destra tiene (screensdesign 04:54, `meta.json`). Tocco su foto per selezionare/deselezionare nei gruppi.

## Impostazioni

- Ingranaggio su dashboard, email e contatti (screenshot 05, 09). Contenuto non documentato pubblicamente.

## Widget, Watch, Shortcuts, Live Activity

- Widget Home: "Memoria N% utilizzata, X su Y GB" con anello, e "Batteria N%" con anello (screenshot 10). Nessuna traccia di Watch, Shortcuts o Live Activity.

## Prezzi

- Settimanale, annuale e a vita; prova 7 giorni (`meta.json`). Listino pubblico: settimanale 3,99-6,99 USD, annuale 29,99 USD, a vita 39,99 USD. Fonte: https://adapty.io/paywall-library/cleanup-phone-storage-cleaner/
- Nelle recensioni italiane: 6,99, 9,99 e 13 EUR a settimana.
