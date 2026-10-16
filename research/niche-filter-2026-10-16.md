# Ventidue nicchie superano il filtro Sbu

**In sintesi.** Su circa 110 nicchie iOS passate al setaccio in sei famiglie (media/file, hardware/sensori, rete locale, produttività/finanza, salute/casa/vita, formazione/musica/creativo), **12 superano pienamente i cinque criteri** e altre **10 passano con una riserva da chiudere con una verifica di un'ora**. Le migliori per rapporto valore/sforzo sono il **cerca-dispositivi Bluetooth** (Wunderfind, 117K valutazioni, cloni a 5,99–7,99 $/settimana, 3–5 giorni di lavoro), il **compressore video** (18K valutazioni, cloni a 6,99 $/settimana, 5–8 giorni), il **programma pulizie "alla Tody"** (Tody 11K + Sweepy 9,4K, nessuna alternativa gratuita, 5–8 giorni) e il **libretto universitario senza pubblicità** (MyLibretto 6,9K valutazioni IT con banner, 5–8 giorni, distribuzione immediata via Discord SecAI). Il telecomando TV universale, già in roadmap come Sbu Remote, esce confermato con i numeri più grandi della ricerca (82K + 712K valutazioni) ma anche con lo sforzo più alto (8–12 giorni ed entitlement multicast). La regola 4 (nessuna app gratis pulita, anche oscura) ha bocciato nicchie molto redditizie come OBD-II, EXIF remover, teleprompter e diario pressione: sono i "quasi-PASS" da riconsiderare se Matteo accetta di competere con app a 5–500 valutazioni. Tre voci della roadmap attuale vanno riviste alla luce dei dati: Sbu BP e Sbu Pulse (riserva) falliscono il filtro, Paprika e Money Pro (vecchia Wave 2) pure.

## Dodici nicchie passano senza riserve, quattro costano meno di una settimana

