# Il ramo Software e Sbu Commerce, il suo primo progetto

sbu.dev ha tre rami: **App** (le app iPhone più vendute rifatte gratis), **Giochi** (i giochi più giocati rifatti senza pubblicità, ADR-0015) e **Software** (il software che le aziende pagano, rifatto open source, `sbu.dev/software`). Le regole qui sotto valgono per ogni progetto Software. Il primo è **Sbu Commerce** (`sbu.dev/software/commerce`): un backend e-commerce open source (MIT) per il B2B, al posto delle piattaforme enterprise a licenza.

- **Self-hosted, mai ospitato da sbu.dev.** Lo installa chi lo usa, sui propri server (Docker). sbu.dev non gestisce server, account o dati dei clienti: la promessa "i dati restano a chi li possiede" vale anche qui. È software server per natura, quindi la regola delle App Sbu "nessuna chiamata di rete" non si applica ai progetti Software.
- **Interoperabilità solo da materiale pubblico** (come ADR-0003): documentazione pubblica e codice open source. Mai codice, binari, dati o documentazione riservata di altri prodotti, mai il loro marchio nel nome del progetto o del repo.
- **Un repo per progetto**, qui `mgiuditta/sbu-commerce`: il monorepo `sbu-apps` resta iOS e sito. Lo stack si sceglie dopo il primo spike (catalogo, carrello).
- **Nessuna versione a pagamento con funzioni chiuse.** Un eventuale ricavo (consulenza, supporto) si decide più avanti e non cambia il codice aperto.
- **Copertura dichiarata**: una tabella pubblica di cosa funziona e cosa no.

Motivo: il commerce enterprise costa centinaia di migliaia di euro l'anno tra licenza e integratori, e le alternative open source chiedono spesso di rifare tutto. Un backend aperto che si adatta a ciò che le aziende hanno già abbassa il costo di uscita. È anche il mestiere del founder.
