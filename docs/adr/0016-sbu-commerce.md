# Sbu Commerce: un backend open source e self-hosted per gli storefront di SAP Commerce

sbu.dev ha tre rami: **App** (le app iPhone più vendute rifatte gratis), **Giochi** (i giochi più giocati rifatti senza pubblicità, ADR-0015) e **Commerce**. Il primo prodotto di Commerce è **Sbu Commerce**: un backend e-commerce open source (MIT) che espone la stessa API OCC degli storefront Spartacus / Composable Storefront, così chi lascia SAP Commerce Cloud cambia backend senza rifare il sito.

- **Self-hosted, mai ospitato da sbu.dev.** Lo installa chi lo usa, sui propri server (Docker). sbu.dev non gestisce server, account o dati dei clienti: la promessa "i dati restano a chi li possiede" vale anche qui. È software server per natura, quindi la regola delle App Sbu "nessuna chiamata di rete" non si applica a Commerce.
- **Interoperabilità solo da materiale pubblico** (come ADR-0003): la documentazione pubblica dell'API OCC e il codice open source di Spartacus (Apache 2.0). Mai codice, binari, dati o documentazione riservata di SAP. Mai "SAP" nel nome del prodotto o del repo; sul sito solo confronti fattuali e la nota sui marchi.
- **Repo separato**, `mgiuditta/sbu-commerce`: il monorepo `sbu-apps` resta iOS e sito. Lo stack del backend si sceglie dopo lo spike di compatibilità (catalogo, carrello) con lo storefront Spartacus di riferimento.
- **Nessuna versione a pagamento con funzioni chiuse.** Un eventuale ricavo (consulenza, supporto) si decide più avanti e non cambia il codice aperto.
- **Copertura dichiarata**: una tabella pubblica, endpoint per endpoint, di cosa funziona e cosa no.

Motivo: il commerce enterprise costa 150–700 k$ l'anno tra licenza e integratori, e la fine del supporto on-premise e dello storefront Accelerator spinge molte aziende a migrare. Le alternative open source (Medusa, Saleor, Shopware, Vendure) chiedono di rifare lo storefront; un backend compatibile OCC no. È anche il mestiere del founder, che conosce SAP Commerce e Spartacus dall'interno.