Il pattern che accomuna le vincitrici è sempre lo stesso: un leader con decine di migliaia di valutazioni che monetizza con abbonamento settimanale, pubblicità o "remove ads" a pagamento, una funzione che il sistema non copre, e un vuoto nella fascia "gratis senza compromessi" che nessun indie ha ancora riempito. Il caso più netto è il cerca-dispositivi Bluetooth: **Wunderfind ha 117K valutazioni con Pro a 4,99 $** ([App Store](https://apps.apple.com/us/app/wunderfind-find-lost-device/id1458601441)), il clone "Find My Bluetooth Device" chiede **7,99 $ a settimana con 4,6K valutazioni** ([App Store](https://apps.apple.com/us/app/id1522814560)), Dov'è di Apple localizza solo accessori certificati Find My, e la ricerca non ha trovato né un'app gratuita pulita né un progetto Swift open source. Tecnicamente è una scansione CoreBluetooth con smoothing dell'RSSI, barra/radar e aptica: 3–5 giorni. Il video compressor replica lo schema: **Compress Videos & Resize Video ha 18K valutazioni e Pro a 4,99 $/mese** ([App Store](https://apps.apple.com/us/app/id1473857051)), "Video Compressor + Resizer!" vende un **Weekly Pro a 6,99 $** ([App Store](https://apps.apple.com/us/app/video-compressor-resizer/id6742453124)), e l'unica via nativa è l'azione Shortcuts "Encode Media" che non permette un target in MB, bitrate custom o batch ([Guiding Tech](https://www.guidingtech.com/extract-audio-from-video-ios/)).

Sul fronte casa e salute, Tody e Sweepy dimostrano che la gente paga per un algoritmo banale: **Tody ha 11K valutazioni e vende il piano Solo a 9,99 $** ([App Store](https://apps.apple.com/us/app/tody-smarter-cleaning/id595339588)), **Sweepy 9,4K valutazioni a 3,99 $/mese** ([App Store](https://apps.apple.com/app/id1498897320)); il modello "frequenza → livello di sporco → priorità" è tutto locale e non esiste alcuna alternativa gratuita pulita. Il promemoria farmaci multi-persona nasce invece da un cambio di prezzo: **Medisafe (79,8K valutazioni) dal 1° gennaio 2026 limita il piano gratuito a due farmaci e riserva i profili famiglia al Premium a 39,99 $/anno** ([App Store](https://apps.apple.com/us/app/medisafe-medication-reminder/id573916946), [pillo.care](https://pillo.care/blog/medisafe-no-longer-free-best-free-alternatives)); l'unica app no-account multi-profilo costa 59,99 $/anno ([App Store](https://apps.apple.com/us/app/medication-tracker-reminder/id1448776934)) e Salute di Apple è legata a un solo utente per iPhone. Per Matteo il libretto universitario è un caso a parte: **MyLibretto domina lo store italiano con 6,9K valutazioni, banner pubblicitari e PRO a 3,49 €** ([App Store IT](https://apps.apple.com/it/app/mylibretto/id914172791), [Aranzulla](https://www.aranzulla.it/app-per-universita-1178483.html)), le alternative senza pubblicità hanno 11–25 valutazioni, e il server Discord SecAI/UniMi è un canale di distribuzione che nessun'altra nicchia offre.

| # | Nicchia | Originale (ID, prezzo, valutazioni) | Perché nessuna alternativa pulita | Tecnica | Giorni | Rischi App Review |
|---|---|---|---|---|---|---|
| 1 | **Cerca-dispositivi Bluetooth (RSSI)** | Wunderfind id1458601441, Pro 4,99 $, 117K val.; Find My Bluetooth Device id1522814560, 5,99–7,99 $/sett., 4,6K val. | Solo cloni con ads o weekly (BLE Scanner 3,99 $/sett., Bluetooth Radar con ads, 4–6 val.); zero progetti Swift open source; Dov'è copre solo accessori Find My | CoreBluetooth scan + EMA/Kalman su RSSI, stima distanza path-loss, CoreHaptics, lista "visti di recente" | 3–5 | 5.2.5: mai "Find My" nel nome; dichiarare il limite "solo dispositivi BLE"; 4.3 gestibile con posizionamento pulito |
| 2 | **Compressore / convertitore video** | Compress Videos & Resize Video id1473857051, Pro 4,99 $/mese, 18K val.; Video Compressor + Resizer! id6742453124, 6,99 $/sett. | Le free hanno ads o 13 valutazioni; nessuna voce nel catalogo open-source-ios-apps; Shortcuts "Encode Media" senza target MB/batch | AVAssetReader/Writer + VideoToolbox (H.264/HEVC), stima dimensione, batch, MOV→MP4, mute, fps | 5–8 | 4.3: decine di "Video Compressor", servono nome e icona distintivi |
| 3 | **Programma pulizie "alla Tody"** | Tody id595339588, Solo 9,99 $ una tantum, 11K val.; Sweepy id1498897320, 3,99 $/mese, 9,4K val. | Housy e simili sono freemium con tracker; nessuna open source iOS | SwiftData (stanza → attività → frequenza → ultimo completamento), punteggio urgenza, WidgetKit, preset | 5–8 | 4.3 basso-medio; offline = niente sync famiglia (va dichiarato) |
| 4 | **Libretto universitario senza ads (IT)** | MyLibretto id914172791, gratis con banner, PRO 3,49 €, 6,9K val. IT | 110eLode 0,99 € (11 val.), UniChecker con banner (25 val.), Uniwhere con account | SwiftData, media aritmetica/ponderata, base di laurea configurabile, simulatore voto, Charts, widget, countdown esami, orario | 5–8 | Nessun rischio 5.2.5; 4.3 basso |
| 5 | **Griglia per disegno (grid overlay + traccia su camera)** | DrawinGrid id1508298774, ads, Pro 8 $/86 $, account, ~5K val.; GridArt id6474590995, 3,99 $/sett. + ads, 212 val. | L'unica senza ads (Drawing Grid) costa 1,99 $ e ha 18 val. | PhotosPicker + Canvas overlay (righe, diagonali, etichette, B/N), export via ImageRenderer, overlay su AVCaptureVideoPreviewLayer | 3–5 | 4.3 medio (8–10 app simili, tutte con ads/sub) |
| 6 | **Promemoria farmaci multi-persona (caregiver)** | Medisafe id573916946, 4,99 $/mese o 39,99 $/anno, 79,8K val.; Med ART id1448776934, 59,99 $/anno, 706 val. | MyTherapy è mono-profilo con account; MedTimer open source è solo Android; Salute è mono-utente | SwiftData (persona → farmaco → schedula → dose), notifiche con azioni, widget, PDF per il medico | 7–10 | 1.4.1: zero consigli di dosaggio/interazioni; 5.1.1; 4.3 medio |
| 7 | **Telecomando TV universale Wi-Fi** (= Sbu Remote già in roadmap) | Universal TV Remote Control・ id6443877058, 6,99–8,99 $/sett., 82K val.; Rokie id1016562846, ads + 2,99–5,99 $/sett., 712K val. | Le ufficiali sono gratis ma mono-marca e con account (Fire TV, ThinQ, SmartThings); Roam (no ads, 301 val.) è solo Roku e PolyForm NC | Roku ECP, Samsung/LG WebSocket + pairing, Sony REST, Android TV v2 (TLS + protobuf); discovery SSDP | 8–12 (5–6 per MVP Roku+Samsung+LG) | 4.3 molto alto; 5.2.5 marchi solo in descrizione; entitlement multicast da chiedere subito, fallback IP manuale |
| 8 | **Contarighe maglia/uncinetto + schemi PDF** | My Row Counter id1342608792, Premium 2,99 $/mese + "No Ads" 2,99 $, 3,8K val.; Knit Pro id1601194384, 2,99 $/7 giorni | Stitch Keeper (pulita) costa 4,99 $; Knit Row Counter è gratis ma solo contatore, 3,5★ | SwiftData, contatori collegati, reminder "ogni N righe", PDFKit con contatore sovrapposto, Watch, widget | 5–8 (8–10 con Watch) | 2.5.9: vietato contare col tasto volume; 4.3 medio |
| 9 | **Tabella faccende + paghetta bambini (un dispositivo di casa)** | Chorsee id1611068600, 8,99 $/mese o 39,99 $/anno, ~12K val.; Homey id1033286805, 49,99 $/anno, 2,8K val. | Tutte freemium con account/sync; nessuna open source iOS | SwiftData (membro → faccenda → ricorrenza → saldo), PIN genitore, modalità bambino, widget | 7–10 | Evitare categoria Kids (1.3/5.1.4); offline = senza sync (posizionare "la tabella sul frigo") |
| 10 | **Lettore RSVP / speed reading con EPUB** | Outread id778846279, 2,99–3,99 $/sett., lifetime 119,99 $, 1,4K val. | ReadOwl costa 24,99 $; Spritz App 2,8★ solo web; nessuna RSVP open source iOS | Parser EPUB (zip + XHTML), ORP, share extension, PDFKit | 6–10 | 4.3 basso-medio; l'utente porta i propri EPUB |
| 11 | **Cast foto/video/musica via DLNA/UPnP** | TV Cast & Screen Mirroring id1470813786, 3,99–5,99 $/sett. (IT fino a 7,49 €), 22K val.; TV Assist id760661078, IAP + ads, 10K val. | VLC "non può ancora fare cast DLNA" ([VideoLAN](https://forum.videolan.org/viewtopic.php?p=506752)); Kodi non è su App Store | SSDP M-SEARCH, SOAP AVTransport, server HTTP locale con NWListener, transcodifica per TV vecchie | 5–8 | Entitlement multicast indispensabile; AirPlay 2 copre le TV recenti (pubblico = TV senza AirPlay); mai "mirroring" nel nome |
| 12 | **Lunga esposizione / scie luminose** (era in vecchia Wave 2) | Slow Shutter Cam id357404131, a pagamento, ~11K val.; ReeXpose id1624485209, 7,99–14,99 $/anno, 457 val. | Nessuna gratis pulita >1K trovata; Live Photo offre solo un effetto automatico ~3 s | AVCaptureVideoDataOutput + accumulo frame in Metal/CoreImage (media/max/somma), timer | 5–8 | 4.3: decine di "long exposure"; gestione termica |

La differenza tra le prime cinque e le altre è il rapporto giorni/base installata: cerca-Bluetooth e griglia costano meno di una settimana e colpiscono un weekly riconoscibile (7,99 $ e 3,99 $ a settimana), esattamente il "numero scandaloso" su cui si regge la strategia punta-di-lancia. Medisafe e Chorsee hanno basi enormi ma chiedono 7–10 giorni e una storia più complessa ("profili famiglia a pagamento").

## Dieci nicchie passano con una riserva che si chiude in un'ora di verifica

Il secondo gruppo non ha fallito nessun criterio, ma la ricerca si è interrotta prima di chiudere un dubbio, oppure il criterio 1 (originale "abusivo") o il 3 (copertura nativa parziale) sono deboli. Il caso più ghiotto è il ridimensionamento immagini a pixel esatti: **Image Size ha 30K valutazioni, contiene pubblicità e chiede 39,99 $ (44,99 € in Italia) per toglierla** ([App Store](https://apps.apple.com/us/app/id670766542), [App Store IT](https://apps.apple.com/it/app/id670766542)); File converte formati ma offre solo quattro taglie fisse, e il lavoro è di 2–4 giorni. Manca solo una ricerca Reddit per escludere un resizer gratuito pulito noto. Stesso discorso per il GIF editor: **ImgPlay ha 45K valutazioni, vende un Weekly Pro a 2,99 $ e mette il watermark nel free** ([App Store](https://apps.apple.com/us/app/id989843523)); Shortcuts ha "Crea GIF" ma senza trim, velocità, testo o controllo del peso, e alternativeto propone solo GIPHY e Coub, entrambe con account ([alternativeto](https://alternativeto.net/software/imgplay/)).

| # | Nicchia | Originale | Riserva da chiudere | Giorni |
|---|---|---|---|---|
| 13 | **Batch resize immagini (px/cm/DPI)** | Image Size id670766542, ads, Remove Ads 39,99 $, 30K val. | Una ricerca "image resizer free no ads iPhone" su Reddit/alternativeto | 2–4 |
| 14 | **GIF editor (video/Live Photo → GIF con trim, velocità, testo, peso)** | ImgPlay id989843523, 2,99 $/sett., 45K val. | Shortcuts copre il caso base (criterio 3 parziale); ricerca Reddit non fatta | 4–6 |
| 15 | **Music tag editor (ID3/MP4/FLAC)** | Evertag id1450763230, 1,99 $/mese, 5,5K val. | Verificare se foobar2000 iOS modifica i tag; Evertag vince col lookup online che Sbu non replica | 5–8 |
| 16 | **Misuratore PPFD/DLI per piante (grow light)** | Photone id1450079523, 5,49 $/mese, lifetime 97 $, 4,9K val. | Ricerca alternative incompleta; misura via fotocamera solo stimata, da dichiarare | 4–6 |
| 17 | **Scansione scontrini OCR on-device + CSV/PDF** | Smart Receipts id905698613, PRO 8,99 $/mese + OCR a consumo | Numero valutazioni di Smart Receipts non letto; ricerca "scontrini" su store IT | 7–10 |
| 18 | **Screen recorder con facecam/commento** | Screen Recorder Pro id1463179214, 4,99 $/sett., 23K val.; Record it! 435K val. con limite 3 min | Complessità ReplayKit (broadcast extension 50 MB RAM) ai limiti dei 12 giorni | 7–12 |
| 19 | **Archiver RAR/7z (estrai RAR, crea 7z/zip con password)** | ZArchiver id1639665809, 2,99 $/sett. + ads, 2,7K val. | Local Storage (open source) estrae già 7z; il varco è RAR + creazione; categoria affollata | 5–8 |
| 20 | **Watermark batch** | Watermarkly id1507414497, 19,99 $/anno, 1,2K val. | Originale non abusivo (vende lifetime); candidato a fondersi con il resize in un'unica "Sbu Image" | 3–4 |
| 21 | **Libretto sanitario animali (multi-pet, PDF per il vet)** | 11pets id1232470530 (74 val.), PetNoter id1580581463 1,99 $/mese; PetDesk 507K val. ma portale clinica | Criterio 1 debole: nessun indipendente supera 100 val.; Manage Pets è gratis pulita ma a zero val. | 6–9 |
| 22 | **Comic reader CBZ/CBR** | Panels id1236567663, 1,49 $/mese o 19,99 $, 13K val. | Verificare MuPDF/Chunky su iPhone; un reader completo è 8–12 giorni | 8–12 |

Restano sotto la soglia, utili solo come riempitivi o tool interni: misure corporee con foto progressi (Body tracker, 634 val.; BodyLog diventerà a pagamento), calendario semine (Seed to Spoon 9,2K val. a 46,99 $/anno ma richiede un dataset colture auto-prodotto), scadenzario manutenzione casa (HomeKeep, nessun originale grande), kanban offline (nessun originale a pagamento: il dolore è l'account Trello), backup rubrica vCard (My Contacts Backup 10K val. con ads, ma Shortcuts lo fa), screenshot framer (Picsew 1,99 $, 3,3K val., zero affollamento, utile a Sbu stessa per gli screenshot) e frame grabber da video (Frame Grabber 3,3K val., sblocco 19,99 $, 2–3 giorni).

## La regola 4 blocca sette mercati enormi per colpa di app che nessuno conosce

Il criterio "nessuna app gratis pulita, anche oscura" è quello che ha pesato di più e ha prodotto un gruppo di bocciature che meritano una decisione esplicita di Matteo. Il caso estremo è l'OBD-II: **Car Scanner ha 33K valutazioni** ([App Store](https://apps.apple.com/us/app/car-scanner-elm-obd2/id1259933623)) e Torque OBD Lite vende a 2,99 $/settimana, ma a giugno 2026 è uscita **OpenOBD, gratis, senza account né ads, con 5 valutazioni** ([App Store](https://apps.apple.com/us/app/id6780283561)). L'EXIF remover è lo stesso schema: **Metapho chiede 19,99 $/anno o 99,99 $ una tantum con 2,1K valutazioni** ([App Store](https://apps.apple.com/us/app/metapho/id914457352)), mentre **MetaX è gratis, open source e ha 12 valutazioni** ([App Store](https://apps.apple.com/app/metax/id1376589355), [GitHub](https://github.com/Ckitakishi/MetaX)). Il teleprompter è il più doloroso da lasciare: **34K valutazioni con Pro a 59,99 $** ([App Store](https://apps.apple.com/us/app/teleprompter/id941620509)) e cloni a 2,99 $/settimana, contro **Open Prompter, MIT, zero rete, 5 valutazioni, aggiornato a settembre 2026** ([App Store](https://apps.apple.com/us/app/id6763611915)).

| Nicchia quasi-PASS | Originale abusivo | App pulita che la blocca | Giorni | Se si allenta la regola 4 |
|---|---|---|---|---|
| OBD-II ELM327 | Car Scanner 33K val.; Torque 2,99 $/sett. | OpenOBD, 5 val., closed source, Firebase opt-in | 8–12 | Mercato hardware più grande; serve auto + adattatore per i test |
| EXIF viewer/remover | Metapho 2,1K val., 19,99 $/anno | MetaX, 12 val., MIT + Commons Clause (non copiare codice) | 3–5 | Micro-app perfetta per il brand "privacy"; idea libera, codice no |
| Teleprompter | Teleprompter 34K val., Pro 59,99 $; BIGVU 36K val., 24,99 $/mese | Open Prompter, 5 val., MIT, set. 2026 | 4–6 | Base enorme; competere con un open source "gemello" è antipatico |
| Diario pressione | Blood Pressure App 4,6K val., 6,99 $/sett. (7,99 € IT) | Simple Blood Pressure Tracker, 516 val., no IAP; Pressure Easy, nuova | 5–7 | Solo come modulo "Salute famiglia" con profili multipli; 1.4.1 e 4.3 alti. **Sbu BP in riserva va tolta** |
| Battito da fotocamera (PPG) | Heartica 7K val., 6,99–9,99 $/sett.; Instant Heart Rate 229K val. | Heart Rate Monitor: Pulse BPM (Ellisapps), no sub/no ads | 3–5 | 1.4.1 + decine di cloni: **Sbu Pulse in riserva va tolta** |
| Baby monitor locale | Cloud Baby Monitor 17,8K val., 6,99 $ una tantum | BabyGuard, 14 val., solo LAN; Cribside 4,99 $ | 8–12 | Originale non abusivo; affidabilità difficile |
| Scanner rete locale | Fing 116K val., Premium 7,99 $/mese + ads | iNet Network Scanner, 2,6K val., no ads, no account | 4–6 | iNet è sopra soglia: FAIL vero; iOS non espone ARP/MAC |
| Vocal pitch monitor | Sing Sharp 14K val., 19,99 $/mese | Nail the Pitch, gratis, 1,3K val. | 4–7 | Solo se il free di Nail the Pitch risulta castrato |
| Dashcam | Driver 11,9K val., 95 $/anno | DashCam Recorder, 244 val., "truly free, no ads" | 6–10 | Stesso indie, stessa filosofia Sbu: lasciare |
| Room scanner LiDAR | magicplan 39,8K val., 12,99–89,99 $/mese | OpenPlan3D Capture, 4 val., open source | 4–6 | Solo iPhone Pro; i pro comprano report, non scansioni |
| Chord finder chitarra | Ultimate Guitar 480K val., 9,99 $/mese | Chord Finder • Guitar, 0 val., solo donazioni | 5–8 | Unico angolo: ukulele/basso/mancini in un'app sola |
| Font installer | iFont 2,99 $/sett., 101 val. | Fontcase, open source, 86 val., fermo al 2022 | 2–3 | Riapre solo se il metodo a profilo non funziona più su iOS 26 |

## Sei funzioni valgono più come estensioni che come app nuove

Diverse nicchie bocciate contengono una funzione che rafforzerebbe un'app Sbu esistente o già pianificata, a costo di 1–4 giorni e senza aprire un nuovo fronte 4.3. La più evidente è la manutenzione auto: **Fuelio mette i promemoria di tagliando nel Premium a 17,99 $/anno** ([App Store](https://apps.apple.com/app/id1487753318)) ma la nicchia "solo manutenzione" non ha un leader; una tab Manutenzione in Sbu Fuel (intervalli km/tempo, gomme, revisione, assicurazione, bollo) costa 3–4 giorni e un'app separata rischierebbe il duplicato dello stesso sviluppatore. Alba, tramonto e ora dorata vanno in Sbu Moon: **Sunlitt (798 val., PRO 19,99 $/anno) dichiara di funzionare offline** ([App Store](https://apps.apple.com/app/id1628751457)), quindi il calcolo è tutto effemeridi, 2–3 giorni con l'algoritmo NOAA già usato per la luna; come app a sé fallirebbe per il free tier di Sunlitt, Solstice open source e Meteo.

| Funzione | Dove inserirla | Perché non un'app a sé | Giorni |
|---|---|---|---|
| Manutenzione auto (tagliandi, gomme, revisione, bollo/scadenze) | Sbu Fuel | Fuelio lo vende nel premium ma nessun leader "solo manutenzione"; app separata = duplicato 4.3 | 3–4 |
| Alba, tramonto, ora dorata/blu, crepuscoli | Sbu Moon | Sunlitt free tier + Solstice open source + Meteo bocciano l'app autonoma | 2–3 |
| Wake-on-LAN | Sbu Remote (se ottiene l'entitlement multicast) | Mercato nullo (Magic Packet 104 val.), già gratis (Mocha WOL); richiede lo stesso entitlement del telecomando | 1 |
| Watermark batch + frame grabber + resize | Un'unica "Sbu Image" | Tre micro-nicchie da 2–4 giorni ciascuna; separate rischiano 4.3 e diluiscono il brand | 6–9 totali |
| Hash/encode/decode/JWT/regex (stile CyberChef/DevToys) | Feature di brand "security student" dentro Sbu Auth o un'utility esistente | Nessuna base installata da attaccare (DevPocket, Dev Tools Kit senza valutazioni); Hash Calculator già gratis | 3–5 |
| Orario lezioni + countdown esami | Sbu Libretto (nicchia #4) | Class Timetable è gratis e di fatto pulita: da sola FAIL, come funzione è attesa | incluso |

Il cast DLNA (#11) è a sua volta un candidato da costruire subito dopo Sbu Remote: condivide discovery SSDP, entitlement multicast, prompt rete locale e parsing XML UPnP, riusando circa un terzo del codice.

## Oltre sessanta nicchie falliscono per un'alternativa gratuita o una funzione nativa

La tabella raccoglie i FAIL con la causa decisiva, così da non riaprirli. La costante è che Apple ha assorbito molte utility (Dov'è, Password, Diario, Nascosti, Clean Up, trascrizione in Memo Vocali, Converti immagine in File) e che gli indie open source presidiano le nicchie da smanettone (LocalSend, BookPlayer, Dime, a-Shell, phyphox).

| Famiglia | Nicchia | Alternativa pulita o motivo decisivo |
|---|---|---|
| Media/file | Audio converter, MP3 cutter | Shortcuts "Encode Media → Audio Only"; GarageBand/Memo Vocali |
| | Ringtone maker | GarageBand è passaggio obbligato e fa tutto gratis |
| | Recorder con trascrizione | Memo Vocali trascrive da iOS 18; diarizzazione >12 giorni |
| | Sottotitoli/SRT burn-in | Nessun originale offline con base grande (le grandi sono cloud) |
| | Convertitore HEIC/JPG/PNG | File → "Converti immagine" (iOS 16, batch) |
| | Photo vault | Album Nascosti con Face ID (iOS 16) |
| | Object/watermark remover | Clean Up di Apple Intelligence; inpainting offline >12 giorni |
| | Slow-mo/timelapse/stop motion | Nativi; Stop Motion Studio 5,99 $ una tantum, 81K val. |
| | Meme/testo su foto | Markup; Mematic vive di template |
| | Trimmer/merge video | iMovie |
| | Spartiti PDF | Piascore gratis (1,9K val.); forScore è >12 giorni |
| | Audiolibri locali | BookPlayer, GPL, 20K val. |
| | Music player locale | foobar2000, VLC, Vibe (Apache) |
| | EPUB reader | Libri |
| | Color picker | PickerFull gratis; contagocce di sistema |
| | Firma PDF | Markup |
| Hardware | Scanner BLE (nRF Connect, LightBlue) | Gli originali sono gratis e del produttore |
| | NFC tools | NFC Tools free tier pulito (14K val.); Shortcuts; decine di cloni |
| | Esposimetro foto | Lightme gratis in tutto (929 val., dev italiano) |
| | Metal detector/EMF | phyphox (GPL); originali a 10–38 val. |
| | Altimetro/barometro | Bussola nativa; Altimeter & Barometer Pro free ad-free |
| | Termocamera, IR remote | Hardware assente |
| | Camera manuale pro | Scope >12 giorni; Manual Camera gratis |
| | Specchio/torcia | Nativi |
| | Walkie-talkie Multipeer | bitTalk gratis, nessun originale a pagamento |
| | Controller tester | Game Controller Tester gratis |
| | Rilevatore telecamere nascoste | Funzionalità ingannevole (2.3); basi minuscole |
| | TPMS/power meter BLE | Protocolli proprietari; nessun originale dominante |
| Rete locale | SSH/SFTP | a-Shell, iSH, Blink (GPL), Termius free senza ads |
| | Smart home locale (Hue, WLED, Shelly) | App ufficiali gratis; Apple Home; mercati minuscoli |
| | Sonos | Ufficiale gratis (932K val.) + sei app one-time economiche |
| | AirPlay receiver / mirroring | Nativo in uscita; ricevitore = protocollo chiuso (2.5.1) |
| | Stampante/scanner eSCL | AirPrint; OpenAirScan gratis (3 val.) |
| | NAS/WebDAV/SFTP browser | File (SMB); Documents gratis (558K val.); FE 4,99 $ one-time |
| | File transfer cross-platform | LocalSend, Apache-2.0, 83K stelle |
| | Wi-Fi QR / iperf | Password di iOS; iPerf Reloaded gratis |
| Produttività | Budget/spese offline | Dime (GPL, 1,9K stelle), BeeCount; categoria satura |
| | Debt payoff, mutuo | Debt Free gratis (~1K val.); mutuo saturo |
| | Spese condivise | Splid: no account, offline, IAP una tantum, 4,1K val. |
| | Countdown widget, compleanni | Countdown° Pro 0,99 $ (24K val.); Calendario |
| | Markdown editor | Markdown° gratis (491 val.); iA Writer una tantum |
| | Mind map | SimpleMind free tier pulito; editor canvas 12–20 giorni |
| | Sticky widget | Widget di Note; originali a 66–259 val. |
| | Time zone planner | Time Buddy gratis (14K val.); Orologio |
| | Tip calculator, packing list, lista spesa | Splito! open source; PackPoint 2,99 $; Promemoria |
| | Ricette | Crouton gratis (2,9K val.); Paprika 4,99 $ una tantum (**togliere dalla vecchia Wave 2**) |
| | Reading tracker | Reading List gratis, no account, 30K val. |
| | Vault password | Password di Apple + Note bloccate |
| | Codice fiscale, busta paga | Basi da 1 a 125 val.; regole annuali |
| Salute/casa | Emicrania/sintomi | Migraine Log e Symptile, entrambe open source |
| | Umore | Health "Stato d'animo" + Diario; Pixy/MoodSnap open source |
| | Respirazione | Mindfulness su Watch; Deep Breathe gratis |
| | Contrazioni | Contraction Timer & Tracker ++ gratis (80 val.) |
| | Gratitudine | Gratitude Jar (401 val.) + Diario |
| | Acqua | Affollamento 4.3 massimo |
| | Alcol, fumo, caffeina | DrinkControl free tier; Quit Smoking Counter; HiCoffee piccolo |
| | 1RM/dischi, 20-20-20 | WOTools gratis; nessun mercato iPhone a pagamento |
| Creativo/formazione | Ear training | OpenEar open source; Tenuto 4,99 $ una tantum |
| | Scale/circolo delle quinte | Nessun leader (Scales Pro 289 val.) |
| | Looper, piano MIDI | GarageBand; Loopy Pro una tantum |
| | Dattilografia, Morse | Nessun leader; GreatTyping gratis |
| | Calcolatrice grafica | Desmos gratis offline; Math Notes |
| | Coniugatore verbi | Contenuto (dataset) non tool |
| | Pose 3D | Asset riggati = contenuto |
| | Pixel art | Sprite Pencil open source; scope 10–15 giorni |
| | Chess clock, initiative tracker | Chess.com Chess Clock gratis; Easy Initiative Tracker gratis |

## Conclusione: ordine di costruzione e verifiche da fare prima di aprire Xcode

L'ordine proposto per le prossime sei app alterna colpi rapidi con weekly riconoscibili e app medie con base enorme, e lascia Sbu Remote dov'è (Wave 3) perché resta la più costosa: **1) Sbu Find** (cerca-Bluetooth, 3–5 giorni, "7,99 $ a settimana per ritrovare le cuffie" = 415 $/anno, nessun rischio review serio); **2) Sbu Shrink** (compressore video, 5–8 giorni, 6,99 $/sett. = 363 $/anno, demo prima/dopo perfetta per il video da 20 secondi); **3) Sbu Grid** (griglia per disegno, 3–5 giorni, GridArt 3,99 $/sett. = 207 $/anno, pubblico r/learnart molto attivo); **4) Sbu Tidy** (pulizie alla Tody, 5–8 giorni, nicchia con 4.3 basso e due originali da 10K); **5) Sbu Libretto** (5–8 giorni, da pubblicare prima della sessione invernale e lanciare sul Discord SecAI come caso-studio locale); **6) Sbu Meds** (farmaci multi-persona, 7–10 giorni, dopo Sbu Cycle così l'esperienza HealthKit/1.4.1 è già fatta, con la storia "Medisafe ha messo a pagamento i profili famiglia nel 2026"). Subito dopo: Sbu Remote seguito dal cast DLNA che ne riusa un terzo del codice, poi il trittico veloce resize/GIF/tag editor appena chiuse le verifiche. Tre correzioni alla roadmap attuale emergono dai dati: Sbu BP e Sbu Pulse vanno tolte dalla riserva (alternative pulite e rischio 1.4.1), Paprika e Money Pro vanno tolte dalla vecchia Wave 2 (Crouton e Dime le coprono), mentre Slow Shutter/NightCap resta valida ma come PASS condizionato.

Le verifiche ancora aperte si fanno in un pomeriggio dal Mac, dove l'API iTunes non è bloccata: conteggi esatti di valutazioni con `itunes.apple.com/lookup` (tutti i numeri qui sono arrotondati dalle schede HTML); ricerche Reddit "free alternative to X" per knitting, speed reading, GIF, video compressor e image resizer, saltate per esaurimento del budget; numero di valutazioni di Smart Receipts e ricerca "scontrini" sullo store IT; cosa limita davvero il free tier di Wunderfind e iNet; se foobar2000 iOS modifica i tag; se MuPDF è ancora scaricabile; se Salute in iOS 26 ha aggiunto profili multipli per i farmaci; tempi 2026 di approvazione dell'entitlement multicast (i thread trovati sono del 2020); se Fontcase funziona su iOS 26; encoding WebP in ImageIO; disponibilità sullo store IT di Chord Finder • Guitar, GridArt, Knit Pro e Stitch Keeper. Restano del tutto non valutate, per mancanza di tempo, tre nicchie potenzialmente grosse: i Live Photo tools (intoLive, 114K valutazioni a 3,99 $/sett.), il batch rename di file e l'agenda ripetizioni per tutor freelance.